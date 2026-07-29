import 'package:cupid_mobile/app/cupid_app.dart';
import 'package:cupid_mobile/core/config/cupid_feature_flags.dart';
import 'package:cupid_mobile/design_system/theme/cupid_platform.dart';
import 'package:cupid_mobile/design_system/theme/cupid_theme.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('CupidFeatureFlags default to false with no --dart-define supplied', () {
    expect(CupidFeatureFlags.enableLightTheme, isFalse);
    expect(CupidFeatureFlags.enableEnLocale, isFalse);
  });

  testWidgets(
    'CupidApp resolves dark theme mode and vi locale with flags off, and '
    'the runtime readiness key still resolves',
    (WidgetTester tester) async {
      await tester.pumpWidget(const CupidApp());

      final MaterialApp app = tester.widget<MaterialApp>(
        find.byType(MaterialApp),
      );
      expect(app.themeMode, ThemeMode.dark);
      expect(app.locale, const Locale('vi'));
      expect(find.byKey(const Key('home_screen_ready_signal')), findsOneWidget);
    },
  );

  test(
    'light ThemeData stays directly constructible with flags off '
    '(flags gate exposure, never existence, per OQ5)',
    () {
      final ThemeData light = buildCupidTheme(
        platform: CupidPlatform.resolveDefault(),
        brightness: Brightness.light,
      );

      expect(light.brightness, Brightness.light);
    },
  );

  testWidgets(
    'AppL10n under Locale(en) stays directly constructible with flags off',
    (WidgetTester tester) async {
      late AppL10n l10n;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppL10n.localizationsDelegates,
          supportedLocales: AppL10n.supportedLocales,
          home: Builder(
            builder: (BuildContext context) {
              l10n = AppL10n.of(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(l10n.app_root_title, isNotEmpty);
    },
  );
}
