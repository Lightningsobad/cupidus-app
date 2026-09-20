import 'package:drift/drift.dart';

import '../cupid_database.dart';
import '../tables/journal_entries.dart';
import '../tables/journal_photos.dart';

part 'journal_dao.g.dart';

/// DAO for the private journal tables.
///
/// Deliberately NOT a `SessionScopedStore`, unlike [TimelineDao] and the
/// message store: journal rows are content the user typed, not a refetchable
/// cache, so clearing them on sign-out would be permanent data loss
/// (`architecture/solution.md` §1 Key Discovery 2). Multi-account isolation on
/// a shared device comes from the mandatory `ownerUserId` filter instead —
/// which is why no method here omits that parameter, and why there is no
/// unfiltered `clearAll()`.
@DriftAccessor(tables: [JournalEntries, JournalPhotos])
class JournalDao extends DatabaseAccessor<CupidDatabase>
    with _$JournalDaoMixin {
  JournalDao(super.db);

  /// Newest-first page of one owner's entries.
  Stream<List<JournalEntry>> watchEntries(
    String ownerUserId, {
    int limit = 50,
    int offset = 0,
  }) {
    return (select(journalEntries)
          ..where((t) => t.ownerUserId.equals(ownerUserId))
          ..orderBy([
            (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc),
          ])
          ..limit(limit, offset: offset))
        .watch();
  }

  Future<JournalEntry?> entryById(String ownerUserId, String id) {
    return (select(journalEntries)
          ..where((t) => t.ownerUserId.equals(ownerUserId) & t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Writes [entry] under [ownerUserId], reusing the existing row when the id
  /// is already this owner's (AC-3: editing never mints a new id). An id that
  /// belongs to a different owner is left untouched, so a second account on the
  /// device can neither read nor overwrite the first one's entry.
  Future<void> upsertEntry(String ownerUserId, JournalEntry entry) {
    final row = entry.copyWith(ownerUserId: ownerUserId);
    return transaction(() async {
      final existing = await entryById(ownerUserId, row.id);
      if (existing == null) {
        await into(journalEntries).insert(row, mode: InsertMode.insertOrIgnore);
      } else {
        await (update(journalEntries)
              ..where(
                (t) => t.id.equals(row.id) & t.ownerUserId.equals(ownerUserId),
              ))
            .write(row.toCompanion(false));
      }
    });
  }

  /// Deletes one entry and its photo rows in a single transaction. The photo
  /// delete is explicit rather than relying only on the FK cascade, so an
  /// environment that opens the database without `foreign_keys` still cannot
  /// leave orphan rows behind (AC-13).
  Future<void> deleteEntry(String ownerUserId, String id) {
    return transaction(() async {
      final owned = await entryById(ownerUserId, id);
      if (owned == null) {
        return;
      }
      await (delete(journalPhotos)..where((t) => t.entryId.equals(id))).go();
      await (delete(journalEntries)
            ..where((t) => t.id.equals(id) & t.ownerUserId.equals(ownerUserId)))
          .go();
    });
  }

  /// AC-12 "delete everything": one transaction, scoped to a single owner.
  Future<void> deleteAllEntries(String ownerUserId) {
    return transaction(() async {
      final ids = await liveEntryIds(ownerUserId);
      if (ids.isEmpty) {
        return;
      }
      await (delete(journalPhotos)..where((t) => t.entryId.isIn(ids))).go();
      await (delete(journalEntries)
            ..where((t) => t.ownerUserId.equals(ownerUserId)))
          .go();
    });
  }

  /// Ids the orphan media sweep checks surviving photo directories against.
  Future<List<String>> liveEntryIds(String ownerUserId) {
    final query = selectOnly(journalEntries)
      ..addColumns([journalEntries.id])
      ..where(journalEntries.ownerUserId.equals(ownerUserId));
    return query.map((row) => row.read(journalEntries.id)!).get();
  }
}
