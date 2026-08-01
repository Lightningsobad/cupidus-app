import 'dart:typed_data';

import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/app_shell.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_local_prefs.dart';
import 'package:cupid_mobile/features/reminders/data/reminder_repository.dart';
import 'package:cupid_mobile/features/reminders/domain/synced_reminder.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_overlay_host.dart';
import 'package:cupid_mobile/features/reminders/presentation/reminder_schedule_bloc.dart';
import 'package:cupid_mobile/features/reminders/presentation/screens/reminder_schedule_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Always returns `{}`; mirrors `test/app/feature_flags_test.dart` and
/// `test/widget_test.dart`. This suite only checks Home-tab reachability, so
/// `ChatPartnerStore`/`CouplePairingStore` never need a real `/users/me`
/// payload -- just a non-throwing one.
class _FakeHttpClientAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

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
    // Production only ever mounts AppShell under ReminderOverlayHost (via
    // PairGateShell's paired branch) -- mirror that nesting here so this
    // test's ReminderOverlayHost reachability assertion is structurally
    // valid, without pulling in the full PairGateCubit state machine.
    home: const ReminderOverlayHost(child: AppShell()),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // Stands in for `setupServiceLocator()`'s `ReminderScheduleBloc`
    // registration, which `ReminderScheduleScreen` resolves unconditionally
    // on build.
    getIt.registerFactory<ReminderScheduleBloc>(
      () => ReminderScheduleBloc(
        repository: _FakeReminderRepository(),
        localPrefs: ReminderLocalPrefs(),
        backendUserIdStore: BackendUserIdStore(),
      ),
    );
    // `const AppShell()` below takes no explicit stores, so its
    // `ChatEntryGate` wrap (always evaluated on build) and its Home tab's
    // `_TimelineEntryPointGate` (rendered first, before the reminder entry
    // card is tapped) both resolve their stores through GetIt; neither has
    // any other override hook.
    final dio = Dio()..httpClientAdapter = _FakeHttpClientAdapter();
    getIt.registerSingleton<ChatPartnerStore>(ChatPartnerStore(dio: dio));
    getIt.registerSingleton<CouplePairingStore>(
      CouplePairingStore(
        api: CupidApi(dio: dio, interceptors: const []),
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
