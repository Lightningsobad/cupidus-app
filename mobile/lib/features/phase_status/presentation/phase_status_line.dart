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
          if (action != null && action.isNotEmpty) ...<Widget>[
            const SizedBox(height: CupidSpacing.sm),
            _PhaseStatusAction(label: action, onTap: onActionTap),
          ],
        ],
      ),
    );
  }
}

/// The secondary action of the waiting phase (AC-5/SB-83), a rounded pill inside
/// the preparation block rather than bare accent text (`ux/uiux-spec.md` §1,
/// 2026-09-26 patch B-1). Shape comes from the `cupid-ch-ng-1` canvas chip:
/// surface fill against the block's `colorSurfaceAlt`, hairline `colorLine`
/// border, fully rounded, `md`/`sm` padding, caption at bold weight. Text uses
/// `colorText` and not `colorAccentPink` because pink fails AA at caption size
/// in the light theme (ADR-004b).
///
/// It sits flush with the block's left edge and hugs its label — the earlier
/// `md` indent belonged to the text-button reading that patch B-1 replaced. It
/// is still deliberately not the card's own CTA pill: the card action keeps one
/// visual tier above anything nested inside this block (D-2).
class _PhaseStatusAction extends StatelessWidget {
  const _PhaseStatusAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Semantics(
      button: true,
      child: GestureDetector(
        key: phaseStatusLineActionKey,
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: platform.tapTarget),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: colors.colorSurface,
              borderRadius: BorderRadius.circular(platform.radiusButton),
              border: Border.all(color: colors.colorLine),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CupidSpacing.md,
                vertical: CupidSpacing.sm,
              ),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: type.caption.copyWith(
                    color: colors.colorText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
