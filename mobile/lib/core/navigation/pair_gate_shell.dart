import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../features/chat/data/chat_partner_store.dart';
import '../../features/chat/data/chat_repository.dart';
import '../../features/chat/data/ghost_consent_store.dart';
import '../../features/pairing/data/pairing_repository.dart';
import '../../features/pairing/presentation/invite_cubit.dart';
import '../../features/pairing/presentation/joincode_cubit.dart';
import '../../features/pairing/presentation/pair_gate_cubit.dart';
import '../../features/pairing/presentation/screens/invite_screen.dart';
import '../../features/pairing/presentation/screens/joincode_screen.dart';
import '../../features/pairing/presentation/screens/paired_screen.dart';
import '../../features/reminders/presentation/reminder_overlay_host.dart';
import '../di/service_locator.dart';
import '../realtime/backend_user_id_store.dart';
import '../realtime/cupid_realtime.dart';
import 'app_shell.dart';

/// Root navigation shell (`ux/uiux-spec.md` section 6, AC4).
///
/// [createPairGateCubit] defaults to wiring the real [PairingRepository] from
/// `getIt` (registered by STORY-005 P0's `setupServiceLocator`, read-only
/// here). Tests supply a fake fetcher instead so the gate can be driven
/// without a live/mocked `Dio`.
///
/// [createInviteCubit] and [createJoincodeCubit] are threaded through to the
/// pushed [InviteScreen]/[JoincodeScreen] (mirrors [createPairGateCubit]'s
/// seam): both screens otherwise default to a `getIt`-backed cubit, which is
/// unavailable in widget tests that never call `setupServiceLocator()`.
///
/// STORY-009 P4: [ReminderOverlayHost] is mounted exactly once here, wrapping
/// the entire gated tree below, so the Synced Reminder firing overlay can
/// render above whatever screen is active, per `ux/uiux-spec.md` §3.
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
    ChatPartnerStore? partnerStore,
    ChatRepository? chatRepository,
    RealtimeCoordinator? coordinator,
    BackendUserIdStore? backendUserIdStore,
    GhostConsentStore? consentStore,
  }) : _createPairGateCubit = createPairGateCubit,
       _createInviteCubit = createInviteCubit,
       _createJoincodeCubit = createJoincodeCubit,
       _partnerStore = partnerStore,
       _chatRepository = chatRepository,
       _coordinator = coordinator,
       _backendUserIdStore = backendUserIdStore,
       _consentStore = consentStore;

  final PairGateCubit Function()? _createPairGateCubit;
  final InviteCubit Function()? _createInviteCubit;
  final JoincodeCubit Function()? _createJoincodeCubit;
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
    return ReminderOverlayHost(
      child: BlocProvider<PairGateCubit>(
        create: (_) => (_createPairGateCubit ?? _defaultPairGateCubit)(),
        child: _AppShellView(
          createInviteCubit: _createInviteCubit,
          createJoincodeCubit: _createJoincodeCubit,
          partnerStore: _partnerStore,
          chatRepository: _chatRepository,
          coordinator: _coordinator,
          backendUserIdStore: _backendUserIdStore,
          consentStore: _consentStore,
        ),
      ),
    );
  }
}

class _AppShellView extends StatelessWidget {
  const _AppShellView({
    required InviteCubit Function()? createInviteCubit,
    required JoincodeCubit Function()? createJoincodeCubit,
    required ChatPartnerStore? partnerStore,
    required ChatRepository? chatRepository,
    required RealtimeCoordinator? coordinator,
    required BackendUserIdStore? backendUserIdStore,
    required GhostConsentStore? consentStore,
  }) : _createInviteCubit = createInviteCubit,
       _createJoincodeCubit = createJoincodeCubit,
       _partnerStore = partnerStore,
       _chatRepository = chatRepository,
       _coordinator = coordinator,
       _backendUserIdStore = backendUserIdStore,
       _consentStore = consentStore;

  final InviteCubit Function()? _createInviteCubit;
  final JoincodeCubit Function()? _createJoincodeCubit;
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
        PairGateUnpaired() => _PairingStack(
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

/// Pairing-flow stack root for an unpaired user (`ux/uiux-spec.md` section 6):
/// `NO_TABS`, architecturally distinct from the main tab shell. Surfaces the
/// discoverable "Pair with your partner" entry action, which pushes
/// [InviteScreen] (`ux/uiux-spec.md` §2's primary flow-map path), plus a
/// secondary "I already have a code" action that pushes [JoincodeScreen]
/// directly — §2's documented alternate entry point for a user who already
/// holds a code, rather than routing everyone through `invite` first.
class _PairingStack extends StatelessWidget {
  const _PairingStack({
    required InviteCubit Function()? createInviteCubit,
    required JoincodeCubit Function()? createJoincodeCubit,
  }) : _createInviteCubit = createInviteCubit,
       _createJoincodeCubit = createJoincodeCubit;

  final InviteCubit Function()? _createInviteCubit;
  final JoincodeCubit Function()? _createJoincodeCubit;

  static void _onPaired(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const PairedScreen()),
      (route) => false,
    );
  }

  void _openInvite(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => InviteScreen(createInviteCubit: _createInviteCubit),
      ),
    );
  }

  void _openJoincode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JoincodeScreen(
          onPaired: _onPaired,
          createJoincodeCubit: _createJoincodeCubit,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final bool isVi = Localizations.localeOf(context).languageCode == 'vi';
    return Scaffold(
      key: const Key('pairing_stack'),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(CupidSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isVi ? 'Ghép đôi để mở khoá Cupid' : 'Pair up to unlock Cupid',
                  textAlign: TextAlign.center,
                  style: context.cupidType.cardTitle.copyWith(
                    color: colors.colorText,
                  ),
                ),
                SizedBox(height: CupidSpacing.xl),
                CupidPrimaryButton(
                  label: isVi
                      ? 'Ghép đôi với người ấy'
                      : 'Pair with your partner',
                  onPressed: () => _openInvite(context),
                ),
                SizedBox(height: CupidSpacing.sm),
                TextButton(
                  onPressed: () => _openJoincode(context),
                  child: Text(
                    isVi ? 'Tôi đã có mã' : 'I already have a code',
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
