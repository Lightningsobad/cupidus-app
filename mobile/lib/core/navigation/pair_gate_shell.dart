import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../design_system/design_system.dart';
import '../../features/auth/presentation/auth_strings.dart';
import '../../features/chat/data/chat_partner_store.dart';
import '../../features/chat/data/chat_repository.dart';
import '../../features/chat/data/ghost_consent_store.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/pairing/data/pairing_repository.dart';
import '../../features/pairing/presentation/invite_cubit.dart';
import '../../features/pairing/presentation/joincode_cubit.dart';
import '../../features/pairing/presentation/pair_gate_cubit.dart';
import '../../features/reminders/presentation/reminder_overlay_host.dart';
import '../couple/couple_pairing_store.dart';
import '../di/service_locator.dart';
import '../realtime/backend_user_id_store.dart';
import '../realtime/cupid_realtime.dart';
import 'app_shell.dart';
import 'onboarding_router.dart';
import 'session_termination_listener.dart';

/// Root navigation shell (`ux/uiux-spec.md` section 6, AC4).
///
/// [createPairGateCubit] defaults to wiring the real [PairingRepository] from
/// `getIt` (registered by STORY-005 P0's `setupServiceLocator`, read-only
/// here). Tests supply a fake fetcher instead so the gate can be driven
/// without a live/mocked `Dio`.
///
/// REQ-016 STORY-001 P9: the unpaired branch below now renders the solo
/// stage-1 [HomeScreen] instead of [PairingChoiceScreen] (`coding-plan/
/// master-plan.md` §8.4), so [createInviteCubit], [createJoincodeCubit], and
/// [router] no longer reach any screen this shell builds. They stay as
/// accepted, unstored constructor parameters only so
/// `test/features/pairing/presentation/pair_gate_cubit_test.dart` — pinned
/// unchanged by §8.7 rule 4 — keeps compiling against its existing call site.
///
/// STORY-009 P4: [ReminderOverlayHost] is mounted exactly once here, wrapping
/// the entire gated tree below, so the Synced Reminder firing overlay can
/// render above whatever screen is active, per `ux/uiux-spec.md` §3.
///
/// REQ-002 STORY-002 P2 (ADR-6): [SessionTerminationListener] is mounted once
/// alongside it, for the same reason — whichever screen the user is on when a
/// sign-out or a refresh failure lands, one listener owns the destination.
///
/// STORY-007: once paired, this gate hands off to [AppShell] (the Home/Chat
/// tab shell). [partnerStore]/[chatRepository]/[coordinator]/
/// [backendUserIdStore]/[consentStore] are threaded through to that [AppShell]
/// so tests can override them; each defaults to null so [AppShell] falls back
/// to its own `getIt<...>()` defaults.
class PairGateShell extends StatelessWidget {
  const PairGateShell({
    super.key,
    PairGateCubit Function()? createPairGateCubit,
    InviteCubit Function()? createInviteCubit,
    JoincodeCubit Function()? createJoincodeCubit,
    OnboardingRouter? router,
    ChatPartnerStore? partnerStore,
    ChatRepository? chatRepository,
    RealtimeCoordinator? coordinator,
    BackendUserIdStore? backendUserIdStore,
    GhostConsentStore? consentStore,
  }) : _createPairGateCubit = createPairGateCubit,
       _partnerStore = partnerStore,
       _chatRepository = chatRepository,
       _coordinator = coordinator,
       _backendUserIdStore = backendUserIdStore,
       _consentStore = consentStore;

  final PairGateCubit Function()? _createPairGateCubit;
  final ChatPartnerStore? _partnerStore;
  final ChatRepository? _chatRepository;
  final RealtimeCoordinator? _coordinator;
  final BackendUserIdStore? _backendUserIdStore;
  final GhostConsentStore? _consentStore;

  PairGateCubit _defaultPairGateCubit() {
    final PairingRepository repository = getIt<PairingRepository>();
    return PairGateCubit(getPartnerLink: repository.getPartnerLink);
  }

  @override
  Widget build(BuildContext context) {
    return SessionTerminationListener(
      child: ReminderOverlayHost(
        child: BlocProvider<PairGateCubit>(
          create: (_) => (_createPairGateCubit ?? _defaultPairGateCubit)(),
          child: _AppShellView(
            partnerStore: _partnerStore,
            chatRepository: _chatRepository,
            coordinator: _coordinator,
            backendUserIdStore: _backendUserIdStore,
            consentStore: _consentStore,
          ),
        ),
      ),
    );
  }
}

class _AppShellView extends StatelessWidget {
  const _AppShellView({
    required ChatPartnerStore? partnerStore,
    required ChatRepository? chatRepository,
    required RealtimeCoordinator? coordinator,
    required BackendUserIdStore? backendUserIdStore,
    required GhostConsentStore? consentStore,
  }) : _partnerStore = partnerStore,
       _chatRepository = chatRepository,
       _coordinator = coordinator,
       _backendUserIdStore = backendUserIdStore,
       _consentStore = consentStore;

  final ChatPartnerStore? _partnerStore;
  final ChatRepository? _chatRepository;
  final RealtimeCoordinator? _coordinator;
  final BackendUserIdStore? _backendUserIdStore;
  final GhostConsentStore? _consentStore;

  /// Pins the unpaired root's [HomeScreen] straight to
  /// [PairingStatus.unpaired] rather than [HomeScreen]'s default
  /// `getIt<CouplePairingStore>()` resolver, a second independent status
  /// source that can return [PairingStatus.unknown]. See `coding-plan/
  /// master-plan.md` §8.5: without the pin, `_SoloHomeGateState` would map
  /// that `unknown` read onto the couple dashboard inside an unpaired
  /// session.
  static Future<PairingStatus> _soloPairingStatus() async =>
      PairingStatus.unpaired;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PairGateCubit, PairGateState>(
      builder: (context, state) => switch (state) {
        PairGateChecking() => const _PairGateChecking(),
        PairGateNetworkError() => const _NetworkErrorView(),
        PairGateUnpaired() => HomeScreen(
          resolvePairingStatus: _soloPairingStatus,
        ),
        PairGatePaired() => AppShell(
          partnerStore: _partnerStore,
          chatRepository: _chatRepository,
          coordinator: _coordinator,
          backendUserIdStore: _backendUserIdStore,
          consentStore: _consentStore,
        ),
      },
    );
  }
}

/// Shown only until the one-shot pair check resolves; no tab bar, matching
/// both possible destinations' `NO_TABS`/main-shell chrome.
class _PairGateChecking extends StatelessWidget {
  const _PairGateChecking();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

/// Displayed when the pair check fails due to network unavailability or timeout.
class _NetworkErrorView extends StatelessWidget {
  const _NetworkErrorView();

  @override
  Widget build(BuildContext context) {
    final colors = context.cupidColors;
    final type = context.cupidType;

    return Scaffold(
      key: const Key('pair_gate_network_error'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: colors.colorSurface.withValues(alpha: 0.8),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colors.colorLine,
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.cloud_off_rounded,
                    size: 44,
                    color: colors.colorAccentPink,
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  context.viEn(
                    'Không thể kết nối máy chủ',
                    'Cannot connect to server',
                  ),
                  textAlign: TextAlign.center,
                  style: type.cardTitle.copyWith(
                    color: colors.colorText,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  context.viEn(
                    'Vui lòng kiểm tra kết nối mạng và thử lại.',
                    'Please check your network connection and try again.',
                  ),
                  textAlign: TextAlign.center,
                  style: type.body.copyWith(
                    color: colors.colorTextMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 36),
                SizedBox(
                  width: double.infinity,
                  child: CupidPrimaryButton(
                    leadingIcon: Icons.refresh_rounded,
                    label: context.viEn('Thử lại', 'Retry'),
                    onPressed: () => context.read<PairGateCubit>().retry(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
