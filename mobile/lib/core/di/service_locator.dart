import 'package:cupid_api/cupid_api.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';

import '../../features/chat/data/chat_partner_store.dart';
import '../../features/chat/data/chat_repository.dart';
import '../auth/cupid_auth_interceptor.dart';
import '../auth/cupid_session.dart';
import '../auth/firebase_id_token_provider.dart';
import '../config/cupid_api_config.dart';
import '../database/cupid_database.dart';
import '../database/daos/message_dao.dart';
import '../network/cupid_api_client.dart';
import '../network/cupid_auth_token_provider.dart';
import '../network/cupid_interceptor_slots.dart';
import '../realtime/backend_user_id_store.dart';
import '../realtime/cupid_realtime.dart';
import '../realtime/fcm_transport.dart';
import '../realtime/pending_event_store.dart';
import '../realtime/realtime_coordinator.dart';
import '../realtime/socket_transport.dart';

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

  getIt.registerLazySingleton<BackendUserIdStore>(BackendUserIdStore.new);

  getIt.registerLazySingleton<PendingEventStore>(PendingEventStore.new);

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
