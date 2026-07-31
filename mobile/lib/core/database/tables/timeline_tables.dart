import 'package:drift/drift.dart';

/// Timeline read-through cache rows (ADR-007 F5). The server assigns `id`;
/// the client never generates it (`architecture/solution.md` §2).
class TimelineEntries extends Table {
  TextColumn get id => text()();
  TextColumn get type => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get icon => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Single-row marker distinguishing never-synced from synced-empty (D-012-6),
/// required because `GET /timeline` returns `[]` for both cases.
class TimelineSyncState extends Table {
  IntColumn get id => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
