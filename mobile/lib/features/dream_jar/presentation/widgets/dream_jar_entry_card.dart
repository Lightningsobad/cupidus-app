import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_l10n.dart';

/// STORY-014 P5 Home "Money" group entry card (`ux/uiux-spec.md` entry-point
/// paragraph before §1.1). The spec's `{{ jarPct }}% · {{ tripLabel }}`
/// subtitle assumes a jar is already loaded on Home; this phase's scope is
/// only the discoverable navigation edge (no Home-level jar fetch), so the
/// subtitle is static copy instead. Carries no encryption/lock/shield
/// affordance (ADR-014a).
class DreamJarEntryCard extends StatelessWidget {
  const DreamJarEntryCard({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      child: Material(
        color: colors.colorSurface,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
            child: Padding(
              padding: EdgeInsets.all(CupidSpacing.md),
              child: Row(
                children: [
                  CupidIcon(CupidIcons.savings, color: colors.colorAccentLilac),
                  SizedBox(width: CupidSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.dream_jar_entry_card_title,
                          style: type.cardTitle.copyWith(
                            color: colors.colorText,
                          ),
                        ),
                        SizedBox(height: CupidSpacing.xs),
                        Text(
                          l10n.dream_jar_entry_card_subtitle,
                          style: type.caption.copyWith(
                            color: colors.colorTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
