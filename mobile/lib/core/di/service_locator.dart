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
import '../../features/chat/data/chat_partner_store.dart';
import '../../features/chat/data/chat_repository.dart';
import '../../features/pet/data/pet_repository.dart';
import '../../features/account/data/account_repository.dart';
import '../../features/account/data/notification_preferences_store.dart';
import '../../features/gallery/data/gallery_api.dart';
import '../../features/gallery/data/gallery_local_cache.dart';
import '../../features/gallery/data/gallery_repository.dart';
import '../../features/love_contracts/data/love_contract_gate_repository.dart';
import '../../features/love_contracts/data/love_contract_repository.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import '../auth/cupid_auth_interceptor.dart';
import '../auth/cupid_session.dart';
import '../auth/firebase_id_token_provider.dart';
import '../config/cupid_api_config.dart';
import '../couple/couple_pairing_store.dart';
import '../database/cupid_database.dart';
import '../database/daos/message_dao.dart';
import '../database/daos/timeline_dao.dart';
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

/// STORY-006 A-1 (`architecture/solution.md` §3): the partner's `displayName`
/// is not resolvable from the frozen backend, so love-contracts UI reads it
/// through this injectable provider instead of hard-coding `null`. The
/// default registration below returns `null`; a later story can override it
/// without touching this feature's widgets.
typedef PartnerDisplayName = String? Function();

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

  getIt.registerLazySingleton<AccountRepository>(
    () => AccountRepository(api: getIt<CupidApi>()),
  );

  // STORY-013 P0 data contract (`architecture/solution.md` §4 Boundaries And
  // Ownership): `GalleryRepository` is the sole gallery network + cache
  // owner, so only it (not `GalleryApi`/`GalleryLocalCache` directly) should
  // be resolved by presentation code in later phases.
  getIt.registerLazySingleton<GalleryApi>(
    () => GalleryApi(api: getIt<CupidApi>()),
  );
  getIt.registerLazySingleton<GalleryLocalCache>(GalleryLocalCache.new);
  getIt.registerLazySingleton<GalleryRepository>(
    () => GalleryRepository(
      api: getIt<GalleryApi>(),
      cache: getIt<GalleryLocalCache>(),
    ),
  );

  getIt.registerLazySingleton<BackendUserIdStore>(BackendUserIdStore.new);

  getIt.registerLazySingleton<PendingEventStore>(PendingEventStore.new);

  getIt.registerLazySingleton<NotificationPreferencesStore>(() {
    final store = NotificationPreferencesStore();
    getIt<CupidSession>().registerScopedStore(store);
    return store;
  });

  // STORY-012 P1: ADR-007 F5 Drift persistence seam. Registered as a
  // session-scoped store so a second user on this device never reads the
  // first couple's cached timeline (D-012-5). `CupidDatabase` itself is
  // registered once below (ADR-010 single canonical Drift owner, see the
  // STORY-011 `MessageDao` section) -- not duplicated here.
  getIt.registerLazySingleton<TimelineDao>(() {
    final dao = getIt<CupidDatabase>().timelineDao;
    getIt<CupidSession>().registerScopedStore(dao);
    return dao;
  });

  // STORY-012 P3: ADR-007 read-through seam joining the P1 Drift cache and
  // the P2 remote source.
  getIt.registerLazySingleton<TimelineRepository>(
    () => TimelineRepository(
      getIt<TimelineDao>(),
      TimelineRemoteDataSource(getIt<CupidApi>()),
    ),
  );

  // STORY-012 P3: AC4 offline pairing gate, cleared on sign-out like the
  // other session-scoped stores above.
  getIt.registerLazySingleton<CouplePairingStore>(() {
    final store = CouplePairingStore(
      api: getIt<CupidApi>(),
      backendUserIdStore: getIt<BackendUserIdStore>(),
    );
    getIt<CupidSession>().registerScopedStore(store);
    return store;
  });

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
      // ADR-013f: this closure resolves through `getIt` at call time (never
      // at registration time), avoiding the circular dependency between
      // `RealtimeCoordinator` and `ChatRepository`.
      resyncFetcher: () => getIt<ChatRepository>().resyncPageOne(),
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

  getIt.registerLazySingleton<CupidDatabase>(CupidDatabase.new);

  getIt.registerLazySingleton<MessageDao>(() {
    final dao = getIt<CupidDatabase>().messageDao;
    // `CupidDatabase` (P0 output) does not itself implement
    // `SessionScopedStore`; adapt here instead of editing that frozen file.
    getIt<CupidSession>().registerScopedStore(_MessageDaoScopedStore(dao));
    return dao;
  });

  getIt.registerLazySingleton<ChatPartnerStore>(() {
    final store = ChatPartnerStore(dio: getIt<CupidApi>().dio);
    getIt<CupidSession>().registerScopedStore(store);
    return store;
  });

  getIt.registerLazySingleton<ChatRepository>(
    () => ChatRepository(
      messageDao: getIt<MessageDao>(),
      coordinator: getIt<RealtimeCoordinator>(),
      dio: getIt<CupidApi>().dio,
      partnerStore: getIt<ChatPartnerStore>(),
      backendUserIdStore: getIt<BackendUserIdStore>(),
    ),
  );

  // STORY-011 `PetRepository` registration (`architecture/solution.md` §4
  // Boundaries And Ownership: additive-only edit).
  getIt.registerLazySingleton<PetRepository>(
    () => PetRepository(api: getIt<CupidApi>()),
  );

  // STORY-006 P0 (`architecture/solution.md` §4 Boundaries And Ownership):
  // the two love-contracts network owners, plus the default (`null`)
  // `PartnerDisplayName` provider.
  getIt.registerLazySingleton<LoveContractRepository>(
    () => LoveContractRepository(getIt<CupidApi>()),
  );

  getIt.registerLazySingleton<LoveContractGateRepository>(
    () => LoveContractGateRepository(getIt<CupidApi>()),
  );

  getIt.registerLazySingleton<PartnerDisplayName>(() => () => null);
}

/// Adapts [MessageDao] to [SessionScopedStore] so the Drift message cache is
/// wiped on sign-out (AC4) without editing `core/database/cupid_database.dart`
/// (P0 output, outside this phase's write scope).
class _MessageDaoScopedStore implements SessionScopedStore {
  _MessageDaoScopedStore(this._dao);

  final MessageDao _dao;

  @override
  Future<void> clearOnSignOut() => _dao.clearAll();
}
