import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../reminder_strings.dart';

/// Hero-card time display with +/- steppers (`ux/uiux-spec.md` §2: "Large
/// time display ..., Nunito 900 56px, gradient text fill ... with +/-
/// steppers either side"). [time] is a plain hour/minute pair -- this widget
/// owns no timezone or absolute-date logic, that is
/// `ReminderScheduleScreen`'s concern (the next-occurrence computation over
/// [time] plus the weekday selection).
///
/// Each tap steps by [stepMinutes] (5 minutes: fine enough to dial in a wake
/// time without excessive taps, coarse enough to reach any time in a few
/// presses -- no step size is specified in the design source).
class ReminderTimeStepper extends StatelessWidget {
  const ReminderTimeStepper({
    super.key,
    required this.time,
    required this.onChanged,
    this.stepMinutes = 5,
  });

  final TimeOfDay time;
  final ValueChanged<TimeOfDay> onChanged;
  final int stepMinutes;

  TimeOfDay _shift(int minutesDelta) {
    final int totalMinutes =
        (time.hour * 60 + time.minute + minutesDelta) % (24 * 60);
    final int normalized = totalMinutes < 0 ? totalMinutes + 24 * 60 : totalMinutes;
    return TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60);
  }

  String _formatted() {
    final String hh = time.hour.toString().padLeft(2, '0');
    final String mm = time.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        _StepperButton(
          icon: CupidIcons.remove,
          semanticLabel: context.reminderDecreaseTimeLabel,
          onPressed: () => onChanged(_shift(-stepMinutes)),
        ),
        Flexible(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: CupidSpacing.md),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: ShaderMask(
                shaderCallback: (bounds) => colors.gradientDream.createShader(bounds),
                child: Text(
                  _formatted(),
                  style: type.display.copyWith(
                    fontSize: 56,
                    color: colors.colorText,
                  ),
                ),
              ),
            ),
          ),
        ),
        _StepperButton(
          icon: CupidIcons.add,
          semanticLabel: context.reminderIncreaseTimeLabel,
          onPressed: () => onChanged(_shift(stepMinutes)),
        ),
      ],
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.semanticLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String semanticLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidColorTokens colors = context.cupidColors;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: platformTokens.tapTarget,
        minHeight: platformTokens.tapTarget,
      ),
      child: IconButton(
        onPressed: onPressed,
        tooltip: semanticLabel,
        icon: CupidIcon(icon, color: colors.colorAccentPink),
      ),
    );
  }
}
