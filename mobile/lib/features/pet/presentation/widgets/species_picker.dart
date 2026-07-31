import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../data/pet_models.dart';
import '../pet_strings.dart';

/// Species label copy is local to this file rather than `pet_strings.dart`:
/// that file is outside P7's write scope (mirrors `pet_screen.dart`'s own
/// local `_petFailureMessage` for the same reason).
String speciesLabel(BuildContext context, PetSpecies species) =>
    switch (species) {
      PetSpecies.cat => context.viEn('Mèo', 'Cat'),
      PetSpecies.dog => context.viEn('Chó', 'Dog'),
      PetSpecies.bunny => context.viEn('Thỏ', 'Bunny'),
    };

/// Adopt-sheet species chooser (`ux/uiux-spec.md` §2.2 item 2, §5 Open Item
/// 4): three horizontally scrollable labelled-icon cards exposed as a
/// single-select radio-group semantic (§7), not unlabelled tappable cards.
/// Reuses `CupidIcons.pets` for all three species — no per-species art exists
/// yet (Open Item 4) — so the label text is the sole visual differentiator.
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
      height: 88,
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
        horizontal: CupidSpacing.sm,
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
          CupidIcon(CupidIcons.pets, size: 28, color: colors.colorText),
          SizedBox(height: CupidSpacing.xs),
          Text(
            label,
            style: context.cupidType.caption.copyWith(color: colors.colorText),
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
