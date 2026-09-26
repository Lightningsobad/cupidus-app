import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_detail_screen.dart';
import 'package:cupid_mobile/features/before_you_go/data/before_you_go_dismissal_store.dart';
import 'package:cupid_mobile/features/before_you_go/domain/before_you_go_content.dart';
import 'package:cupid_mobile/features/before_you_go/domain/before_you_go_content_gate.dart';
import 'package:cupid_mobile/features/before_you_go/presentation/widgets/before_you_go_block.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Rendered evidence for the per-story visual fidelity gate. The block exists
/// only while a `scheduled` card's date is today, so it cannot be reached by
/// navigating a device build — it is captured from the widget tree instead,
/// pinned to the frame the design canvas renders at.
///
/// `flutter test test/features/before_you_go/before_you_go_block_test.dart \
///   --dart-define=CAPTURE_VISUALS=true`
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

/// The viewport `render-design-canvas.js --platform=ios` produced
/// `design-reference-sb-211-truoc-gio-di-ios.png` at, so the pair compares
/// without rescaling either side.
const Size _iosReferenceViewport = Size(415, 900);

const String _visualEvidenceDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-006_before_you_go_checklist/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

/// The day every fixture is resolved against. September is a rainy month in
/// all three regions, so an `outdoor` card in Hà Nội can exercise the rain row
/// without the test depending on the machine's clock.
final DateTime _today = DateTime(2026, 9, 11);

class _StubRepository implements ActivityCardRepository {
  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async => 1;

  @override
  Future<int> clearScheduledDate(String cardId) async => 1;

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async => 1;

  @override
  Future<int> deleteCard(String id) async => 1;

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) =>
      throw UnimplementedError('detail screen never creates');

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError('detail screen never lists');

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) => throw UnimplementedError('detail screen never lists');

  @override
  Future<ActivityCard?> cardById(String id) =>
      throw UnimplementedError('the card is handed in, not fetched');

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() =>
      throw UnimplementedError('detail screen never counts');
}

/// Records every status write the screen makes, so BR-8 can be asserted on the
/// repository rather than on the rendered label alone.
class _RecordingRepository extends _StubRepository {
  final List<ActivityCardStatus> statuses = <ActivityCardStatus>[];

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async {
    statuses.add(status);
    return 1;
  }
}

ActivityCard _card({
  ActivityCardStatus status = ActivityCardStatus.scheduled,
  String? scheduledOn = '2026-09-11',
  int? priceVnd = 120000,
  double? distanceKm = 12.5,
  bool? needsBooking = true,
  ActivityCardIndoorOutdoor? indoorOutdoor = ActivityCardIndoorOutdoor.outdoor,
  String? location = 'Hà Nội',
}) {
  final DateTime now = DateTime(2026, 9, 1);
  return ActivityCard(
    id: 'card-1',
    ownerKey: 'owner-1',
    title: 'Cà phê sách Hào Nam',
    status: status,
    origin: ActivityCardOrigin.manual,
    activityType: ActivityType.dining,
    scheduledOn: scheduledOn,
    priceVnd: priceVnd,
    distanceKm: distanceKm,
    needsBooking: needsBooking,
    indoorOutdoor: indoorOutdoor,
    note: 'Quán nhỏ, có kệ sách cũ ở tầng hai.',
    location: location,
    invited: status != ActivityCardStatus.idea,
    replyState: ActivityCardReplyState.answered,
    createdAt: now,
    updatedAt: now,
  );
}

/// The pack the app actually ships, read off disk rather than restated here.
/// A fixture pack would let the widget drift from the shipped labels without
/// any test noticing, which is the AC-29 failure this suite exists to catch.
BeforeYouGoPack _shippedPack() => parseBeforeYouGoPack(
      File('assets/data/req016/before_you_go.v1.json').readAsStringSync(),
      source: beforeYouGoAssetKey,
    );

/// A syntactically valid pack whose single row cannot hold for any card, so
/// the AC-14 empty branch is reached through the real resolver.
BeforeYouGoPack _unreachablePack() => parseBeforeYouGoPack(
      '''
{
  "id": "before_you_go",
  "version": "1.0.0",
  "schema_id": "req016.before_you_go.v1",
  "locale": "vi",
  "items": [
    {
      "id": "never",
      "order": 10,
      "labelVi": "Dòng này không bao giờ khớp",
      "icon": "payments",
      "when": [{ "field": "priceVnd", "op": "gt", "value": 999999999 }]
    }
  ],
  "regions": []
}
''',
      source: 'test://unreachable',
    );

Widget _host(
  Widget child, {
  CupidPlatform platform = CupidPlatform.material,
}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(platform: platform, child: child),
    );

/// The whole detail screen at once, so the block and the card-level CTA are
/// both hit-testable without a scroll step inside an assertion.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(415, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _pumpDetail(
  WidgetTester tester, {
  required ActivityCard card,
  BeforeYouGoPack? pack,
  ActivityCardRepository? repository,
  Future<void> Function(String text)? share,
  Key? key,
}) async {
  await tester.pumpWidget(
    _host(
      ActivityCardDetailScreen(
        key: key ?? UniqueKey(),
        card: card,
        repository: repository ?? _StubRepository(),
        beforeYouGo: BeforeYouGoOptions(
          today: _today,
          pack: pack ?? _shippedPack(),
          store: BeforeYouGoDismissalStore(),
          share: share,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

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

    // A handful of glyphs on this screen ship with the framework rather than
    // under `assets/fonts/` (`uses-material-design: true`). Without them the
    // capture shows tofu boxes and proves nothing about the icon set.
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
/// washes out of an iOS capture. The block itself is platform-neutral, so the
/// Material band is what the evidence is rendered through.
Future<void> _capture(
  WidgetTester tester,
  String fileName, {
  required ActivityCard card,
  bool dismissFirst = false,
}) async {
  tester.view.physicalSize = _iosReferenceViewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await _loadDesignFonts(tester);
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureBoundaryKey,
      child: _host(
        // The dark sky wash is mounted at the composition root, not by each
        // screen, so a capture without it reads as a light-mode regression.
        CupidAppBackground(
          enableEffectsOverride: false,
          child: ActivityCardDetailScreen(
            key: UniqueKey(),
            card: card,
            repository: _StubRepository(),
            beforeYouGo: BeforeYouGoOptions(
              today: _today,
              pack: _shippedPack(),
              store: BeforeYouGoDismissalStore(),
              share: (String text) async {},
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  if (dismissFirst) {
    await tester.ensureVisible(find.byKey(const Key('before_you_go_dismiss')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('before_you_go_dismiss')));
    await tester.pumpAndSettle();
  }

  await tester.ensureVisible(find.byKey(const Key('before_you_go_block')));
  await tester.pumpAndSettle();

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureBoundaryKey))
          as RenderRepaintBoundary;

  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final File out = File('$_visualEvidenceDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  // A *Đã đi rồi* card reaches STORY-007's activation ledger through the
  // composition root. Nothing here is ever armed, so the empty in-memory
  // database keeps those cards rendering nothing, which is what the
  // "block does not apply" group asserts.
  late CupidDatabase database;

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    database = CupidDatabase(NativeDatabase.memory());
    getIt.registerSingleton<CupidDatabase>(database);
  });

  tearDown(() async {
    await getIt.reset();
    await database.close();
  });

  group('when the block applies', () {
    testWidgets('a scheduled card dated today opens the block with no tap',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpDetail(tester, card: _card());

      expect(find.byKey(const Key('before_you_go_block')), findsOneWidget);
      expect(find.byKey(const Key('before_you_go_collapsed')), findsNothing);
      expect(find.byKey(const Key('before_you_go_dismiss')), findsOneWidget);
      expect(find.text('Trước giờ đi'), findsOneWidget);
    });

    testWidgets('rows come from the card fields, in pack order',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpDetail(tester, card: _card());

      // price > 0, distance >= 10, outdoor in a rainy month, booking required,
      // plus the unconditional share row.
      for (final String id in <String>[
        'cash',
        'fuel',
        'rain',
        'booking',
        'share_location',
      ]) {
        expect(
          find.byKey(Key('before_you_go_row_$id')),
          findsOneWidget,
          reason: 'row $id should hold for this card',
        );
      }
      expect(find.byKey(const Key('before_you_go_share')), findsOneWidget);
    });

    testWidgets('a field with no value drops its row rather than greying it',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpDetail(
        tester,
        card: _card(priceVnd: null, distanceKm: null, needsBooking: null),
      );

      expect(find.byKey(const Key('before_you_go_row_cash')), findsNothing);
      expect(find.byKey(const Key('before_you_go_row_fuel')), findsNothing);
      expect(find.byKey(const Key('before_you_go_row_booking')), findsNothing);
      expect(
        find.byKey(const Key('before_you_go_row_share_location')),
        findsOneWidget,
      );
    });
  });

  group('when the block does not apply', () {
    testWidgets('yesterday and tomorrow both render nothing',
        (WidgetTester tester) async {
      _useTallViewport(tester);

      for (final String date in <String>['2026-09-10', '2026-09-12']) {
        await _pumpDetail(tester, card: _card(scheduledOn: date));
        expect(
          find.byKey(const Key('before_you_go_block')),
          findsNothing,
          reason: 'a card dated $date is not a today card',
        );
        expect(find.byType(BeforeYouGoBlock), findsNothing);
      }
    });

    testWidgets('idea, done and memory cards dated today render nothing',
        (WidgetTester tester) async {
      _useTallViewport(tester);

      for (final ActivityCardStatus status in <ActivityCardStatus>[
        ActivityCardStatus.idea,
        ActivityCardStatus.done,
        ActivityCardStatus.memory,
      ]) {
        await _pumpDetail(tester, card: _card(status: status));
        expect(
          find.byType(BeforeYouGoBlock),
          findsNothing,
          reason: '$status is not the scheduled phase, whatever the date says',
        );
      }
    });

    testWidgets('an empty resolve hides the block, title included, and the '
        'screen still scrolls', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(415, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _pumpDetail(tester, card: _card(), pack: _unreachablePack());

      expect(find.byType(BeforeYouGoBlock), findsNothing);
      expect(find.text('Trước giờ đi'), findsNothing);

      // AC-14: the detail screen is still an ordinary working screen.
      final Finder scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('activity_card_detail')), findsOneWidget);
    });
  });

  group('the card-level action is untouched', () {
    testWidgets('exactly one card-level primary action, label unchanged',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpDetail(tester, card: _card());

      expect(
        find.byKey(const Key('card_detail_primary_action')),
        findsOneWidget,
      );
      expect(find.text('Chuẩn bị cho tươm tất'), findsOneWidget);
      // The block's own pill is a different widget with a different label, at
      // a visibly lower tier (AC-5).
      expect(find.text('Xong hết rồi, đi thôi'), findsOneWidget);
    });
  });

  group('closing and reopening', () {
    testWidgets('close collapses, survives a re-open of the screen the same '
        'day, and "Mở lại" restores the block',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpDetail(tester, card: _card());

      await tester.tap(find.byKey(const Key('before_you_go_dismiss')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('before_you_go_collapsed')), findsOneWidget);
      expect(find.byKey(const Key('before_you_go_dismiss')), findsNothing);
      expect(find.byKey(const Key('before_you_go_reopen')), findsOneWidget);

      // AC-15: leaving and coming back on the same day keeps it closed. A new
      // key means a new element tree, so nothing is carried over in memory —
      // only the stored day can bring the collapsed row back.
      await _pumpDetail(tester, card: _card());
      expect(find.byKey(const Key('before_you_go_collapsed')), findsOneWidget);

      // AC-16: closing is not a dead end.
      await tester.tap(find.byKey(const Key('before_you_go_reopen')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('before_you_go_collapsed')), findsNothing);
      expect(find.byKey(const Key('before_you_go_dismiss')), findsOneWidget);
      expect(find.byKey(const Key('before_you_go_row_cash')), findsOneWidget);
    });

    testWidgets('closing writes only the dismissal key and changes no card '
        'status', (WidgetTester tester) async {
      _useTallViewport(tester);
      final _RecordingRepository repository = _RecordingRepository();
      await _pumpDetail(tester, card: _card(), repository: repository);

      await tester.tap(find.byKey(const Key('before_you_go_dismiss')));
      await tester.pumpAndSettle();

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getKeys(),
        <String>{'before_you_go.dismissed_on.card-1'},
        reason: 'AC-19: closing the block records a day, nothing else',
      );
      expect(prefs.getString('before_you_go.dismissed_on.card-1'),
          '2026-09-11');
      expect(
        repository.statuses,
        isEmpty,
        reason: 'BR-8: the block never advances the card lifecycle',
      );
      // AC-17: no dialog, no congratulation, no second prompt.
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(Dialog), findsNothing);
    });

    testWidgets('the dismissal is per card, not per screen',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await _pumpDetail(tester, card: _card());
      await tester.tap(find.byKey(const Key('before_you_go_dismiss')));
      await tester.pumpAndSettle();

      final ActivityCard other = ActivityCard(
        id: 'card-2',
        ownerKey: 'owner-1',
        title: 'Đi dạo hồ Tây',
        status: ActivityCardStatus.scheduled,
        origin: ActivityCardOrigin.manual,
        activityType: ActivityType.walk,
        scheduledOn: '2026-09-11',
        priceVnd: 50000,
        location: 'Hà Nội',
        invited: true,
        replyState: ActivityCardReplyState.answered,
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );
      await _pumpDetail(tester, card: other);

      expect(find.byKey(const Key('before_you_go_collapsed')), findsNothing);
      expect(find.byKey(const Key('before_you_go_dismiss')), findsOneWidget);
    });
  });

  group('sharing location', () {
    testWidgets('one tap opens the sheet exactly once and records nothing',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      final List<String> shared = <String>[];
      await _pumpDetail(
        tester,
        card: _card(),
        share: (String text) async => shared.add(text),
      );

      await tester.tap(find.byKey(const Key('before_you_go_share')));
      await tester.pumpAndSettle();

      expect(shared, <String>['Cà phê sách Hào Nam · Hà Nội']);

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getKeys(),
        isEmpty,
        reason: 'AC-19: no recipient, no timestamp, no share history',
      );
    });

    testWidgets('skipping the share row blocks nothing and warns about nothing',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      final List<String> shared = <String>[];
      await _pumpDetail(
        tester,
        card: _card(),
        share: (String text) async => shared.add(text),
      );

      // AC-21: straight to "Xong hết rồi, đi thôi" without touching share.
      await tester.tap(find.byKey(const Key('before_you_go_dismiss')));
      await tester.pumpAndSettle();

      expect(shared, isEmpty);
      expect(find.byKey(const Key('before_you_go_collapsed')), findsOneWidget);
    });
  });

  group('content stays data', () {
    test('no shipped label is hardcoded in the feature source (AC-29)', () {
      final BeforeYouGoPack pack = _shippedPack();
      final List<String> labels = <String>[
        for (final ChecklistHint hint in pack.hints.items) hint.labelVi,
      ];
      expect(labels, isNotEmpty);

      final List<File> sources = Directory('lib/features/before_you_go')
          .listSync(recursive: true)
          .whereType<File>()
          .where((File file) => file.path.endsWith('.dart'))
          .toList();
      expect(sources, isNotEmpty);

      for (final File source in sources) {
        final String text = source.readAsStringSync();
        for (final String label in labels) {
          expect(
            text.contains(label),
            isFalse,
            reason: '${source.path} hardcodes the pack label "$label"',
          );
        }
      }
    });

    test('the widget icon map covers exactly the gate allowlist', () {
      expect(beforeYouGoHintIcons.keys.toSet(), beforeYouGoAllowedIcons);
    });

    testWidgets('every rendered row label comes from the pack',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      final BeforeYouGoPack pack = _shippedPack();
      await _pumpDetail(tester, card: _card(), pack: pack);

      final Set<String> packLabels = <String>{
        for (final ChecklistHint hint in pack.hints.items) hint.labelVi,
      };
      for (final ChecklistHint hint in pack.hints.items) {
        final Finder row = find.byKey(Key('before_you_go_row_${hint.id}'));
        final Iterable<Text> texts = tester.widgetList<Text>(
          find.descendant(of: row, matching: find.byType(Text)),
        );
        expect(
          texts.map((Text text) => text.data).whereType<String>(),
          anyElement(isIn(packLabels)),
        );
      }
    });
  });

  group('visual fidelity capture', () {
    testWidgets('captures the open block', (WidgetTester tester) async {
      await _capture(
        tester,
        'implemented-sb-211-truoc-gio-di-ios.png',
        card: _card(),
      );
    }, skip: !kCaptureVisuals);

    testWidgets('captures the collapsed row', (WidgetTester tester) async {
      await _capture(
        tester,
        'implemented-sb-211-truoc-gio-di-ios-collapsed.png',
        card: _card(),
        dismissFirst: true,
      );
    }, skip: !kCaptureVisuals);
  });
}
