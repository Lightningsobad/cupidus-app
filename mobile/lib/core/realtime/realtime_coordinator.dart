import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;

import 'package:flutter/widgets.dart';

import '../auth/cupid_session.dart';
import 'backend_user_id_store.dart';
import 'cupid_realtime.dart';
import 'fcm_transport.dart';
import 'pending_event_store.dart';
import 'socket_transport.dart';

/// Injectable seam over `AppLifecycleListener` (`master-plan.md` §3 "an
/// injectable lifecycle source"), so tests drive a fake instead of the real
/// widgets-binding lifecycle (ADR-012g transition machine).
abstract interface class RealtimeLifecycleSource {
  /// The state at construction time, used to drive the initial transition
  /// from `RealtimeCoordinator.start()` before any [states] event fires.
  AppLifecycleState get currentState;

  Stream<AppLifecycleState> get states;

  void dispose();
}

class _AppLifecycleRealtimeSource implements RealtimeLifecycleSource {
  _AppLifecycleRealtimeSource() {
    _listener = AppLifecycleListener(onStateChange: _controller.add);
  }

  final _controller = StreamController<AppLifecycleState>.broadcast(
    sync: true,
  );
  late final AppLifecycleListener _listener;

  @override
  AppLifecycleState get currentState =>
      WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;

  @override
  Stream<AppLifecycleState> get states => _controller.stream;

  @override
  void dispose() {
    _listener.dispose();
    _controller.close();
  }
}

/// Injectable seam for the ~30s grace-window timer (ADR-012g.2), so tests
/// assert the scheduled [Duration] and fire [onElapsed] deterministically
/// instead of waiting on a real timer.
typedef GraceTimerFactory = Timer Function(
  Duration duration,
  void Function() onElapsed,
);

Timer _defaultGraceTimerFactory(
  Duration duration,
  void Function() onElapsed,
) =>
    Timer(duration, onElapsed);

/// iOS fires `inactive`/`paused` for the notification shade, app switcher,
/// and incoming calls; disconnecting on the first signal causes reconnect
/// storms (ADR-012g.2).
const Duration realtimeGraceDuration = Duration(seconds: 30);

/// Bounded page-1 gap-fill fetch (ADR-012g.3, ADR-007). The frozen `resync()`
/// contract (`cupid_realtime.dart` §2) takes no parameters and the
/// coordinator has no chat-partner scope, so the actual `GET /messages`
/// page-1 call reconciled by id is supplied by feature code that knows the
/// partner. The default is a no-op so a coordinator used before any feature
/// wires a fetcher never throws.
typedef ResyncFetcher = Future<List<RealtimeEvent>> Function();

Future<List<RealtimeEvent>> _defaultResyncFetcher() async =>
    const <RealtimeEvent>[];

void _defaultLog(String message) =>
    developer.log(message, name: 'RealtimeCoordinator');

/// Bounded LRU seen-id set (ADR-012d: 512 entries) for durable-event dedup.
class _BoundedSeenIds {
  _BoundedSeenIds(this.maxLength);

  final int maxLength;
  final LinkedHashSet<String> _ids = LinkedHashSet<String>();

  bool contains(String id) => _ids.contains(id);

  void add(String id) {
    // Re-inserting moves the id to the most-recently-used position so the
    // bound evicts the truly oldest entry first.
    _ids
      ..remove(id)
      ..add(id);
    while (_ids.length > maxLength) {
      _ids.remove(_ids.first);
    }
  }

  void clear() => _ids.clear();
}

/// Concrete `RealtimeCoordinator` (`architecture/solution.md` §2, ADR-012a/
/// d/g). Merges the socket and FCM transports into one deduped broadcast
/// stream and runs the never-two-live-sources lifecycle machine. Also
/// implements `SessionScopedStore` (`core/auth/cupid_session.dart`) so
/// `service_locator.dart` can enroll it in `CupidSession`'s ordered
/// sign-out teardown (§2 Lifecycle contract).
class RealtimeCoordinatorImpl implements RealtimeCoordinator, SessionScopedStore {
  RealtimeCoordinatorImpl({
    required SocketTransport socket,
    required FcmTransport fcm,
    required PendingEventStore pendingEventStore,
    required BackendUserIdStore backendUserIdStore,
    RealtimeLifecycleSource? lifecycleSource,
    GraceTimerFactory graceTimerFactory = _defaultGraceTimerFactory,
    Duration graceDuration = realtimeGraceDuration,
    ResyncFetcher resyncFetcher = _defaultResyncFetcher,
    int maxSeenIds = 512,
    void Function(String message) log = _defaultLog,
  })  : _socket = socket,
        _fcm = fcm,
        _pendingEventStore = pendingEventStore,
        _backendUserIdStore = backendUserIdStore,
        _lifecycleSource = lifecycleSource ?? _AppLifecycleRealtimeSource(),
        _graceTimerFactory = graceTimerFactory,
        _graceDuration = graceDuration,
        _resyncFetcher = resyncFetcher,
        _seenIds = _BoundedSeenIds(maxSeenIds),
        _log = log;

  final SocketTransport _socket;
  final FcmTransport _fcm;
  final PendingEventStore _pendingEventStore;
  final BackendUserIdStore _backendUserIdStore;
  final RealtimeLifecycleSource _lifecycleSource;
  final GraceTimerFactory _graceTimerFactory;
  final Duration _graceDuration;
  final ResyncFetcher _resyncFetcher;
  final _BoundedSeenIds _seenIds;
  final void Function(String message) _log;

  final _eventsController = StreamController<RealtimeEvent>.broadcast(
    sync: true,
  );
  final _statusController = StreamController<RealtimeStatus>.broadcast(
    sync: true,
  );

  StreamSubscription<SocketTransportEvent>? _socketEventsSubscription;
  StreamSubscription<RealtimeStatus>? _socketStatusSubscription;
  StreamSubscription<RealtimeEvent>? _fcmEventsSubscription;
  StreamSubscription<AppLifecycleState>? _lifecycleSubscription;
  Timer? _graceTimer;

  bool _started = false;
  // Not-yet-started is modeled as "not foreground" so the very first
  // transition to `resumed` is treated as a resume (drain + resync), which
  // also covers a cold start with events queued from a previous session.
  bool _foreground = false;
  RealtimeStatus _status = RealtimeStatus.offline;
  int _droppedDuplicateCount = 0;

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) {
    final stream = _eventsController.stream;
    return names == null
        ? stream
        : stream.where((event) => names.contains(event.name));
  }

  @override
  Stream<RealtimeStatus> get status => _statusController.stream;

  @override
  Future<void> start() async {
    if (_started) return;
    _started = true;

    _socketEventsSubscription = _socket.events.listen(_handleSocketEvent);
    _socketStatusSubscription = _socket.status.listen(_handleSocketStatus);
    _fcmEventsSubscription =
        _fcm.foregroundEvents.listen(_handleForegroundFcmEvent);
    _fcm.start();

    _lifecycleSubscription =
        _lifecycleSource.states.listen(_handleLifecycleState);
    await _applyLifecycleState(_lifecycleSource.currentState);
  }

  @override
  Future<void> stop() async {
    if (!_started) return;
    _started = false;

    await _lifecycleSubscription?.cancel();
    _lifecycleSubscription = null;
    _cancelGraceTimer();

    await _socketEventsSubscription?.cancel();
    _socketEventsSubscription = null;
    await _socketStatusSubscription?.cancel();
    _socketStatusSubscription = null;
    await _fcmEventsSubscription?.cancel();
    _fcmEventsSubscription = null;

    await _socket.stop();
    await _fcm.stop();

    _foreground = false;
    _setStatus(RealtimeStatus.offline);
  }

  @override
  Future<void> emit(String name, Object? payload) async {
    if (_status != RealtimeStatus.live) {
      throw const RealtimeNotLiveFailure();
    }
    await _socket.emit(name, payload);
  }

  @override
  Future<void> resync() async {
    final events = await _resyncFetcher();
    for (final event in events) {
      _emitDeduped(event);
    }
  }

  @override
  Future<void> clearOnSignOut() async {
    await stop();
    _seenIds.clear();
    _droppedDuplicateCount = 0;
    // `clearOnSignOut()` is `PendingEventStore`'s only public "clear"
    // operation — this phase's write scope excludes pending_event_store.dart
    // — and it happens to do exactly what AC4 needs here: empty the
    // persisted queue.
    await _pendingEventStore.clearOnSignOut();
    await _backendUserIdStore.clearOnSignOut();
  }

  void _handleLifecycleState(AppLifecycleState state) {
    // The stream listener stays synchronous; `_applyLifecycleState` awaits
    // the socket restart / drain / resync internally as a background task.
    _applyLifecycleState(state);
  }

  Future<void> _applyLifecycleState(AppLifecycleState state) async {
    _log('lifecycle: ${state.name}');
    if (state == AppLifecycleState.resumed) {
      await _enterForeground();
    } else if (state == AppLifecycleState.detached) {
      await _enterBackgroundImmediately();
    } else {
      // inactive, paused, hidden (ADR-012g.2 grace window).
      _enterBackgroundGraceWindow();
    }
  }

  Future<void> _enterForeground() async {
    _cancelGraceTimer();
    final wasForeground = _foreground;
    _foreground = true;
    // Idempotent: reconnects + re-joins only if the socket was actually
    // stopped (grace elapsed) or never started.
    await _socket.start();
    if (!wasForeground) {
      // ADR-012g.3: drain the persisted queue through the same dedup gate,
      // then run the bounded REST resync.
      await _drainPendingQueue();
      await resync();
    }
  }

  void _enterBackgroundGraceWindow() {
    if (!_foreground) return;
    _foreground = false;
    _graceTimer ??= _graceTimerFactory(_graceDuration, _disconnectAfterGrace);
  }

  Future<void> _enterBackgroundImmediately() async {
    _foreground = false;
    _cancelGraceTimer();
    await _socket.stop();
    _setStatus(RealtimeStatus.degraded);
  }

  void _disconnectAfterGrace() {
    _graceTimer = null;
    _socket.stop();
    _setStatus(RealtimeStatus.degraded);
  }

  void _cancelGraceTimer() {
    _graceTimer?.cancel();
    _graceTimer = null;
  }

  Future<void> _drainPendingQueue() async {
    final queued = await _pendingEventStore.loadAll();
    for (final event in queued) {
      _emitDeduped(event);
    }
  }

  void _handleSocketEvent(SocketTransportEvent raw) {
    _emitDeduped(_classifySocketEvent(raw));
  }

  void _handleForegroundFcmEvent(RealtimeEvent event) {
    if (_foreground) {
      // ADR-012g.1: the socket is authoritative while resumed; discarding
      // the foreground FCM message here — rather than relying on dedup —
      // is what makes AC2's no-duplicate property structural.
      _log('Discarded foreground FCM message (socket authoritative)');
      return;
    }
    _emitDeduped(event);
  }

  void _handleSocketStatus(RealtimeStatus socketStatus) {
    if (_foreground) {
      _setStatus(socketStatus);
    }
    // While backgrounded, raw socket status changes (e.g. the disconnect our
    // own `stop()` call triggers) are superseded by `degraded`, set by the
    // background transition handlers.
  }

  void _emitDeduped(RealtimeEvent event) {
    if (event.isEphemeral) {
      // ADR-012d: ephemeral events cannot be deduped and are never
      // FCM-delivered, so they are dropped outright while not foreground.
      if (!_foreground) return;
      _eventsController.add(event);
      return;
    }
    final id = event.id!;
    if (_seenIds.contains(id)) {
      _droppedDuplicateCount++;
      _log('Dropped duplicate durable event, total=$_droppedDuplicateCount');
      return;
    }
    _seenIds.add(id);
    _eventsController.add(event);
  }

  RealtimeEvent _classifySocketEvent(SocketTransportEvent raw) {
    final rawData = raw.data;
    final data = rawData is Map
        ? Map<String, dynamic>.from(rawData)
        : <String, dynamic>{};
    final rawId = data['id'];
    final id = rawId is String && rawId.isNotEmpty ? rawId : null;
    return GenericRealtimeEvent(
      name: raw.name,
      id: id,
      data: data,
      transport: RealtimeTransport.socket,
      receivedAt: DateTime.now(),
    );
  }

  void _setStatus(RealtimeStatus value) {
    if (_status == value) return;
    _status = value;
    _statusController.add(value);
  }
}
