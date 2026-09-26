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

/// The pane labels, never abbreviated (`ux/uiux-spec.md` §3).
String activityPaneLabel(BuildContext context, ActivityCardPane pane) {
  if (pane.isClosedArchive) {
    return activityHubText(context, 'Đã đóng', 'Closed');
  }
  final ActivityCardStatus? status = pane.status;
  return status == null
      ? activityHubText(context, 'Tất cả', 'All')
      : activityStatusLabel(context, status);
}

/// The four status labels, never abbreviated (`ux/uiux-spec.md` §3).
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

/// Segmented status filter: five fixed cells — the leading "Tất cả" view then
/// the four statuses (AC-10, D-1) — each carrying its full label plus a small
/// plain count (`ux/uiux-spec.md` §3 — never a red badge). Scrolls horizontally
/// when the viewport is too narrow rather than shrinking or truncating a label.
///
/// A sixth cell, "Đã đóng", is appended once [showClosedPane] is true. It is
/// the archive's only entry point, on the same strip and the same list as the
/// others — no second screen, no route of its own (`ux/uiux-spec.md` §3).
class ActivityStatusFilter extends StatelessWidget {
  const ActivityStatusFilter({
    super.key,
    required this.selected,
    required this.countOf,
    required this.onSelected,
    this.showClosedPane = false,
  });

  final ActivityCardPane selected;
  final int Function(ActivityCardPane) countOf;
  final ValueChanged<ActivityCardPane> onSelected;

  /// Off by default: a surface that has not been told a closure exists must not
  /// reveal one (AC-16).
  final bool showClosedPane;

  List<ActivityCardPane> get _panes => <ActivityCardPane>[
        for (final ActivityCardPane pane in ActivityCardPane.values)
          if (showClosedPane || !pane.isClosedArchive) pane,
      ];

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
          for (final ActivityCardPane pane in _panes) ...<Widget>[
            if (pane != _panes.first)
              const SizedBox(width: CupidSpacing.sm),
            _StatusCell(
              pane: pane,
              count: countOf(pane),
              isSelected: pane == selected,
              onTap: () => onSelected(pane),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  const _StatusCell({
    required this.pane,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  final ActivityCardPane pane;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final String label = activityPaneLabel(context, pane);

    return Semantics(
      button: true,
      selected: isSelected,
      child: GestureDetector(
        key: Key('activity_status_filter_cell_${pane.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platform.tapTarget),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected ? colors.colorAccentPink : null,
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
                    '· $count',
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
