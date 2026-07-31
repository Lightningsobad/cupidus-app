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

    return Container(
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.viEn('Bún phản ứng thế nào', 'How Bun reacts'),
            style: context.cupidType.cardTitle.copyWith(
              color: colors.colorText,
            ),
          ),
          SizedBox(height: CupidSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ReactionTile(
                state: BunSpriteState.happy,
                caption: context.petMoodLabel(PetMood.happy),
              ),
              const _ReactionTile(
                state: BunSpriteState.sulk,
                // Fixed Vietnamese caption per `ux/uiux-spec.md` §2.1 item 5 —
                // given as a single literal, not a vi/en pair like the rest
                // of this file's copy.
                caption: 'Bơ một chút',
              ),
              const _ReactionTile(
                state: BunSpriteState.sick,
                caption: 'Bơ lâu ghê',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReactionTile extends StatelessWidget {
  const _ReactionTile({required this.state, required this.caption});

  final BunSpriteState state;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BunSprite(state: state, size: 46),
        SizedBox(height: CupidSpacing.xs),
        Text(
          caption,
          textAlign: TextAlign.center,
          style: context.cupidType.caption.copyWith(
            color: context.cupidColors.colorTextMuted,
          ),
        ),
      ],
    );
  }
}
