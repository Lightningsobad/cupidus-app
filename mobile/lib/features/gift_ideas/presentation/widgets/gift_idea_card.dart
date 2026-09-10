import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../domain/gift_content.dart';
import '../../domain/gift_selector.dart';

/// One suggestion, with exactly one primary action.
///
/// Deliberately absent, and asserted absent by the screen's test: a cost field,
/// a cost range, a cheap/expensive label, a shop name, a buy link, a discount
/// code (AC-16, AC-19, AC-23), and any second affordance such as "lưu để xem
/// sau", a favourite toggle or a share button — keeping an idea *is* adding it
/// to the shared hub (SC-1'/AC-22, `ux/uiux-spec.md` Phần D).
class GiftIdeaCard extends StatelessWidget {
  const GiftIdeaCard({
    super.key,
    required this.suggestion,
    required this.added,
    required this.onAddToHub,
  });

  final GiftSuggestion suggestion;

  /// Whether this idea has already been pushed to the hub in this screen
  /// session. Drives the in-place confirmation line only — the action stays
  /// live, because "đã thêm" is not a state this flow stores.
  final bool added;

  final VoidCallback onAddToHub;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final GiftIdea idea = suggestion.idea;
    final String? skillLabel = _skillLabel();

    return DecoratedBox(
      key: Key('gift_idea_card_${idea.id}'),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        border: Border.all(color: colors.colorLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _MetaRow(
              effortLabel: suggestion.effortTier?.label,
              branchLabel: suggestion.branch?.label,
            ),
            const SizedBox(height: CupidSpacing.sm),
            Text(
              idea.title,
              key: Key('gift_idea_title_${idea.id}'),
              style: type.cardTitle.copyWith(color: colors.colorText),
            ),
            const SizedBox(height: CupidSpacing.xs),
            Text(
              idea.description,
              style: type.body.copyWith(color: colors.colorTextMuted),
            ),
            // Only the handmade branch names where an idea came from: it is the
            // one branch whose ranking reads the skill profile, so naming the
            // skill there is an explanation, not a score (AC-20).
            if (idea.isHandmade && skillLabel != null) ...<Widget>[
              const SizedBox(height: CupidSpacing.xs),
              Text(
                l10n.gift_ideas_from_skill(skillLabel),
                key: Key('gift_idea_from_skill_${idea.id}'),
                style: type.caption.copyWith(color: colors.colorTextMuted),
              ),
            ],
            const SizedBox(height: CupidSpacing.md),
            CupidPrimaryButton(
              key: Key('gift_idea_add_${idea.id}'),
              label: l10n.gift_ideas_add_action,
              leadingIcon: CupidIcons.add,
              onPressed: onAddToHub,
            ),
            if (added) ...<Widget>[
              const SizedBox(height: CupidSpacing.sm),
              Text(
                l10n.gift_ideas_added_confirmation,
                key: Key('gift_idea_added_${idea.id}'),
                style: type.caption.copyWith(color: colors.colorMint),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String? _skillLabel() {
    for (final GiftContextMatch match in suggestion.matches) {
      if (match.context.kind == GiftContextKind.skill) {
        return match.context.label;
      }
    }
    return null;
  }
}

/// Effort estimate on the left, branch on the right. Both are pack labels read
/// off the taxonomy — never a Dart string and never a derived band, so a pack
/// that renames a tier renames it here too (R-15a).
class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.effortLabel, required this.branchLabel});

  final String? effortLabel;
  final String? branchLabel;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Row(
      children: <Widget>[
        if (effortLabel != null) ...<Widget>[
          CupidIcon(CupidIcons.timer, color: colors.colorAccentLilac),
          const SizedBox(width: CupidSpacing.xs),
          Flexible(
            child: Text(
              effortLabel!,
              style: type.caption.copyWith(color: colors.colorAccentLilac),
            ),
          ),
        ],
        const Spacer(),
        if (branchLabel != null)
          Text(
            branchLabel!,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
      ],
    );
  }
}
