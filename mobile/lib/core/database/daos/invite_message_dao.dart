import 'package:drift/drift.dart';

import '../cupid_database.dart';
import '../tables/invite_messages_table.dart';

part 'invite_message_dao.g.dart';

/// Row access for [InviteMessages].
///
/// Two point reads and one insert, and nothing else. There is deliberately no
/// `countForCard`, no `watchAll`, and no `selectOnly` aggregate: R-1e/AC-14
/// forbid comparing or scoring exported invites, and the cheapest way to keep
/// that true is for the query to not exist at this layer either.
///
/// Unlike `JournalDao` there is no `ownerUserId` filter here — an invite is
/// reached only through its card, and the card's `ON DELETE CASCADE` is what
/// scopes and disposes of it (BR-2).
@DriftAccessor(tables: [InviteMessages])
class InviteMessageDao extends DatabaseAccessor<CupidDatabase>
    with _$InviteMessageDaoMixin {
  InviteMessageDao(super.db);

  Future<void> insertMessage(InviteMessagesCompanion row) =>
      into(inviteMessages).insert(row);

  /// Newest export for one card. Ties break on `id` descending so two taps
  /// landing in the same millisecond still resolve to one deterministic row
  /// instead of whichever the storage engine happened to return first.
  Future<InviteMessageRow?> latestForCard(String cardId) =>
      (select(inviteMessages)
            ..where((t) => t.cardId.equals(cardId))
            ..orderBy([
              (t) => OrderingTerm.desc(t.createdAt),
              (t) => OrderingTerm.desc(t.id),
            ])
            ..limit(1))
          .getSingleOrNull();

  Future<InviteMessageRow?> rowById(String id) =>
      (select(inviteMessages)..where((t) => t.id.equals(id))).getSingleOrNull();
}
