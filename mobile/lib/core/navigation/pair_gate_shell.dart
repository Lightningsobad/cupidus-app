import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/chat/data/chat_partner_store.dart';
import '../../features/chat/data/chat_repository.dart';
import '../../features/chat/data/ghost_consent_store.dart';
import '../../features/pairing/data/pairing_repository.dart';
import '../../features/pairing/presentation/invite_cubit.dart';
import '../../features/pairing/presentation/joincode_cubit.dart';
import '../../features/pairing/presentation/pair_gate_cubit.dart';
import '../../features/pairing/presentation/screens/pairing_choice_screen.dart';
import '../../features/reminders/presentation/reminder_overlay_host.dart';
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
/// [createInviteCubit] and [createJoincodeCubit] are threaded through
/// [PairingChoiceScreen] to the screens it pushes (mirrors
/// [createPairGateCubit]'s seam): both otherwise default to a `getIt`-backed
/// cubit, which is unavailable in widget tests that never call
/// `setupServiceLocator()`. [router] is threaded the same way, for the
/// `paired` edge at the end of that leg.
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
       _createInviteCubit = createInviteCubit,
       _createJoincodeCubit = createJoincodeCubit,
       _router = router,
       _partnerStore = partnerStore,
       _chatRepository = chatRepository,
       _coordinator = coordinator,
       _backendUserIdStore = backendUserIdStore,
       _consentStore = consentStore;

  final PairGateCubit Function()? _createPairGateCubit;
  final InviteCubit Function()? _createInviteCubit;
  final JoincodeCubit Function()? _createJoincodeCubit;
  final OnboardingRouter? _router;
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
            createInviteCubit: _createInviteCubit,
            createJoincodeCubit: _createJoincodeCubit,
            router: _router,
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
    required InviteCubit Function()? createInviteCubit,
    required JoincodeCubit Function()? createJoincodeCubit,
    required OnboardingRouter? router,
    required ChatPartnerStore? partnerStore,
    required ChatRepository? chatRepository,
    required RealtimeCoordinator? coordinator,
    required BackendUserIdStore? backendUserIdStore,
    required GhostConsentStore? consentStore,
  }) : _createInviteCubit = createInviteCubit,
       _createJoincodeCubit = createJoincodeCubit,
       _router = router,
       _partnerStore = partnerStore,
       _chatRepository = chatRepository,
       _coordinator = coordinator,
       _backendUserIdStore = backendUserIdStore,
       _consentStore = consentStore;

  final InviteCubit Function()? _createInviteCubit;
  final JoincodeCubit Function()? _createJoincodeCubit;
  final OnboardingRouter? _router;
  final ChatPartnerStore? _partnerStore;
  final ChatRepository? _chatRepository;
  final RealtimeCoordinator? _coordinator;
  final BackendUserIdStore? _backendUserIdStore;
  final GhostConsentStore? _consentStore;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PairGateCubit, PairGateState>(
      builder: (context, state) => switch (state) {
        PairGateChecking() => const _PairGateChecking(),
        PairGateUnpaired() => PairingChoiceScreen(
          router: _router,
          createInviteCubit: _createInviteCubit,
          createJoincodeCubit: _createJoincodeCubit,
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
