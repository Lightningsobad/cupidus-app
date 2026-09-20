import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/starter_selector.dart';
import 'starter_line.dart';

/// The lead starter of a round, drawn as the raised card of canvas
/// `6-moi-chuyen-a-a` (Design Ruling Log 2026-09-20, mục 2).
///
/// It is always element `[0]` of the round `StarterSelector` returned: this
/// widget adds no selection rule of its own, so the deterministic order AC-17
/// pins is exactly the order the hero is picked by. The copy affordance is the
/// same control the secondary lines carry — the canvas's solid "Chép để nhắn"
/// button and its `refresh` sibling are a later phase, not this one.
class StarterHeroCard extends StatelessWidget {
  const StarterHeroCard({
    super.key,
    required this.starter,
    required this.onCopied,
  });

  final RenderedStarter starter;

  final VoidCallback onCopied;

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
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Text(
                    starter.text,
                    key: Key('starter_line_text_${starter.id}'),
                    style: type.cardTitle.copyWith(
                      color: colors.colorText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: CupidSpacing.sm),
                StarterCopyButton(starter: starter, onCopied: onCopied),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
