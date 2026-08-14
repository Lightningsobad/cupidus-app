import 'package:cupid_mobile/core/navigation/onboarding_router.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../invite_cubit.dart';
import '../joincode_cubit.dart';
import 'invite_screen.dart';
import 'joincode_screen.dart';

/// `pairing_choice` node (`ux/uiux-spec.md` section 6) — the pairing-flow stack
/// root for an unpaired user: `NO_TABS`, architecturally distinct from the main
/// tab shell. Surfaces the discoverable "Pair with your partner" entry action,
/// which pushes [InviteScreen] (`ux/uiux-spec.md` §2's primary flow-map path),
/// plus a secondary "I already have a code" action that pushes [JoincodeScreen]
/// directly — §2's documented alternate entry point for a user who already
/// holds a code, rather than routing everyone through `invite` first.
///
/// [router] is threaded into the pushed screens rather than used to route these
/// two edges: both destinations carry `create*Cubit` seams that a registry
/// [WidgetBuilder] cannot supply, so the edges stay direct pushes and the
/// router is passed along for the `waiting`/`paired` tail below them.
class PairingChoiceScreen extends StatelessWidget {
  const PairingChoiceScreen({
    super.key,
    this.router,
    InviteCubit Function()? createInviteCubit,
    JoincodeCubit Function()? createJoincodeCubit,
  }) : _createInviteCubit = createInviteCubit,
       _createJoincodeCubit = createJoincodeCubit;

  final OnboardingRouter? router;
  final InviteCubit Function()? _createInviteCubit;
  final JoincodeCubit Function()? _createJoincodeCubit;

  void _openInvite(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            InviteScreen(router: router, createInviteCubit: _createInviteCubit),
      ),
    );
  }

  void _openJoincode(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => JoincodeScreen(
          router: router,
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
                  isVi
                      ? 'Ghép đôi để mở khoá Cupid'
                      : 'Pair up to unlock Cupid',
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
                  child: Text(isVi ? 'Tôi đã có mã' : 'I already have a code'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
