import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CupidLogo Widget Tests', () {
    testWidgets('renders default standard CupidLogo', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Center(child: CupidLogo()))),
      );

      expect(find.byType(CupidLogo), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      final Size size = tester.getSize(find.byType(CupidLogo));
      expect(size.width, 48.0);
      expect(size.height, 48.0);
    });

    testWidgets('renders all CupidLogo variants cleanly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Column(
              children: <Widget>[
                CupidLogo(
                  size: 64,
                  variant: CupidLogoVariant.standard,
                  key: Key('logo_standard'),
                ),
                CupidLogo(
                  size: 18,
                  variant: CupidLogoVariant.small,
                  key: Key('logo_small'),
                ),
                CupidLogo(
                  size: 72,
                  variant: CupidLogoVariant.discOnly,
                  key: Key('logo_disc_only'),
                ),
                CupidLogo(
                  size: 50,
                  variant: CupidLogoVariant.monochrome,
                  key: Key('logo_monochrome'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('logo_standard')), findsOneWidget);
      expect(find.byKey(const Key('logo_small')), findsOneWidget);
      expect(find.byKey(const Key('logo_disc_only')), findsOneWidget);
      expect(find.byKey(const Key('logo_monochrome')), findsOneWidget);
    });

    testWidgets('supports custom colors and animationProgress', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CupidLogo(
              size: 80,
              discColor: Color(0xFFFF7FB6),
              orbitColor: Color(0xFFB78CF5),
              animationProgress: 0.5,
            ),
          ),
        ),
      );

      expect(find.byType(CupidLogo), findsOneWidget);

      final CustomPaint customPaint = tester.widget(
        find.descendant(
          of: find.byType(CupidLogo),
          matching: find.byType(CustomPaint),
        ),
      );

      final CupidLogoPainter painter = customPaint.painter! as CupidLogoPainter;
      expect(painter.animationProgress, 0.5);
      expect(painter.discColor, const Color(0xFFFF7FB6));
      expect(painter.orbitColor, const Color(0xFFB78CF5));
    });

    test('CupidLogoPainter shouldRepaint reflects property changes', () {
      const CupidLogoPainter painter1 = CupidLogoPainter(
        variant: CupidLogoVariant.standard,
        discColor: Color(0xFFFF7FB6),
        orbitColor: Color(0xFFB78CF5),
        monochromeColor: Color(0xFFF7EEFB),
        animationProgress: 0.0,
      );

      const CupidLogoPainter painter2 = CupidLogoPainter(
        variant: CupidLogoVariant.standard,
        discColor: Color(0xFFFF7FB6),
        orbitColor: Color(0xFFB78CF5),
        monochromeColor: Color(0xFFF7EEFB),
        animationProgress: 0.5,
      );

      const CupidLogoPainter painter3 = CupidLogoPainter(
        variant: CupidLogoVariant.small,
        discColor: Color(0xFFFF7FB6),
        orbitColor: Color(0xFFB78CF5),
        monochromeColor: Color(0xFFF7EEFB),
        animationProgress: 0.0,
      );

      expect(painter2.shouldRepaint(painter1), isTrue);
      expect(painter3.shouldRepaint(painter1), isTrue);
      expect(painter1.shouldRepaint(painter1), isFalse);
    });
  });
}
