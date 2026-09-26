import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/content/content_package.dart';
import '../../../../core/di/service_locator.dart';
import '../../../activity_cards/domain/activity_card.dart';
import '../../../activity_cards/domain/activity_card_repository.dart';
import '../../../context_notebook/context_notebook_entry_point.dart';
import '../../data/zodiac_rotation_store.dart';
import '../../domain/zodiac_shell_content.dart';
import '../../domain/zodiac_shell_resolver.dart';

/// Which of the shell's surfaces is showing.
enum ZodiacShellStage { loading, picker, asking, result }

/// Everything the zodiac shell screens draw.
///
/// Deliberately absent: how many questions this round holds, which one of them
/// is showing, and how many rounds this set has seen. A progress bar, a
/// "câu 2/5", or a "đã hết" line cannot be built from this state at all, which
/// is a stronger guarantee than a widget that merely declines to draw one
/// (AC-18/AC-19/AC-31).
class ZodiacShellState {
  const ZodiacShellState({
    required this.stage,
    required this.sets,
    this.set,
    this.question,
    this.result,
  });

  static const ZodiacShellState initial = ZodiacShellState(
    stage: ZodiacShellStage.loading,
    sets: <ZodiacQuizSet>[],
  );

  final ZodiacShellStage stage;

  /// Every playable set, in pack order. All of them are always open (AC-19).
  final List<ZodiacQuizSet> sets;

  /// The set being played, `null` on the picker.
  final ZodiacQuizSet? set;

  /// The one question on screen, `null` outside [ZodiacShellStage.asking].
  final ZodiacQuestion? question;

  /// The finished round, `null` outside [ZodiacShellStage.result].
  final ZodiacShellResult? result;
}

/// One play session: read the two packs once, ask a rotating window of
/// questions, and resolve the round against what the user wrote down.
///
/// The packs are cached for the life of the cubit so a second round does not
/// re-parse them (`solution.md` §5). Nothing here reads the clock, so the same
/// set answered the same way lands on the same outcome tomorrow (AC-21).
class ZodiacShellCubit extends Cubit<ZodiacShellState> {
  ZodiacShellCubit({
    ContentPackageLoader contentLoader = const ContentPackageLoader(),
    ZodiacRotationStore? rotationStore,
    ActivityCardRepository? cardStore,
    ContextNotebookReader? notebookReader,
  })  : _loader = contentLoader,
        _rotation = rotationStore ?? ZodiacRotationStore(),
        _cards = cardStore,
        _notebook = notebookReader,
        super(ZodiacShellState.initial);

  final ContentPackageLoader _loader;
  final ZodiacRotationStore _rotation;
  final ActivityCardRepository? _cards;
  final ContextNotebookReader? _notebook;

  ContentPackage<ZodiacQuizSet>? _quiz;
  ContentPackage<ZodiacOutcome>? _outcomes;

  List<ZodiacQuestion> _round = const <ZodiacQuestion>[];
  final List<ZodiacAnswer> _answers = <ZodiacAnswer>[];

  Future<void> load() async {
    final ContentPackage<ZodiacQuizSet> quiz =
        _quiz ??= await _loader.load<ZodiacQuizSet>(
      zodiacQuizAssetKey,
      expectedSchemaId: zodiacQuizSchemaId,
      itemParser: zodiacQuizSetFromJson,
    );
    _outcomes ??= await _loader.load<ZodiacOutcome>(
      zodiacOutcomesAssetKey,
      expectedSchemaId: zodiacOutcomesSchemaId,
      itemParser: zodiacOutcomeFromJson,
    );
    if (isClosed) {
      return;
    }
    emit(ZodiacShellState(stage: ZodiacShellStage.picker, sets: quiz.items));
  }

  /// Opens [setId] on its next rotation window.
  Future<void> startSet(String setId) async {
    final ZodiacQuizSet? set = _quiz?.itemById(setId);
    if (set == null) {
      return;
    }

    final List<int> window = await _rotation.nextWindow(
      setId: set.id,
      total: set.questions.length,
      perRound: set.questionsPerRound,
    );
    if (isClosed) {
      return;
    }

    _round = <ZodiacQuestion>[
      for (final int index in window) set.questions[index],
    ];
    _answers.clear();
    emit(
      ZodiacShellState(
        stage: ZodiacShellStage.asking,
        sets: state.sets,
        set: set,
        question: _round.first,
      ),
    );
  }

  /// Records the option picked for the question on screen and moves on, or
  /// resolves the round when that was its last question.
  Future<void> answer(String optionId) async {
    final ZodiacQuizSet? set = state.set;
    final ZodiacQuestion? question = state.question;
    if (state.stage != ZodiacShellStage.asking || set == null || question == null) {
      return;
    }

    _answers.add(ZodiacAnswer(questionId: question.id, optionId: optionId));
    if (_answers.length < _round.length) {
      emit(
        ZodiacShellState(
          stage: ZodiacShellStage.asking,
          sets: state.sets,
          set: set,
          question: _round[_answers.length],
        ),
      );
      return;
    }

    final ContentPackage<ZodiacOutcome>? outcomes = _outcomes;
    if (outcomes == null) {
      return;
    }
    final List<String> notebookTags = await _notebookTags();
    if (isClosed) {
      return;
    }
    emit(
      ZodiacShellState(
        stage: ZodiacShellStage.result,
        sets: state.sets,
        set: set,
        result: ZodiacShellResolver.resolve(
          set: set,
          answers: List<ZodiacAnswer>.unmodifiable(_answers),
          outcomes: outcomes,
          notebookTags: notebookTags,
        ),
      ),
    );
  }

  /// Back to the picker. A round left half-answered leaves nothing behind —
  /// no partial answers, and nothing that counts the walking away (AC-3).
  void backToPicker() {
    if (isClosed) {
      return;
    }
    _round = const <ZodiacQuestion>[];
    _answers.clear();
    emit(ZodiacShellState(stage: ZodiacShellStage.picker, sets: state.sets));
  }

  /// "Thêm vào kho của tôi" (AC-7). The title is the only field this screen
  /// supplies; status is the repository's *Mới nghĩ ra* and the card contract
  /// gains no field (BR-7).
  Future<ActivityCard> addToCards(ZodiacSuggestion suggestion) {
    return _cardStore.createCard(
      NewActivityCard(
        title: suggestion.title,
        origin: ActivityCardOrigin.zodiacShell,
      ),
    );
  }

  /// Undo for the add-to-cards snackbar: removes the card this screen just
  /// created, and nothing else.
  Future<void> undoAddToCards(ActivityCard card) async {
    await _cardStore.deleteCard(card.id);
  }

  ActivityCardRepository get _cardStore =>
      _cards ?? getIt<ActivityCardRepository>();

  /// What the user wrote down, folded into the packages' tag vocabulary.
  ///
  /// An empty notebook and an unreachable one are the same answer here: the
  /// notebook needs a resolved backend user id and throws without one
  /// (`context_notebook_repository.dart`), and AC-25/BR-4 make that enrichment
  /// optional rather than a gate. No failure from this call reaches the UI.
  Future<List<String>> _notebookTags() async {
    try {
      final List<NotebookEntry> entries =
          await (_notebook ?? contextNotebookReader()).entries();
      final Set<String> tags = <String>{};
      for (final NotebookEntry entry in entries) {
        tags.addAll(zodiacNotebookTagsIn(entry.value));
        final String? detail = entry.detail;
        if (detail != null) {
          tags.addAll(zodiacNotebookTagsIn(detail));
        }
      }
      return tags.toList(growable: false);
    } on Object {
      return const <String>[];
    }
  }
}
