import 'package:drift/drift.dart';

import '../../auth/cupid_session.dart';
import '../cupid_database.dart';
import '../tables/timeline_tables.dart';

part 'timeline_dao.g.dart';

/// DAO for the `timeline_entries`/`timeline_sync_state` tables (ADR-007 F5
/// seam). Registers as a [SessionScopedStore] so a second user on the same
/// device never reads the first couple's cached content (D-012-5).
@DriftAccessor(tables: [TimelineEntries, TimelineSyncState])
class TimelineDao extends DatabaseAccessor<CupidDatabase>
    with _$TimelineDaoMixin
    implements SessionScopedStore {
  TimelineDao(super.db);

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
