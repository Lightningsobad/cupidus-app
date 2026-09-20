import 'package:drift/drift.dart';

import '../../../core/database/cupid_database.dart';

/// Row access for `portrait_answers`.
///
/// A plain wrapper rather than a `@DriftAccessor` in the database annotation's
/// `daos:` list, for the same reason as `ContextNotebookDao`: that registration
/// would force `core/database/` to import `features/`, which the single Drift
/// owner is not allowed to do (ADR-010).
///
/// Every method takes `ownerKey` explicitly and there is no unfiltered read —
/// a query that forgot the filter would show a second user on the same device
/// what the first user answered.
class PortraitAnswerDao {
  PortraitAnswerDao(this._db);

  final CupidDatabase _db;

  /// Declaration order of the questions pack decides display order, so these
  /// rows are returned unordered on purpose: sorting them here would invent a
  /// second ordering the caller might mistake for progress.
  Future<List<PortraitAnswerRow>> answersFor({required String ownerKey}) =>
      (_db.select(_db.portraitAnswers)
            ..where((t) => t.ownerKey.equals(ownerKey)))
          .get();

  Future<PortraitAnswerRow?> answerRow({
    required String ownerKey,
    required String questionId,
  }) =>
      (_db.select(_db.portraitAnswers)
            ..where(
              (t) =>
                  t.ownerKey.equals(ownerKey) & t.questionId.equals(questionId),
            ))
          .getSingleOrNull();

  /// Answering the same question again replaces the row rather than appending
  /// one, which is what the composite primary key is for: re-answering must not
  /// accumulate history that a later surface could count.
  Future<void> upsertAnswerRow(PortraitAnswersCompanion row) =>
      _db.into(_db.portraitAnswers).insertOnConflictUpdate(row);
}
