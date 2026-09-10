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
                if (state.suggestions.isEmpty)
                  Text(
                    l10n.gift_ideas_no_match,
                    key: const Key('gift-ideas-no-match'),
                    style: context.cupidType.body
                        .copyWith(color: context.cupidColors.colorTextMuted),
                  ),
                for (final GiftSuggestion suggestion in state.suggestions)
                  Padding(
                    padding: const EdgeInsets.only(bottom: CupidSpacing.md),
                    child: GiftIdeaCard(
                      suggestion: suggestion,
                      added: state.addedGiftIds.contains(suggestion.idea.id),
                      onAddToHub: () => cubit.addToHub(suggestion),
                    ),
                  ),
                const _LocationLockLine(),
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

/// The R-13 placeholder for the two surfaces STORY-009/010 own.
///
/// A small text line at the very bottom, under the suggestions — not a banner,
/// not a highlighted card and not a button, because this is a side path out of
/// the gift flow, not a destination of it (`ux/uiux-spec.md` Phần D). Nothing
/// is tappable yet: neither surface exists, and a link that goes nowhere is a
/// dead end (SC-5).
class _LocationLockLine extends StatelessWidget {
  const _LocationLockLine();

  @override
  Widget build(BuildContext context) {
    final AppL10n l10n = AppL10n.of(context);
    final CupidColorTokens colors = context.cupidColors;
    final CupidTypographyTokens type = context.cupidType;

    return Padding(
      key: const Key('gift-ideas-location-lock'),
      padding: const EdgeInsets.only(top: CupidSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            l10n.gift_ideas_location_lock_portrait,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
          const SizedBox(height: CupidSpacing.xs),
          Text(
            l10n.gift_ideas_location_lock_match,
            style: type.caption.copyWith(color: colors.colorTextMuted),
          ),
        ],
      ),
    );
  }
}
