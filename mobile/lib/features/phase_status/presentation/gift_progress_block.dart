import 'package:flutter/material.dart';

import '../../../design_system/icons/cupid_icon.dart';
import '../../../design_system/icons/cupid_icons.dart';
import '../../../design_system/theme/cupid_theme_context.dart';
import '../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../design_system/tokens/cupid_spacing.dart';
import '../../../design_system/tokens/cupid_typography_tokens.dart';

const Key giftProgressBlockKey = Key('gift_progress_block');
const Key dripCaptionLineKey = Key('drip_caption_line');

/// The "món quà đang lớn" block on screen (1) during the quiet phase
/// (`ux/uiux-spec.md` §5).
///
/// [line] says what the *user* is doing, never what the other person will
/// think of it (AC-20). It is one authored sentence from `nudges.v1.json`, so
/// there is no percentage, no continuous bar, and no ratio this file could
/// invent: the card contract is read-only and holds no step field to count
/// (BR-12).
///
/// A null [line] renders as [SizedBox.shrink]. No gift idea running is the
/// correct state, not an empty slot to fill, so there is deliberately no
/// placeholder box and no "thêm ý tưởng quà" call to action (AC-21/BR-2).
class GiftProgressBlock extends StatelessWidget {
  const GiftProgressBlock({super.key, this.line});

  final String? line;

  @override
  Widget build(BuildContext context) {
    final String? body = line;
    if (body == null || body.isEmpty) {
      return const SizedBox.shrink();
    }
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CupidSpacing.md,
        CupidSpacing.md,
        CupidSpacing.md,
        0,
      ),
      child: Container(
        padding: const EdgeInsets.all(CupidSpacing.md),
        decoration: BoxDecoration(
          color: colors.colorSurface,
          borderRadius: BorderRadius.circular(CupidSpacing.md),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            CupidIcon(
              CupidIcons.redeem,
              size: 18,
              color: colors.colorTextMuted,
            ),
            const SizedBox(width: CupidSpacing.sm),
            Expanded(
              child: Text(
                body,
                key: giftProgressBlockKey,
                style: type.body.copyWith(color: colors.colorText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The quiet-phase drip caption (`ux/uiux-spec.md` §5, AC-22/BR-9).
///
/// It lives beside [GiftProgressBlock] because both are the same surface: the
/// two things screen (1) may quietly say while nothing is scheduled. One
/// neutral caption line, never a banner, never a badge, never a red dot.
///
/// A null [line] renders nothing at all. An exhausted drip store looks exactly
/// like a store that is merely between weeks: no "đã hết" message, no count of
/// what is left, no promise of a next time (AC-38).
class DripCaptionLine extends StatelessWidget {
  const DripCaptionLine({super.key, this.line});

  final String? line;

  @override
  Widget build(BuildContext context) {
    final String? body = line;
    if (body == null || body.isEmpty) {
      return const SizedBox.shrink();
    }
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CupidSpacing.md,
        CupidSpacing.sm,
        CupidSpacing.md,
        0,
      ),
      child: Text(
        body,
        key: dripCaptionLineKey,
        style: type.caption.copyWith(color: colors.colorTextMuted),
      ),
    );
  }
}
