import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar.dart';
import '../../data/dream_jar_amount_format.dart';

/// The 3 fixed VND presets confirmed for v1 (`ux/uiux-spec.md` §1.1; the 4th
/// "custom amount" tile is an unresolved Product Owner flag, not in this
/// phase's scope).
const List<num> _presetAmounts = <num>[100000, 200000, 500000];

/// STORY-014 P2 jar detail hero card (`ux/uiux-spec.md` §1.1). Renders the
/// jar name, a proportional progress fill, the amount/percent line, an
/// encouragement line, and the 3 quick-add preset tiles.
///
/// The literal mockup's animated SVG jar illustration is not reproduced here:
/// no SVG asset ships with this phase and ADR-014a forbids adding a new
/// `pubspec.yaml` dependency, so progress is rendered as a token-driven
/// proportional fill bar instead, which carries the same information.
class DreamJarHeroCard extends StatelessWidget {
  const DreamJarHeroCard({
    super.key,
    required this.jar,
    required this.isAddingContribution,
    required this.contributionFailure,
    required this.onQuickAdd,
  });

  final DreamJar jar;
  final bool isAddingContribution;
  final Object? contributionFailure;
  final ValueChanged<num> onQuickAdd;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    final bool isCompleted =
        jar.status == DreamJarStatus.completed || jar.progressPercent >= 100;
    final num remaining = (jar.targetAmount - jar.currentAmount).clamp(
      0,
      jar.targetAmount <= 0 ? 0 : jar.targetAmount,
    );

    return Container(
      padding: EdgeInsets.all(CupidSpacing.lg),
      decoration: BoxDecoration(
        gradient: colors.gradientDream,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
        boxShadow: colors.glowShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            jar.name,
            style: type.cardTitle.copyWith(color: colors.colorText),
          ),
          SizedBox(height: CupidSpacing.md),
          // Decorative fill: the amount/percent text below already conveys
          // progress, so this bar is excluded from the accessibility tree
          // (ux/uiux-spec.md §3).
          ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
              child: SizedBox(
                height: 96,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(color: colors.colorSurfaceAlt),
                    FractionallySizedBox(
                      heightFactor: (jar.progressPercent / 100).clamp(0, 1),
                      child: Container(color: colors.colorAccentLilac),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: CupidSpacing.md),
          Text(
            '${DreamJarAmountFormat.vnd(jar.currentAmount)} '
            '${l10n.dream_jar_of} '
            '${DreamJarAmountFormat.vnd(jar.targetAmount)} · '
            '${jar.progressPercent}%',
            style: type.body.copyWith(color: colors.colorText),
          ),
          SizedBox(height: CupidSpacing.sm),
          Text(
            isCompleted
                ? l10n.dream_jar_completed
                : l10n.dream_jar_remaining(DreamJarAmountFormat.vnd(remaining)),
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
          if (contributionFailure != null) ...[
            SizedBox(height: CupidSpacing.sm),
            Text(
              l10n.dream_jar_contribution_error,
              style: type.caption.copyWith(color: colors.colorRed),
            ),
          ],
          SizedBox(height: CupidSpacing.lg),
          Row(
            children: [
              for (int i = 0; i < _presetAmounts.length; i++) ...[
                if (i > 0) SizedBox(width: CupidSpacing.sm),
                Expanded(
                  child: _QuickAddTile(
                    amount: _presetAmounts[i],
                    isEmphasized: i == _presetAmounts.length - 1,
                    enabled: !isAddingContribution,
                    onTap: () => onQuickAdd(_presetAmounts[i]),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAddTile extends StatelessWidget {
  const _QuickAddTile({
    required this.amount,
    required this.isEmphasized,
    required this.enabled,
    required this.onTap,
  });

  final num amount;
  final bool isEmphasized;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final CupidTypographyTokens type = context.cupidType;
    final AppL10n l10n = AppL10n.of(context);

    return Semantics(
      button: true,
      enabled: enabled,
      label: l10n.dream_jar_quick_add_semantic_label(
        DreamJarAmountFormat.vnd(amount),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
        child: Container(
          constraints: BoxConstraints(minHeight: platformTokens.tapTarget),
          decoration: BoxDecoration(
            color: isEmphasized ? null : colors.colorSurface,
            gradient: isEmphasized ? colors.gradientHot : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: enabled ? onTap : null,
              child: Center(
                child: ExcludeSemantics(
                  child: Text(
                    '+${_shortLabel(amount)}',
                    style: type.body.copyWith(color: colors.colorText),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static String _shortLabel(num amount) => '${(amount / 1000).round()}k';
}
