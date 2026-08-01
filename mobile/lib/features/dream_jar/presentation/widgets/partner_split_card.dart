import 'package:cupid_mobile/design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_l10n.dart';
import '../../data/dream_jar.dart';
import '../../data/dream_jar_amount_format.dart';

/// The current user's and the partner's cumulative contribution totals,
/// derived client-side from a [Contribution] list (`ux/uiux-spec.md` §1.1
/// "Who loves the jar more"). A couple has exactly two members, so every
/// contribution not made by [PartnerSplitTotals.of]'s `currentUserId` is
/// attributed to "the partner" — no partner-identity lookup is needed.
class PartnerSplitTotals {
  const PartnerSplitTotals({required this.selfTotal, required this.partnerTotal});

  final num selfTotal;
  final num partnerTotal;

  /// Sums [contributions] into [selfTotal] (matching [currentUserId]) and
  /// [partnerTotal] (everyone else). A `null` [currentUserId] (identity not
  /// yet resolved) attributes every contribution to the partner rather than
  /// guessing, so the card never mislabels a contribution as the user's own.
  factory PartnerSplitTotals.of(
    List<Contribution> contributions,
    String? currentUserId,
  ) {
    num selfTotal = 0;
    num partnerTotal = 0;
    for (final contribution in contributions) {
      if (currentUserId != null && contribution.userId == currentUserId) {
        selfTotal += contribution.amount;
      } else {
        partnerTotal += contribution.amount;
      }
    }
    return PartnerSplitTotals(selfTotal: selfTotal, partnerTotal: partnerTotal);
  }
}

/// STORY-014 P4 "who loves the jar more" comparison (`ux/uiux-spec.md` §1.1,
/// §3). Purely a read-only, cosmetic/social aggregate view — computed from
/// whatever page(s) of contributions the caller has already loaded (no new
/// backend per-partner aggregate endpoint, `coding-plan/master-plan.md` §6
/// deferred items), so totals reflect contributions loaded so far and become
/// complete once the caller has paginated through the full history.
class PartnerSplitCard extends StatelessWidget {
  const PartnerSplitCard({
    super.key,
    required this.contributions,
    required this.currentUserId,
  });

  final List<Contribution> contributions;

  /// The signed-in user's backend id (matches `Contribution.userId`), or
  /// `null` before it resolves.
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;
    final AppL10n l10n = AppL10n.of(context);

    final totals = PartnerSplitTotals.of(contributions, currentUserId);
    final num maxTotal = totals.selfTotal > totals.partnerTotal
        ? totals.selfTotal
        : totals.partnerTotal;
    final num delta = (totals.selfTotal - totals.partnerTotal).abs();

    final String deltaCopy = totals.selfTotal == totals.partnerTotal
        ? l10n.dream_jar_partner_split_even
        : totals.selfTotal > totals.partnerTotal
        ? l10n.dream_jar_partner_split_you_ahead(DreamJarAmountFormat.vnd(delta))
        : l10n.dream_jar_partner_split_partner_ahead(
            DreamJarAmountFormat.vnd(delta),
          );

    return Container(
      padding: EdgeInsets.all(CupidSpacing.md),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platformTokens.radiusCard),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.dream_jar_partner_split_title,
            style: type.cardTitle.copyWith(color: colors.colorText),
          ),
          SizedBox(height: CupidSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: _SplitColumn(
                  label: l10n.dream_jar_partner_split_you_label,
                  amount: totals.selfTotal,
                  maxAmount: maxTotal,
                  barColor: colors.colorAccentLilac,
                  semanticLabel: l10n.dream_jar_partner_split_you_semantic_label(
                    DreamJarAmountFormat.vnd(totals.selfTotal),
                  ),
                ),
              ),
              SizedBox(width: CupidSpacing.md),
              Expanded(
                child: _SplitColumn(
                  label: l10n.dream_jar_partner_split_partner_label,
                  amount: totals.partnerTotal,
                  maxAmount: maxTotal,
                  barColor: colors.colorMint,
                  semanticLabel:
                      l10n.dream_jar_partner_split_partner_semantic_label(
                        DreamJarAmountFormat.vnd(totals.partnerTotal),
                      ),
                ),
              ),
            ],
          ),
          SizedBox(height: CupidSpacing.sm),
          // The mandatory accessible equivalent of the bar-height comparison
          // (`ux/uiux-spec.md` §3): keep this text, never optional decoration.
          Text(
            deltaCopy,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
        ],
      ),
    );
  }
}

class _SplitColumn extends StatelessWidget {
  const _SplitColumn({
    required this.label,
    required this.amount,
    required this.maxAmount,
    required this.barColor,
    required this.semanticLabel,
  });

  final String label;
  final num amount;
  final num maxAmount;
  final Color barColor;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platformTokens = context.cupidPlatform;

    final double heightFactor = maxAmount <= 0
        ? 0
        : (amount / maxAmount).clamp(0, 1).toDouble();

    return Semantics(
      label: semanticLabel,
      container: true,
      child: Column(
        children: [
          Text(
            DreamJarAmountFormat.vnd(amount),
            style: type.labelMono.copyWith(color: colors.colorText),
          ),
          SizedBox(height: CupidSpacing.sm),
          // Decorative: the mono amount above and the delta line below
          // already carry the comparison as text (ux/uiux-spec.md §3).
          ExcludeSemantics(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(platformTokens.radiusSmall),
              child: SizedBox(
                height: 64,
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(color: colors.colorSurfaceAlt),
                    FractionallySizedBox(
                      heightFactor: heightFactor,
                      child: Container(color: barColor),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: CupidSpacing.sm),
          ExcludeSemantics(
            child: Text(
              label,
              style: type.caption.copyWith(color: colors.colorTextMuted),
            ),
          ),
        ],
      ),
    );
  }
}
