import 'dart:math';

import 'package:drift/drift.dart' show Value;

import '../../../core/database/cupid_database.dart';
import '../../../core/database/daos/activity_card_dao.dart';
import '../../../core/realtime/backend_user_id_store.dart';
import '../domain/activity_card.dart';
import '../domain/activity_card_repository.dart';

/// Drift-backed implementation of [ActivityCardRepository]
/// (`architecture/contract-summary.md` §1). Deliberately not a
/// `SessionScopedStore` (AC-22, `solution.md` §1 Key Discovery); isolation
/// between users on one device comes entirely from resolving `owner_key`
/// through [BackendUserIdStore] on every call.
class ActivityCardRepositoryImpl implements ActivityCardRepository {
  ActivityCardRepositoryImpl({
    required ActivityCardDao dao,
    required BackendUserIdStore ownerKeyStore,
    String Function() newId = _newUuidV4,
  })  : _dao = dao,
        _ownerKeyStore = ownerKeyStore,
        _newId = newId;

  final ActivityCardDao _dao;
  final BackendUserIdStore _ownerKeyStore;
  final String Function() _newId;

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) async {
    final ownerKey = await _requireOwnerKey();
    final now = DateTime.now();
    final id = _newId();
    await _dao.upsertCard(
      ActivityCardsCompanion.insert(
        id: id,
        ownerKey: ownerKey,
        title: _resolveTitle(draft),
        origin: draft.origin.wireValue,
        status: Value(ActivityCardStatus.idea.wireValue),
        activityType: Value(draft.activityType),
        scheduledOn: Value(draft.scheduledOn),
        priceVnd: Value(draft.priceVnd),
        distanceKm: Value(draft.distanceKm),
        needsBooking: Value(draft.needsBooking),
        indoorOutdoor: Value(draft.indoorOutdoor?.wireValue),
        note: Value(draft.note),
        sourceLink: Value(draft.sourceLink),
        invited: const Value(false),
        replyState: Value(ActivityCardReplyState.notAnswered.wireValue),
        createdAt: now,
        updatedAt: now,
      ),
    );
    final saved = await _dao.cardById(ownerKey: ownerKey, id: id);
    return _toDomain(saved!);
  }

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async {
    final ownerKey = await _requireOwnerKey();
    final rows = await _dao.cardsByStatus(
      ownerKey: ownerKey,
      status: status.wireValue,
      limit: limit,
      offset: offset,
    );
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async* {
    final ownerKey = await _requireOwnerKey();
    yield* _dao
        .watchCardsByStatus(
          ownerKey: ownerKey,
          status: status.wireValue,
          limit: limit,
          offset: offset,
        )
        .map((rows) => rows.map(_toDomain).toList(growable: false));
  }

  @override
  Future<ActivityCard?> cardById(String id) async {
    final ownerKey = await _requireOwnerKey();
    final row = await _dao.cardById(ownerKey: ownerKey, id: id);
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() async {
    final ownerKey = await _requireOwnerKey();
    final counts = await _dao.countsByStatus(ownerKey);
    return {
      for (final status in ActivityCardStatus.values)
        if (counts.containsKey(status.wireValue))
          status: counts[status.wireValue]!,
    };
  }

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async {
    final ownerKey = await _requireOwnerKey();
    return _dao.updateCard(
      ownerKey: ownerKey,
      id: cardId,
      // Every editable column is named, so an absent field is impossible and a
      // `null` reaches SQLite as a real `NULL` rather than "no change".
      changes: ActivityCardsCompanion(
        title: Value(edit.title),
        activityType: Value(edit.activityType),
        scheduledOn: Value(edit.scheduledOn),
        priceVnd: Value(edit.priceVnd),
        distanceKm: Value(edit.distanceKm),
        needsBooking: Value(edit.needsBooking),
        indoorOutdoor: Value(edit.indoorOutdoor?.wireValue),
        note: Value(edit.note),
        sourceLink: Value(edit.sourceLink),
        durationMinutes: Value(edit.durationMinutes),
        timeOfDaySlot: Value(edit.timeOfDaySlot),
        noteKeywords: Value(edit.noteKeywords),
        linkSourceLabel: Value(edit.linkSourceLabel),
        linkSavedAt: Value(edit.linkSavedAt),
        invited: Value(edit.invited),
        replyState: Value(edit.replyState.wireValue),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async {
    final ownerKey = await _requireOwnerKey();
    return _dao.updateCard(
      ownerKey: ownerKey,
      id: cardId,
      changes: ActivityCardsCompanion(status: Value(status.wireValue)),
    );
  }

  @override
  Future<int> clearScheduledDate(String cardId) async {
    final ownerKey = await _requireOwnerKey();
    return _dao.updateCard(
      ownerKey: ownerKey,
      id: cardId,
      changes: const ActivityCardsCompanion(scheduledOn: Value(null)),
    );
  }

  @override
  Future<int> deleteCard(String id) async {
    final ownerKey = await _requireOwnerKey();
    return _dao.deleteCard(ownerKey: ownerKey, id: id);
  }

  Future<String> _requireOwnerKey() async {
    final ownerKey = await _ownerKeyStore.resolve();
    if (ownerKey == null || ownerKey.isEmpty) {
      throw StateError(
        'ActivityCardRepository used before a backend user id resolved.',
      );
    }
    return ownerKey;
  }

  /// Dán link: giữ `source_link` nguyên vẹn; nếu người dùng chưa nhập tiêu
  /// đề thì suy giảm êm về host của URL (AC-7). Không có link thì trả về đúng
  /// giá trị người dùng đã nhập, kể cả rỗng — không gọi mạng ở đây (R-7/BR-8).
  String _resolveTitle(NewActivityCard draft) {
    final trimmed = draft.title.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    final link = draft.sourceLink?.trim();
    if (link != null && link.isNotEmpty) {
      final host = Uri.tryParse(link)?.host;
      if (host != null && host.isNotEmpty) {
        return host;
      }
    }
    return trimmed;
  }

  ActivityCard _toDomain(ActivityCardRow row) => ActivityCard(
        id: row.id,
        ownerKey: row.ownerKey,
        title: row.title,
        status: ActivityCardStatus.fromWireValue(row.status),
        origin: ActivityCardOrigin.fromWireValue(row.origin),
        activityType: row.activityType,
        scheduledOn: row.scheduledOn,
        priceVnd: row.priceVnd,
        distanceKm: row.distanceKm,
        needsBooking: row.needsBooking,
        indoorOutdoor: row.indoorOutdoor == null
            ? null
            : ActivityCardIndoorOutdoor.fromWireValue(row.indoorOutdoor!),
        note: row.note,
        sourceLink: row.sourceLink,
        durationMinutes: row.durationMinutes,
        timeOfDaySlot: row.timeOfDaySlot,
        noteKeywords: row.noteKeywords,
        linkSourceLabel: row.linkSourceLabel,
        linkSavedAt: row.linkSavedAt,
        invited: row.invited,
        replyState: ActivityCardReplyState.fromWireValue(row.replyState),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}

/// No `uuid` package is a direct dependency of this app (only transitive via
/// another package), so a client-generated id v4 (R-15a, must not be a
/// rowid/autoincrement) is produced here with `dart:math`'s cryptographic
/// RNG instead of adding one.
String _newUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int start, int end) => bytes
      .sublist(start, end)
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
