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
    final CupidTypographyTokens type = context.cupidType;
    final bool isVi = Localizations.localeOf(context).languageCode == 'vi';
    return Scaffold(
      key: const Key('pairing_stack'),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          // The design source is a fixed portrait frame, but neither
          // `main.dart` nor the Android manifest locks orientation, so the
          // ~350dp this column needs can exceed the viewport once rotated or
          // at an elevated font scale. Scrolling keeps the loose horizontal
          // constraint [Align] hands down (so the title still wraps at the
          // same bound) while trading the overflow for scroll.
          child: SingleChildScrollView(
            child: Padding(
              // The design source's column flows from the top of the frame
              // (`padding:150px 28px 0`, no `justify-content:center`), so this
              // must not be wrapped in a [Center] — that dropped the title to
              // ~43% down instead of the reference's ~23%. The 28 horizontal
              // inset is load-bearing beyond spacing: it sets the title's line
              // width, and the design's title wraps within ~1px of that bound.
              padding: const EdgeInsets.fromLTRB(28, 150, 28, 0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isVi
                        ? 'Ghép đôi để mở khoá Cupid'
                        : 'Pair up to unlock Cupid',
                    textAlign: TextAlign.center,
                    style: type.display.copyWith(
                      fontSize: 24,
                      height: 1.3,
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
      ),
    );
  }
}
