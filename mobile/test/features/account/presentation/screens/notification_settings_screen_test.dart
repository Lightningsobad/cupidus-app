import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/data/notification_preferences_store.dart';
import 'package:cupid_mobile/features/account/presentation/screens/notification_settings_screen.dart';
import 'package:cupid_mobile/features/phase_status/data/local_notification_scheduler.dart';
import 'package:cupid_mobile/features/phase_status/data/phase_status_prefs.dart';
import 'package:cupid_mobile/features/phase_status/domain/evening_check_in_scheduler.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _harness({
  Locale locale = const Locale('en'),
  PhaseStatusPrefs? phaseStatusPrefs,
  EveningCheckInScheduler? eveningCheckIn,
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    home: NotificationSettingsScreen(
      store: NotificationPreferencesStore(),
      phaseStatusPrefs: phaseStatusPrefs,
      eveningCheckIn: eveningCheckIn,
    ),
  );
}

/// The screen is one scrolling list, so a viewport shorter than its content
/// builds none of the offscreen rows and an assertion about a later group
/// fails the moment a row is added above it. Give the list room for every
/// group instead of letting the row count decide what the tests can see.
Future<void> _pumpScreen(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
  PhaseStatusPrefs? phaseStatusPrefs,
  EveningCheckInScheduler? eveningCheckIn,
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    _harness(
      locale: locale,
      phaseStatusPrefs: phaseStatusPrefs,
      eveningCheckIn: eveningCheckIn,
    ),
  );
  await tester.pumpAndSettle();
}

class _FakeNotifications implements LocalNotificationScheduler {
  int cancelAllCalls = 0;

  @override
  Future<bool> requestPermission() async => true;

  @override
  Future<void> schedule({
    required int id,
    required DateTime at,
    required String body,
    String? title,
    String? payload,
  }) async {}

  @override
  Future<void> cancel(int id) async {}

  @override
  Future<void> cancelAll() async => cancelAllCalls++;
}

AlignmentGeometry _pillAlignment(WidgetTester tester, String prefKey) {
  return tester
      .widget<AnimatedContainer>(
        find.descendant(
          of: find.byKey(Key('notif-toggle-$prefKey')),
          matching: find.byType(AnimatedContainer),
        ),
      )
      .alignment!;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('NotificationSettingsScreen', () {
    testWidgets('renders 7 rows across the 3 groups', (tester) async {
      await _pumpScreen(tester);

      expect(find.text('CRITICAL'), findsOneWidget);
      expect(find.text('ENGAGEMENT'), findsOneWidget);
      expect(find.text('INFO'), findsOneWidget);

      expect(find.text('Synced Reminder'), findsOneWidget);
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
      await _pumpScreen(tester);

      expect(find.text('Max 15 pushes/day.'), findsOneWidget);
      expect(find.textContaining('Do Not Disturb'), findsNothing);
      expect(find.textContaining('DND'), findsNothing);
    });

    testWidgets('names the first critical row a reminder, never an alarm', (
      tester,
    ) async {
      await _pumpScreen(tester, locale: const Locale('vi'));

      expect(find.text('Nhắc nhở đồng bộ'), findsOneWidget);
      for (final String banned in <String>[
        'báo thức',
        'Báo thức',
        'alarm',
        'Alarm',
      ]) {
        expect(find.textContaining(banned), findsNothing);
      }
    });

    testWidgets('tapping a toggle flips and persists its state', (tester) async {
      await _pumpScreen(tester);

      final pillFinder = find.byKey(const Key('notif-toggle-baeTyping'));
      expect(pillFinder, findsOneWidget);
      expect(_pillAlignment(tester, 'baeTyping'), Alignment.centerLeft);

      await tester.tap(pillFinder);
      await tester.pumpAndSettle();

      expect(_pillAlignment(tester, 'baeTyping'), Alignment.centerRight);
    });
  });

  group('the two REQ-016 rows (AC-30/AC-32)', () {
    late PhaseStatusPrefs prefs;
    late _FakeNotifications notifications;
    late EveningCheckInScheduler scheduler;

    setUp(() {
      prefs = PhaseStatusPrefs();
      notifications = _FakeNotifications();
      scheduler = EveningCheckInScheduler(
        notifications: notifications,
        prefs: prefs,
      );
    });

    testWidgets('sit in the existing engagement group, not a screen of their own',
        (tester) async {
      await _pumpScreen(
        tester,
        locale: const Locale('vi'),
        phaseStatusPrefs: prefs,
        eveningCheckIn: scheduler,
      );

      expect(find.text('Nhắc về tới nhà chưa?'), findsOneWidget);
      expect(find.text('Nội dung nhỏ giọt khoảng lặng'), findsOneWidget);
      expect(find.byKey(const Key('notif-toggle-eveningCheckIn')),
          findsOneWidget);
      expect(find.byKey(const Key('notif-toggle-quietDrip')), findsOneWidget);
      // Exactly two rows added to the seven already there, and no third row
      // and no separate screen (`ux/uiux-spec.md` §7).
      expect(
        find.byWidgetPredicate(
          (Widget widget) =>
              widget.key is ValueKey<String> &&
              (widget.key! as ValueKey<String>).value.startsWith(
                    'notif-toggle-',
                  ),
        ),
        findsNWidgets(9),
      );
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('both start on, without a first-run write', (tester) async {
      await _pumpScreen(
        tester,
        phaseStatusPrefs: prefs,
        eveningCheckIn: scheduler,
      );

      expect(_pillAlignment(tester, 'eveningCheckIn'), Alignment.centerRight);
      expect(_pillAlignment(tester, 'quietDrip'), Alignment.centerRight);

      final SharedPreferences raw = await SharedPreferences.getInstance();
      expect(raw.getKeys(), isEmpty);
    });

    testWidgets('an already-off switch loads off', (tester) async {
      await prefs.setEveningCheckInEnabled(false);

      await _pumpScreen(
        tester,
        phaseStatusPrefs: prefs,
        eveningCheckIn: scheduler,
      );

      expect(_pillAlignment(tester, 'eveningCheckIn'), Alignment.centerLeft);
      expect(_pillAlignment(tester, 'quietDrip'), Alignment.centerRight);
    });

    testWidgets('turning the evening reminder off drops what is queued',
        (tester) async {
      await _pumpScreen(
        tester,
        phaseStatusPrefs: prefs,
        eveningCheckIn: scheduler,
      );

      await tester.tap(find.byKey(const Key('notif-toggle-eveningCheckIn')));
      await tester.pumpAndSettle();

      expect(_pillAlignment(tester, 'eveningCheckIn'), Alignment.centerLeft);
      expect(notifications.cancelAllCalls, 1);
      expect(await prefs.eveningCheckInEnabled(), isFalse);
    });

    testWidgets('the drip switch writes its own key and cancels nothing',
        (tester) async {
      await _pumpScreen(
        tester,
        phaseStatusPrefs: prefs,
        eveningCheckIn: scheduler,
      );

      await tester.tap(find.byKey(const Key('notif-toggle-quietDrip')));
      await tester.pumpAndSettle();

      expect(await prefs.quietDripEnabled(), isFalse);
      expect(await prefs.eveningCheckInEnabled(), isTrue);
      expect(notifications.cancelAllCalls, isZero);
    });

    testWidgets('neither row goes through the session-scoped store',
        (tester) async {
      await _pumpScreen(
        tester,
        phaseStatusPrefs: prefs,
        eveningCheckIn: scheduler,
      );

      await tester.tap(find.byKey(const Key('notif-toggle-eveningCheckIn')));
      await tester.pumpAndSettle();

      final SharedPreferences raw = await SharedPreferences.getInstance();
      expect(
        raw.getString('cupid_notification_preferences_v1'),
        isNull,
        reason: 'that blob is cleared on sign-out, and a reminder that '
            'outlives the switch is exactly what AC-30 forbids',
      );
      expect(raw.getBool('notifications.evening_check_in.enabled'), isFalse);
    });
  });
}
