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
}) async {
  tester.view.physicalSize = kIosReferenceViewport;
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
  });

  tearDown(() async {
    await getIt.reset();
    await database.close();
  });

  Widget giftScreen() => GiftIdeasScreen(
        giftRepository: gifts,
        cardRepository: cards,
        notebookRepository: notebook,
        contentLoader: diskLoader,
        sessionSkips: AskSessionSkips(),
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
    });

    testWidgets('the location-lock line is small text at the bottom, not a card',
        (WidgetTester tester) async {
      await pumpGiftScreen(tester);

      final Finder line = find.byKey(const Key('gift-ideas-location-lock'));
      expect(line, findsOneWidget);
      // Text only: no tap target, no fill, no card frame around it.
      expect(
        find.descendant(of: line, matching: find.byType(GestureDetector)),
        findsNothing,
      );
      expect(
        find.descendant(of: line, matching: find.byType(ElevatedButton)),
        findsNothing,
      );
      expect(
        find.descendant(of: line, matching: find.byType(DecoratedBox)),
        findsNothing,
      );

      // Below every suggestion, not above them.
      final double lastCard = tester
          .getBottomLeft(find.byType(GiftIdeaCard).last)
          .dy;
      expect(tester.getTopLeft(line).dy, greaterThanOrEqualTo(lastCard));
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

      // Exactly one button per card, and it is the add pill.
      final int cardCount =
          tester.widgetList<GiftIdeaCard>(find.byType(GiftIdeaCard)).length;
      expect(cardCount, greaterThan(0));
      expect(
        find.descendant(
          of: find.byType(GiftIdeaCard),
          matching: find.byType(ElevatedButton),
        ),
        findsNWidgets(cardCount),
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

    testWidgets('the other two Minute-1 cells keep the neutral message',
        (WidgetTester tester) async {
      await registerCompositionRoot();
      tester.view.physicalSize = _tallTestViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(ActivityCardHubView(repository: cards)));
      await tester.pumpAndSettle();

      expect(find.byType(MinuteOneEmptyState), findsOneWidget);

      for (final String slot in <String>['1', '2']) {
        await tester.tap(find.byKey(Key('activity_quick_entry_slot_$slot')));
        await tester.pump();

        expect(
          find.byKey(const Key('activity_quick_entry_coming_soon')),
          findsOneWidget,
        );
        expect(find.byType(GiftIdeasScreen), findsNothing);

        await tester.pumpAndSettle(const Duration(seconds: 5));
      }
    });

    testWidgets('the other two cells still answer with the neutral message',
        (WidgetTester tester) async {
      await registerCompositionRoot();
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

      for (final String slot in <String>['1', '2']) {
        await tester.tap(
          find.byKey(Key('activity_quick_entry_slot_$slot')),
        );
        await tester.pump();

        expect(
          find.byKey(const Key('activity_quick_entry_coming_soon')),
          findsOneWidget,
        );
        expect(find.byType(GiftIdeasScreen), findsNothing);

        await tester.pumpAndSettle(const Duration(seconds: 5));
      }
    });
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
  }, skip: !kCaptureVisuals);
}
