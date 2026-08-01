import 'package:drift/drift.dart';

import '../cupid_database.dart';
import '../tables/expenses_table.dart';

part 'expense_dao.g.dart';

/// DAO for the `expenses`/`expense_sync_metadata` tables (ADR-015.5,
/// ADR-015.6). Read-through cache only — no pending-write/outbox method
/// exists here by design (ADR-007 bound (b)).
@DriftAccessor(tables: [Expenses, ExpenseSyncMetadata])
class ExpenseDao extends DatabaseAccessor<CupidDatabase>
    with _$ExpenseDaoMixin {
  ExpenseDao(super.db);

  /// Upserts by server `id` so a re-fetched page never duplicates a row.
  Future<void> upsertAll(List<ExpenseCacheRow> rows) {
    return batch((batch) {
      batch.insertAllOnConflictUpdate(expenses, rows);
    });
  }

  /// Cached page ordered `date DESC, createdAt DESC`, matching the server's
  /// `GET /expenses` order. Paged only — never a full-table read (system
  /// memory §5 line 76, R4).
  Future<List<ExpenseCacheRow>> getPage({
    required int limit,
    required int offset,
  }) {
    return (select(expenses)
          ..orderBy(_pageOrder)
          ..limit(limit, offset: offset))
        .get();
  }

  /// Live version of [getPage], for the history screen (P3/P4).
  Stream<List<ExpenseCacheRow>> watchPage({
    required int limit,
    required int offset,
  }) {
    return (select(expenses)
          ..orderBy(_pageOrder)
          ..limit(limit, offset: offset))
        .watch();
  }

  /// All cached rows whose `date` falls in the calendar month containing
  /// [month], for P3's client-side monthly aggregation (ADR-015.3). Bounded
  /// to the cache only — ADR-015.3's "hide the delta if incomplete"
  /// consequence is P3's to honor, not this DAO's.
  ///
  /// Builds boundaries in the same UTC-vs-local flavor as [month] so the
  /// comparison lines up with however `date` was stored — a boundary built
  /// in the wrong flavor would silently shift by the host's UTC offset.
  Future<List<ExpenseCacheRow>> monthRows(DateTime month) {
    final start = month.isUtc
        ? DateTime.utc(month.year, month.month)
        : DateTime(month.year, month.month);
    final end = month.isUtc
        ? DateTime.utc(month.year, month.month + 1)
        : DateTime(month.year, month.month + 1);
    return (select(expenses)
          ..where(
            (row) =>
                row.date.isBiggerOrEqualValue(start) &
                row.date.isSmallerThanValue(end),
          )
          ..orderBy(_pageOrder))
        .get();
  }

  /// `null` on a fresh database, non-null only after [markSyncedNow] — the
  /// ADR-015.5 signal that discriminates never-synced from genuinely-zero.
  Future<DateTime?> get lastSuccessfulSyncAt async {
    final row = await (select(expenseSyncMetadata)
          ..where((row) => row.id.equals(0)))
        .getSingleOrNull();
    return row?.lastSuccessfulSyncAt;
  }

  /// Stamps the sync-metadata row after a successful `GET /expenses`
  /// (ADR-015.5) — never on a failed or partial fetch.
  Future<void> markSyncedNow() {
    return into(expenseSyncMetadata).insertOnConflictUpdate(
      ExpenseSyncMetadataCompanion.insert(
        id: const Value(0),
        lastSuccessfulSyncAt: Value(DateTime.now()),
      ),
    );
  }

  /// Row count via `COUNT`, never a full-table read (R4), so P3 can
  /// distinguish "zero rows" from "no page loaded yet" together with
  /// [lastSuccessfulSyncAt].
  Future<int> countAll() async {
    final row =
        await (selectOnly(expenses)..addColumns([expenses.id.count()]))
            .getSingle();
    return row.read(expenses.id.count()) ?? 0;
  }

  List<OrderingTerm Function($ExpensesTable)> get _pageOrder => [
        (row) => OrderingTerm(expression: row.date, mode: OrderingMode.desc),
        (row) =>
            OrderingTerm(expression: row.createdAt, mode: OrderingMode.desc),
      ];
}
