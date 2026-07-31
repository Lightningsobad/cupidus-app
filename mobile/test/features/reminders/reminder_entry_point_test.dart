import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/app_shell.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_local_prefs.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_repository.dart';
import 'package:cupid_mobile/features/reminders/domain/synced_reminder.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_overlay_host.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_schedule_bloc.dart';
import 'package:cupid_mobile/features/reminders/presentation/screens/reminder_schedule_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Never invoked (every method `ReminderScheduleBloc` calls on `_repository`
/// is overridden by [_FakeReminderRepository] below), but the base
/// `ReminderRepository` constructor still requires a live coordinator.
class _EmptyRealtimeCoordinator implements RealtimeCoordinator {
  @override
  Stream<RealtimeEvent> events({Set<String>? names}) => const Stream.empty();

  @override
  Stream<RealtimeStatus> get status => const Stream.empty();

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> emit(String name, Object? payload) async {}

  @override
  Future<void> resync() async {}
}

/// This test only asserts navigation reachability (P4 AC), not hydration
/// content -- P2's own suite already covers `ReminderScheduleBloc` hydration
/// -- so `load`/`events` are stubbed to avoid a real network call from
/// `CupidApi().dio`.
class _FakeReminderRepository extends ReminderRepository {
  _FakeReminderRepository()
    : super(
        api: CupidApi(),
        realtime: _EmptyRealtimeCoordinator(),
        backendUserIdStore: BackendUserIdStore(),
      );

  @override
  Future<SyncedReminder?> load() async => null;

  @override
  Stream<RealtimeEvent> events() => const Stream.empty();
}

Widget _harness() {
  return MaterialApp(
    theme: buildCupidTheme(
      platform: CupidPlatform.material,
      brightness: Brightness.dark,
    ),
    locale: const Locale('en'),
    localizationsDelegates: AppL10n.localizationsDelegates,
    supportedLocales: AppL10n.supportedLocales,
    home: const AppShell(),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // Stands in for `setupServiceLocator()`'s `ReminderScheduleBloc`
    // registration, which `ReminderScheduleScreen` resolves unconditionally
    // on build; nothing else this test exercises is GetIt-registered.
    getIt.registerFactory<ReminderScheduleBloc>(
      () => ReminderScheduleBloc(
        repository: _FakeReminderRepository(),
        localPrefs: ReminderLocalPrefs(),
        backendUserIdStore: BackendUserIdStore(),
      ),
    );
  });

  tearDown(() => getIt.reset());

  testWidgets(
    'home affordance navigates from AppShell to ReminderScheduleScreen (P4 AC)',
    (tester) async {
      await tester.pumpWidget(_harness());
      await tester.pump();

      expect(
        find.byKey(const Key('home_screen_ready_signal')),
        findsOneWidget,
      );
      expect(find.byType(ReminderOverlayHost), findsOneWidget);

      final entryPoint = find.byKey(const Key('home_reminder_entry_card'));
      expect(entryPoint, findsOneWidget);

      await tester.tap(entryPoint);
      await tester.pumpAndSettle();

      expect(find.byType(ReminderScheduleScreen), findsOneWidget);
    },
  );
}
