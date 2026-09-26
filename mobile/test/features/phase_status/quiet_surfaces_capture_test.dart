import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_hub_view.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/quick_entry_strip.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_content_repository.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_status_prefs.dart';
import 'package:cupid_mobile/features/phase_status/presentation/gift_progress_block.dart';
import 'package:cupid_mobile/features/phase_status/presentation/wealth_counter_line.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart'
    show ByteData, CachingAssetBundle, FontLoader;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ---------------------------------------------------------------------------
// Per-story rendered evidence for the two surfaces P8 adds
// (`solution.md` §4 `VISUAL-FIDELITY`).
//
// Screen (1) is only reachable behind a signed-in, unpaired session and a
// DI-resolved card store, so the quiet surfaces are captured here instead, at
// the Android reference viewport the design canvas was drawn at. Off by
// default; enable with `--dart-define=CAPTURE_VISUALS=true`.
// ---------------------------------------------------------------------------
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');
const Size _referenceViewport = Size(412, 915);
const String _captureDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-012_phase_status_and_widget/visual-fidelity';
final GlobalKey _captureKey = GlobalKey();

final DateTime _today = DateTime(2026, 9, 16);

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

class _FakeRepository implements ActivityCardRepository {
  _FakeRepository(this._cards);

  final List<ActivityCard> _cards;

  @override
  Future<List<ActivityCard>> cardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async =>
      _cards
          .where((ActivityCard card) => card.status == status)
          .skip(offset)
          .take(limit)
          .toList(growable: false);

  @override
  Stream<List<ActivityCard>> watchCardsByStatus({
    required ActivityCardStatus status,
    required int limit,
    int offset = 0,
  }) async* {
    yield await cardsByStatus(status: status, limit: limit, offset: offset);
  }

  @override
  Future<Map<ActivityCardStatus, int>> countsByStatus() async {
    final Map<ActivityCardStatus, int> counts = <ActivityCardStatus, int>{};
    for (final ActivityCard card in _cards) {
      counts[card.status] = (counts[card.status] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Future<ActivityCard?> cardById(String id) async =>
      _cards.cast<ActivityCard?>().firstWhere(
            (ActivityCard? card) => card?.id == id,
            orElse: () => null,
          );

  @override
  Future<ActivityCard> createCard(NewActivityCard draft) async =>
      throw UnimplementedError();

  @override
  Future<int> deleteCard(String id) async => 0;

  @override
  Future<int> updateStatus(String cardId, ActivityCardStatus status) async => 1;

  @override
  Future<int> clearScheduledDate(String cardId) async => 1;

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async => 1;
}

ActivityCard _card({
  required String id,
  required ActivityCardStatus status,
  ActivityType? activityType,
}) {
  final DateTime stamp = DateTime(2026, 9, 7);
  return ActivityCard(
    id: id,
    ownerKey: 'owner-1',
    title: 'Thẻ $id',
    status: status,
    origin: ActivityCardOrigin.manual,
    activityType: activityType,
    invited: false,
    replyState: ActivityCardReplyState.notAnswered,
    createdAt: stamp,
    updatedAt: stamp,
  );
}

/// The busiest honest state of the quiet phase: five kept memories (so the
/// milestone caption is live), a gift the user is making, and a drip line that
/// has not been shown this week. Everything P8 can draw is on screen at once.
final List<ActivityCard> _loudestQuietStore = <ActivityCard>[
  _card(
    id: 'gift-1',
    status: ActivityCardStatus.idea,
    activityType: ActivityType.gift,
  ),
  for (int i = 0; i < 5; i++)
    _card(id: 'memory-$i', status: ActivityCardStatus.memory),
];

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

Widget _hub(List<ActivityCard> cards) => _host(
      ActivityCardHubView(
        repository: _FakeRepository(cards),
        phaseContent: PhaseContentRepository(bundle: _DiskBundle()),
        phaseStatusPrefs: PhaseStatusPrefs(),
        today: _today,
      ),
    );

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
  });
}

Future<void> _capture(
  WidgetTester tester,
  Widget app,
  String fileName,
) async {
  tester.view.physicalSize = _referenceViewport;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await _loadDesignFonts(tester);
  // Without an opaque layer under the app the PNG keeps the boundary's alpha
  // and every glyph edge reads washed out in a viewer that composites over
  // white.
  await tester.pumpWidget(
    RepaintBoundary(
      key: _captureKey,
      child: ColoredBox(
        color: const CupidColorTokens.dark().colorBackground,
        child: app,
      ),
    ),
  );
  await tester.pumpAndSettle();

  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureKey)) as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png =
        await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    final File out = File('$_captureDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  testWidgets('the quiet surfaces sit above the quick-entry strip and below '
      'nothing else (uiux §5/§6)', (WidgetTester tester) async {
    tester.view.physicalSize = _referenceViewport;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_hub(_loudestQuietStore));
    await tester.pumpAndSettle();

    expect(find.byKey(wealthCounterLineKey), findsOneWidget);
    expect(find.byKey(wealthCounterMilestoneKey), findsOneWidget);
    expect(find.byKey(giftProgressBlockKey), findsOneWidget);
    expect(find.byKey(dripCaptionLineKey), findsOneWidget);

    // The counter is the first thing under the screen title, ahead of the
    // three-cell strip, and it is not part of the sticky filter header.
    final double counterTop =
        tester.getTopLeft(find.byKey(wealthCounterLineKey)).dy;
    final double stripTop = tester.getTopLeft(find.byType(QuickEntryStrip)).dy;
    expect(counterTop, lessThan(stripTop));
    expect(
      find.ancestor(
        of: find.byKey(wealthCounterLineKey),
        matching: find.byType(SliverPersistentHeader),
      ),
      findsNothing,
    );
  });

  testWidgets(
    'capture the quiet surfaces at the reference viewport',
    (WidgetTester tester) async {
      await _capture(
        tester,
        _hub(_loudestQuietStore),
        'implemented-quiet-surfaces.png',
      );

      expect(File('$_captureDir/implemented-quiet-surfaces.png').existsSync(),
          isTrue);
    },
    skip: !kCaptureVisuals,
  );
}
