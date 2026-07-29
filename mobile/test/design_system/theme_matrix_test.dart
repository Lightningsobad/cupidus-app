import 'dart:io';

import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const List<CupidPlatform> platforms = <CupidPlatform>[
    CupidPlatform.ios,
    CupidPlatform.material,
  ];
  const List<Brightness> brightnesses = <Brightness>[
    Brightness.dark,
    Brightness.light,
  ];

  group('4-combination matrix (AC 1)', () {
    for (final CupidPlatform platform in platforms) {
      for (final Brightness brightness in brightnesses) {
        test('$platform x $brightness resolves all 3 extensions', () {
          final ThemeData theme = buildCupidTheme(
            platform: platform,
            brightness: brightness,
          );

          expect(theme.extension<CupidPlatformTokens>(), isNotNull);
          expect(theme.extension<CupidColorTokens>(), isNotNull);
          expect(theme.extension<CupidTypographyTokens>(), isNotNull);
          expect(theme.brightness, brightness);
        });
      }
    }
  });

  test('platform tokens differ between ios and material', () {
    final ThemeData iosTheme = buildCupidTheme(
      platform: CupidPlatform.ios,
      brightness: Brightness.dark,
    );
    final ThemeData materialTheme = buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    );

    final CupidPlatformTokens iosTokens = iosTheme
        .extension<CupidPlatformTokens>()!;
    final CupidPlatformTokens materialTokens = materialTheme
        .extension<CupidPlatformTokens>()!;

    expect(iosTokens.radiusCard, isNot(materialTokens.radiusCard));
    expect(iosTokens.tapTarget, isNot(materialTokens.tapTarget));
    expect(iosTokens.uiFontFamily, isNull);
    expect(materialTokens.uiFontFamily, 'Roboto');
  });

  test('color tokens differ between dark and light', () {
    final ThemeData darkTheme = buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    );
    final ThemeData lightTheme = buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.light,
    );

    final CupidColorTokens darkTokens = darkTheme
        .extension<CupidColorTokens>()!;
    final CupidColorTokens lightTokens = lightTheme
        .extension<CupidColorTokens>()!;

    expect(darkTokens.colorBackground, isNot(lightTokens.colorBackground));
    expect(darkTokens.colorSurface, isNot(lightTokens.colorSurface));
  });

  group('Required checks', () {
    test('body text style picks up the platform uiFontFamily', () {
      final ThemeData iosTheme = buildCupidTheme(
        platform: CupidPlatform.ios,
        brightness: Brightness.dark,
      );
      final ThemeData materialTheme = buildCupidTheme(
        platform: CupidPlatform.material,
        brightness: Brightness.dark,
      );

      final CupidTypographyTokens iosType = iosTheme
          .extension<CupidTypographyTokens>()!;
      final CupidTypographyTokens materialType = materialTheme
          .extension<CupidTypographyTokens>()!;
      final CupidPlatformTokens iosPlatform = iosTheme
          .extension<CupidPlatformTokens>()!;
      final CupidPlatformTokens materialPlatform = materialTheme
          .extension<CupidPlatformTokens>()!;

      expect(iosType.body.fontFamily, iosPlatform.uiFontFamily);
      expect(materialType.body.fontFamily, materialPlatform.uiFontFamily);
      expect(materialType.body.fontFamily, 'Roboto');
    });

    test('declared font assets exist on disk', () {
      const List<String> assetPaths = <String>[
        'assets/fonts/Nunito-Variable.ttf',
        'assets/fonts/Roboto-Variable.ttf',
        'assets/fonts/RobotoMono-Variable.ttf',
        'assets/fonts/MaterialSymbolsRounded-Variable.ttf',
      ];
      for (final String path in assetPaths) {
        expect(
          File(path).existsSync(),
          isTrue,
          reason: '$path is declared in pubspec.yaml but missing on disk',
        );
      }
    });
  });

  group('CupidThemeContext accessors', () {
    testWidgets('context.cupidColors/cupidPlatform/cupidType resolve', (
      tester,
    ) async {
      late CupidColorTokens colors;
      late CupidPlatformTokens platformTokens;
      late CupidTypographyTokens typeTokens;

      await tester.pumpWidget(
        MaterialApp(
          theme: buildCupidTheme(
            platform: CupidPlatform.material,
            brightness: Brightness.dark,
          ),
          home: Builder(
            builder: (BuildContext context) {
              colors = context.cupidColors;
              platformTokens = context.cupidPlatform;
              typeTokens = context.cupidType;
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(colors, isNotNull);
      expect(platformTokens, isNotNull);
      expect(typeTokens, isNotNull);
    });
  });
}
