import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../design_system/design_system.dart';
import '../../../../l10n/generated/app_l10n.dart';
import '../../../activity_cards/domain/activity_card_repository.dart';
import '../../../context_notebook/context_notebook_entry_point.dart';
import '../../data/gift_repository.dart';
import '../../domain/gift_content.dart';
import '../../domain/gift_selector.dart';
import '../cubit/gift_ideas_cubit.dart';
import '../widgets/gift_idea_card.dart';

/// This screen's entry point id for the inline ask mechanism
/// (`architecture/contract-summary.md` §2).
const String giftIdeasEntryPointId = 'gift_ideas';

/// The ask targets screen (5) personalises from, most wanted first
/// (`architecture/contract-summary.md` §2).
final List<String> giftIdeasNeededFieldIds = List<String>.unmodifiable(
  <String>[
    AskTarget.notebookInterest.wireValue,
    AskTarget.notebookEvent.wireValue,
    AskTarget.skill.wireValue,
  ],
);

/// Builds the one inline ask card for screen (5).
///
/// The screen owns the ask's identity and passes it in; a test or preview
/// substitutes the surface without this screen naming a context notebook
/// internal, which the feature's own import boundary forbids.
typedef GiftIdeasAskSlotBuilder = Widget Function({
  required String entryPointId,
  required List<String> neededFieldIds,
  required VoidCallback onContextChanged,
});

/// "Gợi ý quà", screen (5) of `ux/uiux-spec.md` Phần D.
///
/// Layout, top to bottom: the branch chips, the effort chips, exactly one
/// inline ask card, the suggestion list, and a small text line pointing at the
/// two surfaces STORY-009/010 will own. Every chip in both rows comes from
/// `gift_taxonomy`, so both rows are exactly as long as the pack and a fourth
/// branch appears without a Dart edit (AC-32/AC-34, R-15a/R-15b).
class GiftIdeasScreen extends StatelessWidget {
  const GiftIdeasScreen({
    super.key,
    this.giftRepository,
    this.cardRepository,
    this.askSlotBuilder,
  });

  /// Test/preview seams. Left null in production so the screen resolves the
  /// same composition-root registrations every other consumer uses.
  final GiftRepository? giftRepository;
  final ActivityCardRepository? cardRepository;

  @visibleForTesting
  final GiftIdeasAskSlotBuilder? askSlotBuilder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GiftIdeasCubit>(
      create: (_) => GiftIdeasCubit(
        gifts: giftRepository ?? getIt<GiftRepository>(),
        cards: cardRepository ?? getIt<ActivityCardRepository>(),
      )..load(),
      child: _GiftIdeasBody(askSlotBuilder: askSlotBuilder),
    );
  }
}

Widget _defaultAskSlot({
  required String entryPointId,
  required List<String> neededFieldIds,
  required VoidCallback onContextChanged,
}) {
  return AskOnTheSpotSlot(
    entryPointId: entryPointId,
    neededFieldIds: neededFieldIds,
    onContextChanged: onContextChanged,
  );
}

class _GiftIdeasBody extends StatelessWidget {
  const _GiftIdeasBody({required this.askSlotBuilder});

  final GiftIdeasAskSlotBuilder? askSlotBuilder;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final GiftIdeasCubit cubit = context.read<GiftIdeasCubit>();

    return Scaffold(
      appBar: CupidHeader(
        title: l10n.gift_ideas_screen_title,
        onBack: Navigator.of(context).canPop()
            ? () => Navigator.of(context).maybePop()
            : null,
      ),
      body: SafeArea(
        top: false,
        child: BlocBuilder<GiftIdeasCubit, GiftIdeasState>(
          builder: (BuildContext context, GiftIdeasState state) {
            if (state.loading) {
              return const SizedBox(key: Key('gift-ideas-loading'));
            }

            final List<GiftSuggestion> visible = state.visibleSuggestions;

            return ListView(
              key: const Key('gift-ideas-list'),
              padding: const EdgeInsets.all(CupidSpacing.md),
              children: <Widget>[
                _FilterChipRow(
                  key: const Key('gift-ideas-branch-filter'),
                  keyPrefix: 'gift_branch_chip',
                  items: state.branches,
                  selectedId: state.filter.branchId,
                  onSelected: cubit.selectBranch,
                ),
                const SizedBox(height: CupidSpacing.sm),
                _FilterChipRow(
                  key: const Key('gift-ideas-effort-filter'),
                  keyPrefix: 'gift_effort_chip',
                  items: state.effortTiers,
                  selectedId: state.filter.effortTierId,
                  onSelected: cubit.selectEffortTier,
                ),
                const SizedBox(height: CupidSpacing.sm),
                _BasisBand(
                  skillLabels: state.skillLabels,
                  notebookRowLabels: state.notebookRowLabels,
                ),
                const SizedBox(height: CupidSpacing.md),
                // Exactly one ask card on this route, above the list and below
                // the filters. Answering it re-ranks in place; the slot renders
                // nothing at all once the cadence policy is satisfied, which is
                // a normal state, not an empty one (AC-2).
                (askSlotBuilder ?? _defaultAskSlot)(
                  entryPointId: giftIdeasEntryPointId,
                  neededFieldIds: giftIdeasNeededFieldIds,
                  onContextChanged: cubit.refreshContext,
                ),
                const SizedBox(height: CupidSpacing.md),
                // Read off the ranked list, not off `visible`: this line is
                // the AC-34 defined-empty branch, and saying it because the
                // reader waved everything away would be false (AC-33).
                if (state.suggestions.isEmpty)
                  Text(
                    l10n.gift_ideas_no_match,
                    key: const Key('gift-ideas-no-match'),
                    style: context.cupidType.body
                        .copyWith(color: context.cupidColors.colorTextMuted),
                  ),
                for (final GiftSuggestion suggestion in visible)
                  Padding(
                    padding: const EdgeInsets.only(bottom: CupidSpacing.md),
                    child: GiftIdeaCard(
                      suggestion: suggestion,
                      added: state.addedGiftIds.contains(suggestion.idea.id),
                      onAddToHub: () => cubit.addToHub(suggestion),
                      // The canvas gives the dismiss `×` to the card that has
                      // the primary pill. Dismissing the lead promotes the next
                      // idea into that shape, so every suggestion is reachable
                      // in both roles without a second control on the compact
                      // row the canvas draws bare.
                      //
                      // `identical` against the head rather than an index
                      // compare: the gift flow's content gate rejects every
                      // bare integer in this tree, index or not.
                      onDismiss: identical(suggestion, visible.first)
                          ? () => cubit.dismiss(suggestion)
                          : null,
                      compact: !identical(suggestion, visible.first),
                    ),
                  ),
                const _GuessRow(),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// One chip per taxonomy item of a kind, and nothing else in the row.
///
/// No leading "tất cả" cell: tapping the chip that is already on clears the
/// filter, so the row can stay exactly as long as the pack (AC-34, R-15b).
class _FilterChipRow extends StatelessWidget {
  const _FilterChipRow({
    super.key,
    required this.keyPrefix,
    required this.items,
    required this.selectedId,
    required this.onSelected,
  });

  final String keyPrefix;
  final List<GiftTaxonomyItem> items;
  final String? selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CupidSpacing.sm,
      runSpacing: CupidSpacing.sm,
      children: <Widget>[
        for (final GiftTaxonomyItem item in items)
          _FilterChip(
            key: Key('${keyPrefix}_${item.id}'),
            label: item.label,
            selected: item.id == selectedId,
            onTap: () => onSelected(item.id),
          ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: selected ? colors.colorAccentPink : null,
            borderRadius: BorderRadius.circular(platform.radiusButton),
            border: selected ? null : Border.all(color: colors.colorLine),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CupidSpacing.md,
              vertical: CupidSpacing.sm,
            ),
            child: Text(
              label,
              style: type.body.copyWith(
                color: selected ? colors.colorOnAccent : colors.colorText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// What the whole set is personalised from, said in the reader's own words.
///
/// Only ever restates things the reader typed: the labels from their own skill
/// profile and how many rows they have written in the notebook. It is not a
/// quantity about the other person (AC-25), and not a completeness or progress
/// score — no target, no remainder, no percentage (AC-33). Renders nothing at
/// all for a reader who has written nothing, because a band claiming a basis
/// that does not exist would be worse than no band.
class _BasisBand extends StatelessWidget {
  const _BasisBand({
    required this.skillLabels,
    required this.notebookRowLabels,
  });

  final List<String> skillLabels;

  /// The rows themselves, not a count. The band only needs `.length`, but
  /// carrying labels keeps every integer in this tree derived from real data,
  /// which is what the gift flow's content gate checks for.
  final List<String> notebookRowLabels;

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    final List<String> parts = <String>[
      if (skillLabels.isNotEmpty)
        l10n.gift_ideas_basis_skills(skillLabels.join(' · ')),
      if (notebookRowLabels.isNotEmpty)
        l10n.gift_ideas_basis_notebook(notebookRowLabels.length),
    ];
    if (parts.isEmpty) {
      return const SizedBox.shrink();
    }

    return DecoratedBox(
      key: const Key('gift-ideas-basis-band'),
      decoration: BoxDecoration(
        color: colors.colorSurface,
        borderRadius: BorderRadius.circular(platform.radiusCard),
        border: Border.all(color: colors.colorLine),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CupidSpacing.sm),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            CupidIcon(
              CupidIcons.handyman,
              size: CupidSpacing.md,
              color: colors.colorMint,
            ),
            const SizedBox(width: CupidSpacing.sm),
            Expanded(
              child: Text(
                l10n.gift_ideas_basis_band(
                  parts.join(l10n.gift_ideas_basis_separator),
                ),
                style: type.caption.copyWith(color: colors.colorTextMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The R-13 placeholder for the two surfaces STORY-009/010 own.
///
/// The screen (5) canvas draws it as a card-like row with a `?` disc and a `›`
/// chevron rather than as plain caption text, and the design canvas anchors for
/// this screen. It is still a side path, not the destination of the screen: it
/// sits under every suggestion and carries no gradient and no primary styling.
/// Tapping it says the surfaces are not built yet — the same answer the hub's
/// quick-entry strip gives for a cell it cannot open — so the row is never a
/// tap that does nothing (SC-5).
class _GuessRow extends StatelessWidget {
  const _GuessRow();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;
    final CupidPlatformTokens platform = context.cupidPlatform;

    return Semantics(
      button: true,
      child: GestureDetector(
        key: const Key('gift-ideas-guess-row'),
        behavior: HitTestBehavior.opaque,
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            key: const Key('gift-ideas-guess-coming-soon'),
            content: Text(l10n.gift_ideas_guess_coming_soon),
          ),
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.colorSurface,
            borderRadius: BorderRadius.circular(platform.radiusCard),
            border: Border.all(color: colors.colorLine),
          ),
          child: Padding(
            padding: const EdgeInsets.all(CupidSpacing.sm),
            child: Row(
              children: <Widget>[
                _GlyphDisc(icon: CupidIcons.help, color: colors.colorTextMuted),
                const SizedBox(width: CupidSpacing.sm),
                Expanded(
                  child: Text(
                    l10n.gift_ideas_guess_row,
                    style: type.caption.copyWith(color: colors.colorText),
                  ),
                ),
                const SizedBox(width: CupidSpacing.sm),
                CupidIcon(
                  CupidIcons.chevronRight,
                  size: CupidSpacing.md,
                  color: colors.colorTextMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GlyphDisc extends StatelessWidget {
  const _GlyphDisc({required this.icon, required this.color});

  /// Spacing tokens, not pixel literals: no bare integer may sit under
  /// `features/gift_ideas/`, so the disc is built from the scale.
  static const double _diameter = CupidSpacing.lg;
  static const double _glyph = CupidSpacing.md;

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final CupidColorTokens colors = context.cupidColors;

    return Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colors.colorSurfaceAlt,
      ),
      child: Center(child: CupidIcon(icon, size: _glyph, color: color)),
    );
  }
}
