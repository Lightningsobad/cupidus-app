import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/content_package.dart';
import '../../../context_notebook/context_notebook_entry_point.dart';
import '../../data/portrait_answer_repository.dart';
import '../../domain/portrait_composer.dart';
import '../../domain/portrait_content.dart';

/// Entry-point id carried on every notebook write made from this screen, so a
/// notebook entry stays traceable to where the user typed it (AC-22).
const String portraitEntryPointId = 'your_view_portrait';

/// Signature of [recordAnsweredQuestion], the only legal door into the
/// notebook. Injectable so a test can observe the call without reaching past
/// the entry point.
typedef PortraitNotebookRecorder = Future<String> Function({
  required String entryPointId,
  required String questionId,
  required NotebookKind kind,
  required String value,
  String? detail,
  String? eventOn,
});

enum PortraitStage { loading, questioning, portrait }

class YourViewPortraitState {
  const YourViewPortraitState({
    required this.stage,
    this.question,
    this.questionPosition = 0,
    this.questionCount = 0,
    this.sections = const <ComposedSection>[],
  });

  const YourViewPortraitState.loading() : this(stage: PortraitStage.loading);

  final PortraitStage stage;

  /// The single question on screen. One at a time is the whole point (AC-25).
  final PortraitQuestion? question;

  /// 1-based position of [question] inside the pack, and the pack size. Both
  /// exist only to label the open question sheet; nothing persists them and no
  /// widget turns them into a completion ratio (AC-26/AC-28, BR-16).
  final int questionPosition;
  final int questionCount;

  final List<ComposedSection> sections;
}

class YourViewPortraitCubit extends Cubit<YourViewPortraitState> {
  YourViewPortraitCubit({
    required PortraitAnswerRepository answers,
    ContentPackageLoader contentLoader = const ContentPackageLoader(),
    ContextNotebookReader? notebook,
    PortraitNotebookRecorder recorder = recordAnsweredQuestion,
  })  : _repository = answers,
        _contentLoader = contentLoader,
        _notebook = notebook,
        _recorder = recorder,
        super(const YourViewPortraitState.loading()) {
    unawaited(_load());
  }

  final PortraitAnswerRepository _repository;
  final ContentPackageLoader _contentLoader;
  final ContextNotebookReader? _notebook;
  final PortraitNotebookRecorder _recorder;

  late final ContentPackage<PortraitQuestion> _questions;
  late final ContentPackage<PortraitSection> _sections;
  late final ContentPackage<PortraitAsk> _asks;

  final Map<String, PortraitAnswer> _answers = <String, PortraitAnswer>{};

  /// Questions the user skipped since this screen opened. They stay out of the
  /// current pass so the screen cannot loop back onto a question the user just
  /// declined; the next open offers them again (AC-27).
  final Set<String> _skippedThisPass = <String>{};

  /// Held here, never written to the database, and deliberately never advanced:
  /// two reads of the same answers must render identically (AC-29).
  static const int _askCursor = 0;

  Future<void> _load() async {
    _questions = await _contentLoader.load<PortraitQuestion>(
      portraitQuestionsAssetKey,
      expectedSchemaId: portraitQuestionsSchemaId,
      itemParser: portraitQuestionFromJson,
    );
    _sections = await _contentLoader.load<PortraitSection>(
      portraitSectionsAssetKey,
      expectedSchemaId: portraitSectionsSchemaId,
      itemParser: portraitSectionFromJson,
    );
    _asks = await _contentLoader.load<PortraitAsk>(
      portraitAsksAssetKey,
      expectedSchemaId: portraitAsksSchemaId,
      itemParser: portraitAskFromJson,
    );
    _answers.addAll(await _repository.answers());
    await _refresh();
  }

  Future<void> answer({required String value, String? optionId}) async {
    final PortraitQuestion? current = state.question;
    if (current == null) {
      return;
    }
    final String trimmed = value.trim();
    if (trimmed.isEmpty) {
      return;
    }

    String? notebookEntryId;
    if (current.target.writesToNotebook) {
      notebookEntryId = await _recorder(
        entryPointId: portraitEntryPointId,
        questionId: current.id,
        kind: current.target == PortraitAnswerTarget.notebookInterest
            ? NotebookKind.interest
            : NotebookKind.event,
        value: trimmed,
      );
    }

    _answers[current.id] = await _repository.upsertAnswer(
      questionId: current.id,
      target: current.target,
      optionId: optionId,
      answerValue: notebookEntryId == null ? trimmed : null,
      notebookEntryId: notebookEntryId,
    );
    await _refresh();
  }

  Future<void> skip() async {
    final PortraitQuestion? current = state.question;
    if (current == null) {
      return;
    }
    _answers[current.id] = await _repository.markSkipped(
      questionId: current.id,
    );
    _skippedThisPass.add(current.id);
    await _refresh();
  }

  Future<void> _refresh() async {
    final String? nextId = _nextQuestionId();
    if (nextId == null) {
      _emit(
        YourViewPortraitState(
          stage: PortraitStage.portrait,
          sections: await _compose(),
        ),
      );
      return;
    }
    final int index = _questions.items.indexWhere((q) => q.id == nextId);
    _emit(
      YourViewPortraitState(
        stage: PortraitStage.questioning,
        question: _questions.items[index],
        questionPosition: index + 1,
        questionCount: _questions.length,
      ),
    );
  }

  /// First question never settled, then the first one skipped on an earlier
  /// visit. Identical to [PortraitAnswerRepository.resumeQuestionId] on a fresh
  /// open, and only diverges by holding back this pass's own skips.
  String? _nextQuestionId() {
    for (final PortraitQuestion question in _questions.items) {
      if (!_answers.containsKey(question.id)) {
        return question.id;
      }
    }
    for (final PortraitQuestion question in _questions.items) {
      if (_skippedThisPass.contains(question.id)) {
        continue;
      }
      if (_answers[question.id]!.state == PortraitAnswerState.skipped) {
        return question.id;
      }
    }
    return null;
  }

  Future<List<ComposedSection>> _compose() async {
    final ContextNotebookReader notebook = _notebook ?? contextNotebookReader();
    final List<NotebookEntry> entries = await notebook.entries();
    return composePortrait(
      sections: _sections,
      asks: _asks,
      answers: <String, PortraitSettledAnswer>{
        for (final MapEntry<String, PortraitAnswer> entry in _answers.entries)
          entry.key: PortraitSettledAnswer(
            skipped: entry.value.state == PortraitAnswerState.skipped,
            answerValue: entry.value.answerValue,
            notebookEntryId: entry.value.notebookEntryId,
          ),
      },
      notebookValues: <String, String>{
        for (final NotebookEntry entry in entries) entry.id: entry.value,
      },
      askCursor: _askCursor,
    );
  }

  void _emit(YourViewPortraitState next) {
    if (isClosed) {
      return;
    }
    emit(next);
  }
}
