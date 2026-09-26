import 'package:flutter/material.dart';

import '../../../design_system/icons/cupid_icon.dart';
import '../../../design_system/icons/cupid_icons.dart';
import '../../../design_system/theme/cupid_theme_context.dart';
import '../../../design_system/tokens/cupid_color_tokens.dart';
import '../../../design_system/tokens/cupid_spacing.dart';
import '../../../design_system/tokens/cupid_typography_tokens.dart';

const Key wealthCounterLineKey = Key('wealth_counter_line');
const Key wealthCounterMilestoneKey = Key('wealth_counter_milestone');

/// The "của cải đang lớn" counter line on screen (1) (`ux/uiux-spec.md` §6).
///
/// One static number and nothing beside it: no target, no progress bar, no
/// ring, no comparison with another period (AC-27/BR-7). The icon is the
/// neutral `auto_awesome` mark rather than a trophy or badge, because a badge
/// turns a description into a reward (BR-7).
///
/// [label] and [milestone] arrive already selected and already substituted by
/// `PhaseStatusCubit` from `nudges.v1.json`, so this file holds no display copy
/// at all (AC-37/BR-15).
///
/// [milestone] is a recognition sentence and carries no action: no button, no
/// share, no dialog, no confetti — J12 stops at recognising (AC-28/BR-8).
class WealthCounterLine extends StatelessWidget {
  const WealthCounterLine({super.key, this.label, this.milestone});

  final String? label;
  final String? milestone;

  @override
  Widget build(BuildContext context) {
    final String? line = label;
    if (line == null || line.isEmpty) {
      return const SizedBox.shrink();
    }
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final String? recognition = milestone;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CupidSpacing.md,
        CupidSpacing.md,
        CupidSpacing.md,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CupidIcon(
                CupidIcons.autoAwesome,
                size: 18,
                color: colors.colorTextMuted,
              ),
              const SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: Text(
                  line,
                  key: wealthCounterLineKey,
                  style: type.body.copyWith(color: colors.colorText),
                ),
              ),
            ],
          ),
          if (recognition != null && recognition.isNotEmpty) ...<Widget>[
            const SizedBox(height: CupidSpacing.xs),
            Text(
              recognition,
              key: wealthCounterMilestoneKey,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ],
        ],
      ),
    );
  }
}
