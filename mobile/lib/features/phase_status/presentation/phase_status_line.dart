import 'package:flutter/material.dart';

import '../../../design_system/theme/cupid_theme_context.dart';
import '../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../design_system/tokens/cupid_spacing.dart';
import '../../../design_system/tokens/cupid_typography_tokens.dart';

const Key phaseStatusLineKey = Key('phase_status_line');
const Key phaseStatusLineSecondaryKey = Key('phase_status_line_secondary');

/// Whole civil days from [today] to [scheduledOnIso], negative when the date
/// has already passed and `null` when the string is not a civil date.
///
/// Both sides are normalised to UTC midnight before subtracting, so the answer
/// counts calendar days rather than elapsed time: a day that is 23 or 25 hours
/// long because of a DST shift still counts as one day, which is what a reader
/// of "còn 2 ngày" means by it. Nothing here produces hours, minutes or
/// seconds — the countdown is a day count by construction (AC-14).
int? civilDaysUntil({required String scheduledOnIso, required DateTime today}) {
  final DateTime? target = DateTime.tryParse('${scheduledOnIso}T00:00:00Z');
  if (target == null) {
    return null;
  }
  final DateTime start = DateTime.utc(today.year, today.month, today.day);
  return target.difference(start).inDays;
}

/// The phase status line on screen (1) (`ux/uiux-spec.md` §1).
///
/// Every readable string arrives through [primary]/[secondary], already
/// selected and already substituted by `PhaseStatusCubit` from the content
/// package (AC-37/BR-15). This file deliberately holds no display copy at all:
/// swapping the package changes what this widget says without a Dart edit.
///
/// Nothing to say renders as [SizedBox.shrink] rather than as an empty box,
/// blank row or placeholder — the quiet phase has no screen line of its own at
/// this point, and a gap where a sentence used to be still reads as a message.
class PhaseStatusLine extends StatelessWidget {
  const PhaseStatusLine({super.key, this.primary, this.secondary});

  final String? primary;
  final String? secondary;

  @override
  Widget build(BuildContext context) {
    final String? line = primary;
    if (line == null || line.isEmpty) {
      return const SizedBox.shrink();
    }
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final String? support = secondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: CupidSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            line,
            key: phaseStatusLineKey,
            style: type.body.copyWith(
              fontWeight: FontWeight.w600,
              color: colors.colorText,
            ),
          ),
          if (support != null && support.isNotEmpty) ...<Widget>[
            const SizedBox(height: CupidSpacing.xs),
            Text(
              support,
              key: phaseStatusLineSecondaryKey,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ],
        ],
      ),
    );
  }
}
