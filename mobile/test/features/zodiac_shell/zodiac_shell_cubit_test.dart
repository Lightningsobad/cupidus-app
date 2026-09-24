import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/context_notebook/context_notebook_entry_point.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_content.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_content_gate.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_resolver.dart';
import 'package:cupid_mobile/features/zodiac_shell/presentation/cubit/zodiac_shell_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  ZodiacShellCubit build({
    _FakeCardStore? cards,
    ContextNotebookReader? notebook,
  }) =>
      ZodiacShellCubit(
        cardStore: cards ?? _FakeCardStore(),
        notebookReader: notebook ?? _EmptyNotebook(),
      );

  /// Plays [setId] to the end by always taking the first option.
  Future<void> playThrough(ZodiacShellCubit cubit, String setId) async {
    await cubit.startSet(setId);
    while (cubit.state.stage == ZodiacShellStage.asking) {
      await cubit.answer(cubit.state.question!.options.first.id);
    }
  }

  group('loading the shipped packs', () {
    test('every set is on the picker and none of them is locked (AC-19)',
        () async {
      final ZodiacShellCubit cubit = build();

      await cubit.load();

      expect(cubit.state.stage, ZodiacShellStage.picker);
      expect(cubit.state.sets, isNotEmpty);
      expect(cubit.state.set, isNull);
      expect(cubit.state.result, isNull);
    });

    test('a second load does not re-read the assets', () async {
      final _CountingLoader loader = _CountingLoader();
      final ZodiacShellCubit cubit = ZodiacShellCubit(
        contentLoader: loader,
        cardStore: _FakeCardStore(),
        notebookReader: _EmptyNotebook(),
      );

      await cubit.load();
      await cubit.load();

      expect(loader.loads, 2, reason: 'two packages, read once each');
    });
  });

  group('playing a round', () {
    test('questions arrive one at a time and the state cannot say how many '
        'are left (AC-18/AC-31)', () async {
      final ZodiacShellCubit cubit = build();
      await cubit.load();
      final ZodiacQuizSet set = cubit.state.sets.first;

      await cubit.startSet(set.id);

      expect(cubit.state.stage, ZodiacShellStage.asking);
      expect(cubit.state.question, isNotNull);
      expect(set.questions, contains(cubit.state.question));
    });

    test('the last answer lands on a result with exactly three suggestions '
        '(BR-2)', () async {
      final ZodiacShellCubit cubit = build();
      await cubit.load();

      await playThrough(cubit, cubit.state.sets.first.id);

      expect(cubit.state.stage, ZodiacShellStage.result);
      expect(cubit.state.result, isNotNull);
      expect(
        cubit.state.result!.suggestions,
        hasLength(minimumSuggestionsPerOutcome),
      );
    });

    test('every shipped set plays to a result', () async {
      final ZodiacShellCubit cubit = build();
      await cubit.load();

      for (final ZodiacQuizSet set in cubit.state.sets) {
        await playThrough(cubit, set.id);
        expect(cubit.state.stage, ZodiacShellStage.result,
            reason: 'set "${set.id}" did not resolve');
        expect(cubit.state.result!.suggestions,
            hasLength(minimumSuggestionsPerOutcome));
        cubit.backToPicker();
      }
    });

    test('the same answers land on the same outcome on a later round (AC-21)',
        () async {
      final ZodiacShellCubit cubit = build();
      await cubit.load();
      final String setId = cubit.state.sets.first.id;

      await playThrough(cubit, setId);
      final ZodiacShellResult first = cubit.state.result!;
      cubit.backToPicker();
      await playThrough(cubit, setId);
      final ZodiacShellResult second = cubit.state.result!;

      expect(second.outcome.id, first.outcome.id);
      expect(
        <String>[for (final ZodiacSuggestion s in second.suggestions) s.id],
        <String>[for (final ZodiacSuggestion s in first.suggestions) s.id],
      );
    });

    test('walking away mid-round leaves nothing behind (AC-3)', () async {
      final ZodiacShellCubit cubit = build();
      await cubit.load();
      await cubit.startSet(cubit.state.sets.first.id);

      cubit.backToPicker();

      expect(cubit.state.stage, ZodiacShellStage.picker);
      expect(cubit.state.question, isNull);
      expect(cubit.state.result, isNull);
      expect(cubit.state.set, isNull);
    });

    test('answering outside a round is ignored rather than throwing', () async {
      final ZodiacShellCubit cubit = build();
      await cubit.load();

      await cubit.answer('o.whatever');

      expect(cubit.state.stage, ZodiacShellStage.picker);
    });

    test('a set id no pack declares is ignored', () async {
      final ZodiacShellCubit cubit = build();
      await cubit.load();

      await cubit.startSet('set.that.never.shipped');

      expect(cubit.state.stage, ZodiacShellStage.picker);
    });
  });

  group('the notebook only ever enriches', () {
    test('an empty notebook still yields three suggestions (AC-25)', () async {
      final ZodiacShellCubit cubit = build(notebook: _EmptyNotebook());
      await cubit.load();

      await playThrough(cubit, cubit.state.sets.first.id);

      expect(cubit.state.result!.suggestions,
          hasLength(minimumSuggestionsPerOutcome));
    });

    test('a notebook that throws yields three suggestions and no error state '
        '(AC-25/BR-4)', () async {
      // The notebook door throws without a resolved backend user id, which is
      // an ordinary signed-out state, not a failure of the round.
      final ZodiacShellCubit cubit = build(notebook: _ThrowingNotebook());
      await cubit.load();

      await playThrough(cubit, cubit.state.sets.first.id);

      expect(cubit.state.stage, ZodiacShellStage.result);
      expect(cubit.state.result!.suggestions,
          hasLength(minimumSuggestionsPerOutcome));
    });

    test('what the user wrote reaches the picking, diacritics and all (AC-24)',
        () async {
      final ZodiacShellCubit plain = build(notebook: _EmptyNotebook());
      await plain.load();

      // A set whose round surfaces a suggestion the user's notebook can pull
      // forward: it carries tags, it is not already first, and the pack's own
      // first choice does not share those tags. Without such a case the
      // assertion below would pass on an implementation that ignores the
      // notebook entirely.
      String? setId;
      ZodiacSuggestion? target;
      List<String> withoutNotebook = const <String>[];
      for (final ZodiacQuizSet set in plain.state.sets) {
        await playThrough(plain, set.id);
        final ZodiacOutcome outcome = plain.state.result!.outcome;
        final List<String> chosen = <String>[
          for (final ZodiacSuggestion s in plain.state.result!.suggestions)
            s.id,
        ];
        plain.backToPicker();

        final ZodiacSuggestion first = outcome.suggestions.first;
        for (final ZodiacSuggestion suggestion
            in outcome.suggestions.skip(1).toList().reversed) {
          if (suggestion.notebookTags.isNotEmpty &&
              !suggestion.notebookTags.any(first.notebookTags.contains)) {
            setId = set.id;
            target = suggestion;
            withoutNotebook = chosen;
            break;
          }
        }
        if (target != null) {
          break;
        }
      }

      expect(target, isNotNull,
          reason: 'no shipped outcome offers a tagged suggestion behind an '
              'untagged one, so this assertion cannot tell enrichment from '
              'dead code');
      expect(withoutNotebook.first, isNot(target!.id));

      final ZodiacShellCubit enriched = build(
        notebook: _NotebookSaying(
          _vietnameseFor(target.notebookTags.toSet()),
        ),
      );
      await enriched.load();
      await playThrough(enriched, setId!);
      final List<String> withNotebook = <String>[
        for (final ZodiacSuggestion s in enriched.state.result!.suggestions)
          s.id,
      ];

      expect(withNotebook, hasLength(minimumSuggestionsPerOutcome));
      expect(withNotebook.first, target.id,
          reason: 'free-text Vietnamese in the notebook has to fold onto the '
              'pack tag and pull its suggestion to the front');
    });
  });

  group('thêm vào kho của tôi (AC-7)', () {
    test('the card carries the zodiac origin, the idea status and the '
        'suggestion title', () async {
      final _FakeCardStore cards = _FakeCardStore();
      final ZodiacShellCubit cubit = build(cards: cards);
      await cubit.load();
      await playThrough(cubit, cubit.state.sets.first.id);
      final ZodiacSuggestion suggestion = cubit.state.result!.suggestions.first;

      final ActivityCard card = await cubit.addToCards(suggestion);

      expect(card.title, suggestion.title);
      expect(card.origin, ActivityCardOrigin.zodiacShell);
      expect(card.status, ActivityCardStatus.idea);
      expect(cards.drafts, hasLength(1));
      expect(cards.drafts.single.scheduledOn, isNull,
          reason: 'the shell never schedules anything for the user');
    });

    test('undo removes exactly the card that was just added', () async {
      final _FakeCardStore cards = _FakeCardStore();
      final ZodiacShellCubit cubit = build(cards: cards);
      await cubit.load();
      await playThrough(cubit, cubit.state.sets.first.id);

      final ActivityCard first =
          await cubit.addToCards(cubit.state.result!.suggestions[0]);
      final ActivityCard second =
          await cubit.addToCards(cubit.state.result!.suggestions[1]);
      await cubit.undoAddToCards(first);

      expect(cards.deleted, <String>[first.id]);
      expect(cards.cards.map((ActivityCard c) => c.id), <String>[second.id]);
    });
  });
}

/// Vietnamese text that should fold back onto [tags], so the test exercises the
/// real folding rather than handing the resolver pre-slugged strings.
String _vietnameseFor(Set<String> tags) => tags
    .map((String tag) => tag.split('_').join(' '))
    .join(', ');

class _EmptyNotebook implements ContextNotebookReader {
  @override
  Future<List<NotebookEntry>> entries({NotebookKind? kind}) async =>
      const <NotebookEntry>[];

  @override
  Future<List<SkillEntry>> skills() async => const <SkillEntry>[];
}

class _ThrowingNotebook implements ContextNotebookReader {
  @override
  Future<List<NotebookEntry>> entries({NotebookKind? kind}) async =>
      throw StateError('No backend user id resolved');

  @override
  Future<List<SkillEntry>> skills() async =>
      throw StateError('No backend user id resolved');
}

class _NotebookSaying implements ContextNotebookReader {
  _NotebookSaying(this.value);

  final String value;

  @override
  Future<List<NotebookEntry>> entries({NotebookKind? kind}) async =>
      <NotebookEntry>[
        NotebookEntry(
          id: 'entry.1',
          ownerKey: 'owner',
          kind: NotebookKind.interest,
          value: value,
          source: ContextEntrySource.manual,
          createdAt: DateTime.utc(2026),
          updatedAt: DateTime.utc(2026),
        ),
      ];

  @override
  Future<List<SkillEntry>> skills() async => const <SkillEntry>[];
}

/// Counts how many packages were read, so pack caching is observable.
class _CountingLoader extends ContentPackageLoader {
  _CountingLoader();

  int loads = 0;

  @override
  Future<ContentPackage<T>> load<T extends ContentItem>(
    String assetKey, {
    required String expectedSchemaId,
    required ContentItemParser<T> itemParser,
  }) {
    loads += 1;
    return super.load<T>(
      assetKey,
      expectedSchemaId: expectedSchemaId,
      itemParser: itemParser,
    );
  }
}

/// In-memory stand-in for the card hub. Only the two methods the shell calls
/// are implemented; the rest exist to satisfy the interface.
class _FakeCardStore implements ActivityCardRepository {
  final List<NewActivityCard> drafts = <NewActivityCard>[];
  final List<ActivityCard> cards = <ActivityCard>[];
  final List<String> deleted = <String>[];
  int _next = 0;

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) async {
    drafts.add(draft);
    final ActivityCard card = ActivityCard(
      id: 'card.${_next++}',
      ownerKey: 'owner',
      title: draft.title,
      // The real repository forces *Mới nghĩ ra* regardless of the caller.
      status: ActivityCardStatus.idea,
      origin: draft.origin,
      invited: false,
      replyState: ActivityCardReplyState.notAnswered,
      createdAt: DateTime.utc(2026),
      updatedAt: DateTime.utc(2026),
    );
    cards.add(card);
    return card;
  }

  @override
  Future<int> deleteCard(String id) async {
    deleted.add(id);
    final int before = cards.length;
    cards.removeWhere((ActivityCard card) => card.id == id);
    return before - cards.length;
  }

  @override
  Future<ActivityCard?> cardById(String id) async {
    for (final ActivityCard card in cards) {
      if (card.id == id) {
        return card;
      }
    }
    return null;
  }

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async =>
      cards
          .where((ActivityCard card) => card.status == status)
          .skip(offset)
          .take(limit)
          .toList();

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) =>
      const Stream<List<ActivityCard>>.empty();

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() async =>
      <ActivityCardStatus, int>{};

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async => 0;

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async => 0;

  @override
  Future<int> clearScheduledDate(String cardId) async => 0;
}
