import 'dart:async';

import 'package:cupid_mobile/core/database/cupid_database.dart'
    show ExpenseCacheRow;
import 'package:cupid_mobile/core/database/daos/expense_dao.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/expense_category.dart';
import '../data/expense_models.dart';
import '../data/expenses_repository.dart';
import 'expense_month_summary.dart';

/// Immutable UI state for `ExpenseHistoryScreen`
/// (`coding-plan/phase-P3-history-screen.md` §3/§4).
class ExpenseHistoryState {
  const ExpenseHistoryState({
    this.rows = const <ExpenseCacheRow>[],
    this.hasCompletedInitialFetch = false,
    this.lastSuccessfulSyncAt,
    this.cachedRowCount = 0,
    this.isOffline = false,
    this.hasMore = true,
    this.selectedCategory,
    this.summary,
  });

  /// The loaded page(s), straight from `ExpenseDao` — never the whole table
  /// (system memory §5 line 76, R4). Unfiltered; see [filteredRows].
  final List<ExpenseCacheRow> rows;

  /// `true` once the constructor's initial cache-then-network attempt has
  /// settled — the only signal [isNeverSynced]/[isGenuinelyEmpty] use to
  /// distinguish "not loaded yet" from a genuine empty/never-synced state.
  final bool hasCompletedInitialFetch;

  /// Mirrors `ExpenseDao.lastSuccessfulSyncAt` (ADR-015.5). `null` means no
  /// `GET /expenses` has ever completed successfully on this device.
  final DateTime? lastSuccessfulSyncAt;

  /// Mirrors `ExpenseDao.countAll()` — the *entire* local cache's row
  /// count, not just [rows.length] (which is bounded to the loaded page).
  final int cachedRowCount;

  /// Set when the most recent read-through fetch attempt failed; cleared on
  /// the next successful one. Drives the freshness caption
  /// (`ux/uiux-spec.md` §5) — never a full-screen error (ADR-007: offline
  /// read is a normal, expected state).
  final bool isOffline;

  /// `false` once the most recent page fetch returned fewer rows than
  /// requested — the offset-paging end-of-history signal for `loadMore()`.
  final bool hasMore;

  /// `null` = "All" (`ux/uiux-spec.md` §4). Category-only filter, applied
  /// client-side over [rows] — never a per-partner filter (AC2).
  final ExpenseCategory? selectedCategory;

  /// `null` until the first cache read completes (ADR-015.3 aggregation).
  final ExpenseMonthSummary? summary;

  /// ADR-015.5: no backend signal distinguishes "nothing has ever synced"
  /// from "synced and genuinely empty" — `lastSuccessfulSyncAt == null`
  /// plus a zero cached count is the only source of truth.
  bool get isNeverSynced =>
      hasCompletedInitialFetch &&
      lastSuccessfulSyncAt == null &&
      cachedRowCount == 0;

  /// Distinct from [isNeverSynced] by design (`ux/uiux-spec.md` §5) — the
  /// couple has synced at least once and truly has zero expenses.
  bool get isGenuinelyEmpty =>
      hasCompletedInitialFetch &&
      lastSuccessfulSyncAt != null &&
      cachedRowCount == 0;

  /// Visible only while offline, per `ux/uiux-spec.md` §5 — never a
  /// permanent provenance label, and never shown before any sync has ever
  /// completed (that case is [isNeverSynced]'s copy instead).
  bool get showFreshnessCaption => isOffline && lastSuccessfulSyncAt != null;

  /// Category-only client-side filter over the currently loaded page
  /// (AC2) — never a new query, never a "my/partner" split.
  List<ExpenseCacheRow> get filteredRows {
    final ExpenseCategory? category = selectedCategory;
    if (category == null) return rows;
    return rows
        .where((ExpenseCacheRow row) => row.category == category.wireValue)
        .toList(growable: false);
  }

  ExpenseHistoryState copyWith({
    List<ExpenseCacheRow>? rows,
    bool? hasCompletedInitialFetch,
    DateTime? lastSuccessfulSyncAt,
    int? cachedRowCount,
    bool? isOffline,
    bool? hasMore,
    ExpenseCategory? selectedCategory,
    bool clearSelectedCategory = false,
    ExpenseMonthSummary? summary,
  }) {
    return ExpenseHistoryState(
      rows: rows ?? this.rows,
      hasCompletedInitialFetch:
          hasCompletedInitialFetch ?? this.hasCompletedInitialFetch,
      lastSuccessfulSyncAt: lastSuccessfulSyncAt ?? this.lastSuccessfulSyncAt,
      cachedRowCount: cachedRowCount ?? this.cachedRowCount,
      isOffline: isOffline ?? this.isOffline,
      hasMore: hasMore ?? this.hasMore,
      selectedCategory: clearSelectedCategory
          ? null
          : (selectedCategory ?? this.selectedCategory),
      summary: summary ?? this.summary,
    );
  }
}

/// Cubit for the `expense` history screen
/// (`coding-plan/phase-P3-history-screen.md` §3, AC2/AC3). Implements the
/// read-through contract verbatim: emit cache immediately, refresh from
/// `ExpensesRepository`, and on failure keep the cached page rather than
/// erroring out (ADR-007). Never touches `Dio` or a raw `Drift` query
/// outside `ExpenseDao` (D2, ADR-003).
class ExpenseHistoryCubit extends Cubit<ExpenseHistoryState> {
  ExpenseHistoryCubit({
    required ExpensesRepository repository,
    required ExpenseDao dao,
    DateTime Function()? now,
  }) : _repository = repository,
       _dao = dao,
       _now = now ?? DateTime.now,
       super(const ExpenseHistoryState()) {
    unawaited(_loadInitial());
  }

  static const int _pageSize = 50;

  final ExpensesRepository _repository;
  final ExpenseDao _dao;
  final DateTime Function() _now;

  /// Rows currently believed to be loaded from the server this session —
  /// the `offset` cursor for `loadMore()`. Distinct from
  /// `ExpenseHistoryState.cachedRowCount`, which is the *entire* local
  /// cache (may include rows from a prior session's paging).
  int _loadedCount = 0;

  Future<void> _loadInitial() async {
    await _emitFromCache();
    await _syncPage(limit: _pageSize, offset: 0);
  }

  /// Fetches the next older offset page (`ux/uiux-spec.md` §4 pagination).
  /// The whole table is never held in Cubit state — only what has been
  /// explicitly paged in.
  Future<void> loadMore() async {
    if (isClosed || !state.hasMore) return;
    await _syncPage(limit: _pageSize, offset: _loadedCount);
  }

  /// Pull-to-refresh and screen-focus refresh: re-fetches everything
  /// already paged in, so a scrolled-down user does not lose their loaded
  /// window.
  Future<void> refresh() async {
    if (isClosed) return;
    final int limit = _loadedCount == 0 ? _pageSize : _loadedCount;
    await _syncPage(limit: limit, offset: 0);
  }

  /// `null` selects "All" (`ux/uiux-spec.md` §4).
  void categorySelected(ExpenseCategory? category) {
    if (isClosed) return;
    emit(
      category == null
          ? state.copyWith(clearSelectedCategory: true)
          : state.copyWith(selectedCategory: category),
    );
  }

  Future<void> _emitFromCache() async {
    final List<ExpenseCacheRow> cached = await _dao.getPage(
      limit: _pageSize,
      offset: 0,
    );
    _loadedCount = cached.length;
    final DateTime? syncedAt = await _dao.lastSuccessfulSyncAt;
    final int totalCount = await _dao.countAll();
    final ExpenseMonthSummary summary = await _computeSummary();
    if (isClosed) return;
    emit(
      state.copyWith(
        rows: cached,
        lastSuccessfulSyncAt: syncedAt,
        cachedRowCount: totalCount,
        hasMore: cached.length == _pageSize,
        summary: summary,
      ),
    );
  }

  /// Steps 2-3 of the read-through contract: attempt the network fetch, and
  /// on success upsert + `markSyncedNow()` + re-emit from cache; on failure
  /// keep the cached page and flag offline rather than surfacing an error
  /// state (ADR-007).
  Future<void> _syncPage({required int limit, required int offset}) async {
    try {
      final List<Expense> fetched = await _repository.fetchPage(
        limit: limit,
        offset: offset,
      );
      await _dao.upsertAll(
        fetched.map(_toCacheRow).toList(growable: false),
      );
      await _dao.markSyncedNow();
      final int newLoadedCount = offset + fetched.length;
      if (newLoadedCount > _loadedCount) _loadedCount = newLoadedCount;

      final List<ExpenseCacheRow> cached = await _dao.getPage(
        limit: _loadedCount == 0 ? limit : _loadedCount,
        offset: 0,
      );
      final DateTime? syncedAt = await _dao.lastSuccessfulSyncAt;
      final int totalCount = await _dao.countAll();
      final ExpenseMonthSummary summary = await _computeSummary();
      if (isClosed) return;
      emit(
        state.copyWith(
          rows: cached,
          hasCompletedInitialFetch: true,
          lastSuccessfulSyncAt: syncedAt,
          cachedRowCount: totalCount,
          isOffline: false,
          hasMore: fetched.length == limit,
          summary: summary,
        ),
      );
    } catch (_) {
      // ADR-007: never surface a network failure as an error state — the
      // cached page (already emitted by `_emitFromCache`/a prior
      // `_syncPage`) keeps rendering, only `isOffline` flips.
      if (isClosed) return;
      emit(state.copyWith(hasCompletedInitialFetch: true, isOffline: true));
    }
  }

  /// ADR-015.3: current-month total/chart plus the vs-last-month delta,
  /// hidden unless the cache demonstrably covers the whole previous month.
  /// The "oldest cached row" query reuses existing `ExpenseDao` surface
  /// (`countAll` + `getPage`) rather than adding a new DAO method — see
  /// `ExpenseMonthSummary.compute` dartdoc for why that proves coverage.
  Future<ExpenseMonthSummary> _computeSummary() async {
    final DateTime now = _now();
    final DateTime currentMonth = DateTime(now.year, now.month);
    final DateTime previousMonth = DateTime(now.year, now.month - 1);
    final List<ExpenseCacheRow> currentMonthRows = await _dao.monthRows(
      currentMonth,
    );
    final List<ExpenseCacheRow> previousMonthRows = await _dao.monthRows(
      previousMonth,
    );
    final int totalCached = await _dao.countAll();
    DateTime? oldestCachedDate;
    if (totalCached > 0) {
      final List<ExpenseCacheRow> oldestPage = await _dao.getPage(
        limit: 1,
        offset: totalCached - 1,
      );
      oldestCachedDate = oldestPage.isEmpty ? null : oldestPage.first.date;
    }
    return ExpenseMonthSummary.compute(
      month: currentMonth,
      currentMonthRows: currentMonthRows,
      previousMonthRows: previousMonthRows,
      oldestCachedDate: oldestCachedDate,
    );
  }

  ExpenseCacheRow _toCacheRow(Expense expense) {
    return ExpenseCacheRow(
      id: expense.id,
      userId: expense.userId,
      category: expense.category.wireValue,
      amount: expense.amountVnd.toDouble(),
      description: expense.description,
      date: expense.date,
      createdAt: expense.createdAt,
    );
  }
}
