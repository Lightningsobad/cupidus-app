import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/widgets.dart';

import '../../domain/vibe_mood.dart';
import '../vibe_strings.dart';
import 'vibe_mood_face.dart';

/// The 5-cell mood picker, 2 rows (3 + 2, centered) per `ux/uiux-spec.md`
/// §3's design/backend mismatch resolution — the design source's 6-cell
/// `moodList` drops the backend-less `soft` cell.
///
/// Props-only (`coding-plan/master-plan.md` §3 "Props-only widgets" row): the
/// grid is simultaneously the input control and the status display (UX §4)
/// — [selected] is the mood to highlight, tapping a cell calls [onPick], and
/// [enabled] locks every cell while a submit is in flight (R-010-2).
///
/// Design-source geometry with no token equivalent (`Cupid Screens.dc.html`,
/// `isVibe` block): grid `gap:11px`, cell `padding:17px 8px`, a `1.5px`
/// border kept in both states, and a `12.5px` label `10px` below the face.
const double _gridGap = 11;
const double _cellVerticalPadding = 17;
const double _cellBorderWidth = 1.5;
const double _cellFaceSize = 52;
const double _cellLabelGap = 10;
const double _cellLabelSize = 12.5;

/// `linear-gradient(140deg, rgba(255,127,182,.3), rgba(183,140,245,.26))` —
/// the selected cell's translucent fill. Not `gradientDream`/`gradientHot`:
/// both are opaque and run at 120deg. Direction follows the same CSS-angle
/// mapping as `cupid_color_tokens.dart` (`end = (sin θ, -cos θ)`).
const Alignment _gradient140Begin = Alignment(
  -0.6427876096865393,
  -0.766044443118978,
);
const Alignment _gradient140End = Alignment(
  0.6427876096865393,
  0.766044443118978,
);
const double _selectedPinkOpacity = 0.3;
const double _selectedPurpleOpacity = 0.26;

class VibeMoodGrid extends StatelessWidget {
  const VibeMoodGrid({
    super.key,
    required this.selected,
    required this.enabled,
    required this.onPick,
  });

  final VibeMood? selected;
  final bool enabled;
  final ValueChanged<VibeMood> onPick;

  static const List<VibeMood> _topRow = <VibeMood>[
    VibeMood.happy,
    VibeMood.sad,
    VibeMood.angry,
  ];
  static const List<VibeMood> _bottomRow = <VibeMood>[
    VibeMood.horny,
    VibeMood.tired,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _MoodRow(moods: _topRow, selected: selected, enabled: enabled, onPick: onPick),
        const SizedBox(height: _gridGap),
        // 2/3 the width of the 3-cell row above gives the 2-cell row the
        // same per-cell width, centered, with no separate width calculation.
        FractionallySizedBox(
          widthFactor: 2 / 3,
          child: _MoodRow(
            moods: _bottomRow,
            selected: selected,
            enabled: enabled,
            onPick: onPick,
          ),
        ),
      ],
    );
  }
}

class _MoodRow extends StatelessWidget {
  const _MoodRow({
    required this.moods,
    required this.selected,
    required this.enabled,
    required this.onPick,
  });

  final List<VibeMood> moods;
  final VibeMood? selected;
  final bool enabled;
  final ValueChanged<VibeMood> onPick;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        for (final (int index, VibeMood mood) in moods.indexed)
          Expanded(
            child: Padding(
              // Column gap only, never an outer inset: the grid's own edges
              // align with the screen padding in the design source.
              padding: EdgeInsets.only(left: index == 0 ? 0 : _gridGap),
              child: _MoodCell(
                mood: mood,
                isSelected: mood == selected,
                enabled: enabled,
                onPick: onPick,
              ),
            ),
          ),
      ],
    );
  }
}

class _MoodCell extends StatelessWidget {
  const _MoodCell({
    required this.mood,
    required this.isSelected,
    required this.enabled,
    required this.onPick,
  });

  final VibeMood mood;
  final bool isSelected;
  final bool enabled;
  final ValueChanged<VibeMood> onPick;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final String label = context.moodLabel(mood);

    return Semantics(
      button: true,
      enabled: enabled,
      selected: isSelected,
      label: label,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: enabled ? () => onPick(mood) : null,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: platform.tapTarget,
              minHeight: platform.tapTarget,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: _cellVerticalPadding,
                horizontal: CupidSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isSelected ? null : colors.colorSurface,
                gradient: isSelected
                    ? LinearGradient(
                        begin: _gradient140Begin,
                        end: _gradient140End,
                        colors: <Color>[
                          colors.colorAccentPink.withValues(
                            alpha: _selectedPinkOpacity,
                          ),
                          colors.colorAccentPurple.withValues(
                            alpha: _selectedPurpleOpacity,
                          ),
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(platform.radiusCard),
                border: Border.all(
                  // The off state keeps a `1.5px solid transparent` border so
                  // selecting a cell never resizes it. No transparent token
                  // exists and the no-fork guard bans the framework's raw
                  // color constants, so the cell's own surface color stands in.
                  color: isSelected ? colors.colorAccentPink : colors.colorSurface,
                  width: _cellBorderWidth,
                ),
                boxShadow: isSelected ? colors.glowShadow : platform.elevationShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  VibeMoodFace(mood: mood, size: _cellFaceSize),
                  const SizedBox(height: _cellLabelGap),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.cupidType.caption.copyWith(
                      fontSize: _cellLabelSize,
                      color: isSelected ? colors.colorText : colors.colorTextMuted,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
