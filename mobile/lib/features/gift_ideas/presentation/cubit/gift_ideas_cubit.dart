import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../activity_cards/domain/activity_card.dart';
import '../../../activity_cards/domain/activity_card_repository.dart';
import '../../data/gift_repository.dart';
import '../../domain/gift_content.dart';
import '../../domain/gift_selector.dart';

/// How long the hub card says an idea takes.
///
/// A read, not a conversion: `gift_taxonomy` already stores each tier's ceiling
/// in minutes, so no per-tier factor is pinned in Dart and a pack that ships a
/// fourth tier needs no edit here (R-15a, AC-34). Null when a pack points at a
/// tier the taxonomy does not declare, which leaves the hub card's estimate
/// blank rather than inventing one.
int? giftDurationMinutes(GiftSuggestion suggestion) => suggestion.effortMinutes;

/// Everything screen (5) draws, including the two chip rows.
///
/// [branches] and [effortTiers] are carried in state rather than read from a
/// Dart list at build time, so the chip rows are exactly as long as the pack
/// (AC-32/AC-34, R-15b).
class GiftIdeasState {
  const GiftIdeasState({
    required this.loading,
    required this.branches,
    required this.effortTiers,
    required this.suggestions,
    required this.filter,
    required this.addedGiftIds,
  });

  static const GiftIdeasState initial = GiftIdeasState(
    loading: true,
    branches: <GiftTaxonomyItem>[],
    effortTiers: <GiftTaxonomyItem>[],
    suggestions: <GiftSuggestion>[],
    filter: GiftFilter.none,
    addedGiftIds: <String>{},
  );

  final bool loading;
  final List<GiftTaxonomyItem> branches;
  final List<GiftTaxonomyItem> effortTiers;
  final List<GiftSuggestion> suggestions;
  final GiftFilter filter;

  /// Ideas already pushed to the hub this session, so each card can confirm in
  /// place. Screen state only — nothing here is written down, because a
  /// remembered "đã thêm" set is the second store `contract-summary.md` §6
  /// rules out.
  final Set<String> addedGiftIds;

  GiftIdeasState withAdded(String giftId) => GiftIdeasState(
        loading: loading,
        branches: branches,
        effortTiers: effortTiers,
        suggestions: suggestions,
        filter: filter,
        addedGiftIds: <String>{...addedGiftIds, giftId},
      );
}

/// Screen (5)'s state holder: read the packs, read what the user wrote, rank,
/// and push a chosen idea into the shared hub of screen (1).
///
/// It owns no store of its own and never writes to the notebook — the inline
/// ask card does that, and this cubit only re-reads afterwards.
class GiftIdeasCubit extends Cubit<GiftIdeasState> {
  GiftIdeasCubit({
    required GiftRepository gifts,
    required ActivityCardRepository cards,
    GiftSelector selector = const GiftSelector(),
  })  : _gifts = gifts,
        _cards = cards,
        _selector = selector,
        super(GiftIdeasState.initial);

  final GiftRepository _gifts;
  final ActivityCardRepository _cards;
  final GiftSelector _selector;

  Future<void> load() => _rank(state.filter);

  /// Tapping the chip that is already on clears that filter. That is why the
  /// branch row holds exactly one chip per pack branch and no extra "tất cả"
  /// cell: an added cell would make the row longer than the pack (AC-34).
  Future<void> selectBranch(String branchId) => _rank(
        GiftFilter(
          branchId: state.filter.branchId == branchId ? null : branchId,
          effortTierId: state.filter.effortTierId,
        ),
      );

  Future<void> selectEffortTier(String effortTierId) => _rank(
        GiftFilter(
          branchId: state.filter.branchId,
          effortTierId: state.filter.effortTierId == effortTierId
              ? null
              : effortTierId,
        ),
      );

  /// Re-runs the selector after the inline ask card records an answer. In
  /// place, on the same screen, with the same filters: answering a question
  /// never moves the reader anywhere (AC-2, AC-24).
  Future<void> refreshContext() => _rank(state.filter);

  /// The single write this flow performs, and it lands in the shared hub, not
  /// anywhere local (SC-1'/AC-22). The draft carries a title, the provenance
  /// value STORY-001 reserved for this story, and the effort estimate; every
  /// other field is left alone, so the cost field STORY-001 offers is never
  /// filled by this flow (AC-23).
  Future<void> addToHub(GiftSuggestion suggestion) async {
    await _cards.createCard(
      NewActivityCard(
        title: suggestion.idea.title,
        origin: ActivityCardOrigin.giftSuggestion,
        durationMinutes: giftDurationMinutes(suggestion),
      ),
    );
    if (isClosed) {
      return;
    }
    emit(state.withAdded(suggestion.idea.id));
  }

  Future<void> _rank(GiftFilter filter) async {
    final GiftCatalogue catalogue = await _gifts.catalogue();
    // Read fresh every pass: the inline ask card writes to the notebook while
    // this screen is open, so a cached snapshot would rank against context the
    // user has already replaced.
    final GiftContextSnapshot snapshot = await _gifts.context();
    if (isClosed) {
      return;
    }
    emit(
      GiftIdeasState(
        loading: false,
        branches: catalogue.branches,
        effortTiers: catalogue.effortTiers,
        suggestions: _selector.suggest(
          catalogue: catalogue,
          context: snapshot,
          filter: filter,
        ),
        filter: filter,
        addedGiftIds: state.addedGiftIds,
      ),
    );
  }
}
