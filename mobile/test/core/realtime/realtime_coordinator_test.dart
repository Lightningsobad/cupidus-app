import 'dart:async';

import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/core/realtime/fcm_transport.dart';
import 'package:cupid_mobile/core/realtime/pending_event_store.dart';
import 'package:cupid_mobile/core/realtime/realtime_coordinator.dart';
import 'package:cupid_mobile/core/realtime/socket_transport.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fake [RealtimeSocket]: never opens a real connection. Reimplemented here
/// (rather than shared) because `socket_transport_test.dart`'s equivalent
/// fake is private to that file.
class _EmitCall {
  _EmitCall(this.event, this.data, this.completer);

  final String event;
  final dynamic data;
  final Completer<dynamic> completer;
}

class _FakeRealtimeSocket implements RealtimeSocket {
  int connectCalls = 0;
  int disconnectCalls = 0;
  final List<_EmitCall> emitCalls = [];

  dynamic Function(dynamic)? _connectHandler;
  dynamic Function(dynamic)? _disconnectHandler;
  dynamic Function(String, dynamic)? _anyHandler;

  @override
  void connect() => connectCalls++;

  @override
  void disconnect() => disconnectCalls++;

  @override
  void onConnect(dynamic Function(dynamic payload) handler) =>
      _connectHandler = handler;

  @override
  void onConnectError(dynamic Function(dynamic payload) handler) {
    // No test in this file exercises the connect-error/token-refresh path
    // (already covered by `socket_transport_test.dart`), so the handler is
    // accepted but not stored.
  }

  @override
  void onDisconnect(dynamic Function(dynamic payload) handler) =>
      _disconnectHandler = handler;

  @override
  void onAny(dynamic Function(String event, dynamic payload) handler) =>
      _anyHandler = handler;

  @override
  Future<dynamic> emitWithAckAsync(String event, dynamic data) {
    final completer = Completer<dynamic>();
    emitCalls.add(_EmitCall(event, data, completer));
    return completer.future;
  }

  @override
  set auth(Map<String, dynamic> value) {}

  Future<void> fireConnect() async => await _connectHandler?.call(null);

  void fireDisconnect() => _disconnectHandler?.call(null);

  void fireAny(String event, dynamic data) => _anyHandler?.call(event, data);

  void ackLastEmit([dynamic response]) {
    emitCalls.last.completer.complete(response);
  }
}

/// Drives the real [SocketTransport] all the way to `RealtimeStatus.live`
/// using the `fireConnect()` / `ackLastEmit()` handshake pattern from
/// `socket_transport_test.dart`.
Future<void> _bringSocketLive(_FakeRealtimeSocket fake) async {
  final connectHandled = fake.fireConnect();
  await Future<void>.delayed(Duration.zero);
  fake.ackLastEmit({'event': 'joinedRoom'});
  await connectHandled;
}

class _FakeLifecycleSource implements RealtimeLifecycleSource {
  @override
  AppLifecycleState currentState = AppLifecycleState.resumed;

  final _controller = StreamController<AppLifecycleState>.broadcast(
    sync: true,
  );

  @override
  Stream<AppLifecycleState> get states => _controller.stream;

  void emit(AppLifecycleState state) {
    currentState = state;
    _controller.add(state);
  }

  @override
  void dispose() {}
}

class _FakeGraceTimer implements Timer {
  _FakeGraceTimer(this._onElapsed);

  final void Function() _onElapsed;
  bool _cancelled = false;

  void fire() {
    if (!_cancelled) _onElapsed();
  }

  @override
  void cancel() => _cancelled = true;

  @override
  bool get isActive => !_cancelled;

  @override
  int get tick => 0;
}

class _FakeGraceTimerFactory {
  Duration? lastDuration;
  _FakeGraceTimer? lastTimer;
  int callCount = 0;

  Timer call(Duration duration, void Function() onElapsed) {
    callCount++;
    lastDuration = duration;
    final timer = _FakeGraceTimer(onElapsed);
    lastTimer = timer;
    return timer;
  }
}

/// Default grace-timer factory for tests that don't exercise grace timing:
/// an inert fake that never auto-fires, so no real `Timer` is ever left
/// pending after a test completes.
Timer _inertGraceTimerFactory(Duration duration, void Function() onElapsed) =>
    _FakeGraceTimer(onElapsed);

RealtimeCoordinatorImpl _buildCoordinator({
  required _FakeRealtimeSocket fakeSocket,
  required PendingEventStore pendingEventStore,
  required BackendUserIdStore backendUserIdStore,
  required _FakeLifecycleSource lifecycleSource,
  Stream<RemoteMessage> Function()? fcmMessageStream,
  GraceTimerFactory graceTimerFactory = _inertGraceTimerFactory,
  ResyncFetcher resyncFetcher = _noOpResync,
  int maxSeenIds = 512,
  List<String>? logSink,
}) {
  return RealtimeCoordinatorImpl(
    socket: SocketTransport(
      url: 'http://localhost',
      idToken: ({bool forceRefresh = false}) async => 'token',
      idTokenStream: const Stream<String?>.empty(),
      backendUserId: () async => 'user-1',
      socketFactory: (url, options) => fakeSocket,
    ),
    fcm: FcmTransport(
      messageStreamFactory:
          fcmMessageStream ?? () => const Stream<RemoteMessage>.empty(),
      registerBackgroundHandler: (_) {},
    ),
    pendingEventStore: pendingEventStore,
    backendUserIdStore: backendUserIdStore,
    lifecycleSource: lifecycleSource,
    graceTimerFactory: graceTimerFactory,
    resyncFetcher: resyncFetcher,
    maxSeenIds: maxSeenIds,
    log: logSink == null ? _noOpLog : logSink.add,
  );
}

Future<List<RealtimeEvent>> _noOpResync() async => const <RealtimeEvent>[];

void _noOpLog(String message) {}

RealtimeEvent _durableEvent(String id, {String name = 'chat.messageCreated'}) =>
    GenericRealtimeEvent(
      name: name,
      id: id,
      data: const {'text': 'hi'},
      transport: RealtimeTransport.fcmBackgroundReplay,
      receivedAt: DateTime.utc(2026, 7, 30),
    );

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('RealtimeCoordinator dedup (ADR-012d, AC1/AC2)', () {
    test(
        'the same durable id delivered via the socket and via a queued FCM '
        'replay yields exactly one event', () async {
      final fakeSocket = _FakeRealtimeSocket();
      final pendingStore = PendingEventStore();
      final lifecycle = _FakeLifecycleSource();
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: pendingStore,
        backendUserIdStore: BackendUserIdStore(),
        lifecycleSource: lifecycle,
      );

      final events = <RealtimeEvent>[];
      coordinator.events().listen(events.add);

      await coordinator.start();
      await _bringSocketLive(fakeSocket);

      // Overlap window (ADR-012g): the socket delivers the durable id...
      fakeSocket.fireAny('chat.messageCreated', {'id': 'msg-1', 'text': 'hi'});
      await Future<void>.delayed(Duration.zero);

      // ...and the same id was also queued via the FCM background replay
      // path (simulating grace-window overlap).
      await pendingStore.append(_durableEvent('msg-1'));

      lifecycle.emit(AppLifecycleState.paused);
      lifecycle.emit(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      expect(events.where((e) => e.id == 'msg-1'), hasLength(1));
    });

    test('a foreground FCM message is discarded while resumed, and the '
        'socket event for the same id still arrives exactly once', () async {
      final fakeSocket = _FakeRealtimeSocket();
      final fcmController = StreamController<RemoteMessage>();
      final lifecycle = _FakeLifecycleSource();
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: PendingEventStore(),
        backendUserIdStore: BackendUserIdStore(),
        lifecycleSource: lifecycle,
        fcmMessageStream: () => fcmController.stream,
      );

      final events = <RealtimeEvent>[];
      coordinator.events().listen(events.add);

      await coordinator.start();
      await _bringSocketLive(fakeSocket);

      fcmController.add(
        RemoteMessage(
          data: {
            'cupid_event': 'chat.messageCreated',
            'cupid_event_id': 'msg-2',
          },
        ),
      );
      await Future<void>.delayed(Duration.zero);

      fakeSocket.fireAny('chat.messageCreated', {'id': 'msg-2', 'text': 'hi'});
      await Future<void>.delayed(Duration.zero);

      final matching = events.where((e) => e.id == 'msg-2');
      expect(matching, hasLength(1));
      expect(matching.single.transport, RealtimeTransport.socket);

      await fcmController.close();
    });
  });

  group('lifecycle transition machine (ADR-012g)', () {
    test(
        'resumed -> paused -> resumed (grace not elapsed) produces no '
        'duplicate and no dropped durable event, and preserves order',
        () async {
      final fakeSocket = _FakeRealtimeSocket();
      final lifecycle = _FakeLifecycleSource();
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: PendingEventStore(),
        backendUserIdStore: BackendUserIdStore(),
        lifecycleSource: lifecycle,
      );

      final events = <RealtimeEvent>[];
      coordinator.events().listen(events.add);

      await coordinator.start();
      await _bringSocketLive(fakeSocket);

      fakeSocket.fireAny('chat.messageCreated', {'id': 'm1', 'text': 'hi'});
      await Future<void>.delayed(Duration.zero);

      lifecycle.emit(AppLifecycleState.paused);
      lifecycle.emit(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      fakeSocket.fireAny('chat.messageCreated', {'id': 'm2', 'text': 'hi'});
      await Future<void>.delayed(Duration.zero);

      expect(events.map((e) => e.id), ['m1', 'm2']);
      // The socket was never actually stopped (grace not elapsed), so
      // start()'s reconnect-on-resume is a no-op: exactly one connect call.
      expect(fakeSocket.connectCalls, 1);
    });

    test('the socket is not disconnected before the grace window elapses, '
        'and disconnects to RealtimeStatus.degraded once it does', () async {
      final fakeSocket = _FakeRealtimeSocket();
      final lifecycle = _FakeLifecycleSource();
      final graceFactory = _FakeGraceTimerFactory();
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: PendingEventStore(),
        backendUserIdStore: BackendUserIdStore(),
        lifecycleSource: lifecycle,
        graceTimerFactory: graceFactory.call,
      );

      final statuses = <RealtimeStatus>[];
      coordinator.status.listen(statuses.add);

      await coordinator.start();
      await _bringSocketLive(fakeSocket);

      lifecycle.emit(AppLifecycleState.paused);

      expect(graceFactory.callCount, 1);
      expect(graceFactory.lastDuration, const Duration(seconds: 30));
      expect(fakeSocket.disconnectCalls, 0);

      graceFactory.lastTimer!.fire();
      // `SocketTransport.stop()` awaits its token-subscription cancellation
      // before calling `disconnect()`, so the disconnect lands on the next
      // microtask rather than synchronously with `fire()`.
      await Future<void>.delayed(Duration.zero);

      expect(fakeSocket.disconnectCalls, 1);
      expect(statuses.last, RealtimeStatus.degraded);
    });

    test('ephemeral events are dropped while not foreground and are never '
        'queued', () async {
      final fakeSocket = _FakeRealtimeSocket();
      final lifecycle = _FakeLifecycleSource();
      final pendingStore = PendingEventStore();
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: pendingStore,
        backendUserIdStore: BackendUserIdStore(),
        lifecycleSource: lifecycle,
      );

      final events = <RealtimeEvent>[];
      coordinator.events().listen(events.add);

      await coordinator.start();
      await _bringSocketLive(fakeSocket);

      lifecycle.emit(AppLifecycleState.paused);

      // Simulates a server-delivered ephemeral event (no id) arriving in the
      // grace-window overlap, before the socket is actually disconnected.
      fakeSocket.fireAny('chat.ghostTyping', {'senderId': 'u1'});
      await Future<void>.delayed(Duration.zero);

      expect(events, isEmpty);
      expect(await pendingStore.loadAll(), isEmpty);
    });

    test(
        'a background-injected event is drained on resume in order, '
        'followed by resync catch-up events, with no duplicate and no '
        'dropped durable event', () async {
      final fakeSocket = _FakeRealtimeSocket();
      final lifecycle = _FakeLifecycleSource();
      final pendingStore = PendingEventStore();
      // `start()` itself models the initial transition-to-resumed as a
      // resume (so a cold start also drains/resyncs), so the first
      // `resync()` call happens during `start()` rather than after the
      // pause/resume this test drives. Return the catch-up event only from
      // the *second* call, isolating the post-resume resync this test
      // targets.
      var resyncCalls = 0;
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: pendingStore,
        backendUserIdStore: BackendUserIdStore(),
        lifecycleSource: lifecycle,
        resyncFetcher: () async {
          resyncCalls++;
          return resyncCalls == 1 ? const <RealtimeEvent>[] : [_durableEvent('e3')];
        },
      );

      final events = <RealtimeEvent>[];
      coordinator.events().listen(events.add);

      await coordinator.start();
      await _bringSocketLive(fakeSocket);

      // Delivered live via the socket while resumed.
      fakeSocket.fireAny('chat.messageCreated', {'id': 'e1', 'text': 'hi'});
      await Future<void>.delayed(Duration.zero);

      lifecycle.emit(AppLifecycleState.paused);

      // Simulates the FCM background isolate persisting a durable event
      // while the app is backgrounded (`fcmBackgroundMessageHandler` writes
      // to the same `PendingEventStore`) — no socket delivery for this id
      // at all, so this is a genuine "no drop" case, not a dedup overlap.
      await pendingStore.append(_durableEvent('e2'));

      lifecycle.emit(AppLifecycleState.resumed);
      await Future<void>.delayed(Duration.zero);

      // ADR-012g.3: the queue drains before the REST resync runs, so the
      // queued event precedes the resync catch-up event and arrival order
      // is preserved end to end.
      expect(events.map((e) => e.id), ['e1', 'e2', 'e3']);
    });
  });

  group('emit (ADR-012h)', () {
    test('throws RealtimeNotLiveFailure when status is not live', () async {
      final fakeSocket = _FakeRealtimeSocket();
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: PendingEventStore(),
        backendUserIdStore: BackendUserIdStore(),
        lifecycleSource: _FakeLifecycleSource(),
      );

      await expectLater(
        () => coordinator.emit('sendMessage', {'text': 'hi'}),
        throwsA(isA<RealtimeNotLiveFailure>()),
      );
    });

    test('forwards to the socket transport once live', () async {
      final fakeSocket = _FakeRealtimeSocket();
      final lifecycle = _FakeLifecycleSource();
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: PendingEventStore(),
        backendUserIdStore: BackendUserIdStore(),
        lifecycleSource: lifecycle,
      );

      await coordinator.start();
      await _bringSocketLive(fakeSocket);

      final future = coordinator.emit('sendMessage', {'text': 'hi'});
      await Future<void>.delayed(Duration.zero);
      fakeSocket.ackLastEmit('ok');
      await future;

      expect(
        fakeSocket.emitCalls.map((c) => c.event),
        containsAll(['sendMessage']),
      );
    });
  });

  group('start() idempotence', () {
    test('start() called twice opens only one connection', () async {
      final fakeSocket = _FakeRealtimeSocket();
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: PendingEventStore(),
        backendUserIdStore: BackendUserIdStore(),
        lifecycleSource: _FakeLifecycleSource(),
      );

      await coordinator.start();
      await coordinator.start();

      expect(fakeSocket.connectCalls, 1);
    });
  });

  group('LRU bound (ADR-012d: 512 entries)', () {
    test('an id evicted from the bound is no longer treated as seen',
        () async {
      final fakeSocket = _FakeRealtimeSocket();
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: PendingEventStore(),
        backendUserIdStore: BackendUserIdStore(),
        lifecycleSource: _FakeLifecycleSource(),
        maxSeenIds: 3,
      );

      final events = <RealtimeEvent>[];
      coordinator.events().listen(events.add);

      await coordinator.start();
      await _bringSocketLive(fakeSocket);

      for (final id in ['a', 'b', 'c', 'd']) {
        fakeSocket.fireAny('chat.messageCreated', {'id': id, 'text': 'hi'});
      }
      await Future<void>.delayed(Duration.zero);

      // Re-inject 'a', which fell out of the bound-3 LRU (b, c, d remain).
      fakeSocket.fireAny('chat.messageCreated', {'id': 'a', 'text': 'hi'});
      await Future<void>.delayed(Duration.zero);

      expect(events.where((e) => e.id == 'a'), hasLength(2));
    });
  });

  group('clearOnSignOut (AC4)', () {
    test('clears the LRU, the pending queue, the room key, and disconnects',
        () async {
      final fakeSocket = _FakeRealtimeSocket();
      final pendingStore = PendingEventStore();
      final backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-1'});
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: pendingStore,
        backendUserIdStore: backendUserIdStore,
        lifecycleSource: _FakeLifecycleSource(),
      );

      final events = <RealtimeEvent>[];
      coordinator.events().listen(events.add);

      await coordinator.start();
      await _bringSocketLive(fakeSocket);

      fakeSocket.fireAny('chat.messageCreated', {'id': 'msg-1', 'text': 'hi'});
      await Future<void>.delayed(Duration.zero);
      await pendingStore.append(_durableEvent('msg-2'));

      await coordinator.clearOnSignOut();

      expect(fakeSocket.disconnectCalls, 1);
      expect(await pendingStore.loadAll(), isEmpty);
      expect(backendUserIdStore.backendUserId, isNull);

      // The LRU is empty: re-injecting the same id after signout emits it
      // again rather than deduping it away.
      await coordinator.start();
      await _bringSocketLive(fakeSocket);
      fakeSocket.fireAny('chat.messageCreated', {'id': 'msg-1', 'text': 'hi'});
      await Future<void>.delayed(Duration.zero);

      expect(events.where((e) => e.id == 'msg-1'), hasLength(2));
    });
  });

  group('log output never contains payload contents or tokens', () {
    test('dropped-duplicate and discarded-FCM log lines omit payload data',
        () async {
      final fakeSocket = _FakeRealtimeSocket();
      final fcmController = StreamController<RemoteMessage>();
      final lifecycle = _FakeLifecycleSource();
      final logged = <String>[];
      final coordinator = _buildCoordinator(
        fakeSocket: fakeSocket,
        pendingEventStore: PendingEventStore(),
        backendUserIdStore: BackendUserIdStore(),
        lifecycleSource: lifecycle,
        fcmMessageStream: () => fcmController.stream,
        logSink: logged,
      );

      await coordinator.start();
      await _bringSocketLive(fakeSocket);

      const secretPayload = 'super-secret-token-xyz';
      fcmController.add(
        RemoteMessage(
          data: {
            'cupid_event': 'chat.messageCreated',
            'cupid_event_id': 'msg-3',
            'cupid_payload': '{"text":"$secretPayload"}',
          },
        ),
      );
      await Future<void>.delayed(Duration.zero);

      fakeSocket.fireAny(
        'chat.messageCreated',
        {'id': 'msg-3', 'text': secretPayload},
      );
      await Future<void>.delayed(Duration.zero);
      fakeSocket.fireAny(
        'chat.messageCreated',
        {'id': 'msg-3', 'text': secretPayload},
      );
      await Future<void>.delayed(Duration.zero);

      expect(logged, isNotEmpty);
      for (final line in logged) {
        expect(line.contains(secretPayload), isFalse);
      }

      await fcmController.close();
    });
  });

  group('DI registration', () {
    setUp(getIt.reset);
    tearDown(getIt.reset);

    test('setupServiceLocator() registers RealtimeCoordinator through get_it',
        () {
      setupServiceLocator();

      expect(getIt.isRegistered<RealtimeCoordinator>(), isTrue);
    });
  });
}
