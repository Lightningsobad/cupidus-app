import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../data/pet_models.dart';
import '../../data/pet_mood.dart';
import '../pet_strings.dart';
import 'pet_sprite.dart';

/// Species label copy supporting all 6 adoptable companion species.
String speciesLabel(BuildContext context, PetSpecies species) =>
    switch (species) {
      PetSpecies.cat => context.viEn('Mèo', 'Cat'),
      PetSpecies.dog => context.viEn('Chó', 'Dog'),
      PetSpecies.bunny => context.viEn('Thỏ', 'Bunny'),
      PetSpecies.bear => context.viEn('Gấu', 'Bear'),
      PetSpecies.chick => context.viEn('Gà con', 'Chick'),
      PetSpecies.panda => context.viEn('Gấu trúc', 'Panda'),
    };

/// Adopt-sheet species chooser supporting all 6 companion species
/// (Bún/Cat, Bơ/Shiba, Sữa/Bunny, Mochi/Bear, Xoài/Chick, Kem/Panda)
/// with live animated mini vector sprites.
class SpeciesPicker extends StatelessWidget {
  const SpeciesPicker({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PetSpecies? selected;
  final ValueChanged<PetSpecies> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: PetSpecies.values.length,
        separatorBuilder: (_, _) => SizedBox(width: CupidSpacing.sm),
        itemBuilder: (context, index) {
          final PetSpecies species = PetSpecies.values[index];
          return _SpeciesCard(
            species: species,
            isSelected: species == selected,
            onTap: () => onSelected(species),
          );
        },
      ),
    );
  }
}

class _SpeciesCard extends StatelessWidget {
  const _SpeciesCard({
    required this.species,
    required this.isSelected,
    required this.onTap,
  });

  final PetSpecies species;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final String label = speciesLabel(context, species);

    final Widget card = Container(
      width: 84,
      padding: EdgeInsets.symmetric(
        horizontal: CupidSpacing.xs,
        vertical: CupidSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: isSelected ? colors.colorSurfaceAlt : colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
        border: Border.all(
          color: isSelected ? colors.colorAccentPink : colors.colorLine,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          PetSprite(
            species: species,
            state: BunSpriteState.happy,
            size: 38,
          ),
          SizedBox(height: CupidSpacing.xs / 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.cupidType.caption.copyWith(
              color: colors.colorText,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );

    return Semantics(
      inMutuallyExclusiveGroup: true,
      button: true,
      selected: isSelected,
      label: label,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}
