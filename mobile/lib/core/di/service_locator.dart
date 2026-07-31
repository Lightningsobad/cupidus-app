import 'package:cupid_api/cupid_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/vibes/data/vibes_repository.dart';
import '../../features/vibes/presentation/vibe_cubit.dart';
import '../../features/reminders/data/reminder_local_prefs.dart';
import '../../features/reminders/data/reminder_repository.dart';
import '../../features/reminders/presentation/reminder_firing_cubit.dart';
import '../../features/reminders/presentation/reminder_schedule_bloc.dart';
import '../../features/dream_jar/data/dream_jar_repository.dart';
import '../auth/cupid_auth_interceptor.dart';
import '../auth/cupid_session.dart';
import '../auth/firebase_id_token_provider.dart';
import '../config/cupid_api_config.dart';
import '../network/cupid_api_client.dart';
import '../network/cupid_auth_token_provider.dart';
import '../network/cupid_interceptor_slots.dart';
import '../realtime/backend_user_id_store.dart';
import '../realtime/cupid_realtime.dart';
import '../realtime/fcm_transport.dart';
import '../realtime/pending_event_store.dart';
import '../realtime/realtime_coordinator.dart';
import '../realtime/socket_transport.dart';
import '../../features/pairing/data/pairing_repository.dart';
import '../../features/anti_ghosting/data/ghost_config_repository.dart';

/// The app's composition root (ADR-011g).
final GetIt getIt = GetIt.instance;

/// Registers the auth lane and the generated API client.
///
/// `CupidApiClient.create()` builds its `Dio` internally and never accepts
/// one as an input, so `CupidAuthInterceptor` (which must be constructed
/// first to be passed in as the `auth` slot override) cannot receive that
/// `Dio` at construction time. Instead, its `dio` field is assigned from the
/// returned `CupidApi.dio` -- the identical instance -- immediately after
/// `create()` returns and before the client is used anywhere.
void setupServiceLocator() {
  getIt.registerLazySingleton<CupidAuthTokenProvider>(
    () => FirebaseIdTokenProvider(FirebaseAuth.instance),
  );

  getIt.registerLazySingleton<CupidSession>(
    () => CupidSession(tokenProvider: getIt<CupidAuthTokenProvider>()),
  );

  getIt.registerLazySingleton<CupidAuthInterceptor>(
    () => CupidAuthInterceptor(
      tokenProvider: getIt<CupidAuthTokenProvider>(),
      onSessionExpired: () => getIt<CupidSession>().signOut(),
    ),
  );

  getIt.registerLazySingleton<CupidApi>(() {
    final authInterceptor = getIt<CupidAuthInterceptor>();
    final cupidApi = CupidApiClient.create(
      slotOverrides: {CupidInterceptorSlot.auth: authInterceptor},
    );
    authInterceptor.dio = cupidApi.dio;
    return cupidApi;
  });

  getIt.registerLazySingleton<PairingRepository>(
    () => PairingRepository(api: getIt<CupidApi>()),
  );

  getIt.registerLazySingleton<BackendUserIdStore>(BackendUserIdStore.new);

  getIt.registerLazySingleton<PendingEventStore>(PendingEventStore.new);

  // STORY-014 P5: registered here (not by the P1 phase that defined the
  // repository) because P5 owns the Home entry point that is the sole
  // consumer/navigation route for Dream Jar (`ux/uiux-spec.md` entry-point
  // paragraph before §1.1).
  getIt.registerLazySingleton<DreamJarRepository>(
    () => DreamJarRepository(getIt<CupidApi>()),
  );

  // ADR-011g lazy-singleton registration: this is the reachability wiring
  // for `RealtimeCoordinator` (`architecture/solution.md` §4 Boundaries And
  // Ownership) — without it the module is orphaned, since this story ships
  // no UI surface (UX WAIVED).
  getIt.registerLazySingleton<RealtimeCoordinator>(() {
    final session = getIt<CupidSession>();
    final backendUserIdStore = getIt<BackendUserIdStore>();
    final coordinator = RealtimeCoordinatorImpl(
      socket: SocketTransport(
        url: CupidApiConfig.baseUrl,
        idToken: session.idToken,
        idTokenStream: session.idTokenStream,
        backendUserId: backendUserIdStore.resolve,
      ),
      fcm: FcmTransport(),
      pendingEventStore: getIt<PendingEventStore>(),
      backendUserIdStore: backendUserIdStore,
    );
    session.registerScopedStore(coordinator);
    return coordinator;
  });

  // Append-only registrations for STORY-010 (`architecture/solution.md` §4
  // Boundaries And Ownership) to limit parallel-wave conflicts on this file.
  getIt.registerLazySingleton<VibesRepository>(
    () => VibesRepository(getIt<CupidApi>()),
  );

  getIt.registerFactory<VibeCubit>(
    () => VibeCubit(repository: getIt<VibesRepository>()),
  );

  // STORY-009 P1: reminder feature data layer + schedule bloc
  // (`architecture/solution.md` §4 Boundaries And Ownership). Registered
  // here, not in P0, because P0 shipped no DI wiring for this feature slice.
  getIt.registerLazySingleton<ReminderLocalPrefs>(() {
    final prefs = ReminderLocalPrefs();
    getIt<CupidSession>().registerScopedStore(prefs);
    return prefs;
  });

  getIt.registerLazySingleton<ReminderRepository>(
    () => ReminderRepository(
      api: getIt<CupidApi>(),
      realtime: getIt<RealtimeCoordinator>(),
      backendUserIdStore: getIt<BackendUserIdStore>(),
    ),
  );

  getIt.registerFactory<ReminderScheduleBloc>(
    () => ReminderScheduleBloc(
      repository: getIt<ReminderRepository>(),
      localPrefs: getIt<ReminderLocalPrefs>(),
      backendUserIdStore: getIt<BackendUserIdStore>(),
    ),
  );

  // STORY-009 P3: the firing-overlay cubit, mounted once by `ReminderOverlayHost`
  // above the shell (`architecture/solution.md` §4 Mobile Contract).
  getIt.registerFactory<ReminderFiringCubit>(
    () => ReminderFiringCubit(
      repository: getIt<ReminderRepository>(),
      localPrefs: getIt<ReminderLocalPrefs>(),
      backendUserIdStore: getIt<BackendUserIdStore>(),
    ),
  );

  // STORY-008 P0 (`architecture/solution.md` §4): additive registration for
  // the anti_ghosting feature's data layer, consumed by later STORY-008
  // phases.
  getIt.registerLazySingleton<GhostConfigRepository>(
    () => GhostConfigRepository(api: getIt<CupidApi>()),
  );
}
