import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../data/pet_mood.dart';
import '../../data/pet_models.dart';
import '../pet_strings.dart';
import 'bun_sprite.dart';

/// The `pet` tab hero card (`ux/uiux-spec.md` §2.1 item 1): sprite, `Lv.`
/// pill, pet name, and mood status line. The gradient background is
/// [PetHeroGradient.gradient] (design-system token file; see its dartdoc for
/// why the literal hex values live there rather than in this file).
class PetHeroCard extends StatelessWidget {
  const PetHeroCard({super.key, required this.status});

  final PetStatus status;

  @override
  Widget build(BuildContext context) {
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final CupidColorTokens colors = context.cupidColors;
    final BunSpriteState spriteState = BunSpriteState.fromMood(status.mood);
    final String moodLabel = context.petMoodLabel(status.mood);
    final String statusLine = context.petStatusLine(status.mood);

    return Container(
      padding: EdgeInsets.all(CupidSpacing.lg),
      decoration: BoxDecoration(
        gradient: PetHeroGradient.gradient,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Column(
        children: [
          BunSprite(state: spriteState, size: 206),
          SizedBox(height: CupidSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: CupidSpacing.sm,
              vertical: CupidSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.colorSurface.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(platformTokens.radiusButton),
            ),
            child: Text(
              'Lv.${status.pet.level} · $moodLabel',
              style: type.labelMono.copyWith(color: colors.colorText),
            ),
          ),
          SizedBox(height: CupidSpacing.sm),
          Text(
            status.pet.name,
            style: type.cardTitle.copyWith(color: colors.colorText),
          ),
          SizedBox(height: CupidSpacing.xs),
          Text(
            statusLine,
            textAlign: TextAlign.center,
            style: type.body.copyWith(color: colors.colorText),
          ),
        ],
      ),
    );
  }
}
