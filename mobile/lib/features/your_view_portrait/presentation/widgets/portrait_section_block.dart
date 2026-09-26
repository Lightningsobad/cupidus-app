import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../domain/portrait_composer.dart';

/// One result section: what the user's own answers add up to, closed by a line
/// they could actually ask.
///
/// A section whose clauses all dropped out still renders, reduced to the ask
/// line alone — a thin portrait is a valid portrait, not an error state and not
/// something to apologise for (AC-19).
class PortraitSectionBlock extends StatelessWidget {
  const PortraitSectionBlock({super.key, required this.section});

  final ComposedSection section;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final bool hasBody = section.clauses.isNotEmpty;

    return Container(
      key: Key('portrait-section-${section.sectionId}'),
      margin: const EdgeInsets.only(bottom: CupidSpacing.md),
      padding: const EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusSmall),
        border: Border.all(color: colors.colorLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (hasBody) ...<Widget>[
            Text(
              section.heading,
              style: type.cardTitle.copyWith(color: colors.colorText),
            ),
            const SizedBox(height: CupidSpacing.sm),
            Text(
              section.paragraph,
              style: type.body.copyWith(color: colors.colorText),
            ),
            const SizedBox(height: CupidSpacing.md),
          ],
          Container(
            key: Key('portrait-ask-${section.sectionId}'),
            width: double.infinity,
            padding: const EdgeInsets.all(CupidSpacing.sm),
            decoration: BoxDecoration(
              color: colors.colorSurfaceAlt,
              borderRadius: BorderRadius.circular(platform.radiusSmall),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.help_outline,
                  size: 20,
                  color: colors.colorAccentPurple,
                ),
                const SizedBox(width: CupidSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        l10n.portrait_ask_row_label,
                        style: type.caption.copyWith(
                          color: colors.colorTextMuted,
                        ),
                      ),
                      const SizedBox(height: CupidSpacing.xs),
                      Text(
                        section.askText,
                        style: type.body.copyWith(
                          color: colors.colorText,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
