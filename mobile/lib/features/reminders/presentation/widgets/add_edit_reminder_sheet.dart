import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../domain/synced_reminder.dart';
import '../reminder_strings.dart';
import 'reminder_time_wheel_picker.dart';
import 'reminder_weekday_chips.dart';

/// Modal bottom sheet for creating or editing a synced reminder with mutual consent.
class AddEditReminderSheet extends StatefulWidget {
  const AddEditReminderSheet({
    super.key,
    this.existing,
    required this.onSave,
    this.onDelete,
  });

  final SyncedReminder? existing;
  final void Function(DateTime time, String description, Set<int> weekdays) onSave;
  final VoidCallback? onDelete;

  static Future<void> show({
    required BuildContext context,
    SyncedReminder? existing,
    required void Function(DateTime time, String description, Set<int> weekdays) onSave,
    VoidCallback? onDelete,
  }) {
    final CupidColorTokens palette = context.cupidColors;
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.colorBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: AddEditReminderSheet(
          existing: existing,
          onSave: onSave,
          onDelete: onDelete,
        ),
      ),
    );
  }

  @override
  State<AddEditReminderSheet> createState() => _AddEditReminderSheetState();
}

class _AddEditReminderSheetState extends State<AddEditReminderSheet> {
  late TimeOfDay _timeOfDay;
  late TextEditingController _descriptionController;
  late Set<int> _weekdays;

  @override
  void initState() {
    super.initState();
    final initial = widget.existing?.time ?? DateTime.now().add(const Duration(minutes: 5));
    _timeOfDay = TimeOfDay(hour: initial.hour, minute: initial.minute);
    _descriptionController = TextEditingController(
      text: widget.existing?.description ?? 'Nhắc nhở đồng bộ',
    );
    _weekdays = Set<int>.from(widget.existing?.weekdays ?? const <int>{});
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final now = DateTime.now();
    final targetTime = DateTime(
      now.year,
      now.month,
      now.day,
      _timeOfDay.hour,
      _timeOfDay.minute,
    );
    final desc = _descriptionController.text.trim().isEmpty
        ? 'Nhắc nhở đồng bộ'
        : _descriptionController.text.trim();

    widget.onSave(targetTime, desc, _weekdays);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens palette = context.cupidColors;
    final CupidTypographyTokens typography = context.cupidType;
    final isEditing = widget.existing != null;

    final tags = [
      context.reminderTagWakeUp,
      context.reminderTagDrinkWater,
      context.reminderTagPills,
      context.reminderTagDate,
      context.reminderTagSleep,
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: palette.colorLine.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEditing
                    ? context.reminderEditTitle
                    : context.reminderCreateTitle,
                style: typography.cardTitle.copyWith(
                  fontWeight: FontWeight.w800,
                  color: palette.colorText,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: palette.colorTextMuted,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Time Wheel Picker
          ReminderTimeWheelPicker(
            initialTime: _timeOfDay,
            onTimeChanged: (t) => setState(() => _timeOfDay = t),
          ),
          const SizedBox(height: 20),

          // Description / Label Section
          Text(
            context.reminderDescriptionLabel,
            style: typography.body.copyWith(
              color: palette.colorText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            style: typography.body.copyWith(color: palette.colorText),
            decoration: InputDecoration(
              hintText: context.reminderDescriptionHint,
              hintStyle: typography.body.copyWith(color: palette.colorTextMuted),
              filled: true,
              fillColor: palette.colorSurface.withValues(alpha: 0.4),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: palette.colorLine,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: palette.colorLine,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: palette.colorAccentPink,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Suggestion Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: tags.map((tag) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      tag,
                      style: typography.caption.copyWith(
                        color: palette.colorText,
                        fontSize: 12,
                      ),
                    ),
                    backgroundColor: palette.colorSurface.withValues(alpha: 0.4),
                    side: BorderSide(
                      color: palette.colorLine.withValues(alpha: 0.5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () {
                      _descriptionController.text = tag;
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Repeat Days Section
          Text(
            context.reminderRepeatTitle,
            style: typography.body.copyWith(
              color: palette.colorText,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          ReminderWeekdayChips(
            selected: _weekdays,
            onChanged: (w) => setState(() => _weekdays = w),
          ),
          const SizedBox(height: 28),

          // Save / Send Proposal Button
          Container(
            height: 52,
            decoration: BoxDecoration(
              gradient: palette.gradientHot,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: palette.colorAccentPink.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: palette.colorBackground.withValues(alpha: 0),
                shadowColor: palette.colorBackground.withValues(alpha: 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              child: Text(
                isEditing
                    ? context.reminderSaveCta
                    : context.reminderSendProposalCta,
                style: typography.body.copyWith(
                  color: palette.colorText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),

          // Delete Button (if editing)
          if (isEditing && widget.onDelete != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onDelete?.call();
              },
              child: Text(
                context.reminderDeleteCta,
                style: typography.body.copyWith(
                  color: palette.colorRed,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
