import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar.dart';
import '../../data/dream_jar_amount_format.dart';
import 'dream_jar_illustration.dart';

/// STORY-027 jar detail hero card, transcribed from the locked design
/// source's `jar` screen: the jar selector chip, the animated fill-level
/// illustration, the amount block, and the "remaining" pill, all over the
/// screen's own 172° gradient.
///
/// The quick-add presets are deliberately *not* part of this card — the
/// design source places them in a sibling section below it
/// ([DreamJarQuickAddSection]).
class DreamJarHeroCard extends StatelessWidget {
  const DreamJarHeroCard({
    super.key,
    required this.jar,
    required this.contributionFailure,
    required this.onSelectJar,
  });

  final DreamJar jar;
  final Object? contributionFailure;

  /// The selector chip's `goJarList` action.
  final VoidCallback? onSelectJar;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    final bool isCompleted =
        jar.status == DreamJarStatus.completed || jar.progressPercent >= 100;
    final num remaining = (jar.targetAmount - jar.currentAmount).clamp(
      0,
      jar.targetAmount <= 0 ? 0 : jar.targetAmount,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: DreamJarPalette.heroGradient,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: colors.colorLine),
        boxShadow: context.cupidPlatform.elevationShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          // Without this the padded column only gets loose width constraints
          // and shrink-wraps to its widest child, so the card's centred
          // content ends up hugging the left edge.
          fit: StackFit.passthrough,
          children: [
            const Positioned.fill(child: _HeroDecorations()),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                children: [
                  _JarSelectorChip(name: jar.name, onTap: onSelectJar),
                  const SizedBox(height: 16),
                  DreamJarIllustration(
                    progressPercent: jar.progressPercent,
                    semanticLabel: l10n.dream_jar_quick_add_semantic_label(
                      DreamJarAmountFormat.vnd(jar.currentAmount),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DreamJarAmountFormat.vnd(jar.currentAmount),
                    textAlign: TextAlign.center,
                    style: type.display.copyWith(
                      fontSize: 32,
                      height: 1.1,
                      color: DreamJarPalette.onHeroText,
                      shadows: const <Shadow>[DreamJarPalette.heroAmountShadow],
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${l10n.dream_jar_of} '
                    '${DreamJarAmountFormat.vnd(jar.targetAmount)} · '
                    '${jar.progressPercent}%',
                    textAlign: TextAlign.center,
                    style: type.caption.copyWith(
                      fontSize: 13,
                      color: DreamJarPalette.onHeroSubText,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _RemainingPill(
                    label: isCompleted
                        ? l10n.dream_jar_completed
                        : l10n.dream_jar_remaining(
                            DreamJarAmountFormat.vnd(remaining),
                          ),
                  ),
                  if (contributionFailure != null) ...[
                    SizedBox(height: CupidSpacing.sm),
                    Text(
                      l10n.dream_jar_contribution_error,
                      textAlign: TextAlign.center,
                      style: type.caption.copyWith(color: colors.colorRed),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The card's decorative layer: the `radial-gradient` bloom at
/// `top:10%;left:9%` plus the two drifting sparkle glyphs at
/// `top:14%;right:12%` and `top:34%;left:8%`.
class _HeroDecorations extends StatelessWidget {
  const _HeroDecorations();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: LayoutBuilder(
        builder: (context, constraints) => Stack(
          children: [
            Positioned(
              top: constraints.maxHeight * 0.10,
              left: constraints.maxWidth * 0.09,
              child: Container(
                width: 110,
                height: 110,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: DreamJarPalette.heroBloom,
                ),
              ),
            ),
            Positioned(
              top: constraints.maxHeight * 0.14,
              right: constraints.maxWidth * 0.12,
              child: const Text(
                '✧',
                style: TextStyle(
                  fontSize: 13,
                  color: DreamJarPalette.onHeroText,
                ),
              ),
            ),
            Positioned(
              top: constraints.maxHeight * 0.34,
              left: constraints.maxWidth * 0.08,
              child: const Text(
                '✦',
                style: TextStyle(
                  fontSize: 10,
                  color: DreamJarPalette.onHeroText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `padding:6px 8px 6px 13px;border-radius:999px;background:rgba(255,255,255,.18)`
class _JarSelectorChip extends StatelessWidget {
  const _JarSelectorChip({required this.name, required this.onTap});

  final String name;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: onTap != null,
      child: Material(
        color: DreamJarPalette.onHeroChipFill,
        shape: StadiumBorder(
          side: BorderSide(color: DreamJarPalette.onHeroChipBorder),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 6, 8, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CupidIcon(
                  CupidIcons.flightTakeoff,
                  size: 15,
                  color: DreamJarPalette.onHeroText,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: type.caption.copyWith(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: DreamJarPalette.onHeroText,
                    ),
                  ),
                ),
                const SizedBox(width: 7),
                Opacity(
                  opacity: 0.8,
                  child: const CupidIcon(
                    CupidIcons.expandMore,
                    size: 17,
                    color: DreamJarPalette.onHeroText,
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

/// `gap:7px;padding:8px 15px;border-radius:999px;background:rgba(255,255,255,.16)`
class _RemainingPill extends StatelessWidget {
  const _RemainingPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      decoration: const ShapeDecoration(
        color: DreamJarPalette.onHeroPillFill,
        shape: StadiumBorder(),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CupidIcon(
            CupidIcons.favorite,
            size: 15,
            color: DreamJarPalette.onHeroText,
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              label,
              style: type.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: DreamJarPalette.onHeroText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
