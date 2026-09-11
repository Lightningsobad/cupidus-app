import 'package:flutter/material.dart';

import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../domain/gift_content.dart';
import '../../domain/gift_selector.dart';

/// One suggestion, with exactly one primary action.
///
/// Two shapes, both drawn by the screen (5) design canvas: [compact] `false` is
/// the lead card (effort pill, branch, title, description, provenance, the
/// full-width pill and the dismiss `×`), [compact] `true` is the smaller row
/// beneath it (minutes badge, title, provenance, a circular add control). Which
/// shape a card gets is a presentation choice made by the screen; nothing here
/// assumes how many suggestions exist (R-15b).
///
/// Deliberately absent, and asserted absent by the screen's test: a cost field,
/// a cost range, a cheap/expensive label, a shop name, a buy link, a discount
/// code (AC-16, AC-19, AC-23), and any second *keeping* affordance such as "lưu
/// để xem sau", a favourite toggle or a share button — keeping an idea *is*
/// adding it to the shared hub (SC-1'/AC-22, `ux/uiux-spec.md` Phần D). The
/// dismiss `×` is not such an affordance: it stores nothing and removes the
/// card from view for this screen session only.
class GiftIdeaCard extends StatelessWidget {
  const GiftIdeaCard({
    super.key,
    required this.suggestion,
    required this.added,
    required this.onAddToHub,
    this.onDismiss,
    this.compact = false,
  });

  final GiftSuggestion suggestion;

  /// Whether this idea has already been pushed to the hub in this screen
  /// session. Drives the in-place confirmation line only — the action stays
  /// live, because "đã thêm" is not a state this flow stores.
  final bool added;

  final VoidCallback onAddToHub;

  /// The `×` the canvas draws beside the primary pill. Null on the compact
  /// shape, which the canvas gives no dismiss control.
  final VoidCallback? onDismiss;

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return DecoratedBox(
      key: Key('gift_idea_card_${suggestion.idea.id}'),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        border: Border.all(color: colors.colorLine),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? CupidSpacing.sm : CupidSpacing.md),
        child: compact ? _CompactBody(card: this) : _FullBody(card: this),
      ),
    );
  }
}

class _FullBody extends StatelessWidget {
  const _FullBody({required this.card});

  final GiftIdeaCard card;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final GiftSuggestion suggestion = card.suggestion;
    final GiftIdea idea = suggestion.idea;
    final VoidCallback? onDismiss = card.onDismiss;

    return Column(
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
        _ProvenanceLine(suggestion: suggestion),
        const SizedBox(height: CupidSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: CupidPrimaryButton(
                key: Key('gift_idea_add_${idea.id}'),
                label: l10n.gift_ideas_add_action,
                leadingIcon: CupidIcons.add,
                onPressed: card.onAddToHub,
              ),
            ),
            if (onDismiss != null) ...<Widget>[
              const SizedBox(width: CupidSpacing.sm),
              _CircleAction(
                key: Key('gift_idea_dismiss_${idea.id}'),
                semanticLabel: l10n.gift_ideas_dismiss_action,
                icon: CupidIcons.close,
                color: colors.colorTextMuted,
                onTap: onDismiss,
              ),
            ],
          ],
        ),
        if (card.added) ...<Widget>[
          const SizedBox(height: CupidSpacing.sm),
          Text(
            l10n.gift_ideas_added_confirmation,
            key: Key('gift_idea_added_${idea.id}'),
            style: type.caption.copyWith(color: colors.colorMint),
          ),
        ],
      ],
    );
  }
}

class _CompactBody extends StatelessWidget {
  const _CompactBody({required this.card});

  final GiftIdeaCard card;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final GiftSuggestion suggestion = card.suggestion;
    final GiftIdea idea = suggestion.idea;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        _EffortBadge(suggestion: suggestion),
        const SizedBox(width: CupidSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                idea.title,
                key: Key('gift_idea_title_${idea.id}'),
                style: type.cardTitle.copyWith(color: colors.colorText),
              ),
              _ProvenanceLine(suggestion: suggestion),
              if (card.added) ...<Widget>[
                const SizedBox(height: CupidSpacing.xs),
                Text(
                  l10n.gift_ideas_added_confirmation,
                  key: Key('gift_idea_added_${idea.id}'),
                  style: type.caption.copyWith(color: colors.colorMint),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: CupidSpacing.sm),
        _CircleAction(
          key: Key('gift_idea_add_${idea.id}'),
          semanticLabel: l10n.gift_ideas_add_action,
          icon: CupidIcons.add,
          color: colors.colorAccentPink,
          onTap: card.onAddToHub,
        ),
      ],
    );
  }
}

/// The recorded thing a suggestion rests on, whichever kind it is.
///
/// AC-14 asks every personalised suggestion to state the basis the *user
/// entered*, so all three ask targets are covered, not only the skill profile:
/// an idea lifted by a notebook interest or a recorded occasion says so in the
/// same place. Renders nothing when [GiftSuggestion.matches] is empty, which is
/// the ordinary general-suggestion case, not a degraded one (AC-15).
class _ProvenanceLine extends StatelessWidget {
  const _ProvenanceLine({required this.suggestion});

  final GiftSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final GiftContextValue? basis = _basis();
    if (basis == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: CupidSpacing.xs),
      child: Text(
        switch (basis.kind) {
          GiftContextKind.skill => l10n.gift_ideas_from_skill(basis.label),
          GiftContextKind.interest =>
            l10n.gift_ideas_from_interest(basis.label),
          GiftContextKind.event => l10n.gift_ideas_from_event(basis.label),
        },
        key: Key('gift_idea_from_context_${suggestion.idea.id}'),
        style: type.caption.copyWith(color: colors.colorTextMuted),
      ),
    );
  }

  /// One line, not a list: the first match in pack order. A handmade idea keeps
  /// naming its skill, because the skill match is the one the handmade branch
  /// ranks on and it sorts first among that idea's matches (AC-20).
  GiftContextValue? _basis() {
    for (final GiftContextMatch match in suggestion.matches) {
      if (suggestion.idea.isHandmade &&
          match.context.kind == GiftContextKind.skill) {
        return match.context;
      }
    }
    return suggestion.matches.isEmpty ? null : suggestion.matches.first.context;
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

/// The compact shape's `20'` badge.
///
/// Reads the tier's own `max_minutes` off the pack and renders it in minutes —
/// a unit render of pack data, not a Dart-side band: no per-tier factor, no
/// bucket boundary and no assumption about how many tiers exist (R-15a,
/// AC-34). Falls back to the pack's tier label when a pack ships a tier with no
/// ceiling, rather than inventing a number.
class _EffortBadge extends StatelessWidget {
  const _EffortBadge({required this.suggestion});

  final GiftSuggestion suggestion;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;
    final int? minutes = suggestion.effortMinutes;
    final String? label = minutes != null
        ? l10n.gift_ideas_effort_minutes(minutes)
        : suggestion.effortTier?.label;
    if (label == null) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      key: Key('gift_idea_effort_badge_${suggestion.idea.id}'),
      decoration: BoxDecoration(
        color: colors.colorSurfaceAlt,
        borderRadius: BorderRadius.circular(platform.radiusButton),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CupidSpacing.sm,
          vertical: CupidSpacing.xs,
        ),
        child: Text(
          label,
          style: type.caption.copyWith(color: colors.colorAccentLilac),
        ),
      ),
    );
  }
}

/// A circular icon control: the compact shape's add button and the lead card's
/// dismiss `×`.
///
/// A `GestureDetector` rather than a second `ElevatedButton`, so "one primary
/// button per card" stays literally true in the widget tree as well as in the
/// reading.
class _CircleAction extends StatelessWidget {
  const _CircleAction({
    super.key,
    required this.semanticLabel,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  /// Spacing tokens, not a pixel literal: the gift flow's content gate rejects
  /// every bare integer under `features/gift_ideas/` so no pack assumption can
  /// hide in one (AC-33/BR-17).
  static const double _diameter = CupidSpacing.xl;
  static const double _glyph = CupidSpacing.md;

  final String semanticLabel;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          width: _diameter,
          height: _diameter,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.colorSurfaceAlt,
            border: Border.all(color: colors.colorLine),
          ),
          child: Center(
            child: CupidIcon(icon, size: _glyph, color: color),
          ),
        ),
      ),
    );
  }
}
