import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../data/pet_models.dart';
import '../pet_strings.dart';

/// XP card (`ux/uiux-spec.md` §2.1 item 2): progress bar toward the next
/// level, bound to [PetStatus.levelProgress]
/// (`(totalInteractions % 50) / 50`, computed in `pet_models.dart`). Do not
/// recompute level math here.
class PetXpCard extends StatelessWidget {
  const PetXpCard({super.key, required this.status});

  final PetStatus status;

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
            context.viEn('Kinh nghiệm', 'Experience'),
            style: context.cupidType.caption.copyWith(
              color: colors.colorTextMuted,
            ),
          ),
          SizedBox(height: CupidSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
            child: LinearProgressIndicator(
              value: status.levelProgress,
              minHeight: 8,
              backgroundColor: colors.colorSurfaceAlt,
              valueColor: AlwaysStoppedAnimation<Color>(
                colors.colorAccentPink,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
