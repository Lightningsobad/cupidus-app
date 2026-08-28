import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/design_system/tokens/theme_catalog.dart';
import 'package:cupid_mobile/features/home/presentation/widgets/themed_days_counter_nurture.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

void main() {
  group('ThemedDaysCounterNurture', () {
    testWidgets('renders days count with ShaderMask and Nunito font correctly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(const ThemedDaysCounterNurture(days: 247)),
      );
      await tester.pump(const Duration(milliseconds: 100));

      final Finder counter = find.byKey(const Key('home_days_counter'));
      expect(counter, findsOneWidget);

      final ShaderMask mask = tester.widget<ShaderMask>(counter);
      expect(mask.blendMode, BlendMode.srcIn);

      final Text count = tester.widget<Text>(
        find.descendant(of: counter, matching: find.text('247')),
      );
      expect(count.style?.fontFamily, 'Nunito');
      expect(count.style?.fontWeight, FontWeight.w900);
      expect(count.style?.fontSize, 66);

      expect(find.text('ngày bên nhau'), findsOne);
    });

    testWidgets('renders across all 8 themes in catalog without errors', (
      WidgetTester tester,
    ) async {
      for (final theme in cupidThemeCatalog) {
        await tester.pumpWidget(
          _host(ThemedDaysCounterNurture(days: 100, themeOverride: theme)),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(find.byKey(const Key('home_days_counter')), findsOneWidget);
        expect(find.text('100'), findsOneWidget);
      }
    });

    testWidgets('tap triggers bounce animation and callback', (
      WidgetTester tester,
    ) async {
      bool tapped = false;
      await tester.pumpWidget(
        _host(
          ThemedDaysCounterNurture(
            days: 365,
            onTap: () {
              tapped = true;
            },
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.byKey(const Key('home_days_counter')));
      await tester.pump(const Duration(milliseconds: 50));

      expect(tapped, isTrue);

      // Advance past bounce duration
      await tester.pump(const Duration(milliseconds: 200));
    });

    testWidgets('respects reduceMotion / disableAnimations without throwing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const ThemedDaysCounterNurture(days: 50),
          disableAnimations: true,
        ),
      );
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byKey(const Key('home_days_counter')), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
    });
  });
}
