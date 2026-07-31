import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../pairing_strings.dart';

/// `paired` screen (`ux/uiux-spec.md` §2, §4, §8, §9) — the shared
/// celebration screen both arrival paths converge on: the inviter via
/// `WaitingScreen`'s poll-triggered `onPaired` (auto-navigation, no user tap)
/// and the invitee via `JoincodeScreen`'s accept-triggered `onPaired`
/// (user-initiated tap). `NO_CHROME`: no header, no tab bar (§1).
///
/// The downstream "Sign the Love Contract →" CTA (§4) is out of this story's
/// scope — no Love Contract flow exists yet — and is not built here,
/// mirroring plan §1 D2's "excluded, not stubbed" precedent for out-of-scope
/// CTAs.
///
/// Takes no arrival-path parameter and performs its own accessibility
/// announcement (below) rather than depending on the caller: `waiting`'s
/// poll-triggered arrival is the only true "auto-navigation" case (§9), but
/// `joincode`'s arrival follows the user's own "Pair up" tap, so this screen
/// is the one place both paths agree a paired user has actually landed.
class PairedScreen extends StatelessWidget {
  const PairedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;

    return Scaffold(
      key: const Key('paired_screen'),
      backgroundColor: colors.colorBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(CupidSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const ExcludeSemantics(child: _PoppingHeart()),
                SizedBox(height: CupidSpacing.lg),
                // The real accessible status (§9): a live region announces
                // the moment this shared screen appears, regardless of
                // whether the caller pushed it automatically (waiting's
                // poll) or after an explicit user action (joincode's tap).
                Semantics(
                  liveRegion: true,
                  child: Text(
                    context.viEn('Đã ghép đôi!', "You're paired!"),
                    textAlign: TextAlign.center,
                    style: context.cupidType.cardTitle.copyWith(
                      color: colors.colorText,
                    ),
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

/// Decorative pop-in + bob heart (§8: reuses the existing `popIn`/`bob`
/// keyframe vocabulary, no new animation primitive) — hidden from assistive
/// tech by the caller's [ExcludeSemantics]; the celebratory text above is the
/// real accessible signal.
class _PoppingHeart extends StatefulWidget {
  const _PoppingHeart();

  @override
  State<_PoppingHeart> createState() => _PoppingHeartState();
}

class _PoppingHeartState extends State<_PoppingHeart>
    with TickerProviderStateMixin {
  late final AnimationController _popController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final Animation<double> _pop = CurvedAnimation(
    parent: _popController,
    curve: Curves.elasticOut,
  );
  late final AnimationController _bobController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    _popController.forward().whenComplete(() {
      if (mounted) _bobController.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _popController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    return AnimatedBuilder(
      animation: Listenable.merge(<Listenable>[_popController, _bobController]),
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, -6 * _bobController.value),
          child: Transform.scale(
            scale: _pop.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.colorAccentPink,
                shape: BoxShape.circle,
              ),
              child: const SizedBox(width: 72, height: 72),
            ),
          ),
        );
      },
    );
  }
}
