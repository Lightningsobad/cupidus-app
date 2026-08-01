import 'dart:async';

import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/core/realtime/socket_transport.dart';
import 'package:flutter_test/flutter_test.dart';

class _EmitCall {
  _EmitCall(this.event, this.data, this.completer);

  final String event;
  final dynamic data;
  final Completer<dynamic> completer;
}

/// Fake [RealtimeSocket]: never opens a real connection. Tests drive the
/// registered handlers directly to simulate server behavior.
class _FakeRealtimeSocket implements RealtimeSocket {
  int connectCalls = 0;
  int disconnectCalls = 0;
  Map<String, dynamic>? capturedAuth;
  final List<_EmitCall> emitCalls = [];

  dynamic Function(dynamic)? _connectHandler;
  dynamic Function(dynamic)? _connectErrorHandler;
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
  void onConnectError(dynamic Function(dynamic payload) handler) =>
      _connectErrorHandler = handler;

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
  set auth(Map<String, dynamic> value) => capturedAuth = value;

  /// Simulates the server accepting the connection. Returns the future the
  /// production `onConnect` handler completes (the `joinRoom` ack await), so
  /// tests can choose when to `await` it.
  Future<void> fireConnect() async => await _connectHandler?.call(null);

  Future<void> fireConnectError() async =>
      await _connectErrorHandler?.call(null);

  void fireDisconnect() => _disconnectHandler?.call(null);

  void fireAny(String event, dynamic data) => _anyHandler?.call(event, data);

  void ackLastEmit([dynamic response]) {
    emitCalls.last.completer.complete(response);
  }
}

void main() {
  group('SocketTransport handshake (ADR-012b/c)', () {
    test(
        'the built option map carries setTransports/disableAutoConnect and '
        'the current idToken() under auth.token', () async {
      Map<String, dynamic>? capturedOptions;
      final fake = _FakeRealtimeSocket();
      final transport = SocketTransport(
        url: 'http://localhost',
        idToken: ({bool forceRefresh = false}) async => 'token-initial',
        idTokenStream: const Stream<String?>.empty(),
        backendUserId: () async => 'user-42',
        socketFactory: (url, options) {
          capturedOptions = options;
          return fake;
        },
      );

      await transport.start();

      expect(capturedOptions, isNotNull);
      expect(capturedOptions!['transports'], ['websocket']);
      expect(capturedOptions!['autoConnect'], false);
      expect(capturedOptions!['auth'], {'token': 'token-initial'});
    });

    test(
        'observes strictly connect -> joinRoom(<backend User.id>) -> ack -> '
        'live, and surfaces no event received before the ack', () async {
      final fake = _FakeRealtimeSocket();
      final transport = SocketTransport(
        url: 'http://localhost',
        idToken: ({bool forceRefresh = false}) async => 'token-1',
        idTokenStream: const Stream<String?>.empty(),
        backendUserId: () async => 'user-42',
        socketFactory: (url, options) => fake,
      );

      final statuses = <RealtimeStatus>[];
      transport.status.listen(statuses.add);
      final events = <SocketTransportEvent>[];
      transport.events.listen(events.add);

      await transport.start();
      expect(fake.connectCalls, 1);
      expect(statuses, [RealtimeStatus.connecting]);

      final connectHandled = fake.fireConnect();
      await Future<void>.delayed(Duration.zero);

      expect(fake.emitCalls, hasLength(1));
      expect(fake.emitCalls.single.event, socketJoinRoomEvent);
      expect(fake.emitCalls.single.data, 'user-42');
      expect(statuses, isNot(contains(RealtimeStatus.live)));

      fake.fireAny('newMessage', {'content': 'too early'});
      await Future<void>.delayed(Duration.zero);
      expect(events, isEmpty);

      fake.ackLastEmit({'event': 'joinedRoom', 'data': 'user-42'});
      await connectHandled;

      expect(statuses.last, RealtimeStatus.live);

      fake.fireAny('newMessage', {'content': 'on time'});
      await Future<void>.delayed(Duration.zero);
      expect(events, hasLength(1));
      expect(events.single.name, 'newMessage');
    });

    test('a simulated reconnect re-emits joinRoom', () async {
      final fake = _FakeRealtimeSocket();
      final transport = SocketTransport(
        url: 'http://localhost',
        idToken: ({bool forceRefresh = false}) async => 'token-1',
        idTokenStream: const Stream<String?>.empty(),
        backendUserId: () async => 'user-42',
        socketFactory: (url, options) => fake,
      );

      await transport.start();

      final firstConnect = fake.fireConnect();
      await Future<void>.delayed(Duration.zero);
      fake.ackLastEmit({'event': 'joinedRoom', 'data': 'user-42'});
      await firstConnect;

      fake.fireDisconnect();

      final secondConnect = fake.fireConnect();
      await Future<void>.delayed(Duration.zero);
      fake.ackLastEmit({'event': 'joinedRoom', 'data': 'user-42'});
      await secondConnect;

      expect(fake.emitCalls, hasLength(2));
      expect(
        fake.emitCalls.map((c) => c.event),
        [socketJoinRoomEvent, socketJoinRoomEvent],
      );
    });
  });

  group('SocketTransport token rotation (ADR-012c)', () {
    test(
        'an idTokenStream emit updates the auth map for the next handshake '
        'without forcing a reconnect', () async {
      final fake = _FakeRealtimeSocket();
      final tokenController = StreamController<String?>();
      addTearDown(tokenController.close);

      final transport = SocketTransport(
        url: 'http://localhost',
        idToken: ({bool forceRefresh = false}) async => 'token-1',
        idTokenStream: tokenController.stream,
        backendUserId: () async => 'user-42',
        socketFactory: (url, options) => fake,
      );

      await transport.start();
      expect(fake.connectCalls, 1);
      expect(fake.disconnectCalls, 0);

      tokenController.add('token-2');
      await Future<void>.delayed(Duration.zero);

      expect(fake.capturedAuth, {'token': 'token-2'});
      expect(fake.connectCalls, 1);
      expect(fake.disconnectCalls, 0);
    });

    test(
        'a connect_error force-refreshes the token and replaces the auth map',
        () async {
      final fake = _FakeRealtimeSocket();
      final forceRefreshCalls = <bool>[];
      final transport = SocketTransport(
        url: 'http://localhost',
        idToken: ({bool forceRefresh = false}) async {
          forceRefreshCalls.add(forceRefresh);
          return forceRefresh ? 'token-refreshed' : 'token-1';
        },
        idTokenStream: const Stream<String?>.empty(),
        backendUserId: () async => 'user-42',
        socketFactory: (url, options) => fake,
      );

      await transport.start();
      await fake.fireConnectError();

      expect(forceRefreshCalls, [false, true]);
      expect(fake.capturedAuth, {'token': 'token-refreshed'});
      // Reconnect timing/backoff is delegated to the socket_io_client
      // Manager; this transport never calls connect()/disconnect() itself
      // in response to connect_error.
      expect(fake.connectCalls, 1);
      expect(fake.disconnectCalls, 0);
    });
  });

  group('SocketTransport room key (§2 backendUserId)', () {
    test(
        'raises RealtimeRoomKeyUnavailableFailure and never opens a '
        'connection when the backendUserId resolver has no value', () async {
      var factoryCalls = 0;
      final transport = SocketTransport(
        url: 'http://localhost',
        idToken: ({bool forceRefresh = false}) async => 'token-1',
        idTokenStream: const Stream<String?>.empty(),
        backendUserId: () async => null,
        socketFactory: (url, options) {
          factoryCalls++;
          return _FakeRealtimeSocket();
        },
      );

      await expectLater(
        transport.start(),
        throwsA(isA<RealtimeRoomKeyUnavailableFailure>()),
      );
      expect(factoryCalls, 0);
    });
  });
}
