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
    required this.dismissedGiftIds,
    required this.roundStartGiftId,
    required this.skillLabels,
    required this.notebookRowLabels,
  });

  static const GiftIdeasState initial = GiftIdeasState(
    loading: true,
    branches: <GiftTaxonomyItem>[],
    effortTiers: <GiftTaxonomyItem>[],
    suggestions: <GiftSuggestion>[],
    filter: GiftFilter.none,
    addedGiftIds: <String>{},
    dismissedGiftIds: <String>{},
    roundStartGiftId: null,
    skillLabels: <String>[],
    notebookRowLabels: <String>[],
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

  /// Ideas the reader waved away with the per-card `×`. Same rule as
  /// [addedGiftIds]: screen-session state, never persisted, so a dismissal is
  /// undone by leaving the screen rather than by a "bỏ qua" list nobody asked
  /// for.
  final Set<String> dismissedGiftIds;

  /// Which idea the current round of suggestions starts at, or null while the
  /// round starts at the head of the ranked order.
  ///
  /// An id rather than an index, for the same reason the list is walked by
  /// identity elsewhere: the gift flow ships no bare counts (BR-17). Screen
  /// lifetime only, like the two sets above
  /// (`architecture/contract-summary.md` §6); it moves on when a dismissal
  /// would otherwise leave nothing to show, which is what turns exhaustion
  /// into a wrap instead of a dead end.
  final String? roundStartGiftId;

  /// What the explainer band names as the basis of the whole set. Both are
  /// derived from the same snapshot the selector ranked against, so the band
  /// can never claim a basis the ranking did not actually use.
  ///
  /// The notebook side is the labels, not a count, so the band reads
  /// `.length`/`.isNotEmpty` off real rows instead of carrying an integer the
  /// gift flow's content gate would (rightly) read as a pinned quantity.
  final List<String> skillLabels;
  final List<String> notebookRowLabels;

  GiftIdeasState _copyWith({
    Set<String>? addedGiftIds,
    Set<String>? dismissedGiftIds,
    String? roundStartGiftId,
  }) =>
      GiftIdeasState(
        loading: loading,
        branches: branches,
        effortTiers: effortTiers,
        suggestions: suggestions,
        filter: filter,
        addedGiftIds: addedGiftIds ?? this.addedGiftIds,
        dismissedGiftIds: dismissedGiftIds ?? this.dismissedGiftIds,
        roundStartGiftId: roundStartGiftId ?? this.roundStartGiftId,
        skillLabels: skillLabels,
        notebookRowLabels: notebookRowLabels,
      );

  GiftIdeasState withAdded(String giftId) =>
      _copyWith(addedGiftIds: <String>{...addedGiftIds, giftId});

  /// Moves past [giftId] rather than striking it off for the session.
  ///
  /// When waving this one away would leave the ranked list with nothing to
  /// show, the set clears and the round moves on one place instead: the whole
  /// ranked order comes back, led by the idea after the one that led the round
  /// just finished. So the reader can keep asking for the next idea for as
  /// long as they like, at any N, and never reaches an "đã hết ý tưởng" state
  /// (AC-33, BR-3).
  GiftIdeasState withDismissed(String giftId) {
    final Set<String> dismissed = <String>{...dismissedGiftIds, giftId};
    final bool exhausted = suggestions.isNotEmpty &&
        suggestions.every(
          (GiftSuggestion suggestion) => dismissed.contains(suggestion.idea.id),
        );
    if (!exhausted) {
      return _copyWith(dismissedGiftIds: dismissed);
    }

    final List<GiftSuggestion> round = _startingAtRound(suggestions);
    final Iterable<GiftSuggestion> afterLead = round.where(
      (GiftSuggestion suggestion) => !identical(suggestion, round.first),
    );
    return _copyWith(
      dismissedGiftIds: const <String>{},
      roundStartGiftId:
          (afterLead.isEmpty ? round.first : afterLead.first).idea.id,
    );
  }

  /// What the list actually draws: the ranked order rotated to
  /// [roundStartGiftId], minus the ideas waved away so far in this round.
  ///
  /// Dismissals are applied here rather than in the selector so the ranking
  /// stays a pure function of recorded context and filters (AC-28).
  ///
  /// Falling back to the whole ranked list matters when a filter narrows it
  /// down to ideas already dismissed under a wider one: without that, a branch
  /// that genuinely has matches would render as empty (AC-18). An empty
  /// [suggestions] still yields nothing, which is the defined empty branch of
  /// AC-34 and the only way the no-match line is reached.
  List<GiftSuggestion> get visibleSuggestions {
    final List<GiftSuggestion> remaining = <GiftSuggestion>[
      for (final GiftSuggestion suggestion in suggestions)
        if (!dismissedGiftIds.contains(suggestion.idea.id)) suggestion,
    ];
    return _startingAtRound(remaining.isEmpty ? suggestions : remaining);
  }

  /// [round] rotated so it opens on [roundStartGiftId], or untouched while no
  /// round start is set or the current one is not in this list — which is what
  /// a filter change leaves behind.
  List<GiftSuggestion> _startingAtRound(List<GiftSuggestion> round) {
    final int start = round.indexWhere(
      (GiftSuggestion suggestion) => suggestion.idea.id == roundStartGiftId,
    );
    return start.isNegative
        ? List<GiftSuggestion>.unmodifiable(round)
        : const GiftSelector()
            .nextBatch(round, cursor: start, size: round.length);
  }
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

  /// Waves one suggestion out of the list and shows the next one.
  ///
  /// Writes nothing: there is no "đã bỏ qua" table, and reopening the screen
  /// brings the idea back. A remembered rejection set would be a second store
  /// of gift state (SC-1'/AC-22) and, worse, a profile of the reader's taste
  /// that nobody asked to keep.
  ///
  /// Waving away the last one wraps the round rather than emptying the screen;
  /// see [GiftIdeasState.withDismissed].
  void dismiss(GiftSuggestion suggestion) {
    emit(state.withDismissed(suggestion.idea.id));
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
        dismissedGiftIds: state.dismissedGiftIds,
        roundStartGiftId: state.roundStartGiftId,
        skillLabels: <String>[
          for (final GiftContextValue value in snapshot.values)
            if (value.kind == GiftContextKind.skill) value.label,
        ],
        notebookRowLabels: <String>[
          for (final GiftContextValue value in snapshot.values)
            if (value.kind != GiftContextKind.skill) value.label,
        ],
      ),
    );
  }
}
