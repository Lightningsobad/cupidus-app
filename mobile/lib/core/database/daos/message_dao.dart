import 'package:drift/drift.dart';

import '../cupid_database.dart';
import '../tables/messages_table.dart';

part 'message_dao.g.dart';

/// DAO for the `messages` table (`architecture/solution.md` §2 Mobile
/// contract). All dedupe is by server `Message.id` — there is no
/// client-generated identity for a chat message (ADR-007).
@DriftAccessor(tables: [Messages])
class MessageDao extends DatabaseAccessor<CupidDatabase> with _$MessageDaoMixin {
  MessageDao(super.db);

  /// Upserts by server `id` so re-fetching the same row never duplicates it.
  Future<void> upsertAll(List<Message> rows) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(messages, rows);
    });
  }

  /// Ascending `createdAt` page for one conversation, covering both
  /// directions (I am sender or I am receiver). The REST source is
  /// newest-first; the repository normalizes to ascending before calling
  /// this DAO, not the UI.
  Future<List<Message>> pageForPartner({
    required String myId,
    required String partnerId,
    required int limit,
    required int offset,
  }) {
    return (select(messages)
          ..where((row) => _forPartner(row, myId, partnerId))
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Live ascending stream of the same conversation, for the thread view.
  Stream<List<Message>> watchForPartner({
    required String myId,
    required String partnerId,
    required int limit,
  }) {
    return (select(messages)
          ..where((row) => _forPartner(row, myId, partnerId))
          ..orderBy([(row) => OrderingTerm.asc(row.createdAt)])
          ..limit(limit))
        .watch();
  }

  /// Marks messages the partner sent me as seen. The client emits `markSeen`
  /// only — never `markDelivered` (ADR-013d) — so this is the only local
  /// receipt-state transition.
  Future<void> markSeenLocally({
    required String senderId,
    required String receiverId,
  }) async {
    await (update(messages)
          ..where(
            (row) =>
                row.senderId.equals(senderId) &
                row.receiverId.equals(receiverId),
          ))
        .write(
      MessagesCompanion(
        status: const Value('seen'),
        readAt: Value(DateTime.now()),
      ),
    );
  }

  /// Sign-out teardown: wipes the whole local cache.
  Future<void> clearAll() async => delete(messages).go();

  Expression<bool> _forPartner(
    $MessagesTable row,
    String myId,
    String partnerId,
  ) {
    final iAmSender =
        row.senderId.equals(myId) & row.receiverId.equals(partnerId);
    final iAmReceiver =
        row.senderId.equals(partnerId) & row.receiverId.equals(myId);
    return iAmSender | iAmReceiver;
  }
}
