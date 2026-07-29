import 'dart:math' as math;

import 'package:cupid_mobile/design_system/theme/cupid_platform.dart';
import 'package:cupid_mobile/design_system/tokens/cupid_color_tokens.dart';
import 'package:cupid_mobile/design_system/tokens/cupid_platform_tokens.dart';
import 'package:cupid_mobile/design_system/tokens/cupid_spacing.dart';
import 'package:cupid_mobile/design_system/tokens/cupid_typography_tokens.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// WCAG relative luminance: linearize an sRGB channel (0.0-1.0).
double _linearize(double channel) {
  return channel <= 0.03928
      ? channel / 12.92
      : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
}

/// WCAG relative luminance of [color].
double _relativeLuminance(Color color) {
  final double r = _linearize(color.r);
  final double g = _linearize(color.g);
  final double b = _linearize(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// WCAG contrast ratio between two opaque colors.
double _contrastRatio(Color a, Color b) {
  final double la = _relativeLuminance(a);
  final double lb = _relativeLuminance(b);
  final double lighter = math.max(la, lb);
  final double darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('contrast tripwire (ADR-004b)', () {
    const CupidColorTokens dark = CupidColorTokens.dark();
    const CupidColorTokens light = CupidColorTokens.light();

    test(
      'light colorAccentPink on colorSurface is AA-fail for small text '
      'but AA-pass for large text/icons (>=3.0, <4.5)',
      () {
        final double ratio = _contrastRatio(
          light.colorAccentPink,
          light.colorSurface,
        );
        expect(ratio, greaterThanOrEqualTo(3.0));
        expect(ratio, lessThan(4.5));
      },
    );

    test('dark colorAccentPink on colorSurface passes AA (>=4.5)', () {
      final double ratio = _contrastRatio(
        dark.colorAccentPink,
        dark.colorSurface,
      );
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('dark colorText on colorBackground passes AA (>=4.5)', () {
      final double ratio = _contrastRatio(
        dark.colorText,
        dark.colorBackground,
      );
      expect(ratio, greaterThanOrEqualTo(4.5));
    });

    test('light colorText on colorBackground passes AA (>=4.5)', () {
      final double ratio = _contrastRatio(
        light.colorText,
        light.colorBackground,
      );
      expect(ratio, greaterThanOrEqualTo(4.5));
    });
  });

  group('token completeness (Required checks)', () {
    test('every field of .dark()/.light()/.ios()/.material() is non-null', () {
      const CupidPlatformTokens ios = CupidPlatformTokens.ios();
      const CupidPlatformTokens material = CupidPlatformTokens.material();
      const CupidColorTokens dark = CupidColorTokens.dark();
      const CupidColorTokens light = CupidColorTokens.light();

      // uiFontFamily is intentionally nullable and is `null` by design on
      // iOS (falls back to the host OS default); Material must be non-null.
      expect(ios.uiFontFamily, isNull);
      expect(material.uiFontFamily, isNotNull);
      expect(ios.elevationShadow, isNotEmpty);
      expect(material.elevationShadow, isNotEmpty);

      expect(dark.colorBackground, isNotNull);
      expect(dark.colorSurface, isNotNull);
      expect(dark.glowShadow, isNotEmpty);
      expect(dark.skyGradient, isNotEmpty);
      expect(dark.gradientDream.colors, isNotEmpty);
      expect(dark.gradientHot.colors, isNotEmpty);

      expect(light.colorBackground, isNotNull);
      expect(light.colorSurface, isNotNull);
      expect(light.glowShadow, isNotEmpty);
      expect(light.skyGradient, isNotEmpty);
      expect(light.gradientDream.colors, isNotEmpty);
      expect(light.gradientHot.colors, isNotEmpty);

      final CupidTypographyTokens iosType =
          CupidTypographyTokens.forPlatform(CupidPlatform.ios);
      final CupidTypographyTokens materialType =
          CupidTypographyTokens.forPlatform(CupidPlatform.material);
      for (final CupidTypographyTokens type in <CupidTypographyTokens>[
        iosType,
        materialType,
      ]) {
        expect(type.display, isNotNull);
        expect(type.cardTitle, isNotNull);
        expect(type.body, isNotNull);
        expect(type.caption, isNotNull);
        expect(type.labelMono, isNotNull);
      }

      expect(CupidSpacing.xs, 4);
      expect(CupidSpacing.sm, 8);
      expect(CupidSpacing.md, 16);
      expect(CupidSpacing.lg, 24);
      expect(CupidSpacing.xl, 32);
      expect(CupidSpacing.xxl, 48);
    });
  });

  group('copyWith and lerp (all 3 extensions)', () {
    test('CupidPlatformTokens.lerp at t=0 and t=1 returns the endpoints', () {
      const CupidPlatformTokens ios = CupidPlatformTokens.ios();
      const CupidPlatformTokens material = CupidPlatformTokens.material();

      final CupidPlatformTokens atZero = ios.lerp(material, 0);
      final CupidPlatformTokens atOne = ios.lerp(material, 1);

      expect(atZero.radiusCard, ios.radiusCard);
      expect(atZero.tapTarget, ios.tapTarget);
      expect(atOne.radiusCard, material.radiusCard);
      expect(atOne.tapTarget, material.tapTarget);
    });

    test('CupidColorTokens.lerp at t=0 and t=1 returns the endpoints', () {
      const CupidColorTokens dark = CupidColorTokens.dark();
      const CupidColorTokens light = CupidColorTokens.light();

      final CupidColorTokens atZero = dark.lerp(light, 0);
      final CupidColorTokens atOne = dark.lerp(light, 1);

      expect(atZero.colorBackground, dark.colorBackground);
      expect(atZero.colorAccentPink, dark.colorAccentPink);
      expect(atOne.colorBackground, light.colorBackground);
      expect(atOne.colorAccentPink, light.colorAccentPink);
    });

    test('CupidTypographyTokens.lerp at t=0 and t=1 returns the endpoints', () {
      final CupidTypographyTokens ios = CupidTypographyTokens.forPlatform(
        CupidPlatform.ios,
      );
      final CupidTypographyTokens material = CupidTypographyTokens.forPlatform(
        CupidPlatform.material,
      );

      final CupidTypographyTokens atZero = ios.lerp(material, 0);
      final CupidTypographyTokens atOne = ios.lerp(material, 1);

      expect(atZero.display.fontSize, ios.display.fontSize);
      expect(atOne.display.fontSize, material.display.fontSize);
    });

    test('copyWith overrides only the given fields', () {
      const CupidPlatformTokens ios = CupidPlatformTokens.ios();
      final CupidPlatformTokens copy = ios.copyWith(radiusCard: 10);
      expect(copy.radiusCard, 10);
      expect(copy.radiusButton, ios.radiusButton);
    });
  });

  group('CupidPlatformOverride', () {
    testWidgets('lets a test render either platform on one device', (
      WidgetTester tester,
    ) async {
      late CupidPlatform resolvedIos;
      late CupidPlatform resolvedMaterial;

      await tester.pumpWidget(
        CupidPlatformOverride(
          platform: CupidPlatform.ios,
          child: Builder(
            builder: (BuildContext context) {
              resolvedIos = CupidPlatform.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolvedIos, CupidPlatform.ios);

      await tester.pumpWidget(
        CupidPlatformOverride(
          platform: CupidPlatform.material,
          child: Builder(
            builder: (BuildContext context) {
              resolvedMaterial = CupidPlatform.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      expect(resolvedMaterial, CupidPlatform.material);
    });
  });
}
