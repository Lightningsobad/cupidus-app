import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/activity_card.dart';
import '../domain/activity_card_repository.dart';

/// Page size for one status pane. The hub never reads the whole store
/// (`phase-P4-hub-list-and-entry-point.md` §3): a pane grows by appending
/// pages of this size through `cardsByStatus(limit:, offset:)`.
const int kActivityCardPageSize = 20;

/// The four panes, in the fixed order `ux/uiux-spec.md` §3 draws them.
const List<ActivityCardStatus> kActivityCardPanes = <ActivityCardStatus>[
  ActivityCardStatus.idea,
  ActivityCardStatus.scheduled,
  ActivityCardStatus.done,
  ActivityCardStatus.memory,
];

class ActivityCardListState {
  const ActivityCardListState({
    this.pane = ActivityCardStatus.idea,
    this.cards = const <ActivityCard>[],
    this.counts = const <ActivityCardStatus, int>{},
    this.replyOverrides = const <String, ActivityCardReplyState>{},
    this.loading = true,
    this.loadingMore = false,
    this.hasMore = false,
    this.failed = false,
  });

  final ActivityCardStatus pane;

  /// Only the pages loaded for [pane] — never cards of another status.
  final List<ActivityCard> cards;
  final Map<ActivityCardStatus, int> counts;

  /// `ActivityCardRepository` exposes no writer for the `reply_state` column,
  /// so the "đã rủ" chip's two values are toggled here and are not persisted.
  /// The story that owns that column replaces this map with a repository call.
  final Map<String, ActivityCardReplyState> replyOverrides;

  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final bool failed;

  int countFor(ActivityCardStatus status) => counts[status] ?? 0;

  /// Total cards across all four panes, used to tell "this pane is empty but
  /// the store is not" (`ux/uiux-spec.md` §4b) from the Minute-1 empty store.
  int get storeCount =>
      counts.values.fold<int>(0, (int sum, int count) => sum + count);

  ActivityCardReplyState replyStateOf(ActivityCard card) =>
      replyOverrides[card.id] ?? card.replyState;

  ActivityCardListState copyWith({
    ActivityCardStatus? pane,
    List<ActivityCard>? cards,
    Map<ActivityCardStatus, int>? counts,
    Map<String, ActivityCardReplyState>? replyOverrides,
    bool? loading,
    bool? loadingMore,
    bool? hasMore,
    bool? failed,
  }) {
    return ActivityCardListState(
      pane: pane ?? this.pane,
      cards: cards ?? this.cards,
      counts: counts ?? this.counts,
      replyOverrides: replyOverrides ?? this.replyOverrides,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      hasMore: hasMore ?? this.hasMore,
      failed: failed ?? this.failed,
    );
  }
}

/// Drives the activity-card hub: which pane is selected, that pane's paged
/// cards, and the per-pane counts drawn beside the filter labels.
class ActivityCardListCubit extends Cubit<ActivityCardListState> {
  ActivityCardListCubit({
    required ActivityCardRepository repository,
    int pageSize = kActivityCardPageSize,
  })  : _repository = repository,
        _pageSize = pageSize,
        super(const ActivityCardListState());

  final ActivityCardRepository _repository;
  final int _pageSize;

  Future<void> load() => _loadPane(state.pane);

  Future<void> selectPane(ActivityCardStatus pane) => _loadPane(pane);

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) {
      return;
    }
    final ActivityCardStatus pane = state.pane;
    final int offset = state.cards.length;
    emit(state.copyWith(loadingMore: true));
    try {
      final List<ActivityCard> page = await _repository.cardsByStatus(
        status: pane,
        limit: _pageSize,
        offset: offset,
      );
      if (isClosed || state.pane != pane) {
        return;
      }
      emit(
        state.copyWith(
          cards: <ActivityCard>[...state.cards, ...page],
          loadingMore: false,
          hasMore: page.length == _pageSize,
        ),
      );
    } on Object {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(loadingMore: false, hasMore: false));
    }
  }

  void toggleReplyState(String cardId) {
    final ActivityCard? card = state.cards
        .cast<ActivityCard?>()
        .firstWhere((ActivityCard? each) => each?.id == cardId, orElse: () => null);
    if (card == null) {
      return;
    }
    final ActivityCardReplyState next =
        state.replyStateOf(card) == ActivityCardReplyState.answered
            ? ActivityCardReplyState.notAnswered
            : ActivityCardReplyState.answered;
    emit(
      state.copyWith(
        replyOverrides: <String, ActivityCardReplyState>{
          ...state.replyOverrides,
          cardId: next,
        },
      ),
    );
  }

  /// AC-13's delete path, available in every pane including *Đã thành kỷ niệm*.
  Future<void> deleteCard(String cardId) async {
    try {
      await _repository.deleteCard(cardId);
    } on Object {
      if (isClosed) {
        return;
      }
      emit(state.copyWith(failed: true));
      return;
    }
    if (isClosed) {
      return;
    }
    await _loadPane(state.pane);
  }

  Future<void> _loadPane(ActivityCardStatus pane) async {
    emit(
      state.copyWith(
        pane: pane,
        cards: const <ActivityCard>[],
        loading: true,
        loadingMore: false,
        hasMore: false,
        failed: false,
      ),
    );
    try {
      final Map<ActivityCardStatus, int> counts =
          await _repository.countsByStatus();
      final List<ActivityCard> page = await _repository.cardsByStatus(
        status: pane,
        limit: _pageSize,
        offset: 0,
      );
      if (isClosed || state.pane != pane) {
        return;
      }
      emit(
        state.copyWith(
          cards: page,
          counts: counts,
          loading: false,
          hasMore: page.length == _pageSize,
        ),
      );
    } on Object {
      if (isClosed || state.pane != pane) {
        return;
      }
      emit(state.copyWith(loading: false, failed: true));
    }
  }
}
