import 'package:cupid_api/cupid_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
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
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/data/firebase_auth_sign_in_gateway.dart';
import '../../features/account/data/notification_preferences_store.dart';
import '../../features/gallery/data/gallery_api.dart';
import '../../features/gallery/data/gallery_local_cache.dart';
import '../../features/gallery/data/gallery_repository.dart';
import '../../features/love_contracts/data/love_contract_gate_repository.dart';
import '../../features/love_contracts/data/love_contract_repository.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_repository.dart';
import '../../features/auth/presentation/screens/forgot_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/otp_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/welcome_screen.dart';
import '../../features/love_contracts/presentation/screens/love_contract_screen.dart';
import '../../features/pairing/presentation/screens/paired_screen.dart';
import '../../features/pairing/presentation/screens/pairing_choice_screen.dart';
import '../../features/vow/presentation/screens/vow_screen.dart';
import '../navigation/pair_gate_shell.dart';
import '../auth/auth_history_store.dart';
import '../auth/cupid_auth_interceptor.dart';
import '../auth/cupid_session.dart';
import '../auth/firebase_id_token_provider.dart';
import '../auth/session_termination.dart';
import '../navigation/onboarding_chain.dart';
import '../navigation/onboarding_progress_resolver.dart';
import '../navigation/onboarding_router.dart';
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
import '../../features/expenses/data/expenses_repository.dart';
import '../../features/expenses/data/pairing_state_reader.dart';
import '../../features/expenses/presentation/add_expense_cubit.dart';
import '../../features/expenses/presentation/expense_history_cubit.dart';
import '../database/daos/expense_dao.dart';

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

  // REQ-002 STORY-002 P2 (ADR-6, defect D6): the reason channel that keeps a
  // deliberate sign-out distinguishable from a failed refresh, both of which
  // still converge on `CupidSession.signOut()` below.
  getIt.registerLazySingleton<SessionTerminationNotifier>(
    SessionTerminationNotifier.new,
  );

  getIt.registerLazySingleton<CupidAuthInterceptor>(
    () => CupidAuthInterceptor(
      tokenProvider: getIt<CupidAuthTokenProvider>(),
      sessionTermination: getIt<SessionTerminationNotifier>(),
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

  getIt.registerLazySingleton<PartnerDisplayName>(
    () =>
        () => null,
  );

  // STORY-015 P5 (`architecture/solution.md` §4 Boundaries And Ownership;
  // ADR-015.7): additive registrations for the expenses feature's data layer,
  // pairing gate seam, and Cubits.
  getIt.registerLazySingleton<ExpenseDao>(
    () => getIt<CupidDatabase>().expenseDao,
  );

  getIt.registerLazySingleton<ExpensesRepository>(
    () => ExpensesRepository(api: getIt<CupidApi>()),
  );

  getIt.registerLazySingleton<PairingStateReader>(
    () => PairingStateReader(pairingStore: getIt<CouplePairingStore>()),
  );

  getIt.registerFactory<ExpenseHistoryCubit>(
    () => ExpenseHistoryCubit(
      repository: getIt<ExpensesRepository>(),
      dao: getIt<ExpenseDao>(),
    ),
  );

  getIt.registerFactory<AddExpenseCubit>(
    () => AddExpenseCubit(getIt<ExpensesRepository>()),
  );

  // REQ-002 STORY-001 P0 (ADR-7): the production construction site for
  // `AuthRepository`. Before this, the only one was the preview harness in
  // `main_preview.dart`, so the login/welcome destinations of the splash gate
  // were unreachable in a real build.
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      gateway: FirebaseAuthSignInGateway(FirebaseAuth.instance),
      api: getIt<CupidApi>(),
      signOut: () => getIt<CupidSession>().signOut(),
      backendUserIdStore: getIt<BackendUserIdStore>(),
      authHistoryStore: getIt<AuthHistoryStore>(),
    ),
  );

  // REQ-002 STORY-001 P1 (ADR-3): the previously-authenticated marker that
  // splits AC2 from AC3. Registered as a session-scoped store so a deliberate
  // sign-out clears it through the existing teardown, rather than adding a
  // second sign-out path.
  getIt.registerLazySingleton<AuthHistoryStore>(() {
    final store = AuthHistoryStore();
    getIt<CupidSession>().registerScopedStore(store);
    return store;
  });

  getIt.registerLazySingleton<OnboardingRouter>(
    () => OnboardingRouter(builders: onboardingRouteBuilders()),
  );

  // REQ-002 STORY-002 P3 (ADR-2): both reads already exist, so the resolver is
  // composed here instead of each caller re-deriving the rule table.
  getIt.registerLazySingleton<OnboardingProgressResolver>(
    () => OnboardingProgressResolver(
      fetchProfile: () => getIt<AccountRepository>().fetchProfile(),
      reloadEmailVerified: () => getIt<AuthRepository>().reloadEmailVerified(),
    ),
  );
}

/// REQ-002 STORY-002 P2/P3/P4/P5 (ADR-1): the nodes the shipped edges can
/// reach. `profileSetup`, `invite`, `joinCode` and `waiting` are deliberately
/// absent — each needs a runtime argument (a resolved `CupidProfile`, a
/// `create*Cubit` seam, an invitation's `expiresAt`/`code`) that no
/// `WidgetBuilder` can supply, so their edges stay direct pushes from the
/// screen that holds the argument. An unregistered node throws
/// `OnboardingRouteNotRegistered` rather than silently no-opping.
///
/// The tail screens resolve their router at tap time rather than capturing it
/// here: these closures run while the router singleton is being constructed,
/// so a direct reference would be re-entrant.
///
/// Exposed as a function, not inlined into the registration, so
/// `onboarding_route_registry_guard_test.dart` can assert this exact map
/// against the resolver's outcomes without booting the container.
Map<OnboardingNode, WidgetBuilder> onboardingRouteBuilders() {
  return <OnboardingNode, WidgetBuilder>{
    OnboardingNode.welcome: (_) =>
        WelcomeScreen(authRepository: getIt<AuthRepository>()),
    OnboardingNode.login: (_) =>
        LoginScreen(authRepository: getIt<AuthRepository>()),
    OnboardingNode.register: (_) =>
        RegisterScreen(authRepository: getIt<AuthRepository>()),
    OnboardingNode.forgotPassword: (_) =>
        ForgotScreen(authRepository: getIt<AuthRepository>()),
    // The chain reaches `otp` only while a Firebase user exists and is
    // unverified, so its subtitle address comes from that user rather than
    // from a new argument the registry cannot carry.
    OnboardingNode.otp: (_) =>
        OtpScreen(email: FirebaseAuth.instance.currentUser?.email ?? ''),
    OnboardingNode.pairingChoice: (_) => const PairingChoiceScreen(),
    // Both pairing legs converge here, and both reach it through `resetTo`,
    // so it must resolve from the registry.
    OnboardingNode.paired: (BuildContext context) => PairedScreen(
      onSignContract: () =>
          getIt<OnboardingRouter>().goNext(context, OnboardingNode.paired),
    ),
    OnboardingNode.loveContract: (_) => LoveContractScreen(
      // Registry construction is the in-chain entry by definition; the
      // post-home entry is built by `LoveContractGateRoute` instead.
      entry: LoveContractEntry.onboardingStep,
      repository: getIt<LoveContractRepository>(),
      partnerDisplayName: getIt<PartnerDisplayName>(),
    ),
    OnboardingNode.vow: (BuildContext context) => VowScreen(
      // `resetTo`, not `goNext`: `home` is the chain's exit, so the whole
      // onboarding stack goes with it and Android back cannot re-enter.
      onEnterDashboard: () =>
          getIt<OnboardingRouter>().resetTo(context, OnboardingNode.home),
    ),
    // `PairGateShell`, not `HomeScreen`: AC4 puts the 5-tab bar's first
    // appearance on this node, and only the shell behind the gate mounts
    // `CupidTabBar`. It also remounts `SessionTerminationListener` and
    // `ReminderOverlayHost`, which the chain's earlier `resetTo` calls
    // discard along with the original shell root.
    OnboardingNode.home: (_) => const PairGateShell(),
  };
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
