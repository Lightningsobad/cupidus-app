import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/activity_card.dart';
import '../domain/activity_card_repository.dart';

/// Page size for one status pane. The hub never reads the whole store
/// (`phase-P4-hub-list-and-entry-point.md` §3): a pane grows by appending
/// pages of this size through `cardsByStatus(limit:, offset:)`.
const int kActivityCardPageSize = 20;

/// The five panes, in the fixed order `ux/uiux-spec.md` §3 draws them: the
/// leading "Tất cả" view followed by the four lifecycle statuses. [all] is a
/// view and not a fifth status — no card is ever stored with it, and the
/// lifecycle stays four-valued (AC-10, D-1).
enum ActivityCardPane {
  all(null),
  idea(ActivityCardStatus.idea),
  scheduled(ActivityCardStatus.scheduled),
  done(ActivityCardStatus.done),
  memory(ActivityCardStatus.memory);

  const ActivityCardPane(this.status);

  final ActivityCardStatus? status;
}

class ActivityCardListState {
  const ActivityCardListState({
    this.pane = ActivityCardPane.all,
    this.cards = const <ActivityCard>[],
    this.counts = const <ActivityCardStatus, int>{},
    this.replyOverrides = const <String, ActivityCardReplyState>{},
    this.loading = true,
    this.loadingMore = false,
    this.hasMore = false,
    this.failed = false,
  });

  final ActivityCardPane pane;

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

  /// The number drawn beside a pane label. "Tất cả" shows the store total
  /// (`ux/uiux-spec.md` §3), each status pane shows its own count.
  int countForPane(ActivityCardPane pane) {
    final ActivityCardStatus? status = pane.status;
    return status == null ? storeCount : countFor(status);
  }

  /// Total cards across all four statuses, used to tell "this pane is empty
  /// but the store is not" (`ux/uiux-spec.md` §4b) from the Minute-1 empty
  /// store, and as the "Tất cả" pane's count.
  int get storeCount =>
      counts.values.fold<int>(0, (int sum, int count) => sum + count);

  ActivityCardReplyState replyStateOf(ActivityCard card) =>
      replyOverrides[card.id] ?? card.replyState;

  ActivityCardListState copyWith({
    ActivityCardPane? pane,
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

  Future<void> selectPane(ActivityCardPane pane) => _loadPane(pane);

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) {
      return;
    }
    final ActivityCardPane pane = state.pane;
    final List<ActivityCard> loaded = state.cards;
    emit(state.copyWith(loadingMore: true));
    try {
      final _CardPage page = await _fetchPage(pane, loaded);
      if (isClosed || state.pane != pane) {
        return;
      }
      emit(
        state.copyWith(
          cards: <ActivityCard>[...state.cards, ...page.cards],
          loadingMore: false,
          hasMore: page.hasMore,
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

  Future<void> _loadPane(ActivityCardPane pane) async {
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
      final _CardPage page = await _fetchPage(pane, const <ActivityCard>[]);
      if (isClosed || state.pane != pane) {
        return;
      }
      emit(
        state.copyWith(
          cards: page.cards,
          counts: counts,
          loading: false,
          hasMore: page.hasMore,
        ),
      );
    } on Object {
      if (isClosed || state.pane != pane) {
        return;
      }
      emit(state.copyWith(loading: false, failed: true));
    }
  }

  /// One page of [pane], continuing after [loaded]. A status pane is a single
  /// bounded `cardsByStatus` read. "Tất cả" has no query of its own — the
  /// repository contract exposes no cross-status read — so it is the four
  /// status panes advanced in parallel and merged newest-updated first, each
  /// offset by how many of its own cards are already loaded. Still bounded:
  /// no path here reads the whole store.
  Future<_CardPage> _fetchPage(
    ActivityCardPane pane,
    List<ActivityCard> loaded,
  ) async {
    final ActivityCardStatus? status = pane.status;
    if (status != null) {
      final List<ActivityCard> page = await _repository.cardsByStatus(
        status: status,
        limit: _pageSize,
        offset: loaded.length,
      );
      return _CardPage(page, page.length == _pageSize);
    }
    final List<List<ActivityCard>> pages = await Future.wait(
      ActivityCardStatus.values.map(
        (ActivityCardStatus each) => _repository.cardsByStatus(
          status: each,
          limit: _pageSize,
          offset: loaded
              .where((ActivityCard card) => card.status == each)
              .length,
        ),
      ),
    );
    final List<ActivityCard> merged = <ActivityCard>[
      for (final List<ActivityCard> page in pages) ...page,
    ]..sort((ActivityCard a, ActivityCard b) =>
        b.updatedAt.compareTo(a.updatedAt));
    return _CardPage(
      merged,
      pages.any((List<ActivityCard> page) => page.length == _pageSize),
    );
  }
}

class _CardPage {
  const _CardPage(this.cards, this.hasMore);

  final List<ActivityCard> cards;
  final bool hasMore;
}
