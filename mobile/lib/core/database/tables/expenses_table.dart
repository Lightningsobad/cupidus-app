import 'package:drift/drift.dart';

/// Local read-through cache of the frozen backend `Expense` entity
/// (`architecture/solution.md` §2 Data model / migration contract). Renamed
/// via `@DataClassName` to `ExpenseCacheRow` because `features/expenses`
/// already owns a domain `Expense` model (P1) and `core/` must never import
/// `features/` (see `cupid_database.dart`) to reuse it here.
///
/// Server-authoritative, cache-only; no pending-write/outbox column exists
/// here by design (ADR-007 bound (b), ADR-015.6).
@DataClassName('ExpenseCacheRow')
class Expenses extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get category => text()();
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get date => dateTime()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Single-row marker distinguishing never-synced from synced-zero-expenses
/// (ADR-015.5), required because `GET /expenses` returns `[]` for both cases.
class ExpenseSyncMetadata extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSuccessfulSyncAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
