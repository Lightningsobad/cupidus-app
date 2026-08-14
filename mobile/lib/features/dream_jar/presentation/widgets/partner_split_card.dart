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

/// STORY-027 "who loves the jar more" comparison, transcribed from the locked
/// design source's `jar` screen: a compact mono total, a rounded gradient
/// column, an overlapping initial avatar, and a name, per partner.
///
/// Purely a read-only, cosmetic/social aggregate view — computed from
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
      padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 18),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(context.cupidPlatform.radiusCard),
        boxShadow: context.cupidPlatform.elevationShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.dream_jar_partner_split_title,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: colors.colorText,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SplitColumn(
                label: l10n.dream_jar_partner_split_you_label,
                amount: totals.selfTotal,
                maxAmount: maxTotal,
                amountColor: colors.colorAccentPink,
                barGradient: DreamJarPalette.comparisonSelfBar,
                avatarGradient: CoupleAvatarGradients.self,
                semanticLabel: l10n.dream_jar_partner_split_you_semantic_label(
                  DreamJarAmountFormat.vnd(totals.selfTotal),
                ),
              ),
              const SizedBox(width: 26),
              _SplitColumn(
                label: l10n.dream_jar_partner_split_partner_label,
                amount: totals.partnerTotal,
                maxAmount: maxTotal,
                amountColor: colors.colorMint,
                barGradient: DreamJarPalette.comparisonPartnerBar,
                avatarGradient: CoupleAvatarGradients.partner,
                semanticLabel:
                    l10n.dream_jar_partner_split_partner_semantic_label(
                      DreamJarAmountFormat.vnd(totals.partnerTotal),
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // The mandatory accessible equivalent of the bar-height comparison
          // (`ux/uiux-spec.md` §3): keep this text, never optional decoration.
          Text(
            deltaCopy,
            textAlign: TextAlign.center,
            style: type.caption.copyWith(
              fontSize: 12,
              height: 1.5,
              color: colors.colorTextMuted,
            ),
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
    required this.amountColor,
    required this.barGradient,
    required this.avatarGradient,
    required this.semanticLabel,
  });

  final String label;
  final num amount;
  final num maxAmount;
  final Color amountColor;
  final LinearGradient barGradient;
  final LinearGradient avatarGradient;
  final String semanticLabel;

  static const double _barHeight = 88;
  static const double _avatarSize = 36;

  /// `gap:8px` between the bar and the avatar, then the avatar's
  /// `margin-top:-24px` pulls it back over the bar.
  static const double _avatarOverlap = 24;
  static const double _gap = 8;

  /// The design authors the two bars at `height:78%` and `height:62%` for
  /// 2,18tr vs 1,72tr — a 0.789 ratio, i.e. the trailing bar is scaled off the
  /// leading one, and the leading one stops short of the track so the track is
  /// always visible behind it.
  static const double _leadFillFraction = 0.78;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    final double heightFactor = maxAmount <= 0
        ? 0
        : (_leadFillFraction * amount / maxAmount).clamp(0, 1).toDouble();

    return Semantics(
      label: semanticLabel,
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Text(
              DreamJarAmountFormat.compact(amount),
              style: type.labelMono.copyWith(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: amountColor,
              ),
            ),
          ),
          const SizedBox(height: _gap),
          ExcludeSemantics(
            child: SizedBox(
              width: 48,
              height: _barHeight + _gap + _avatarSize - _avatarOverlap,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: _barHeight,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ColoredBox(
                        color: colors.colorSurfaceAlt,
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: FractionallySizedBox(
                            heightFactor: heightFactor,
                            widthFactor: 1,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: barGradient,
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: _barHeight + _gap - _avatarOverlap,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _InitialAvatar(
                        initial: _initialOf(label),
                        gradient: avatarGradient,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: _gap),
          ExcludeSemantics(
            child: Text(
              label,
              style: type.caption.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: colors.colorText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The design shows a per-partner initial. The app has no partner display
  /// name on this screen (`Contribution` carries only `userId`), so the
  /// localized role label supplies it.
  static String _initialOf(String label) =>
      label.isEmpty ? '' : label.characters.first.toUpperCase();
}

/// `36x36;border-radius:50%;border:2.5px solid var(--surf);font-size:13px;font-weight:800`
class _InitialAvatar extends StatelessWidget {
  const _InitialAvatar({required this.initial, required this.gradient});

  final String initial;
  final LinearGradient gradient;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Container(
      width: _SplitColumn._avatarSize,
      height: _SplitColumn._avatarSize,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: gradient,
        border: Border.all(color: colors.colorSurface, width: 2.5),
      ),
      child: Text(
        initial,
        style: type.caption.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: DreamJarPalette.onHeroText,
        ),
      ),
    );
  }
}
