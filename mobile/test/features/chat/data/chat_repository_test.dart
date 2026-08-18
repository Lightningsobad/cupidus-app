import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/features/chat/data/chat_events.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/chat/data/chat_repository.dart';
import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fake [HttpClientAdapter]: every test supplies a [handler] that inspects
/// the outbound [RequestOptions] and returns the JSON-encodable body (or
/// throws) instead of making a real request. Mirrors the JSON content-type
/// dio's [SyncTransformer] requires to auto-decode the body.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final Object? Function(RequestOptions options) _handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final body = _handler(options);
    return ResponseBody.fromString(
      jsonEncode(body),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

class _EmitCall {
  _EmitCall(this.name, this.payload);

  final String name;
  final Object? payload;
}

/// Fake [RealtimeCoordinator]: mirrors the not-live guard ordering of
/// `RealtimeCoordinatorImpl.emit` (status checked before the emit is ever
/// recorded), and lets each test script the ack per event name.
class _FakeRealtimeCoordinator implements RealtimeCoordinator {
  RealtimeStatus statusValue = RealtimeStatus.live;
  Object? Function(String name, Object? payload)? ackResolver;
  final List<_EmitCall> emitCalls = [];
  final _eventsController = StreamController<RealtimeEvent>.broadcast();

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) {
    final stream = _eventsController.stream;
    if (names == null) return stream;
    return stream.where((event) => names.contains(event.name));
  }

  @override
  Stream<RealtimeStatus> get status => Stream.value(statusValue);

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> resync() async {}

  @override
  Future<Object?> emit(String name, Object? payload) async {
    if (statusValue != RealtimeStatus.live) {
      throw const RealtimeNotLiveFailure();
    }
    emitCalls.add(_EmitCall(name, payload));
    return ackResolver?.call(name, payload);
  }

  void fireEvent(RealtimeEvent event) => _eventsController.add(event);

  Future<void> dispose() => _eventsController.close();
}

class _TestContext {
  _TestContext({
    required this.database,
    required this.adapter,
    required this.coordinator,
    required this.partnerStore,
    required this.backendUserIdStore,
    required this.repository,
  });

  final CupidDatabase database;
  final _FakeHttpClientAdapter adapter;
  final _FakeRealtimeCoordinator coordinator;
  final ChatPartnerStore partnerStore;
  final BackendUserIdStore backendUserIdStore;
  final ChatRepository repository;

  Future<void> dispose() async {
    await coordinator.dispose();
    await database.close();
  }
}

const String _myId = 'me-1';
const String _partnerId = 'partner-1';

Object? _usersMeHandler(RequestOptions options) => {
      'partnerId': _partnerId,
      'displayName': 'Partner One',
      'isGhostModeEnabled': false,
    };

Object? _neverCalledHandler(RequestOptions options) {
  fail('unexpected REST request to ${options.path}');
}

Future<_TestContext> _buildContext({
  required Object? Function(RequestOptions options) messagesHandler,
  Object? Function(String name, Object? payload)? ackResolver,
  RealtimeStatus status = RealtimeStatus.live,
  bool withPartner = true,
}) async {
  final database = CupidDatabase(NativeDatabase.memory());
  final adapter = _FakeHttpClientAdapter((options) {
    if (options.path == '/users/me') return _usersMeHandler(options);
    return messagesHandler(options);
  });
  final dio = Dio()..httpClientAdapter = adapter;
  final coordinator = _FakeRealtimeCoordinator()
    ..statusValue = status
    ..ackResolver = ackResolver;
  final partnerStore = ChatPartnerStore(dio: dio);
  if (withPartner) {
    await partnerStore.refreshFromServer();
  }
  final backendUserIdStore = BackendUserIdStore()
    ..updateFromLoginResponse({'id': _myId});
  final repository = ChatRepository(
    messageDao: database.messageDao,
    coordinator: coordinator,
    dio: dio,
    partnerStore: partnerStore,
    backendUserIdStore: backendUserIdStore,
  );
  return _TestContext(
    database: database,
    adapter: adapter,
    coordinator: coordinator,
    partnerStore: partnerStore,
    backendUserIdStore: backendUserIdStore,
    repository: repository,
  );
}

Map<String, dynamic> _messageJson({
  required String id,
  required String senderId,
  required String receiverId,
  String content = 'hi',
  String status = 'sent',
  String? readAt,
  required String createdAt,
}) => {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'type': 'text',
      'status': status,
      'readAt': readAt,
      'createdAt': createdAt,
    };

Future<List<Message>> _thread(_TestContext ctx) => ctx.database.messageDao
    .pageForPartner(myId: _myId, partnerId: _partnerId, limit: 50, offset: 0);

void main() {
  group('ChatRepository.send', () {
    test('upserts exactly the ack payload when the coordinator acks',
        () async {
      final ctx = await _buildContext(
        messagesHandler: _neverCalledHandler,
        ackResolver: (name, payload) => name == ChatEvents.sendMessage
            ? _messageJson(
                id: 'msg-1',
                senderId: _myId,
                receiverId: _partnerId,
                content: 'hi',
                createdAt: '2026-01-01T00:00:00.000Z',
              )
            : null,
      );

      await ctx.repository.send('hi');

      final rows = await _thread(ctx);
      expect(rows, hasLength(1));
      expect(rows.single.id, 'msg-1');
      expect(rows.single.content, 'hi');
      expect(
        ctx.adapter.requests.where((r) => r.path == '/messages'),
        isEmpty,
      );

      await ctx.dispose();
    });

    test(
        'on a non-live coordinator throws RealtimeNotLiveFailure and writes '
        'nothing anywhere', () async {
      final ctx = await _buildContext(
        messagesHandler: _neverCalledHandler,
        status: RealtimeStatus.degraded,
      );

      await expectLater(
        () => ctx.repository.send('hi'),
        throwsA(isA<RealtimeNotLiveFailure>()),
      );

      expect(await _thread(ctx), isEmpty);
      expect(ctx.coordinator.emitCalls, isEmpty);
      expect(
        ctx.adapter.requests.where((r) => r.path == '/messages'),
        isEmpty,
      );

      await ctx.dispose();
    });

    test(
        'with a null ack writes no Drift row directly and triggers exactly '
        'one resyncPageOne(); no second sendMessage emit ever occurs',
        () async {
      final ctx = await _buildContext(
        messagesHandler: (options) => [
          _messageJson(
            id: 'msg-9',
            senderId: _myId,
            receiverId: _partnerId,
            content: 'later',
            createdAt: '2026-01-01T00:02:00.000Z',
          ),
          _messageJson(
            id: 'msg-8',
            senderId: _myId,
            receiverId: _partnerId,
            content: 'earlier',
            createdAt: '2026-01-01T00:01:00.000Z',
          ),
        ],
        ackResolver: (name, payload) => null,
      );

      await ctx.repository.send('hi');

      expect(
        ctx.coordinator.emitCalls
            .where((c) => c.name == ChatEvents.sendMessage),
        hasLength(1),
      );
      final page1Requests = ctx.adapter.requests.where(
        (r) => r.path == '/messages' && r.queryParameters['page'] == 1,
      );
      expect(page1Requests, hasLength(1));

      final rows = await _thread(ctx);
      expect(rows.map((r) => r.id), ['msg-8', 'msg-9']);

      await ctx.dispose();
    });
  });

  group('ChatRepository.loadOlder', () {
    test('reverses a newest-first response to ascending before upsert',
        () async {
      final ctx = await _buildContext(
        messagesHandler: (options) => [
          _messageJson(
            id: 'm3',
            senderId: _myId,
            receiverId: _partnerId,
            createdAt: '2026-01-01T00:03:00.000Z',
          ),
          _messageJson(
            id: 'm2',
            senderId: _myId,
            receiverId: _partnerId,
            createdAt: '2026-01-01T00:02:00.000Z',
          ),
          _messageJson(
            id: 'm1',
            senderId: _myId,
            receiverId: _partnerId,
            createdAt: '2026-01-01T00:01:00.000Z',
          ),
        ],
      );

      await ctx.repository.loadOlder();

      final rows = await _thread(ctx);
      expect(rows.map((r) => r.id), ['m1', 'm2', 'm3']);

      await ctx.dispose();
    });

    test('a failing REST call leaves previously cached rows intact',
        () async {
      final ctx = await _buildContext(
        messagesHandler: (options) =>
            throw DioException(requestOptions: options, error: 'boom'),
      );
      await ctx.database.messageDao.upsertAll([
        Message(
          id: 'kept-1',
          senderId: _myId,
          receiverId: _partnerId,
          content: 'kept',
          type: 'text',
          status: 'sent',
          readAt: null,
          createdAt: DateTime.utc(2026, 1, 1),
          cachedAt: DateTime.now(),
        ),
      ]);

      await expectLater(
        () => ctx.repository.loadOlder(),
        throwsA(isA<DioException>()),
      );

      final rows = await _thread(ctx);
      expect(rows.map((r) => r.id), ['kept-1']);

      await ctx.dispose();
    });
  });

  group('ChatRepository.resyncPageOne', () {
    test('upserts and returns events', () async {
      final ctx = await _buildContext(
        messagesHandler: (options) => [
          _messageJson(
            id: 'r2',
            senderId: _partnerId,
            receiverId: _myId,
            createdAt: '2026-01-01T00:02:00.000Z',
          ),
          _messageJson(
            id: 'r1',
            senderId: _partnerId,
            receiverId: _myId,
            createdAt: '2026-01-01T00:01:00.000Z',
          ),
        ],
      );

      final events = await ctx.repository.resyncPageOne();

      expect(events.map((e) => e.id), ['r1', 'r2']);
      for (final event in events) {
        expect(event.name, ChatEvents.newMessage);
      }
      final rows = await _thread(ctx);
      expect(rows.map((r) => r.id), ['r1', 'r2']);

      await ctx.dispose();
    });

    test('returns const [] when partnerId is null', () async {
      final ctx = await _buildContext(
        messagesHandler: _neverCalledHandler,
        withPartner: false,
      );

      final events = await ctx.repository.resyncPageOne();

      expect(events, isEmpty);
      expect(
        ctx.adapter.requests.where((r) => r.path == '/messages'),
        isEmpty,
      );

      await ctx.dispose();
    });
  });

  group('ChatRepository.markSeen', () {
    test(
        'emits exactly one markSeen with the correct payload and marks '
        'local rows seen', () async {
      final ctx = await _buildContext(
        messagesHandler: _neverCalledHandler,
        ackResolver: (name, payload) => null,
      );
      await ctx.database.messageDao.upsertAll([
        Message(
          id: 'seen-me-1',
          senderId: _partnerId,
          receiverId: _myId,
          content: 'hi',
          type: 'text',
          status: 'sent',
          readAt: null,
          createdAt: DateTime.utc(2026, 1, 1),
          cachedAt: DateTime.now(),
        ),
      ]);

      await ctx.repository.markSeen();

      expect(ctx.coordinator.emitCalls, hasLength(1));
      expect(ctx.coordinator.emitCalls.single.name, ChatEvents.markSeen);
      expect(
        ctx.coordinator.emitCalls.single.payload,
        {'senderId': _partnerId, 'receiverId': _myId},
      );

      final rows = await _thread(ctx);
      expect(rows.single.status, 'seen');
      expect(rows.single.readAt, isNotNull);

      await ctx.dispose();
    });

    test('swallows RealtimeNotLiveFailure silently and still marks locally',
        () async {
      final ctx = await _buildContext(
        messagesHandler: _neverCalledHandler,
        status: RealtimeStatus.degraded,
      );
      await ctx.database.messageDao.upsertAll([
        Message(
          id: 'seen-me-2',
          senderId: _partnerId,
          receiverId: _myId,
          content: 'hi',
          type: 'text',
          status: 'sent',
          readAt: null,
          createdAt: DateTime.utc(2026, 1, 1),
          cachedAt: DateTime.now(),
        ),
      ]);

      await ctx.repository.markSeen();

      expect(ctx.coordinator.emitCalls, isEmpty);
      final rows = await _thread(ctx);
      expect(rows.single.status, 'seen');

      await ctx.dispose();
    });
  });

  group('ChatRepository inbound event subscription', () {
    test('a newMessage event upserts the row', () async {
      final ctx = await _buildContext(messagesHandler: _neverCalledHandler);

      ctx.coordinator.fireEvent(
        GenericRealtimeEvent(
          name: ChatEvents.newMessage,
          id: 'inbound-1',
          data: _messageJson(
            id: 'inbound-1',
            senderId: _partnerId,
            receiverId: _myId,
            createdAt: '2026-01-01T00:00:00.000Z',
          ),
          transport: RealtimeTransport.socket,
          receivedAt: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final rows = await _thread(ctx);
      expect(rows.single.id, 'inbound-1');

      await ctx.dispose();
    });

    test('a messageSeen event marks messages I sent as seen', () async {
      final ctx = await _buildContext(messagesHandler: _neverCalledHandler);
      await ctx.database.messageDao.upsertAll([
        Message(
          id: 'sent-1',
          senderId: _myId,
          receiverId: _partnerId,
          content: 'hi',
          type: 'text',
          status: 'sent',
          readAt: null,
          createdAt: DateTime.utc(2026, 1, 1),
          cachedAt: DateTime.now(),
        ),
      ]);

      ctx.coordinator.fireEvent(
        GenericRealtimeEvent(
          name: ChatEvents.messageSeen,
          id: null,
          data: const {'senderId': _myId, 'receiverId': _partnerId},
          transport: RealtimeTransport.socket,
          receivedAt: DateTime.now(),
        ),
      );
      await Future<void>.delayed(Duration.zero);

      final rows = await _thread(ctx);
      expect(rows.single.status, 'seen');

      await ctx.dispose();
    });
  });

  group('ChatPartnerStore', () {
    // The two names differ so a getter wired to the wrong key cannot pass.
    ChatPartnerStore storeFrom(Map<String, Object?> body) {
      final adapter = _FakeHttpClientAdapter((options) => body);
      return ChatPartnerStore(dio: Dio()..httpClientAdapter = adapter);
    }

    Map<String, Object?> pairedBody() => {
      'partnerId': _partnerId,
      'displayName': 'Minh',
      'partnerDisplayName': 'Linh',
      'isGhostModeEnabled': true,
    };

    test('refreshFromServer maps the two identity keys onto two distinct '
        'getters', () async {
      final store = storeFrom(pairedBody());

      await store.refreshFromServer();

      expect(store.partnerId, _partnerId);
      expect(store.selfDisplayName, 'Minh');
      expect(store.partnerDisplayName, 'Linh');
      expect(store.partnerDisplayName, isNot(store.selfDisplayName));
      expect(store.isGhostModeEnabled, isTrue);
    });

    test('a missing partnerDisplayName key reads as null, not an error',
        () async {
      final store = storeFrom({
        'partnerId': _partnerId,
        'displayName': 'Minh',
        'isGhostModeEnabled': true,
      });

      await store.refreshFromServer();

      expect(store.selfDisplayName, 'Minh');
      expect(store.partnerDisplayName, isNull);
    });

    test('a null partnerDisplayName (unpaired, dangling, or nameless '
        'partner) reads as null', () async {
      final store = storeFrom({
        'partnerId': null,
        'displayName': 'Minh',
        'partnerDisplayName': null,
        'isGhostModeEnabled': false,
      });

      await store.refreshFromServer();

      expect(store.partnerId, isNull);
      expect(store.selfDisplayName, 'Minh');
      expect(store.partnerDisplayName, isNull);
    });

    test('clearOnSignOut clears both names alongside partnerId and the '
        'ghost flag', () async {
      final store = storeFrom(pairedBody());
      await store.refreshFromServer();

      await store.clearOnSignOut();

      expect(store.partnerId, isNull);
      expect(store.selfDisplayName, isNull);
      expect(store.partnerDisplayName, isNull);
      expect(store.isGhostModeEnabled, isNull);
    });

    // `contract-summary.md` §6: the absence of a compatibility getter is what
    // forces every call site through the compiler. A re-added alias would
    // compile silently, so guard the source text.
    test('no compatibility displayName getter survives the split', () {
      final source = File(
        'lib/features/chat/data/chat_partner_store.dart',
      ).readAsStringSync();

      expect(source, contains('get selfDisplayName'));
      expect(source, contains('get partnerDisplayName'));
      expect(source, isNot(contains('get displayName')));
    });
  });

  group('markDelivered guard (ADR-013d)', () {
    test('the string markDelivered appears nowhere under lib/features/chat',
        () {
      final chatDir = Directory('lib/features/chat');
      expect(chatDir.existsSync(), isTrue);
      final dartFiles = chatDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      expect(dartFiles, isNotEmpty);
      for (final file in dartFiles) {
        expect(
          file.readAsStringSync().contains('markDelivered'),
          isFalse,
          reason: '${file.path} must never reference markDelivered',
        );
      }
    });

    test('no socket_io_client or firebase_messaging import appears anywhere '
        'under features/chat', () {
      final chatDir = Directory('lib/features/chat');
      final dartFiles = chatDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'));
      for (final file in dartFiles) {
        final content = file.readAsStringSync();
        expect(content.contains('socket_io_client'), isFalse);
        expect(content.contains('firebase_messaging'), isFalse);
      }
    });
  });
}
