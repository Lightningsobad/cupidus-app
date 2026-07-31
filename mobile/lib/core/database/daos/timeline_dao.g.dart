// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'timeline_dao.dart';

// ignore_for_file: type=lint
mixin _$TimelineDaoMixin on DatabaseAccessor<CupidDatabase> {
  $TimelineEntriesTable get timelineEntries => attachedDatabase.timelineEntries;
  $TimelineSyncStateTable get timelineSyncState =>
      attachedDatabase.timelineSyncState;
  TimelineDaoManager get managers => TimelineDaoManager(this);
}

class TimelineDaoManager {
  final _$TimelineDaoMixin _db;
  TimelineDaoManager(this._db);
  $$TimelineEntriesTableTableManager get timelineEntries =>
      $$TimelineEntriesTableTableManager(
        _db.attachedDatabase,
        _db.timelineEntries,
      );
  $$TimelineSyncStateTableTableManager get timelineSyncState =>
      $$TimelineSyncStateTableTableManager(
        _db.attachedDatabase,
        _db.timelineSyncState,
      );
}
