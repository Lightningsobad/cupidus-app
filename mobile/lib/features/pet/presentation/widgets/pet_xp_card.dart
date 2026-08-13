import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

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
    final CupidTypographyTokens type = context.cupidType;
    final double progress = status.levelProgress.clamp(0.0, 1.0);
    final int percent = (progress * 100).round();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                context.viEn('Kinh nghiệm', 'Experience'),
                style: type.caption.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.colorText,
                ),
              ),
              Text(
                '$percent%',
                // `labelMono` is intentionally unsized (see its dartdoc);
                // 12 is the design source's size for this readout.
                style: type.labelMono.copyWith(
                  fontSize: 12,
                  color: colors.colorAccentPink,
                ),
              ),
            ],
          ),
          SizedBox(height: CupidSpacing.sm),
          Semantics(
            value: '$percent%',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
              child: SizedBox(
                height: 12,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: ColoredBox(color: colors.colorSurfaceAlt),
                    ),
                    FractionallySizedBox(
                      widthFactor: progress,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: colors.gradientDream,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
