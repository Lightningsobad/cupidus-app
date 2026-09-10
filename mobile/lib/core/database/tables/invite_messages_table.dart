import 'package:drift/drift.dart';

import 'activity_cards_table.dart';

/// One exported invite, stored as the structured payload it was rendered from
/// rather than as the flattened sentence (`architecture/contract-summary.md`
/// §4, SB-125/AC-17). Re-rendering is
/// `userEditedText ?? render(preset[presetId], filledValues)` (AC-18), so
/// writing the rendered string into columns 3-6 is a contract violation.
///
/// Client-owned solo data with no server counterpart, exactly like
/// [ActivityCards]: every later migration touching this table must be
/// additive.
///
/// The column set is a closed allowlist. This table has no recipient, no send
/// channel, no `sent_at`/`opened_at`/`seen_at`, no Share Sheet result, and no
/// export counter — those are forbidden by R-1b/AC-19, and the repository
/// deliberately exposes no count-per-card API (R-1e/AC-14).
@DataClassName('InviteMessageRow')
class InviteMessages extends Table {
  /// Client-generated UUID v4, permanently stable.
  TextColumn get id => text()();

  /// The card this invite was composed from. `ON DELETE CASCADE` (BR-2):
  /// deleting a card takes its invites with it, and enforcement depends on the
  /// `PRAGMA foreign_keys = ON` that `beforeOpen` sets on every connection.
  TextColumn get cardId =>
      text().references(ActivityCards, #id, onDelete: KeyAction.cascade)();

  /// Preset category; `invite` is the only one this story ships (AC-22).
  TextColumn get categoryId => text()();

  /// `items[].id` of the preset used, stable across pack versions.
  TextColumn get presetId => text()();

  /// `version` of the content package at export time, so a later pack revision
  /// is detectable instead of silently changing an already-sent invite.
  TextColumn get packVersion => text()();

  /// JSON object `{variableName: value}` holding only the variables that had
  /// data — the mad-libs input, not the output.
  TextColumn get filledValues => text()();

  /// The user's manual override of the rendered text (AC-7). `NULL` means the
  /// user did not edit, not "empty invite".
  TextColumn get userEditedText => text().nullable()();

  /// Epoch milliseconds at the moment the user tapped share. INTEGER rather
  /// than a `DateTimeColumn`, matching the `link_saved_at` precedent.
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
