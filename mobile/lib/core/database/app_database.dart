import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../auth/cupid_session.dart';

part 'app_database.g.dart';

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

/// The app's first local persistence layer (ADR-007 F5 seam). Registers as a
/// [SessionScopedStore] so a second user on the same device never reads the
/// first couple's cached content (D-012-5).
@DriftDatabase(tables: [TimelineEntries, TimelineSyncState])
class AppDatabase extends _$AppDatabase implements SessionScopedStore {
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());

  @override
  int get schemaVersion => 1;

  /// Newest-first stream of the cached first page (AC3).
  Stream<List<TimelineEntry>> watchFirstPage() {
    return (select(timelineEntries)
          ..orderBy(
            [(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)],
          ))
        .watch();
  }

  /// Atomically replaces the cached first page and stamps
  /// `timeline_sync_state.lastSyncedAt` in the same transaction, so a
  /// mid-write failure leaves the previous rows intact (ADR-007).
  Future<void> replaceFirstPage(List<TimelineEntry> entries) {
    return transaction(() async {
      await delete(timelineEntries).go();
      if (entries.isNotEmpty) {
        await batch((batch) {
          batch.insertAll(
            timelineEntries,
            entries.map((entry) => entry.toCompanion(false)),
          );
        });
      }
      await into(timelineSyncState).insertOnConflictUpdate(
        TimelineSyncStateCompanion.insert(
          id: const Value(0),
          lastSyncedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  /// `null` before the first [replaceFirstPage] call, a timestamp after
  /// (D-012-6).
  Future<DateTime?> lastSyncedAt() async {
    final row = await (select(timelineSyncState)..where((t) => t.id.equals(0)))
        .getSingleOrNull();
    return row?.lastSyncedAt;
  }

  /// AC4 sign-out teardown: empties both tables (D-012-5). No token,
  /// credential, or auth material is ever stored here.
  @override
  Future<void> clearOnSignOut() async {
    await delete(timelineEntries).go();
    await delete(timelineSyncState).go();
  }
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'cupid_app_database.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
