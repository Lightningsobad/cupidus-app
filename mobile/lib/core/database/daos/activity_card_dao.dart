import 'package:drift/drift.dart';

import '../cupid_database.dart';
import '../tables/activity_cards_table.dart';
import '../tables/chapter_closure_tables.dart';
import 'chapter_closure_dao.dart';

part 'activity_card_dao.g.dart';

/// DAO for the client-owned activity card store
/// (`architecture/contract-summary.md` §3).
///
/// Deliberately NOT a `SessionScopedStore`: registering the sign-out hook here
/// would turn a sign-out into permanent loss of the user's whole card store
/// (`architecture/solution.md` §1 Key Discovery, AC-22). Isolation between
/// users on one device comes from [ownerKey] filtering on every query instead.
@DriftAccessor(tables: [ActivityCards, ActivityCardPhotos])
class ActivityCardDao extends DatabaseAccessor<CupidDatabase>
    with _$ActivityCardDaoMixin {
  ActivityCardDao(super.db);

  /// Excludes the cards a closed chapter took with it
  /// (`architecture/contract-summary.md` §3).
  ///
  /// Applied in SQL, before `LIMIT`/`OFFSET`: filtering the page in Dart after
  /// the read would return fewer rows than `pageSize` and make the cubit stop
  /// paging early (`ActivityCardListCubit._fetchPage` derives `hasMore` from
  /// `page.length == _pageSize`).
  Expression<bool> get _notClosed => notClosedItem(
        itemKind: ChapterClosureItemKinds.activityCard,
        itemId: activityCards.id,
        closureItems: attachedDatabase.chapterClosureItems,
      );

  /// One status pane, newest-updated first, paged — never a full-table read.
  Future<List<ActivityCardRow>> cardsByStatus({
    required String ownerKey,
    required String status,
    required int limit,
    int offset = 0,
  }) {
    return (select(activityCards)
          ..where((row) =>
              row.ownerKey.equals(ownerKey) &
              row.status.equals(status) &
              _notClosed)
          ..orderBy(_recentFirst)
          ..limit(limit, offset: offset))
        .get();
  }

  /// Live version of [cardsByStatus] for the list screen.
  Stream<List<ActivityCardRow>> watchCardsByStatus({
    required String ownerKey,
    required String status,
    required int limit,
    int offset = 0,
  }) {
    return (select(activityCards)
          ..where((row) =>
              row.ownerKey.equals(ownerKey) &
              row.status.equals(status) &
              _notClosed)
          ..orderBy(_recentFirst)
          ..limit(limit, offset: offset))
        .watch();
  }

  Future<ActivityCardRow?> cardById({
    required String ownerKey,
    required String id,
  }) {
    return (select(activityCards)
          ..where((row) => row.ownerKey.equals(ownerKey) & row.id.equals(id)))
        .getSingleOrNull();
  }

  /// Per-pane badge counts via `COUNT`, never by loading the rows. Statuses
  /// with no card are absent from the map rather than mapped to `0`.
  Future<Map<String, int>> countsByStatus(String ownerKey) async {
    final count = activityCards.id.count();
    final rows = await (selectOnly(activityCards)
          ..addColumns([activityCards.status, count])
          ..where(activityCards.ownerKey.equals(ownerKey) & _notClosed)
          ..groupBy([activityCards.status]))
        .get();
    return {
      for (final row in rows)
        row.read(activityCards.status)!: row.read(count) ?? 0,
    };
  }

  Future<void> upsertCard(ActivityCardsCompanion card) {
    return into(activityCards).insertOnConflictUpdate(card);
  }

  /// Applies [changes] to one card owned by [ownerKey]; returns the number of
  /// rows written, so a caller can tell "not mine" from "updated".
  Future<int> updateCard({
    required String ownerKey,
    required String id,
    required ActivityCardsCompanion changes,
  }) {
    return (update(activityCards)
          ..where((row) => row.ownerKey.equals(ownerKey) & row.id.equals(id)))
        .write(changes);
  }

  /// Deletes the card; its photo rows go with it through the
  /// `ON DELETE CASCADE` foreign key (which needs `PRAGMA foreign_keys`, set in
  /// `CupidDatabase.migration`).
  Future<int> deleteCard({required String ownerKey, required String id}) {
    return (delete(activityCards)
          ..where((row) => row.ownerKey.equals(ownerKey) & row.id.equals(id)))
        .go();
  }

  Future<void> upsertPhoto(ActivityCardPhotosCompanion photo) {
    return into(activityCardPhotos).insertOnConflictUpdate(photo);
  }

  Future<List<ActivityCardPhotoRow>> photosForCard(String cardId) {
    return (select(activityCardPhotos)
          ..where((row) => row.cardId.equals(cardId))
          ..orderBy([(row) => OrderingTerm(expression: row.sortIndex)]))
        .get();
  }

  List<OrderingTerm Function($ActivityCardsTable)> get _recentFirst => [
        (row) =>
            OrderingTerm(expression: row.updatedAt, mode: OrderingMode.desc),
        (row) =>
            OrderingTerm(expression: row.createdAt, mode: OrderingMode.desc),
      ];
}
