import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/activity_card_dao.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/data/activity_card_repository_impl.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_hub_view.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/minute_one_empty_state.dart';
import 'package:cupid_mobile/features/compatibility_lookup/compatibility_lookup_entry_point.dart';
import 'package:cupid_mobile/features/compatibility_lookup/data/relationship_label_repository.dart';
import 'package:cupid_mobile/features/compatibility_lookup/presentation/cubit/compatibility_lookup_cubit.dart';
import 'package:cupid_mobile/features/context_notebook/context_notebook_entry_point.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/ask_cadence_policy.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:cupid_mobile/features/gift_ideas/data/gift_repository.dart';
import 'package:cupid_mobile/features/gift_ideas/domain/gift_content.dart';
import 'package:cupid_mobile/features/gift_ideas/domain/gift_selector.dart';
import 'package:cupid_mobile/features/gift_ideas/gift_ideas_entry_point.dart';
import 'package:cupid_mobile/features/gift_ideas/presentation/cubit/gift_ideas_cubit.dart';
import 'package:cupid_mobile/features/gift_ideas/presentation/widgets/gift_idea_card.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rendered-evidence capture for screen (5), off unless
/// `--dart-define=CAPTURE_VISUALS=true` so the ordinary suite stays hermetic.
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

/// Matches the `--platform=ios` render of the design canvas that produced
/// `design-reference-5-goi-y-qua-thang-cong-suc-ios.png`, so the pair compares
/// without rescaling either image.
const Size kIosReferenceViewport = Size(415, 900);

const String _outputDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-004_relationship_notebook_and_gift_ideas/visual-fidelity';

/// A frame tall enough that every suggestion is mounted at once. The list
/// virtualizes, so in a shorter frame `find.byType(GiftIdeaCard)` counts only
/// what is on screen and an absence assertion would pass by never having built
/// the offending card.
const Size _tallTestViewport = Size(415, 6000);

/// One frame that holds the whole screen at reference width. The canvas is a
/// single unscrolled page, but the implemented screen is taller than 900px, so
/// the components below the fold — the compact cards and the bottom guess row —
/// are only evidenced by a capture that does not clip them.
const Size _fullPageViewport = Size(415, 1600);

final GlobalKey _captureBoundaryKey = GlobalKey();

/// Widget tests ship no asset bundle, so the shipped packs and the bundled
/// fonts are read straight off disk. Reading the real packs is the point: the
/// chip rows are asserted against what an author shipped, not against fixture
/// copy.
class _DiskBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) async {
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }
}

class _RepositoryReader implements ContextNotebookReader {
  const _RepositoryReader(this._repository);

  final ContextNotebookRepository _repository;

  @override
  Future<List<NotebookEntry>> entries({NotebookKind? kind}) =>
      _repository.entries(kind: kind);

  @override
  Future<List<SkillEntry>> skills() => _repository.skills();
}

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

/// Every `Text` currently on screen, as plain strings.
List<String> _renderedText(WidgetTester tester) => <String>[
      for (final Text text in tester.widgetList<Text>(find.byType(Text)))
        text.data ?? text.textSpan?.toPlainText() ?? '',
    ];

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

    // The `add` glyph on the primary pill and the back chevron ship with the
    // framework rather than under `assets/fonts/`, so without this the capture
    // shows notdef boxes and proves nothing.
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

/// `CupidHeader`'s iOS band is a `BackdropFilter`, and an offscreen
/// `RenderRepaintBoundary.toImage()` has no backdrop to sample, so the title
/// washes out of every iOS capture. The Material re-render is how the title
/// band is evidenced — same finding as the P4 harness.
Future<void> _captureAtReferenceViewport(
  WidgetTester tester,
  Widget home,
  String fileName, {
  CupidPlatform platform = CupidPlatform.ios,
  Size viewport = kIosReferenceViewport,
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
          platform: platform,
          brightness: Brightness.dark,
        ),
        builder: (BuildContext context, Widget? child) => CupidAppBackground(
          enableEffectsOverride: false,
          child: child!,
        ),
        home: CupidPlatformOverride(platform: platform, child: home),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureBoundaryKey))
          as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final File out = File('$_outputDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  late CupidDatabase database;
  late ContextNotebookRepository notebook;
  late GiftRepository gifts;
  late ActivityCardRepository cards;
  late ContentPackageLoader diskLoader;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    final BackendUserIdStore owner = BackendUserIdStore()
      ..updateUserId('user-1');
    notebook = ContextNotebookRepository(
      dao: ContextNotebookDao(database),
      ownerKeyStore: owner,
    );
    diskLoader = ContentPackageLoader(bundle: _DiskBundle());
    gifts = GiftRepository(
      notebook: _RepositoryReader(notebook),
      loader: diskLoader,
    );
    cards = ActivityCardRepositoryImpl(
      dao: ActivityCardDao(database),
      ownerKeyStore: owner,
    );
    // The guess row's door resolves its own storage from the composition root
    // (STORY-009 P5), so screen (5) cannot be pumped without these two.
    getIt
      ..registerSingleton<CupidDatabase>(database)
      ..registerSingleton<BackendUserIdStore>(owner);
  });

  tearDown(() async {
    await getIt.reset();
    await database.close();
  });

  Widget giftScreen() => GiftIdeasScreen(
        giftRepository: gifts,
        cardRepository: cards,
        // The screen hands its own entry point and targets to the builder, so
        // injecting the notebook seams here does not take the production ask
        // identity out of the assertions below.
        askSlotBuilder: ({
          required String entryPointId,
          required List<String> neededFieldIds,
          required VoidCallback onContextChanged,
        }) =>
            AskOnTheSpotSlot(
          entryPointId: entryPointId,
          neededFieldIds: neededFieldIds,
          onContextChanged: onContextChanged,
          repository: notebook,
          contentLoader: diskLoader,
          sessionSkips: AskSessionSkips(),
        ),
      );

  /// What the screen is expected to show. Fewer than the pack ships: the
  /// selector drops ideas whose context the notebook cannot support, so the
  /// pack length is not the baseline for anything rendered.
  Future<List<GiftSuggestion>> rankedSuggestions({
    GiftFilter filter = GiftFilter.none,
  }) async =>
      const GiftSelector().suggest(
        catalogue: await gifts.catalogue(),
        context: await gifts.context(),
        filter: filter,
      );

  Future<void> pumpGiftScreen(WidgetTester tester) async {
    tester.view.physicalSize = _tallTestViewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(_host(giftScreen()));
    await tester.pumpAndSettle();
  }

  group('mức công sức đổi ra phút (AC-34, R-15a)', () {
    test('a tier maps to the minutes the pack declares, not to a Dart factor',
        () async {
      final GiftCatalogue catalogue = await gifts.catalogue();
      final List<GiftSuggestion> ranked = const GiftSelector().suggest(
        catalogue: catalogue,
        context: await gifts.context(),
      );

      expect(ranked, isNotEmpty);
      for (final GiftSuggestion suggestion in ranked) {
        final GiftTaxonomyItem tier =
            catalogue.taxonomyItemById(suggestion.idea.effortTierId)!;
        expect(giftDurationMinutes(suggestion), tier.maxMinutes);
        expect(giftDurationMinutes(suggestion), isNotNull);
      }

      // Every shipped tier is exercised by the assertion above, so a pack that
      // adds a fourth tier is covered without an edit here.
      expect(
        ranked
            .map((GiftSuggestion s) => s.idea.effortTierId)
            .toSet()
            .length,
        catalogue.effortTiers.length,
      );
    });

    test('a suggestion whose tier the taxonomy does not declare maps to null',
        () async {
      final GiftCatalogue catalogue = await gifts.catalogue();
      final GiftIdea idea = catalogue.gifts.items.first;

      expect(
        giftDurationMinutes(
          GiftSuggestion(
            idea: idea,
            branch: catalogue.taxonomyItemById(idea.branchId),
            effortTier: null,
            matches: const <GiftContextMatch>[],
          ),
        ),
        isNull,
      );
    });
  });

  group('cubit đổi bộ lọc (AC-17, AC-18, AC-32)', () {
    test('the chip rows are exactly as long as the pack', () async {
      final GiftIdeasCubit cubit = GiftIdeasCubit(gifts: gifts, cards: cards);
      addTearDown(cubit.close);
      await cubit.load();

      final GiftCatalogue catalogue = await gifts.catalogue();
      expect(cubit.state.branches, catalogue.branches);
      expect(cubit.state.effortTiers, catalogue.effortTiers);
      expect(cubit.state.loading, isFalse);
    });

    test('picking a branch narrows the list, picking it again clears it',
        () async {
      final GiftIdeasCubit cubit = GiftIdeasCubit(gifts: gifts, cards: cards);
      addTearDown(cubit.close);
      await cubit.load();

      final int unfiltered = cubit.state.suggestions.length;
      final GiftTaxonomyItem branch = cubit.state.branches.first;

      await cubit.selectBranch(branch.id);
      expect(cubit.state.filter.branchId, branch.id);
      expect(cubit.state.suggestions, isNotEmpty);
      expect(
        cubit.state.suggestions
            .every((GiftSuggestion s) => s.idea.branchId == branch.id),
        isTrue,
      );
      expect(cubit.state.suggestions.length, lessThan(unfiltered));

      await cubit.selectBranch(branch.id);
      expect(cubit.state.filter.branchId, isNull);
      expect(cubit.state.suggestions.length, unfiltered);
    });

    test('the effort chip is a ceiling and composes with the branch chip',
        () async {
      final GiftIdeasCubit cubit = GiftIdeasCubit(gifts: gifts, cards: cards);
      addTearDown(cubit.close);
      await cubit.load();

      final GiftTaxonomyItem tightest = cubit.state.effortTiers.reduce(
        (GiftTaxonomyItem a, GiftTaxonomyItem b) =>
            a.maxMinutes! <= b.maxMinutes! ? a : b,
      );

      await cubit.selectEffortTier(tightest.id);
      expect(cubit.state.filter.effortTierId, tightest.id);
      expect(
        cubit.state.suggestions.every(
          (GiftSuggestion s) => s.effortMinutes! <= tightest.maxMinutes!,
        ),
        isTrue,
      );

      final GiftTaxonomyItem branch = cubit.state.branches.first;
      await cubit.selectBranch(branch.id);
      expect(cubit.state.filter.effortTierId, tightest.id);
      expect(cubit.state.filter.branchId, branch.id);
    });

    test('answering the ask card re-ranks in place without losing the filter',
        () async {
      final GiftIdeasCubit cubit = GiftIdeasCubit(gifts: gifts, cards: cards);
      addTearDown(cubit.close);
      await cubit.load();
      final GiftTaxonomyItem branch = cubit.state.branches.first;
      await cubit.selectBranch(branch.id);
      final List<String> before = cubit.state.suggestions
          .map((GiftSuggestion s) => s.idea.id)
          .toList(growable: false);

      await notebook.addEntry(
        kind: NotebookKind.event,
        value: 'sinh nhật',
        source: ContextEntrySource.askOnTheSpot,
        questionId: 'ask.event.upcoming.v1',
      );
      await cubit.refreshContext();

      expect(cubit.state.filter.branchId, branch.id);
      expect(
        cubit.state.suggestions.map((GiftSuggestion s) => s.idea.id).toSet(),
        before.toSet(),
      );
    });

    test('dismissals carried into a narrower branch cannot empty it (AC-18)',
        () async {
      final GiftIdeasCubit cubit = GiftIdeasCubit(gifts: gifts, cards: cards);
      addTearDown(cubit.close);
      await cubit.load();

      // The narrowest branch is the one a carried-over dismissal starves
      // first. Which branch that is belongs to the pack, so it is searched
      // for rather than named (R-15b).
      final List<GiftSuggestion> unfiltered = cubit.state.suggestions;
      List<GiftSuggestion>? narrowest;
      GiftTaxonomyItem? narrowestBranch;
      for (final GiftTaxonomyItem branch in cubit.state.branches) {
        final List<GiftSuggestion> inBranch = <GiftSuggestion>[
          for (final GiftSuggestion s in unfiltered)
            if (s.idea.branchId == branch.id) s,
        ];
        if (inBranch.isNotEmpty &&
            (narrowest == null || inBranch.length < narrowest.length)) {
          narrowest = inBranch;
          narrowestBranch = branch;
        }
      }
      expect(narrowest, isNotNull);
      // Dismissing only this branch leaves the wider set with ideas in it, so
      // no wrap happens and the dismissals really do carry over.
      expect(narrowest!.length, lessThan(unfiltered.length));

      for (final GiftSuggestion suggestion in narrowest) {
        cubit.dismiss(suggestion);
      }
      expect(cubit.state.visibleSuggestions, isNotEmpty);

      await cubit.selectBranch(narrowestBranch!.id);

      expect(cubit.state.suggestions, isNotEmpty);
      expect(cubit.state.visibleSuggestions, isNotEmpty);
      expect(
        cubit.state.visibleSuggestions
            .map((GiftSuggestion s) => s.idea.id)
            .toSet(),
        cubit.state.suggestions.map((GiftSuggestion s) => s.idea.id).toSet(),
      );
    });
  });

  group('màn (5) dựng từ gói đã ship', () {
    testWidgets('one chip per branch and one per tier, and no extra cell',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);
      final GiftCatalogue catalogue = await gifts.catalogue();

      for (final GiftTaxonomyItem branch in catalogue.branches) {
        expect(find.byKey(Key('gift_branch_chip_${branch.id}')), findsOneWidget);
      }
      for (final GiftTaxonomyItem tier in catalogue.effortTiers) {
        expect(find.byKey(Key('gift_effort_chip_${tier.id}')), findsOneWidget);
      }

      // The rows hold nothing else: an added "tất cả" cell would make either
      // row longer than the pack it is built from (AC-34, R-15b).
      expect(
        find.descendant(
          of: find.byKey(const Key('gift-ideas-branch-filter')),
          matching: find.byType(GestureDetector),
        ),
        findsNWidgets(catalogue.branches.length),
      );
      expect(
        find.descendant(
          of: find.byKey(const Key('gift-ideas-effort-filter')),
          matching: find.byType(GestureDetector),
        ),
        findsNWidgets(catalogue.effortTiers.length),
      );
    });

    testWidgets('every ranked idea renders as a card',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);
      final List<GiftSuggestion> ranked = await rankedSuggestions();

      expect(ranked, isNotEmpty);
      expect(find.byType(GiftIdeaCard), findsNWidgets(ranked.length));
      for (final GiftSuggestion suggestion in ranked) {
        expect(
          find.byKey(Key('gift_idea_card_${suggestion.idea.id}')),
          findsOneWidget,
        );
      }
      expect(find.byKey(const Key('gift-ideas-no-match')), findsNothing);
    });

    testWidgets('tapping a branch chip filters the list in place',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);
      final GiftCatalogue catalogue = await gifts.catalogue();
      final GiftTaxonomyItem branch = catalogue.branches.first;
      final List<GiftSuggestion> inBranch = await rankedSuggestions(
        filter: GiftFilter(branchId: branch.id),
      );

      await tester.tap(find.byKey(Key('gift_branch_chip_${branch.id}')));
      await tester.pumpAndSettle();

      expect(inBranch, isNotEmpty);
      expect(find.byType(GiftIdeaCard), findsNWidgets(inBranch.length));
      // Still the same screen: filtering never pushes a route.
      expect(find.byType(GiftIdeasScreen), findsOneWidget);
    });

    testWidgets('a branch with nothing left gets a settled empty state (AC-34)',
        (WidgetTester tester) async {
      // Which pair empties out is a property of the shipped pack, so it is
      // searched for rather than named: a pack that reshuffles its tiers keeps
      // this test meaningful instead of silently passing.
      final GiftCatalogue catalogue = await gifts.catalogue();
      GiftFilter? empty;
      for (final GiftTaxonomyItem branch in catalogue.branches) {
        for (final GiftTaxonomyItem tier in catalogue.effortTiers) {
          final GiftFilter candidate =
              GiftFilter(branchId: branch.id, effortTierId: tier.id);
          if ((await rankedSuggestions(filter: candidate)).isEmpty) {
            empty = candidate;
            break;
          }
        }
        if (empty != null) {
          break;
        }
      }
      expect(empty, isNotNull, reason: 'the pack no longer has an empty branch');

      await pumpGiftScreen(tester);
      await tester.tap(find.byKey(Key('gift_branch_chip_${empty!.branchId}')));
      await tester.pumpAndSettle();
      await tester
          .tap(find.byKey(Key('gift_effort_chip_${empty.effortTierId}')));
      await tester.pumpAndSettle();

      expect(find.byType(GiftIdeaCard), findsNothing);
      expect(find.byKey(const Key('gift-ideas-no-match')), findsOneWidget);
      expect(tester.takeException(), isNull);
      // The chips stay put, so the way out is one tap and not a dead end.
      expect(
        find.byKey(Key('gift_branch_chip_${empty.branchId}')),
        findsOneWidget,
      );
    });

    testWidgets('no progress, percentage or "ran out" indicator (AC-33)',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);

      for (final String rendered in _renderedText(tester)) {
        final String lower = rendered.toLowerCase();
        for (final String token in <String>[
          '%',
          'đã hết',
          'hết ý tưởng',
          'còn lại',
          'xem thêm',
          'tải thêm',
        ]) {
          expect(
            lower.contains(token),
            isFalse,
            reason: 'screen (5) rendered "$rendered", which counts the set',
          );
        }
      }
      expect(find.byType(LinearProgressIndicator), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('exactly one inline ask card, between filters and list',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);

      expect(find.byType(AskOnTheSpotSlot), findsOneWidget);
      expect(find.byKey(const Key('ask-on-the-spot-card')), findsOneWidget);

      final AskOnTheSpotSlot slot =
          tester.widget<AskOnTheSpotSlot>(find.byType(AskOnTheSpotSlot));
      expect(slot.entryPointId, giftIdeasEntryPointId);
      expect(slot.neededFieldIds, <String>[
        AskTarget.notebookInterest.wireValue,
        AskTarget.notebookEvent.wireValue,
        AskTarget.skill.wireValue,
      ]);
    });

    testWidgets('the bottom row is the tappable guess row, under every card',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);

      final Finder row = find.byKey(const Key('gift-ideas-guess-row'));
      expect(row, findsOneWidget);
      // Card-like and tappable per the canvas, but still a side path: no
      // primary button and no gradient pill down there.
      expect(
        find.descendant(of: row, matching: find.byType(ElevatedButton)),
        findsNothing,
      );
      expect(find.byIcon(CupidIcons.help), findsOneWidget);
      // Two entry rows share this shape now (portrait + compatibility table),
      // so the chevron glyph renders once per row.
      expect(find.byIcon(CupidIcons.chevronRight), findsNWidgets(2));

      // Below every suggestion, not above them.
      final double lastCard =
          tester.getBottomLeft(find.byType(GiftIdeaCard).last).dy;
      expect(tester.getTopLeft(row).dy, greaterThanOrEqualTo(lastCard));
    });

    testWidgets('tapping the guess row opens the portrait (SC-5, AC-2)',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);

      final Finder row = find.byKey(const Key('gift-ideas-guess-row'));
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pumpAndSettle();

      // The provenance label is the portrait's own chrome and renders in both
      // of its states, so it identifies the destination without waiting on the
      // content packs.
      expect(find.byKey(const Key('portrait-provenance')), findsOneWidget);
      // Pushed, not replaced: screen (5) is still underneath (AC-4). The route
      // below a completed push is offstage, which the default finder skips.
      expect(
        find.byType(GiftIdeasScreen, skipOffstage: false),
        findsOneWidget,
      );
    });

    testWidgets('tapping the compatibility row opens the compatibility table (SC-5)',
        (WidgetTester tester) async {
      final BackendUserIdStore owner = BackendUserIdStore()
        ..updateUserId('user-1');
      getIt.registerFactory<CompatibilityLookupCubit>(
        () => CompatibilityLookupCubit(
          labels: RelationshipLabelRepository(
            dao: database.relationshipLabelsDao,
            ownerKeyStore: owner,
          ),
          cards: cards,
          loader: diskLoader,
        ),
      );

      await pumpGiftScreen(tester);

      final Finder row = find.byKey(const Key('gift-ideas-compat-row'));
      await tester.ensureVisible(row);
      await tester.pumpAndSettle();
      await tester.tap(row);
      await tester.pumpAndSettle();

      // The row is screen (10)'s only door, and it opens it by calling the
      // entry point directly — there is no route name to push (AC-2/AC-3).
      expect(find.byType(CompatibilityLookupScreen), findsOneWidget);
    });

    testWidgets('the lead card is full, every following card is compact',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);
      final List<GiftSuggestion> ranked = await rankedSuggestions();
      expect(
        ranked.length,
        greaterThan(1),
        reason: 'the pack no longer ships a second suggestion to compact',
      );

      final List<GiftIdeaCard> cards =
          tester.widgetList<GiftIdeaCard>(find.byType(GiftIdeaCard)).toList();
      expect(cards.first.compact, isFalse);
      expect(
        cards.skip(1).every((GiftIdeaCard card) => card.compact),
        isTrue,
      );

      // The compact shape is the canvas's minutes badge plus a circular add
      // control, and it carries no second primary pill.
      final GiftSuggestion second = ranked[1];
      expect(
        find.byKey(Key('gift_idea_effort_badge_${second.idea.id}')),
        findsOneWidget,
      );
      expect(
        find.byKey(Key('gift_idea_add_${second.idea.id}')),
        findsOneWidget,
      );
      expect(
        find.descendant(
          of: find.byKey(Key('gift_idea_card_${second.idea.id}')),
          matching: find.byType(ElevatedButton),
        ),
        findsNothing,
      );
      // The badge says the pack's own ceiling in minutes, not a Dart band.
      // Scoped to this card: several compact cards can legitimately share a
      // tier, so the same text is expected elsewhere in the list.
      expect(
        find.descendant(
          of: find.byKey(Key('gift_idea_card_${second.idea.id}')),
          matching: find.text("${second.effortTier!.maxMinutes}'"),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the compact add control pushes to the hub like the pill',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);
      final List<GiftSuggestion> ranked = await rankedSuggestions();
      final GiftIdea second = ranked[1].idea;

      final Finder circle = find.byKey(Key('gift_idea_add_${second.id}'));
      await tester.ensureVisible(circle);
      await tester.pumpAndSettle();
      await tester.tap(circle);
      await tester.pumpAndSettle();

      final List<ActivityCard> created = await cards.cardsByStatus(
        status: ActivityCardStatus.idea,
        limit: ranked.length,
      );
      expect(created, hasLength(1));
      expect(created.single.title, second.title);
      expect(created.single.origin, ActivityCardOrigin.giftSuggestion);
      expect(created.single.priceVnd, isNull);
      expect(find.byKey(Key('gift_idea_added_${second.id}')), findsOneWidget);
    });
  });

  group('bỏ qua một gợi ý (không ghi lại gì)', () {
    testWidgets('the × sits beside the primary pill, on the lead card only',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);
      final List<GiftSuggestion> ranked = await rankedSuggestions();

      expect(
        find.byKey(Key('gift_idea_dismiss_${ranked.first.idea.id}')),
        findsOneWidget,
      );
      for (final GiftSuggestion later in ranked.skip(1)) {
        expect(
          find.byKey(Key('gift_idea_dismiss_${later.idea.id}')),
          findsNothing,
        );
      }
      expect(find.byIcon(CupidIcons.close), findsOneWidget);
    });

    testWidgets('tapping it drops the card and promotes the next one',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);
      final List<GiftSuggestion> ranked = await rankedSuggestions();
      final GiftIdea lead = ranked.first.idea;
      final GiftIdea next = ranked[1].idea;

      await tester.tap(find.byKey(Key('gift_idea_dismiss_${lead.id}')));
      await tester.pumpAndSettle();

      expect(find.byKey(Key('gift_idea_card_${lead.id}')), findsNothing);
      expect(find.byType(GiftIdeaCard), findsNWidgets(ranked.length - 1));
      // The next idea takes the lead shape, so it now carries the pill and the
      // dismiss control the canvas draws there.
      final GiftIdeaCard promoted = tester.widget<GiftIdeaCard>(
        find.ancestor(
          of: find.byKey(Key('gift_idea_card_${next.id}')),
          matching: find.byType(GiftIdeaCard),
        ),
      );
      expect(promoted.compact, isFalse);
      expect(
        find.byKey(Key('gift_idea_dismiss_${next.id}')),
        findsOneWidget,
      );
      // Nothing was written down: the dismissal is screen-session state only.
      final List<ActivityCard> created = await cards.cardsByStatus(
        status: ActivityCardStatus.idea,
        limit: ranked.length,
      );
      expect(created, isEmpty);
      expect(find.byType(GiftIdeasScreen), findsOneWidget);
    });

    testWidgets('waving every idea away wraps the round, it does not empty it',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);
      final List<GiftSuggestion> ranked = await rankedSuggestions();
      expect(ranked.length, greaterThan(1));

      // One tap per ranked idea. Each one dismisses the current lead, so the
      // expected lead at every step is the next ranked idea; the last tap is
      // the one that used to leave the reader looking at a no-match line for
      // a set that still has ideas in it (AC-33).
      for (final GiftSuggestion suggestion in ranked) {
        final Finder dismiss =
            find.byKey(Key('gift_idea_dismiss_${suggestion.idea.id}'));
        expect(
          dismiss,
          findsOneWidget,
          reason: '${suggestion.idea.id} should hold the lead at this step',
        );
        await tester.ensureVisible(dismiss);
        await tester.pumpAndSettle();
        await tester.tap(dismiss);
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('gift-ideas-no-match')), findsNothing);
        expect(find.byType(GiftIdeaCard), findsWidgets);
      }

      // The whole ranked set is back, rotated on by one, so asking for the
      // next idea keeps working at any N (AC-33, R-15b).
      expect(find.byType(GiftIdeaCard), findsNWidgets(ranked.length));
      for (final GiftSuggestion suggestion in ranked) {
        expect(
          find.byKey(Key('gift_idea_card_${suggestion.idea.id}')),
          findsOneWidget,
        );
      }
      final GiftIdeaCard lead = tester.widget<GiftIdeaCard>(
        find.ancestor(
          of: find.byKey(Key('gift_idea_card_${ranked[1].idea.id}')),
          matching: find.byType(GiftIdeaCard),
        ),
      );
      expect(lead.compact, isFalse);
      expect(
        find.byKey(Key('gift_idea_dismiss_${ranked[1].idea.id}')),
        findsOneWidget,
      );

      // Still nothing written down after a full round.
      final List<ActivityCard> created = await cards.cardsByStatus(
        status: ActivityCardStatus.idea,
        limit: ranked.length,
      );
      expect(created, isEmpty);
    });
  });

  group('dải "dựa trên" dưới bộ lọc (AC-14)', () {
    testWidgets('it names the reader\'s own skills and notebook row count',
        (WidgetTester tester) async {
      await notebook.addSkill(
        label: 'gói quà đẹp',
        source: ContextEntrySource.manual,
        seedId: 'skill.goi_qua_dep.v1',
      );
      await notebook.addEntry(
        kind: NotebookKind.interest,
        value: 'cà phê',
        source: ContextEntrySource.manual,
      );
      await notebook.addEntry(
        kind: NotebookKind.event,
        value: 'sinh nhật',
        source: ContextEntrySource.manual,
      );
      await pumpGiftScreen(tester);

      final Finder band = find.byKey(const Key('gift-ideas-basis-band'));
      expect(band, findsOneWidget);
      final String text = tester
          .widget<Text>(find.descendant(of: band, matching: find.byType(Text)))
          .data!;
      expect(text, contains('gói quà đẹp'));
      expect(text, contains('2 dòng'));
      // The count is of rows the reader wrote, never of the other person's
      // behaviour (AC-25) and never a completeness target (AC-33).
      expect(text, isNot(contains('%')));
    });

    testWidgets('a reader who has written nothing gets no band at all',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);

      expect(find.byKey(const Key('gift-ideas-basis-band')), findsNothing);
      // And the list is still usable, which is the AC-15 promise.
      expect(find.byType(GiftIdeaCard), findsWidgets);
    });
  });

  group('đẩy sang kho chung, không ngõ cụt (AC-21, AC-23, AC-24)', () {
    testWidgets('the primary action creates a hub card and stays on the screen',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);
      final List<GiftSuggestion> ranked = await rankedSuggestions();
      final GiftSuggestion suggestion = ranked.first;
      final GiftIdea idea = suggestion.idea;
      final GiftTaxonomyItem tier = suggestion.effortTier!;

      final Finder pill = find.byKey(Key('gift_idea_add_${idea.id}'));
      await tester.ensureVisible(pill);
      await tester.pumpAndSettle();
      await tester.tap(pill);
      await tester.pumpAndSettle();

      final List<ActivityCard> created = await cards.cardsByStatus(
        status: ActivityCardStatus.idea,
        limit: ranked.length,
      );

      expect(created, hasLength(1));
      expect(created.single.title, idea.title);
      expect(created.single.origin, ActivityCardOrigin.giftSuggestion);
      expect(created.single.origin.wireValue, 'gift_suggestion');
      expect(created.single.durationMinutes, tier.maxMinutes);
      // The cost field STORY-001 offers is never filled by this flow (AC-23).
      expect(created.single.priceVnd, isNull);

      // No auto-navigation, no separate "đã lưu" screen: the reader is still
      // on screen (5), with the confirmation in place (AC-24, SC-5).
      expect(find.byType(GiftIdeasScreen), findsOneWidget);
      expect(find.byKey(Key('gift_idea_added_${idea.id}')), findsOneWidget);
      expect(pill, findsOneWidget);
    });

    testWidgets('a handmade suggestion names the skill it came from (AC-20)',
        (WidgetTester tester) async {
      await notebook.addSkill(
        label: 'gói quà đẹp',
        source: ContextEntrySource.manual,
        seedId: 'skill.goi_qua_dep.v1',
      );
      await pumpGiftScreen(tester);

      final Iterable<GiftIdeaCard> handmade = tester
          .widgetList<GiftIdeaCard>(find.byType(GiftIdeaCard))
          .where((GiftIdeaCard card) => card.suggestion.idea.isHandmade);
      expect(handmade, isNotEmpty);

      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget is Text &&
              (widget.data ?? '').startsWith('từ kỹ năng: '),
        ),
        findsWidgets,
      );
    });

    testWidgets(
        'every personalised suggestion states its basis, not only handmade '
        '(AC-14)', (WidgetTester tester) async {
      // One recorded value of each notebook kind, so the assertion below is
      // about the interest and event branches and not only about the skill
      // profile the handmade branch already covered.
      for (final GiftIndexRow row in (await gifts.catalogue()).giftIndex.items) {
        if (row.contextKind == GiftContextKind.skill) {
          continue;
        }
        await notebook.addEntry(
          kind: row.contextKind == GiftContextKind.interest
              ? NotebookKind.interest
              : NotebookKind.event,
          value: row.value,
          source: ContextEntrySource.manual,
        );
      }
      await pumpGiftScreen(tester);

      final List<GiftSuggestion> ranked = await rankedSuggestions();
      final Iterable<GiftSuggestion> personalised = ranked.where(
        (GiftSuggestion suggestion) => suggestion.matches.isNotEmpty,
      );
      expect(personalised, isNotEmpty);

      // Non-handmade matches exist, so this is not the AC-20 case renamed.
      expect(
        personalised.any(
          (GiftSuggestion suggestion) =>
              !suggestion.idea.isHandmade &&
              suggestion.matches.any(
                (GiftContextMatch match) =>
                    match.context.kind != GiftContextKind.skill,
              ),
        ),
        isTrue,
      );

      for (final GiftSuggestion suggestion in personalised) {
        expect(
          find.byKey(Key('gift_idea_from_context_${suggestion.idea.id}')),
          findsOneWidget,
          reason: '"${suggestion.idea.title}" was personalised but says '
              'nothing about what the reader wrote that led to it',
        );
      }
    });
  });

  group('những thứ không được có mặt (AC-16, AC-19, AC-22)', () {
    testWidgets('no currency symbol, no cost band, no shop or discount copy',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);

      const List<String> bannedTokens = <String>[
        '₫',
        'vnđ',
        'vnd',
        'đồng',
        r'$',
        'giá',
        'rẻ',
        'đắt',
        'khuyến mãi',
        'giảm giá',
        'mã giảm',
        'cửa hàng',
        'shop',
        'mua ',
        'http',
      ];

      for (final String rendered in _renderedText(tester)) {
        final String lower = rendered.toLowerCase();
        for (final String token in bannedTokens) {
          expect(
            lower.contains(token),
            isFalse,
            reason: 'screen (5) rendered "$rendered", which carries "$token"',
          );
        }
      }
    });

    testWidgets('no save, favourite or share affordance beside the one action',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);

      const List<String> bannedActions = <String>[
        'lưu',
        'yêu thích',
        'chia sẻ',
        'save',
        'favourite',
        'favorite',
        'share',
        'để dành',
        'xem sau',
      ];
      for (final String rendered in _renderedText(tester)) {
        final String lower = rendered.toLowerCase();
        for (final String token in bannedActions) {
          expect(
            lower.contains(token),
            isFalse,
            reason: 'screen (5) rendered the second action "$rendered"',
          );
        }
      }

      for (final IconData glyph in <IconData>[
        Icons.share,
        Icons.favorite,
        Icons.favorite_border,
        Icons.bookmark,
        Icons.bookmark_border,
        Icons.star,
        Icons.star_border,
      ]) {
        expect(find.byIcon(glyph), findsNothing);
      }

      // Exactly one add affordance per card, whichever shape the card has,
      // and no second *keeping* control beside it. The lead card's × is the
      // canvas's dismiss: it stores nothing, so it is not a second store.
      final List<GiftIdeaCard> rendered =
          tester.widgetList<GiftIdeaCard>(find.byType(GiftIdeaCard)).toList();
      expect(rendered, isNotEmpty);
      for (final GiftIdeaCard card in rendered) {
        expect(
          find.byKey(Key('gift_idea_add_${card.suggestion.idea.id}')),
          findsOneWidget,
        );
      }
      // Only the lead card is a full pill, so exactly one ElevatedButton.
      expect(
        find.descendant(
          of: find.byType(GiftIdeaCard),
          matching: find.byType(ElevatedButton),
        ),
        findsOneWidget,
      );
    });
  });

  group('ô "Gợi ý quà" ở dải cửa vào nhanh', () {
    Future<void> registerCompositionRoot() async {
      getIt
        ..registerSingleton<ContextNotebookRepository>(notebook)
        ..registerSingleton<ActivityCardRepository>(cards)
        ..registerSingleton<GiftRepository>(gifts);
    }

    testWidgets('tapping it pushes screen (5)', (WidgetTester tester) async {
      await registerCompositionRoot();
      // A non-empty store, so the hub renders its own strip rather than the
      // Minute-1 surface.
      await cards.createCard(
        const NewActivityCard(
          title: 'Thẻ đã có',
          origin: ActivityCardOrigin.manual,
        ),
      );

      tester.view.physicalSize = _tallTestViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(ActivityCardHubView(repository: cards)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('activity_quick_entry_slot_0')));
      await tester.pumpAndSettle();

      expect(find.byType(GiftIdeasScreen), findsOneWidget);
      expect(
        find.byKey(const Key('activity_quick_entry_coming_soon')),
        findsNothing,
      );
    });

    testWidgets('it also pushes screen (5) from the Minute-1 empty store',
        (WidgetTester tester) async {
      await registerCompositionRoot();
      // No seeded card on purpose: an empty store puts the hub in Minute-1,
      // which carries its own copy of the strip. That is the first hub a new
      // user ever sees, so the cell has to lead somewhere from here too.
      tester.view.physicalSize = _tallTestViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(ActivityCardHubView(repository: cards)));
      await tester.pumpAndSettle();

      expect(find.byType(MinuteOneEmptyState), findsOneWidget);

      await tester.tap(find.byKey(const Key('activity_quick_entry_slot_0')));
      await tester.pumpAndSettle();

      expect(find.byType(GiftIdeasScreen), findsOneWidget);
      expect(
        find.byKey(const Key('activity_quick_entry_coming_soon')),
        findsNothing,
      );
    });

    // Slot 1 ("mồi chuyện") left this list when STORY-005 shipped screen (6),
    // and slot 2 ("vỏ hoàng đạo") when STORY-011 shipped screen (7). Each
    // keeps its navigation regression in its own suite:
    // `test/features/conversation_starters/conversation_starters_screen_test.dart`
    // and `test/features/zodiac_shell/zodiac_shell_entry_point_test.dart`.
    // No cell answers with the neutral "sắp có" message any more, so this file
    // asserts only that slot 0 reaches this feature's own screen.
  });

  testWidgets('captures 5-goi-y-qua-thang-cong-suc',
      (WidgetTester tester) async {
    await notebook.addSkill(
      label: 'Gói quà đẹp',
      source: ContextEntrySource.manual,
      seedId: 'skill.goi_qua_dep.v1',
    );
    await notebook.addEntry(
      kind: NotebookKind.event,
      value: 'sinh nhật',
      detail: '15/05',
      source: ContextEntrySource.manual,
    );

    await _captureAtReferenceViewport(
      tester,
      giftScreen(),
      'implemented-5-goi-y-qua-thang-cong-suc-ios.png',
    );
    await _captureAtReferenceViewport(
      tester,
      giftScreen(),
      'implemented-5-goi-y-qua-thang-cong-suc-md.png',
      platform: CupidPlatform.material,
    );
    await _captureAtReferenceViewport(
      tester,
      giftScreen(),
      'implemented-5-goi-y-qua-thang-cong-suc-md-full.png',
      platform: CupidPlatform.material,
      viewport: _fullPageViewport,
    );
  }, skip: !kCaptureVisuals);
}
