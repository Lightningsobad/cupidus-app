import 'package:drift/drift.dart';

/// What the user answered in the "Chân dung theo cách BẠN nhìn" question set
/// (`STORY-009/architecture/contract-summary.md` §5). Client-owned and
/// local-only: no server counterpart, no sync, so every later migration
/// touching it must be additive.
///
/// The column set below is a closed allowlist enforced by
/// `test/features/your_view_portrait/portrait_answer_repository_test.dart`.
/// Any column that counts, scores, grades, or measures progress
/// (`answered_count`, `completed_at`, percent, streak, level) is forbidden by
/// R-1b/AC-12/AC-28, and so is any column measuring the other person's
/// behaviour. The rotation cursor of the ask store is likewise absent on
/// purpose — it lives in the Cubit for one screen lifetime (§6).
@DataClassName('PortraitAnswerRow')
class PortraitAnswers extends Table {
  /// Backend `User.id`; every query filters on this column.
  TextColumn get ownerKey => text()();

  /// Stable `items[].id` from `req016.portrait_questions.v1`.
  TextColumn get questionId => text()();

  /// `answered` | `skipped` (§2). `skipped` is a first-class outcome, not a
  /// failure (AC-27).
  TextColumn get state => text()();

  /// Stable id of the chip the user picked, or NULL for free text and for a
  /// skip.
  TextColumn get optionId => text().nullable()();

  /// The answer itself, stored here **only** when the question's target is
  /// `portrait.guess`. A `notebook.*` answer lives in the notebook and is read
  /// back from there, so editing or deleting the notebook entry thins the
  /// portrait instead of leaving two copies that disagree (§4, AC-22).
  TextColumn get answerValue => text().nullable()();

  /// `notebook_entries.id` produced by `recordAnsweredQuestion`, set **only**
  /// for a `notebook.*` target.
  TextColumn get notebookEntryId => text().nullable()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {ownerKey, questionId};
}
