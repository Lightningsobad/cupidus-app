import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Rebuilds a real on-disk v2 database (messages + timeline + expenses only,
/// with `user_version` rewound) so the next open exercises the actual
/// `onUpgrade(from: 2)` path rather than a hand-written DDL approximation.
///
/// `onCreate` always emits the *current* schema, so every table introduced
/// after v2 has to be dropped again here — otherwise the `from < 3` branch
/// re-creates tables that already exist.
Future<void> seedV2Database(File file) async {
  final database = CupidDatabase(NativeDatabase(file));

  await database.timelineDao.replaceFirstPage([
    TimelineEntry(
      id: 'tl-1',
      type: 'memory',
      title: 'chuyến đi Đà Lạt',
      description: 'v2 row that must survive the upgrade',
      createdAt: DateTime.utc(2026, 6, 1),
    ),
  ]);
  await database.expenseDao.upsertAll([
    ExpenseCacheRow(
      id: 'exp-1',
      userId: 'user-a',
      category: 'food',
      amount: 120000,
      description: 'v2 row that must survive the upgrade',
      date: DateTime.utc(2026, 6, 2),
      createdAt: DateTime.utc(2026, 6, 2),
    ),
  ]);

  await database.customStatement('DROP TABLE journal_photos');
  await database.customStatement('DROP TABLE journal_entries');
  // Before activity_cards: it holds the cascading foreign key onto it.
  await database.customStatement('DROP TABLE invite_messages');
  await database
      .customStatement('DROP INDEX IF EXISTS activity_cards_owner_status');
  await database.customStatement('DROP TABLE activity_card_photos');
  await database.customStatement('DROP TABLE activity_cards');
  await database.customStatement('PRAGMA user_version = 2');
  await database.close();
}

void main() {
  late Directory tempDir;
  late File file;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cupid_migration_v3');
    file = File('${tempDir.path}${Platform.pathSeparator}cupid.sqlite');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  test('upgrading from v2 creates the journal and activity-card tables',
      () async {
    await seedV2Database(file);

    final upgraded = CupidDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    await upgraded.select(upgraded.journalEntries).get();
    await upgraded.select(upgraded.journalPhotos).get();
    await upgraded.select(upgraded.activityCards).get();
    await upgraded.select(upgraded.activityCardPhotos).get();

    final version = await upgraded
        .customSelect('PRAGMA user_version')
        .map((row) => row.read<int>('user_version'))
        .getSingle();
    expect(version, upgraded.schemaVersion);
  });

  test('v2 rows are still intact after the upgrade (additive migration only)',
      () async {
    await seedV2Database(file);

    final upgraded = CupidDatabase(NativeDatabase(file));
    addTearDown(upgraded.close);

    final timeline = await upgraded.select(upgraded.timelineEntries).get();
    expect(timeline.map((row) => row.id), ['tl-1']);
    expect(timeline.single.title, 'chuyến đi Đà Lạt');

    final expenses = await upgraded.select(upgraded.expenses).get();
    expect(expenses.map((row) => row.id), ['exp-1']);
    expect(expenses.single.amount, 120000);
  });

  test('journal rows written after the upgrade round-trip on the same file',
      () async {
    await seedV2Database(file);

    final upgraded = CupidDatabase(NativeDatabase(file));
    await upgraded.journalDao.upsertEntry(
      'user-a',
      JournalEntry(
        id: 'e-1',
        ownerUserId: 'user-a',
        bodyText: 'mục đầu tiên sau khi nâng cấp',
        createdAt: 1000,
        updatedAt: 1000,
        origin: 'manual',
        originRef: null,
      ),
    );
    await upgraded.close();

    final reopened = CupidDatabase(NativeDatabase(file));
    addTearDown(reopened.close);

    final entry = await reopened.journalDao.entryById('user-a', 'e-1');
    expect(entry, isNotNull);
    expect(entry!.bodyText, 'mục đầu tiên sau khi nâng cấp');
  });

  test('a fresh database creates every table without a migration', () async {
    final fresh = CupidDatabase(NativeDatabase(file));
    addTearDown(fresh.close);

    await fresh.select(fresh.journalEntries).get();
    await fresh.select(fresh.journalPhotos).get();
    await fresh.select(fresh.activityCards).get();
    await fresh.select(fresh.activityCardPhotos).get();
    await fresh.select(fresh.expenses).get();
    await fresh.select(fresh.timelineEntries).get();
    await fresh.select(fresh.messages).get();

    final version = await fresh
        .customSelect('PRAGMA user_version')
        .map((row) => row.read<int>('user_version'))
        .getSingle();
    expect(version, fresh.schemaVersion);
  });
}
