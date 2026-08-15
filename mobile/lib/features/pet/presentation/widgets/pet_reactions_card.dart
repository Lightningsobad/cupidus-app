import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../data/pet_mood.dart';
import '../pet_strings.dart';
import 'bun_sprite.dart';

/// "How Bun reacts" reference card (`ux/uiux-spec.md` §2.1 item 5, §3): three
/// reference sprites at the fixed 46px reference-row size — a positive state
/// plus the two "if you ignore me" states, `sulk` and `sick`. Captions are
/// the continuous-decay-friendly copy from §2.1 item 5 ("Bơ một chút" /
/// "Bơ lâu ghê"), never the backend's stepped hour/day thresholds, and the
/// sprite's unused `sleep` state (`ux/uiux-spec.md` §3) is never rendered
/// here.
class PetReactionsCard extends StatelessWidget {
  const PetReactionsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context
                .viEn('Bún phản ứng thế nào', 'How Bun reacts')
                .toUpperCase(),
            style: type.caption.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.05 * type.caption.fontSize!,
              color: colors.colorTextMuted,
            ),
          ),
          SizedBox(height: CupidSpacing.md),
          Row(
            children: [
              Expanded(
                child: _ReactionTile(
                  state: BunSpriteState.happy,
                  caption: context.petMoodLabel(PetMood.happy),
                  accent: colors.colorMint,
                ),
              ),
              SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: _ReactionTile(
                  state: BunSpriteState.sulk,
                  // Fixed Vietnamese caption per `ux/uiux-spec.md` §2.1 item
                  // 5 — given as a single literal, not a vi/en pair like the
                  // rest of this file's copy.
                  caption: 'Bơ một chút',
                  accent: colors.colorAmber,
                ),
              ),
              SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: _ReactionTile(
                  state: BunSpriteState.sick,
                  caption: 'Bơ lâu ghê',
                  accent: colors.colorPeach,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReactionTile extends StatelessWidget {
  const _ReactionTile({
    required this.state,
    required this.caption,
    required this.accent,
  });

  final BunSpriteState state;
  final String caption;

  /// Role color of this reaction, used for both the tile tint and the
  /// caption (design source: mint / amber / peach at 14% tint).
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: CupidSpacing.sm,
        horizontal: CupidSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
      ),
      child: Column(
        children: [
          BunSprite(state: state, size: 46),
          SizedBox(height: CupidSpacing.xs),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: context.cupidType.caption.copyWith(
              fontWeight: FontWeight.w700,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
