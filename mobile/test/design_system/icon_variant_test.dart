import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CupidIconVariant axis mapping (ux/uiux-spec.md section 2)', () {
    test('filled = FILL 1 / wght 400 / GRAD 0 / opsz 24', () {
      expect(CupidIconVariant.filled.fill, 1);
      expect(CupidIconVariant.filled.weight, 400);
      expect(CupidIconVariant.filled.grade, 0);
      expect(CupidIconVariant.filled.opticalSize, 24);
    });

    test('line = FILL 0 / wght 350 / GRAD 0 / opsz 24', () {
      expect(CupidIconVariant.line.fill, 0);
      expect(CupidIconVariant.line.weight, 350);
      expect(CupidIconVariant.line.grade, 0);
      expect(CupidIconVariant.line.opticalSize, 24);
    });

    test('soft = FILL 1 / wght 300 / GRAD -25 / opsz 24', () {
      expect(CupidIconVariant.soft.fill, 1);
      expect(CupidIconVariant.soft.weight, 300);
      expect(CupidIconVariant.soft.grade, -25);
      expect(CupidIconVariant.soft.opticalSize, 24);
    });
  });

  group('Required checks', () {
    const IconData testIcon = IconData(
      0xe000,
      fontFamily: CupidIcons.fontFamily,
    );

    testWidgets('CupidIcon renders inside a buildCupidTheme wrapper without a missing-extension assertion', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCupidTheme(
            platform: CupidPlatform.material,
            brightness: Brightness.dark,
          ),
          home: const Scaffold(body: CupidIcon(testIcon)),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.byType(CupidIcon), findsOneWidget);
    });

    testWidgets('CupidIcon default color derives from context.cupidColors, not a literal', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildCupidTheme(
            platform: CupidPlatform.material,
            brightness: Brightness.dark,
          ),
          home: const Scaffold(body: CupidIcon(testIcon)),
        ),
      );

      final Icon renderedIcon = tester.widget<Icon>(find.byType(Icon));
      const CupidColorTokens dark = CupidColorTokens.dark();
      expect(renderedIcon.color, dark.colorText);
    });
  });
}
