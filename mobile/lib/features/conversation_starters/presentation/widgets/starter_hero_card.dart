import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/starter_selector.dart';
import 'starter_line.dart';

/// The lead starter of a round, drawn as the raised card of canvas
/// `6-moi-chuyen-a-a` (Design Ruling Log 2026-09-20, mục 2).
///
/// It is always element `[0]` of the round `StarterSelector` returned: this
/// widget adds no selection rule of its own, so the deterministic order AC-17
/// pins is exactly the order the hero is picked by.
class StarterHeroCard extends StatelessWidget {
  const StarterHeroCard({
    super.key,
    required this.starter,
    required this.onCopied,
    required this.onNextRound,
  });

  final RenderedStarter starter;

  final VoidCallback onCopied;

  /// Swaps the whole round for the next one. It lives on the hero card because
  /// the canvas draws it there, beside the copy CTA — the behaviour is the one
  /// the screen's text button used to carry.
  final VoidCallback onNextRound;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return DecoratedBox(
      key: const Key('starter_hero_card'),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platform.radiusCard),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              starterText(context, 'CÂU HÔM NAY', "TODAY'S LINE"),
              key: const Key('starter_hero_caption'),
              style: type.caption.copyWith(
                color: colors.colorMint,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: CupidSpacing.sm),
            Text(
              starter.text,
              key: Key('starter_line_text_${starter.id}'),
              style: type.cardTitle.copyWith(
                color: colors.colorText,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: CupidSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: CupidPrimaryButton(
                    key: Key('starter_line_copy_${starter.id}'),
                    label: starterText(context, 'Chép để nhắn', 'Copy to send'),
                    leadingIcon: CupidIcons.contentCopy,
                    onPressed: () => copyStarter(starter, onCopied),
                  ),
                ),
                const SizedBox(width: CupidSpacing.sm),
                _NextRoundControl(onPressed: onNextRound),
              ],
            ),
            const SizedBox(height: CupidSpacing.sm),
            Text(
              starterText(
                context,
                'Câu này nhắn liền, không cần lưu. Quay lại là có câu khác.',
                'Send it as is — nothing to save, and there is always another.',
              ),
              key: const Key('starter_hero_reassurance'),
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// The round-swap disc beside the hero CTA, icon-only.
///
/// Never disabled: the selector wraps, so there is no exhausted state to
/// disable it into, and the screen ships no "x/N" and no "đã xem hết" beside
/// it (AC-4/AC-27). Icon-only, so it carries its own accessible name and keeps
/// the full [kStarterCopyTapTarget] touch area.
class _NextRoundControl extends StatelessWidget {
  const _NextRoundControl({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Semantics(
      button: true,
      label: starterText(context, 'Xem câu khác', 'Show other lines'),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colors.colorSurface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.colorLine),
        ),
        child: InkWell(
          key: const Key('starter_next_round'),
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: kStarterCopyTapTarget,
            height: kStarterCopyTapTarget,
            child: Center(
              child: CupidIcon(
                CupidIcons.refresh,
                variant: CupidIconVariant.line,
                size: CupidSpacing.lg,
                color: colors.colorText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
