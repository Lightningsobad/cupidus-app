import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../data/pet_models.dart';
import '../../data/pet_mood.dart';
import '../pet_strings.dart';
import 'pet_sprite.dart';

/// "How pet reacts" reference card: three reference sprites at the fixed
/// 46px reference-row size — a positive state plus the two "if you ignore me"
/// states, `sulk` and `sick`.
class PetReactionsCard extends StatelessWidget {
  const PetReactionsCard({
    super.key,
    this.species = PetSpecies.cat,
    this.petName,
  });

  final PetSpecies species;
  final String? petName;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final String title = petName != null
        ? context.viEn('$petName phản ứng thế nào', 'How $petName reacts')
        : switch (species) {
            PetSpecies.cat => context.viEn('Bún phản ứng thế nào', 'How Bun reacts'),
            PetSpecies.dog => context.viEn('Bơ phản ứng thế nào', 'How Bo reacts'),
            PetSpecies.bunny => context.viEn('Sữa phản ứng thế nào', 'How Sua reacts'),
            PetSpecies.bear => context.viEn('Mochi phản ứng thế nào', 'How Mochi reacts'),
            PetSpecies.chick => context.viEn('Xoài phản ứng thế nào', 'How Xoai reacts'),
            PetSpecies.panda => context.viEn('Kem phản ứng thế nào', 'How Kem reacts'),
          };

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
            title.toUpperCase(),
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
                  species: species,
                  state: BunSpriteState.happy,
                  caption: context.petMoodLabel(PetMood.happy),
                  accent: colors.colorMint,
                ),
              ),
              SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: _ReactionTile(
                  species: species,
                  state: BunSpriteState.sulk,
                  caption: 'Bơ một chút',
                  accent: colors.colorAmber,
                ),
              ),
              SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: _ReactionTile(
                  species: species,
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
    required this.species,
    required this.state,
    required this.caption,
    required this.accent,
  });

  final PetSpecies species;
  final BunSpriteState state;
  final String caption;
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
          PetSprite(species: species, state: state, size: 46),
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
