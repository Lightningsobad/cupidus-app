import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../reminder_strings.dart';

/// The 7-day chip row (`ux/uiux-spec.md` §2). [selected] and [onChanged] use
/// `DateTime.weekday` values (`DateTime.monday` == 1 .. `DateTime.sunday` ==
/// 7). This is a client-local selection only (ASSUMPTION-1) -- it never
/// implies a recurring schedule in its own label; the recurrence caveat
/// lives in the rule card, not here.
class ReminderWeekdayChips extends StatelessWidget {
  const ReminderWeekdayChips({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final Set<int> selected;
  final ValueChanged<Set<int>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: CupidSpacing.xs,
      runSpacing: CupidSpacing.xs,
      children: [
        for (int weekday = 1; weekday <= 7; weekday++)
          _WeekdayChip(
            weekday: weekday,
            isSelected: selected.contains(weekday),
            onTap: () {
              final Set<int> next = Set<int>.from(selected);
              if (!next.remove(weekday)) {
                next.add(weekday);
              }
              onChanged(next);
            },
          ),
      ],
    );
  }
}

class _WeekdayChip extends StatelessWidget {
  const _WeekdayChip({
    required this.weekday,
    required this.isSelected,
    required this.onTap,
  });

  final int weekday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Semantics(
      button: true,
      toggled: isSelected,
      label: context.reminderWeekdayFullLabel(weekday),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: platformTokens.tapTarget,
          minHeight: platformTokens.tapTarget,
        ),
        child: Material(
          color: isSelected ? colors.colorMint : colors.colorSurfaceAlt,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: Center(
              child: Text(
                context.reminderWeekdayShortLabel(weekday),
                style: type.caption.copyWith(
                  color: isSelected ? colors.colorBackground : colors.colorText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
