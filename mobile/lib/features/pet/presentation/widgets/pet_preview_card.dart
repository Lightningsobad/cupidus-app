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
        PetReady() => _PreviewShell(child: _PreviewReady(status: state.status)),
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

/// Shared tappable card chrome (`ux/uiux-spec.md` §2.1): every state variant
/// navigates the same way, so the tap target and card shell live once here.
class _PreviewShell extends StatelessWidget {
  const _PreviewShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Semantics(
      button: true,
      label: context.viEn('Mở Bún', 'Open Bun'),
      child: GestureDetector(
        onTap: () => PetRoute.push(context),
        child: Container(
          padding: EdgeInsets.all(CupidSpacing.md),
          decoration: BoxDecoration(
            color: colors.colorSurface,
            borderRadius: BorderRadius.circular(platformTokens.radiusCard),
          ),
          child: child,
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

/// The paired-with-pet variant: 74×74 sprite, `Lv.{level} · {moodLabel}`
/// chip, pet name, one-line status, and an XP progress bar bound to
/// [PetStatus.levelProgress] — the same getter [PetXpCard] uses on
/// [PetScreen], never recomputed here. [PetXpCard] itself is not reused
/// directly to avoid nesting its own card chrome inside this card's.
class _PreviewReady extends StatelessWidget {
  const _PreviewReady({required this.status});

  final PetStatus status;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final BunSpriteState spriteState = BunSpriteState.fromMood(status.mood);
    final String moodLabel = context.petMoodLabel(status.mood);
    final String statusLine = context.petStatusLine(status.mood);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BunSprite(state: spriteState, size: 74),
            SizedBox(width: CupidSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: CupidSpacing.sm,
                      vertical: CupidSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: colors.colorSurfaceAlt,
                      borderRadius:
                          BorderRadius.circular(platformTokens.radiusButton),
                    ),
                    child: Text(
                      'Lv.${status.pet.level} · $moodLabel',
                      style:
                          context.cupidType.labelMono.copyWith(color: colors.colorText),
                    ),
                  ),
                  SizedBox(height: CupidSpacing.xs),
                  Text(
                    status.pet.name,
                    style:
                        context.cupidType.cardTitle.copyWith(color: colors.colorText),
                  ),
                  SizedBox(height: CupidSpacing.xs),
                  Text(
                    statusLine,
                    style: context.cupidType.caption
                        .copyWith(color: colors.colorTextMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: CupidSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
          child: LinearProgressIndicator(
            value: status.levelProgress,
            minHeight: 6,
            backgroundColor: colors.colorSurfaceAlt,
            valueColor: AlwaysStoppedAnimation<Color>(colors.colorAccentPink),
          ),
        ),
      ],
    );
  }
}
