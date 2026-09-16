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
  memory(ActivityCardStatus.memory),

  /// The closed archive (AC-11, AC-14). Like [all] it is a view and not a
  /// lifecycle value: a closed card keeps the status it had, and the ledger —
  /// not a column — decides which pane shows it (BR-4). It is built into the
  /// filter only once a closure exists (AC-16).
  closed(null);

  const ActivityCardPane(this.status);

  final ActivityCardStatus? status;

  /// Distinguishes the two status-less panes, which [status] alone cannot.
  bool get isClosedArchive => this == ActivityCardPane.closed;
}

class ActivityCardListState {
  const ActivityCardListState({
    this.pane = ActivityCardPane.all,
    this.cards = const <ActivityCard>[],
    this.counts = const <ActivityCardStatus, int>{},
    this.replyOverrides = const <String, ActivityCardReplyState>{},
    this.hasClosedArchive = false,
    this.closedCount = 0,
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

  /// Whether a closure exists at all. The filter draws its sixth cell only
  /// while this is true, so before the first closure nothing on screen hints
  /// that a closed archive is a thing this app has (AC-16).
  final bool hasClosedArchive;

  /// Closed cards for the current owner, drawn beside the sixth label. Not part
  /// of [storeCount]: the five ordinary panes and their total never count what
  /// a closure took away (AC-11).
  final int closedCount;

  final bool loading;
  final bool loadingMore;
  final bool hasMore;
  final bool failed;

  int countFor(ActivityCardStatus status) => counts[status] ?? 0;

  /// The number drawn beside a pane label. "Tất cả" shows the store total
  /// (`ux/uiux-spec.md` §3), each status pane shows its own count.
  int countForPane(ActivityCardPane pane) {
    if (pane.isClosedArchive) {
      return closedCount;
    }
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
    bool? hasClosedArchive,
    int? closedCount,
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
      hasClosedArchive: hasClosedArchive ?? this.hasClosedArchive,
      closedCount: closedCount ?? this.closedCount,
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
    ClosedArchiveReader? closedArchive,
    int pageSize = kActivityCardPageSize,
  })  : _repository = repository,
        _closedArchive = closedArchive,
        _pageSize = pageSize,
        super(const ActivityCardListState());

  final ActivityCardRepository _repository;

  /// Absent in every surface that has no business showing closed material: the
  /// sixth pane then never appears and the five ordinary ones behave exactly as
  /// they did before this story.
  final ClosedArchiveReader? _closedArchive;

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
      final _ClosureSummary closure = await _readClosure();
      // Reopening or purging from inside the archive empties it while the user
      // is standing in it. Land them on "Tất cả" rather than on a pane that no
      // longer exists (AC-17, AC-30).
      final ActivityCardPane effective =
          pane.isClosedArchive && !closure.hasAny ? ActivityCardPane.all : pane;
      final _CardPage page = await _fetchPage(effective, const <ActivityCard>[]);
      if (isClosed || state.pane != pane) {
        return;
      }
      emit(
        state.copyWith(
          pane: effective,
          cards: page.cards,
          counts: counts,
          hasClosedArchive: closure.hasAny,
          closedCount: closure.count,
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
  Future<_ClosureSummary> _readClosure() async {
    final ClosedArchiveReader? archive = _closedArchive;
    if (archive == null || !await archive.hasAnyClosure()) {
      return const _ClosureSummary(false, 0);
    }
    return _ClosureSummary(true, await archive.closedCardCount());
  }

  Future<_CardPage> _fetchPage(
    ActivityCardPane pane,
    List<ActivityCard> loaded,
  ) async {
    if (pane.isClosedArchive) {
      final ClosedArchiveReader? archive = _closedArchive;
      if (archive == null) {
        return const _CardPage(<ActivityCard>[], false);
      }
      final List<ActivityCard> page = await archive.closedCards(
        limit: _pageSize,
        offset: loaded.length,
      );
      return _CardPage(page, page.length == _pageSize);
    }
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

class _ClosureSummary {
  const _ClosureSummary(this.hasAny, this.count);

  final bool hasAny;
  final int count;
}
