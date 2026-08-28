import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../reminder_strings.dart';

/// Interactive hour and minute wheel picker styled with theme design tokens.
class ReminderTimeWheelPicker extends StatefulWidget {
  const ReminderTimeWheelPicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
  });

  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;

  @override
  State<ReminderTimeWheelPicker> createState() => _ReminderTimeWheelPickerState();
}

class _ReminderTimeWheelPickerState extends State<ReminderTimeWheelPicker> {
  late int _hour;
  late int _minute;
  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _hour = widget.initialTime.hour;
    _minute = widget.initialTime.minute;
    _hourController = FixedExtentScrollController(initialItem: _hour);
    _minuteController = FixedExtentScrollController(initialItem: _minute);
  }

  @override
  void didUpdateWidget(covariant ReminderTimeWheelPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTime != widget.initialTime) {
      _hour = widget.initialTime.hour;
      _minute = widget.initialTime.minute;
      if (_hourController.hasClients && _hourController.selectedItem != _hour) {
        _hourController.jumpToItem(_hour);
      }
      if (_minuteController.hasClients && _minuteController.selectedItem != _minute) {
        _minuteController.jumpToItem(_minute);
      }
    }
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  void _updateHour(int newHour) {
    setState(() => _hour = newHour);
    widget.onTimeChanged(TimeOfDay(hour: _hour, minute: _minute));
  }

  void _updateMinute(int newMinute) {
    setState(() => _minute = newMinute);
    widget.onTimeChanged(TimeOfDay(hour: _hour, minute: _minute));
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens palette = context.cupidColors;
    final CupidTypographyTokens typography = context.cupidType;

    return Container(
      height: 180,
      decoration: BoxDecoration(
        color: palette.colorSurface.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: palette.colorLine,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Middle Selection Highlight Bar
          Positioned(
            left: 20,
            right: 20,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: palette.colorAccentPink.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: palette.colorAccentPink.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Hour Wheel (00 - 23)
              Expanded(
                child: CupertinoPicker.builder(
                  scrollController: _hourController,
                  itemExtent: 44,
                  selectionOverlay: const SizedBox.shrink(),
                  onSelectedItemChanged: _updateHour,
                  childCount: 24,
                  itemBuilder: (context, index) {
                    final isSelected = index == _hour;
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: typography.display.copyWith(
                          fontSize: isSelected ? 32 : 22,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                          color: isSelected
                              ? palette.colorText
                              : palette.colorTextMuted.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Colon Separator
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  ':',
                  style: typography.display.copyWith(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: palette.colorText,
                  ),
                ),
              ),
              // Minute Wheel (00 - 59)
              Expanded(
                child: CupertinoPicker.builder(
                  scrollController: _minuteController,
                  itemExtent: 44,
                  selectionOverlay: const SizedBox.shrink(),
                  onSelectedItemChanged: _updateMinute,
                  childCount: 60,
                  itemBuilder: (context, index) {
                    final isSelected = index == _minute;
                    return Center(
                      child: Text(
                        index.toString().padLeft(2, '0'),
                        style: typography.display.copyWith(
                          fontSize: isSelected ? 32 : 22,
                          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
                          color: isSelected
                              ? palette.colorText
                              : palette.colorTextMuted.withValues(alpha: 0.6),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          // Column Headers
          Positioned(
            top: 8,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  context.reminderHourLabel,
                  style: typography.caption.copyWith(
                    color: palette.colorTextMuted,
                    fontSize: 11,
                  ),
                ),
                Text(
                  context.reminderMinuteLabel,
                  style: typography.caption.copyWith(
                    color: palette.colorTextMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
