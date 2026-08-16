import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../pairing/presentation/screens/invite_screen.dart';
import '../expense_strings.dart';

/// AC4 defensive gate (`ux/uiux-spec.md` §6): a dedicated screen shown
/// whenever the expenses route is reached without an active pairing --
/// never a generic error, a snackbar, or a silently-empty list. Mirrors
/// `SplashScreen`'s auth-check-gate shape (`splash_screen.dart`), keyed on
/// pairing state instead of auth state. The primary action opens
/// `InviteScreen`; `PairingRepository.generateInvitation` is idempotent
/// (returns the existing active code if one exists), so this single target
/// already matches "whichever entry the user's account has in progress"
/// without this gate needing to know which pairing state the account is in.
class PairingRequiredGate extends StatelessWidget {
  const PairingRequiredGate({super.key});

  void _openPairingFlow(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const InviteScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(CupidSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 40,
                  color: colors.colorTextMuted,
                ),
                SizedBox(height: CupidSpacing.md),
                Text(
                  ExpenseStrings.pairingGateMessage(context),
                  textAlign: TextAlign.center,
                  style: context.cupidType.body.copyWith(
                    color: colors.colorTextMuted,
                  ),
                ),
                SizedBox(height: CupidSpacing.lg),
                CupidPrimaryButton(
                  label: ExpenseStrings.pairingGateActionLabel(context),
                  onPressed: () => _openPairingFlow(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
