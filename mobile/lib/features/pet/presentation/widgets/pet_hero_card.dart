import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../data/pet_mood.dart';
import '../../data/pet_models.dart';
import '../pet_strings.dart';
import 'pet_sprite.dart';

/// The `pet` tab hero card: sprite, `Lv.` pill, pet name, and mood status line.
/// Supports all 6 companion species via [PetSprite].
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
      decoration: BoxDecoration(
        gradient: PetHeroGradient.gradient,
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: colors.colorLine),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: Stack(
          children: [
            // Decorative background glowing circles
            Positioned(
              top: 30,
              left: 20,
              child: IgnorePointer(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        PetHeroDecorations.circleGlow1,
                        PetHeroDecorations.transparent,
                      ],
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 20,
              right: 25,
              child: IgnorePointer(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        PetHeroDecorations.circleGlow2,
                        PetHeroDecorations.transparent,
                      ],
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
              ),
            ),
            // Floating stars
            const Positioned(
              top: 40,
              left: 45,
              child: IgnorePointer(
                child: Text(
                  '✧',
                  style: TextStyle(
                    fontSize: 15,
                    color: PetHeroDecorations.starColor,
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 70,
              right: 40,
              child: IgnorePointer(
                child: Text(
                  '✦',
                  style: TextStyle(
                    fontSize: 12,
                    color: PetHeroDecorations.starColor,
                  ),
                ),
              ),
            ),
            const Positioned(
              top: 30,
              right: 100,
              child: IgnorePointer(
                child: Text(
                  '✧',
                  style: TextStyle(
                    fontSize: 10,
                    color: PetHeroDecorations.starColor,
                  ),
                ),
              ),
            ),
            // Main content
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Sprite halo glow
                      Container(
                        width: 206,
                        height: 206,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              PetHeroDecorations.haloGlow,
                              PetHeroDecorations.transparent,
                            ],
                            stops: [0.0, 0.66],
                          ),
                        ),
                      ),
                      PetSprite(
                        species: status.pet.species,
                        state: spriteState,
                        size: 206,
                      ),
                    ],
                  ),
                  // Drop shadow underneath sprite
                  Transform.translate(
                    offset: const Offset(0, -4),
                    child: Container(
                      width: 132,
                      height: 15,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: const [
                          BoxShadow(
                            color: PetHeroDecorations.shadowColor,
                            blurRadius: 7,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
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
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: colors.colorText,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    status.pet.name,
                    style: type.display.copyWith(
                      fontSize: 34,
                      fontWeight: FontWeight.w900,
                      color: colors.colorText,
                      letterSpacing: -0.02 * 34,
                      shadows: const [PetHeroDecorations.textShadow],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    statusLine,
                    textAlign: TextAlign.center,
                    style: type.caption.copyWith(
                      fontSize: 13.5,
                      color: colors.colorText.withValues(alpha: 0.82),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
