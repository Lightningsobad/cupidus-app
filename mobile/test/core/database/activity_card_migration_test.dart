import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Migrations onto `activity_cards` must be purely additive: it holds
/// client-owned originals with no server copy, so the drop-and-recreate that is
/// legitimate for the cache tables (ADR-007/ADR-015.6) would destroy user data
/// here (`architecture/solution.md` §1 Key Discovery).
///
/// Both fixtures are produced by opening the current schema on a file and then
/// removing exactly the later additions, so the older shapes stay in step with
/// the real table definitions instead of being retyped by hand.
void main() {
  Future<int> readUserVersion(CupidDatabase database) async {
    final row = await database.customSelect('PRAGMA user_version').getSingle();
    return row.read<int>('user_version');
  }

  group('v2 -> current', () {
    late Directory tempDir;
    late File databaseFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cupid_db_migration_v2');
      databaseFile =
          File('${tempDir.path}${Platform.pathSeparator}cupid.sqlite');

      final seeded = CupidDatabase(NativeDatabase(databaseFile));
      await seeded.customStatement('DROP TABLE invite_messages');
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

    test('a v2 database with cache data upgrades keeping that data', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final expenses = await upgraded.select(upgraded.expenses).get();
      final timeline = await upgraded.select(upgraded.timelineEntries).get();

      expect(await readUserVersion(upgraded), 8);
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
        {
          'activity_cards',
          'activity_card_photos',
          'activity_cards_owner_status',
        },
      );
    });

    test('a v2 machine lands on the full v5 column set in one open', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final columns = await upgraded
          .customSelect("PRAGMA table_info('activity_cards')")
          .get();

      expect(
        columns.map((row) => row.read<String>('name')).toSet(),
        containsAll(<String>[
          'duration_minutes',
          'time_of_day_slot',
          'note_keywords',
          'link_source_label',
          'link_saved_at',
          'location',
        ]),
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
  });

  group('v3 -> current (ruling B-1: five additive columns)', () {
    late Directory tempDir;
    late File databaseFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('cupid_db_migration_v3');
      databaseFile =
          File('${tempDir.path}${Platform.pathSeparator}cupid.sqlite');

      final seeded = CupidDatabase(NativeDatabase(databaseFile));
      // A card the user created while the app was still on v3. Written before
      // the columns are removed, so it is a genuine pre-existing row.
      await seeded.activityCardDao.upsertCard(
        ActivityCardsCompanion.insert(
          id: 'card-v3',
          ownerKey: 'user-1',
          title: 'Đi ăn lẩu',
          origin: 'manual',
          note: const Value('thẻ viết từ hồi v3'),
          scheduledOn: const Value('2026-09-20'),
          priceVnd: const Value(250000),
          createdAt: DateTime.utc(2026, 9, 1),
          updatedAt: DateTime.utc(2026, 9, 1),
        ),
      );
      for (final column in const <String>[
        'duration_minutes',
        'time_of_day_slot',
        'note_keywords',
        'link_source_label',
        'link_saved_at',
        'location',
      ]) {
        await seeded
            .customStatement('ALTER TABLE activity_cards DROP COLUMN $column');
      }
      await seeded.customStatement('DROP TABLE invite_messages');
      await seeded.customStatement('PRAGMA user_version = 3');
      await seeded.close();
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test('the upgrade adds the five B-1 columns and nothing else beyond v5',
        () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final columns = await upgraded
          .customSelect("PRAGMA table_info('activity_cards')")
          .get();
      final names = columns.map((row) => row.read<String>('name')).toSet();

      expect(await readUserVersion(upgraded), 8);
      expect(
        names,
        containsAll(<String>[
          'duration_minutes',
          'time_of_day_slot',
          'note_keywords',
          'link_source_label',
          'link_saved_at',
        ]),
      );
      expect(names, hasLength(23));
    });

    test('the row written under v3 is still there, unchanged', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final card = await upgraded.activityCardDao.cardById(
        ownerKey: 'user-1',
        id: 'card-v3',
      );

      expect(card, isNotNull);
      expect(card!.title, 'Đi ăn lẩu');
      expect(card.note, 'thẻ viết từ hồi v3');
      expect(card.scheduledOn, '2026-09-20');
      expect(card.priceVnd, 250000);
      expect(card.status, 'idea');
      // Drift stores this as unix seconds and reads it back in local time, so
      // the instant is what survives the upgrade, not the DateTime's zone.
      expect(
        card.createdAt.toUtc(),
        DateTime.utc(2026, 9, 1),
      );
    });

    test('the five new fields of that row read back as null', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final card = await upgraded.activityCardDao.cardById(
        ownerKey: 'user-1',
        id: 'card-v3',
      );

      expect(card!.durationMinutes, isNull);
      expect(card.timeOfDaySlot, isNull);
      expect(card.noteKeywords, isNull);
      expect(card.linkSourceLabel, isNull);
      expect(card.linkSavedAt, isNull);
    });
  });
}
