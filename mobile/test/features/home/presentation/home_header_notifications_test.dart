import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/notification_preferences_store.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/account/presentation/screens/notification_settings_screen.dart';
import 'package:cupid_mobile/features/home/presentation/home_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const Key _actionKey = Key('home_header_notifications_action');
const Key _dotKey = Key('home_header_notifications_dot');

Future<CupidProfile> _profile() async => CupidProfile(
  id: 'test-user',
  email: 'test@cupid.test',
  language: 'vi',
  vowTaken: true,
  isGhostModeEnabled: false,
  displayName: 'Minh',
  relationshipStartDate: DateTime.now().subtract(const Duration(days: 246)),
  partnerId: 'test-partner',
  coupleType: 'SAME_CITY',
);

/// AC1 pins the enabled dark theme + `vi` locale, so the harness renders that
/// combination rather than the default light/`en` one.
Widget _harness({required Future<bool> Function() resolveUnconfigured}) {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('vi'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: HomeScreen(
      resolveProfile: _profile,
      resolveNotificationsUnconfigured: resolveUnconfigured,
      // Keeps the unrelated timeline entry point off the DI container; this
      // story only exercises the header.
      resolvePairingStatus: () async => PairingStatus.unpaired,
    ),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    if (!getIt.isRegistered<NotificationPreferencesStore>()) {
      getIt.registerLazySingleton<NotificationPreferencesStore>(
        NotificationPreferencesStore.new,
      );
    }
  });

  tearDown(() => getIt.reset());

  testWidgets('AC1: the header renders the notifications action', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(resolveUnconfigured: () async => false));
    await tester.pumpAndSettle();

    expect(find.byKey(_actionKey), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AC3: no dot when preferences have already been saved', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(resolveUnconfigured: () async => false));
    await tester.pumpAndSettle();

    expect(find.byKey(_dotKey), findsNothing);
  });

  testWidgets('AC3: the dot renders while the user is unconfigured', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(resolveUnconfigured: () async => true));
    await tester.pumpAndSettle();

    expect(find.byKey(_dotKey), findsOneWidget);
  });

  testWidgets('AC2: tapping the action reaches the shipped Notifications screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(_harness(resolveUnconfigured: () async => false));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(_actionKey));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationSettingsScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'the dot clears once the store has a persisted value after the visit',
    (WidgetTester tester) async {
      final NotificationPreferencesStore store =
          getIt<NotificationPreferencesStore>();
      await tester.pumpWidget(
        _harness(
          resolveUnconfigured: () async => !await store.hasStoredPreferences(),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(_dotKey), findsOneWidget);

      await tester.tap(find.byKey(_actionKey));
      await tester.pumpAndSettle();
      await store.setEnabled('syncedAlarm', false);

      tester.state<NavigatorState>(find.byType(Navigator)).pop();
      await tester.pumpAndSettle();

      expect(find.byKey(_dotKey), findsNothing);
    },
  );
}
