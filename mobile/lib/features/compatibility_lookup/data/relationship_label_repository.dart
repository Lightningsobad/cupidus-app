import 'dart:math';

import '../../../core/database/cupid_database.dart';
import '../../../core/database/daos/relationship_labels_dao.dart';
import '../../../core/realtime/backend_user_id_store.dart';

/// Whose label this is. `self` and `partner` are the only two subjects; there
/// is no third "what the app inferred" subject, because AC-7 makes the user
/// typing it the only legal source of a label.
enum LabelSubject {
  self('self'),
  partner('partner');

  const LabelSubject(this.wireValue);

  final String wireValue;

  static LabelSubject fromWireValue(String raw) =>
      LabelSubject.values.firstWhere((subject) => subject.wireValue == raw);
}

/// Which label vocabulary the value belongs to.
enum LabelSystem {
  zodiac('zodiac'),
  mbti('mbti');

  const LabelSystem(this.wireValue);

  final String wireValue;

  static LabelSystem fromWireValue(String raw) =>
      LabelSystem.values.firstWhere((system) => system.wireValue == raw);
}

/// How sure the user is. A [guess] must stay visibly the *user's* guess on
/// every surface that renders it, never a fact the app confirms (AC-8), which
/// is why the distinction is stored rather than flattened away on write.
enum LabelCertainty {
  known('known'),
  guess('guess');

  const LabelCertainty(this.wireValue);

  final String wireValue;

  static LabelCertainty fromWireValue(String raw) =>
      LabelCertainty.values.firstWhere((certainty) => certainty.wireValue == raw);
}

/// One self-declared zodiac/MBTI label.
class RelationshipLabel {
  const RelationshipLabel({
    required this.id,
    required this.ownerKey,
    required this.subject,
    required this.system,
    required this.value,
    required this.certainty,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String ownerKey;
  final LabelSubject subject;
  final LabelSystem system;

  /// An `axis_value.id` from the matching `req016.compat_*` pack.
  final String value;

  final LabelCertainty certainty;
  final DateTime createdAt;
  final DateTime updatedAt;
}

/// The single read/write door onto `relationship_labels`
/// (`architecture/contract-summary.md` §4).
///
/// Deliberately not a `SessionScopedStore`: these rows are client-owned and
/// survive sign-out, so isolation between two users on one device comes from
/// resolving `owner_key` through [BackendUserIdStore] on every call.
///
/// This repository is the only storage STORY-010 has. It writes zero bytes to
/// `notebook_entries` and `skill_profile_entries`, and it has no method that
/// could persist a lookup result — a band, a cell, or a judgement about the
/// other person (AC-31).
class RelationshipLabelRepository {
  RelationshipLabelRepository({
    required RelationshipLabelsDao dao,
    required BackendUserIdStore ownerKeyStore,
    String Function() newId = _newUuidV4,
    DateTime Function() now = DateTime.now,
  })  : _dao = dao,
        _ownerKeyStore = ownerKeyStore,
        _newId = newId,
        _now = now;

  final RelationshipLabelsDao _dao;
  final BackendUserIdStore _ownerKeyStore;
  final String Function() _newId;
  final DateTime Function() _now;

  /// Every label this owner has declared. An empty list is a normal state, not
  /// an error: a user who never declared a label is not behind on anything.
  Future<List<RelationshipLabel>> labels() async {
    final ownerKey = await _requireOwnerKey();
    final rows = await _dao.rowsForOwner(ownerKey);
    return rows.map(_toLabel).toList(growable: false);
  }

  Future<RelationshipLabel?> label({
    required LabelSubject subject,
    required LabelSystem system,
  }) async {
    final ownerKey = await _requireOwnerKey();
    final row = await _dao.rowByNaturalKey(
      ownerKey: ownerKey,
      subject: subject.wireValue,
      system: system.wireValue,
    );
    return row == null ? null : _toLabel(row);
  }

  /// Declares or re-declares one label. Re-declaring the same
  /// `(subject, system)` edits the existing row rather than appending a second
  /// one, so a correction leaves one truth behind and no history of what the
  /// user used to think (AC-9).
  Future<RelationshipLabel> saveLabel({
    required LabelSubject subject,
    required LabelSystem system,
    required String value,
    required LabelCertainty certainty,
  }) async {
    final ownerKey = await _requireOwnerKey();
    final timestamp = _now();
    await _dao.upsertRow(
      RelationshipLabelsCompanion.insert(
        id: _newId(),
        ownerKey: ownerKey,
        subject: subject.wireValue,
        system: system.wireValue,
        value: _requireText(value, 'value'),
        certainty: certainty.wireValue,
        createdAt: timestamp,
        updatedAt: timestamp,
      ),
    );
    final saved = await _dao.rowByNaturalKey(
      ownerKey: ownerKey,
      subject: subject.wireValue,
      system: system.wireValue,
    );
    return _toLabel(saved!);
  }

  /// Removes a label outright. There is no soft-delete and no trash: a user who
  /// withdraws a guess about the other person should leave nothing behind.
  Future<int> deleteLabel({
    required LabelSubject subject,
    required LabelSystem system,
  }) async {
    final ownerKey = await _requireOwnerKey();
    return _dao.deleteByNaturalKey(
      ownerKey: ownerKey,
      subject: subject.wireValue,
      system: system.wireValue,
    );
  }

  Future<String> _requireOwnerKey() async {
    final ownerKey = await _ownerKeyStore.resolve();
    if (ownerKey == null || ownerKey.isEmpty) {
      throw StateError(
        'RelationshipLabelRepository used before a backend user id resolved.',
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

  RelationshipLabel _toLabel(RelationshipLabelRow row) => RelationshipLabel(
        id: row.id,
        ownerKey: row.ownerKey,
        subject: LabelSubject.fromWireValue(row.subject),
        system: LabelSystem.fromWireValue(row.system),
        value: row.value,
        certainty: LabelCertainty.fromWireValue(row.certainty),
        createdAt: row.createdAt,
        updatedAt: row.updatedAt,
      );
}

/// No `uuid` package is a direct dependency of this app, so the client-generated
/// v4 id is produced with `dart:math`'s cryptographic RNG, matching
/// `ContextNotebookRepository` and `ActivityCardRepositoryImpl`.
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
