import 'dart:convert';
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
import 'package:cupid_mobile/features/context_notebook/context_notebook_entry_point.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_dao.dart';
import 'package:cupid_mobile/features/context_notebook/data/context_notebook_repository.dart';
import 'package:cupid_mobile/features/context_notebook/domain/ask_cadence_policy.dart';
import 'package:cupid_mobile/features/context_notebook/domain/context_notebook_models.dart';
import 'package:cupid_mobile/features/conversation_starters/data/calendar_event_state_repository.dart';
import 'package:cupid_mobile/features/conversation_starters/domain/event_date_label.dart';
import 'package:cupid_mobile/features/conversation_starters/domain/starter_content.dart';
import 'package:cupid_mobile/features/conversation_starters/domain/starter_selector.dart';
import 'package:cupid_mobile/features/conversation_starters/presentation/cubit/conversation_starters_cubit.dart';
// The entry point exports only the screen and its id, so the internals this
// file asserts on are reached through their own library.
import 'package:cupid_mobile/features/conversation_starters/presentation/screens/conversation_starters_screen.dart';
import 'package:cupid_mobile/features/conversation_starters/presentation/widgets/starter_hero_card.dart';
import 'package:cupid_mobile/features/conversation_starters/presentation/widgets/starter_line.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rendered-evidence capture for screen (6), off unless
/// `--dart-define=CAPTURE_VISUALS=true` so the ordinary suite stays hermetic.
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

const String _outputDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-005_conversation_starters/visual-fidelity';

/// Reference width of the iOS design render, so the capture compares with
/// `../ux/uiux-spec.md` §2 without rescaling.
const Size _referenceViewport = Size(415, 900);

/// A frame tall enough that every row is mounted at once. The body is a
/// `ListView`, so in a shorter frame an absence assertion could pass by never
/// having built the offending widget, and a `tap()` on the events strip would
/// miss.
const Size _tallViewport = Size(415, 4000);

/// The injected civil date. Every ordering assertion below is pinned to it:
/// the selector keys on `'$today|<id>'`, so changing this string reshuffles the
/// expected tables (AC-17).
const String _today = '2026-09-16';

final GlobalKey _captureBoundaryKey = GlobalKey();

/// Serves this file's synthetic packs for the two conversation-starter asset
/// keys and reads everything else — fonts, the ask card's own question pack —
/// straight off disk, the way a widget test has to.
///
/// The packs are synthetic on purpose: the rotation table below has to prove
/// what happens at N = 2, and no shipped pack is two items long.
class _FixtureBundle extends CachingAssetBundle {
  _FixtureBundle({required this.starters, required this.events});

  final String starters;
  final String events;

  @override
  Future<ByteData> load(String key) async {
    if (key == startersAssetKey) {
      return _bytes(starters);
    }
    if (key == calendarEventsAssetKey) {
      return _bytes(events);
    }
    final File file = File(key);
    if (!file.existsSync()) {
      throw FlutterError('no shipped asset at "$key"');
    }
    return ByteData.sublistView(file.readAsBytesSync());
  }

  static ByteData _bytes(String source) =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
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

String _startersPack(int count) => jsonEncode(<String, Object?>{
      'id': 'fixture.starters',
      'version': '1.0.0',
      'schema_id': startersSchemaId,
      'items': <Map<String, Object?>>[
        for (int index = 1; index <= count; index++)
          <String, Object?>{
            'id': 's${index.toString().padLeft(2, '0')}',
            'kind': 'generic',
            'text': 'Fixture starter $index?',
          },
      ],
    });

String _eventsPack(List<Map<String, Object?>> items) =>
    jsonEncode(<String, Object?>{
      'id': 'fixture.calendar_events',
      'version': '1.0.0',
      'schema_id': calendarEventsSchemaId,
      'items': items,
    });

Map<String, Object?> _event(
  String id,
  String name,
  List<String> dates, {
  String? activityType,
  String? reasonTemplate,
  String? reasonContextSlot,
}) =>
    <String, Object?>{
      'id': id,
      'name': name,
      'calendar': 'solar',
      'dates': dates,
      'activity_type': ?activityType,
      'reason_template': ?reasonTemplate,
      'reason_context_slot': ?reasonContextSlot,
    };

/// The reason line an event draws under its name, or `null` when the row is
/// silent — read off the widget tree rather than off the cubit.
String? _reasonOnScreen(WidgetTester tester, String eventId) {
  final Finder finder = find.byKey(Key('starter_event_reason_$eventId'));
  return finder.evaluate().isEmpty
      ? null
      : tester.widget<Text>(finder).data;
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

/// The ids currently on screen, top to bottom — the rotation evidence AC-27
/// asks for, read off the widgets rather than off the cubit.
///
/// The hero card comes first because it renders element `[0]` of the round;
/// the secondary lines follow in the selector's order, so this list stays the
/// round itself and the ordering tables below keep their meaning.
List<String> _starterIdsOnScreen(WidgetTester tester) => <String>[
      for (final StarterHeroCard hero in tester.widgetList<StarterHeroCard>(
        find.byType(StarterHeroCard),
      ))
        hero.starter.id,
      for (final StarterLine line in tester.widgetList<StarterLine>(
        find.byType(StarterLine),
      ))
        line.starter.id,
    ];

List<String> _renderedText(WidgetTester tester) => <String>[
      for (final Text text in tester.widgetList<Text>(find.byType(Text)))
        text.data ?? text.textSpan?.toPlainText() ?? '',
    ];

/// Rendered text minus the event rows, whose names now carry a `dd/mm` date
/// inline — the one legitimate `n/m` shape on this screen, which would
/// otherwise read as the "x/N" progress counter the forbidden-shape scan is
/// looking for.
List<String> _renderedTextOutsideEventNames(WidgetTester tester) => <String>[
      for (final Text text in tester.widgetList<Text>(find.byType(Text)))
        if (!_isEventName(text.key))
          text.data ?? text.textSpan?.toPlainText() ?? '',
    ];

bool _isEventName(Key? key) =>
    key is ValueKey<String> && key.value.startsWith('starter_event_name_');

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
    // `assets/fonts/`, so without this the capture shows a notdef box where the
    // header's back control belongs and proves nothing.
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
/// washes out of an iOS capture. Material is what evidences the title band.
Future<void> _captureAtReferenceViewport(
  WidgetTester tester,
  Widget home,
  String fileName, {
  CupidPlatform platform = CupidPlatform.material,
  Size viewport = _referenceViewport,
  Future<void> Function(WidgetTester)? beforeCapture,
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

  if (beforeCapture != null) {
    await beforeCapture(tester);
    await tester.pumpAndSettle();
  }

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
  late BackendUserIdStore owner;
  late ContextNotebookRepository notebook;
  late ActivityCardRepository cards;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    owner = BackendUserIdStore()..updateUserId('user-1');
    notebook = ContextNotebookRepository(
      dao: ContextNotebookDao(database),
      ownerKeyStore: owner,
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

  ContentPackageLoader fixtureLoader({
    int starterCount = 12,
    List<Map<String, Object?>> events = const <Map<String, Object?>>[],
  }) =>
      ContentPackageLoader(
        bundle: _FixtureBundle(
          starters: _startersPack(starterCount),
          events: _eventsPack(events),
        ),
      );

  Widget startersScreen(
    ContentPackageLoader loader, {
    void Function(ConversationStartersCubit)? onCubitCreated,
  }) =>
      ConversationStartersScreen(
        today: _today,
        cubitBuilder: () {
          final ConversationStartersCubit cubit = ConversationStartersCubit(
            notebook: _RepositoryReader(notebook),
            cardRepository: cards,
            eventStateRepository: CalendarEventStateRepository(database),
            ownerKeyStore: owner,
            today: _today,
            loader: loader,
          );
          onCubitCreated?.call(cubit);
          return cubit;
        },
        // The screen still hands its own entry point and target list to the
        // builder, so injecting the notebook seams here does not take the
        // production ask identity out of the assertions.
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
          contentLoader: loader,
          sessionSkips: AskSessionSkips(),
        ),
      );

  Future<void> pumpStarters(
    WidgetTester tester, {
    int starterCount = 12,
    List<Map<String, Object?>> events = const <Map<String, Object?>>[],
  }) async {
    tester.view.physicalSize = _tallViewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _host(
        startersScreen(fixtureLoader(starterCount: starterCount, events: events)),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<List<String>> expectedRound(int starterCount, int page) async {
    final ContentPackage<StarterItem> package =
        await fixtureLoader(starterCount: starterCount).load<StarterItem>(
      startersAssetKey,
      expectedSchemaId: startersSchemaId,
      itemParser: starterItemFromJson,
    );
    return <String>[
      for (final RenderedStarter starter in StarterSelector.select(
        package: package,
        notebook: await notebook.entries(),
        today: _today,
        page: page,
        perPage: kStartersPerRound,
      ))
        starter.id,
    ];
  }

  Future<int> cardCount() async {
    final Map<ActivityCardStatus, int> counts = await cards.countsByStatus();
    return counts.values.fold<int>(0, (int sum, int value) => sum + value);
  }

  group('vòng câu mồi (AC-4, AC-27, AC-28)', () {
    testWidgets('một vòng là đúng ba câu khi kho đủ dài (N = 12)',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12);

      expect(find.byKey(const Key('conversation-starters-list')), findsOneWidget);
      expect(_starterIdsOnScreen(tester), await expectedRound(12, 0));
      expect(_starterIdsOnScreen(tester), hasLength(kStartersPerRound));
    });

    testWidgets('kho ngắn hơn một vòng hiện đúng số câu có thật (N = 2)',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 2);

      final List<String> shown = _starterIdsOnScreen(tester);
      expect(shown, hasLength(2));
      expect(shown.toSet(), hasLength(2));
      // No filler: nothing stands in for the third slot the layout would have
      // held (AC-28).
      expect(find.byKey(const Key('starter_line_placeholder')), findsNothing);
    });

    testWidgets(
        'bấm nhiều lần hơn số câu vẫn luôn ra câu, nút không bao giờ tắt '
        '(N = 2)', (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 2);

      // "số lần bấm -> id câu hiện ra", the loop evidence AC-27 asks for.
      final List<List<String>> table = <List<String>>[];
      for (int taps = 0; taps <= 5; taps++) {
        table.add(_starterIdsOnScreen(tester));

        final InkWell button = tester.widget<InkWell>(
          find.byKey(const Key('starter_next_round')),
        );
        expect(button.onTap, isNotNull, reason: 'tap $taps left it enabled');

        await tester.tap(find.byKey(const Key('starter_next_round')));
        await tester.pumpAndSettle();
      }

      for (final List<String> round in table) {
        expect(round, hasLength(2));
      }
      // start = (page * 3) % 2 alternates 0, 1, 0, 1 ... so the pair swaps and
      // then comes back, forever, with no exhausted state in between.
      final List<String> first = table.first;
      final List<String> swapped = <String>[first[1], first[0]];
      expect(table[1], swapped);
      expect(table[2], first);
      expect(table[3], swapped);
      expect(table[4], first);
      expect(table[5], swapped);
    });

    testWidgets('bấm quá hết kho dài vẫn quay vòng (N = 12)',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12);

      // 12 items / 3 per round = 4 distinct rounds; tap past that.
      for (int taps = 1; taps <= 6; taps++) {
        await tester.tap(find.byKey(const Key('starter_next_round')));
        await tester.pumpAndSettle();

        expect(_starterIdsOnScreen(tester), hasLength(kStartersPerRound));
        expect(_starterIdsOnScreen(tester), await expectedRound(12, taps));
      }

      expect(_starterIdsOnScreen(tester), await expectedRound(12, 2));
    });

    testWidgets('sổ tay rỗng vẫn có câu để đọc (AC-6)',
        (WidgetTester tester) async {
      expect(await notebook.entries(), isEmpty);

      await pumpStarters(tester, starterCount: 12);

      expect(_starterIdsOnScreen(tester), hasLength(kStartersPerRound));
    });
  });

  group('phân cấp hero/phụ của khối Bản A (ruling 2026-09-20 mục 2)', () {
    testWidgets('kho đủ dài: một thẻ hero + hai câu phụ dưới caption (N = 12)',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12);

      expect(find.byKey(const Key('starter_hero_card')), findsOneWidget);
      expect(find.byKey(const Key('starter_hero_caption')), findsOneWidget);
      expect(find.text('CÂU HÔM NAY'), findsOneWidget);
      expect(find.byKey(const Key('starter_topic_caption')), findsOneWidget);
      expect(find.text('CÙNG CHỦ ĐỀ'), findsOneWidget);
      expect(find.byType(StarterLine), findsNWidgets(2));

      // The hero is element [0] of the round the selector returned — this
      // phase adds no second ordering rule on top of AC-17.
      final StarterHeroCard hero =
          tester.widget<StarterHeroCard>(find.byType(StarterHeroCard));
      expect(hero.starter.id, (await expectedRound(12, 0)).first);
    });

    testWidgets('N = 2: một hero + đúng một câu phụ',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 2);

      expect(find.byKey(const Key('starter_hero_card')), findsOneWidget);
      expect(find.byKey(const Key('starter_topic_caption')), findsOneWidget);
      expect(find.byType(StarterLine), findsOneWidget);
    });

    testWidgets('N = 1: chỉ thẻ hero, không caption "CÙNG CHỦ ĐỀ", không ô rỗng',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 1);

      expect(find.byKey(const Key('starter_hero_card')), findsOneWidget);
      expect(find.byKey(const Key('starter_topic_caption')), findsNothing);
      expect(find.text('CÙNG CHỦ ĐỀ'), findsNothing);
      expect(find.byType(StarterLine), findsNothing);
      expect(find.byKey(const Key('starter_line_placeholder')), findsNothing);
      expect(_starterIdsOnScreen(tester), hasLength(1));
    });

    testWidgets('hero nổi hơn câu phụ về cỡ chữ, không cùng một cỡ',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12);

      final List<String> ids = _starterIdsOnScreen(tester);
      final TextStyle heroStyle = tester
          .widget<Text>(find.byKey(Key('starter_line_text_${ids.first}')))
          .style!;
      final TextStyle secondaryStyle = tester
          .widget<Text>(find.byKey(Key('starter_line_text_${ids[1]}')))
          .style!;

      expect(heroStyle.fontSize, greaterThan(secondaryStyle.fontSize!));
      expect(
        heroStyle.fontWeight!.value,
        greaterThan(secondaryStyle.fontWeight!.value),
      );
    });

    testWidgets('bấm quá số mục thì hero luôn còn chữ (N = 2)',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 2);

      for (int taps = 0; taps <= 5; taps++) {
        final StarterHeroCard hero =
            tester.widget<StarterHeroCard>(find.byType(StarterHeroCard));
        expect(hero.starter.text, isNotEmpty, reason: 'sau $taps lần bấm');
        expect(
          tester
              .widget<Text>(
                find.byKey(Key('starter_line_text_${hero.starter.id}')),
              )
              .data,
          hero.starter.text,
        );

        await tester.tap(find.byKey(const Key('starter_next_round')));
        await tester.pumpAndSettle();
      }
    });

    testWidgets('cùng (ngày, sổ tay, page) ra cùng một hero qua hai lần dựng '
        '(AC-17)', (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12);
      final String first =
          tester.widget<StarterHeroCard>(find.byType(StarterHeroCard)).starter.id;

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      await pumpStarters(tester, starterCount: 12);
      final String second =
          tester.widget<StarterHeroCard>(find.byType(StarterHeroCard)).starter.id;

      expect(second, first);
    });
  });

  group('nhãn và affordance (ruling 2026-09-20 mục 3, 4, 5)', () {
    testWidgets('thẻ hero có nút đặc "Chép để nhắn" kèm icon copy',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12);

      final String heroId = _starterIdsOnScreen(tester).first;
      final Finder cta = find.byKey(Key('starter_line_copy_$heroId'));
      expect(cta, findsOneWidget);

      final CupidPrimaryButton button = tester.widget<CupidPrimaryButton>(cta);
      expect(button.label, 'Chép để nhắn');
      expect(button.leadingIcon, CupidIcons.contentCopy);
      expect(find.text('Chép để nhắn'), findsOneWidget);

      // Thẻ hero không còn nút icon copy trần; hai câu phụ thì vẫn giữ.
      expect(
        find.descendant(
          of: find.byType(StarterHeroCard),
          matching: find.byType(StarterCopyButton),
        ),
        findsNothing,
      );
      expect(find.byType(StarterCopyButton), findsNWidgets(2));
    });

    testWidgets('nút tròn refresh thay text button "Xem câu khác"',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12);

      final Finder next = find.byKey(const Key('starter_next_round'));
      expect(next, findsOneWidget);
      expect(tester.widget<InkWell>(next).onTap, isNotNull);
      expect(
        find.descendant(of: find.byType(StarterHeroCard), matching: next),
        findsOneWidget,
      );

      // Chữ biến mất khỏi thân màn, nhãn chỉ còn ở tầng trợ năng.
      expect(find.text('Xem câu khác'), findsNothing);
      final Semantics semantics = tester.widget<Semantics>(
        find.ancestor(of: next, matching: find.byType(Semantics)).first,
      );
      expect(semantics.properties.button, isTrue);
      expect(semantics.properties.label, 'Xem câu khác');

      expect(find.byIcon(CupidIcons.refresh), findsOneWidget);
      final Size size = tester.getSize(next);
      expect(size.width, greaterThanOrEqualTo(kStarterCopyTapTarget));
      expect(size.height, greaterThanOrEqualTo(kStarterCopyTapTarget));
    });

    testWidgets('dòng trấn an nằm dưới hàng CTA của thẻ hero',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12);

      final Finder reassurance =
          find.byKey(const Key('starter_hero_reassurance'));
      expect(reassurance, findsOneWidget);
      expect(
        tester.widget<Text>(reassurance).data,
        'Câu này nhắn liền, không cần lưu. Quay lại là có câu khác.',
      );
      expect(
        find.descendant(
          of: find.byType(StarterHeroCard),
          matching: reassurance,
        ),
        findsOneWidget,
      );

      final String heroId = _starterIdsOnScreen(tester).first;
      expect(
        tester.getTopLeft(reassurance).dy,
        greaterThan(
          tester.getBottomLeft(find.byKey(Key('starter_line_copy_$heroId'))).dy,
        ),
      );
    });

    testWidgets('khối sự kiện đọc nhãn mới, nhãn cũ biến mất',
        (WidgetTester tester) async {
      await pumpStarters(
        tester,
        starterCount: 12,
        events: <Map<String, Object?>>[
          _event('ev-upcoming', 'Fixture dated event', <String>['2026-10-20']),
        ],
      );

      expect(
        tester
            .widget<Text>(find.byKey(const Key('starter_events_heading')))
            .data,
        'CÓ LỊCH SẴN · RỦ ĐI ĐƯỢC',
      );
      expect(find.text('Sự kiện có lịch'), findsNothing);
      expect(find.byIcon(CupidIcons.event), findsOneWidget);

      expect(find.text('Thêm vào Muốn làm'), findsOneWidget);
      expect(find.text('Thêm vào kho'), findsNothing);
      expect(find.byIcon(CupidIcons.add), findsOneWidget);

      final Semantics pill = tester.widget<Semantics>(
        find
            .descendant(
              of: find.byKey(const Key('starter_event_add_ev-upcoming')),
              matching: find.byType(Semantics),
            )
            .first,
      );
      expect(pill.properties.button, isTrue);
      expect(pill.properties.label, 'Thêm vào Muốn làm');
    });
  });

  group('copy một câu (AC-2, AC-3)', () {
    testWidgets('chép vào clipboard, hiện toast, không tạo thẻ nào',
        (WidgetTester tester) async {
      final List<String> copied = <String>[];
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (MethodCall call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map<Object?, Object?>)['text']! as String);
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger
            .setMockMethodCallHandler(SystemChannels.platform, null),
      );

      await pumpStarters(tester, starterCount: 12);

      final String firstId = _starterIdsOnScreen(tester).first;
      final String firstText = tester
          .widget<Text>(find.byKey(Key('starter_line_text_$firstId')))
          .data!;

      await tester.tap(find.byKey(Key('starter_line_copy_$firstId')));
      await tester.pump();

      expect(copied, <String>[firstText]);
      expect(find.byKey(const Key('starter_copied_toast')), findsOneWidget);
      expect(find.text('Đã copy'), findsOneWidget);
      expect(await cardCount(), 0);

      // Transient, not a blocking dialog: it leaves on its own. The dismissal
      // timer only starts once the entrance animation has settled, so that is
      // pumped through first.
      await tester.pumpAndSettle();
      await tester.pump(kStarterCopiedToastDuration);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('starter_copied_toast')), findsNothing);
    });
  });

  group('sự kiện có lịch (AC-11, AC-12, AC-13, AC-14)', () {
    final List<Map<String, Object?>> twoUpcoming = <Map<String, Object?>>[
      _event('ev-upcoming', 'Fixture dated event', <String>['2026-10-20']),
      _event('ev-later', 'Fixture later event', <String>['2026-11-02']),
    ];

    testWidgets('kho sự kiện rỗng là một dòng trung tính, không phải lời mời',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12);

      expect(find.byKey(const Key('starter_events_heading')), findsOneWidget);
      expect(find.byKey(const Key('starter_events_empty')), findsOneWidget);
      expect(find.text('Chưa có sự kiện nào sắp tới'), findsOneWidget);
    });

    testWidgets('sự kiện đã qua không xuất hiện (AC-13)',
        (WidgetTester tester) async {
      await pumpStarters(
        tester,
        starterCount: 12,
        events: <Map<String, Object?>>[
          _event('ev-past', 'Fixture past event', <String>['2026-01-01']),
        ],
      );

      expect(find.byKey(const Key('starter_event_ev-past')), findsNothing);
      expect(find.byKey(const Key('starter_events_empty')), findsOneWidget);
      expect(_renderedText(tester), isNot(contains('Fixture past event')));
    });

    testWidgets('ngày nằm trong dòng tên, không còn badge riêng (ruling 6b)',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12, events: twoUpcoming);

      expect(
        tester
            .widget<Text>(find.byKey(const Key('starter_event_name_ev-upcoming')))
            .data,
        'Fixture dated event — thứ Ba 20/10',
      );
      expect(
        tester
            .widget<Text>(find.byKey(const Key('starter_event_name_ev-later')))
            .data,
        'Fixture later event — thứ Hai 02/11',
      );

      // Đúng một dòng cho mỗi sự kiện: badge leading đã bỏ hẳn.
      for (final String id in <String>['ev-upcoming', 'ev-later']) {
        expect(find.byKey(Key('starter_event_date_$id')), findsNothing);
        expect(find.byKey(Key('starter_event_name_$id')), findsOneWidget);
      }
      expect(find.text('20/10'), findsNothing);
    });

    testWidgets('ngày hiển thị khớp VisibleCalendarEvent.date',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12, events: twoUpcoming);

      final String rendered = tester
          .widget<Text>(find.byKey(const Key('starter_event_name_ev-upcoming')))
          .data!;
      expect(rendered, endsWith(eventDateLabel('2026-10-20')));
    });

    testWidgets('"Thêm vào Muốn làm" tạo thẻ conversationStarter rồi bỏ dòng đi',
        (WidgetTester tester) async {
      await pumpStarters(
        tester,
        starterCount: 12,
        events: <Map<String, Object?>>[
          _event(
            'ev-upcoming',
            'Fixture dated event',
            <String>['2026-10-20'],
            activityType: 'an_uong',
          ),
          twoUpcoming[1],
        ],
      );

      await tester.tap(find.byKey(const Key('starter_event_add_ev-upcoming')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('starter_event_ev-upcoming')), findsNothing);
      expect(find.byKey(const Key('starter_event_ev-later')), findsOneWidget);

      final List<ActivityCard> ideas = await cards.cardsByStatus(
        status: ActivityCardStatus.idea,
        limit: 50,
      );
      expect(ideas, hasLength(1));
      expect(ideas.single.title, 'Fixture dated event');
      expect(ideas.single.origin, ActivityCardOrigin.conversationStarter);
      expect(ideas.single.scheduledOn, '2026-10-20');
    });

    testWidgets('"Bỏ qua" bỏ dòng ngay, không hỏi lại, không tạo thẻ (AC-14)',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12, events: twoUpcoming);

      await tester
          .tap(find.byKey(const Key('starter_event_dismiss_ev-upcoming')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('starter_event_ev-upcoming')), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byKey(const Key('starter_event_ev-later')), findsOneWidget);
      expect(await cardCount(), 0);
    });

    testWidgets('bỏ hết sự kiện thì quay về dòng trung tính',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12, events: twoUpcoming);

      for (final String id in <String>['ev-upcoming', 'ev-later']) {
        await tester.tap(find.byKey(Key('starter_event_dismiss_$id')));
        await tester.pumpAndSettle();
      }

      expect(find.byKey(const Key('starter_events_empty')), findsOneWidget);
    });
  });

  group('màn hình không mọc thêm cửa nào (R-1b, R-1f, AC-3, AC-27)', () {
    testWidgets('không có bộ đếm, phần trăm, "đã hết", hay nút lưu/xuất',
        (WidgetTester tester) async {
      await pumpStarters(
        tester,
        starterCount: 2,
        events: <Map<String, Object?>>[
          _event('ev-upcoming', 'Fixture dated event', <String>['2026-10-20']),
        ],
      );

      Future<void> assertClean(String stage) async {
        final String joined = _renderedText(tester).join('\n').toLowerCase();
        for (final String forbidden in <String>[
          '%',
          'đã hết',
          'hết câu',
          'đã xem hết',
          'còn lại',
          'lưu lại',
          'xuất',
          'yêu thích',
          'đã dùng',
          'điểm',
          'chuỗi ngày',
          'streak',
        ]) {
          expect(
            joined.contains(forbidden),
            isFalse,
            reason: '"$forbidden" surfaced at $stage',
          );
        }
        // "1/2", "2/2" and friends, anywhere outside the dd/mm event badges.
        expect(
          RegExp(r'\d{1,3}\s*/\s*\d{1,3}').hasMatch(
            _renderedTextOutsideEventNames(tester).join('\n'),
          ),
          isFalse,
          reason: 'a x/N counter surfaced at $stage',
        );
        expect(find.byType(Checkbox), findsNothing, reason: stage);
        expect(find.byType(Switch), findsNothing, reason: stage);
        expect(find.byType(Slider), findsNothing, reason: stage);
        expect(find.byType(LinearProgressIndicator), findsNothing, reason: stage);
        expect(
          find.byType(CircularProgressIndicator),
          findsNothing,
          reason: stage,
        );
      }

      await assertClean('vòng đầu');

      // Past the end of a two-item pack, where an exhaustion message would be.
      for (int taps = 0; taps < 3; taps++) {
        await tester.tap(find.byKey(const Key('starter_next_round')));
        await tester.pumpAndSettle();
      }
      await assertClean('sau khi quay vòng');
    });

    testWidgets('mỗi câu chỉ có một nút copy, không có gì để chấm điểm',
        (WidgetTester tester) async {
      await pumpStarters(tester, starterCount: 12);

      for (final String id in _starterIdsOnScreen(tester)) {
        expect(find.byKey(Key('starter_line_copy_$id')), findsOneWidget);
      }
      expect(find.byType(IconButton), findsNothing);
      expect(find.byIcon(Icons.thumb_up), findsNothing);
      expect(find.byIcon(Icons.thumb_down), findsNothing);
      expect(find.byIcon(Icons.star), findsNothing);
      expect(find.byIcon(Icons.star_border), findsNothing);
    });
  });

  // No AC names this entry point; it is specified by ux/uiux-spec.md §1 ("Mở từ
  // ô thứ 2 trong dải lối-vào-nhanh 3 ô trên đầu tab Nhà").
  group('lối vào từ ô quick-entry của màn (1)', () {
    Future<void> registerCompositionRoot() async {
      getIt
        ..registerSingleton<CupidDatabase>(database)
        ..registerSingleton<BackendUserIdStore>(owner)
        ..registerSingleton<ContextNotebookRepository>(notebook)
        ..registerSingleton<ActivityCardRepository>(cards);
    }

    testWidgets('ô "mồi chuyện" mở màn (6) bằng đường sản xuất thật',
        (WidgetTester tester) async {
      await registerCompositionRoot();
      await cards.createCard(
        const NewActivityCard(
          title: 'Thẻ đã có',
          origin: ActivityCardOrigin.manual,
        ),
      );

      tester.view.physicalSize = _tallViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(ActivityCardHubView(repository: cards)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('activity_quick_entry_slot_1')));
      await tester.pumpAndSettle();

      expect(find.byType(ConversationStartersScreen), findsOneWidget);
      expect(
        find.byKey(const Key('activity_quick_entry_coming_soon')),
        findsNothing,
      );
      // The shipped pack, through the production `_resolveCubit` path.
      expect(find.byType(StarterLine), findsWidgets);
    });

    testWidgets('ô "mồi chuyện" cũng mở được từ màn hình Minute-1',
        (WidgetTester tester) async {
      await registerCompositionRoot();

      tester.view.physicalSize = _tallViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(_host(ActivityCardHubView(repository: cards)));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('activity_quick_entry_slot_1')));
      await tester.pumpAndSettle();

      expect(find.byType(ConversationStartersScreen), findsOneWidget);
    });

    // Ô 2 ("vỏ hoàng đạo") rời danh sách này khi STORY-011 ship màn (7):
    // không còn ô nào trả lời "sắp có" nữa. Hồi quy điều hướng của nó nằm ở
    // `test/features/zodiac_shell/zodiac_shell_entry_point_test.dart`.

    test('entry point id và ô hỏi của màn (6) là đúng hai đích sổ tay', () {
      expect(conversationStartersEntryPointId, 'conversation_starters');
      expect(
        conversationStartersNeededFieldIds,
        <String>[
          AskTarget.notebookInterest.wireValue,
          AskTarget.notebookEvent.wireValue,
        ],
      );
    });
  });

  group('dòng lý do dưới tên sự kiện (ruling 2026-09-20 mục 7)', () {
    const String template = 'Đúng dòng "{value}" trong sổ tay';

    List<Map<String, Object?>> eventsWithAndWithoutReason() =>
        <Map<String, Object?>>[
          _event(
            'ev-upcoming',
            'Fixture dated event',
            <String>['2026-10-20'],
            reasonTemplate: template,
            reasonContextSlot: 'interest',
          ),
          _event('ev-later', 'Fixture later event', <String>['2026-11-02']),
        ];

    testWidgets('sổ tay có mục khớp: chỉ sự kiện khai template mới có lý do',
        (WidgetTester tester) async {
      await notebook.addEntry(
        kind: NotebookKind.interest,
        value: 'Cà phê sáng',
        source: ContextEntrySource.manual,
      );

      await pumpStarters(
        tester,
        starterCount: 12,
        events: eventsWithAndWithoutReason(),
      );

      expect(
        _reasonOnScreen(tester, 'ev-upcoming'),
        'Đúng dòng "Cà phê sáng" trong sổ tay',
      );
      expect(_reasonOnScreen(tester, 'ev-later'), isNull);
    });

    testWidgets('sổ tay rỗng: không dòng lý do nào, và không ô nào lộ {value}',
        (WidgetTester tester) async {
      expect(await notebook.entries(), isEmpty);

      await pumpStarters(
        tester,
        starterCount: 12,
        events: eventsWithAndWithoutReason(),
      );

      expect(_reasonOnScreen(tester, 'ev-upcoming'), isNull);
      expect(_reasonOnScreen(tester, 'ev-later'), isNull);
      expect(
        _renderedText(tester).where((String text) => text.contains('{value}')),
        isEmpty,
      );
    });

    testWidgets(
        'trả lời xong câu hỏi: dòng lý do hiện ra, nhưng dòng đã bỏ qua '
        'không sống lại (AC-12, AC-14)', (WidgetTester tester) async {
      late ConversationStartersCubit cubit;
      tester.view.physicalSize = _tallViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        _host(
          startersScreen(
            fixtureLoader(
              starterCount: 12,
              events: eventsWithAndWithoutReason(),
            ),
            onCubitCreated: (ConversationStartersCubit created) =>
                cubit = created,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(_reasonOnScreen(tester, 'ev-upcoming'), isNull);

      await tester.tap(find.byKey(const Key('starter_event_dismiss_ev-later')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('starter_event_ev-later')), findsNothing);

      await notebook.addEntry(
        kind: NotebookKind.interest,
        value: 'Cà phê sáng',
        source: ContextEntrySource.askOnTheSpot,
      );
      await cubit.refreshContext();
      await tester.pumpAndSettle();

      expect(
        _reasonOnScreen(tester, 'ev-upcoming'),
        'Đúng dòng "Cà phê sáng" trong sổ tay',
      );
      expect(find.byKey(const Key('starter_event_ev-later')), findsNothing);
    });
  });

  testWidgets(
    'captures 6-moi-chuyen-a-a',
    (WidgetTester tester) async {
      await notebook.addEntry(
        kind: NotebookKind.interest,
        value: 'thích đọc sách cũ',
        source: ContextEntrySource.manual,
      );

      await _captureAtReferenceViewport(
        tester,
        startersScreen(
          fixtureLoader(
            starterCount: 12,
            events: <Map<String, Object?>>[
              _event(
                'ev-a',
                'Sinh nhật bạn ấy',
                <String>['2026-10-20'],
                reasonTemplate: 'Đúng dòng "{value}" trong sổ tay',
                reasonContextSlot: 'interest',
              ),
              _event('ev-b', 'Kỷ niệm quen nhau', <String>['2026-11-02']),
            ],
          ),
        ),
        'implemented-6-moi-chuyen-a-a-material.png',
        // The canvas frames the event strip with no ask card above it. Left up,
        // the card fills the lower half and pushes the reason line — the one
        // thing this phase adds — below the reference fold.
        beforeCapture: (WidgetTester tester) =>
            tester.tap(find.byKey(const Key('ask-skip'))),
      );

      expect(
        File('$_outputDir/implemented-6-moi-chuyen-a-a-material.png')
            .existsSync(),
        isTrue,
      );
    },
    skip: !kCaptureVisuals,
  );
}
