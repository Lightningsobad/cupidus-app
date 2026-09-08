import 'dart:io';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_card_repository.dart';
import 'package:cupid_mobile/features/activity_cards/domain/activity_type.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/screens/activity_card_detail_screen.dart';
import 'package:cupid_mobile/features/activity_cards/presentation/widgets/activity_card_tile.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rendered-evidence capture for the per-story visual fidelity gate. Off by
/// default so the scoped suite stays hermetic; enable with
/// `flutter test test/features/activity_cards/activity_card_detail_screen_test.dart
/// --dart-define=CAPTURE_VISUALS=true`.
///
/// A widget-tree capture rather than a device screenshot, so the frame is
/// pinned to `_iosReferenceViewport` and compares against the design PNG
/// without rescaling. (Since B-1 the screen is reachable from the hub, but
/// driving it through navigation would not give the capture a fixed frame.)
const bool kCaptureVisuals = bool.fromEnvironment('CAPTURE_VISUALS');

/// Exactly the frame the `design-reference-*-ios.png` pair was rendered at, so
/// the PNGs compare without rescaling either side.
const Size _iosReferenceViewport = Size(415, 900);

const String _visualEvidenceDir =
    '../data/requirements/REQ-016_solo_stage1_relationship_assistant/'
    'STORY-001_activity_card_hub/visual-fidelity';

final GlobalKey _captureBoundaryKey = GlobalKey();

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

ActivityCard _card(ActivityCardStatus status) {
  final DateTime now = DateTime(2026, 9, 8);
  return ActivityCard(
    id: 'card-1',
    ownerKey: 'owner-1',
    title: 'Cà phê sách Hào Nam',
    status: status,
    origin: ActivityCardOrigin.manual,
    activityType: ActivityType.dining,
    scheduledOn: status == ActivityCardStatus.idea ? null : '2026-10-01',
    priceVnd: 120000,
    distanceKm: 3.5,
    needsBooking: false,
    indoorOutdoor: ActivityCardIndoorOutdoor.indoor,
    note: 'Quán nhỏ, có kệ sách cũ ở tầng hai.',
    sourceLink: 'https://maps.app/hao-nam',
    invited: status != ActivityCardStatus.idea,
    replyState: ActivityCardReplyState.answered,
    createdAt: now,
    updatedAt: now,
  );
}

Widget _host(Widget child, {CupidPlatform platform = CupidPlatform.material}) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildCupidTheme(platform: platform, brightness: Brightness.dark),
      locale: const Locale('vi'),
      localizationsDelegates: AppL10n.localizationsDelegates,
      supportedLocales: AppL10n.supportedLocales,
      home: CupidPlatformOverride(platform: platform, child: child),
    );

/// Keyed by status so pumping a second status rebuilds the screen from
/// scratch. Without the key the element tree is reused, the `BlocProvider`
/// keeps the first card, and the assertion silently re-checks status one.
Widget _detail(ActivityCardStatus status) => ActivityCardDetailScreen(
      key: ValueKey<ActivityCardStatus>(status),
      card: _card(status),
      repository: _StubRepository(),
    );

/// The whole detail screen at once, so a CTA at the bottom is hit-testable
/// without a scroll step in the middle of the assertion.
void _useTallViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(415, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// D-18: A4 words its CTA for this screen instead of using the fixed SC-4
/// label. Kept here verbatim so a wording change has to be made twice.
const Map<ActivityCardStatus, String> _screenCtaText =
    <ActivityCardStatus, String>{
  ActivityCardStatus.idea: 'Chốt ngày đi thôi',
  ActivityCardStatus.scheduled: 'Chuẩn bị cho tươm tất',
  ActivityCardStatus.done: 'Ghi lại buổi đó đi',
  ActivityCardStatus.memory: 'Đọc lại · rủ đi lần nữa',
};

/// D-19: the single secondary line under the CTA, on this screen only.
const Map<ActivityCardStatus, String> _screenSecondaryText =
    <ActivityCardStatus, String>{
  ActivityCardStatus.idea: 'hoặc soạn lời rủ cho ngọt · để dành hôm khác',
  ActivityCardStatus.scheduled: 'hoặc ngó lại ghi chú · để mai tính tiếp',
  ActivityCardStatus.done: 'hoặc thêm ảnh sau · viết dần cũng được',
  ActivityCardStatus.memory: 'hoặc để yên đó · lúc nào nhớ thì mở lại',
};

List<String> _renderedText(WidgetTester tester) => <String>[
      for (final Text text in tester.widgetList<Text>(find.byType(Text)))
        if (text.data != null) text.data!.toLowerCase(),
    ];

void main() {
  group('one screen, two modes (AC-13)', () {
    testWidgets('"ghi lại" is a mode of the detail screen, not a destination',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_detail(ActivityCardStatus.done)));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('activity_card_detail')), findsOneWidget);
      expect(find.text('GHI LẠI BUỔI ĐÓ'), findsOneWidget);
      expect(find.byKey(const Key('card_detail_note_field')), findsOneWidget);
      // The record mode is the working mode, so it carries no memory frame.
      expect(find.byKey(const Key('card_detail_memory_photo')), findsNothing);
    });

    testWidgets('"xem lại" keeps a way out, so a memory is not a dead end',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_detail(ActivityCardStatus.memory)));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('activity_card_detail')), findsOneWidget);
      expect(find.byKey(const Key('card_detail_memory_photo')), findsOneWidget);
      expect(find.text('CÂU BẠN VIẾT TỐI ĐÓ'), findsOneWidget);

      // Both exits are on the same screen: back down the lifecycle, or delete.
      expect(
        find.byKey(const Key('card_detail_change_status_row')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('card_detail_delete_row')), findsOneWidget);
      expect(find.text('Đọc lại · rủ đi lần nữa'), findsOneWidget);
    });
  });

  group('SC-4 · exactly one primary action', () {
    testWidgets('every status shows one CTA, worded for this screen (D-18)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      for (final MapEntry<ActivityCardStatus, String> expected
          in _screenCtaText.entries) {
        await tester.pumpWidget(_host(_detail(expected.key)));
        await tester.pumpAndSettle();

        final Finder cta = find.byKey(const Key('card_detail_primary_action'));
        expect(cta, findsOneWidget, reason: 'status ${expected.key.wireValue}');

        expect(
          find.descendant(of: cta, matching: find.text(expected.value)),
          findsOneWidget,
          reason: 'status ${expected.key.wireValue}',
        );

        // D-18 loosens only this screen: the fixed SC-4 label the P4 tile
        // still renders must no longer be the text on A4's CTA.
        final BuildContext context = tester.element(cta);
        expect(
          find.descendant(
            of: cta,
            matching: find.text(
              activityPrimaryActionLabel(
                context,
                primaryActionFor(expected.key),
              ),
            ),
          ),
          findsNothing,
          reason: 'status ${expected.key.wireValue}',
        );
      }
    });

    testWidgets('the one secondary line sits below the CTA, inert (D-19)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      for (final MapEntry<ActivityCardStatus, String> expected
          in _screenSecondaryText.entries) {
        await tester.pumpWidget(_host(_detail(expected.key)));
        await tester.pumpAndSettle();

        final Finder secondary =
            find.byKey(const Key('card_detail_secondary_line'));
        expect(
          secondary,
          findsOneWidget,
          reason: 'status ${expected.key.wireValue}',
        );
        expect(
          tester.widget<Text>(secondary).data,
          expected.value,
          reason: 'status ${expected.key.wireValue}',
        );

        // Structurally distinct: it is not inside the CTA, and it is below it.
        final Finder cta = find.byKey(const Key('card_detail_primary_action'));
        expect(
          find.descendant(of: cta, matching: secondary),
          findsNothing,
          reason: 'status ${expected.key.wireValue}',
        );
        expect(
          tester.getTopLeft(secondary).dy,
          greaterThan(tester.getBottomLeft(cta).dy - 1),
          reason: 'status ${expected.key.wireValue}',
        );

        // Visually distinct: no CTA pill, and not a second tappable action.
        expect(
          find.ancestor(of: secondary, matching: find.byType(GestureDetector)),
          findsNothing,
          reason: 'status ${expected.key.wireValue}',
        );
        expect(
          tester.widget<Text>(secondary).style?.fontWeight,
          isNot(FontWeight.w700),
          reason: 'status ${expected.key.wireValue}',
        );
      }
    });

    testWidgets('the Mới nghĩ ra CTA opens a date picker (AC-12)',
        (WidgetTester tester) async {
      _useTallViewport(tester);
      await tester.pumpWidget(_host(_detail(ActivityCardStatus.idea)));
      await tester.pumpAndSettle();

      final Finder cta = find.byKey(const Key('card_detail_primary_action'));
      await tester.tap(cta);
      await tester.pumpAndSettle();

      expect(find.byType(DatePickerDialog), findsOneWidget);
    });
  });

  group('AC-18/AC-19 · nothing about the other person', () {
    testWidgets('no behaviour metric and no verdict in any mode',
        (WidgetTester tester) async {
      // Every phrase `ux/uiux-spec.md` §7 rules out, plus the scoring and
      // streak vocabulary AC-19/AC-20 rule out. This is a copy gate: the
      // schema already has no column to feed any of them.
      const List<String> forbidden = <String>[
        'đã xem',
        'đã đọc',
        'lần mở',
        'lượt mở',
        'lượt xem',
        'trả lời sau',
        'tốc độ trả lời',
        'tỷ lệ',
        'điểm',
        'xếp hạng',
        'chuỗi ngày',
        'streak',
        'huy hiệu',
        'lần cuối',
        'online',
      ];

      for (final ActivityCardStatus status in ActivityCardStatus.values) {
        await tester.pumpWidget(_host(_detail(status)));
        await tester.pumpAndSettle();

        final List<String> rendered = _renderedText(tester);
        for (final String phrase in forbidden) {
          expect(
            rendered.where((String line) => line.contains(phrase)),
            isEmpty,
            reason:
                '"$phrase" appeared in ${status.wireValue} mode; the detail '
                'screen may not measure or judge the other person',
          );
        }
      }
    });

    testWidgets('the reply flag carries no time label',
        (WidgetTester tester) async {
      await tester.pumpWidget(_host(_detail(ActivityCardStatus.scheduled)));
      await tester.pumpAndSettle();

      final Finder chip = find.byKey(const Key('card_detail_reply_chip'));
      await tester.ensureVisible(chip);
      expect(chip, findsOneWidget);
      expect(
        find.descendant(of: chip, matching: find.byType(Text)),
        findsOneWidget,
      );
      expect(
        tester.widget<Text>(
          find.descendant(of: chip, matching: find.byType(Text)),
        ).data,
        'Đã trả lời',
      );
    });
  });

  testWidgets(
    'renders the visual-fidelity evidence frames',
    (WidgetTester tester) async {
      tester.view.physicalSize = _iosReferenceViewport;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await _loadDesignFonts(tester);

      const Map<ActivityCardStatus, String> pillLabel =
          <ActivityCardStatus, String>{
        ActivityCardStatus.idea: 'MỚI NGHĨ RA',
        ActivityCardStatus.done: 'ĐÃ ĐI RỒI',
        ActivityCardStatus.memory: 'ĐÃ THÀNH KỶ NIỆM',
      };

      for (final MapEntry<ActivityCardStatus, String> frame
          in <ActivityCardStatus, String>{
        ActivityCardStatus.idea: 'implemented-chi-tiet-the-moi-nghi-ra-ios.png',
        ActivityCardStatus.done:
            'implemented-chi-tiet-the-moi-nghi-ra-ios-ghi-lai.png',
        ActivityCardStatus.memory: 'implemented-the-da-thanh-ky-niem-ios.png',
      }.entries) {
        await tester.pumpWidget(
          RepaintBoundary(
            key: _captureBoundaryKey,
            child: _host(_detail(frame.key), platform: CupidPlatform.ios),
          ),
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        // A frame that silently re-rendered the previous status is worse than
        // no evidence at all, so the pill is read back before the PNG is kept.
        expect(
          find.descendant(
            of: find.byKey(const Key('card_detail_status_pill')),
            matching: find.text(pillLabel[frame.key]!),
          ),
          findsOneWidget,
        );
        await _writeCapture(tester, frame.value);
      }
    },
    skip: !kCaptureVisuals,
  );
}

/// Widget tests ship no asset bundle, so the bundled variable fonts are read
/// off disk. Without this every glyph rasterizes as a fallback box and the
/// capture is worthless for typography comparison.
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

Future<void> _writeCapture(WidgetTester tester, String fileName) async {
  final RenderRepaintBoundary boundary =
      tester.renderObject(find.byKey(_captureBoundaryKey))
          as RenderRepaintBoundary;
  await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage(pixelRatio: 1);
    final ByteData? png = await image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    image.dispose();
    final File out = File('$_visualEvidenceDir/$fileName');
    out.parent.createSync(recursive: true);
    out.writeAsBytesSync(png!.buffer.asUint8List());
  });
}
