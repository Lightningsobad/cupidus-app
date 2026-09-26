import 'package:drift/drift.dart';

import '../../../core/database/cupid_database.dart';
import '../../chapter_closure/domain/chapter_closure_gate.dart';

/// Row access for the three context-notebook tables.
///
/// A plain wrapper rather than a `@DriftAccessor` registered in the database
/// annotation's `daos:` list: that registration would force
/// `core/database/cupid_database.dart` to import `features/`, which the single
/// Drift owner is not allowed to do (ADR-010).
///
/// Every method takes `ownerKey` explicitly. There is no unfiltered read on
/// purpose — a query that forgets the filter would let a second user on the
/// same device see the first user's notebook.
class ContextNotebookDao {
  ContextNotebookDao(this._db);

  final CupidDatabase _db;

  /// Backs `ContextNotebookRepository.entries()` and nothing else, which is why
  /// the closure exclusion lives here rather than behind a flag: `skills()`
  /// (AC-8) and `promptStateRows` read their own tables and are untouched.
  Future<List<NotebookEntryRow>> notebookRows({
    required String ownerKey,
    String? kind,
  }) {
    final query = _db.select(_db.notebookEntries)
      ..where(
        (t) =>
            t.ownerKey.equals(ownerKey) &
            ChapterClosureGate.notClosed(
              kind: ChapterClosureItemKind.notebookEntry,
              itemId: t.id,
              closureItems: _db.chapterClosureItems,
            ),
      );
    if (kind != null) {
      query.where((t) => t.kind.equals(kind));
    }
    query.orderBy([
      (t) => OrderingTerm.desc(t.createdAt),
      (t) => OrderingTerm.desc(t.id),
    ]);
    return query.get();
  }

  Future<NotebookEntryRow?> notebookRowById({
    required String ownerKey,
    required String id,
  }) =>
      (_db.select(_db.notebookEntries)
            ..where((t) => t.ownerKey.equals(ownerKey) & t.id.equals(id)))
          .getSingleOrNull();

  Future<void> insertNotebookRow(NotebookEntriesCompanion row) =>
      _db.into(_db.notebookEntries).insert(row);

  Future<int> updateNotebookRow({
    required String ownerKey,
    required String id,
    required NotebookEntriesCompanion changes,
  }) =>
      (_db.update(_db.notebookEntries)
            ..where((t) => t.ownerKey.equals(ownerKey) & t.id.equals(id)))
          .write(changes);

  Future<int> deleteNotebookRow({
    required String ownerKey,
    required String id,
  }) =>
      (_db.delete(_db.notebookEntries)
            ..where((t) => t.ownerKey.equals(ownerKey) & t.id.equals(id)))
          .go();

  Future<List<SkillProfileEntryRow>> skillRows({required String ownerKey}) =>
      (_db.select(_db.skillProfileEntries)
            ..where((t) => t.ownerKey.equals(ownerKey))
            ..orderBy([
              (t) => OrderingTerm.asc(t.createdAt),
              (t) => OrderingTerm.asc(t.id),
            ]))
          .get();

  Future<SkillProfileEntryRow?> skillRowById({
    required String ownerKey,
    required String id,
  }) =>
      (_db.select(_db.skillProfileEntries)
            ..where((t) => t.ownerKey.equals(ownerKey) & t.id.equals(id)))
          .getSingleOrNull();

  Future<void> insertSkillRow(SkillProfileEntriesCompanion row) =>
      _db.into(_db.skillProfileEntries).insert(row);

  Future<int> updateSkillRow({
    required String ownerKey,
    required String id,
    required SkillProfileEntriesCompanion changes,
  }) =>
      (_db.update(_db.skillProfileEntries)
            ..where((t) => t.ownerKey.equals(ownerKey) & t.id.equals(id)))
          .write(changes);

  Future<int> deleteSkillRow({
    required String ownerKey,
    required String id,
  }) =>
      (_db.delete(_db.skillProfileEntries)
            ..where((t) => t.ownerKey.equals(ownerKey) & t.id.equals(id)))
          .go();

  Future<List<AskPromptStateRow>> promptStateRows({required String ownerKey}) =>
      (_db.select(_db.askPromptState)
            ..where((t) => t.ownerKey.equals(ownerKey)))
          .get();

  Future<AskPromptStateRow?> promptStateRow({
    required String ownerKey,
    required String questionId,
  }) =>
      (_db.select(_db.askPromptState)
            ..where(
              (t) =>
                  t.ownerKey.equals(ownerKey) & t.questionId.equals(questionId),
            ))
          .getSingleOrNull();

  Future<void> upsertPromptStateRow(AskPromptStateCompanion row) =>
      _db.into(_db.askPromptState).insertOnConflictUpdate(row);
}
