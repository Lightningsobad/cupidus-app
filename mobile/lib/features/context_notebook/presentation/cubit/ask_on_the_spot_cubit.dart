import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/content_package.dart';
import '../../data/context_notebook_repository.dart';
import '../../domain/ask_cadence_policy.dart';
import '../../domain/context_content.dart';
import '../../domain/context_notebook_models.dart';

enum AskSlotStatus { loading, hidden, asking }

/// One tap-to-pick seed on the ask card. [seedId] is set only for skill seeds,
/// where the stable id is what `skill_profile_entries.seed_id` stores; a chip
/// authored inside a notebook question has no id of its own.
class AskChoice {
  const AskChoice({required this.label, this.seedId});

  final String label;
  final String? seedId;
}

class AskOnTheSpotState {
  const AskOnTheSpotState._({
    required this.status,
    this.question,
    this.choices = const <AskChoice>[],
  });

  const AskOnTheSpotState.loading() : this._(status: AskSlotStatus.loading);

  const AskOnTheSpotState.hidden() : this._(status: AskSlotStatus.hidden);

  const AskOnTheSpotState.asking({
    required AskQuestion question,
    required List<AskChoice> choices,
  }) : this._(
          status: AskSlotStatus.asking,
          question: question,
          choices: choices,
        );

  final AskSlotStatus status;
  final AskQuestion? question;

  /// Always non-empty while asking: a question with no seeds is the blank
  /// "your skills are?" box AC-10 forbids.
  final List<AskChoice> choices;

  bool get allowFreeText => question?.allowFreeText ?? false;
}

/// Drives one inline ask card: which question, which seeds, and where the
/// answer lands.
///
/// Answering writes straight through the repository and then leaves — there is
/// no "saved" state between asking and hidden, because AC-1 forbids the
/// confirmation screen or toast such a state would exist to render.
class AskOnTheSpotCubit extends Cubit<AskOnTheSpotState> {
  AskOnTheSpotCubit({
    required ContextNotebookRepository repository,
    required List<String> neededFieldIds,
    ContentPackageLoader contentLoader = const ContentPackageLoader(),
    AskCadencePolicy policy = const AskCadencePolicy(),
    AskSessionSkips? sessionSkips,
  })  : _repository = repository,
        _neededFieldIds = neededFieldIds,
        _contentLoader = contentLoader,
        _policy = policy,
        _sessionSkips = sessionSkips ?? AskSessionSkips.shared,
        super(const AskOnTheSpotState.loading()) {
    unawaited(_load());
  }

  final ContextNotebookRepository _repository;
  final List<String> _neededFieldIds;
  final ContentPackageLoader _contentLoader;
  final AskCadencePolicy _policy;
  final AskSessionSkips _sessionSkips;

  Future<void> _load() async {
    try {
      final ContentPackage<AskQuestion> questions =
          await _contentLoader.load<AskQuestion>(
        askQuestionsAssetKey,
        expectedSchemaId: askQuestionsSchemaId,
        itemParser: askQuestionFromJson,
      );
      final Map<String, AskPromptStatus> settled =
          await _repository.promptStates();
      final AskQuestion? question = _policy.nextQuestion(
        questions: questions,
        neededFieldIds: _neededFieldIds,
        settled: settled,
        sessionSkips: _sessionSkips,
      );
      if (question == null) {
        _emit(const AskOnTheSpotState.hidden());
        return;
      }
      _emit(
        AskOnTheSpotState.asking(
          question: question,
          choices: await _choicesFor(question),
        ),
      );
    } on Object {
      // The ask card is an optional enrichment of somebody else's flow, and
      // BR-1/AC-3 say that flow is never blocked. An owner key that has not
      // resolved yet, or a bundle without the packs, makes the card absent —
      // never an error the host screen has to render.
      _emit(const AskOnTheSpotState.hidden());
    }
  }

  Future<List<AskChoice>> _choicesFor(AskQuestion question) async {
    if (question.target != AskTarget.skill) {
      return <AskChoice>[
        for (final String chip in question.chips) AskChoice(label: chip),
      ];
    }
    // AC-10/AC-11: a skill question is answered from the shipped seed set, not
    // from the question's own chips, so the everyday soft skills the gate
    // guarantees are on screen before the user types anything. Declaration
    // order is kept as authored — pulling the four required seeds to the front
    // would be exactly the "nhóm phụ" ranking `uiux-spec.md` Phần C forbids.
    final ContentPackage<SkillSeed> seeds = await _contentLoader.load<SkillSeed>(
      skillSeedsAssetKey,
      expectedSchemaId: skillSeedsSchemaId,
      itemParser: skillSeedFromJson,
    );
    return <AskChoice>[
      for (final SkillSeed seed in seeds.items)
        AskChoice(label: seed.label, seedId: seed.id),
    ];
  }

  /// Writes [label] where this question's target says it goes, then hides the
  /// card. Callers refresh their own results afterwards; nothing here shows a
  /// confirmation (AC-1).
  Future<void> answer({required String label, String? seedId}) async {
    final AskQuestion? question = state.question;
    if (state.status != AskSlotStatus.asking || question == null) {
      return;
    }
    final String value = label.trim();
    if (value.isEmpty) {
      return;
    }

    switch (question.target) {
      case AskTarget.notebookInterest:
        await _repository.addEntry(
          kind: NotebookKind.interest,
          value: value,
          source: ContextEntrySource.askOnTheSpot,
          questionId: question.id,
        );
      case AskTarget.notebookEvent:
        await _repository.addEntry(
          kind: NotebookKind.event,
          value: value,
          source: ContextEntrySource.askOnTheSpot,
          questionId: question.id,
        );
      case AskTarget.skill:
        await _repository.addSkill(
          label: value,
          source: ContextEntrySource.askOnTheSpot,
          seedId: seedId,
        );
    }
    await _repository.recordPromptState(
      questionId: question.id,
      state: AskPromptStatus.answered,
    );
    _emit(const AskOnTheSpotState.hidden());
  }

  /// Hands the flow back before the write, because AC-3's "không bị chặn" is
  /// about the user, not about the database.
  Future<void> skip() async {
    final AskQuestion? question = state.question;
    if (state.status != AskSlotStatus.asking || question == null) {
      return;
    }
    _sessionSkips.add(question.id);
    _emit(const AskOnTheSpotState.hidden());
    await _repository.recordPromptState(
      questionId: question.id,
      state: AskPromptStatus.skipped,
    );
  }

  void _emit(AskOnTheSpotState next) {
    if (!isClosed) {
      emit(next);
    }
  }
}
