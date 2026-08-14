// Preview entrypoint — render ONE screen, already in the state you want to
// photograph, as the root of the app. DEV-ONLY scaffolding; never a release
// entrypoint, and it ships no real credentials.
//
// Why this exists: 35 of the design's screens sit behind auth, pairing and
// live backend data, so driving the real app to reach one is slow, flaky on a
// headless emulator, and dependent on state we do not control. A design-
// fidelity capture must FAKE the state, not navigate to it.
//
//   flutter run -t lib/main_preview.dart -d <device> --dart-define=PREVIEW=home
//
// Omit PREVIEW for an index of everything registered. Capture with:
//   .ai-team-bundle/runtime/tools/capture-mobile-screen.sh \
//     --out=<story>/visual-fidelity --label=<screen> --width=540
//
// The keys are the DESIGN canvas screen ids (render-design-canvas.js
// --list-screens), so an implementation capture and its design reference are
// named the same thing and cannot be mismatched by accident.
//
// STORY-018 P6 DEC-1: once running, screens can also be switched at runtime
// without a rebuild+install cycle by sending a `cupidpreview://screen/<id>`
// deep link (`mobile/android/app/src/debug/AndroidManifest.xml`), e.g.:
//   adb shell am start -a android.intent.action.VIEW -d "cupidpreview://screen/gallery"
// The compile-time `--dart-define=PREVIEW=<id>` path keeps working unchanged
// as a fallback if the route channel misbehaves on a given emulator.
//
// STORY-018 P6 DEC-3: pass `--dart-define=PREVIEW_EMAIL=` and
// `--dart-define=PREVIEW_PASSWORD=` to sign in for real before the app
// renders, for screens that need live, authenticated, paired backend state.
// Omit both for today's unauthenticated behaviour, unchanged.
import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/auth/cupid_session.dart';
import 'core/database/daos/expense_dao.dart';
import 'core/di/service_locator.dart';
import 'core/network/cupid_api.dart';
import 'core/realtime/backend_user_id_store.dart';
import 'core/realtime/cupid_realtime.dart';
import 'design_system/theme/cupid_platform.dart';
import 'design_system/theme/cupid_theme.dart';
import 'firebase_options.dart';
import 'l10n/generated/app_l10n.dart';
import 'preview/preview_app_shell_chrome.dart';
import 'preview/preview_not_implemented_screen.dart';
import 'preview/preview_reminder_fixture.dart';
import 'preview/preview_screen_entry.dart';
import 'preview/preview_session_bootstrap.dart';
import 'features/account/data/account_repository.dart';
import 'features/account/domain/cupid_profile.dart';
import 'features/account/data/notification_preferences_store.dart';
import 'features/account/presentation/screens/me_screen.dart';
import 'features/account/presentation/screens/notification_settings_screen.dart';
import 'features/account/presentation/screens/privacy_screen.dart';
import 'features/anti_ghosting/presentation/screens/anti_ghost_screen.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/firebase_sign_in_gateway.dart';
import 'features/auth/presentation/screens/forgot_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/chat/data/chat_events.dart';
import 'features/chat/data/chat_partner_store.dart';
import 'features/chat/data/chat_repository.dart';
import 'features/chat/data/ghost_consent_store.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/chat/presentation/screens/ghost_settings_screen.dart';
import 'features/dream_jar/data/dream_jar_repository.dart';
import 'features/dream_jar/presentation/screens/dream_jar_detail_screen.dart';
import 'features/dream_jar/presentation/screens/dream_jar_list_screen.dart';
import 'features/dream_jar/presentation/widgets/create_dream_jar_sheet.dart';
import 'features/expenses/data/expenses_repository.dart';
import 'features/expenses/presentation/screens/expense_history_screen.dart';
import 'features/gallery/presentation/screens/gallery_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/onboarding/presentation/screens/permissions_screen.dart';
import 'features/love_contracts/data/love_contract.dart';
import 'features/love_contracts/data/love_contract_repository.dart';
import 'features/love_contracts/presentation/screens/love_contract_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart';
import 'features/pairing/presentation/screens/invite_screen.dart';
import 'features/pairing/presentation/screens/joincode_screen.dart';
import 'features/pairing/presentation/screens/paired_screen.dart';
import 'features/pairing/presentation/screens/waiting_screen.dart';
import 'features/pet/presentation/pet_screen.dart';
import 'features/reminders/presentation/screens/reminder_schedule_screen.dart';
import 'features/timeline/data/timeline_repository.dart';
import 'features/timeline/presentation/screens/timeline_screen.dart';
import 'features/timeline/presentation/timeline_cubit.dart';
import 'features/vibes/presentation/vibe_screen.dart';
import 'features/vow/presentation/screens/vow_screen.dart';

/// STORY-018 P7 seeded dream-jar row + paired-couple ids so `getIt`-backed
/// repositories resolve real backend rows for the screens below instead of
/// 404ing against an empty seed.
const String _seededJarId = '8bed1e32-0f20-4634-8036-55abe21f28b7';

/// Screens that render from their own defaults today. STORY-018 P6 DEC-4:
/// each entry is `{builder, wrapInShell, seedNote}` rather than a bare
/// `WidgetBuilder`; `wrapInShell` is set per screen (P8) from the rule: it is
/// an `AppShell` tab destination (home/chat/gallery) or its P5 design
/// reference visibly shows the bottom tab bar.
final Map<String, PreviewScreenEntry>
previewScreens = <String, PreviewScreenEntry>{
  'alarm': const PreviewScreenEntry(builder: _buildAlarm),
  'antighost': const PreviewScreenEntry(builder: _buildAntighost),
  'chat': const PreviewScreenEntry(
    builder: _buildChat,
    wrapInShell: true,
    seedNote: 'AppShell chat tab destination; paired couple c0dd4c26/14833d65.',
  ),
  'contract': const PreviewScreenEntry(builder: _buildContract),
  'expense': const PreviewScreenEntry(
    builder: _buildExpense,
    wrapInShell: true,
    seedNote:
        'Design reference shows the shared bottom tab bar (Ví chung tab).',
  ),
  'forgot': const PreviewScreenEntry(builder: _buildForgot),
  'gallery': const PreviewScreenEntry(
    builder: _buildGallery,
    wrapInShell: true,
  ),
  'ghostset': const PreviewScreenEntry(
    builder: _buildGhostset,
    // The design reference shows the shared tab bar, but `app_shell.dart`'s
    // `_openGhostSettings` pushes this screen as a full-screen route ABOVE
    // the shell, so the real app never renders tab bar or account-hub FAB
    // here. Wrapping it would add chrome to the capture that runtime does
    // not have — recorded as a deviation in visual-fidelity-report.md
    // instead.
    seedNote: 'Pushed over AppShell as a full-screen route; no shell chrome.',
  ),
  'home': const PreviewScreenEntry(builder: _buildHome, wrapInShell: true),
  'invite': const PreviewScreenEntry(builder: _buildInvite),
  'jar': PreviewScreenEntry(
    builder: (BuildContext context) => DreamJarDetailScreen(
      jarId: _seededJarId,
      repository: getIt<DreamJarRepository>(),
    ),
    wrapInShell: true,
    seedNote:
        'Seeded jar $_seededJarId. Design reference shows the shared bottom tab bar (Ví chung tab).',
  ),
  'jarlist': const PreviewScreenEntry(
    builder: _buildJarlist,
    wrapInShell: true,
    seedNote:
        'Design reference shows the shared bottom tab bar (Ví chung tab).',
  ),
  'jarnew': const PreviewScreenEntry(
    builder: _buildJarnew,
    seedNote:
        'STORY-018 P8: design reference "Hũ mới" is the create-jar form, not '
        'contribution history — mapped to CreateDreamJarSheet (wrapped in a '
        'bare Scaffold for capture; it is normally opened as a modal sheet), '
        'not ContributionHistoryScreen (no canvas id of its own).',
  ),
  'joincode': const PreviewScreenEntry(builder: _buildJoincode),
  'login': const PreviewScreenEntry(builder: _buildLogin),
  'me': const PreviewScreenEntry(
    builder: _buildMe,
    wrapInShell: true,
    seedNote: 'Design reference shows the shared bottom tab bar (Tôi tab).',
  ),
  'notifs': const PreviewScreenEntry(
    builder: _buildNotifs,
    wrapInShell: true,
    seedNote: 'Design reference shows the shared bottom tab bar (Tôi tab).',
  ),
  'paired': const PreviewScreenEntry(
    builder: _buildPaired,
  ),
  'permissions': const PreviewScreenEntry(
    builder: _buildPermissions,
    seedNote:
        'Grant state is authored here, not requested from the OS: the design '
        'canvas composes notifications + fingerprint granted and photos '
        'not-yet-decided, and both card states must be in one capture.',
  ),
  'pet': const PreviewScreenEntry(
    builder: _buildPet,
  ),
  'privacy': const PreviewScreenEntry(
    builder: _buildPrivacy,
    wrapInShell: true,
    seedNote: 'Design reference shows the shared bottom tab bar (Tôi tab).',
  ),
  'profile': const PreviewScreenEntry(
    builder: _buildProfile,
    seedNote:
        'Canvas `profile` is the onboarding OnboardingProfileSetupScreen '
        '(STORY-010). CupidProfile is fetched live via '
        'AccountRepository.fetchProfile(); pass '
        '--dart-define=PREVIEW_PROFILE=fixture for a backend-free capture.',
  ),
  'register': const PreviewScreenEntry(builder: _buildRegister),
  'splash': const PreviewScreenEntry(builder: _buildSplash),
  'timeline': PreviewScreenEntry(
    builder: (BuildContext context) => TimelineScreen(
      createCubit: () => TimelineCubit(getIt<TimelineRepository>()),
    ),
    wrapInShell: true,
    seedNote: 'Design reference shows the shared bottom tab bar (Pet tab).',
  ),
  'vibe': const PreviewScreenEntry(builder: _buildVibe),
  'vow': const PreviewScreenEntry(
    builder: _buildVow,
    seedNote:
        'PREVIEW_VOW_STATE=idle|signed|both selects the AC4 confirmation '
        'state; the holding state is a live gesture, not a seed.',
  ),
  'waiting': const PreviewScreenEntry(builder: _buildWaiting),
  'welcome': const PreviewScreenEntry(builder: _buildWelcome),
  for (final String canvasId in _notImplementedCanvasIds)
    canvasId: PreviewScreenEntry(
      builder: (BuildContext context) =>
          PreviewNotImplementedScreen(canvasId: canvasId),
    ),
};

/// Design canvas ids with no shipped screen anywhere in this worktree yet
/// (`coding-plan/master-plan.md` §3). Rendered with
/// [PreviewNotImplementedScreen] so `implemented-<id>-*.png` exists at
/// capture time rather than being silently absent from the delivered set.
const List<String> _notImplementedCanvasIds = <String>[
  'otp',
  'shareapprove',
  'shareedit',
  'shareok',
  'sharepick',
  'themedetail',
  'themes',
  'zodiac',
];

/// STORY-016: `--dart-define=PREVIEW_VOW_STATE=<state>`
/// (`signed` | `both`) seeds the two confirmation states that follow a
/// completed vow, so each AC4 state can be screenshotted without a live
/// backend. Omit the define for the idle (`myNotVowed`) state.
const String _vowStateFixture = String.fromEnvironment('PREVIEW_VOW_STATE');

Widget _buildVow(BuildContext context) => VowScreen(
  selfVowed: _vowStateFixture == 'signed' || _vowStateFixture == 'both',
  partnerVowed: _vowStateFixture == 'both',
  selfInitial: 'M',
  partnerInitial: 'L',
);

/// STORY-021 F-1: `--dart-define=PREVIEW_REMINDER_STATE=<state>`
/// (`schedule` | `ringing`) swaps the DI-backed screen for a seeded fixture, so
/// the two AC-bearing states can be screenshotted on a capture emulator without
/// a live backend. Omit the define for today's unchanged live behaviour.
const String _reminderStateFixture = String.fromEnvironment(
  'PREVIEW_REMINDER_STATE',
);

Widget _buildAlarm(BuildContext context) => switch (_reminderStateFixture) {
  'schedule' => const PreviewReminderFixture(ringing: false),
  'ringing' => const PreviewReminderFixture(ringing: true),
  _ => const ReminderScheduleScreen(),
};

Widget _buildAntighost(BuildContext context) => const AntiGhostScreen();

Widget _buildChat(BuildContext context) => ChatScreen(
  repository: getIt<ChatRepository>(),
  coordinator: getIt<RealtimeCoordinator>(),
  backendUserIdStore: getIt<BackendUserIdStore>(),
  partnerStore: getIt<ChatPartnerStore>(),
  consentStore: _buildGhostConsentStore(),
);

/// STORY-019 P3: `--dart-define=PREVIEW_CONTRACT_SIGN_STATUS=<state>`
/// (`partnerAlreadySigned` | `bothSigned`) selects a fixture `LoveContract`
/// instead of the live `getIt<LoveContractRepository>()`, so the two new
/// viewer-aware sign states can be screenshotted for the P3 visual-fidelity
/// smoke check (no other state needs one — everything else was already
/// reachable). Omit the define for today's unchanged live-repository
/// behaviour.
const String _contractSignStatusFixture = String.fromEnvironment(
  'PREVIEW_CONTRACT_SIGN_STATUS',
);

Widget _buildContract(BuildContext context) {
  final LoveContract? fixture = _contractFixtureFor(_contractSignStatusFixture);
  return LoveContractScreen(
    repository: fixture == null
        ? getIt<LoveContractRepository>()
        : _PreviewLoveContractRepository(fixture),
    partnerDisplayName: fixture == null
        ? _noPartnerDisplayName
        : () => 'Minh Anh',
  );
}

String? _noPartnerDisplayName() => null;

LoveContract? _contractFixtureFor(String signStatus) {
  final DateTime now = DateTime.now();
  switch (signStatus) {
    case 'partnerAlreadySigned':
      return LoveContract(
        id: 'preview-contract',
        clauses: const <String>['Always tell the truth', "Don't sleep angry"],
        viewerRole: ContractViewerRole.partner,
        signedAtRequester: now,
        signedAtPartner: null,
      );
    case 'bothSigned':
      return LoveContract(
        id: 'preview-contract',
        clauses: const <String>[
          'Always tell the truth',
          "Don't sleep angry",
          'Check in once a day',
        ],
        viewerRole: ContractViewerRole.requester,
        signedAtRequester: now,
        signedAtPartner: now,
      );
    default:
      return null;
  }
}

/// Returns a fixed [LoveContract] instead of calling the backend. `sign()`
/// and `saveClauses()` are never reached from a static capture (mirrors the
/// `_PreviewUnusedAuthGateway` precedent above).
class _PreviewLoveContractRepository extends LoveContractRepository {
  _PreviewLoveContractRepository(this._fixture) : super(getIt<CupidApi>());

  final LoveContract _fixture;

  @override
  Future<LoveContract?> fetchCurrent() async => _fixture;

  @override
  Future<LoveContract> saveClauses(List<String> clauses) =>
      throw UnimplementedError();

  @override
  Future<LoveContract> sign() => throw UnimplementedError();
}

Widget _buildExpense(BuildContext context) => ExpenseHistoryScreen(
  repository: getIt<ExpensesRepository>(),
  dao: getIt<ExpenseDao>(),
  backendUserIdStore: getIt<BackendUserIdStore>(),
);

Widget _buildForgot(BuildContext context) =>
    ForgotScreen(authRepository: _buildAuthRepository());

Widget _buildGallery(BuildContext context) => const GalleryScreen();

/// `--dart-define=PREVIEW_GHOST_CONSENT=<off|pending|on>` pins the ADR-013e
/// consent level instead of deriving it from live backend + device state, so
/// all three AC3 states can be screenshotted. `on` additionally needs an
/// inbound `ghostTyping`, which no static capture can produce. Omit the
/// define for today's unchanged live behaviour.
const String _ghostConsentFixture =
    String.fromEnvironment('PREVIEW_GHOST_CONSENT');

/// `app_shell.dart`'s `_openGhostSettings` always supplies `onBack`, so a
/// capture built without one would be missing the header's back affordance.
void _previewNoOpBack() {}

Widget _buildGhostset(BuildContext context) {
  if (_ghostConsentFixture.isEmpty) {
    return GhostSettingsScreen(
      coordinator: getIt<RealtimeCoordinator>(),
      consentStore: _buildGhostConsentStore(),
      partnerStore: getIt<ChatPartnerStore>(),
      backendUserIdStore: getIt<BackendUserIdStore>(),
      onBack: _previewNoOpBack,
    );
  }
  final bool optedIn = _ghostConsentFixture != 'off';
  return GhostSettingsScreen(
    coordinator: _ghostConsentFixture == 'on'
        ? _PreviewGhostTypingCoordinator()
        : getIt<RealtimeCoordinator>(),
    consentStore: _PreviewGhostConsentStore(optedIn: optedIn),
    partnerStore: _PreviewChatPartnerStore(ghostModeEnabled: optedIn),
    backendUserIdStore: getIt<BackendUserIdStore>(),
    onBack: _previewNoOpBack,
  );
}

/// Pins `hasOptedIn` and drops the `PATCH /users/me` sync, which an
/// unauthenticated preview session cannot make.
class _PreviewGhostConsentStore extends GhostConsentStore {
  _PreviewGhostConsentStore({required this.optedIn})
      : super(dio: getIt<CupidApi>().dio);

  final bool optedIn;

  @override
  Future<bool> hasOptedIn() async => optedIn;

  @override
  Future<void> optIn() async {}

  @override
  Future<void> optOut() async {}
}

/// Pins the server-side `isGhostModeEnabled` flag `GhostCubit` reads at
/// construction; `refreshFromServer()` would otherwise leave it null.
class _PreviewChatPartnerStore extends ChatPartnerStore {
  _PreviewChatPartnerStore({required this.ghostModeEnabled})
      : super(dio: getIt<CupidApi>().dio);

  final bool ghostModeEnabled;

  @override
  bool? get isGhostModeEnabled => ghostModeEnabled;
}

/// Delivers one `ghostTyping` after subscription, the only thing that moves
/// `GhostCubit` from `pending` to `on`.
class _PreviewGhostTypingCoordinator implements RealtimeCoordinator {
  @override
  Stream<RealtimeEvent> events({Set<String>? names}) {
    if (names != null && !names.contains(ChatEvents.ghostTyping)) {
      return const Stream<RealtimeEvent>.empty();
    }
    return Stream<RealtimeEvent>.fromFuture(
      Future<RealtimeEvent>.delayed(
        const Duration(milliseconds: 300),
        () => GenericRealtimeEvent(
          name: ChatEvents.ghostTyping,
          id: null,
          data: const <String, dynamic>{'content': 'anh ăn cơm chưa'},
          transport: RealtimeTransport.socket,
          receivedAt: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Stream<RealtimeStatus> get status =>
      Stream<RealtimeStatus>.value(RealtimeStatus.live);

  @override
  Future<void> start() async {}

  @override
  Future<void> stop() async {}

  @override
  Future<Object?> emit(String name, Object? payload) async => null;

  @override
  Future<void> resync() async {}
}

/// STORY-017: `--dart-define=PREVIEW_HOME_FIXTURE=true` hands [HomeScreen] an
/// authored [CupidProfile] instead of `GET /users/me`, so the presence header,
/// days counter and milestone pill can be photographed without a live
/// authenticated session — the design-fidelity loop requires the captured
/// state to be faked, not driven. Values mirror the design source's own `home`
/// state (paired couple, same city, day 247). Same shape as STORY-019 P3's
/// `PREVIEW_CONTRACT_SIGN_STATUS` fixture above; omit the define for today's
/// unchanged live-repository behaviour.
const bool _homeFixture = bool.fromEnvironment('PREVIEW_HOME_FIXTURE');

Widget _buildHome(BuildContext context) =>
    _homeFixture ? HomeScreen(resolveProfile: _previewHomeProfile) : const HomeScreen();

Future<CupidProfile> _previewHomeProfile() async => CupidProfile(
  id: 'preview-home-user',
  email: 'preview.dev.a@cupid.test',
  language: 'vi',
  vowTaken: true,
  isGhostModeEnabled: false,
  displayName: 'Minh',
  relationshipStartDate: DateTime.now().subtract(const Duration(days: 247)),
  partnerId: 'preview-home-partner',
  coupleType: 'SAME_CITY',
);

Widget _buildInvite(BuildContext context) => const InviteScreen();

Widget _buildJarlist(BuildContext context) =>
    DreamJarListScreen(repository: getIt<DreamJarRepository>());

/// STORY-018 P8: the "jarnew" canvas is the create-jar form
/// ([CreateDreamJarSheet]), normally presented as a modal bottom sheet with
/// no `Scaffold`/app bar of its own — wrapped here in a bare [Scaffold] so it
/// has a capturable, full-frame surface like every other registry entry.
Widget _buildJarnew(BuildContext context) => Scaffold(
  body: SafeArea(
    child: CreateDreamJarSheet(repository: getIt<DreamJarRepository>()),
  ),
);

Widget _buildJoincode(BuildContext context) => const JoincodeScreen();

Widget _buildLogin(BuildContext context) =>
    LoginScreen(authRepository: _buildAuthRepository());

/// STORY-029: `--dart-define=PREVIEW_ME_FIXTURE=true` hands [MeScreen] an
/// authored [CupidProfile] instead of `GET /users/me`, same shape and reason
/// as [_homeFixture]. Values mirror the design source's own `me` state
/// (Linh, pisces, 03/03/2001, Ghost on, vi).
const bool _meFixture = bool.fromEnvironment('PREVIEW_ME_FIXTURE');

/// Mirrors `AppShell._openAccountHub`, the only production caller: it passes
/// no `AuthRepository`, and the design source's `me` screen has no sign-out
/// affordance. Supplying one here would render a row the shipped screen never
/// shows.
Widget _buildMe(BuildContext context) => MeScreen(
  accountRepository: getIt<AccountRepository>(),
  resolveProfile: _meFixture ? _previewMeProfile : null,
);

Future<CupidProfile> _previewMeProfile() async => CupidProfile(
  id: 'preview-me-user',
  email: 'preview.dev.b@cupid.test',
  language: 'vi',
  vowTaken: true,
  isGhostModeEnabled: true,
  displayName: 'Linh',
  birthday: DateTime(2001, 3, 3),
  zodiacSign: 'Pisces',
  partnerId: 'preview-me-partner',
  coupleType: 'SAME_CITY',
);

Widget _buildNotifs(BuildContext context) =>
    NotificationSettingsScreen(store: getIt<NotificationPreferencesStore>());

Widget _buildPaired(BuildContext context) => const PairedScreen();

Widget _buildPermissions(BuildContext context) => const PermissionsScreen(
  initiallyGranted: <OnboardingPermission>{
    OnboardingPermission.notifications,
    OnboardingPermission.biometric,
  },
);

Widget _buildPet(BuildContext context) => const PetScreen();
Widget _buildPrivacy(BuildContext context) =>
    PrivacyScreen(accountRepository: getIt<AccountRepository>());

/// STORY-018 P8: [OnboardingProfileSetupScreen] needs a real [CupidProfile],
/// only obtainable via [AccountRepository.fetchProfile()]'s async
/// `GET /users/me` (mirrors how [MeScreen]/`AccountCubit` reach it) —
/// [PreviewScreenEntry]'s builder is synchronous, so this wraps the fetch in a
/// [FutureBuilder].
/// STORY-010: `--dart-define=PREVIEW_PROFILE=fixture` swaps the live
/// `GET /users/me` for authored data, so the `profile` design-fidelity
/// capture does not depend on a seeded backend row (without it the frame is
/// a `CircularProgressIndicator`). Values mirror the design canvas's own
/// placeholders. Mirrors the `PREVIEW_CONTRACT_SIGN_STATUS` precedent above.
const String _profileFixtureMode = String.fromEnvironment('PREVIEW_PROFILE');

final CupidProfile _previewProfileFixture = CupidProfile(
  id: 'preview-user',
  email: 'linh@example.com',
  language: 'vi',
  vowTaken: false,
  isGhostModeEnabled: true,
  displayName: 'Linh',
  birthday: DateTime(2001, 3, 3),
);

/// Returns the fixture instead of calling the backend. `updateProfile()` is
/// never reached from a static capture (mirrors
/// [_PreviewLoveContractRepository]).
class _PreviewAccountRepository extends AccountRepository {
  _PreviewAccountRepository(this._fixture) : super(api: getIt<CupidApi>());

  final CupidProfile _fixture;

  @override
  Future<CupidProfile> fetchProfile() async => _fixture;
}

Widget _buildProfile(BuildContext context) {
  final AccountRepository repository = _profileFixtureMode == 'fixture'
      ? _PreviewAccountRepository(_previewProfileFixture)
      : getIt<AccountRepository>();
  return FutureBuilder<CupidProfile>(
    future: repository.fetchProfile(),
    builder: (BuildContext context, AsyncSnapshot<CupidProfile> snapshot) {
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      return OnboardingProfileSetupScreen(
        profile: snapshot.data!,
        // The capture harness has no onward destination; STORY-002 owns the
        // real transition.
        onContinue: () {},
      );
    },
  );
}

Widget _buildRegister(BuildContext context) =>
    RegisterScreen(authRepository: _buildAuthRepository());

Widget _buildSplash(BuildContext context) =>
    SplashScreen(authRepository: _buildAuthRepository());

Widget _buildVibe(BuildContext context) => const VibeScreen();

Widget _buildWaiting(BuildContext context) => WaitingScreen(
  expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  // The design canvas' own sample code, so the capture and its reference show
  // the same string in the "Mã của bạn" card.
  code: 'CPD-8F2K',
);

Widget _buildWelcome(BuildContext context) =>
    WelcomeScreen(authRepository: _buildAuthRepository());

/// STORY-018 P8: `FirebaseSignInGateway` has no concrete implementation
/// anywhere in this worktree yet (`features/auth/data/
/// firebase_sign_in_gateway.dart`'s own doc comment: "out of this phase's
/// write scope"), so `AuthRepository` cannot be built from a real gateway.
/// Mirrors the same no-op stub the auth screens' own widget tests already use
/// (`test/features/auth/presentation/splash_screen_test.dart`'s
/// `_UnusedGateway`) — every method throws, which is safe here because these
/// screens only call it from a button tap, never during a static capture.
class _PreviewUnusedAuthGateway implements FirebaseSignInGateway {
  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> registerWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) => throw UnimplementedError();

  @override
  Future<void> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<void> signInWithApple() => throw UnimplementedError();

  @override
  Future<void> signInWithFacebook() => throw UnimplementedError();

  @override
  Future<void> sendEmailVerification() => throw UnimplementedError();

  @override
  Future<void> sendPasswordResetEmail(String email) =>
      throw UnimplementedError();

  @override
  Future<bool> reloadEmailVerified() => throw UnimplementedError();
}

AuthRepository _buildAuthRepository() => AuthRepository(
  gateway: _PreviewUnusedAuthGateway(),
  api: getIt<CupidApi>(),
  signOut: () => getIt<CupidSession>().signOut(),
);

/// [GhostConsentStore] is not `getIt`-registered (STORY-018 P8 finding);
/// mirrors the established inline-construction precedent at
/// `core/navigation/app_shell.dart`'s own `AppShell` default.
GhostConsentStore _buildGhostConsentStore() =>
    GhostConsentStore(dio: getIt<CupidApi>().dio);

/// All 37 design canvas ids are registered above; nothing is left needing a
/// fixture (STORY-018 P8).
const List<String> needsFixtures = <String>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupServiceLocator();
  await bootstrapPreviewSession();
  runApp(const PreviewApp());
}

class PreviewApp extends StatefulWidget {
  const PreviewApp({super.key});

  @override
  State<PreviewApp> createState() => _PreviewAppState();
}

class _PreviewAppState extends State<PreviewApp> with WidgetsBindingObserver {
  static const String _initialTarget = String.fromEnvironment('PREVIEW');
  static const String _brightness = String.fromEnvironment(
    'PREVIEW_BRIGHTNESS',
    defaultValue: 'dark',
  );

  /// STORY-017: `--dart-define=PREVIEW_PLATFORM=ios|material` renders the
  /// other platform silhouette on whichever device is available, so AC4's two
  /// tab-bar variants can both be photographed without a second simulator.
  /// [CupidPlatformOverride] exists for exactly this; omit the define for the
  /// host device's own platform.
  static const String _platformOverride =
      String.fromEnvironment('PREVIEW_PLATFORM');

  /// STORY-018 P6 DEC-1: mutable so a runtime `cupidpreview://screen/<id>`
  /// deep link can switch the rendered screen without a rebuild+install
  /// cycle. Starts from the compile-time `--dart-define=PREVIEW=<id>` value
  /// and is only ever overwritten by a recognised runtime route.
  String _currentTarget = _initialTarget;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<bool> didPushRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final Uri uri = routeInformation.uri;
    // `cupidpreview://screen/<id>`
    // (`mobile/android/app/src/debug/AndroidManifest.xml`). Any other
    // scheme/host is ignored rather than crashing the harness on an
    // unrelated deep link delivered to the same debug build.
    if (uri.scheme != 'cupidpreview' || uri.host != 'screen') {
      return false;
    }
    final String? id = uri.pathSegments.isNotEmpty
        ? uri.pathSegments.first
        : null;
    if (id == null || !previewScreens.containsKey(id)) {
      return false;
    }
    setState(() => _currentTarget = id);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final CupidPlatform platform = switch (_platformOverride) {
      'ios' => CupidPlatform.ios,
      'material' => CupidPlatform.material,
      _ => CupidPlatform.of(context),
    };
    final Brightness brightness =
        _brightness == 'light' ? Brightness.light : Brightness.dark;
    final PreviewScreenEntry? entry = previewScreens[_currentTarget];

    return CupidPlatformOverride(
      platform: platform,
      child: MaterialApp(
        title: 'Cupid preview',
        // The debug banner overlaps the top-right of every capture and would
        // read as a design delta that is not real.
        debugShowCheckedModeBanner: false,
        // Reuse the app's own theme builder rather than a stand-in: a preview
        // rendered against different tokens would prove nothing about fidelity.
        theme: buildCupidTheme(platform: platform, brightness: brightness),
        themeMode: ThemeMode.light,
        // Pin locale and text scale. A host device with a system font-size
        // override would silently change every measurement in the capture.
        locale: const Locale('vi'),
        localizationsDelegates: AppL10n.localizationsDelegates,
        supportedLocales: AppL10n.supportedLocales,
        builder: (BuildContext context, Widget? child) =>
            MediaQuery.withNoTextScaling(child: child ?? const SizedBox.shrink()),
        home: entry != null
            ? _PreviewScreen(screenId: _currentTarget, entry: entry)
            : const _PreviewIndex(),
      ),
    );
  }
}

/// Builds one registry entry, applying its DEC-4 `AppShell`/`CupidTabBar`
/// chrome opt-in.
class _PreviewScreen extends StatelessWidget {
  const _PreviewScreen({required this.screenId, required this.entry});

  final String screenId;
  final PreviewScreenEntry entry;

  @override
  Widget build(BuildContext context) {
    final Widget screen = Builder(builder: entry.builder);
    if (!entry.wrapInShell) {
      return screen;
    }
    final PreviewAppShellTab? tab = switch (screenId) {
      'home' => PreviewAppShellTab.home,
      'chat' => PreviewAppShellTab.chat,
      'gallery' => PreviewAppShellTab.gallery,
      _ => null,
    };
    return PreviewAppShellChrome(activeTab: tab, child: screen);
  }
}

/// Shown when PREVIEW is unset or names an unregistered screen. Listing the
/// valid keys turns a typo into a one-line fix instead of a blank screen.
class _PreviewIndex extends StatelessWidget {
  const _PreviewIndex();

  @override
  Widget build(BuildContext context) {
    final List<String> keys = previewScreens.keys.toList()..sort();
    return Scaffold(
      appBar: AppBar(title: const Text('Preview screens')),
      body: ListView(
        children: <Widget>[
          for (final String k in keys)
            ListTile(
              title: Text(k),
              subtitle: Text('--dart-define=PREVIEW=$k'),
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) =>
                      _PreviewScreen(screenId: k, entry: previewScreens[k]!),
                ),
              ),
            ),
          if (needsFixtures.isNotEmpty) ...<Widget>[
            const Divider(),
            const ListTile(
              title: Text('Needs fixtures'),
              subtitle: Text(
                'constructors require repositories/cubits/row data',
              ),
            ),
            for (final String k in needsFixtures)
              ListTile(
                dense: true,
                title: Text(k, style: const TextStyle(color: Colors.grey)),
              ),
          ],
        ],
      ),
    );
  }
}
