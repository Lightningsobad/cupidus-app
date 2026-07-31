import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_l10n.dart';

/// `privacy` screen (`coding-plan/master-plan.md` §6.2 P4, `ux/uiux-spec.md`
/// §4, DEC-3). AC2 view-only: the three tier cards are static informational
/// content. No "Controls" card, no toggle, no PATCH, no
/// `isGhostModeEnabled` reference, and no "Export all my data" button
/// (DEC-5) — none of those may be added here without a new decision.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    return Scaffold(
      backgroundColor: colors.colorBackground,
      appBar: CupidHeader(
        title: l10n.privacy_title,
        onBack: () => Navigator.of(context).maybePop(),
        backLabel: l10n.me_hub_title,
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(CupidSpacing.lg),
          children: <Widget>[
            Text(
              l10n.privacy_intro,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
            SizedBox(height: CupidSpacing.lg),
            _TierCard(
              icon: Icons.smartphone,
              levelLabel: l10n.privacy_tier1_label,
              levelColor: colors.colorAccentPink,
              iconBackground: colors.colorAccentPink.withValues(alpha: 0.28),
              title: l10n.privacy_tier1_title,
              description: l10n.privacy_tier1_description,
              tags: <String>[
                l10n.privacy_tier1_tag_typing_ghost,
                l10n.privacy_tier1_tag_private_gallery,
                l10n.privacy_tier1_tag_messages,
              ],
              highlighted: true,
              colors: colors,
              type: type,
              platformTokens: platformTokens,
            ),
            SizedBox(height: CupidSpacing.md),
            _TierCard(
              icon: Icons.enhanced_encryption,
              levelLabel: l10n.privacy_tier2_label,
              levelColor: colors.colorAccentPurple,
              iconBackground: colors.colorAccentPurple.withValues(alpha: 0.2),
              title: l10n.privacy_tier2_title,
              description: l10n.privacy_tier2_description,
              tags: <String>[
                l10n.privacy_tier2_tag_dream_jar,
                l10n.privacy_tier2_tag_love_timeline,
                l10n.privacy_tier2_tag_vibe_check,
              ],
              highlighted: false,
              colors: colors,
              type: type,
              platformTokens: platformTokens,
            ),
            SizedBox(height: CupidSpacing.md),
            _TierCard(
              icon: Icons.cloud,
              levelLabel: l10n.privacy_tier3_label,
              levelColor: colors.colorTextMuted,
              iconBackground: colors.colorSurfaceAlt,
              title: l10n.privacy_tier3_title,
              description: l10n.privacy_tier3_description,
              tags: <String>[
                l10n.privacy_tier3_tag_profile,
                l10n.privacy_tier3_tag_love_pet_stats,
                l10n.privacy_tier3_tag_alarm_settings,
              ],
              highlighted: false,
              colors: colors,
              type: type,
              platformTokens: platformTokens,
            ),
          ],
        ),
      ),
    );
  }
}

/// One of the three privacy-tier informational cards
/// (`ux/uiux-spec.md` §4, design source lines 893-921). Purely presentational
/// — no `onTap`, no trailing control of any kind.
class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.icon,
    required this.levelLabel,
    required this.levelColor,
    required this.iconBackground,
    required this.title,
    required this.description,
    required this.tags,
    required this.highlighted,
    required this.colors,
    required this.type,
    required this.platformTokens,
  });

  final IconData icon;
  final String levelLabel;
  final Color levelColor;
  final Color iconBackground;
  final String title;
  final String description;
  final List<String> tags;

  /// Level 1 renders as a tinted gradient card with a border (design source
  /// line 893); levels 2/3 render as plain surface cards with elevation
  /// (lines 903, 913).
  final bool highlighted;

  final CupidColorTokens colors;
  final CupidTypographyTokens type;
  final CupidPlatformTokens platformTokens;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(
      platformTokens.radiusCard,
    );

    return Container(
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: highlighted
          ? BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  colors.colorAccentPink.withValues(alpha: 0.22),
                  colors.colorAccentPurple.withValues(alpha: 0.14),
                ],
              ),
              borderRadius: radius,
              border: Border.all(
                color: colors.colorAccentPink.withValues(alpha: 0.4),
              ),
            )
          : BoxDecoration(
              color: colors.colorSurface,
              borderRadius: radius,
              boxShadow: platformTokens.elevationShadow,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(
                    platformTokens.radiusSmall,
                  ),
                ),
                child: Icon(icon, size: 21, color: levelColor),
              ),
              SizedBox(width: CupidSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      levelLabel,
                      style: type.labelMono.copyWith(
                        color: levelColor,
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      title,
                      style: type.body.copyWith(
                        color: colors.colorText,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: CupidSpacing.sm),
          Text(
            description,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
          SizedBox(height: CupidSpacing.sm),
          Wrap(
            spacing: CupidSpacing.xs,
            runSpacing: CupidSpacing.xs,
            children: <Widget>[
              for (final String tag in tags)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: CupidSpacing.sm,
                    vertical: CupidSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.colorSurfaceAlt,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tag,
                    style: type.caption.copyWith(
                      color: colors.colorText,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
