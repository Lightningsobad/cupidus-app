import 'package:flutter/material.dart';

import '../../../../design_system/icons/cupid_icons.dart';
import '../../../../design_system/theme/cupid_theme_context.dart';
import '../../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../../design_system/tokens/cupid_spacing.dart';
import '../../../../design_system/tokens/cupid_typography_tokens.dart';
import '../../domain/time_of_day_slot.dart';
import 'activity_status_filter.dart';

/// The five answers the KHUNG GIỜ cell can carry: the four slots plus *Chưa
/// rõ*, which is a real answer and not a cancel. Picking it writes `null`.
///
/// [TimeOfDaySlotChoice.unset] exists so the sheet can tell "the user chose
/// *Chưa rõ*" from "the user dismissed the sheet", which returns `null` and
/// writes nothing.
enum TimeOfDaySlotChoice { morning, noon, afternoon, evening, unset }

/// The [TimeOfDaySlot] a choice writes. *Chưa rõ* clears the column.
TimeOfDaySlot? timeOfDaySlotForChoice(TimeOfDaySlotChoice choice) {
  switch (choice) {
    case TimeOfDaySlotChoice.morning:
      return TimeOfDaySlot.morning;
    case TimeOfDaySlotChoice.noon:
      return TimeOfDaySlot.noon;
    case TimeOfDaySlotChoice.afternoon:
      return TimeOfDaySlot.afternoon;
    case TimeOfDaySlotChoice.evening:
      return TimeOfDaySlot.evening;
    case TimeOfDaySlotChoice.unset:
      return null;
  }
}

TimeOfDaySlotChoice _choiceForSlot(TimeOfDaySlot? slot) {
  switch (slot) {
    case null:
      return TimeOfDaySlotChoice.unset;
    case TimeOfDaySlot.morning:
      return TimeOfDaySlotChoice.morning;
    case TimeOfDaySlot.noon:
      return TimeOfDaySlotChoice.noon;
    case TimeOfDaySlot.afternoon:
      return TimeOfDaySlotChoice.afternoon;
    case TimeOfDaySlot.evening:
      return TimeOfDaySlotChoice.evening;
  }
}

String timeOfDaySlotChoiceLabel(
  BuildContext context,
  TimeOfDaySlotChoice choice,
) {
  switch (choice) {
    case TimeOfDaySlotChoice.morning:
      return activityHubText(context, 'Sáng', 'Morning');
    case TimeOfDaySlotChoice.noon:
      return activityHubText(context, 'Trưa', 'Midday');
    case TimeOfDaySlotChoice.afternoon:
      return activityHubText(context, 'Chiều', 'Afternoon');
    case TimeOfDaySlotChoice.evening:
      return activityHubText(context, 'Tối', 'Evening');
    case TimeOfDaySlotChoice.unset:
      return activityHubText(context, 'Chưa rõ', 'Not set');
  }
}

/// One level, five options, no nesting — the same shape as the status picker
/// (§13.2). Returns `null` when the sheet is dismissed without a tap, which the
/// caller must treat as "leave the card alone".
Future<TimeOfDaySlotChoice?> showTimeOfDaySlotPicker(
  BuildContext context, {
  required TimeOfDaySlot? current,
}) {
  final CupidPlatformTokens platform = context.cupidPlatform;
  final CupidColorTokens colors = context.cupidColors;

  return showModalBottomSheet<TimeOfDaySlotChoice>(
    context: context,
    backgroundColor: colors.colorSurface,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(platform.radiusSheet),
      ),
    ),
    builder: (BuildContext sheetContext) =>
        TimeOfDaySlotPicker(current: current),
  );
}

class TimeOfDaySlotPicker extends StatelessWidget {
  const TimeOfDaySlotPicker({super.key, required this.current});

  final TimeOfDaySlot? current;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final TimeOfDaySlotChoice selected = _choiceForSlot(current);

    return SafeArea(
      key: const Key('time_of_day_slot_picker'),
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
                activityHubText(context, 'Khung giờ', 'Time of day'),
                style: type.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colors.colorText,
                ),
              ),
            ),
            for (final TimeOfDaySlotChoice choice in TimeOfDaySlotChoice.values)
              _SlotOption(choice: choice, selected: choice == selected),
          ],
        ),
      ),
    );
  }
}

class _SlotOption extends StatelessWidget {
  const _SlotOption({required this.choice, required this.selected});

  final TimeOfDaySlotChoice choice;
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
        key: Key('time_of_day_slot_option_${choice.name}'),
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).pop(choice),
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
                    timeOfDaySlotChoiceLabel(context, choice),
                    style: type.body.copyWith(
                      color: choice == TimeOfDaySlotChoice.unset
                          ? colors.colorTextMuted
                          : colors.colorText,
                    ),
                  ),
                ),
                if (selected)
                  Icon(
                    CupidIcons.check,
                    size: 18,
                    color: colors.colorAccentPink,
                    semanticLabel: activityHubText(
                      context,
                      'Đang ở khung giờ này',
                      'Current time of day',
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
