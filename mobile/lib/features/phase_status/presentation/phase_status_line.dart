import 'package:flutter/material.dart';

import '../../../design_system/theme/cupid_theme_context.dart';
import '../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../design_system/tokens/cupid_platform_tokens.dart';
import '../../../design_system/tokens/cupid_spacing.dart';
import '../../../design_system/tokens/cupid_typography_tokens.dart';

const Key phaseStatusLineKey = Key('phase_status_line');
const Key phaseStatusLineSecondaryKey = Key('phase_status_line_secondary');
const Key phaseStatusLineActionKey = Key('phase_status_line_action');

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
/// Every readable string arrives through [primary]/[secondary]/[actionLabel],
/// already selected and already substituted by `PhaseStatusCubit` from the
/// content package (AC-37/BR-15). This file deliberately holds no display copy
/// at all: swapping the package changes what this widget says without a Dart
/// edit, and a phase with no [actionLabel] draws no action rather than a
/// default one.
///
/// Nothing to say renders as [SizedBox.shrink] rather than as an empty box,
/// blank row or placeholder — the quiet phase has no screen line of its own at
/// this point, and a gap where a sentence used to be still reads as a message.
///
/// It draws its own rounded surface (D-1) and the hub mounts it inside the card
/// it is about, rather than as bare text heading the whole list: the block
/// explains one card, so it is bounded like one.
class PhaseStatusLine extends StatelessWidget {
  const PhaseStatusLine({
    super.key,
    this.primary,
    this.secondary,
    this.actionLabel,
    this.onActionTap,
  });

  final String? primary;
  final String? secondary;

  /// The secondary action's words, or `null` for a phase that offers none.
  final String? actionLabel;

  final VoidCallback? onActionTap;

  @override
  Widget build(BuildContext context) {
    final String? line = primary;
    if (line == null || line.isEmpty) {
      return const SizedBox.shrink();
    }
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final String? support = secondary;
    final String? action = actionLabel;

    return Container(
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        border: Border.all(color: colors.colorLine),
      ),
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
          if (action != null && action.isNotEmpty)
            _PhaseStatusAction(label: action, onTap: onActionTap),
        ],
      ),
    );
  }
}

/// The secondary action of the waiting phase (AC-5/SB-83), drawn from the
/// `hành động phụ` column of the action-tier table
/// (`ux/requirement-ux-survey.md` §4): a text button, no solid fill, caption at
/// regular weight, indented `md` from the block edge, and still a full tap
/// target. It is deliberately not the card's own pill — the card action stays
/// one visual tier above anything nested inside this block.
class _PhaseStatusAction extends StatelessWidget {
  const _PhaseStatusAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Padding(
      padding: const EdgeInsets.only(left: CupidSpacing.md),
      child: Semantics(
        button: true,
        child: GestureDetector(
          key: phaseStatusLineActionKey,
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: platform.tapTarget),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                label,
                style: type.caption.copyWith(
                  color: colors.colorAccentPink,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
