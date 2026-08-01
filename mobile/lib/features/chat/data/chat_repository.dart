import 'dart:async';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/message_dao.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:dio/dio.dart';

import 'chat_events.dart';
import 'chat_message_mapper.dart';
import 'chat_partner_store.dart';

/// Chat's only data entry point (`architecture/solution.md` §2, §4
/// Contracts And Integrations). Owns the socket write path, the Drift
/// read-through, and the page-1 REST reconcile wired into the coordinator's
/// `ResyncFetcher` (ADR-013f). Feature widgets never touch [MessageDao],
/// [RealtimeCoordinator], or [Dio] directly.
class ChatRepository {
  ChatRepository({
    required MessageDao messageDao,
    required RealtimeCoordinator coordinator,
    required Dio dio,
    required ChatPartnerStore partnerStore,
    required BackendUserIdStore backendUserIdStore,
  })  : _messageDao = messageDao,
        _coordinator = coordinator,
        _dio = dio,
        _partnerStore = partnerStore,
        _backendUserIdStore = backendUserIdStore {
    _eventsSubscription = _coordinator
        .events(names: {ChatEvents.newMessage, ChatEvents.messageSeen})
        .listen(_handleInboundEvent);
  }

  static const int _pageSize = 30;

  final MessageDao _messageDao;
  final RealtimeCoordinator _coordinator;
  final Dio _dio;
  final ChatPartnerStore _partnerStore;
  final BackendUserIdStore _backendUserIdStore;
  late final StreamSubscription<RealtimeEvent> _eventsSubscription;

  // `loadOlder` fetches the page *after* the newest page (page 1), which is
  // assumed already loaded via `resyncPageOne`/the coordinator's resync.
  int _nextOlderPage = 2;

  /// Cancels the inbound event subscription. This repository is registered
  /// as a lazy singleton for the app's lifetime, so nothing calls this today
  /// — it exists so the subscription is not leaked if that ever changes.
  Future<void> dispose() => _eventsSubscription.cancel();

  /// The signed-in device's own backend `User.id` — the same room key
  /// STORY-004 uses (`core/realtime/backend_user_id_store.dart`). Only ever
  /// called once a chat surface is mounted, which AC5's pairing gate
  /// guarantees is after a successful login.
  String get _myId => _backendUserIdStore.backendUserId!;

  /// The paired partner's backend `User.id`. Only ever called once a chat
  /// surface is mounted, which AC5's pairing gate guarantees is after
  /// `partnerId` is non-null.
  String get _partnerId => _partnerStore.partnerId!;

  /// Drift-backed, ascending, bounded page-size read-through for the thread
  /// view (`architecture/solution.md` §2).
  Stream<List<Message>> watchThread() => _messageDao.watchForPartner(
        myId: _myId,
        partnerId: _partnerId,
        limit: _pageSize,
      );

  /// Sends over the socket only (ADR-012h/ADR-013a invariant #1). Awaits the
  /// ack (ADR-013g): a non-null ack is the sender's own persisted row and is
  /// upserted directly, since the gateway fans `newMessage` out to
  /// `receiverId` only and the sender has no other path to it. A `null` ack
  /// (timeout) is not a send failure — no fabricated row is written and no
  /// retry occurs (OQ4/ADR-007); instead exactly one bounded
  /// [resyncPageOne] pulls the server-authoritative row.
  /// `RealtimeNotLiveFailure` propagates unchanged (AC4).
  Future<void> send(String text) async {
    final ack = await _coordinator.emit(ChatEvents.sendMessage, {
      'content': text,
      'type': 'text',
      'senderId': _myId,
      'receiverId': _partnerId,
    });
    if (ack is Map) {
      final row = ChatMessageMapper.fromJson(Map<String, dynamic>.from(ack));
      await _messageDao.upsertAll([row]);
      return;
    }
    await resyncPageOne();
  }

  /// Fetches the next older page via `GET /messages`, reverses the
  /// newest-first response to ascending, and upserts it. Never clears the
  /// cache on failure — a thrown [DioException] propagates unchanged and no
  /// DAO write happens, so previously cached rows are left untouched.
  Future<void> loadOlder() async {
    final response = await _dio.get<Object?>(
      '/messages',
      queryParameters: {
        'partnerId': _partnerId,
        'page': _nextOlderPage,
        'limit': _pageSize,
      },
    );
    final ascending = _parseMessageRows(response.data).reversed.toList();
    await _messageDao.upsertAll(ascending);
    _nextOlderPage++;
  }

  /// Bounded page-1 REST refetch reconciled by id (ADR-012g.3, ADR-007).
  /// Upserts into Drift and returns the fetched rows as
  /// [GenericRealtimeEvent]s so the coordinator's LRU dedupe sees them.
  /// Returns `const []` when unpaired.
  Future<List<RealtimeEvent>> resyncPageOne() async {
    final partnerId = _partnerStore.partnerId;
    if (partnerId == null) return const [];

    final response = await _dio.get<Object?>(
      '/messages',
      queryParameters: {'partnerId': partnerId, 'page': 1, 'limit': _pageSize},
    );
    final ascending = _parseMessageRows(response.data).reversed.toList();
    await _messageDao.upsertAll(ascending);
    return ascending
        .map(
          (row) => GenericRealtimeEvent(
            name: ChatEvents.newMessage,
            id: row.id,
            // Built directly from the typed row (not `row.toJson()`) so the
            // shape is guaranteed to round-trip through `ChatMessageMapper`
            // — Drift's own JSON serializer format is not guaranteed to
            // match it.
            data: _toMapperJson(row),
            transport: RealtimeTransport.socket,
            receivedAt: DateTime.now(),
          ),
        )
        .toList();
  }

  /// `markSeen` only — no other receipt-state client emit is ever sent
  /// (ADR-013d: a delivered-style write would permanently block a later
  /// seen-state write from persisting, per the backend's status filter). The
  /// ack is ignored and not awaited inline (this event never acks); a
  /// not-live emit is a silent no-op.
  Future<void> markSeen() async {
    unawaited(_emitIgnoringNotLive(ChatEvents.markSeen, {
      'senderId': _partnerId,
      'receiverId': _myId,
    }));
    await _messageDao.markSeenLocally(senderId: _partnerId, receiverId: _myId);
  }

  Future<void> _emitIgnoringNotLive(String name, Object? payload) async {
    try {
      await _coordinator.emit(name, payload);
    } on RealtimeNotLiveFailure {
      // A seen-marker emitted while offline is a silent no-op, not a
      // user-visible error (ADR-013g consumption rules).
    }
  }

  void _handleInboundEvent(RealtimeEvent event) {
    switch (event.name) {
      case ChatEvents.newMessage:
        unawaited(_handleNewMessage(event));
      case ChatEvents.messageSeen:
        unawaited(_messageDao.markSeenLocally(
          senderId: _myId,
          receiverId: _partnerId,
        ));
    }
  }

  Future<void> _handleNewMessage(RealtimeEvent event) {
    final row = ChatMessageMapper.fromJson(event.data);
    return _messageDao.upsertAll([row]);
  }

  List<Message> _parseMessageRows(Object? body) {
    if (body is! List) return const [];
    return body
        .whereType<Map>()
        .map((row) => ChatMessageMapper.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  Map<String, dynamic> _toMapperJson(Message row) => {
        'id': row.id,
        'senderId': row.senderId,
        'receiverId': row.receiverId,
        'content': row.content,
        'type': row.type,
        'status': row.status,
        'readAt': row.readAt?.toIso8601String(),
        'createdAt': row.createdAt.toIso8601String(),
      };
}
