import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
import 'package:cupid_mobile/features/invite_composer/domain/preset_catalogue.dart';
import 'package:cupid_mobile/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Same frame as the P5 capture, so both surfaces of this story compare
/// against the design references without rescaling either side.
const Size _designFrame = Size(415, 900);

const String _visualFidelityDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-002_invite_message_composer/visual-fidelity';

final GlobalKey _captureKey = GlobalKey();

ActivityCard _card() => ActivityCard(
  id: 'card-1',
  ownerKey: 'owner-1',
  title: 'xem phim Dune',
  status: ActivityCardStatus.scheduled,
  origin: ActivityCardOrigin.manual,
  scheduledOn: '2026-08-15',
  timeOfDaySlot: TimeOfDaySlot.evening,
  durationMinutes: 120,
  location: 'rạp CGV Vincom Đồng Khởi',
  invited: false,
  replyState: ActivityCardReplyState.notAnswered,
  createdAt: DateTime.utc(2026, 8, 1),
  updatedAt: DateTime.utc(2026, 8, 1),
);

class _TestBundle extends AssetBundle {
  _TestBundle(this._sources);

  final Map<String, String> _sources;

  @override
  Future<ByteData> load(String key) async {
    final String? source = _sources[key];
    if (source == null) {
      throw FlutterError('asset not registered in this test bundle: $key');
    }
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(source)));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      utf8.decode((await load(key)).buffer.asUint8List());

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async => parser(await loadString(key));
}

String _packJson({int presetCount = 2}) => jsonEncode(<String, Object?>{
  'id': 'presets.invite',
  'version': '1.0.0',
  'schema_id': presetsSchemaId,
  'locale': 'vi',
  'items': List<Map<String, Object?>>.generate(presetCount, (int index) {
    return <String, Object?>{
      'id': 'frame.$index.v1',
      'frame': 'Rủ nhẹ nhàng',
      'clauses': <Map<String, Object?>>[
        <String, Object?>{
          'text': 'Rảnh không, mình đi {activity} nhé?',
          'requires': <String>['activity'],
          'targets': 'neutral',
        },
        <String, Object?>{
          'text': 'Bận thì cứ nói mình biết nha.',
          'requires': <String>[],
          'targets': 'neutral',
          'role': 'decline_door',
        },
      ],
    };
  }, growable: false),
});

/// A catalogue whose invite pack holds [presetCount] frames.
PresetCatalogue _catalogue({int presetCount = 2}) => PresetCatalogue(
  loader: ContentPackageLoader(
    bundle: _TestBundle(<String, String>{
      presetAssetKey(inviteCategoryId): _packJson(presetCount: presetCount),
    }),
  ),
);

/// A catalogue whose invite asset is not in the bundle at all, so the load
/// throws rather than returning an empty pack.
PresetCatalogue _missingPackCatalogue() =>
    PresetCatalogue(loader: ContentPackageLoader(bundle: _TestBundle(const {})));

Future<void> _loadBundledFonts() async {
  const Map<String, String> families = <String, String>{
    'Roboto': 'assets/fonts/Roboto-Variable.ttf',
    'Nunito': 'assets/fonts/Nunito-Variable.ttf',
    'Roboto Mono': 'assets/fonts/RobotoMono-Variable.ttf',
    // Without this the two row icons rasterize as tofu boxes and the capture
    // is useless as fidelity evidence, while the test still passes.
    'Material Symbols Rounded':
        'assets/fonts/MaterialSymbolsRounded-Variable.ttf',
  };
  for (final MapEntry<String, String> entry in families.entries) {
    final FontLoader loader = FontLoader(entry.key);
    loader.addFont(
      File(entry.value).readAsBytes().then(
        (Uint8List bytes) => ByteData.sublistView(bytes),
      ),
    );
    await loader.load();
  }
}

void main() {
  setUpAll(_loadBundledFonts);

  Widget host(Widget child) => RepaintBoundary(
    key: _captureKey,
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
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
    ),
  );

  /// The still-pending `showPrepareActionsSheet` call, so a test can await the
  /// whole interaction after tapping a row.
  late Future<void> pendingSheet;

  /// Pumps a backdrop and asks for the "Chuẩn bị" sheet over it.
  Future<void> openSheet(
    WidgetTester tester, {
    required PresetCatalogue catalogue,
    InviteComposerOpener? openComposer,
  }) async {
    tester.view.physicalSize = _designFrame;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    late BuildContext hostContext;
    await tester.pumpWidget(
      host(
        Builder(
          builder: (BuildContext context) {
            hostContext = context;
            return const Scaffold(body: SizedBox.expand());
          },
        ),
      ),
    );

    pendingSheet = showPrepareActionsSheet(
      hostContext,
      _card(),
      catalogue: catalogue,
      openComposer:
          openComposer ??
          (BuildContext _, ActivityCard _, String _) async => false,
    );
    await tester.pumpAndSettle();
  }

  List<String> visibleText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((Text text) => text.data ?? '')
      .where((String data) => data.isNotEmpty)
      .toList();

  testWidgets('lists "Xuất lời mời" when the invite pack resolves', (
    WidgetTester tester,
  ) async {
    await openSheet(tester, catalogue: _catalogue());

    expect(find.byKey(const Key('prepare_actions_sheet')), findsOneWidget);
    expect(find.text('Chuẩn bị'), findsOneWidget);
    expect(find.byKey(const Key('prepare_action_invite')), findsOneWidget);
    expect(find.text('Xuất lời mời'), findsOneWidget);
  });

  testWidgets('does not open at all when the pack holds no preset (AC-27)', (
    WidgetTester tester,
  ) async {
    await openSheet(tester, catalogue: _catalogue(presetCount: 0));

    // Not an empty sheet and not an error screen: no sheet.
    expect(find.byKey(const Key('prepare_actions_sheet')), findsNothing);
    expect(find.text('Xuất lời mời'), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
  });

  testWidgets('does not open when the pack asset is missing (AC-27)', (
    WidgetTester tester,
  ) async {
    await openSheet(tester, catalogue: _missingPackCatalogue());

    expect(find.byKey(const Key('prepare_actions_sheet')), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);
    for (final String data in visibleText(tester)) {
      expect(data, isNot(contains('lỗi')));
      expect(data, isNot(contains('Lỗi')));
    }
  });

  testWidgets('hands the card and the invite category to the composer', (
    WidgetTester tester,
  ) async {
    final List<(String, String)> opened = <(String, String)>[];
    await openSheet(
      tester,
      catalogue: _catalogue(),
      openComposer:
          (BuildContext _, ActivityCard card, String categoryId) async {
            opened.add((card.id, categoryId));
            return false;
          },
    );

    await tester.tap(find.byKey(const Key('prepare_action_invite')));
    await tester.pumpAndSettle();
    await pendingSheet;

    expect(opened, <(String, String)>[('card-1', inviteCategoryId)]);
  });

  testWidgets('closes itself before the composer opens (UX §4)', (
    WidgetTester tester,
  ) async {
    // Stays pending, so the assertions below run while the composer is still
    // "open" — dismissing it then has to land on the card detail, not here.
    final Completer<bool> composer = Completer<bool>();
    await openSheet(
      tester,
      catalogue: _catalogue(),
      openComposer: (BuildContext _, ActivityCard _, String _) =>
          composer.future,
    );

    await tester.tap(find.byKey(const Key('prepare_action_invite')));
    await tester.pumpAndSettle();

    expect(composer.isCompleted, isFalse);
    expect(find.byKey(const Key('prepare_actions_sheet')), findsNothing);
    expect(find.byType(BottomSheet), findsNothing);

    composer.complete(false);
    await pendingSheet;
  });

  testWidgets('shows no export count and no "sent" marker (AC-26/AC-27)', (
    WidgetTester tester,
  ) async {
    await openSheet(tester, catalogue: _catalogue(presetCount: 7));

    final RegExp positionCounter = RegExp(r'\d+\s*(/|của|trên)\s*\d+');
    for (final String data in visibleText(tester)) {
      expect(data, isNot(matches(positionCounter)));
      for (final String forbidden in const <String>[
        'đã gửi',
        'Đã gửi',
        'lần',
        'khung',
      ]) {
        expect(data, isNot(contains(forbidden)));
      }
    }
  });

  test('the sheet registers no route and no menu entry (AC-3)', () {
    final String code = File(
      'lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart',
    ).readAsLinesSync().where((String line) => !line.trimLeft().startsWith('//')).join('\n');

    for (final String forbidden in const <String>[
      'MaterialPageRoute',
      'CupertinoPageRoute',
      'Navigator.push',
      'routes:',
      'onGenerateRoute',
      'BottomNavigationBarItem',
      'PopupMenuItem',
    ]) {
      expect(code, isNot(contains(forbidden)));
    }
  });

  testWidgets('captures the implemented sheet for the visual fidelity gate', (
    WidgetTester tester,
  ) async {
    await openSheet(tester, catalogue: _catalogue());

    await _capture(tester, 'implemented-11-chuan-bi-chon-hanh-dong-ios.png');
  });
}

/// `toImage`/`toByteData` complete on the real engine, not on the fake async
/// clock a `testWidgets` body runs under, so the capture has to leave that
/// clock via `runAsync` or it never returns.
Future<void> _capture(WidgetTester tester, String fileName) async {
  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureKey)) as RenderRepaintBoundary;
  final ByteData? png = await tester.runAsync<ByteData?>(() async {
    final ui.Image image = await boundary.toImage();
    final ByteData? bytes = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    return bytes;
  });
  expect(png, isNotNull);
  final Directory dir = Directory(_visualFidelityDir);
  dir.createSync(recursive: true);
  File(
    '${dir.path}/$fileName',
  ).writeAsBytesSync(png!.buffer.asUint8List(), flush: true);
}
