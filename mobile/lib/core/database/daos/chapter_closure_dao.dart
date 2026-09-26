import 'package:drift/drift.dart';

import '../cupid_database.dart';
import '../tables/chapter_closure_tables.dart';

part 'chapter_closure_dao.g.dart';

/// The canonical anti-join, for use inside another DAO's `where` clause:
///
/// ```sql
/// NOT EXISTS (SELECT 1 FROM chapter_closure_items
///             WHERE item_kind = ? AND item_id = <table>.<pk>)
/// ```
///
/// It lives in `core/` rather than next to `ChapterClosureGate` so that
/// `core/database/daos/activity_card_dao.dart` can exclude closed rows without
/// importing `features/` (ADR-010). [itemKind] must come from
/// [ChapterClosureItemKinds]; the SQL is assembled from that closed vocabulary
/// and from generated column metadata, never from caller-supplied text.
///
/// There is no owner predicate and none is needed: an [itemId] belongs to
/// exactly one owner, and the consumer's own query already filters `owner_key`
/// on its table.
///
/// Filtering here rather than in Dart after the read is what keeps a paged
/// query correct: a Dart-side filter produces short pages and a wrong `hasMore`
/// flag (`architecture/solution.md` §1).
Expression<bool> notClosedItem({
  required String itemKind,
  required GeneratedColumn<String> itemId,
  required $ChapterClosureItemsTable closureItems,
}) {
  return CustomExpression<bool>(
    'NOT EXISTS (SELECT 1 FROM ${closureItems.actualTableName} '
    "WHERE ${closureItems.itemKind.name} = '$itemKind' "
    'AND ${closureItems.itemId.name} = '
    '${itemId.tableName}.${itemId.name})',
    watchedTables: [closureItems],
    precedence: Precedence.comparisonEq,
  );
}

/// Row access for the closure ledger.
///
/// Kinds cross this boundary as plain strings on purpose: `core/` must never
/// import `features/`, so the `ChapterClosureItemKind` vocabulary stays in
/// `features/chapter_closure/` and `ChapterClosureGate` does the conversion.
///
/// There is no `closuresOf(ownerKey)`, no `history()` and no `closedAt`
/// getter here: every closure-count or closure-date query that does not exist
/// is one more way the UI cannot grow a "lần thứ 3 bạn đóng ngăn" string
/// (BR-7).
@DriftAccessor(tables: [ChapterClosures, ChapterClosureItems])
class ChapterClosureDao extends DatabaseAccessor<CupidDatabase>
    with _$ChapterClosureDaoMixin {
  ChapterClosureDao(super.db);

  /// Closure row and all of its members in one transaction, so a crash
  /// mid-close can never leave a half-closed chapter (AC-1).
  Future<void> createClosure({
    required String id,
    required String ownerKey,
    required DateTime closedAt,
    required Map<String, Set<String>> itemIdsByKind,
  }) {
    return transaction(() async {
      await into(chapterClosures).insert(
        ChapterClosuresCompanion.insert(
          id: id,
          ownerKey: ownerKey,
          closedAt: closedAt,
        ),
      );
      await batch((batch) {
        for (final entry in itemIdsByKind.entries) {
          batch.insertAll(chapterClosureItems, <ChapterClosureItemsCompanion>[
            for (final itemId in entry.value)
              ChapterClosureItemsCompanion.insert(
                closureId: id,
                itemKind: entry.key,
                itemId: itemId,
              ),
          ]);
        }
      });
    });
  }

  /// Reopening (AC-17). Members go with it through `ON DELETE CASCADE`.
  Future<int> deleteClosure(String id) =>
      (delete(chapterClosures)..where((row) => row.id.equals(id))).go();

  /// Reopening addressed by owner instead of by closure id.
  ///
  /// Stage 1 has exactly one relationship, and therefore at most one live
  /// closure per owner, so this deletes that one row. Going through the owner
  /// is what lets [deleteClosure]'s id stay unreachable from the UI: a caller
  /// that never learns a closure id can never turn one into a history
  /// (BR-7, AC-17).
  Future<int> deleteClosuresForOwner(String ownerKey) =>
      (delete(chapterClosures)..where((row) => row.ownerKey.equals(ownerKey)))
          .go();

  Future<Set<String>> closedItemIds(String itemKind) async {
    final query = selectOnly(chapterClosureItems)
      ..addColumns([chapterClosureItems.itemId])
      ..where(chapterClosureItems.itemKind.equals(itemKind));
    final rows = await query.get();
    return rows.map((row) => row.read(chapterClosureItems.itemId)!).toSet();
  }

  Future<int> closureCount() async {
    final total = chapterClosures.id.count();
    final row =
        await (selectOnly(chapterClosures)..addColumns([total])).getSingle();
    return row.read(total)!;
  }
}
