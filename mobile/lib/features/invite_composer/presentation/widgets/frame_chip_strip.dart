import 'package:flutter/material.dart';

import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';

/// Selected-chip fill (`ux/uiux-spec.md` §2.2: "nền `--pink` nhạt").
///
/// Derived from [CupidColorTokens.colorAccentPink] rather than taken from a
/// token, because no pale-pink token exists and the spec asks for the accent at
/// a lower intensity than the primary action — a second full-strength accent
/// next to the `--grad` CTA would read as a competing button.
const double _selectedChipFillOpacity = 0.22;

const double _chipBorderWidth = 1;

/// Horizontal strip of frame chips (`ux/uiux-spec.md` §2.2).
///
/// [labels] comes straight from the loaded pack, so the strip renders whatever
/// number of frames the pack holds. It shows no count, no position indicator,
/// and no "hết khung" terminator in any form (AC-26/AC-27/R-15b): with one
/// label it draws exactly one chip and no placeholder cell.
class FrameChipStrip extends StatelessWidget {
  const FrameChipStrip({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
  });

  /// Frame names as authored in the content pack. Content, not l10n — never
  /// translated or reworded here (R-15a).
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return SingleChildScrollView(
      key: const Key('frame_chip_strip'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.md),
      child: Row(
        children: <Widget>[
          for (int index = 0; index < labels.length; index++)
            Padding(
              padding: EdgeInsets.only(
                right: index == labels.length - 1 ? 0 : CupidSpacing.sm,
              ),
              child: _FrameChip(
                key: Key('invite_frame_chip_$index'),
                label: labels[index],
                selected: index == selectedIndex,
                onTap: () => onSelected(index),
                colors: colors,
                platform: platform,
                type: type,
              ),
            ),
        ],
      ),
    );
  }
}

class _FrameChip extends StatelessWidget {
  const _FrameChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
    required this.platform,
    required this.type,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final CupidColorTokens colors;
  final CupidPlatformTokens platform;
  final CupidTypographyTokens type;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platform.tapTarget),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: selected
                  ? colors.colorAccentPink
                      .withValues(alpha: _selectedChipFillOpacity)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(platform.radiusButton),
              border: selected
                  ? null
                  : Border.all(
                      color: colors.colorLine,
                      width: _chipBorderWidth,
                    ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CupidSpacing.md,
                vertical: CupidSpacing.sm,
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: selected
                      ? type.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.colorText,
                        )
                      : type.body.copyWith(color: colors.colorTextMuted),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
