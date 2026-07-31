import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/notification_preferences_store.dart';
import 'package:cupid_mobile/features/account/presentation/screens/notification_settings_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _harness() {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: NotificationSettingsScreen(store: NotificationPreferencesStore()),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('NotificationSettingsScreen', () {
    testWidgets('renders 7 rows across the 3 groups', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('ENGAGEMENT'), findsOneWidget);
      expect(find.text('INFO'), findsOneWidget);

      expect(find.text('Synced Alarm'), findsOneWidget);
      expect(find.text('Emoji Storm'), findsOneWidget);
      expect(find.text('Vibe Check'), findsOneWidget);
      expect(find.text('Bun needs you'), findsOneWidget);
      expect(find.text('Bae is typing'), findsOneWidget);
      expect(find.text('Dream Jar milestone'), findsOneWidget);
      expect(find.text('Love Timeline'), findsOneWidget);
    });

    testWidgets('shows only the numeric cap copy, no DND-bypass clause (DEC-6)', (
      tester,
    ) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      expect(find.text('Max 15 pushes/day.'), findsOneWidget);
      expect(find.textContaining('Do Not Disturb'), findsNothing);
      expect(find.textContaining('DND'), findsNothing);
    });

    testWidgets('tapping a toggle flips and persists its state', (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      final pillFinder = find.byKey(const Key('notif-toggle-baeTyping'));
      expect(pillFinder, findsOneWidget);

      AnimatedContainer pillBefore = tester.widget<AnimatedContainer>(
        find.descendant(
          of: pillFinder,
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(pillBefore.alignment, Alignment.centerLeft);

      await tester.tap(pillFinder);
      await tester.pumpAndSettle();

      AnimatedContainer pillAfter = tester.widget<AnimatedContainer>(
        find.descendant(
          of: pillFinder,
          matching: find.byType(AnimatedContainer),
        ),
      );
      expect(pillAfter.alignment, Alignment.centerRight);
    });
  });
}
