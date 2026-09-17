import 'package:drift/drift.dart' show Value;

import '../../../core/database/cupid_database.dart';
import '../../../core/realtime/backend_user_id_store.dart';
import '../domain/portrait_content.dart';
import 'portrait_answer_dao.dart';

/// Terminal state of one portrait question (§2). `skipped` keeps the flow
/// going and carries no consequence (AC-27).
enum PortraitAnswerState {
  answered('answered'),
  skipped('skipped');

  const PortraitAnswerState(this.wireValue);

  final String wireValue;

  static PortraitAnswerState fromWireValue(String value) =>
      PortraitAnswerState.values.firstWhere(
        (state) => state.wireValue == value,
        orElse: _unknownState,
      );

  static Never _unknownState() =>
      throw ArgumentError('Unknown PortraitAnswerState wire value');
}

/// One settled question, as stored.
class PortraitAnswer {
  const PortraitAnswer({
    required this.ownerKey,
    required this.questionId,
    required this.state,
    required this.updatedAt,
    this.optionId,
    this.answerValue,
    this.notebookEntryId,
  });

  final String ownerKey;
  final String questionId;
  final PortraitAnswerState state;

  /// Chip the user picked, or `null` for free text and for a skip.
  final String? optionId;

  /// Set only for a `portrait.guess` question; a `notebook.*` answer is read
  /// back from the notebook so the two never disagree (§4, AC-22).
  final String? answerValue;

  /// Set only for a `notebook.*` question.
  final String? notebookEntryId;

  final DateTime updatedAt;
}

/// The read/write door onto `portrait_answers`.
///
/// Deliberately not a `SessionScopedStore`: these rows are client-owned and
/// survive sign-out, so isolation between two users on one device comes from
/// resolving `owner_key` through [BackendUserIdStore] on every call, exactly
/// like `ContextNotebookRepository`.
///
/// There is no method here that returns how many questions are settled, and
/// [resumeQuestionId] derives the cursor from the answers at read time rather
/// than reading a stored one — a count or a persisted cursor is what a progress
/// bar gets built out of later (AC-26/AC-28, §5).
class PortraitAnswerRepository {
  PortraitAnswerRepository({
    required PortraitAnswerDao dao,
    required BackendUserIdStore ownerKeyStore,
    DateTime Function() now = DateTime.now,
  })  : _dao = dao,
        _ownerKeyStore = ownerKeyStore,
        _now = now;

  final PortraitAnswerDao _dao;
  final BackendUserIdStore _ownerKeyStore;
  final DateTime Function() _now;

  /// Keyed by `question_id`. An empty map is a normal state.
  Future<Map<String, PortraitAnswer>> answers() async {
    final ownerKey = await _requireOwnerKey();
    final rows = await _dao.answersFor(ownerKey: ownerKey);
    return <String, PortraitAnswer>{
      for (final row in rows) row.questionId: _toAnswer(row),
    };
  }

  Future<PortraitAnswer?> answerFor(String questionId) async {
    final ownerKey = await _requireOwnerKey();
    final row = await _dao.answerRow(
      ownerKey: ownerKey,
      questionId: _requireText(questionId, 'questionId'),
    );
    return row == null ? null : _toAnswer(row);
  }

  /// Records an answered question. [target] decides which of the two value
  /// columns may be filled, and the mismatch throws instead of silently
  /// storing a second copy of a notebook entry here.
  Future<PortraitAnswer> upsertAnswer({
    required String questionId,
    required PortraitAnswerTarget target,
    String? optionId,
    String? answerValue,
    String? notebookEntryId,
  }) async {
    final ownerKey = await _requireOwnerKey();
    final id = _requireText(questionId, 'questionId');
    final storedValue = _optionalText(answerValue);
    final storedEntryId = _optionalText(notebookEntryId);
    if (target.writesToNotebook) {
      if (storedEntryId == null) {
        throw ArgumentError.value(
          notebookEntryId,
          'notebookEntryId',
          'a ${target.wireValue} answer must carry the notebook entry it wrote',
        );
      }
      if (storedValue != null) {
        throw ArgumentError.value(
          answerValue,
          'answerValue',
          'a ${target.wireValue} answer lives in the notebook, not here',
        );
      }
    } else {
      if (storedValue == null) {
        throw ArgumentError.value(
          answerValue,
          'answerValue',
          'a ${target.wireValue} answer must carry its value',
        );
      }
      if (storedEntryId != null) {
        throw ArgumentError.value(
          notebookEntryId,
          'notebookEntryId',
          'a ${target.wireValue} answer must not reach the notebook (AC-23)',
        );
      }
    }
    return _write(
      ownerKey: ownerKey,
      questionId: id,
      state: PortraitAnswerState.answered,
      optionId: _optionalText(optionId),
      answerValue: storedValue,
      notebookEntryId: storedEntryId,
    );
  }

  /// Skipping clears any value a previous answer left, so re-skipping a
  /// question is a full reset rather than a half-kept row.
  Future<PortraitAnswer> markSkipped({required String questionId}) async {
    final ownerKey = await _requireOwnerKey();
    return _write(
      ownerKey: ownerKey,
      questionId: _requireText(questionId, 'questionId'),
      state: PortraitAnswerState.skipped,
      optionId: null,
      answerValue: null,
      notebookEntryId: null,
    );
  }

  /// Where to reopen the question set, in the pack's declaration order:
  /// the first question never settled, else the first one skipped so a skip
  /// comes back around on a later pass (AC-27), else `null` when every
  /// question is answered.
  ///
  /// [questionIds] comes from the pack, so pack size stays data (BR-16): this
  /// never asks how many questions exist, only which one is next.
  Future<String?> resumeQuestionId(List<String> questionIds) async {
    final settled = await answers();
    return resolveResumeQuestionId(questionIds, settled);
  }

  Future<PortraitAnswer> _write({
    required String ownerKey,
    required String questionId,
    required PortraitAnswerState state,
    required String? optionId,
    required String? answerValue,
    required String? notebookEntryId,
  }) async {
    final timestamp = _now();
    await _dao.upsertAnswerRow(
      PortraitAnswersCompanion.insert(
        ownerKey: ownerKey,
        questionId: questionId,
        state: state.wireValue,
        optionId: Value(optionId),
        answerValue: Value(answerValue),
        notebookEntryId: Value(notebookEntryId),
        updatedAt: timestamp,
      ),
    );
    final saved = await _dao.answerRow(
      ownerKey: ownerKey,
      questionId: questionId,
    );
    return _toAnswer(saved!);
  }

  Future<String> _requireOwnerKey() async {
    final ownerKey = await _ownerKeyStore.resolve();
    if (ownerKey == null || ownerKey.isEmpty) {
      throw StateError(
        'PortraitAnswerRepository used before a backend user id resolved.',
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

  PortraitAnswer _toAnswer(PortraitAnswerRow row) => PortraitAnswer(
        ownerKey: row.ownerKey,
        questionId: row.questionId,
        state: PortraitAnswerState.fromWireValue(row.state),
        optionId: row.optionId,
        answerValue: row.answerValue,
        notebookEntryId: row.notebookEntryId,
        updatedAt: row.updatedAt,
      );
}

/// Pure form of the resume rule, so the cursor stays derivable from the answer
/// set alone and no column ever has to mean "where the user stopped".
String? resolveResumeQuestionId(
  List<String> questionIds,
  Map<String, PortraitAnswer> settled,
) {
  for (final questionId in questionIds) {
    if (!settled.containsKey(questionId)) {
      return questionId;
    }
  }
  for (final questionId in questionIds) {
    if (settled[questionId]?.state == PortraitAnswerState.skipped) {
      return questionId;
    }
  }
  return null;
}
