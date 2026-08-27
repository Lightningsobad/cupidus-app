import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import 'realtime_event.dart';
import 'realtime_failure.dart';

/// Minimal seam over `package:socket_io_client`'s `Socket`
/// (`architecture/solution.md` §4 Boundaries And Ownership: this file is the
/// only place under `core/realtime/` allowed to import
/// `package:socket_io_client`). Handler return types mirror the vendor's own
/// `EventHandler`/`AnyEventHandler` typedefs (`dynamic`) so async handlers
/// compose without a wrapping shim. Tests inject a fake implementation so
/// [SocketTransport] never opens a real connection.
abstract interface class RealtimeSocket {
  void connect();
  void disconnect();
  void onConnect(dynamic Function(dynamic payload) handler);
  void onConnectError(dynamic Function(dynamic payload) handler);
  void onDisconnect(dynamic Function(dynamic payload) handler);
  void onAny(dynamic Function(String event, dynamic payload) handler);
  Future<dynamic> emitWithAckAsync(String event, dynamic data);
  set auth(Map<String, dynamic> value);
}

class _SocketIoRealtimeSocket implements RealtimeSocket {
  _SocketIoRealtimeSocket(this._socket);

  final io.Socket _socket;

  @override
  void connect() => _socket.connect();

  @override
  void disconnect() => _socket.disconnect();

  @override
  void onConnect(dynamic Function(dynamic payload) handler) =>
      _socket.onConnect(handler);

  @override
  void onConnectError(dynamic Function(dynamic payload) handler) =>
      _socket.onConnectError(handler);

  @override
  void onDisconnect(dynamic Function(dynamic payload) handler) =>
      _socket.onDisconnect(handler);

  @override
  void onAny(dynamic Function(String event, dynamic payload) handler) =>
      _socket.onAny(handler);

  @override
  Future<dynamic> emitWithAckAsync(String event, dynamic data) =>
      _socket.emitWithAckAsync(event, data);

  @override
  set auth(Map<String, dynamic> value) => _socket.auth = value;
}

/// Builds a [RealtimeSocket] from the handshake options map produced by
/// `OptionBuilder(...).build()` (ADR-012c). Injectable so tests never open a
/// real connection.
typedef RealtimeSocketFactory = RealtimeSocket Function(
  String url,
  Map<String, dynamic> options,
);

RealtimeSocket _defaultSocketFactory(
  String url,
  Map<String, dynamic> options,
) =>
    _SocketIoRealtimeSocket(io.io(url, options));

/// `ChatGateway.handleJoinRoom` subscription event name
/// (`chat.constants.ts` `CHAT_EVENTS.JOIN_ROOM`, ADR-012b). Because both
/// gateways share the default namespace (ADR-012a), this single chat-owned
/// join also subscribes the client to alarm delivery.
const socketJoinRoomEvent = 'joinRoom';

/// A single raw event received over the socket, forwarded only after the
/// `joinRoom` ack (ADR-012b) so no event is ever surfaced before the room
/// subscription completes. Consumed by `RealtimeCoordinator` (P4), which
/// classifies it into a [RealtimeEvent].
class SocketTransportEvent {
  const SocketTransportEvent({required this.name, required this.data});

  final String name;
  final dynamic data;
}

/// Owns exactly one Socket.IO connection for both `ChatGateway` and
/// `AlarmsGateway` (ADR-012a). Builds the handshake per ADR-012c, performs
/// the mandatory two-step `joinRoom` subscription per ADR-012b before ever
/// reporting [RealtimeStatus.live], and applies the token-rotation /
/// force-refresh policy from ADR-012c. `RealtimeCoordinator` (P4) is the
/// intended sole consumer.
class SocketTransport {
  SocketTransport({
    required String url,
    required Future<String?> Function({bool forceRefresh}) idToken,
    required Stream<String?> idTokenStream,
    required Future<String?> Function() backendUserId,
    RealtimeSocketFactory socketFactory = _defaultSocketFactory,
  })  : _url = url,
        _idToken = idToken,
        _idTokenStream = idTokenStream,
        _backendUserId = backendUserId,
        _socketFactory = socketFactory;

  final String _url;
  final Future<String?> Function({bool forceRefresh}) _idToken;
  final Stream<String?> _idTokenStream;
  final Future<String?> Function() _backendUserId;
  final RealtimeSocketFactory _socketFactory;

  // `sync: true` so status/event listeners observe each transition
  // deterministically as soon as it happens (ADR-012b: no event before the
  // `joinRoom` ack), rather than after a scheduled microtask hop.
  final _statusController = StreamController<RealtimeStatus>.broadcast(
    sync: true,
  );
  final _eventsController = StreamController<SocketTransportEvent>.broadcast(
    sync: true,
  );

  RealtimeSocket? _socket;
  StreamSubscription<String?>? _idTokenSubscription;
  String? _roomKey;
  bool _started = false;
  bool _joined = false;

  /// Transport-level connection status. [RealtimeStatus.live] is reached
  /// only after the `joinedRoom` ack (ADR-012b).
  Stream<RealtimeStatus> get status => _statusController.stream;

  /// Raw events received after the room join, filtered by [_joined]
  /// (ADR-012b: no event before the ack).
  Stream<SocketTransportEvent> get events => _eventsController.stream;

  /// Idempotent: connects the socket and performs the `joinRoom` handshake.
  /// Throws [RealtimeRoomKeyUnavailableFailure] when the injected
  /// `backendUserId` resolver has no value — this transport never falls back
  /// to the Firebase uid because it is never given one (§2 Room-key typing
  /// gap).
  Future<void> start() async {
    if (_started) return;

    final roomKey = await _backendUserId();
    if (roomKey == null || roomKey.isEmpty) {
      throw const RealtimeRoomKeyUnavailableFailure();
    }
    _roomKey = roomKey;
    _started = true;

    final initialToken = await _idToken();
    _idTokenSubscription = _idTokenStream.listen((token) {
      // ADR-012c: store for the *next* handshake only, never force a
      // reconnect. `Socket.auth` is read again by the vendor client on every
      // (re)connection, so mutating it now is enough.
      _socket?.auth = {'token': token};
    });

    final options = (io.OptionBuilder()
          ..setTransports(['websocket'])
          ..disableAutoConnect())
        .setAuth({'token': initialToken})
        .build();
    final socket = _socketFactory(_url, options);
    _socket = socket;

    socket.onConnect((_) async {
      await _handleConnect(socket);
    });
    socket.onConnectError((_) async {
      await _handleConnectError(socket);
    });
    socket.onDisconnect((_) => _handleDisconnect());
    socket.onAny((name, data) => _handleAny(name, data));

    _statusController.add(RealtimeStatus.connecting);
    socket.connect();
  }

  /// Disconnects the socket and releases the token-rotation subscription.
  Future<void> stop() async {
    if (!_started) return;
    _started = false;
    _joined = false;
    await _idTokenSubscription?.cancel();
    _idTokenSubscription = null;
    _socket?.disconnect();
    _socket = null;
    _statusController.add(RealtimeStatus.offline);
  }

  /// Socket-only write path (ADR-012h). The caller (`RealtimeCoordinator`,
  /// P4) is responsible for gating on [status] being [RealtimeStatus.live].
  Future<dynamic> emit(String name, Object? payload) async {
    final socket = _socket;
    if (socket == null) {
      throw const RealtimeNotLiveFailure();
    }
    try {
      return await socket.emitWithAckAsync(name, payload).timeout(const Duration(seconds: 4));
    } catch (_) {
      return null;
    }
  }

  Future<void> _handleConnect(RealtimeSocket socket) async {
    _joined = false;
    _statusController.add(RealtimeStatus.connecting);
    // ADR-012b: connect alone delivers nothing; joinRoom is the mandatory
    // subscription and this ack gates `live`. Re-run on every reconnect
    // because rooms are per-connection.
    try {
      await socket.emitWithAckAsync(socketJoinRoomEvent, _roomKey).timeout(const Duration(seconds: 2));
    } catch (_) {
      // Fallback
    }
    _joined = true;
    _statusController.add(RealtimeStatus.live);
  }

  Future<void> _handleConnectError(RealtimeSocket socket) async {
    // Forward-compat safety net (ADR-012c): the backend ignores the token
    // today, but force-refresh and replace the auth map so the client is
    // already correct the day the backend enforces it.
    final refreshed = await _idToken(forceRefresh: true);
    socket.auth = {'token': refreshed};
  }

  void _handleDisconnect() {
    _joined = false;
    _statusController.add(RealtimeStatus.offline);
  }

  void _handleAny(String name, dynamic data) {
    if (!_joined || name == socketJoinRoomEvent) return;
    _eventsController.add(SocketTransportEvent(name: name, data: data));
  }
}
