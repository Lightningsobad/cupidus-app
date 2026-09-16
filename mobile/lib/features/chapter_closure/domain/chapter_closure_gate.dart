import 'package:drift/drift.dart';

import '../../../core/database/cupid_database.dart';
import '../../../core/database/daos/chapter_closure_dao.dart';
import '../../../core/database/tables/chapter_closure_tables.dart';

/// The append-only membership vocabulary of the closure ledger
/// (`architecture/contract-summary.md` §2).
///
/// A value is never renamed and never reused for a different meaning: the wire
/// value is already written into `chapter_closure_items` rows on real devices.
/// Private journal entries are deliberately absent — they are never closure
/// members (BR-6) — and so is the skill profile, which is never filtered
/// (AC-8).
enum ChapterClosureItemKind {
  activityCard(ChapterClosureItemKinds.activityCard),
  notebookEntry(ChapterClosureItemKinds.notebookEntry),

  /// `item_id` is the `question_id`, not a row id (§2).
  askPrompt(ChapterClosureItemKinds.askPrompt);

  const ChapterClosureItemKind(this.wireValue);

  final String wireValue;
}

/// The only read API for "what is currently closed"
/// (`architecture/contract-summary.md` §3).
///
/// Every consumer that reads person-attached data goes through this gate, and
/// a consumer whose query has `LIMIT`/`OFFSET` must use [notClosed] rather than
/// [closedIdsOf]: filtering in Dart after the read produces short pages and a
/// wrong `hasMore` flag (`architecture/solution.md` §1).
///
/// `closedAt` is intentionally unreachable from here. Nothing outside the DAO
/// may turn a closure into a duration, a date, or a count of past chapters
/// (BR-7, AC-19/AC-20).
class ChapterClosureGate {
  const ChapterClosureGate(this._dao);

  final ChapterClosureDao _dao;

  /// Ids currently closed for one kind. An empty set is the normal state, not
  /// an error: before the first closure every query simply excludes nothing.
  Future<Set<String>> closedIdsOf(ChapterClosureItemKind kind) =>
      _dao.closedItemIds(kind.wireValue);

  /// Drives progressive disclosure of the "Đã đóng" pane, which stays hidden
  /// until the user has actually closed something.
  Future<bool> hasAnyClosure() async => await _dao.closureCount() > 0;

  /// The canonical anti-join, for use inside another DAO's `where` clause.
  ///
  /// The expression itself is built by `notClosedItem` in `core/`: readers that
  /// live under `core/database/daos/` need the same clause and may not import
  /// this file (ADR-010), so the builder sits on the side both callers can
  /// reach and this is the typed entry point for `features/` callers.
  static Expression<bool> notClosed({
    required ChapterClosureItemKind kind,
    required GeneratedColumn<String> itemId,
    required $ChapterClosureItemsTable closureItems,
  }) {
    return notClosedItem(
      itemKind: kind.wireValue,
      itemId: itemId,
      closureItems: closureItems,
    );
  }
}
