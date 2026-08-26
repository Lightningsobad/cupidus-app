import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../data/pet_models.dart';
import '../pet_strings.dart';

/// Stats row (`Cupid Screens.dc.html` lines 694-698): exactly three
/// tiles — `totalInteractions` (heart icon in pink), `streak` (flame icon in mint),
/// and `badges` (military tech icon in butter) — matching the design source verbatim.
class PetStatsRow extends StatelessWidget {
  const PetStatsRow({super.key, required this.status});

  final PetStatus status;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: CupidIcons.favorite,
            iconColor: colors.colorAccentPink,
            value: status.formattedInteractions,
            label: context.viEn('tương tác', 'interactions'),
          ),
        ),
        SizedBox(width: CupidSpacing.sm),
        Expanded(
          child: _StatTile(
            icon: CupidIcons.localFireDepartment,
            iconColor: colors.colorMint,
            value: '${status.streak}',
            label: context.viEn('ngày streak', 'day streak'),
          ),
        ),
        SizedBox(width: CupidSpacing.sm),
        Expanded(
          child: _StatTile(
            icon: CupidIcons.militaryTech,
            iconColor: colors.colorButter,
            value: '${status.badgesCount}',
            label: context.viEn('huy hiệu', 'badges'),
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CupidIcon(icon, size: 22, color: iconColor),
          const SizedBox(height: 7),
          Text(
            value,
            textAlign: TextAlign.center,
            // Design source sizes this Nunito/900 stat value at 19; the
            // `display` role carries the family/weight, not this size.
            style: type.display.copyWith(
              fontSize: 19,
              color: colors.colorText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(
              fontSize: 10.5,
              color: colors.colorTextMuted,
            ),
          ),
        ],
      ),
    );
  }
}
