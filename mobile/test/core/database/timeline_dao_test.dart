import 'package:cupid_mobile/core/auth/cupid_session.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/timeline_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

TimelineEntry _entry({
  required String id,
  required DateTime createdAt,
  String title = 'A memory',
}) =>
    TimelineEntry(
      id: id,
      type: 'memory',
      title: title,
      description: null,
      photoUrl: null,
      icon: null,
      createdAt: createdAt,
    );

void main() {
  late CupidDatabase database;
  late TimelineDao dao;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    dao = database.timelineDao;
  });

  tearDown(() async {
    await database.close();
  });

  test('opens at the current schema version with both tables present',
      () async {
    expect(database.schemaVersion, 3);
    await database.select(database.timelineEntries).get();
    await database.select(database.timelineSyncState).get();
  });

  test('is registered as a SessionScopedStore', () {
    expect(dao, isA<SessionScopedStore>());
  });

  test('watchFirstPage emits on replaceFirstPage and orders newest-first',
      () async {
    final emissions = <List<TimelineEntry>>[];
    final subscription = dao.watchFirstPage().listen(emissions.add);
    addTearDown(subscription.cancel);

    await dao.replaceFirstPage([
      _entry(id: 'a', createdAt: DateTime.utc(2026, 1, 1)),
      _entry(id: 'b', createdAt: DateTime.utc(2026, 1, 3)),
      _entry(id: 'c', createdAt: DateTime.utc(2026, 1, 2)),
    ]);
    await pumpEventQueue();

    expect(emissions, isNotEmpty);
    expect(emissions.last.map((e) => e.id), ['b', 'c', 'a']);
  });

  test(
      'replaceFirstPage is atomic: a mid-write failure leaves previous rows '
      'intact', () async {
    await dao.replaceFirstPage([
      _entry(id: 'a', createdAt: DateTime.utc(2026, 1, 1)),
    ]);

    await expectLater(
      dao.replaceFirstPage([
        _entry(id: 'dup', createdAt: DateTime.utc(2026, 1, 2)),
        _entry(id: 'dup', createdAt: DateTime.utc(2026, 1, 2)),
      ]),
      throwsA(anything),
    );

    final rows = await database.select(database.timelineEntries).get();
    expect(rows.map((e) => e.id), ['a']);
  });

  test('lastSyncedAt is null before the first replaceFirstPage and set after',
      () async {
    expect(await dao.lastSyncedAt(), isNull);

    await dao.replaceFirstPage([
      _entry(id: 'a', createdAt: DateTime.utc(2026, 1, 1)),
    ]);

    expect(await dao.lastSyncedAt(), isNotNull);
  });

  test('clearOnSignOut empties both tables', () async {
    await dao.replaceFirstPage([
      _entry(id: 'a', createdAt: DateTime.utc(2026, 1, 1)),
    ]);
    expect(await dao.lastSyncedAt(), isNotNull);

    await dao.clearOnSignOut();

    expect(await database.select(database.timelineEntries).get(), isEmpty);
    expect(await dao.lastSyncedAt(), isNull);
  });
}
