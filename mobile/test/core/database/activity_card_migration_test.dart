import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migration v2 -> v3 must be purely additive: `activity_cards` holds
/// client-owned originals with no server copy, so the drop-and-recreate that is
/// legitimate for the cache tables (ADR-007/ADR-015.6) would destroy user data
/// here (`architecture/solution.md` §1 Key Discovery).
///
/// The v2 fixture is produced by opening the current schema on a file and then
/// removing exactly the v3 additions, so the older shape stays in step with the
/// real v1/v2 table definitions instead of being retyped by hand.
void main() {
  late Directory tempDir;
  late File databaseFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cupid_db_migration');
    databaseFile = File('${tempDir.path}${Platform.pathSeparator}cupid.sqlite');

    final seeded = CupidDatabase(NativeDatabase(databaseFile));
    await seeded.customStatement('DROP INDEX activity_cards_owner_status');
    await seeded.customStatement('DROP TABLE activity_card_photos');
    await seeded.customStatement('DROP TABLE activity_cards');

    await seeded.into(seeded.expenses).insert(
          ExpenseCacheRow(
            id: 'exp-1',
            userId: 'user-1',
            category: 'food',
            amount: 150000,
            description: 'cache row written under v2',
            date: DateTime.utc(2026, 8, 1),
            createdAt: DateTime.utc(2026, 8, 1),
          ),
        );
    await seeded.into(seeded.timelineEntries).insert(
          TimelineEntry(
            id: 'tl-1',
            type: 'moment',
            title: 'cache row written under v1',
            createdAt: DateTime.utc(2026, 8, 1),
          ),
        );

    await seeded.customStatement('PRAGMA user_version = 2');
    await seeded.close();
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  Future<int> readUserVersion(CupidDatabase database) async {
    final row = await database.customSelect('PRAGMA user_version').getSingle();
    return row.read<int>('user_version');
  }

  test('a v2 database with cache data upgrades to v3 keeping that data',
      () async {
    final upgraded = CupidDatabase(NativeDatabase(databaseFile));
    addTearDown(upgraded.close);

    final expenses = await upgraded.select(upgraded.expenses).get();
    final timeline = await upgraded.select(upgraded.timelineEntries).get();

    expect(await readUserVersion(upgraded), 3);
    expect(expenses.single.description, 'cache row written under v2');
    expect(timeline.single.title, 'cache row written under v1');
  });

  test('the upgrade creates the activity card tables and the pane index',
      () async {
    final upgraded = CupidDatabase(NativeDatabase(databaseFile));
    addTearDown(upgraded.close);

    final created = await upgraded
        .customSelect(
          "SELECT name FROM sqlite_master "
          "WHERE name IN ('activity_cards', 'activity_card_photos', "
          "'activity_cards_owner_status')",
        )
        .get();

    expect(
      created.map((row) => row.read<String>('name')).toSet(),
      {'activity_cards', 'activity_card_photos', 'activity_cards_owner_status'},
    );
  });

  test('cards written after the upgrade survive a reopen', () async {
    final upgraded = CupidDatabase(NativeDatabase(databaseFile));
    final now = DateTime.utc(2026, 9, 7);
    await upgraded.activityCardDao.upsertCard(
      ActivityCardsCompanion.insert(
        id: 'card-1',
        ownerKey: 'user-1',
        title: 'Đi xem phim',
        origin: 'manual',
        createdAt: now,
        updatedAt: now,
      ),
    );
    await upgraded.close();

    final reopened = CupidDatabase(NativeDatabase(databaseFile));
    addTearDown(reopened.close);

    final cards = await reopened.activityCardDao.cardsByStatus(
      ownerKey: 'user-1',
      status: 'idea',
      limit: 10,
    );

    expect(cards.single.title, 'Đi xem phim');
  });
}
