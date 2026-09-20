import 'package:drift/drift.dart';

/// The chapter-closure ledger (`architecture/contract-summary.md` §1).
///
/// Closing a chapter does not change any row the user wrote: it records, once,
/// which ids were person-attached at that instant. "Closed" is therefore a
/// filter that lives only here, never a fifth [ActivityCardStatus] and never a
/// `closed_at`/`archived`/`hidden` column on someone else's table (BR-3/BR-4).
///
/// Like `activity_cards` these rows are device-authoritative and exist on no
/// server, so every later migration touching them must be additive
/// (`architecture/solution.md` §1 Key Discovery).
///
/// The column sets below are closed allowlists enforced by
/// `test/core/database/chapter_closure_migration_test.dart`. AC-5/BR-9 forbid
/// storing *why* a chapter was closed or any judgement about the other person,
/// so `reason`, `label`, `note`, `sentiment`, `person*` and `*count*` are
/// permanently banned. `reopened_at` is banned too: reopening deletes the
/// closure row (AC-17), and a history that does not exist can never be shown
/// back to the user as a streak (BR-7).
/// The wire values of `chapter_closure_items.item_kind`, single-sourced here
/// because both `core/` readers and the `features/` vocabulary enum need them
/// and `core/` may not import `features/` (ADR-010).
///
/// Append-only: a value is already written into rows on real devices, so it is
/// never renamed and never reused for a different meaning (§2).
abstract final class ChapterClosureItemKinds {
  static const String activityCard = 'activity_card';
  static const String notebookEntry = 'notebook_entry';
  static const String askPrompt = 'ask_prompt';
}

@DataClassName('ChapterClosureRow')
class ChapterClosures extends Table {
  /// Client-generated UUID v4, permanently stable (R-15a).
  TextColumn get id => text()();

  /// Backend `User.id` — chapter closure is a global event per owner because
  /// stage 1 has exactly one relationship at a time (`ux/uiux-spec.md` §1).
  TextColumn get ownerKey => text()();

  /// Internal ordering only. Never exposed as an elapsed-time measurement
  /// (AC-19/AC-20).
  DateTimeColumn get closedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// One member of a closure: an `(item_kind, item_id)` pair captured at closing
/// time. The snapshot is never recomputed on read — recomputing would pull
/// cards that survived the closure into the closed archive and break AC-9.
///
/// [itemKind] is an append-only vocabulary (`contract-summary.md` §2); [itemId]
/// is the owning table's stable primary key, never a rowid.
@DataClassName('ChapterClosureItemRow')
@TableIndex(
  name: 'chapter_closure_items_kind_item',
  columns: {#itemKind, #itemId},
)
class ChapterClosureItems extends Table {
  /// Cascades so that reopening a chapter is a single-row delete (AC-17). The
  /// cascade only fires because `beforeOpen` switches `PRAGMA foreign_keys` on.
  TextColumn get closureId =>
      text().references(ChapterClosures, #id, onDelete: KeyAction.cascade)();

  /// `activity_card` | `notebook_entry` | `ask_prompt` (§2).
  TextColumn get itemKind => text()();

  TextColumn get itemId => text()();

  @override
  Set<Column> get primaryKey => {closureId, itemKind, itemId};
}
