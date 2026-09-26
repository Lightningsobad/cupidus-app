import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/context_notebook/context_notebook_entry_point.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_content.dart';
import 'package:cupid_mobile/features/zodiac_shell/domain/zodiac_shell_content_gate.dart';
import 'package:cupid_mobile/features/zodiac_shell/presentation/cubit/zodiac_shell_cubit.dart';
import 'package:cupid_mobile/features/zodiac_shell/presentation/screens/zodiac_shell_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The shipped packs, read off disk: these assertions are about the sets and
/// outcomes an author actually shipped, not about fixture copy that could drift
/// away from them.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }

  /// Decoded in-process: above 50 KB the inherited `loadString` hands the
  /// decode to `compute()`, and an isolate never finishes inside the fake async
  /// zone of a widget test, so the screen would sit in its loading state.
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      utf8.decode((await load(key)).buffer.asUint8List());
}

/// Tall enough that the picker, a question and the whole result surface are
/// each mounted in one frame. Every stage is a `ListView`, so in a short frame
/// an absence assertion could pass by never having built what it looks for.
const Size _tallViewport = Size(415, 4000);

/// Rendered evidence for the story-level visual-fidelity package, off unless
/// `--dart-define=CAPTURE_VISUALS=true` so the ordinary suite stays hermetic.
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

const String _visualOutputDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-011_zodiac_quiz_shell/visual-fidelity';

/// The frame of the Stage-1 canvas render this screen is audited against, so
/// the two images are compared at the same size rather than across a crop.
const Size _captureViewport = Size(415, 900);

/// The picker carries every shipped set at once and runs past a phone frame.
/// It is captured unclipped instead, since the audit is about what a card says
/// rather than about where the fold lands.
const Size _pickerCaptureViewport = Size(415, 1100);

/// The only set whose every mapping lands on an outcome about the other
/// person, so a round of it is what puts the guess provenance and the "câu để
/// hỏi" block in the same frame as the three suggestions.
const String _guessSetId = 'set.quiz_phong_doan.v1';

final GlobalKey _captureBoundaryKey = GlobalKey();

Widget _host(Widget child) => MaterialApp(
      theme: buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      ),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(
        platform: CupidPlatform.material,
        child: child,
      ),
    );

Finder _suggestionCards() => find.byWidgetPredicate((Widget widget) {
      final Key? key = widget.key;
      return key is ValueKey<String> &&
          key.value.startsWith('zodiac_suggestion_card_');
    });

Future<void> _loadDesignFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    const Map<String, String> families = <String, String>{
      'Nunito': 'assets/fonts/Nunito-Variable.ttf',
      'Roboto': 'assets/fonts/Roboto-Variable.ttf',
      'Roboto Mono': 'assets/fonts/RobotoMono-Variable.ttf',
      'Material Symbols Rounded':
          'assets/fonts/MaterialSymbolsRounded-Variable.ttf',
    };
    for (final MapEntry<String, String> entry in families.entries) {
      final Uint8List bytes = await File(entry.value).readAsBytes();
      await (FontLoader(entry.key)
            ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer))))
          .load();
    }

    // The back chevron ships with the framework rather than under
    // `assets/fonts/`, so without this the capture shows notdef boxes and
    // proves nothing.
    final String? flutterRoot = Platform.environment['FLUTTER_ROOT'];
    if (flutterRoot != null) {
      final File materialIcons = File(
        '$flutterRoot/bin/cache/artifacts/material_fonts/'
        'MaterialIcons-Regular.otf',
      );
      if (materialIcons.existsSync()) {
        final Uint8List bytes = await materialIcons.readAsBytes();
        await (FontLoader('MaterialIcons')
              ..addFont(Future<ByteData>.value(ByteData.view(bytes.buffer))))
            .load();
      }
    }
  });
}

/// Captured on the Material platform, not iOS: `CupidHeader`'s iOS band is a
/// `BackdropFilter`, and an offscreen `RenderRepaintBoundary.toImage()` has no
/// backdrop to sample, so the title washes out of every iOS capture.
Future<void> _captureScreen(
  WidgetTester tester,
  Widget home,
  String fileName, {
  Size viewport = _captureViewport,
  Future<void> Function(WidgetTester tester)? drive,
}) async {
  tester.view.physicalSize = viewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await _loadDesignFonts(tester);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureBoundaryKey,
      child: MaterialApp(
        locale: const Locale('vi'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        debugShowCheckedModeBanner: false,
        theme: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: Brightness.dark,
        ),
        builder: (BuildContext context, Widget? child) => CupidAppBackground(
          enableEffectsOverride: false,
          child: child!,
        ),
        home: CupidPlatformOverride(
          platform: CupidPlatform.material,
          child: home,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await drive?.call(tester);
  await tester.pumpAndSettle();

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureBoundaryKey))
          as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final File out = File('$_visualOutputDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  late _FakeCardStore cards;
  late ContentPackageLoader diskLoader;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    cards = _FakeCardStore();
    diskLoader = ContentPackageLoader(bundle: _DiskBundle());
  });

  ZodiacShellCubit buildCubit() => ZodiacShellCubit(
        contentLoader: diskLoader,
        cardStore: cards,
        notebookReader: _EmptyNotebook(),
      );

  Future<ZodiacShellCubit> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = _tallViewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late ZodiacShellCubit cubit;
    await tester.pumpWidget(
      _host(
        ZodiacShellScreen(
          createCubit: () {
            cubit = buildCubit();
            return cubit;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cubit;
  }

  /// Plays the round on screen to its result by always taking the first option
  /// offered, which is what a reader who never re-reads a question does.
  Future<void> playThrough(WidgetTester tester, ZodiacShellCubit cubit) async {
    while (cubit.state.stage == ZodiacShellStage.asking) {
      final String optionId = cubit.state.question!.options.first.id;
      await tester.tap(find.byKey(Key('zodiac_option_$optionId')));
      await tester.pumpAndSettle();
    }
  }

  group('màn chọn lát (AC-18/AC-19)', () {
    testWidgets('every shipped set is on the picker, and none of them is shut',
        (WidgetTester tester) async {
      final ZodiacShellCubit cubit = await pumpScreen(tester);

      expect(cubit.state.sets, isNotEmpty);
      for (final ZodiacQuizSet set in cubit.state.sets) {
        expect(
          find.byKey(Key('zodiac_set_card_${set.id}')),
          findsOneWidget,
          reason: 'set "${set.id}" is shipped but not on the picker',
        );
        expect(find.text(set.title), findsOneWidget);
      }
    });

    testWidgets('no card carries a lock, a streak or a count of anything',
        (WidgetTester tester) async {
      await pumpScreen(tester);

      for (final Text text in tester.widgetList<Text>(find.byType(Text))) {
        final String value = (text.data ?? '').toLowerCase();
        expect(value, isNot(contains('mới mở khoá')));
        expect(value, isNot(contains('mở khoá')));
        expect(value, isNot(contains('chuỗi')));
        // "3/10", "0 lượt": a progression readout of any shape.
        expect(value, isNot(matches(RegExp(r'\d+\s*/\s*\d+'))));
      }
      expect(find.byType(Badge), findsNothing);
    });
  });

  group('một câu một lần (AC-3/AC-12/AC-18)', () {
    testWidgets('a set opens on a single question with no position readout',
        (WidgetTester tester) async {
      final ZodiacShellCubit cubit = await pumpScreen(tester);
      final ZodiacQuizSet set = cubit.state.sets.first;

      await tester.tap(find.byKey(Key('zodiac_set_card_${set.id}')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('zodiac_question_prompt')), findsOneWidget);
      expect(find.text(cubit.state.question!.prompt), findsOneWidget);
      expect(find.byKey(const Key('zodiac_picker_list')), findsNothing);
      expect(find.byType(LinearProgressIndicator), findsNothing);
    });

    testWidgets('a question asked on the other person\'s behalf is framed as '
        'the reader\'s guess', (WidgetTester tester) async {
      final ZodiacShellCubit cubit = await pumpScreen(tester);

      await tester.tap(find.byKey(const Key('zodiac_set_card_$_guessSetId')));
      await tester.pumpAndSettle();

      // The rotation decides which of the two questions comes first, so the
      // label is asserted against the subject of the question on screen.
      while (cubit.state.stage == ZodiacShellStage.asking) {
        final bool aboutOther = cubit.state.question!.subject ==
            ZodiacQuestionSubject.guessAboutOther;
        expect(
          find.byKey(const Key('zodiac_question_guess_label')),
          aboutOther ? findsOneWidget : findsNothing,
          reason: 'question "${cubit.state.question!.id}" mislabels its subject',
        );
        await tester.tap(
          find.byKey(Key('zodiac_option_${cubit.state.question!.options.first.id}')),
        );
        await tester.pumpAndSettle();
      }
    });

    testWidgets('walking out mid-round leaves nothing behind and counts nothing',
        (WidgetTester tester) async {
      final ZodiacShellCubit cubit = await pumpScreen(tester);
      final ZodiacQuizSet set = cubit.state.sets.firstWhere(
        (ZodiacQuizSet candidate) => candidate.questionsPerRound > 1,
      );

      await tester.tap(find.byKey(Key('zodiac_set_card_${set.id}')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('zodiac_leave_round')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('zodiac_picker_list')), findsOneWidget);
      expect(cubit.state.set, isNull);
      expect(cubit.state.question, isNull);
      expect(cubit.state.result, isNull);

      // Re-entering starts clean: a fresh question, not the one half-answered.
      await tester.tap(find.byKey(Key('zodiac_set_card_${set.id}')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('zodiac_question_prompt')), findsOneWidget);
    });
  });

  group('kết quả là một bề mặt (AC-4/AC-5/AC-6)', () {
    testWidgets('the last answer lands straight on verdict plus three cards',
        (WidgetTester tester) async {
      final ZodiacShellCubit cubit = await pumpScreen(tester);

      await tester.tap(
        find.byKey(Key('zodiac_set_card_${cubit.state.sets.first.id}')),
      );
      await tester.pumpAndSettle();
      await playThrough(tester, cubit);

      expect(find.byKey(const Key('zodiac_result_surface')), findsOneWidget);
      expect(find.byKey(const Key('zodiac_result_insight')), findsOneWidget);
      expect(_suggestionCards(), findsNWidgets(minimumSuggestionsPerOutcome));
      // No second tap stands between the verdict and the suggestions.
      expect(find.byType(ExpansionTile), findsNothing);
    });

    testWidgets('every shipped set reaches that same surface',
        (WidgetTester tester) async {
      final ZodiacShellCubit cubit = await pumpScreen(tester);

      for (final ZodiacQuizSet set in cubit.state.sets) {
        await tester.tap(find.byKey(Key('zodiac_set_card_${set.id}')));
        await tester.pumpAndSettle();
        await playThrough(tester, cubit);

        expect(
          _suggestionCards(),
          findsNWidgets(minimumSuggestionsPerOutcome),
          reason: 'set "${set.id}" resolved without its three suggestions',
        );

        await tester.tap(find.byKey(const Key('zodiac_back_to_picker')));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('leaving with none of the three picked costs nothing (AC-10)',
        (WidgetTester tester) async {
      final ZodiacShellCubit cubit = await pumpScreen(tester);

      await tester.tap(
        find.byKey(Key('zodiac_set_card_${cubit.state.sets.first.id}')),
      );
      await tester.pumpAndSettle();
      await playThrough(tester, cubit);
      await tester.tap(find.byKey(const Key('zodiac_back_to_picker')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('zodiac_picker_list')), findsOneWidget);
      expect(cards.cards, isEmpty);
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('thêm vào kho của tôi (AC-2/AC-7)', () {
    Future<ZodiacShellCubit> reachResult(WidgetTester tester) async {
      final ZodiacShellCubit cubit = await pumpScreen(tester);
      await tester.tap(
        find.byKey(Key('zodiac_set_card_${cubit.state.sets.first.id}')),
      );
      await tester.pumpAndSettle();
      await playThrough(tester, cubit);
      return cubit;
    }

    testWidgets('one tap creates one card, with no dialog in the way',
        (WidgetTester tester) async {
      final ZodiacShellCubit cubit = await reachResult(tester);
      final ZodiacSuggestion suggestion = cubit.state.result!.suggestions.first;

      await tester.tap(
        find.byKey(Key('zodiac_suggestion_add_${suggestion.id}')),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(cards.cards, hasLength(1));
      expect(cards.cards.single.title, suggestion.title);
      expect(cards.cards.single.origin, ActivityCardOrigin.zodiacShell);
      expect(cards.cards.single.status, ActivityCardStatus.idea);
      // The reader stays on the result, so a second card is still one tap away.
      expect(find.byKey(const Key('zodiac_result_surface')), findsOneWidget);
    });

    testWidgets('the card is announced with five seconds of undo',
        (WidgetTester tester) async {
      final ZodiacShellCubit cubit = await reachResult(tester);
      final ZodiacSuggestion suggestion = cubit.state.result!.suggestions.first;

      await tester.tap(
        find.byKey(Key('zodiac_suggestion_add_${suggestion.id}')),
      );
      await tester.pumpAndSettle();

      final SnackBar bar = tester.widget<SnackBar>(
        find.byKey(const Key('zodiac_card_created_snackbar')),
      );
      expect(bar.duration, const Duration(seconds: 5));
      expect(bar.action, isNotNull);
    });

    testWidgets('undo takes back the card it just made, and only that one',
        (WidgetTester tester) async {
      final ZodiacShellCubit cubit = await reachResult(tester);
      final List<ZodiacSuggestion> suggestions =
          cubit.state.result!.suggestions;

      await tester.tap(
        find.byKey(Key('zodiac_suggestion_add_${suggestions[0].id}')),
      );
      await tester.pumpAndSettle();
      final String firstId = cards.cards.single.id;

      await tester.tap(find.byType(SnackBarAction));
      await tester.pumpAndSettle();

      expect(cards.deleted, <String>[firstId]);
      expect(cards.cards, isEmpty);

      // Undoing one add does not sour the surface: the next card still lands.
      await tester.tap(
        find.byKey(Key('zodiac_suggestion_add_${suggestions[1].id}')),
      );
      await tester.pumpAndSettle();

      expect(cards.cards.single.title, suggestions[1].title);
      expect(cards.deleted, <String>[firstId]);
    });

    testWidgets('all three can go to the store from the one surface',
        (WidgetTester tester) async {
      final ZodiacShellCubit cubit = await reachResult(tester);

      for (final ZodiacSuggestion suggestion
          in cubit.state.result!.suggestions) {
        await tester.tap(
          find.byKey(Key('zodiac_suggestion_add_${suggestion.id}')),
        );
        await tester.pumpAndSettle();
      }

      expect(
        <String>[for (final ActivityCard card in cards.cards) card.title],
        <String>[
          for (final ZodiacSuggestion s in cubit.state.result!.suggestions)
            s.title,
        ],
      );
    });
  });

  group('bằng chứng visual-fidelity', () {
    testWidgets('captures 7-vo-hoang-dao-3-viec', (WidgetTester tester) async {
      const String captureName = 'implemented-7-vo-hoang-dao-3-viec-md.png';
      late ZodiacShellCubit cubit;

      // The guess set, so the frame carries the states the spec makes rules
      // about: guess provenance, the question to ask, and the three cards.
      await _captureScreen(
        tester,
        ZodiacShellScreen(
          createCubit: () {
            cubit = buildCubit();
            return cubit;
          },
        ),
        captureName,
        drive: (WidgetTester tester) async {
          // The guess set is the last card on the picker, so in a phone-sized
          // capture frame it starts below the fold.
          final Finder card =
              find.byKey(const Key('zodiac_set_card_$_guessSetId'));
          await tester.ensureVisible(card);
          await tester.pumpAndSettle();
          await tester.tap(card);
          await tester.pumpAndSettle();
          await playThrough(tester, cubit);
        },
      );

      expect(cubit.state.result!.outcome.aboutOther, isTrue);
      expect(File('$_visualOutputDir/$captureName').existsSync(), isTrue);
    }, skip: !kCaptureVisuals);

    testWidgets('captures the picker', (WidgetTester tester) async {
      const String captureName =
          'implemented-7-vo-hoang-dao-3-viec-md-chon-lat.png';

      await _captureScreen(
        tester,
        ZodiacShellScreen(createCubit: buildCubit),
        captureName,
        viewport: _pickerCaptureViewport,
      );

      expect(File('$_visualOutputDir/$captureName').existsSync(), isTrue);
    }, skip: !kCaptureVisuals);
  });
}

class _EmptyNotebook implements ContextNotebookReader {
  @override
  Future<List<NotebookEntry>> entries({NotebookKind? kind}) async =>
      const <NotebookEntry>[];

  @override
  Future<List<SkillEntry>> skills() async => const <SkillEntry>[];
}

/// In-memory stand-in for the card hub. Only the two methods the shell calls
/// are implemented; the rest exist to satisfy the interface.
class _FakeCardStore implements ActivityCardRepository {
  final List<ActivityCard> cards = <ActivityCard>[];
  final List<String> deleted = <String>[];
  int _next = 0;

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) async {
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
