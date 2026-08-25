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

import 'package:drift/native.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'core/auth/cupid_session.dart';
// The Drift row type of the same name is never used here, and the timeline
// fixture below needs the domain one.
import 'core/database/cupid_database.dart' hide TimelineEntry;
import 'core/database/daos/expense_dao.dart';
import 'core/di/service_locator.dart';
import 'core/navigation/onboarding_chain.dart';
import 'core/network/cupid_api.dart';
import 'core/realtime/backend_user_id_store.dart';
import 'core/realtime/cupid_realtime.dart';
import 'design_system/icons/cupid_zodiac_icon.dart';
import 'design_system/theme/cupid_app_background.dart';
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
import 'features/anti_ghosting/data/ghost_config_models.dart';
import 'features/anti_ghosting/data/ghost_config_repository.dart';
import 'features/anti_ghosting/presentation/screens/anti_ghost_screen.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/data/firebase_sign_in_gateway.dart';
import 'features/auth/presentation/screens/forgot_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/otp_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/chat/data/chat_events.dart';
import 'features/chat/data/chat_partner_store.dart';
import 'features/chat/data/chat_repository.dart';
import 'features/chat/data/ghost_consent_store.dart';
import 'features/chat/presentation/screens/chat_screen.dart';
import 'features/chat/presentation/screens/ghost_settings_screen.dart';
import 'features/dream_jar/data/dream_jar.dart';
import 'features/dream_jar/data/dream_jar_repository.dart';
import 'features/dream_jar/presentation/screens/dream_jar_detail_screen.dart';
import 'features/dream_jar/presentation/screens/dream_jar_list_screen.dart';
import 'features/dream_jar/presentation/widgets/create_dream_jar_sheet.dart';
import 'features/expenses/data/expense_category.dart';
import 'features/expenses/data/expense_models.dart';
import 'features/expenses/data/expenses_repository.dart';
import 'features/expenses/presentation/screens/expense_history_screen.dart';
import 'features/gallery/presentation/screens/gallery_screen.dart';
import 'features/home/presentation/home_screen.dart';
import 'features/onboarding/presentation/screens/permissions_screen.dart';
import 'features/love_contracts/data/love_contract.dart';
import 'features/love_contracts/data/love_contract_repository.dart';
import 'features/love_contracts/presentation/screens/love_contract_screen.dart';
import 'features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart';
import 'features/pairing/data/pairing_failure.dart';
import 'features/pairing/data/pairing_invitation.dart';
import 'features/pairing/data/partner_link.dart';
import 'features/pairing/presentation/invite_cubit.dart';
import 'features/pairing/presentation/joincode_cubit.dart';
import 'features/pairing/presentation/screens/invite_screen.dart';
import 'features/pairing/presentation/screens/joincode_screen.dart';
import 'features/pairing/presentation/screens/paired_screen.dart';
import 'features/pairing/presentation/screens/waiting_screen.dart';
import 'features/pairing/presentation/waiting_cubit.dart';
import 'features/pet/data/pet_models.dart';
import 'features/pet/data/pet_mood.dart';
import 'features/pet/data/pet_repository.dart';
import 'features/pet/presentation/pet_screen.dart';
import 'features/reminders/presentation/screens/reminder_schedule_screen.dart';
import 'features/timeline/data/timeline_event_dto.dart';
import 'features/timeline/data/timeline_repository.dart';
import 'features/timeline/domain/timeline_entry.dart';
import 'features/timeline/presentation/screens/timeline_screen.dart';
import 'features/timeline/presentation/timeline_cubit.dart';
import 'features/vibes/presentation/vibe_screen.dart';
import 'features/vow/presentation/screens/vow_screen.dart';
import 'features/zodiac/data/zodiac_repository.dart';
import 'features/zodiac/domain/zodiac_red_flag.dart';
import 'features/zodiac/presentation/zodiac_cubit.dart';
import 'features/zodiac/presentation/zodiac_red_flag_screen.dart';

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
    // The design reference shows the shared tab bar, but `home_screen.dart`'s
    // `_ExpensesEntryCard` pushes `ExpensesEntryPoint` onto the root navigator
    // (`app_shell.dart` builds tab bodies directly, with no nested Navigator),
    // so runtime renders this screen above the shell with neither tab bar nor
    // account-hub FAB. Wrapping it also painted that FAB over this screen's own
    // `CupidAddAction` — same call as `ghostset`: capture what runtime shows and
    // record the tab-bar difference in visual-fidelity-report.md instead.
    seedNote:
        'Pushed over AppShell as a full-screen route; no shell chrome. '
        '--dart-define=PREVIEW_EXPENSE_FIXTURE=true seeds the design canvas '
        'own expense rows, month total and weekday profile.',
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
  'invite': const PreviewScreenEntry(
    builder: _buildInvite,
    seedNote:
        "Design canvas' own sample invitation (CPD-8F2K, 24h TTL); without it "
        'the unauthenticated preview renders InviteFailed.',
  ),
  'jar': const PreviewScreenEntry(
    builder: _buildJar,
    wrapInShell: true,
    seedNote:
        'Seeded jar $_seededJarId, or the design fixture under '
        '--dart-define=PREVIEW_JAR_FIXTURE=design. Design reference shows the '
        'shared bottom tab bar (Ví chung tab).',
  ),
  'jarlist': const PreviewScreenEntry(
    builder: _buildJarlist,
    wrapInShell: true,
    seedNote:
        'Design reference shows the shared bottom tab bar (Ví chung tab). '
        '--dart-define=PREVIEW_JARLIST_FIXTURE=empty|ready seeds the two '
        'states that carry the header contract; without it the '
        'unauthenticated preview renders DreamJarListFailed.',
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
  'otp': const PreviewScreenEntry(builder: _buildOtp),
  'paired': const PreviewScreenEntry(
    builder: _buildPaired,
  ),
  'pairingchoice': const PreviewScreenEntry(
    builder: _buildPairingChoice,
    seedNote:
        'Design reference restored under `isPairingChoice` in STORY-002 P1; '
        'compare against design-reference-pairingchoice-android.png.',
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
  'register': const PreviewScreenEntry(
    builder: _buildRegister,
    seedNote:
        "Design source's own filled row (Minh / minh@gmail.com / loveyou247); "
        'the reference renders every field populated.',
  ),
  'splash': const PreviewScreenEntry(builder: _buildSplash),
  'timeline': const PreviewScreenEntry(
    builder: _buildTimeline,
    wrapInShell: true,
    seedNote:
        'Design reference shows the shared bottom tab bar (Pet tab). '
        '--dart-define=PREVIEW_TIMELINE_FIXTURE=true seeds the countdown '
        'anchor and the design canvas own five timeline rows.',
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
  'zodiac': const PreviewScreenEntry(
    builder: _buildZodiac,
    // Pushed above `AppShell` by `Navigator.pushNamed`, so no tab bar at
    // runtime — the `ghostset`/`expense` precedent above. The design reference
    // does draw the tab bar; that difference is recorded in
    // `visual-fidelity/visual-fidelity-report.md` rather than faked here.
    seedNote:
        'PREVIEW_ZODIAC_STATE=ready|incomplete selects the loaded three-card '
        'state or the AC3 degraded state; both are served from a fixture '
        'repository, never a live GET /zodiac/red-flag/today.',
  ),
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
  'shareapprove',
  'shareedit',
  'shareok',
  'sharepick',
  'themedetail',
  'themes',
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

/// STORY-041: `--dart-define=PREVIEW_ANTIGHOST=state-a|state-b` swaps the
/// DI-backed `GhostConfigRepository` for a fixture. `AntiGhostCubit.load()`
/// derives the lifecycle from two authenticated `ghost-config` fetches, so an
/// unauthenticated preview only ever reaches `AntiGhostLoadFailed` and none of
/// the AC-bearing controls is capturable. `state-a` serves the propose form
/// (threshold segmented control + penalty selector); `state-b` serves
/// `AntiGhostPendingMine`, whose waiting badge and disabled controls preview
/// have no other capturable route. Omit the define for today's unchanged
/// live-repository behaviour.
const String _antighostFixture = String.fromEnvironment('PREVIEW_ANTIGHOST');

const String _previewAntighostSelfId = 'preview-antighost-self';

/// State B's proposal, on a preset threshold so the disabled segmented control
/// renders its selected segment rather than the custom-minutes fallback.
final GhostConfig _previewPendingGhostConfig = GhostConfig(
  id: 'preview-ghost-config',
  coupleId: 'preview-couple',
  timeoutMinutes: 10,
  penalty: Penalty.emojiStorm,
  publicCountdown: true,
  proposedBy: _previewAntighostSelfId,
  approvedBy: null,
  status: ConfigStatus.pendingApproval,
  createdAt: DateTime(2026, 8, 16),
  updatedAt: DateTime(2026, 8, 16),
);

/// Serves State A (`AntiGhostNoConfig`) or State B (`AntiGhostPendingMine`).
/// The mutating calls are never reached from a static capture (mirrors
/// [_PreviewChatRepository] below).
class _PreviewGhostConfigRepository implements GhostConfigRepository {
  _PreviewGhostConfigRepository({required this.pending});

  final bool pending;

  @override
  Future<GhostConfig?> fetchActive() async => null;

  @override
  Future<List<GhostConfig>> fetchPending() async => pending
      ? <GhostConfig>[_previewPendingGhostConfig]
      : const <GhostConfig>[];

  @override
  Future<GhostConfig> propose({
    required int timeoutMinutes,
    required Penalty penalty,
    bool publicCountdown = true,
  }) => throw UnimplementedError();

  @override
  Future<GhostConfig> approve(String id) => throw UnimplementedError();

  @override
  Future<GhostConfig> reject(String id) => throw UnimplementedError();

  @override
  Future<StormStatus> fetchStormStatus(String partnerId) =>
      throw UnimplementedError();
}

/// STORY-040: `--dart-define=PREVIEW_CHAT_GHOST=on` renders `chat` with the
/// Typing Ghost bubble already on screen. The bubble is pure ephemeral
/// realtime state — it exists only while an inbound `ghostTyping` diff is
/// live, is never persisted (`architecture/solution.md` §2 invariant 3), and
/// cannot be reached by navigation — so the AC4 fade/strikethrough treatment
/// has no capturable state without this fixture. Omit the define for today's
/// unchanged live-repository behaviour.
const String _chatGhostFixture = String.fromEnvironment('PREVIEW_CHAT_GHOST');

const String _previewChatSelfId = 'preview-chat-self';
const String _previewChatPartnerId = 'preview-chat-partner';

Widget _buildChat(BuildContext context) {
  if (_chatGhostFixture != 'on') {
    return ChatScreen(
      repository: getIt<ChatRepository>(),
      coordinator: getIt<RealtimeCoordinator>(),
      backendUserIdStore: getIt<BackendUserIdStore>(),
      partnerStore: getIt<ChatPartnerStore>(),
      consentStore: _buildGhostConsentStore(),
    );
  }
  return ChatScreen(
    repository: _PreviewChatRepository(),
    coordinator: _PreviewGhostTypingCoordinator(replayDeletion: true),
    backendUserIdStore: BackendUserIdStore()
      ..updateFromLoginResponse(
        const <String, dynamic>{'id': _previewChatSelfId},
      ),
    partnerStore: _PreviewChatPartnerStore(
      ghostModeEnabled: true,
      partnerId: _previewChatPartnerId,
      selfDisplayName: 'Minh',
      partnerDisplayName: 'Linh',
    ),
    consentStore: _PreviewGhostConsentStore(optedIn: true),
  );
}

/// Replays the design source's own three-message `chat` thread instead of
/// Drift + `GET /messages`. `send`/`loadOlder` are never reached from a
/// static capture (mirrors [_PreviewLoveContractRepository] below).
class _PreviewChatRepository implements ChatRepository {
  static final DateTime _day = DateTime(2026, 8, 16);

  @override
  Stream<List<Message>> watchThread() =>
      Stream<List<Message>>.value(<Message>[
        _message('m1', _previewChatSelfId, 'Anh ăn cơm chưa?', 20, 41),
        _message('m2', _previewChatPartnerId, 'Chưa, đang fix bug 😩', 20, 42),
        _message(
          'm3',
          _previewChatSelfId,
          'Lại bug. Bug với em, chọn một 🔪',
          20,
          44,
        ),
      ]);

  static Message _message(
    String id,
    String senderId,
    String content,
    int hour,
    int minute,
  ) {
    final DateTime at = _day.add(Duration(hours: hour, minutes: minute));
    return Message(
      id: id,
      senderId: senderId,
      receiverId: senderId == _previewChatSelfId
          ? _previewChatPartnerId
          : _previewChatSelfId,
      content: content,
      type: 'text',
      status: 'seen',
      createdAt: at,
      cachedAt: at,
    );
  }

  @override
  Future<void> send(String text) async {}

  @override
  Future<void> loadOlder() async {}

  @override
  Future<List<RealtimeEvent>> resyncPageOne() async => const <RealtimeEvent>[];

  @override
  Future<void> markSeen() async {}

  @override
  Future<void> dispose() async {}
}

/// STORY-019 P3: `--dart-define=PREVIEW_CONTRACT_SIGN_STATUS=<state>`
/// (`requesterUnsigned` | `partnerAlreadySigned` | `bothSigned`) selects a
/// fixture `LoveContract` instead of the live `getIt<LoveContractRepository>()`,
/// so the viewer-aware sign states can be screenshotted for the P3
/// visual-fidelity smoke check (no other state needs one — everything else was
/// already reachable). Omit the define for today's unchanged live-repository
/// behaviour.
///
/// STORY-049 added `requesterUnsigned`: the add-clause row is gated on
/// `canEditClauses`, which ADR-019e derives from `viewerRole` alone, so this is
/// the only fixture that paints that row *in the same sign state as the design
/// canvas's `myUnsigned` branch* — the comparison D-7/D-8 needed.
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
    case 'requesterUnsigned':
      return LoveContract(
        id: 'preview-contract',
        clauses: const <String>['Always tell the truth', "Don't sleep angry"],
        viewerRole: ContractViewerRole.requester,
        signedAtRequester: null,
        signedAtPartner: null,
      );
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

/// STORY-043: `--dart-define=PREVIEW_EXPENSE_FIXTURE=true` seeds this screen.
/// `ExpenseHistoryCubit` is a read-through cache over `GET /expenses` + Drift;
/// an unauthenticated preview resolves neither, so the capture is the
/// `isNeverSynced` empty state and none of the AC-bearing surfaces (summary
/// card, weekday chart, category chips, list card, rows, add action) is
/// reachable. Omit the define for today's unchanged live-repository behaviour.
const bool _expenseFixture = bool.fromEnvironment('PREVIEW_EXPENSE_FIXTURE');

const String _previewExpenseSelfId = 'preview-expense-self';
const String _previewExpensePartnerId = 'preview-expense-partner';

/// Isolated from the device's own `cupid.sqlite` so the seeded page is exactly
/// the rows below on every run, with no residue from a prior preview session.
final CupidDatabase _previewExpenseDatabase = CupidDatabase(
  NativeDatabase.memory(),
);

Widget _buildExpense(BuildContext context) {
  if (!_expenseFixture) {
    return ExpenseHistoryScreen(
      repository: getIt<ExpensesRepository>(),
      dao: getIt<ExpenseDao>(),
      backendUserIdStore: getIt<BackendUserIdStore>(),
    );
  }
  return ExpenseHistoryScreen(
    repository: _PreviewExpensesRepository(),
    dao: _previewExpenseDatabase.expenseDao,
    backendUserIdStore: BackendUserIdStore()
      ..updateFromLoginResponse(
        const <String, dynamic>{'id': _previewExpenseSelfId},
      ),
  );
}

/// Replays the design source's own `expense` state (`Cupid Screens.dc.html`
/// L843-886) instead of `GET /expenses`: the five list rows it draws, plus the
/// filler rows the "Xem tất cả 18 khoản" footer implies, weighted so
/// `ExpenseMonthSummary` derives the canvas' own 4.350.000₫ total, 18-item
/// count and 7-bucket bar profile. The previous-month rows exist only to make
/// the delta visible at all — `ExpenseMonthSummary` hides it unless the cache
/// reaches back to the first day of that month. `create` is never reached from
/// a static capture (mirrors [_PreviewChatRepository]).
///
/// Day-of-month is anchored to the capture month rather than a literal date,
/// so the summary never falls outside its own month on a later capture. Every
/// day used is <= 17, which exists in every month; the canvas' exact bar
/// profile additionally requires the capture month to start on a Saturday, as
/// August 2026 does.
class _PreviewExpensesRepository implements ExpensesRepository {
  @override
  Future<List<Expense>> fetchPage({int limit = 50, int offset = 0}) async {
    if (offset > 0) return const <Expense>[];
    final DateTime now = DateTime.now();
    int seq = 0;
    Expense row(
      int monthOffset,
      int day,
      num amount,
      ExpenseCategory category,
      bool own,
      String? description,
    ) {
      final DateTime date = DateTime(now.year, now.month + monthOffset, day);
      seq++;
      return Expense(
        id: 'preview-expense-$seq',
        userId: own ? _previewExpenseSelfId : _previewExpensePartnerId,
        category: category,
        amountVnd: amount,
        description: description,
        // Distinct per row so the two same-day rows keep the canvas' order
        // under the DAO's `date DESC, createdAt DESC` paging.
        date: date,
        createdAt: date.add(Duration(minutes: 100 - seq)),
      );
    }

    return <Expense>[
      // The five rows the canvas actually draws, newest first.
      row(0, 17, 480000, ExpenseCategory.food, true, 'Lẩu ở Nguyễn Huệ'),
      row(0, 16, 96000, ExpenseCategory.other, false, 'Trà sữa hoà giải'),
      row(0, 15, 260000, ExpenseCategory.shopping, true, 'Xem phim, hàng cuối'),
      row(0, 15, 132000, ExpenseCategory.travel, false, 'Grab về nhà, 1h sáng'),
      row(0, 14, 215000, ExpenseCategory.date, true, 'Quà cho Bún (đồ ăn mèo thật)'),
      // Filler rows: below the fold, but they carry the total, the item count
      // and the chart profile.
      row(0, 13, 525000, ExpenseCategory.food, false, 'Đi chợ cuối tuần'),
      row(0, 12, 240000, ExpenseCategory.other, true, 'Thuốc cho Bún'),
      row(0, 11, 415000, ExpenseCategory.travel, false, 'Vé xe về quê'),
      row(0, 10, 30000, ExpenseCategory.other, true, 'Gửi xe'),
      row(0, 9, 154000, ExpenseCategory.food, false, 'Bánh mì sáng'),
      row(0, 8, 218000, ExpenseCategory.shopping, true, 'Áo mưa đôi'),
      row(0, 7, 185000, ExpenseCategory.food, false, 'Cà phê góc phố'),
      row(0, 7, 200000, ExpenseCategory.date, true, 'Vé sở thú'),
      row(0, 6, 400000, ExpenseCategory.travel, false, 'Xăng xe cả tuần'),
      row(0, 5, 200000, ExpenseCategory.other, true, 'Sửa quạt'),
      row(0, 4, 300000, ExpenseCategory.shopping, false, 'Gối ôm mới'),
      row(0, 2, 100000, ExpenseCategory.food, true, 'Trà chanh vỉa hè'),
      row(0, 1, 200000, ExpenseCategory.date, false, 'Xem phim đầu tháng'),
      // Previous month, ending on its first day so the delta is not hidden.
      row(-1, 28, 1500000, ExpenseCategory.travel, true, 'Chuyến Vũng Tàu'),
      row(-1, 15, 1200000, ExpenseCategory.food, false, 'Sinh nhật Linh'),
      row(-1, 1, 1200000, ExpenseCategory.shopping, true, 'Nồi chiên không dầu'),
    ];
  }

  @override
  Future<Expense> create({
    required ExpenseCategory category,
    required num amountVnd,
    String? description,
    required DateTime date,
  }) => throw UnimplementedError();
}

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
/// construction; `refreshFromServer()` would otherwise leave it null. The two
/// names are supplied independently so a capture can show the caller and the
/// partner as the distinct people the design source renders.
class _PreviewChatPartnerStore extends ChatPartnerStore {
  _PreviewChatPartnerStore({
    required this.ghostModeEnabled,
    this.partnerId,
    this.selfDisplayName,
    this.partnerDisplayName,
  }) : super(dio: getIt<CupidApi>().dio);

  final bool ghostModeEnabled;

  @override
  final String? partnerId;

  @override
  final String? selfDisplayName;

  @override
  final String? partnerDisplayName;

  @override
  bool? get isGhostModeEnabled => ghostModeEnabled;
}

/// Delivers one `ghostTyping` after subscription, the only thing that moves
/// `GhostCubit` from `pending` to `on`. With [replayDeletion] it instead
/// loops a typed-then-deleted pair, because the struck-through tail is a
/// receiver-side diff of two consecutive events and `GhostCubit` clears the
/// bubble `ghostReceiverStaleExpiryDuration` after the last one — a one-shot
/// stream leaves nothing on screen by the time a capture lands.
class _PreviewGhostTypingCoordinator implements RealtimeCoordinator {
  _PreviewGhostTypingCoordinator({this.replayDeletion = false});

  final bool replayDeletion;

  static const String _ghostKept = 'anh xin lỗi, ';
  static const String _ghostStruck = 'em sai rồi';

  @override
  Stream<RealtimeEvent> events({Set<String>? names}) {
    if (names != null && !names.contains(ChatEvents.ghostTyping)) {
      return const Stream<RealtimeEvent>.empty();
    }
    if (replayDeletion) return _replayDeletion();
    return Stream<RealtimeEvent>.fromFuture(
      Future<RealtimeEvent>.delayed(
        const Duration(milliseconds: 300),
        () => _typing('anh ăn cơm chưa'),
      ),
    );
  }

  Stream<RealtimeEvent> _replayDeletion() async* {
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 300));
      yield _typing('$_ghostKept$_ghostStruck');
      await Future<void>.delayed(const Duration(milliseconds: 250));
      yield _typing(_ghostKept);
      // Shorter than the 6s stale expiry, so the struck tail never blanks.
      await Future<void>.delayed(const Duration(seconds: 5));
    }
  }

  RealtimeEvent _typing(String content) => GenericRealtimeEvent(
    name: ChatEvents.ghostTyping,
    id: null,
    data: <String, dynamic>{'content': content},
    transport: RealtimeTransport.socket,
    receivedAt: DateTime.now(),
  );

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

/// STORY-003: `--dart-define=PREVIEW_PET_FIXTURE=true` hands [HomeScreen] an
/// authored [PetRepository] so the Bún preview card resolves to `PetReady`
/// instead of the `PetFailure` state an unauthenticated `GET /users/me`
/// produces — the ready variant is the only one the design source depicts, so
/// without this the capture photographs "Không thể tải Bún". Same
/// `bool.fromEnvironment` shape as [_homeFixture]; omit it for today's
/// unchanged live-repository behaviour.
const bool _petFixture = bool.fromEnvironment('PREVIEW_PET_FIXTURE');

Widget _buildHome(BuildContext context) => HomeScreen(
  resolveProfile: _homeFixture ? _previewHomeProfile : null,
  petRepository: _petFixture ? _PreviewPetRepository() : null,
);

/// Resolves straight to the design canvas' own pet state (`Cupid Screens.dc.html`
/// line 1979: `petXp: 62, petLv: 3`, species `bun`) without touching the
/// network. `PetCubit.load()` reaches `PetReady` when `readPairing()` reports
/// paired and `readStatus()` returns a non-null status, so both are authored.
///
/// `totalInteractions: 131` is chosen against the backend's frozen level math,
/// not picked to look right: `floor(131 / 50) + 1 == 3` reproduces the canvas'
/// `Lv.3`, and `(131 % 50) / 50 == 0.62` reproduces its 62% bar fill.
///
/// `interact()` and `adopt()` are never reached from a static capture (mirrors
/// the [_PreviewDreamJarRepository] precedent).
class _PreviewPetRepository implements PetRepository {
  @override
  Future<PetPairing> readPairing() async => const PetPairing(isPaired: true);

  @override
  Future<PetStatus?> readStatus() async => const PetStatus(
    pet: Pet(
      id: 'preview-pet',
      coupleId: 'preview-couple',
      species: PetSpecies.bunny,
      name: 'Bún',
      happiness: 62,
      level: 3,
      totalInteractions: 131,
      // Null keeps the cubit out of its cooldown branch, so the capture is a
      // settled frame rather than a ticking countdown.
      lastInteraction: null,
    ),
    // `petXp: 62` falls in the canvas' `neutral` sprite band, which
    // `BunSpriteState.fromMood` reaches from `PetMood.content` — the same mood
    // whose status line is the canvas' own "đòi được để ý một chút".
    mood: PetMood.content,
    decayedHappiness: 62,
    milestone: null,
    nextMilestone: 150,
  );

  @override
  Future<PetStatus> interact() => throw UnimplementedError();

  @override
  Future<PetStatus> adopt({
    required PetSpecies species,
    required String name,
  }) => throw UnimplementedError();
}

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

/// STORY-037: without an injected cubit, [InviteScreen] resolves its code from
/// `getIt<PairingRepository>().generateInvitation`, which needs an
/// authenticated, paired-capable backend session this preview does not have —
/// the capture then shows `InviteFailed`, never the code card this canvas id
/// names. The fixture never calls the backend and seeds the design canvas' own
/// sample code, so the capture and its reference show the same string in the
/// "Mã ghép đôi của bạn" card (mirrors [_buildWaiting] below).
Widget _buildInvite(BuildContext context) => InviteScreen(
  createInviteCubit: () => InviteCubit(
    generateInvitation: () async => PairingInvitation(
      code: 'CPD-8F2K',
      // The frozen backend contract's 24h TTL, so the countdown line renders
      // the shipped format rather than the mockup's "15 phút".
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
    ),
    // REQ-009 STORY-001: without a seeded selection the canvas would only ever
    // capture the unselected grid, never the selected-card treatment.
    fetchCoupleType: () async => 'SAME_CITY',
  ),
);

/// STORY-027: `--dart-define=PREVIEW_JAR_FIXTURE=design` renders this screen
/// from the design source's own numbers instead of the live seed. Every
/// contribution on the seeded jar belongs to one account, so the per-partner
/// comparison card has no partner bar to draw against real data. Omit the
/// define for today's unchanged live-repository behaviour.
const String _jarFixture = String.fromEnvironment('PREVIEW_JAR_FIXTURE');

const String _previewJarId = 'preview-jar';
const String _previewJarSelfUserId = 'preview-self';

Widget _buildJar(BuildContext context) {
  final bool useFixture = _jarFixture == 'design';
  return DreamJarDetailScreen(
    jarId: useFixture ? _previewJarId : _seededJarId,
    repository: useFixture
        ? _PreviewDreamJarRepository()
        : getIt<DreamJarRepository>(),
    // Live path: resolved by `bootstrapPreviewSession`, so seeded
    // contributions land on the right side of the per-partner comparison.
    currentUserId: useFixture
        ? _previewJarSelfUserId
        : getIt<BackendUserIdStore>().backendUserId,
  );
}

/// Returns the design source's jar and its two-sided contribution split
/// instead of calling the backend. `createJar()` and `addContribution()` are
/// never reached from a static capture (mirrors the
/// [_PreviewLoveContractRepository] precedent below).
class _PreviewDreamJarRepository extends DreamJarRepository {
  _PreviewDreamJarRepository() : super(getIt<CupidApi>());

  @override
  Future<DreamJar> fetchJar(String id) async => DreamJar(
    id: _previewJarId,
    name: 'Du lịch Đà Lạt',
    targetAmount: 5000000,
    currentAmount: 3900000,
    deadline: null,
    currency: 'VND',
    status: DreamJarStatus.active,
    serverProgress: null,
    createdAt: DateTime(2026, 1, 1),
  );

  @override
  Future<List<Contribution>> fetchContributions(
    String jarId, {
    int limit = 50,
    int offset = 0,
  }) async => <Contribution>[
    Contribution(
      id: 'preview-contribution-self',
      dreamJarId: _previewJarId,
      userId: _previewJarSelfUserId,
      amount: 2180000,
      note: null,
      createdAt: DateTime(2026, 1, 1),
    ),
    Contribution(
      id: 'preview-contribution-partner',
      dreamJarId: _previewJarId,
      userId: 'preview-partner',
      amount: 1720000,
      note: null,
      createdAt: DateTime(2026, 1, 2),
    ),
  ];
}

/// STORY-059: `--dart-define=PREVIEW_JARLIST_FIXTURE=empty|ready` renders this
/// screen in the two states that carry the header contract. `DreamJarListCubit`
/// reaches `GET /jars`, which an unauthenticated preview cannot resolve, so
/// without a fixture the capture is always `DreamJarListFailed` — the one state
/// that never had a header action either before or after the fix, and therefore
/// cannot evidence its removal. Omit the define for today's unchanged
/// live-repository behaviour.
const String _jarlistFixture = String.fromEnvironment(
  'PREVIEW_JARLIST_FIXTURE',
);

/// Three active jars, not two: matches the design source's own jar set, and any
/// count above one avoids the single-non-archived-jar bypass at
/// `dream_jar_list_screen.dart:59` that swaps this screen for the detail screen.
///
/// STORY-061 P2 adds the two completed jars the design source names ("2 cái ·
/// Tai nghe cho Linh, Sinh nhật Minh"). They are partitioned out of the card
/// list by `DreamJarListCubit`, so the summary pill's active-only total stays
/// 7.150.000₫ / 3 hũ while the completed-jars row gains on-device evidence.
final List<DreamJar> _previewJarlistJars = <DreamJar>[
  DreamJar(
    id: 'preview-jarlist-1',
    name: 'Du lịch Đà Lạt',
    targetAmount: 5000000,
    currentAmount: 3900000,
    deadline: DateTime(2026, 9, 30),
    currency: 'VND',
    status: DreamJarStatus.active,
    serverProgress: null,
    createdAt: DateTime(2026, 1, 1),
  ),
  DreamJar(
    id: 'preview-jarlist-2',
    name: 'Nhẫn đôi',
    targetAmount: 8000000,
    currentAmount: 2400000,
    deadline: DateTime(2027, 2, 14),
    currency: 'VND',
    status: DreamJarStatus.active,
    serverProgress: null,
    createdAt: DateTime(2026, 1, 2),
  ),
  DreamJar(
    id: 'preview-jarlist-3',
    name: 'Dọn về ở chung',
    targetAmount: 30000000,
    currentAmount: 850000,
    deadline: DateTime(2027, 6, 1),
    currency: 'VND',
    status: DreamJarStatus.active,
    serverProgress: null,
    createdAt: DateTime(2026, 1, 3),
  ),
  DreamJar(
    id: 'preview-jarlist-4',
    name: 'Tai nghe cho Linh',
    targetAmount: 2000000,
    currentAmount: 2000000,
    deadline: DateTime(2026, 5, 20),
    currency: 'VND',
    status: DreamJarStatus.completed,
    serverProgress: null,
    createdAt: DateTime(2025, 11, 1),
  ),
  DreamJar(
    id: 'preview-jarlist-5',
    name: 'Sinh nhật Minh',
    targetAmount: 1200000,
    currentAmount: 1200000,
    deadline: DateTime(2026, 6, 8),
    currency: 'VND',
    status: DreamJarStatus.completed,
    serverProgress: null,
    createdAt: DateTime(2025, 12, 1),
  ),
];

/// Overrides `fetchJars` only — the list screen calls nothing else, and a
/// static capture never reaches create/contribute (mirrors the
/// [_PreviewDreamJarRepository] precedent above).
class _PreviewDreamJarListRepository extends DreamJarRepository {
  _PreviewDreamJarListRepository(this.jars) : super(getIt<CupidApi>());

  final List<DreamJar> jars;

  @override
  Future<List<DreamJar>> fetchJars({int limit = 50, int offset = 0}) async =>
      jars;
}

Widget _buildJarlist(BuildContext context) => DreamJarListScreen(
  repository: switch (_jarlistFixture) {
    'empty' => _PreviewDreamJarListRepository(const <DreamJar>[]),
    'ready' => _PreviewDreamJarListRepository(_previewJarlistJars),
    _ => getIt<DreamJarRepository>(),
  },
);

/// STORY-018 P8: the "jarnew" canvas is the create-jar form
/// ([CreateDreamJarSheet]), normally presented as a modal bottom sheet with
/// no `Scaffold`/app bar of its own — wrapped here in a bare [Scaffold] so it
/// has a capturable, full-frame surface like every other registry entry.
Widget _buildJarnew(BuildContext context) => Scaffold(
  body: SafeArea(
    child: CreateDreamJarSheet(repository: getIt<DreamJarRepository>()),
  ),
);

/// STORY-047: the six-slot code entry has four design-source states, and the
/// capture tool photographs a route without touching it. These two defines seed
/// the state directly — `PREVIEW_JOINCODE_CODE` fills that many slots, and
/// `PREVIEW_JOINCODE_STATE=error` submits once against a rejecting stub so the
/// frame lands on the red slots plus the inline rejection line.
const String _joincodeCode = String.fromEnvironment('PREVIEW_JOINCODE_CODE');
const String _joincodeState = String.fromEnvironment('PREVIEW_JOINCODE_STATE');

Widget _buildJoincode(BuildContext context) => JoincodeScreen(
  initialCode: _joincodeCode,
  createJoincodeCubit: _joincodeState == 'error'
      ? () {
          final JoincodeCubit cubit = JoincodeCubit(
            acceptInvitation: (_) async =>
                throw const InvalidOrExpiredCodeFailure(),
          );
          unawaited(cubit.submit(_joincodeCode));
          return cubit;
        }
      : null,
);

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

/// Resolved through the shipped registry rather than constructed here, so the
/// capture photographs the widget production actually mounts at this node. A
/// hand-built copy could drift from the registry and still look right.
Widget _buildPairingChoice(BuildContext context) =>
    onboardingRouteBuilders()[OnboardingNode.pairingChoice]!(context);

/// Seeded to the design source's own composed frame: 3 of 6 digits entered
/// with the caret on the 4th cell, and the resend cooldown at `00:42`.
Widget _buildOtp(BuildContext context) => const OtpScreen(
  email: 'minh@gmail.com',
  initialCode: '247',
  resendSeconds: 42,
);

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

/// Seeded to the design source's own composed frame (`Cupid Screens.dc.html`
/// `isRegister`, lines 1475-1492): `Minh` / `minh@gmail.com` / `loveyou247`,
/// the password that scores 3 of 4 and shows the `Mạnh` caption. Without it
/// the capture is the empty state and cannot be compared against a reference
/// that renders every field filled.
Widget _buildRegister(BuildContext context) => RegisterScreen(
  authRepository: _buildAuthRepository(),
  initialName: 'Minh',
  initialEmail: 'minh@gmail.com',
  initialPassword: 'loveyou247',
);

Widget _buildSplash(BuildContext context) =>
    SplashScreen(authRepository: _buildAuthRepository());

/// STORY-042: `--dart-define=PREVIEW_TIMELINE_FIXTURE=true` seeds both halves
/// of this screen. The countdown hero reads
/// `CupidProfile.relationshipStartDate` through `AccountRepository`, and the
/// rail reads Drift + `GET /timeline`; an unauthenticated preview resolves
/// neither, so the capture is `TimelineOfflineNoCache` and none of the
/// AC-bearing surfaces (gradient card, progress ring, countdown numerals,
/// connector rail, entry cards, photo placeholder, auto-added pill) is
/// reachable. Omit the define for today's unchanged live-repository behaviour.
const bool _timelineFixture = bool.fromEnvironment('PREVIEW_TIMELINE_FIXTURE');

Widget _buildTimeline(BuildContext context) {
  if (!_timelineFixture) {
    return TimelineScreen(
      createCubit: () => TimelineCubit(getIt<TimelineRepository>()),
    );
  }
  final TimelineRepository repository = _PreviewTimelineRepository();
  return TimelineScreen(
    createCubit: () => TimelineCubit(repository),
    repository: repository,
    accountRepository: _PreviewAccountRepository(_previewTimelineProfile()),
  );
}

/// 246 days back, so `TimelineCountdown.since` derives the design source's own
/// numbers on any capture date: 247 days together -> "Còn 53 ngày", milestone
/// 300, 82%. The canvas' literal 20/09/2026 milestone date is a function of
/// its own "today" (29/07/2026) and cannot be reproduced together with those
/// numbers from a single anchor.
CupidProfile _previewTimelineProfile() => CupidProfile(
  id: 'preview-timeline-user',
  email: 'preview.dev.c@cupid.test',
  language: 'vi',
  vowTaken: true,
  isGhostModeEnabled: false,
  displayName: 'Minh',
  relationshipStartDate: DateTime.now().subtract(const Duration(days: 246)),
  partnerId: 'preview-timeline-partner',
  coupleType: 'SAME_CITY',
);

/// Replays the design source's own five-row `timeline` list
/// (`Cupid Screens.dc.html` L2279-2285) instead of Drift + `GET /timeline`,
/// so the rail's per-row accent cycle, dates, auto-added pills and photo
/// placeholder land in the capture in the canvas' own order. `createEntry` is
/// never reached from a static capture (mirrors [_PreviewChatRepository]).
class _PreviewTimelineRepository implements TimelineRepository {
  @override
  Stream<List<TimelineEntry>> watchEntries() =>
      Stream<List<TimelineEntry>>.value(<TimelineEntry>[
        _entry(
          '1',
          'Mốc 200 ngày',
          'Bún lên Lv.3 đúng ngày này.',
          'celebration',
          DateTime(2026, 1, 18),
          auto: true,
        ),
        _entry(
          '2',
          'Dream Jar đạt 75%',
          'Chuyến Đà Lạt đang thành hình.',
          'savings',
          DateTime(2026, 1, 2),
          auto: true,
        ),
        _entry(
          '3',
          'Cãi nhau lần đầu, sống sót',
          'Linh tự thêm. Im lặng 3 tiếng rồi trà sữa hoà giải.',
          'favorite',
          DateTime(2025, 11, 11),
          auto: false,
          // The canvas draws `<image-slot>`'s empty state here, which is what
          // `TimelineEntryCard` renders once an unreachable URL fails.
          photoUrl: 'https://preview.invalid/ky-niem.jpg',
        ),
        _entry(
          '4',
          'Nhận nuôi Bún',
          'Chọn mèo vì cả hai đều không muốn dắt chó đi dạo.',
          'pets',
          DateTime(2025, 11, 26),
          auto: true,
        ),
        _entry(
          '5',
          'Ký Love Contract',
          'Ngày thứ 1. Bốn điều khoản, hai dấu vân tay.',
          'draw',
          DateTime(2025, 11, 25),
          auto: true,
        ),
      ]);

  static TimelineEntry _entry(
    String id,
    String title,
    String description,
    String icon,
    DateTime createdAt, {
    required bool auto,
    String? photoUrl,
  }) => TimelineEntry(
    id: id,
    // `isAutoGenerated` is `type != memory`, and that is what draws the
    // canvas' "tự động thêm" pill.
    type: auto ? TimelineEventType.milestone : TimelineEventType.memory,
    title: title,
    createdAt: createdAt,
    description: description,
    photoUrl: photoUrl,
    icon: icon,
  );

  @override
  Future<TimelineRefreshOutcome> refresh() async => const TimelineSynced();

  @override
  Future<TimelineRefreshOutcome> createEntry(TimelineDraft draft) =>
      throw UnimplementedError();
}

Widget _buildVibe(BuildContext context) => const VibeScreen();

/// STORY-032: without an injected cubit, [WaitingScreen] polls
/// `getIt<PairingRepository>().getPartnerLink`, which in this seeded preview
/// backend resolves an already-paired link — [WaitingCubit] then emits
/// `WaitingPaired` immediately and the capture shows the paired state, never
/// the hold state this canvas id names. The fixture below never pairs, so the
/// screen stays in `WaitingInProgress` (mirrors the
/// [_PreviewLoveContractRepository] fixture precedent above).
Widget _buildWaiting(BuildContext context) {
  final DateTime expiresAt = DateTime.now().add(const Duration(minutes: 10));
  return WaitingScreen(
    expiresAt: expiresAt,
    // The design canvas' own sample code, so the capture and its reference
    // show the same string in the "Mã của bạn" card.
    code: 'CPD-8F2K',
    createWaitingCubit: () => WaitingCubit(
      getPartnerLink: () async => const PartnerLink(partnerId: null),
      expiresAt: expiresAt,
    ),
  );
}

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

/// REQ-011 STORY-001 P3: `--dart-define=PREVIEW_ZODIAC_STATE=incomplete`
/// renders the AC3 degraded state; anything else renders the loaded three-card
/// state. Both come from [_PreviewZodiacRepository] rather than a live
/// `GET /zodiac/red-flag/today`, so the capture never depends on a seeded
/// backend couple having both zodiac signs set.
const String _zodiacStateFixture = String.fromEnvironment(
  'PREVIEW_ZODIAC_STATE',
);

Widget _buildZodiac(BuildContext context) => ZodiacRedFlagScreen(
  createCubit: () => ZodiacCubit(
    repository: _PreviewZodiacRepository(
      incompleteProfile: _zodiacStateFixture == 'incomplete',
    ),
  ),
);

/// Serves the backend's own content for the design canvas' couple — Minh
/// (`cancer`) and Linh (`pisces`) — instead of the canvas' fixture prose.
///
/// `conflict-index.content.ts` scores that water/water pair `7` of `10`, which
/// is exactly the score and bar fill the design reference draws, so the
/// numeric half of the comparison stays exact. The headline/body strings are
/// the shipped generated copy, not the canvas' hand-written sample: replaying
/// the sample would put strings in the capture that the product can never
/// render. `tip-01`/`tip-02`/`tip-03` are the pool's `videocam`+mint,
/// `block`+pink and `local_cafe`+amber rows, matching the canvas' own tile
/// sequence.
class _PreviewZodiacRepository implements ZodiacRepository {
  _PreviewZodiacRepository({required this.incompleteProfile});

  final bool incompleteProfile;

  /// The design canvas' own day (`Red flag · 29/07`), so the eyebrow date in
  /// the capture and its reference read the same.
  static const String _contentDate = '2026-07-29';

  @override
  Future<ZodiacRedFlagToday> fetchToday() async {
    if (incompleteProfile) {
      return const ZodiacRedFlagIncompleteProfile(
        contentDate: _contentDate,
        missing: <String>['partner_zodiac'],
      );
    }
    return const ZodiacRedFlagReady(
      contentDate: _contentDate,
      conflictIndex: ZodiacConflictIndex(
        score: 7,
        scoreMax: 10,
        headline: 'Cự Giải và Song Ngư',
        body:
            'Cự Giải (nhạy cảm, giàu cảm xúc) và Song Ngư (mơ mộng, giàu trực '
            'giác) cần thêm thời gian để hiểu nhau, nhưng hoàn toàn có thể '
            'hòa hợp.',
      ),
      partners: <ZodiacPartner>[
        ZodiacPartner(
          role: ZodiacPartnerRole.self,
          displayName: 'Minh',
          sign: CupidZodiacSign.cancer,
        ),
        ZodiacPartner(
          role: ZodiacPartnerRole.partner,
          displayName: 'Linh',
          sign: CupidZodiacSign.pisces,
        ),
      ],
      dailyTips: <ZodiacDailyTip>[
        ZodiacDailyTip(
          id: 'tip-01',
          icon: ZodiacTipIcon.videocam,
          tint: ZodiacTipTint.mint,
          title: 'Gọi video 10 phút',
          body:
              'Dành 10 phút gọi video để kể cho nhau nghe một chuyện vui '
              'trong ngày.',
        ),
        ZodiacDailyTip(
          id: 'tip-02',
          icon: ZodiacTipIcon.block,
          tint: ZodiacTipTint.pink,
          title: 'Tạm dừng tranh luận',
          body:
              'Nếu thấy giọng điệu căng thẳng, hãy tạm dừng 5 phút trước khi '
              'nói tiếp.',
        ),
        ZodiacDailyTip(
          id: 'tip-03',
          icon: ZodiacTipIcon.localCafe,
          tint: ZodiacTipTint.amber,
          title: 'Hẹn cà phê cuối tuần',
          body: 'Rủ nhau một buổi cà phê không điện thoại vào cuối tuần này.',
        ),
      ],
    );
  }
}

/// All 37 design canvas ids are registered above; nothing is left needing a
/// fixture (STORY-018 P8).
const List<String> needsFixtures = <String>[];

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  setupServiceLocator();
  if (_antighostFixture == 'state-a' || _antighostFixture == 'state-b') {
    final bool pending = _antighostFixture == 'state-b';
    getIt.unregister<GhostConfigRepository>();
    getIt.registerLazySingleton<GhostConfigRepository>(
      () => _PreviewGhostConfigRepository(pending: pending),
    );
    if (pending) {
      // `_lifecycleForPending` falls back to `AntiGhostPendingUnknownRole`
      // until a backend user id resolves, so State B needs the proposer's id
      // seeded as well as the proposal itself.
      getIt<BackendUserIdStore>().updateFromLoginResponse(
        const <String, dynamic>{'id': _previewAntighostSelfId},
      );
    }
  }
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
        // `CupidAppBackground` is mounted here, not per screen, because that is
        // exactly where the real composition root mounts it (`app/cupid_app.dart`)
        // — a preview missing it would show an empty scaffold wash and read as a
        // background delta that is not real.
        builder: (BuildContext context, Widget? child) => CupidAppBackground(
          child: MediaQuery.withNoTextScaling(
            child: child ?? const SizedBox.shrink(),
          ),
        ),
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
    // `gallery` deliberately has no arm: it is no longer a shell destination,
    // it is pushed from `HomeScreen`'s Gallery entry card, so no tab is
    // highlighted while it is captured.
    final PreviewAppShellTab? tab = switch (screenId) {
      'home' => PreviewAppShellTab.home,
      'chat' => PreviewAppShellTab.chat,
      'pet' => PreviewAppShellTab.pet,
      'jarlist' => PreviewAppShellTab.viChung,
      'me' => PreviewAppShellTab.toi,
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
