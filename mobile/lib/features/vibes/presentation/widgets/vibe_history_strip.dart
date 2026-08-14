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
///
/// Design-source geometry with no token equivalent (`Cupid Screens.dc.html`,
/// `isVibe` block): card `padding:17px`, an uppercase `12px/700` header at
/// `letter-spacing:.05em` sitting `14px` above the strip, `5px` between
/// columns and `7px` inside one, a `3px/2px` connector and a `9.5px` mono
/// day label.
const double _cardPadding = 17;
const double _headerSize = 12;
const double _headerLetterSpacing = 0.6;
const double _headerBottomGap = 14;
const double _columnGap = 5;
const double _stackGap = 7;
const double _faceSize = 26;
const double _connectorHeight = 3;
const double _connectorRadius = 2;
const double _dayLabelSize = 9.5;

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
      padding: const EdgeInsets.all(_cardPadding),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        boxShadow: platform.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            // `text-transform:uppercase` in the design source; the copy itself
            // stays the UX §6 A-2 wording, which drops the source's
            // unimplemented "auto-deleted in 30d" retention claim.
            context.historyHeader.toUpperCase(),
            style: context.cupidType.caption.copyWith(
              fontSize: _headerSize,
              letterSpacing: _headerLetterSpacing,
              color: colors.colorTextMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: _headerBottomGap),
          Row(
            children: <Widget>[
              for (int i = 0; i < length; i++)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: i == 0 ? 0 : _columnGap),
                    child: _HistoryColumn(
                      mine: mine[i],
                      partner: partner[i],
                      weekdayLabel: context.weekdayLabel(
                        today.subtract(Duration(days: length - 1 - i)),
                      ),
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
        VibeMoodFace(mood: mine, size: _faceSize),
        const SizedBox(height: _stackGap),
        Container(
          height: _connectorHeight,
          decoration: BoxDecoration(
            color: colors.colorLine,
            borderRadius: BorderRadius.circular(_connectorRadius),
          ),
        ),
        const SizedBox(height: _stackGap),
        VibeMoodFace(mood: partner, size: _faceSize),
        const SizedBox(height: _stackGap),
        Text(
          weekdayLabel,
          style: context.cupidType.labelMono.copyWith(
            fontSize: _dayLabelSize,
            color: colors.colorTextMuted,
          ),
        ),
      ],
    );
  }
}
