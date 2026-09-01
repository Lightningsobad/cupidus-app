import 'package:cupid_mobile/core/di/service_locator.dart';
import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/pet_models.dart';
import '../../data/pet_mood.dart';
import '../../data/pet_repository.dart';
import '../pet_cubit.dart';
import '../pet_route.dart';
import '../pet_state.dart';
import '../pet_strings.dart';
import 'bun_sprite.dart';

/// Design-source measurements for the ready-state card with no `CupidSpacing`
/// or token equivalent, transcribed verbatim from the `isHome` pet node
/// (`Cupid Screens.dc.html` lines 291-300) rather than rounded onto the 8pt
/// scale — same sourcing rule as `home_screen.dart`'s hero constants.

/// `rgba(255,127,182,.2)` and `rgba(121,226,205,.16)`: the 130deg card wash.
const int _readyGradientPinkAlpha = 51;
const int _readyGradientMintAlpha = 41;

/// Direction vectors for `linear-gradient(130deg, ...)`: CSS 0deg points "to
/// top" and rotates clockwise, so the axis is `(sin130, -cos130)`.
const Alignment _readyGradientBegin = Alignment(
  -0.766044443118978,
  -0.6427876096865393,
);
const Alignment _readyGradientEnd = Alignment(
  0.766044443118978,
  0.6427876096865393,
);

/// `top:-14px; right:12%; width:74px; height:74px;`
/// `radial-gradient(circle, rgba(255,255,255,.26), transparent 70%)`.
const double _readyGlowDiameter = 74;
const double _readyGlowTop = -14;
const double _readyGlowRightFraction = 0.12;
const int _readyGlowAlpha = 66;
const List<double> _readyGlowStops = <double>[0.0, 0.7];

/// `font-family:Nunito; font-size:17px; font-weight:900` — no shared
/// typography token owns this role (`ux/uiux-spec.md` §3.3).
const double _petNameFontSize = 17;

/// `padding:2px 7px; border-radius:6px; background:rgba(255,127,182,.22);`
/// `font-family:'Roboto Mono'; font-size:10px; color:var(--pink)`.
const int _levelChipAlpha = 56;
const double _levelChipRadius = 6;
const double _levelChipFontSize = 10;

/// `font-size:12px; color:var(--tx2)` — a smaller role than `caption`'s 13px.
const double _statusLineFontSize = 12;

/// `height:8px; background:var(--surf)`.
const double _xpBarHeight = 8;

/// Home-dashboard entry point into the pet feature (`ux/uiux-spec.md` §2.1
/// "Home-dashboard preview card": sprite thumbnail + name + level chip +
/// one-line status + XP bar, "using the same data mapping as the full
/// screen"). It owns its own short-lived [PetCubit] load and never
/// recomputes mood or XP math itself — [PetXpCard] is reused verbatim for
/// the progress bar.
///
/// Tapping always pushes [PetScreen] via [PetRoute], including from the
/// locked/no-pet compact variants: [PetScreen] independently re-derives and
/// enforces the same AC3 pairing gate, so this card never renders a pet card
/// with placeholder data and never opens the adopt sheet itself
/// (`coding-plan/phase-P8-entry-point.md` §3-§4).
class PetPreviewCard extends StatelessWidget {
  const PetPreviewCard({super.key, this.repository});

  /// Overrides the default `getIt<PetRepository>()` lookup; used by widget
  /// tests to inject a fake without touching the global service locator.
  final PetRepository? repository;

  @override
  Widget build(BuildContext context) {
    // `test/widget_test.dart` boots `CupidApp` straight from `main`'s widget
    // tree without calling `setupServiceLocator()` first (it only asserts the
    // `home_screen_ready_signal` key). The real app always registers
    // `PetRepository` before running, so this guard only ever engages in that
    // DI-less smoke test, never in production.
    if (repository == null && !getIt.isRegistered<PetRepository>()) {
      return const SizedBox.shrink();
    }
    final PetRepository resolvedRepository =
        repository ?? getIt<PetRepository>();
    return BlocProvider<PetCubit>(
      create: (_) => PetCubit(repository: resolvedRepository)..load(),
      child: const _PetPreviewView(),
    );
  }
}

class _PetPreviewView extends StatelessWidget {
  const _PetPreviewView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PetCubit, PetState>(
      builder: (context, state) => switch (state) {
        PetLoading() => const _PreviewShell(child: _PreviewLoading()),
        PetLocked() => _PreviewShell(
            child: _PreviewCompact(
              icon: CupidIcons.lock,
              headline: context.petLockedHeadline,
            ),
          ),
        PetNoPet() => _PreviewShell(
            child: _PreviewCompact(
              icon: CupidIcons.pets,
              headline: context.petAdoptHeadline,
            ),
          ),
        PetReady() =>
          _PreviewReadyShell(child: _PreviewReady(status: state.status)),
        PetFailure() => _PreviewShell(
            child: _PreviewCompact(
              icon: CupidIcons.pets,
              headline: context.viEn('Không thể tải Bún', 'Could not load Bun'),
            ),
          ),
      },
    );
  }
}

/// The card's one and only tap target (`ux/uiux-spec.md` §5, AC4). Both
/// chrome variants below wrap themselves in this, so the navigation contract
/// is defined exactly once no matter which state renders.
class _PreviewTapTarget extends StatelessWidget {
  const _PreviewTapTarget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: context.viEn('Mở Bún', 'Open Bun'),
      child: GestureDetector(
        onTap: () => PetRoute.push(context),
        child: child,
      ),
    );
  }
}

/// Card chrome for the four states the design source does not depict
/// (`ux/uiux-spec.md` §0): flat `colorSurface`, no gradient, no border, no
/// glow. Deliberately left unrepainted by STORY-003 — the ready variant gets
/// its own widget below rather than a branch in here.
class _PreviewShell extends StatelessWidget {
  const _PreviewShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return _PreviewTapTarget(
      child: Container(
        padding: EdgeInsets.all(CupidSpacing.md),
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        ),
        child: child,
      ),
    );
  }
}

/// Card chrome for the one variant the design source does depict
/// (`ux/uiux-spec.md` §1-§2, `isHome` line 291): the 130deg pink/mint wash,
/// the hairline border, `overflow:hidden`, and the decorative glow circle.
///
/// The glow is a static [Positioned] behind an [IgnorePointer], matching the
/// hero-glow precedent in `home_screen.dart` — the design's `animation:breathe`
/// is a prototype flourish the static-capture fidelity method cannot verify.
class _PreviewReadyShell extends StatelessWidget {
  const _PreviewReadyShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return _PreviewTapTarget(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: _readyGradientBegin,
              end: _readyGradientEnd,
              colors: <Color>[
                colors.colorAccentPink.withAlpha(_readyGradientPinkAlpha),
                colors.colorMint.withAlpha(_readyGradientMintAlpha),
              ],
            ),
            border: Border.all(color: colors.colorLine, width: 1),
            borderRadius: BorderRadius.circular(platformTokens.radiusCard),
          ),
          // The design anchors the glow to 12% of the *card's* width, not the
          // screen's, so the offset has to be resolved against real
          // constraints instead of transcribed as a pixel value.
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return Stack(
                children: <Widget>[
                  Positioned(
                    top: _readyGlowTop,
                    right: constraints.maxWidth * _readyGlowRightFraction,
                    child: IgnorePointer(
                      child: Container(
                        width: _readyGlowDiameter,
                        height: _readyGlowDiameter,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: <Color>[
                              colors.colorGlowCore.withAlpha(_readyGlowAlpha),
                              colors.colorGlowCore.withAlpha(0),
                            ],
                            stops: _readyGlowStops,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(CupidSpacing.md),
                    child: child,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PreviewLoading extends StatelessWidget {
  const _PreviewLoading();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 74,
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }
}

/// The locked / no-pet / failure compact variant: an icon plus one headline
/// line, never a pet card with placeholder data.
class _PreviewCompact extends StatelessWidget {
  const _PreviewCompact({required this.icon, required this.headline});

  final IconData icon;
  final String headline;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Row(
      children: [
        CupidIcon(icon, size: 28, color: colors.colorText),
        SizedBox(width: CupidSpacing.md),
        Expanded(
          child: Text(
            headline,
            style: context.cupidType.body.copyWith(color: colors.colorText),
          ),
        ),
      ],
    );
  }
}

/// The paired-with-pet variant (`ux/uiux-spec.md` §3): 74×74 sprite, a
/// baseline row pairing the pet name with a `Lv.{level}` chip, a one-line
/// status caption, and an XP bar bound to [PetStatus.levelProgress] — the same
/// getter [PetXpCard] uses on [PetScreen], never recomputed here. [PetXpCard]
/// itself is not reused directly to avoid nesting its own card chrome inside
/// this card's; only its bar structure is.
class _PreviewReady extends StatelessWidget {
  const _PreviewReady({required this.status});

  final PetStatus status;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final BunSpriteState spriteState = BunSpriteState.fromMood(status.mood);
    final String statusLine = context.petStatusLine(status.mood);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        PetSprite(
          species: status.pet.species,
          state: spriteState,
          size: 74,
        ),
        SizedBox(width: CupidSpacing.md),
        Expanded(
          child: Column(
            // Tight width for every child, as in [PetXpCard]: the XP bar spans
            // the text column, and a shrink-wrapping column would collapse it
            // onto `levelProgress`' own fraction of that width.
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Flexible(
                    child: Text(
                      status.pet.name,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: _petNameFontSize,
                        color: colors.colorText,
                      ),
                    ),
                  ),
                  SizedBox(width: CupidSpacing.sm),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: CupidSpacing.sm,
                      vertical: CupidSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.colorAccentPink.withAlpha(_levelChipAlpha),
                      borderRadius: BorderRadius.circular(_levelChipRadius),
                    ),
                    child: Text(
                      'Lv.${status.pet.level}',
                      style: context.cupidType.labelMono.copyWith(
                        fontSize: _levelChipFontSize,
                        color: colors.colorAccentPink,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: CupidSpacing.xs),
              Text(
                statusLine,
                style: context.cupidType.caption.copyWith(
                  fontSize: _statusLineFontSize,
                  color: colors.colorTextMuted,
                ),
              ),
              SizedBox(height: CupidSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
                child: SizedBox(
                  height: _xpBarHeight,
                  child: Stack(
                    children: <Widget>[
                      Positioned.fill(
                        child: ColoredBox(color: colors.colorSurface),
                      ),
                      FractionallySizedBox(
                        widthFactor: status.levelProgress.clamp(0.0, 1.0),
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration:
                              BoxDecoration(gradient: colors.gradientDream),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
