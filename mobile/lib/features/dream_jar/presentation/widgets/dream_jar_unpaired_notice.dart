import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_l10n.dart';

/// AC3: shown in place of the jar hero when [DreamJarUnpairedFailure] is
/// resolved, instead of a per-feature "are you paired?" check
/// (`ux/uiux-spec.md` §1.8).
class DreamJarUnpairedNotice extends StatelessWidget {
  const DreamJarUnpairedNotice({super.key});

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(CupidSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.dream_jar_unpaired_title,
              textAlign: TextAlign.center,
              style: type.cardTitle.copyWith(color: colors.colorText),
            ),
            SizedBox(height: CupidSpacing.sm),
            Text(
              l10n.dream_jar_unpaired_body,
              textAlign: TextAlign.center,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
          ],
        ),
      ),
    );
  }
}
