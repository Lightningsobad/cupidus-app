import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../domain/compat_content.dart';

/// "1 câu để hỏi" — always the last block of a result (AC-19).
///
/// The question is rendered as text. It is not a `TextField`, not a form and
/// not a prompt with a submit button: this story never collects an answer
/// (AC-31), and an input box would turn a conversation opener into a stored
/// claim about the other person.
///
/// Per `STORY-009/ux/uiux-spec.md` section 3.4 this block is layered on a
/// different tone from the three blocks above it, carries the `help_outline`
/// glyph, and sets its text at `500` weight so the reader sees an action point
/// rather than a conclusion (AC-16).
class CompatQuestionBlock extends StatelessWidget {
  const CompatQuestionBlock({super.key, required this.cell});

  final CompatCell cell;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);

    return DecoratedBox(
      key: const Key('compat_question_block'),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platform.radiusSmall),
        border: Border.all(color: colors.colorLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                CupidIcon(
                  CupidIcons.help,
                  variant: CupidIconVariant.line,
                  size: 20,
                  color: colors.colorTextMuted,
                ),
                const SizedBox(width: CupidSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.compat_block_question_title,
                    style: type.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.colorTextMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: CupidSpacing.sm),
            Text(
              cell.question,
              style: type.body.copyWith(
                fontWeight: FontWeight.w500,
                color: colors.colorText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
