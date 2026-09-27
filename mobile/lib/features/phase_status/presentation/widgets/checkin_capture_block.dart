import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../context_notebook/context_notebook_entry_point.dart';

const Key eveningCheckInCaptureKey = Key('evening_check_in_capture');
const Key eveningCheckInCaptureFieldKey =
    Key('evening_check_in_capture_field');
const Key eveningCheckInCaptureHintKey = Key('evening_check_in_capture_hint');
const Key eveningCheckInCaptureErrorKey = Key('evening_check_in_capture_error');
const Key eveningCheckInCaptureRetryKey = Key('evening_check_in_capture_retry');

/// The optional second ask on the 23h check-in screen (`ux/uiux-spec.md`
/// Phần A): one short line about the other person, and the user's own choice of
/// which of the two notebook groups it belongs to.
///
/// A divider and nothing else separates it from the sentence block above: a card
/// of its own would read as a second primary step, and the block must never
/// outweigh the photo and sentence steps it follows (AC-1, AC-7).
///
/// Stateless on purpose. Every piece of its state lives in the check-in screen,
/// because the screen's own save button is what decides when the typed line is
/// written and whether the screen may close (KD-1) — state split across the two
/// would put that decision in two places.
class CheckinCaptureBlock extends StatelessWidget {
  const CheckinCaptureBlock({
    super.key,
    required this.copy,
    required this.controller,
    required this.selectedKind,
    required this.enabled,
    required this.kindMissing,
    required this.saveFailed,
    required this.onKindSelected,
    required this.onRetry,
  });

  /// Resolved copy for every line in the block. Wording never comes from
  /// `l10n` or a Dart constant here (AC-14, UX Phần D).
  final CheckinCaptureCopySet copy;

  final TextEditingController controller;

  /// `null` until the user picks one. Nothing is ever selected on the user's
  /// behalf, at any point, including after they finish typing (AC-3, BR-4).
  final NotebookKind? selectedKind;

  final bool enabled;

  /// Shown only from the moment the save button was tapped with a typed line and
  /// no group chosen, and cleared as soon as either is resolved (UX Phần A.4).
  final bool kindMissing;

  /// The notebook write failed on its own. The photo and sentence steps are
  /// unaffected, so the failure is reported inside this block only (AC-12,
  /// BR-10).
  final bool saveFailed;

  final void Function(NotebookKind kind) onKindSelected;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        const SizedBox(height: CupidSpacing.md),
        Divider(height: 1, thickness: 1, color: colors.colorLine),
        const SizedBox(height: CupidSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: <Widget>[
            Expanded(
              child: Text(
                copy.text(checkinCaptureQuestionId),
                style: type.body.copyWith(color: colors.colorText),
              ),
            ),
            const SizedBox(width: CupidSpacing.sm),
            Text(
              copy.text(checkinCaptureOptionalLabelId),
              style: type.caption.copyWith(color: colors.colorGhost),
            ),
          ],
        ),
        const SizedBox(height: CupidSpacing.sm),
        TextField(
          key: eveningCheckInCaptureFieldKey,
          controller: controller,
          enabled: enabled,
          // One line, not the several the sentence field offers: this asks for
          // one short thing, never a paragraph (AC-17).
          maxLines: 1,
          textInputAction: TextInputAction.done,
          style: type.body.copyWith(color: colors.colorText),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: colors.colorSurface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(platform.radiusSmall),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: CupidSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: ContextInlineSegmented(
            options: <ContextInlineAddOption>[
              ContextInlineAddOption(
                id: NotebookKind.interest.wireValue,
                label: copy.text(checkinCaptureInterestKindId),
              ),
              ContextInlineAddOption(
                id: NotebookKind.event.wireValue,
                label: copy.text(checkinCaptureEventKindId),
              ),
            ],
            selectedId: selectedKind?.wireValue,
            onChanged: (String id) {
              if (!enabled) {
                return;
              }
              onKindSelected(NotebookKind.fromWireValue(id));
            },
          ),
        ),
        if (kindMissing) ...<Widget>[
          const SizedBox(height: CupidSpacing.xs),
          Text(
            copy.text(checkinCaptureKindRequiredHintId),
            key: eveningCheckInCaptureHintKey,
            style: type.caption.copyWith(color: colors.colorRed),
          ),
        ],
        if (saveFailed) ...<Widget>[
          const SizedBox(height: CupidSpacing.xs),
          Text(
            copy.text(checkinCaptureSaveErrorId),
            key: eveningCheckInCaptureErrorKey,
            style: type.caption.copyWith(color: colors.colorRed),
          ),
          InkWell(
            key: eveningCheckInCaptureRetryKey,
            onTap: enabled ? onRetry : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: CupidSpacing.xs),
              child: Text(
                copy.text(checkinCaptureRetryId),
                style: type.caption.copyWith(
                  color: colors.colorAccentPink,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
