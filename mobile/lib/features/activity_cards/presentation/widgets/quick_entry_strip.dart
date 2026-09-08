import 'package:flutter/material.dart';

import '../../../../design_system/icons/cupid_icon.dart';
import '../../../../design_system/icons/cupid_icons.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import 'activity_status_filter.dart';

/// The three fixed quick-entry cells (`ux/uiux-spec.md` §6). The set is closed
/// and ordered: the strip renders every value, always, so its shape never
/// depends on how much data the store holds.
enum QuickEntryCell { giftIdeas, conversationStarters, zodiacShell }

/// Number of cells the strip renders. Named so a test can pin the count
/// without restating the literal the widget uses.
const int kQuickEntryCellCount = 3;

/// Narrowest a cell may get before its one-line label stops being readable.
/// Below this the strip scrolls horizontally rather than squeezing three cells
/// into the viewport, because an ellipsised label is not a usable entry point
/// (S5-F-4).
const double kQuickEntryMinCellWidth = 104;

/// The always-visible three-cell quick-entry strip (`ux/uiux-spec.md` §6).
///
/// Every cell is the same size and carries a `filled` glyph plus one label
/// line, with deliberately no count badge and no "new" dot. The stories that
/// fill the cells (STORY-002/004/005/011) have not shipped, so each tap
/// answers with the neutral "sắp có" message §6 prescribes for an unfilled
/// entry point rather than becoming a dead end (SC-5).
class QuickEntryStrip extends StatelessWidget {
  const QuickEntryStrip({super.key, this.onCellSelected});

  /// Overrides the neutral placeholder response, for the story that eventually
  /// fills a cell. Left null everywhere today.
  final ValueChanged<QuickEntryCell>? onCellSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: const Key('activity_quick_entry_strip'),
      padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.md),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          const double gaps = CupidSpacing.sm * (kQuickEntryCellCount - 1);
          final double evenWidth =
              (constraints.maxWidth - gaps) / kQuickEntryCellCount;
          final bool fits = evenWidth >= kQuickEntryMinCellWidth;
          final double cellWidth = fits ? evenWidth : kQuickEntryMinCellWidth;

          final Widget row = Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              for (int slot = 0;
                  slot < kQuickEntryCellCount;
                  slot++) ...<Widget>[
                if (slot > 0) const SizedBox(width: CupidSpacing.sm),
                SizedBox(
                  width: cellWidth,
                  child: _QuickEntryCell(
                    slot: slot,
                    cell: QuickEntryCell.values[slot],
                    onSelected: onCellSelected,
                  ),
                ),
              ],
            ],
          );

          if (fits) {
            return row;
          }
          // The set of cells is closed and ordered, so scrolling is the only
          // way a narrow screen keeps all three reachable: dropping or
          // wrapping one would change the strip's shape per device.
          return SingleChildScrollView(
            key: const Key('activity_quick_entry_strip_scroll'),
            scrollDirection: Axis.horizontal,
            child: row,
          );
        },
      ),
    );
  }
}

class _QuickEntryCell extends StatelessWidget {
  const _QuickEntryCell({
    required this.slot,
    required this.cell,
    required this.onSelected,
  });

  final int slot;
  final QuickEntryCell cell;
  final ValueChanged<QuickEntryCell>? onSelected;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final String label = _label(context, cell);

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        key: Key('activity_quick_entry_slot_$slot'),
        behavior: HitTestBehavior.opaque,
        onTap: () => _handleTap(context),
        child: SizedBox(
          height: platform.tapTarget + CupidSpacing.lg,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.colorSurface,
              borderRadius: BorderRadius.circular(platform.radiusSmall),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CupidSpacing.xs,
                vertical: CupidSpacing.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CupidIcon(
                    _glyph(cell),
                    color: colors.colorAccentLilac,
                    size: 22,
                  ),
                  const SizedBox(height: CupidSpacing.xs),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: type.caption.copyWith(color: colors.colorText),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    final ValueChanged<QuickEntryCell>? handler = onSelected;
    if (handler != null) {
      handler(cell);
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        key: const Key('activity_quick_entry_coming_soon'),
        content: Text(activityHubText(context, 'Sắp có', 'Coming soon')),
      ),
    );
  }
}

/// `CupidIcons` is closed to this phase (P7 owns it), so each cell reuses an
/// existing token rather than adding a codepoint: `mood` carries the
/// conversation cell because `lightbulb` is already the "Ý tưởng" tab glyph in
/// the same shell.
IconData _glyph(QuickEntryCell cell) {
  switch (cell) {
    case QuickEntryCell.giftIdeas:
      return CupidIcons.redeem;
    case QuickEntryCell.conversationStarters:
      return CupidIcons.mood;
    case QuickEntryCell.zodiacShell:
      return CupidIcons.autoAwesome;
  }
}

String _label(BuildContext context, QuickEntryCell cell) {
  switch (cell) {
    case QuickEntryCell.giftIdeas:
      return activityHubText(context, 'Gợi ý quà', 'Gift ideas');
    case QuickEntryCell.conversationStarters:
      return activityHubText(context, 'Mồi chuyện', 'Ice breakers');
    case QuickEntryCell.zodiacShell:
      return activityHubText(context, 'Vỏ hoàng đạo', 'Zodiac shell');
  }
}
