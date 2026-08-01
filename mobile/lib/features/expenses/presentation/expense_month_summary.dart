import 'package:cupid_mobile/core/database/cupid_database.dart' show ExpenseCacheRow;

/// Client-side monthly aggregation over cached rows only (ADR-015.3):
/// current-month total, item count, a 7-bucket Mon-Sun spend profile for the
/// mini chart, and the vs-last-month delta.
///
/// A pure value type — no Dio, no Drift query, no `BuildContext`. The
/// caller ([ExpenseHistoryCubit]) is responsible for fetching
/// [currentMonthRows] / [previousMonthRows] from `ExpenseDao.monthRows` and
/// for supplying [oldestCachedDate].
class ExpenseMonthSummary {
  const ExpenseMonthSummary({
    required this.totalVnd,
    required this.itemCount,
    required this.weekdayTotalsVnd,
    this.previousMonthTotalVnd,
  });

  /// Sum of `amount` across the current month's cached rows.
  final num totalVnd;

  /// Row count for the current month's cached rows.
  final int itemCount;

  /// 7 buckets indexed `[0]` = Monday .. `[6]` = Sunday
  /// (`DateTime.weekday` 1..7), each the sum of that weekday's spend across
  /// the current month's cached rows. Backs the 7-bar mini chart.
  final List<num> weekdayTotalsVnd;

  /// `null` when the cache does not demonstrably cover the whole previous
  /// month (ADR-015.3) — never a delta computed from a partial cache.
  final num? previousMonthTotalVnd;

  /// `null` when [previousMonthTotalVnd] is hidden; a positive value is a
  /// spending increase vs. last month, negative a decrease.
  num? get deltaVnd =>
      previousMonthTotalVnd == null ? null : totalVnd - previousMonthTotalVnd!;

  /// Computes the summary for the calendar month containing [month].
  ///
  /// [oldestCachedDate] is the `date` of the single oldest row across the
  /// *entire* local cache (not just [previousMonthRows]) — derivable from
  /// existing `ExpenseDao` surface via `getPage(limit: 1, offset:
  /// countAll() - 1)` (paging is `date DESC`, so the last page row is the
  /// oldest). Because `GET /expenses` paging is sequential and
  /// non-skipping, an [oldestCachedDate] on or before the first day of the
  /// previous month proves every row the server has for that month is
  /// already cached — the only way to "demonstrably cover" it without a
  /// server-side coverage signal (none exists; `/expenses/report` was
  /// rejected as the summary source, ADR-015.3). A `null`
  /// [oldestCachedDate] (nothing cached yet) always hides the delta.
  factory ExpenseMonthSummary.compute({
    required DateTime month,
    required List<ExpenseCacheRow> currentMonthRows,
    required List<ExpenseCacheRow> previousMonthRows,
    required DateTime? oldestCachedDate,
  }) {
    final num total = _sum(currentMonthRows);
    final List<num> buckets = List<num>.filled(7, 0);
    for (final ExpenseCacheRow row in currentMonthRows) {
      final int bucketIndex = row.date.weekday - 1;
      buckets[bucketIndex] += row.amount;
    }

    // Matches [month]'s UTC-ness so the `isAfter` comparison below never
    // drifts by a local-timezone offset against [oldestCachedDate] (both
    // `ExpenseDao` and its callers work in UTC, per `expense_dao_test.dart`).
    final DateTime previousMonthStart = month.isUtc
        ? DateTime.utc(month.year, month.month - 1)
        : DateTime(month.year, month.month - 1);
    final bool previousMonthCovered =
        oldestCachedDate != null &&
        !oldestCachedDate.isAfter(previousMonthStart);

    return ExpenseMonthSummary(
      totalVnd: total,
      itemCount: currentMonthRows.length,
      weekdayTotalsVnd: buckets,
      previousMonthTotalVnd: previousMonthCovered
          ? _sum(previousMonthRows)
          : null,
    );
  }

  static num _sum(List<ExpenseCacheRow> rows) =>
      rows.fold<num>(0, (num sum, ExpenseCacheRow row) => sum + row.amount);
}
