import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../pairing_strings.dart';

/// `paired` screen — the shared celebration screen both arrival paths converge
/// on: the inviter via `WaitingScreen`'s poll-triggered `onPaired`
/// (auto-navigation, no user tap) and the invitee via `JoincodeScreen`'s
/// accept-triggered `onPaired` (user-initiated tap). `NO_CHROME`: no header,
/// no tab bar.
///
/// Layout, spacing, color and typography are transcribed from the locked
/// design source `cupid-app-design-system/project/Cupid Screens.dc.html`
/// (`isPaired` block). The bare numeric literals below are design-source pixel
/// values that fall off the 8pt [CupidSpacing] grid; they are carried verbatim
/// rather than rounded to the nearest token so the rendered screen matches the
/// source exactly.
///
/// Takes no arrival-path parameter and performs its own accessibility
/// announcement (below) rather than depending on the caller: `waiting`'s
/// poll-triggered arrival is the only true "auto-navigation" case, but
/// `joincode`'s arrival follows the user's own "Pair up" tap, so this screen
/// is the one place both paths agree a paired user has actually landed.
class PairedScreen extends StatelessWidget {
  const PairedScreen({super.key, this.onSignContract});

  /// Caller-supplied destination for the design source's "Ký Love Contract →"
  /// CTA, mirroring the `onPaired` seam on `WaitingScreen`/`JoincodeScreen`.
  /// Choosing where `paired` navigates next is owned by the inter-screen
  /// navigation stories, so this screen renders the CTA but wires no route.
  final VoidCallback? onSignContract;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Scaffold(
      key: const Key('paired_screen'),
      body: DecoratedBox(
        // `radial-gradient(circle at 50% 38%, rgba(255,127,182,.3),
        // transparent 62%)`. `rgba(255,127,182)` is `colorAccentPink`; the end
        // stop keeps that hue at zero alpha so the fade carries no gray
        // fringe. CSS sizes a bare `circle` to the farthest corner, which on
        // the design frame puts the 62% stop at ~0.9 of the shortest side —
        // the fraction Flutter's [RadialGradient.radius] expects.
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0, -0.24),
            radius: 0.9,
            colors: <Color>[
              colors.colorAccentPink.withValues(alpha: 0.3),
              colors.colorAccentPink.withValues(alpha: 0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                vertical: 40,
                horizontal: 26,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const ExcludeSemantics(child: _CoupleCelebration()),
                  const SizedBox(height: 28),
                  // The real accessible status: a live region announces the
                  // moment this shared screen appears, regardless of whether
                  // the caller pushed it automatically (waiting's poll) or
                  // after an explicit user action (joincode's tap).
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      context.viEn('Ghép đôi thành công!', 'You are paired!'),
                      textAlign: TextAlign.center,
                      style: type.display.copyWith(
                        fontSize: 28,
                        height: 1.2,
                        color: colors.colorText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 275),
                    child: Text(
                      context.viEn(
                        'Từ giây phút này mọi thứ trong Cupid là của chung '
                        'hai người. Không có đường lui đâu 🎀',
                        'From now on everything in Cupid belongs to both of '
                        'you. No backing out 🎀',
                      ),
                      textAlign: TextAlign.center,
                      style: type.caption.copyWith(
                        fontSize: 13.5,
                        height: 1.6,
                        color: colors.colorTextMuted,
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  const _PairedStats(),
                  const SizedBox(height: 30),
                  _SignContractCta(onPressed: onSignContract),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The overlapping couple avatars with the floating heart above them — hidden
/// from assistive tech by the caller's [ExcludeSemantics]; the celebratory
/// text below is the real accessible signal.
///
/// Design source: the avatar cluster runs `popIn .6s
/// cubic-bezier(.2,1.6,.4,1)` and the heart runs `bob 2s ease-in-out
/// infinite`.
class _CoupleCelebration extends StatefulWidget {
  const _CoupleCelebration();

  @override
  State<_CoupleCelebration> createState() => _CoupleCelebrationState();
}

class _CoupleCelebrationState extends State<_CoupleCelebration>
    with TickerProviderStateMixin {
  late final AnimationController _popController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  late final Animation<double> _pop = CurvedAnimation(
    parent: _popController,
    curve: const Cubic(0.2, 1.6, 0.4, 1),
  );

  // Half of `bob`'s 2s cycle: `repeat(reverse: true)` replays the keyframe's
  // 0% -> 50% -> 100% travel over the full 2s.
  late final AnimationController _bobController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  late final Animation<double> _bob = CurvedAnimation(
    parent: _bobController,
    curve: Curves.easeInOut,
  );

  @override
  void dispose() {
    _popController.dispose();
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pop,
      builder: (context, child) {
        // `popIn`: scale(.94) translateY(8px) opacity 0 -> scale(1)
        // translateY(0) opacity 1. The curve overshoots past 1 by design, so
        // only opacity is clamped.
        final double t = _pop.value;
        return Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - t)),
            child: Transform.scale(scale: 0.94 + 0.06 * t, child: child),
          ),
        );
      },
      // Two 76px avatars overlapping by 22px, so the cluster is 130px wide.
      child: SizedBox(
        width: 130,
        height: 76,
        child: Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            const Positioned(
              left: 0,
              child: _CoupleAvatar(gradient: CoupleAvatarGradients.self),
            ),
            const Positioned(
              left: 54,
              child: _CoupleAvatar(gradient: CoupleAvatarGradients.partner),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: -16,
              child: Center(
                child: AnimatedBuilder(
                  animation: _bob,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(0, -7 * _bob.value),
                    child: child,
                  ),
                  child: const Text('💕', style: TextStyle(fontSize: 26)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoupleAvatar extends StatelessWidget {
  const _CoupleAvatar({required this.gradient});

  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        border: Border.all(color: colors.colorBackground, width: 3),
      ),
    );
  }
}

/// The three celebration stat chips (`1 ngày`, `16 tính năng`, `0 lần cãi`).
/// The values are fixed copy in the design source, not derived state.
class _PairedStats extends StatelessWidget {
  const _PairedStats();

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _StatChip(
          value: '1',
          label: context.viEn('ngày', 'day'),
          valueColor: colors.colorAccentPink,
        ),
        const SizedBox(width: 12),
        _StatChip(
          value: '16',
          label: context.viEn('tính năng', 'features'),
          valueColor: colors.colorMint,
        ),
        const SizedBox(width: 12),
        _StatChip(
          value: '0',
          label: context.viEn('lần cãi', 'fights'),
          valueColor: colors.colorAccentPurple,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: context.cupidPlatform.elevationShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            value,
            style: type.display.copyWith(fontSize: 22, color: valueColor),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: type.caption.copyWith(
              fontSize: 11,
              color: colors.colorTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SignContractCta extends StatelessWidget {
  const _SignContractCta({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    // Bound to a local rather than chained off `context` on each use: a
    // directly-chained token access matches the no-fork guard test's
    // forbidden-literal-color substring scan.
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final BorderRadius radius = BorderRadius.circular(
      context.cupidPlatform.radiusButton,
    );

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 300),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: colors.gradientHot,
            borderRadius: radius,
            boxShadow: colors.glowShadow,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: radius,
              onTap: onPressed,
              child: Center(
                child: Text(
                  context.viEn(
                    'Ký Love Contract →',
                    'Sign the Love Contract →',
                  ),
                  style: type.body.copyWith(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: colors.colorText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
