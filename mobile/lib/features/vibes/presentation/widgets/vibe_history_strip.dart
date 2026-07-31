import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../domain/vibe_mood.dart';
import '../vibe_strings.dart';
import 'vibe_mood_face.dart';

/// The 7-day history strip (`ux/uiux-spec.md` §6): oldest→newest columns,
/// each showing both partners' [VibeMoodFace] glyphs with a connecting
/// divider and a day-of-week mono label. A missing day renders the `none`
/// face (`null` entry) for that side.
///
/// [mine] and [partner] are oldest-first, same length (7-slot per
/// `VibeState.myWeek`/`partnerWeek`, `phase-P1-vibe-cubit.md`), and are
/// assumed to end on local today — the day-of-week label for column `i` is
/// derived from `DateTime.now()` counting back from the last slot.
class VibeHistoryStrip extends StatelessWidget {
  const VibeHistoryStrip({super.key, required this.mine, required this.partner})
    : assert(
        mine.length == partner.length,
        'mine and partner must be the same length',
      );

  final List<VibeMood?> mine;
  final List<VibeMood?> partner;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final int length = mine.length;
    final DateTime today = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        boxShadow: platform.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.historyHeader,
            style: context.cupidType.caption.copyWith(
              color: colors.colorTextMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: CupidSpacing.md),
          Row(
            children: <Widget>[
              for (int i = 0; i < length; i++)
                Expanded(
                  child: _HistoryColumn(
                    mine: mine[i],
                    partner: partner[i],
                    weekdayLabel: context.weekdayLabel(
                      today.subtract(Duration(days: length - 1 - i)),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryColumn extends StatelessWidget {
  const _HistoryColumn({
    required this.mine,
    required this.partner,
    required this.weekdayLabel,
  });

  final VibeMood? mine;
  final VibeMood? partner;
  final String weekdayLabel;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Column(
      children: <Widget>[
        VibeMoodFace(mood: mine, size: 26),
        const SizedBox(height: CupidSpacing.xs),
        Container(height: 3, color: colors.colorLine),
        const SizedBox(height: CupidSpacing.xs),
        VibeMoodFace(mood: partner, size: 26),
        const SizedBox(height: CupidSpacing.xs),
        Text(
          weekdayLabel,
          style: context.cupidType.labelMono.copyWith(color: colors.colorTextMuted),
        ),
      ],
    );
  }
}
