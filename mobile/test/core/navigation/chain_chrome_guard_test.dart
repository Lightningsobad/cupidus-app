// AC4 NO_CHROME / NO_TABS guard for the onboarding chain.
//
// `OnboardingChain.isChromeless` is only a table; this suite pumps the real
// screen behind every chromeless node and asserts the rendered tree carries
// no header and no tab bar. It then asserts the shell the `home` node lands
// on DOES mount `CupidTabBar`, so the guard proves the first-appearance rule
// rather than a blanket absence.
import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cupid_mobile/core/couple/couple_pairing_store.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart' show Message;
import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/core/navigation/app_shell.dart';
import 'package:cupid_mobile/core/navigation/onboarding_chain.dart';
import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/core/realtime/cupid_realtime.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:cupid_mobile/features/account/domain/cupid_profile.dart';
import 'package:cupid_mobile/features/auth/data/auth_repository.dart';
import 'package:cupid_mobile/features/auth/data/firebase_sign_in_gateway.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/forgot_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/otp_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/register_screen.dart';
import 'package:cupid_mobile/features/auth/presentation/screens/welcome_screen.dart';
import 'package:cupid_mobile/features/chat/data/chat_partner_store.dart';
import 'package:cupid_mobile/features/chat/data/chat_repository.dart';
import 'package:cupid_mobile/features/chat/data/ghost_consent_store.dart';
import 'package:cupid_mobile/features/love_contracts/data/love_contract_repository.dart';
import 'package:cupid_mobile/features/love_contracts/presentation/screens/love_contract_screen.dart';
import 'package:cupid_mobile/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart';
import 'package:cupid_mobile/features/onboarding/presentation/screens/permissions_screen.dart';
import 'package:cupid_mobile/features/pairing/data/pairing_invitation.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link.dart';
import 'package:cupid_mobile/features/pairing/data/partner_link_poller.dart';
import 'package:cupid_mobile/features/pairing/presentation/invite_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/joincode_cubit.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/invite_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/joincode_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/paired_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/pairing_choice_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/screens/waiting_screen.dart';
import 'package:cupid_mobile/features/pairing/presentation/waiting_cubit.dart';
import 'package:cupid_mobile/features/vow/presentation/screens/vow_screen.dart';
import 'package:cupid_mobile/l10n/generated/app_l10n.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter([this._body = const <String, Object?>{}]);

  final Object? _body;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async => ResponseBody.fromString(
    jsonEncode(_body),
    200,
    headers: <String, List<String>>{
      Headers.contentTypeHeader: <String>[Headers.jsonContentType],
    },
  );
}

/// Every leg succeeds and nothing is asserted about auth here; the screens
/// only need a repository that constructs.
class _InertGateway implements FirebaseSignInGateway {
  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithFacebook() async {}

  @override
  Future<void> sendEmailVerification() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<bool> reloadEmailVerified() async => true;
}

AuthRepository _authRepository() {
  final CupidApi api = CupidApiClient.create();
  api.dio.httpClientAdapter = _FakeHttpClientAdapter(<String, Object?>{
    'id': 'user-1',
  });
  return AuthRepository(
    gateway: _InertGateway(),
    api: api,
    signOut: () async {},
  );
}

LoveContractRepository _loveContractRepository() {
  final Dio dio = Dio(BaseOptions(baseUrl: 'http://localhost'))
    ..httpClientAdapter = _FakeHttpClientAdapter();
  return LoveContractRepository(CupidApi(dio: dio, interceptors: const []));
}

class _IdleTimer implements Timer {
  @override
  bool get isActive => true;

  @override
  void cancel() {}

  @override
  int get tick => 0;
}

/// Mirrors `test/features/pairing/presentation/invite_screen_test.dart`: the
/// real, already-tested poller with a timer factory that never fires, so the
/// waiting screen renders without scheduling real work.
WaitingCubit _idleWaitingCubit() => WaitingCubit(
  getPartnerLink: () async => const PartnerLink(partnerId: null),
  expiresAt: DateTime.utc(2026, 1, 2),
  createPoller: (onPaired, onTimedOut) => PartnerLinkPoller(
    fetchPartnerLink: () async => const PartnerLink(partnerId: null),
    expiresAt: DateTime.utc(2026, 1, 2),
    onPaired: onPaired,
    onTimedOut: onTimedOut,
    timerFactory: (duration, callback) => _IdleTimer(),
  ),
);

InviteCubit _idleInviteCubit() => InviteCubit(
  generateInvitation: () async => PairingInvitation(
    code: '3F9A2B',
    expiresAt: DateTime.utc(2026, 1, 2),
  ),
  now: () => DateTime.utc(2026, 1, 1),
);

/// Stand-in registry: no screen under test is asked to navigate, but the
/// chained screens resolve a router at build time and must not reach GetIt.
OnboardingRouter _stubRouter() => OnboardingRouter(
  builders: <OnboardingNode, WidgetBuilder>{
    for (final OnboardingNode node in OnboardingNode.values)
      node: (_) => const Scaffold(),
  },
);

CupidProfile _profile() => const CupidProfile(
  id: 'user-1',
  email: 'user@example.com',
  language: 'vi',
  vowTaken: false,
  isGhostModeEnabled: true,
);

/// The real screen behind each chromeless node, built through its own
/// injection seams. Keyed by node so a node added to [OnboardingChain]
/// without an entry here fails the coverage test below rather than silently
/// escaping the guard.
Map<OnboardingNode, Widget Function()> _chromelessScreens() =>
    <OnboardingNode, Widget Function()>{
      OnboardingNode.welcome: () =>
          WelcomeScreen(authRepository: _authRepository()),
      OnboardingNode.login: () =>
          LoginScreen(authRepository: _authRepository()),
      OnboardingNode.register: () =>
          RegisterScreen(authRepository: _authRepository()),
      OnboardingNode.forgotPassword: () =>
          ForgotScreen(authRepository: _authRepository()),
      OnboardingNode.otp: () => const OtpScreen(email: 'user@example.com'),
      OnboardingNode.permissions: () => const PermissionsScreen(),
      OnboardingNode.profileSetup: () =>
          OnboardingProfileSetupScreen(profile: _profile(), onContinue: () {}),
      OnboardingNode.pairingChoice: () => const PairingChoiceScreen(),
      OnboardingNode.invite: () => InviteScreen(
        createInviteCubit: _idleInviteCubit,
        createWaitingCubit: _idleWaitingCubit,
        router: _stubRouter(),
      ),
      OnboardingNode.joinCode: () => JoincodeScreen(
        createJoincodeCubit: () => JoincodeCubit(acceptInvitation: (_) async {}),
        router: _stubRouter(),
      ),
      OnboardingNode.waiting: () => WaitingScreen(
        expiresAt: DateTime.utc(2026, 1, 2),
        createWaitingCubit: _idleWaitingCubit,
        router: _stubRouter(),
      ),
      OnboardingNode.paired: () => const PairedScreen(),
      OnboardingNode.loveContract: () => LoveContractScreen(
        repository: _loveContractRepository(),
        entry: LoveContractEntry.onboardingStep,
        router: _stubRouter(),
      ),
      OnboardingNode.vow: () => const VowScreen(),
    };

Widget _harness(Widget screen) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppL10n.localizationsDelegates,
  supportedLocales: AppL10n.supportedLocales,
  theme: buildCupidTheme(
    platform: CupidPlatform.material,
    brightness: Brightness.dark,
  ),
  home: screen,
);

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  tearDown(() async {
    await getIt.reset();
  });

  test('home is the only node the chain treats as chromed', () {
    for (final OnboardingNode node in OnboardingNode.values) {
      expect(
        OnboardingChain.isChromeless(node),
        node != OnboardingNode.home,
        reason: '${node.name} disagrees with the AC4 chrome rule',
      );
    }
  });

  test('every chromeless node has a screen under guard', () {
    final Set<OnboardingNode> guarded = _chromelessScreens().keys.toSet();
    final Set<OnboardingNode> chromeless = OnboardingNode.values
        .where(OnboardingChain.isChromeless)
        .toSet();
    expect(
      guarded,
      chromeless,
      reason: 'a chain node escaped the AC4 chrome guard',
    );
  });

  for (final MapEntry<OnboardingNode, Widget Function()> entry
      in _chromelessScreens().entries) {
    testWidgets(
      '${entry.key.name} renders no header and no tab bar',
      (tester) async {
        await tester.pumpWidget(_harness(entry.value()));
        // Bounded pumps rather than `pumpAndSettle`: several chain screens run
        // looping ambient animations by design and would never settle.
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.byType(CupidHeader),
          findsNothing,
          reason: '${entry.key.name} grew a header AC4 forbids',
        );
        // `CupidHeader` builds an `AppBar` internally, so a header breach shows
        // up under both finders; a chromeless node must have neither.
        expect(
          find.byType(AppBar),
          findsNothing,
          reason: '${entry.key.name} disagrees with its header expectation',
        );
        expect(find.byType(BottomNavigationBar), findsNothing);
        expect(find.byType(NavigationBar), findsNothing);
        expect(find.byType(CupidTabBar), findsNothing);
      },
    );
  }

  testWidgets(
    'the shell behind the home node is where the tab bar first appears',
    (tester) async {
      final Dio dio = Dio()
        ..httpClientAdapter = _FakeHttpClientAdapter(<String, Object?>{
          'partnerId': 'partner-1',
          'displayName': 'Partner One',
          'isGhostModeEnabled': false,
        });
      final BackendUserIdStore backendUserIdStore = BackendUserIdStore()
        ..updateFromLoginResponse(<String, Object?>{'id': 'me-1'});
      // The Home tab resolves its own store through GetIt; `app_shell.dart`
      // exposes no override for it (see `app_shell_test.dart`).
      getIt.registerSingleton<CouplePairingStore>(
        CouplePairingStore(
          api: CupidApi(dio: dio, interceptors: const []),
          backendUserIdStore: backendUserIdStore,
        ),
      );

      final _InertChatRepository chatRepository = _InertChatRepository();
      final _InertRealtimeCoordinator coordinator = _InertRealtimeCoordinator();
      addTearDown(chatRepository.dispose);
      addTearDown(coordinator.dispose);

      await tester.pumpWidget(
        _harness(
          AppShell(
            partnerStore: ChatPartnerStore(dio: dio),
            chatRepository: chatRepository,
            coordinator: coordinator,
            backendUserIdStore: backendUserIdStore,
            consentStore: GhostConsentStore(dio: dio),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CupidTabBar), findsOneWidget);
    },
  );
}

class _InertRealtimeCoordinator implements RealtimeCoordinator {
  final StreamController<RealtimeStatus> _status =
      StreamController<RealtimeStatus>.broadcast();

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) => const Stream.empty();

  @override
  Stream<RealtimeStatus> get status => _status.stream;

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<void> resync() async {}

  @override
  Future<Object?> emit(String name, Object? payload) async => null;

  Future<void> dispose() => _status.close();
}

class _InertChatRepository implements ChatRepository {
  final StreamController<List<Message>> _thread =
      StreamController<List<Message>>();

  @override
  Stream<List<Message>> watchThread() => _thread.stream;

  @override
  Future<void> send(String text) async {}

  @override
  Future<void> sendImage(dynamic file) async {}

  @override
  Future<void> sendEmoji(String emojiCode) async {}

  @override
  Future<void> loadOlder() async {}

  @override
  Future<List<RealtimeEvent>> resyncPageOne() async => const <RealtimeEvent>[];

  @override
  Future<void> markSeen() async {}

  @override
  Stream<int> watchUnreadCount() => const Stream.empty();

  @override
  Future<void> dispose() async {
    // No listener when the Chat tab is never mounted, so awaiting `close()`
    // would hang (same reasoning as `app_shell_test.dart`).
    unawaited(_thread.close());
  }
}
