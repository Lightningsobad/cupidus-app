import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../data/pet_models.dart';
import '../pet_strings.dart';

/// Stats row (`ux/uiux-spec.md` §2.1 item 4, §5 Open Item 2): exactly two
/// tiles — `totalInteractions` and `nextMilestone` — replacing the design
/// mockup's "day streak" / "badges" tiles, neither of which is backed by any
/// `pets` field. Never renders [PetStatus.milestone] (English-only backend
/// copy); the "{totalInteractions}/{nextMilestone}" caption is built from the
/// two numbers instead.
class PetStatsRow extends StatelessWidget {
  const PetStatsRow({super.key, required this.status});

  final PetStatus status;

  @override
  Widget build(BuildContext context) {
    final (int totalInteractions, int nextMilestone) =
        status.interactionsTowardNextMilestone;

    return Row(
      children: [
        Expanded(
          child: _StatTile(
            value: '$totalInteractions',
            label: context.viEn('Tương tác', 'Interactions'),
          ),
        ),
        SizedBox(width: CupidSpacing.sm),
        Expanded(
          child: _StatTile(
            value: '$nextMilestone',
            label: context.viEn('Mốc tiếp theo', 'Next milestone'),
            caption: '$totalInteractions/$nextMilestone',
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.value, required this.label, this.caption});

  final String value;
  final String label;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: CupidSpacing.md,
        horizontal: CupidSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: platformTokens.elevationShadow,
      ),
      child: Column(
        children: [
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
          SizedBox(height: CupidSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
          if (caption != null) ...[
            SizedBox(height: CupidSpacing.xs),
            Text(
              caption!,
              textAlign: TextAlign.center,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ],
        ],
      ),
    );
  }
}
