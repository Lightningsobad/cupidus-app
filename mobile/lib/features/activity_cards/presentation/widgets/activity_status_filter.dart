import 'package:flutter/material.dart';

import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../domain/activity_card.dart';
import '../activity_card_list_cubit.dart';

/// `mobile/lib/l10n/` is outside this story's write scope, so the hub follows
/// the same file-local bilingual helper the Home and Timeline surfaces
/// already use instead of adding ARB keys.
String activityHubText(BuildContext context, String vi, String en) =>
    Localizations.localeOf(context).languageCode == 'vi' ? vi : en;

/// The four pane labels, never abbreviated (`ux/uiux-spec.md` §3).
String activityStatusLabel(BuildContext context, ActivityCardStatus status) {
  switch (status) {
    case ActivityCardStatus.idea:
      return activityHubText(context, 'Mới nghĩ ra', 'Just an idea');
    case ActivityCardStatus.scheduled:
      return activityHubText(context, 'Đã hẹn ngày', 'Date set');
    case ActivityCardStatus.done:
      return activityHubText(context, 'Đã đi rồi', 'Been there');
    case ActivityCardStatus.memory:
      return activityHubText(context, 'Đã thành kỷ niệm', 'A memory');
  }
}

/// Segmented status filter: exactly four fixed cells, each carrying its full
/// label plus a small plain count (`ux/uiux-spec.md` §3 — never a red badge).
/// Scrolls horizontally when the viewport is too narrow rather than shrinking
/// or truncating a label.
class ActivityStatusFilter extends StatelessWidget {
  const ActivityStatusFilter({
    super.key,
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  final ActivityCardStatus selected;
  final Map<ActivityCardStatus, int> counts;
  final ValueChanged<ActivityCardStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const Key('activity_status_filter'),
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: CupidSpacing.md,
        vertical: CupidSpacing.sm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final ActivityCardStatus status in kActivityCardPanes) ...<Widget>[
            if (status != kActivityCardPanes.first)
              const SizedBox(width: CupidSpacing.sm),
            _StatusCell(
              status: status,
              count: counts[status] ?? 0,
              isSelected: status == selected,
              onTap: () => onSelected(status),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  const _StatusCell({
    required this.status,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final ActivityCardStatus status;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final String label = activityStatusLabel(context, status);

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        key: Key('activity_status_filter_cell_${status.wireValue}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platform.tapTarget),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected ? colors.colorAccentPink : Colors.transparent,
              borderRadius: BorderRadius.circular(platform.radiusButton),
              border: isSelected
                  ? null
                  : Border.all(color: colors.colorLine),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CupidSpacing.md,
                vertical: CupidSpacing.sm,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    label,
                    style: type.body.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? colors.colorOnAccent
                          : colors.colorTextMuted,
                    ),
                  ),
                  const SizedBox(width: CupidSpacing.xs),
                  Text(
                    '$count',
                    style: type.caption.copyWith(
                      color: isSelected
                          ? colors.colorOnAccent
                          : colors.colorTextMuted,
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
