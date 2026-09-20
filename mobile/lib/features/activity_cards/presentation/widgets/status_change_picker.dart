import 'package:flutter/material.dart';

import '../../../../design_system/icons/cupid_icons.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../domain/activity_card.dart';
import '../activity_card_detail_cubit.dart';
import 'activity_status_filter.dart';

/// The status picker the detail screen's "Chuyển trạng thái" row opens
/// (`ux/uiux-spec.md` §5, AC-14).
///
/// All four statuses are always offered, in both directions: a plan that was
/// cancelled goes back to *Mới nghĩ ra*, and a card mis-marked as a memory
/// comes back out. Nothing here filters the list by the current status, which
/// is what would turn a mistake into a one-way door.
Future<ActivityCardStatus?> showStatusChangePicker(
  BuildContext context, {
  required ActivityCardStatus current,
}) {
  final CupidPlatformTokens platform = context.cupidPlatform;
  final CupidColorTokens colors = context.cupidColors;

  return showModalBottomSheet<ActivityCardStatus>(
    context: context,
    backgroundColor: colors.colorSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(platform.radiusSheet),
      ),
    ),
    builder: (BuildContext sheetContext) =>
        _StatusChangeSheet(current: current),
  );
}

class _StatusChangeSheet extends StatelessWidget {
  const _StatusChangeSheet({required this.current});

  final ActivityCardStatus current;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return SafeArea(
      key: const Key('status_change_picker'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: CupidSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CupidSpacing.lg,
                0,
                CupidSpacing.lg,
                CupidSpacing.sm,
              ),
              child: Text(
                activityHubText(context, 'Chuyển trạng thái', 'Change status'),
                style: type.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.colorText,
                ),
              ),
            ),
            for (final ActivityCardStatus status in ActivityCardStatus.values)
              _StatusOption(status: status, selected: status == current),
          ],
        ),
      ),
    );
  }
}

class _StatusOption extends StatelessWidget {
  const _StatusOption({required this.status, required this.selected});

  final ActivityCardStatus status;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        key: Key('status_change_option_${status.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(status),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platform.tapTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CupidSpacing.lg,
              vertical: CupidSpacing.sm,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    activityStatusLabel(context, status),
                    style: type.body.copyWith(color: colors.colorText),
                  ),
                ),
                if (selected)
                  Icon(
                    CupidIcons.check,
                    size: 18,
                    color: colors.colorAccentPink,
                    semanticLabel: activityHubText(
                      context,
                      'Đang ở trạng thái này',
                      'Current status',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The AC-15 question, asked only when moving *Đã hẹn ngày* → *Mới nghĩ ra*
/// with a date already saved (`ux/uiux-spec.md` §5).
///
/// Two explicit branches, drawn identically. Neither is an
/// [ElevatedButton]-style default and neither is autofocused, so no keyboard
/// or accessibility default can trigger the destructive branch; only
/// [ScheduledDateChoice.clear] drops the date, and only on its own tap.
/// Dismissing the dialog returns `null`, which the caller treats as "leave the
/// card alone" — the safe outcome is what happens when the user does nothing.
Future<ScheduledDateChoice?> showScheduledDateChoiceDialog(
  BuildContext context,
) {
  return showDialog<ScheduledDateChoice>(
    context: context,
    builder: (BuildContext dialogContext) {
      final CupidColorTokens colors = dialogContext.cupidColors;
      final CupidPlatformTokens platform = dialogContext.cupidPlatform;
      final CupidTypographyTokens type = dialogContext.cupidType;

      return AlertDialog(
        key: const Key('scheduled_date_choice_dialog'),
        backgroundColor: colors.colorSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(platform.radiusCard),
        ),
        title: Text(
          activityHubText(
            dialogContext,
            'Giữ ngày hẹn đã lưu hay xoá luôn?',
            'Keep the saved date, or clear it?',
          ),
          style: type.body.copyWith(
            fontWeight: FontWeight.w600,
            color: colors.colorText,
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          ActivityDialogChoiceButton(
            optionKey: const Key('scheduled_date_choice_keep'),
            label: activityHubText(
              dialogContext,
              'Giữ ngày hẹn',
              'Keep the date',
            ),
            color: colors.colorText,
            onTap: () =>
                Navigator.of(dialogContext).pop(ScheduledDateChoice.keep),
          ),
          ActivityDialogChoiceButton(
            optionKey: const Key('scheduled_date_choice_clear'),
            label: activityHubText(
              dialogContext,
              'Xoá ngày hẹn',
              'Clear the date',
            ),
            color: colors.colorRed,
            onTap: () =>
                Navigator.of(dialogContext).pop(ScheduledDateChoice.clear),
          ),
        ],
      );
    },
  );
}

/// A dialog action drawn as plain text on the dialog surface. Shared by the
/// AC-15 question and the AC-16 delete dialog so the two choices in each are
/// visually equal apart from the color of the destructive label.
class ActivityDialogChoiceButton extends StatelessWidget {
  const ActivityDialogChoiceButton({
    super.key,
    required this.optionKey,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final Key optionKey;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: true,
      child: GestureDetector(
        key: optionKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platform.tapTarget),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: CupidSpacing.md),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                style: type.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
