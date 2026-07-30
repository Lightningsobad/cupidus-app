import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:firebase_messaging/firebase_messaging.dart';

import 'pending_event_store.dart';
import 'realtime_event.dart';

/// Injectable seam for the foreground FCM message stream
/// (`master-plan.md` §3 "FCM transport with an injectable message source"),
/// so tests and P5's harness can drive a fake without opening a real
/// `firebase_messaging` platform channel. Defaults to
/// `FirebaseMessaging.onMessage`.
typedef FcmMessageStreamFactory = Stream<RemoteMessage> Function();

/// Injectable seam for registering the background handler, so tests never
/// call the real static `FirebaseMessaging.onBackgroundMessage`, which
/// requires an initialized Firebase app.
typedef BackgroundHandlerRegistrar = void Function(
  BackgroundMessageHandler handler,
);

/// Parses one FCM `data` map into a [RealtimeEvent] per ADR-012f, reusing the
/// same event model the socket transport produces so a single parser serves
/// both transports (`master-plan.md` §3). Returns `null` when `cupid_event`
/// is absent so the caller can reject/ignore the message without throwing.
RealtimeEvent? parseFcmDataMap(
  Map<String, dynamic> data, {
  required RealtimeTransport transport,
  required DateTime receivedAt,
  void Function(String message) log = _logRejection,
}) {
  final eventName = data['cupid_event'];
  if (eventName is! String || eventName.isEmpty) {
    // Never log payload contents (AC: no log line contains payload
    // contents) — the message names the rejection reason only.
    log('Rejected FCM message: missing cupid_event');
    return null;
  }

  final rawId = data['cupid_event_id'];
  final id = rawId is String && rawId.isNotEmpty ? rawId : null;

  final rawPayload = data['cupid_payload'];
  final payload = rawPayload is String && rawPayload.isNotEmpty
      ? Map<String, dynamic>.from(jsonDecode(rawPayload) as Map)
      : <String, dynamic>{};

  return GenericRealtimeEvent(
    name: eventName,
    id: id,
    data: payload,
    transport: transport,
    receivedAt: receivedAt,
  );
}

Stream<RemoteMessage> _defaultForegroundMessages() =>
    FirebaseMessaging.onMessage;

void _logRejection(String message) =>
    developer.log(message, name: 'FcmTransport');

/// Top-level background handler — must stay top-level because
/// `firebase_messaging` runs it in a separate isolate. It must never touch
/// `get_it` or any in-memory state (ADR-012g.4): its only side effect is
/// appending a durable event to a fresh [PendingEventStore]. Ephemeral
/// events (`RealtimeEvent.isEphemeral`) are never FCM-delivered (ADR-012d)
/// and are dropped rather than persisted.
@pragma('vm:entry-point')
Future<void> fcmBackgroundMessageHandler(RemoteMessage message) async {
  final event = parseFcmDataMap(
    message.data,
    transport: RealtimeTransport.fcmBackgroundReplay,
    receivedAt: DateTime.now(),
  );
  if (event == null || event.isEphemeral) return;
  await PendingEventStore().append(event);
}

/// Owns the FCM leg: parses foreground messages into [RealtimeEvent]s and
/// registers the top-level background handler that persists durable events
/// to [PendingEventStore] (`architecture/solution.md` §4 Boundaries And
/// Ownership — `firebase_messaging` may only be imported under
/// `core/realtime/`). `RealtimeCoordinator` (P4) is the intended sole
/// consumer of [foregroundEvents] and of draining `PendingEventStore`.
class FcmTransport {
  FcmTransport({
    FcmMessageStreamFactory messageStreamFactory = _defaultForegroundMessages,
    BackgroundHandlerRegistrar registerBackgroundHandler =
        FirebaseMessaging.onBackgroundMessage,
  })  : _messageStreamFactory = messageStreamFactory,
        _registerBackgroundHandler = registerBackgroundHandler;

  final FcmMessageStreamFactory _messageStreamFactory;
  final BackgroundHandlerRegistrar _registerBackgroundHandler;

  final _eventsController = StreamController<RealtimeEvent>.broadcast(
    sync: true,
  );
  StreamSubscription<RemoteMessage>? _subscription;
  bool _started = false;

  /// Parsed foreground messages (`onMessage`). A message missing
  /// `cupid_event` never reaches this stream — it is rejected in
  /// [parseFcmDataMap].
  Stream<RealtimeEvent> get foregroundEvents => _eventsController.stream;

  /// Idempotent: registers the top-level background handler and starts
  /// listening to the foreground message stream.
  void start() {
    if (_started) return;
    _started = true;
    _registerBackgroundHandler(fcmBackgroundMessageHandler);
    _subscription = _messageStreamFactory().listen(_handleForegroundMessage);
  }

  /// Cancels the foreground subscription. The background handler
  /// registration is process-lifetime (per the vendor API) and is not
  /// undone here.
  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    await _subscription?.cancel();
    _subscription = null;
  }

  void _handleForegroundMessage(RemoteMessage message) {
    final event = parseFcmDataMap(
      message.data,
      transport: RealtimeTransport.fcmForeground,
      receivedAt: DateTime.now(),
    );
    if (event != null) {
      _eventsController.add(event);
    }
  }
}
