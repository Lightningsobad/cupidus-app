import 'package:cupid_mobile/core/database/cupid_database.dart' as db;
import 'package:cupid_mobile/core/database/daos/timeline_dao.dart';
import 'package:cupid_mobile/core/network/cupid_api.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_event_dto.dart';
import 'package:cupid_mobile/features/timeline/data/timeline_remote_data_source.dart';
import 'package:cupid_mobile/features/timeline/domain/timeline_entry.dart';

/// The outcome of [TimelineRepository.refresh] (ADR-007 read-through).
sealed class TimelineRefreshOutcome {
  const TimelineRefreshOutcome();
}

/// The remote fetch succeeded and the cache was replaced.
class TimelineSynced extends TimelineRefreshOutcome {
  const TimelineSynced();
}

/// The network was unavailable but a prior sync left cached rows readable
/// (AC3).
class TimelineOfflineWithCache extends TimelineRefreshOutcome {
  const TimelineOfflineWithCache();
}

/// The network was unavailable and no prior sync ever populated the cache.
class TimelineOfflineNoCache extends TimelineRefreshOutcome {
  const TimelineOfflineNoCache();
}

/// A non-connectivity [CupidApiFailure]; the cache is left untouched.
class TimelineRefreshFailed extends TimelineRefreshOutcome {
  const TimelineRefreshFailed(this.failure);

  final CupidApiFailure failure;
}

/// ADR-007 read-through seam joining the Drift cache (P1) and the remote
/// source (P2). [watchEntries] is the only read path the UI sees; a network
/// result is never surfaced directly, and a connectivity failure never
/// clears the cache.
class TimelineRepository {
  TimelineRepository(this._database, this._remote);

  final TimelineDao _database;
  final TimelineRemoteDataSource _remote;

  Stream<List<TimelineEntry>> watchEntries() => _database
      .watchFirstPage()
      .map((rows) => rows.map(_toDomain).toList(growable: false));

  /// Replaces the cache on a successful fetch. On a connectivity failure the
  /// cache is left untouched and the outcome reflects whether a prior sync
  /// ever populated it (D-012-6); on any other [CupidApiFailure] the outcome
  /// carries the failure and the cache is likewise untouched.
  Future<TimelineRefreshOutcome> refresh() async {
    try {
      final entries = await _remote.fetchFirstPage();
      await _database.replaceFirstPage(entries.map(_toRow).toList());
      return const TimelineSynced();
    } on CupidApiFailure catch (failure) {
      if (failure is NetworkUnavailableFailure || failure is TimeoutFailure) {
        final lastSyncedAt = await _database.lastSyncedAt();
        return lastSyncedAt != null
            ? const TimelineOfflineWithCache()
            : const TimelineOfflineNoCache();
      }
      return TimelineRefreshFailed(failure);
    }
  }

  /// Writes nothing locally on failure and rethrows the [CupidApiFailure]
  /// (ADR-007: no optimistic insert, no outbox, no automatic retry). On
  /// success, [refresh] makes the server-assigned `id`/`createdAt` the local
  /// truth.
  Future<TimelineRefreshOutcome> createEntry(TimelineDraft draft) async {
    await _remote.createEntry(draft);
    return refresh();
  }

  db.TimelineEntry _toRow(TimelineEntry entry) => db.TimelineEntry(
    id: entry.id,
    type: entry.type.name,
    title: entry.title,
    description: entry.description,
    photoUrl: entry.photoUrl,
    icon: entry.icon,
    createdAt: entry.createdAt,
  );

  TimelineEntry _toDomain(db.TimelineEntry row) => TimelineEntry(
    id: row.id,
    type: TimelineEventType.values.firstWhere(
      (type) => type.name == row.type,
      orElse: () => TimelineEventType.memory,
    ),
    title: row.title,
    createdAt: row.createdAt,
    description: row.description,
    photoUrl: row.photoUrl,
    icon: row.icon,
  );
}
