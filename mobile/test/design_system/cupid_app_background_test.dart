import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const Key _probeKey = Key('cupid_app_background_probe');

Widget _host({
  required Widget child,
  Brightness brightness = Brightness.dark,
  bool disableAnimations = false,
}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Theme(
        data: buildCupidTheme(
          platform: CupidPlatform.material,
          brightness: brightness,
        ),
        child: RepaintBoundary(
          key: _probeKey,
          child: CupidAppBackground(child: child),
        ),
      ),
    ),
  );
}

CupidSkyPainter _skyPainter(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((CustomPaint paint) => paint.painter)
      .whereType<CupidSkyPainter>()
      .single;
}

Color _pixelAt(ByteData rgba, int imageWidth, int x, int y) {
  final int offset = (y * imageWidth + x) * 4;
  return Color.fromARGB(
    rgba.getUint8(offset + 3),
    rgba.getUint8(offset),
    rgba.getUint8(offset + 1),
    rgba.getUint8(offset + 2),
  );
}

void main() {
  testWidgets('renders its child', (WidgetTester tester) async {
    await tester.pumpWidget(_host(child: const Text('screen content')));

    expect(find.text('screen content'), findsOneWidget);
  });

  testWidgets('selects the sky layer set from the theme brightness', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(child: const SizedBox.shrink(), brightness: Brightness.dark),
    );
    expect(_skyPainter(tester).layers, same(CupidSkyPalette.darkLayers));

    await tester.pumpWidget(
      _host(child: const SizedBox.shrink(), brightness: Brightness.light),
    );
    expect(_skyPainter(tester).layers, same(CupidSkyPalette.lightLayers));
  });

  testWidgets('holds the stars at rest with no ticker when animations are '
      'disabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      _host(child: const SizedBox.shrink(), disableAnimations: true),
    );

    expect(tester.binding.transientCallbackCount, 0);
    expect(
      tester
          .widgetList<Opacity>(find.byType(Opacity))
          .map((Opacity opacity) => opacity.opacity),
      everyElement(CupidSkyPalette.twinkleMinOpacity),
    );
  });

  testWidgets('twinkles the stars when animations are enabled', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_host(child: const SizedBox.shrink()));
    await tester.pump(const Duration(milliseconds: 1700));

    expect(tester.binding.transientCallbackCount, greaterThan(0));
    expect(
      tester.widgetList<Opacity>(find.byType(Opacity)).first.opacity,
      greaterThan(CupidSkyPalette.twinkleMinOpacity),
    );
  });

  testWidgets('never intercepts a tap landing on a star', (
    WidgetTester tester,
  ) async {
    final CupidSkyStar star = CupidSkyPalette.stars.first;
    final Offset starCenter = Offset(
      star.leftFactor! * 800 + star.size / 2,
      star.topFactor * 600 + star.size / 2,
    );
    bool tapped = false;

    await tester.pumpWidget(
      _host(
        disableAnimations: true,
        child: Stack(
          children: <Widget>[
            Positioned(
              left: starCenter.dx - 20,
              top: starCenter.dy - 20,
              width: 40,
              height: 40,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => tapped = true,
              ),
            ),
          ],
        ),
      ),
    );
    await tester.tapAt(starCenter);

    expect(tapped, isTrue);
  });

  testWidgets('paints the wash over the flat background fill', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      _host(child: const SizedBox.shrink(), disableAnimations: true),
    );

    final RenderRepaintBoundary boundary = tester
        .renderObject<RenderRepaintBoundary>(find.byKey(_probeKey));
    late final int imageWidth;
    // Rasterizing needs real async: the fake-async test zone never completes
    // the engine's toImage future.
    final ByteData rgba = (await tester.runAsync(() async {
      final ui.Image image = await boundary.toImage();
      imageWidth = image.width;
      return (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
    }))!;

    // Under the first dark layer's ellipse (center 15%, -8%), the wash must
    // read as purple, not as the flat colorBackground fill.
    const Color flatFill = Color(0xFF171129);
    final Color washed = _pixelAt(rgba, imageWidth, 120, 10);
    expect(washed, isNot(flatFill));
    expect(washed.r, greaterThan(flatFill.r));
    expect(washed.b, greaterThan(flatFill.b));
  });
}
