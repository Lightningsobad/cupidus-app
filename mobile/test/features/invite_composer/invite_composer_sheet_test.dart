import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/core/content/content_package.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/time_of_day_slot.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_payload.dart';
import 'package:cupid_mobile/features/invite_composer/domain/invite_payload_repository.dart';
import 'package:cupid_mobile/features/invite_composer/domain/preset_catalogue.dart';
import 'package:cupid_mobile/features/invite_composer/presentation/invite_composer_cubit.dart';
import 'package:cupid_mobile/features/invite_composer/presentation/widgets/frame_chip_strip.dart';
import 'package:cupid_mobile/features/invite_composer/presentation/widgets/invite_composer_sheet.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// The design references this capture is compared against are rendered at
/// 415x900 (`visual-fidelity/design-reference-*.png`), so the implementation is
/// captured in the same frame rather than the 800x600 test default.
const Size _designFrame = Size(415, 900);

const String _visualFidelityDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-002_invite_message_composer/visual-fidelity';

final GlobalKey _captureKey = GlobalKey();

ActivityCard _card({bool invited = false}) => ActivityCard(
  id: 'card-1',
  ownerKey: 'owner-1',
  title: 'xem phim Dune',
  status: ActivityCardStatus.scheduled,
  origin: ActivityCardOrigin.manual,
  scheduledOn: '2026-08-15',
  timeOfDaySlot: TimeOfDaySlot.evening,
  durationMinutes: 120,
  location: 'rạp CGV Vincom Đồng Khởi',
  invited: invited,
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

  /// Decodes in-process. The inherited implementation hands payloads over
  /// ~50 KB to a `compute` isolate, whose future never resolves under the
  /// widget-test fake clock — which would make a large pack look unloadable
  /// here for a reason that does not exist on a device.
  @override
  Future<String> loadString(String key, {bool cache = true}) async =>
      utf8.decode((await load(key)).buffer.asUint8List());

  @override
  Future<T> loadStructuredData<T>(
    String key,
    Future<T> Function(String value) parser,
  ) async => parser(await loadString(key));
}

/// Frame names and clause wording are deliberately realistic Vietnamese: the
/// capture this file writes is eyeballed for diacritic rendering, and synthetic
/// ASCII labels would hide a missing-glyph regression.
const List<(String, String)> _frames = <(String, String)>[
  ('Rủ nhẹ nhàng', 'Rảnh không, mình đi {activity} nhé?'),
  ('Kiểu nghiêm túc', 'Trân trọng kính mời bạn đi {activity}.'),
  ('Kiểu lầy lội', 'Ê, {activity} không, đi liền cho nóng!'),
  ('Kiểu ngắn gọn', '{activity}?'),
];

String _packJson({int presetCount = 4}) => jsonEncode(<String, Object?>{
  'id': 'presets.invite',
  'version': '1.0.0',
  'schema_id': presetsSchemaId,
  'locale': 'vi',
  'items': List<Map<String, Object?>>.generate(presetCount, (int index) {
    final (String frame, String opening) = _frames[index % _frames.length];
    return <String, Object?>{
      'id': 'frame.$index.v1',
      'frame': frame,
      'clauses': <Map<String, Object?>>[
        <String, Object?>{
          'text': opening,
          'requires': <String>['activity'],
          'targets': 'neutral',
        },
        <String, Object?>{
          'text': 'Hẹn {date} {time} ở {place}, chắc khoảng {duration}.',
          'requires': <String>['date', 'time', 'place', 'duration'],
          'targets': 'neutral',
        },
        <String, Object?>{
          'text': 'Bận thì cứ nói mình biết nha, không sao đâu.',
          'requires': <String>[],
          'targets': 'neutral',
          'role': 'decline_door',
        },
      ],
    };
  }, growable: false),
});

PresetCatalogue _catalogue({int presetCount = 4}) => PresetCatalogue(
  loader: ContentPackageLoader(
    bundle: _TestBundle(<String, String>{
      presetAssetKey(inviteCategoryId): _packJson(presetCount: presetCount),
    }),
  ),
);

class _FakePayloadRepository implements InvitePayloadRepository {
  final List<InvitePayload> saved = <InvitePayload>[];

  @override
  Future<InvitePayload> savePayload({
    required String cardId,
    required String categoryId,
    required String presetId,
    required String packVersion,
    required Map<String, String> filledValues,
    String? userEditedText,
  }) async {
    final InvitePayload payload = InvitePayload(
      id: 'payload-${saved.length}',
      cardId: cardId,
      categoryId: categoryId,
      presetId: presetId,
      packVersion: packVersion,
      filledValues: filledValues,
      userEditedText: userEditedText,
      createdAt: DateTime.utc(2026, 8, 2),
    );
    saved.add(payload);
    return payload;
  }

  @override
  Future<InvitePayload?> latestForCard(String cardId) async => null;

  @override
  Future<InvitePayload?> payloadById(String id) async => null;
}

class _FakeCardRepository implements ActivityCardRepository {
  final List<ActivityCardEdit> edits = <ActivityCardEdit>[];

  @override
  Future<int> updateCardDetails(String cardId, ActivityCardEdit edit) async {
    edits.add(edit);
    return 1;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(
    'the composer must not call ${invocation.memberName}',
  );
}

/// Loads the app's own bundled text fonts.
///
/// Without this, `flutter test` draws every glyph as a placeholder box, and a
/// capture taken that way would pass an exit-code check while showing nothing
/// legible — least of all the Vietnamese diacritics this screen is full of.
Future<void> _loadBundledFonts() async {
  const Map<String, String> families = <String, String>{
    'Roboto': 'assets/fonts/Roboto-Variable.ttf',
    'Nunito': 'assets/fonts/Nunito-Variable.ttf',
    'Roboto Mono': 'assets/fonts/RobotoMono-Variable.ttf',
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
  late _FakePayloadRepository payloads;
  late _FakeCardRepository cards;
  late List<String> shared;

  setUpAll(_loadBundledFonts);

  setUp(() {
    payloads = _FakePayloadRepository();
    cards = _FakeCardRepository();
    shared = <String>[];
  });

  InviteComposerCubit Function() cubitFactory({
    ActivityCard? card,
    int presetCount = 4,
  }) => () => InviteComposerCubit(
    card: card ?? _card(),
    categoryId: inviteCategoryId,
    catalogue: _catalogue(presetCount: presetCount),
    payloads: payloads,
    cards: cards,
    share: (String text) async => shared.add(text),
  );

  Widget host(Widget child) => RepaintBoundary(
    key: _captureKey,
    child: MaterialApp(
      // The banner would sit on top of the captured frame and read as a visual
      // delta against the design reference that does not exist in the app.
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

  /// Pumps a backdrop screen and opens the composer over it, returning the
  /// still-pending result of [showInviteComposerSheet].
  Future<Future<bool>> openSheet(
    WidgetTester tester, {
    ActivityCard? card,
    int presetCount = 4,
    PresetCatalogue? emptyCatalogue,
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

    final Future<bool> result = showInviteComposerSheet(
      hostContext,
      card ?? _card(),
      inviteCategoryId,
      createCubit: emptyCatalogue == null
          ? cubitFactory(card: card, presetCount: presetCount)
          : () => InviteComposerCubit(
              card: card ?? _card(),
              categoryId: inviteCategoryId,
              catalogue: emptyCatalogue,
              payloads: payloads,
              cards: cards,
              share: (String text) async => shared.add(text),
            ),
    );
    await tester.pumpAndSettle();
    return result;
  }

  List<String> visibleText(WidgetTester tester) => tester
      .widgetList<Text>(find.byType(Text))
      .map((Text text) => text.data ?? '')
      .where((String data) => data.isNotEmpty)
      .toList();

  testWidgets('opens with the first frame already rendered', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    expect(find.byKey(const Key('invite_composer_sheet')), findsOneWidget);
    expect(find.text('Soạn lời mời'), findsOneWidget);
    expect(find.byType(FrameChipStrip), findsOneWidget);
    expect(find.byKey(const Key('invite_frame_chip_0')), findsOneWidget);
    expect(find.byKey(const Key('invite_frame_chip_3')), findsOneWidget);
    // AC-4: activity, date and place are all already filled in, with no
    // placeholder braces left over.
    final String preview = tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(const Key('invite_composer_preview')),
            matching: find.byType(Text),
          ),
        )
        .data!;
    expect(preview, startsWith('Rảnh không, mình đi xem phim Dune nhé?'));
    expect(preview, contains('rạp CGV Vincom Đồng Khởi'));
    // The date clause survived, which it only can if `date` resolved: it
    // `requires` all four of date/time/place/duration.
    expect(preview, contains('Hẹn '));
    expect(preview, isNot(contains('{')));
    expect(preview, contains('Bận thì cứ nói mình biết nha'));
  });

  testWidgets('a pack with one frame draws one chip and no placeholder', (
    WidgetTester tester,
  ) async {
    await openSheet(tester, presetCount: 1);

    expect(find.byKey(const Key('invite_frame_chip_0')), findsOneWidget);
    expect(find.byKey(const Key('invite_frame_chip_1')), findsNothing);
  });

  testWidgets('a 200-frame pack behaves exactly like a 1-frame one (R-15b)', (
    WidgetTester tester,
  ) async {
    await openSheet(tester, presetCount: 200);

    expect(find.byKey(const Key('invite_frame_chip_0')), findsOneWidget);
    expect(find.byKey(const Key('invite_frame_chip_199')), findsOneWidget);
    expect(find.byKey(const Key('invite_composer_share')), findsOneWidget);
    for (final String data in visibleText(tester)) {
      expect(data, isNot(contains('200')));
    }

    await tester.tap(find.byKey(const Key('invite_composer_share')));
    await tester.pumpAndSettle();

    expect(payloads.saved, hasLength(1));
    expect(shared, hasLength(1));
  });

  testWidgets('tapping a chip re-renders the preview with no apply step', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    await tester.tap(find.byKey(const Key('invite_frame_chip_2')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Ê, xem phim Dune không, đi liền cho nóng!'),
      findsOneWidget,
    );
    expect(find.textContaining('Rảnh không'), findsNothing);
    expect(find.text('Áp dụng'), findsNothing);
  });

  testWidgets('tapping the preview edits it in place, not on a new screen', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    expect(find.byType(TextField), findsNothing);
    await tester.tap(find.byKey(const Key('invite_composer_preview')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key('invite_composer_preview_field')),
      findsOneWidget,
    );
    // Still the same sheet: the frame strip and the CTA never went away.
    expect(find.byType(FrameChipStrip), findsOneWidget);
    expect(find.byKey(const Key('invite_composer_share')), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('invite_composer_preview_field')),
      'Tối nay đi xem Dune nhé?',
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('invite_composer_share')));
    await tester.pumpAndSettle();

    expect(payloads.saved.single.userEditedText, 'Tối nay đi xem Dune nhé?');
    expect(shared.single, 'Tối nay đi xem Dune nhé?');
  });

  testWidgets('sharing saves the payload, marks invited, then closes', (
    WidgetTester tester,
  ) async {
    final Future<bool> result = await openSheet(tester);

    await tester.tap(find.byKey(const Key('invite_composer_share')));
    await tester.pumpAndSettle();

    expect(payloads.saved, hasLength(1));
    expect(cards.edits.single.invited, isTrue);
    expect(shared, hasLength(1));
    expect(await result, isTrue);
    expect(find.byKey(const Key('invite_composer_sheet')), findsNothing);
  });

  testWidgets('an unusable pack never opens an empty composer', (
    WidgetTester tester,
  ) async {
    final Future<bool> result = await openSheet(
      tester,
      emptyCatalogue: PresetCatalogue(
        loader: ContentPackageLoader(bundle: _TestBundle(<String, String>{})),
      ),
    );

    expect(find.byKey(const Key('invite_composer_sheet')), findsNothing);
    expect(await result, isFalse);
  });

  testWidgets('the only send affordance is the one Share Sheet CTA (AC-16)', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    expect(find.byType(CupidPrimaryButton), findsOneWidget);
    expect(find.text('Chia sẻ'), findsOneWidget);
    // No contact/phone entry and no per-channel button anywhere on the sheet.
    expect(find.byType(TextField), findsNothing);
    for (final String data in visibleText(tester)) {
      for (final String forbidden in const <String>[
        'Zalo',
        'Messenger',
        'SMS',
        'Gửi',
        'Số điện thoại',
      ]) {
        expect(
          data,
          isNot(contains(forbidden)),
          reason: 'AC-16: the sheet exports through the OS Share Sheet only',
        );
      }
    }
  });

  testWidgets('no frame count, position, or progress is shown (AC-26/AC-27)', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    // The invite body carries a `d/M` date ("15/8") that reads like an "n/m"
    // position, so it is excluded from the counter scan: AC-26/AC-27 ban a
    // count in the *chrome*, and the body is pack content the user asked for.
    final String previewText = tester
        .widget<Text>(
          find.descendant(
            of: find.byKey(const Key('invite_composer_preview')),
            matching: find.byType(Text),
          ),
        )
        .data!;
    final RegExp positionCounter = RegExp(r'\d+\s*(/|của|trên)\s*\d+');
    for (final String data in visibleText(tester)) {
      if (data != previewText) {
        expect(data, isNot(matches(positionCounter)));
      }
      for (final String forbidden in const <String>[
        'hết khung',
        'Hết khung',
        'khung cuối',
        'Còn ',
        'còn lại',
      ]) {
        expect(data, isNot(contains(forbidden)));
      }
    }
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(PageView), findsNothing);
  });

  group('phase boundary (SC-4)', () {
    test('this phase adds no route, tab, or menu entry — that is P6', () {
      for (final String path in _p5LibFiles) {
        final String code = _codeOf(path);
        for (final String forbidden in const <String>[
          'MaterialPageRoute',
          'CupertinoPageRoute',
          'Navigator.push',
          'routes:',
          'onGenerateRoute',
          'BottomNavigationBarItem',
        ]) {
          expect(
            code,
            isNot(contains(forbidden)),
            reason: '$path must not register an entry point in P5',
          );
        }
      }
    });

    test('the share call hands off and reads nothing back (R-1b/AC-19)', () {
      for (final String path in _p5LibFiles) {
        final String code = _codeOf(path);
        for (final String forbidden in const <String>[
          'ShareResult',
          'ShareResultStatus',
          'presetCount',
          'totalFrames',
        ]) {
          expect(code, isNot(contains(forbidden)), reason: 'in $path');
        }
      }
    });
  });

  testWidgets('captures the implemented sheet for the visual fidelity gate', (
    WidgetTester tester,
  ) async {
    await openSheet(tester);

    await _capture(tester, 'implemented-11-xuat-loi-moi-chon-khung-ios.png');

    await tester.tap(find.byKey(const Key('invite_composer_preview')));
    await tester.pumpAndSettle();
    await _capture(
      tester,
      'implemented-11-dien-mad-libs-xem-truoc-ios.png',
    );
  });
}

const List<String> _p5LibFiles = <String>[
  'lib/features/invite_composer/presentation/invite_composer_cubit.dart',
  'lib/features/invite_composer/presentation/widgets/invite_composer_sheet.dart',
  'lib/features/invite_composer/presentation/widgets/frame_chip_strip.dart',
];

/// File contents with `//` lines stripped, so a rule stated in prose in a doc
/// comment cannot make a source scan pass or fail by accident.
String _codeOf(String path) => File(path)
    .readAsLinesSync()
    .where((String line) => !line.trimLeft().startsWith('//'))
    .join('\n');

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
