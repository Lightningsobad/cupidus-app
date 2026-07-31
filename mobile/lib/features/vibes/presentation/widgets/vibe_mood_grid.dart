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
        const SizedBox(height: CupidSpacing.md),
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
        for (final VibeMood mood in moods)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.xs),
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
                vertical: CupidSpacing.md,
                horizontal: CupidSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected ? null : colors.colorSurface,
                gradient: isSelected ? colors.gradientDream : null,
                borderRadius: BorderRadius.circular(platform.radiusCard),
                border: isSelected
                    ? Border.all(color: colors.colorAccentPink, width: 1.5)
                    : null,
                boxShadow: isSelected ? colors.glowShadow : platform.elevationShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  VibeMoodFace(mood: mood, size: 52),
                  const SizedBox(height: CupidSpacing.sm),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.cupidType.caption.copyWith(
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
