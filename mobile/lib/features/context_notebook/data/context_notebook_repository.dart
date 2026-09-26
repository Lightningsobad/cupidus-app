import 'dart:math';

import 'package:drift/drift.dart' show Value;

import '../../../core/database/cupid_database.dart';
import '../../../core/realtime/backend_user_id_store.dart';
import '../domain/context_notebook_models.dart';
import 'context_notebook_dao.dart';

/// The single read/write door onto the context notebook
/// (`architecture/contract-summary.md` §4). Screens and the ask-on-the-spot
/// slot go through here; nothing else touches the three tables.
///
/// Deliberately not a `SessionScopedStore`: these rows are client-owned and
/// survive sign-out, so isolation between two users on one device comes from
/// resolving `owner_key` through [BackendUserIdStore] on every call.
///
/// Normalization and defaults live here rather than in the UI, so an entry
/// written by the inline ask card and one typed on the notebook screen land in
/// the same shape.
class ContextNotebookRepository {
  ContextNotebookRepository({
    required ContextNotebookDao dao,
    required BackendUserIdStore ownerKeyStore,
    String Function() newId = _newUuidV4,
    DateTime Function() now = DateTime.now,
  })  : _dao = dao,
        _ownerKeyStore = ownerKeyStore,
        _newId = newId,
        _now = now;

  final ContextNotebookDao _dao;
  final BackendUserIdStore _ownerKeyStore;
  final String Function() _newId;
  final DateTime Function() _now;

  /// Newest first. An empty list is a normal state, not an error (AC-8).
  Future<List<NotebookEntry>> entries({NotebookKind? kind}) async {
    final ownerKey = await _requireOwnerKey();
    final rows = await _dao.notebookRows(
      ownerKey: ownerKey,
      kind: kind?.wireValue,
    );
    return rows.map(_toEntry).toList(growable: false);
  }

  Future<NotebookEntry?> entryById(String id) async {
    final ownerKey = await _requireOwnerKey();
    final row = await _dao.notebookRowById(ownerKey: ownerKey, id: id);
    return row == null ? null : _toEntry(row);
  }

  Future<NotebookEntry> addEntry({
    required NotebookKind kind,
    required String value,
    required ContextEntrySource source,
    String? detail,
    String? eventOn,
    String? questionId,
  }) async {
    final ownerKey = await _requireOwnerKey();
    final id = _newId();
    final timestamp = _now();
    await _dao.insertNotebookRow(
      NotebookEntriesCompanion.insert(
        id: id,
        ownerKey: ownerKey,
        kind: kind.wireValue,
        value: _requireText(value, 'value'),
        source: source.wireValue,
        detail: Value(_optionalText(detail)),
        eventOn: Value(_eventOnFor(kind, eventOn)),
        questionId: Value(_optionalText(questionId)),
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );
    final saved = await _dao.notebookRowById(ownerKey: ownerKey, id: id);
    return _toEntry(saved!);
  }

  /// Full snapshot of the user-editable fields (AC-9): passing `null` for
  /// [detail] or [eventOn] clears the column rather than leaving it alone,
  /// which is what an edit form that emptied the field means.
  ///
  /// Returns the stored entry, or `null` when the id does not belong to the
  /// current owner.
  Future<NotebookEntry?> updateEntry({
    required String id,
    required String value,
    String? detail,
    String? eventOn,
  }) async {
    final ownerKey = await _requireOwnerKey();
    final existing = await _dao.notebookRowById(ownerKey: ownerKey, id: id);
    if (existing == null) {
      return null;
    }
    await _dao.updateNotebookRow(
      ownerKey: ownerKey,
      id: id,
      changes: NotebookEntriesCompanion(
        value: Value(_requireText(value, 'value')),
        detail: Value(_optionalText(detail)),
        eventOn: Value(
          _eventOnFor(NotebookKind.fromWireValue(existing.kind), eventOn),
        ),
        updatedAt: Value(_now()),
      ),
    );
    final saved = await _dao.notebookRowById(ownerKey: ownerKey, id: id);
    return _toEntry(saved!);
  }

  /// Deletes immediately and reports how many rows went (AC-9). There is no
  /// soft-delete, no trash, and no confirmation state here — undramatic removal
  /// is the contract (R-12).
  Future<int> deleteEntry(String id) async {
    final ownerKey = await _requireOwnerKey();
    return _dao.deleteNotebookRow(ownerKey: ownerKey, id: id);
  }

  /// Oldest first, so a seed chip tapped early keeps its place in the list.
  Future<List<SkillEntry>> skills() async {
    final ownerKey = await _requireOwnerKey();
    final rows = await _dao.skillRows(ownerKey: ownerKey);
    return rows.map(_toSkill).toList(growable: false);
  }

  Future<SkillEntry> addSkill({
    required String label,
    required ContextEntrySource source,
    String? seedId,
  }) async {
    final ownerKey = await _requireOwnerKey();
    final id = _newId();
    final timestamp = _now();
    await _dao.insertSkillRow(
      SkillProfileEntriesCompanion.insert(
        id: id,
        ownerKey: ownerKey,
        label: _requireText(label, 'label'),
        source: source.wireValue,
        seedId: Value(_optionalText(seedId)),
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );
    final saved = await _dao.skillRowById(ownerKey: ownerKey, id: id);
    return _toSkill(saved!);
  }

  Future<SkillEntry?> updateSkill({
    required String id,
    required String label,
  }) async {
    final ownerKey = await _requireOwnerKey();
    final existing = await _dao.skillRowById(ownerKey: ownerKey, id: id);
    if (existing == null) {
      return null;
    }
    await _dao.updateSkillRow(
      ownerKey: ownerKey,
      id: id,
      changes: SkillProfileEntriesCompanion(
        label: Value(_requireText(label, 'label')),
        updatedAt: Value(_now()),
      ),
    );
    final saved = await _dao.skillRowById(ownerKey: ownerKey, id: id);
    return _toSkill(saved!);
  }

  Future<int> deleteSkill(String id) async {
    final ownerKey = await _requireOwnerKey();
    return _dao.deleteSkillRow(ownerKey: ownerKey, id: id);
  }

  /// Every question this owner has already settled, keyed by question id.
  Future<Map<String, AskPromptStatus>> promptStates() async {
    final ownerKey = await _requireOwnerKey();
    final rows = await _dao.promptStateRows(ownerKey: ownerKey);
    return <String, AskPromptStatus>{
      for (final row in rows)
        row.questionId: AskPromptStatus.fromWireValue(row.state),
    };
  }

  Future<AskPromptStatus?> promptState(String questionId) async {
    final ownerKey = await _requireOwnerKey();
    final row = await _dao.promptStateRow(
      ownerKey: ownerKey,
      questionId: questionId,
    );
    return row == null ? null : AskPromptStatus.fromWireValue(row.state);
  }

  Future<void> recordPromptState({
    required String questionId,
    required AskPromptStatus state,
  }) async {
    final ownerKey = await _requireOwnerKey();
    await _dao.upsertPromptStateRow(
      AskPromptStateCompanion.insert(
        ownerKey: ownerKey,
        questionId: _requireText(questionId, 'questionId'),
        state: state.wireValue,
        updatedAt: _now(),
      ),
    );
  }

  Future<String> _requireOwnerKey() async {
    final ownerKey = await _ownerKeyStore.resolve();
    if (ownerKey == null || ownerKey.isEmpty) {
      throw StateError(
        'ContextNotebookRepository used before a backend user id resolved.',
      );
    }
    return ownerKey;
  }

  String _requireText(String raw, String field) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(raw, field, 'must not be blank');
    }
    return trimmed;
  }

  String? _optionalText(String? raw) {
    final trimmed = raw?.trim();
    return (trimmed == null || trimmed.isEmpty) ? null : trimmed;
  }

  /// A date only means something on an `event` entry (§4), so an interest can
  /// never carry one even if the caller passes it.
  String? _eventOnFor(NotebookKind kind, String? eventOn) =>
      kind == NotebookKind.event ? _optionalText(eventOn) : null;

  NotebookEntry _toEntry(NotebookEntryRow row) => NotebookEntry(
        id: row.id,
        ownerKey: row.ownerKey,
        kind: NotebookKind.fromWireValue(row.kind),
        value: row.value,
        detail: row.detail,
        eventOn: row.eventOn,
        source: ContextEntrySource.fromWireValue(row.source),
        questionId: row.questionId,
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );

  SkillEntry _toSkill(SkillProfileEntryRow row) => SkillEntry(
        id: row.id,
        ownerKey: row.ownerKey,
        label: row.label,
        seedId: row.seedId,
        source: ContextEntrySource.fromWireValue(row.source),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}

/// No `uuid` package is a direct dependency of this app, so the client-generated
/// v4 id (R-15a: never a rowid/autoincrement) is produced with `dart:math`'s
/// cryptographic RNG, matching `ActivityCardRepositoryImpl`.
String _newUuidV4() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int start, int end) => bytes
      .sublist(start, end)
      .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
      .join();
  return '${hex(0, 4)}-${hex(4, 6)}-${hex(6, 8)}-${hex(8, 10)}-${hex(10, 16)}';
}
