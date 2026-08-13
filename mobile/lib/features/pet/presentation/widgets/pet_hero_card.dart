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
        border: Border.all(color: colors.colorLine),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        children: [
          BunSprite(state: spriteState, size: 206),
          SizedBox(height: CupidSpacing.md),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: CupidSpacing.md,
              vertical: CupidSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.colorText.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(platformTokens.radiusButton),
              border: Border.all(
                color: colors.colorText.withValues(alpha: 0.28),
              ),
            ),
            child: Text(
              'Lv.${status.pet.level} · $moodLabel',
              style: type.caption.copyWith(
                fontWeight: FontWeight.w800,
                color: colors.colorText,
              ),
            ),
          ),
          SizedBox(height: CupidSpacing.md),
          Text(
            status.pet.name,
            style: type.display.copyWith(
              color: colors.colorText,
              letterSpacing: -0.02 * type.display.fontSize!,
            ),
          ),
          SizedBox(height: CupidSpacing.xs),
          Text(
            statusLine,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(
              color: colors.colorText.withValues(alpha: 0.82),
            ),
          ),
        ],
      ),
    );
  }
}
