import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/vow/presentation/screens/vow_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dark theme + `vi` locale — the only combination enabled for users (OQ5).
Widget _harness({
  bool selfVowed = false,
  bool partnerVowed = false,
  VoidCallback? onVowSigned,
  VoidCallback? onEnterDashboard,
}) {
  return MaterialApp(
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    // Mirrors the production composition root (`cupid_app.dart:58-59`): the
    // shared shell, and with it the twinkle layer, is mounted once here.
    builder: (BuildContext context, Widget? child) => RepaintBoundary(
      key: _probeKey,
      child: CupidAppBackground(child: child ?? const SizedBox.shrink()),
    ),
    home: VowScreen(
      selfVowed: selfVowed,
      partnerVowed: partnerVowed,
      selfInitial: 'M',
      partnerInitial: 'L',
      onVowSigned: onVowSigned,
      onEnterDashboard: onEnterDashboard,
    ),
  );
}

const Key _probeKey = Key('vow_star_probe');

/// The source's percentage star positions only land where the design puts them
/// on a phone-sized frame.
const Size _phoneSurface = Size(390, 844);

/// Reads one pixel of the rasterized [_probeKey] boundary. The caller pins
/// `devicePixelRatio` to 1 so logical coordinates index the image directly.
Future<Color> _probePixel(WidgetTester tester, Offset at) async {
  final RenderRepaintBoundary boundary = tester
      .renderObject<RenderRepaintBoundary>(find.byKey(_probeKey));
  late final int imageWidth;
  // Rasterizing needs real async: the fake-async test zone never completes the
  // engine's toImage future.
  final ByteData rgba = (await tester.runAsync(() async {
    final ui.Image image = await boundary.toImage();
    imageWidth = image.width;
    return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  }))!;

  final int offset = (at.dy.round() * imageWidth + at.dx.round()) * 4;
  return Color.fromARGB(
    rgba.getUint8(offset + 3),
    rgba.getUint8(offset),
    rgba.getUint8(offset + 1),
    rgba.getUint8(offset + 2),
  );
}

Finder _discOf(Key key) =>
    find.descendant(of: find.byKey(key), matching: find.byType(Container));

void main() {
  testWidgets('AC1: renders the design source header block in vi', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.text('FINGERPRINT VOW'), findsOneWidget);
    expect(find.text('Cùng đặt ngón tay\nvào một lúc'), findsOneWidget);
    expect(find.textContaining('Vân tay xử lý ngay trên máy.'), findsOneWidget);
  });

  testWidgets('AC4 idle: fingerprint hold target, both partners waiting', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.pump();

    expect(find.byKey(const Key('vow_hold_target')), findsOneWidget);
    expect(find.byKey(const Key('vow_signed_disc')), findsNothing);
    expect(find.text('đang đợi'), findsNWidgets(2));
    expect(find.text('sẵn sàng'), findsNothing);
    expect(find.byKey(const Key('vow_enter_dashboard_cta')), findsNothing);
  });

  testWidgets('AC3: a full 1.5s dwell signs the vow, a short one does not', (
    WidgetTester tester,
  ) async {
    int signed = 0;
    await tester.pumpWidget(_harness(onVowSigned: () => signed++));
    await tester.pump();

    final TestGesture shortHold = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('vow_hold_target'))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await shortHold.up();
    await tester.pump();

    expect(signed, 0);
    expect(find.byKey(const Key('vow_signed_disc')), findsNothing);

    final TestGesture fullHold = await tester.startGesture(
      tester.getCenter(find.byKey(const Key('vow_hold_target'))),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1600));
    await fullHold.up();
    await tester.pump();

    expect(signed, 1);
    expect(find.byKey(const Key('vow_signed_disc')), findsOneWidget);
    expect(find.byKey(const Key('vow_hold_target')), findsNothing);
  });

  testWidgets('AC4 first-partner-signed: check disc, no dashboard CTA, but solo CTA available', (
    WidgetTester tester,
  ) async {
    int entered = 0;
    await tester.pumpWidget(_harness(selfVowed: true, onEnterDashboard: () => entered++));
    await tester.pump();

    expect(find.byKey(const Key('vow_signed_disc')), findsOneWidget);
    expect(find.text('sẵn sàng'), findsOneWidget);
    expect(find.text('đang đợi'), findsOneWidget);
    expect(find.byKey(const Key('vow_enter_dashboard_cta')), findsNothing);
    expect(find.byKey(const Key('vow_enter_dashboard_solo_cta')), findsOneWidget);

    await tester.tap(find.byKey(const Key('vow_enter_dashboard_solo_cta')));
    await tester.pump();
    expect(entered, 1);
  });

  testWidgets('AC4 both-signed: both ready and the dashboard CTA appears', (
    WidgetTester tester,
  ) async {
    int entered = 0;
    await tester.pumpWidget(
      _harness(
        selfVowed: true,
        partnerVowed: true,
        onEnterDashboard: () => entered++,
      ),
    );
    await tester.pump();

    expect(find.text('sẵn sàng'), findsNWidgets(2));
    expect(find.text('Vào Dashboard'), findsOneWidget);

    await tester.tap(find.byKey(const Key('vow_enter_dashboard_cta')));
    await tester.pump();
    expect(entered, 1);
  });

  testWidgets('AC1: signed disc uses the design mint fill and 2px border', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(selfVowed: true));
    await tester.pump(const Duration(milliseconds: 600));

    final Container disc = tester.widget<Container>(
      _discOf(const Key('vow_signed_disc')).first,
    );
    final BoxDecoration decoration = disc.decoration! as BoxDecoration;
    const Color mint = Color(0xFF79E2CD);

    expect(decoration.shape, BoxShape.circle);
    expect(decoration.color, mint.withValues(alpha: 0.16));
    expect(decoration.border!.top.color, mint);
    expect(decoration.border!.top.width, 2);
  });

  testWidgets('AC1: the shared twinkle star field paints over the screen', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = _phoneSurface;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_harness());
    // Star 2 is the probe, as in `welcome_screen_test.dart` and the STORY-060
    // `contract` test: its twinkle peak is at `delay + period / 2` = 800ms +
    // 2300ms. The ticker never settles, so this is pumped, never settled.
    await tester.pump(const Duration(milliseconds: 3100));

    final CupidSkyStar star = CupidSkyPalette.stars[1];
    final Offset starCenter = Offset(
      _phoneSurface.width - star.rightFactor! * _phoneSurface.width -
          star.size / 2,
      star.topFactor * _phoneSurface.height + star.size / 2,
    );

    // At its peak the star is fully opaque, so the pixel is its own token
    // colour rather than a blend.
    final Color onStar = await _probePixel(tester, starCenter);
    expect(onStar.r, closeTo(star.color.r, 0.15));
    expect(onStar.g, closeTo(star.color.g, 0.15));
    expect(onStar.b, closeTo(star.color.b, 0.15));

    final Color control = await _probePixel(
      tester,
      starCenter + const Offset(40, 0),
    );
    expect(
      control.g,
      isNot(closeTo(star.color.g, 0.02)),
      reason:
          "the control pixel must be vow's own backdrop, otherwise the probe "
          'proves nothing about paint order',
    );

    // The source marks the particles `pointer-events:none`, so the layer that
    // now sits above the whole route must not intercept a tap landing on a
    // star; the hold target below it stays reachable.
    expect(
      tester
          .hitTestOnBinding(starCenter)
          .path
          .map((HitTestEntry entry) => entry.target),
      contains(tester.renderObject(find.byType(VowScreen))),
      reason: 'the particle layer swallowed a tap landing on a star',
    );
    await tester.tap(find.byKey(const Key('vow_hold_target')));
    await tester.pump();
  });

  testWidgets('AC3: the hold target exposes an accessible activation', (
    WidgetTester tester,
  ) async {
    int signed = 0;
    await tester.pumpWidget(_harness(onVowSigned: () => signed++));
    await tester.pump();

    final SemanticsNode node = tester.getSemantics(
      find.byKey(const Key('vow_hold_target')),
    );
    expect(node.label, 'Giữ 1,5 giây để ký Fingerprint Vow');

    final SemanticsHandle handle = tester.ensureSemantics();
    final PipelineOwner owner = tester
        .element(find.byKey(const Key('vow_hold_target')))
        .renderObject!
        .owner!;
    owner.semanticsOwner!.performAction(node.id, SemanticsAction.tap);
    await tester.pump();

    expect(signed, 1);
    expect(find.byKey(const Key('vow_signed_disc')), findsOneWidget);
    handle.dispose();
  });
}
