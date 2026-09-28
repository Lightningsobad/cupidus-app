import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Schema v6 adds `notebook_entries`, `skill_profile_entries`, and
/// `ask_prompt_state` (`architecture/contract-summary.md` §4). All three are
/// device-authoritative, so the migration is `CREATE TABLE` only: the three
/// older client-owned tables must come through untouched.
///
/// The fixture is built by opening the current schema on a file and then
/// removing exactly the v6 additions, so the v5 shape tracks the real table
/// definitions instead of being retyped by hand.
///
/// The fixture also drops `calendar_event_state` (v7) and the two
/// chapter-closure ledger tables (v9), and lands the upgrade at v9, not v7:
/// three sibling stories (STORY-009's `calendar_event_state`, STORY-010's
/// `relationship_labels`, and STORY-013's chapter-closure tables) each added a
/// schema step after this one, so the "current" version moved from v6 to v9 as
/// they merged. `relationship_labels` already exists in this fixture (it
/// comes from the current schema the fixture is built on), so the v8 upgrade
/// step is a no-op `CREATE TABLE IF NOT EXISTS` here — it does not affect what
/// this file is testing.
void main() {
  Future<int> readUserVersion(CupidDatabase database) async {
    final row = await database.customSelect('PRAGMA user_version').getSingle();
    return row.read<int>('user_version');
  }

  Future<Set<String>> tableNames(CupidDatabase database) async {
    final rows = await database
        .customSelect("SELECT name FROM sqlite_master WHERE type = 'table'")
        .get();
    return rows.map((row) => row.read<String>('name')).toSet();
  }

  Future<Set<String>> columnNames(CupidDatabase database, String table) async {
    final rows =
        await database.customSelect("PRAGMA table_info('$table')").get();
    return rows.map((row) => row.read<String>('name')).toSet();
  }

  /// Seeds one row in each of the three pre-existing client-owned tables, then
  /// strips the v6 additions and rewinds `user_version`, leaving a database
  /// that looks exactly like one that stopped at v5.
  Future<void> seedV5(File file) async {
    final seeded = CupidDatabase(NativeDatabase(file));
    await seeded.activityCardDao.upsertCard(
      ActivityCardsCompanion.insert(
        id: 'card-old',
        ownerKey: 'user-1',
        title: 'Đi ăn lẩu',
        origin: 'manual',
        note: const Value('thẻ viết từ hồi v5'),
        createdAt: DateTime.utc(2026, 9, 1),
        updatedAt: DateTime.utc(2026, 9, 1),
      ),
    );
    await seeded.into(seeded.journalEntries).insert(
          JournalEntriesCompanion.insert(
            id: 'journal-old',
            ownerUserId: 'user-1',
            bodyText: 'Hôm nay trời đẹp',
            createdAt: 1757462400000,
            updatedAt: 1757462400000,
          ),
        );
    await seeded.into(seeded.inviteMessages).insert(
          InviteMessagesCompanion.insert(
            id: 'invite-old',
            cardId: 'card-old',
            categoryId: 'invite',
            presetId: 'invite.rap_phim.v1',
            packVersion: '1.0.0',
            filledValues: '{"activity":"Đi ăn lẩu"}',
            createdAt: 1757462400000,
          ),
        );
    for (final table in const <String>[
      'notebook_entries',
      'skill_profile_entries',
      'ask_prompt_state',
      'calendar_event_state',
      // Items first: it holds the cascading foreign key onto chapter_closures.
      'chapter_closure_items',
      'chapter_closures',
    ]) {
      await seeded.customStatement('DROP TABLE $table');
    }
    await seeded.customStatement('PRAGMA user_version = 5');
    await seeded.close();
  }

  /// Rewinds a current-schema database to v10 by dropping exactly the three
  /// v11 origin columns, after seeding one notebook row the way a device
  /// running v10 would hold it. Same idiom as [seedV5]: the fixture is derived
  /// from the real table definition rather than retyped by hand.
  Future<void> seedV10(File file) async {
    final seeded = CupidDatabase(NativeDatabase(file));
    await seeded.into(seeded.notebookEntries).insert(
          NotebookEntriesCompanion.insert(
            id: 'entry-from-v10',
            ownerKey: 'user-1',
            kind: 'event',
            value: 'Sinh nhật người ấy',
            source: 'manual',
            eventOn: const Value('2026-11-02'),
            createdAt: DateTime.utc(2026, 9, 20),
            updatedAt: DateTime.utc(2026, 9, 20),
          ),
        );
    for (final column in const <String>[
      'origin_check_in_ref',
      'origin_card_id',
      'origin_card_title',
    ]) {
      await seeded
          .customStatement('ALTER TABLE notebook_entries DROP COLUMN $column');
    }
    await seeded.customStatement('PRAGMA user_version = 10');
    await seeded.close();
  }

  late Directory tempDir;
  late File databaseFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cupid_db_migration_v6');
    databaseFile = File('${tempDir.path}${Platform.pathSeparator}cupid.sqlite');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('v5 -> v6', () {
    setUp(() async {
      await seedV5(databaseFile);
    });

    test(
        'lands on the current schema with the three context-notebook tables '
        'present', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      expect(await readUserVersion(upgraded), 11);
      expect(
        await tableNames(upgraded),
        containsAll(<String>[
          'notebook_entries',
          'skill_profile_entries',
          'ask_prompt_state',
        ]),
      );
    });

    test('every pre-existing client-owned row survives the upgrade intact',
        () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final cards = await upgraded.select(upgraded.activityCards).get();
      final journals = await upgraded.select(upgraded.journalEntries).get();
      final invites = await upgraded.select(upgraded.inviteMessages).get();

      expect(cards, hasLength(1));
      expect(cards.single.title, 'Đi ăn lẩu');
      expect(cards.single.note, 'thẻ viết từ hồi v5');
      expect(journals, hasLength(1));
      expect(journals.single.bodyText, 'Hôm nay trời đẹp');
      expect(invites, hasLength(1));
      expect(invites.single.presetId, 'invite.rap_phim.v1');
    });

    test('the new tables are writable right after the upgrade', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      await upgraded.into(upgraded.notebookEntries).insert(
            NotebookEntriesCompanion.insert(
              id: 'entry-1',
              ownerKey: 'user-1',
              kind: 'interest',
              value: 'Trà sữa',
              source: 'manual',
              createdAt: DateTime.utc(2026, 9, 10),
              updatedAt: DateTime.utc(2026, 9, 10),
            ),
          );

      final stored = await upgraded.select(upgraded.notebookEntries).get();

      expect(stored.single.value, 'Trà sữa');
    });
  });

  group('v10 -> v11 (REQ-017 origin columns)', () {
    setUp(() async {
      await seedV10(databaseFile);
    });

    test('adds the three origin columns with ADD COLUMN only', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      expect(await readUserVersion(upgraded), 11);
      expect(
        await columnNames(upgraded, 'notebook_entries'),
        containsAll(<String>[
          'origin_check_in_ref',
          'origin_card_id',
          'origin_card_title',
        ]),
      );
    });

    test('the pre-v11 row survives and reads back with all three columns null',
        () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final stored = (await upgraded.select(upgraded.notebookEntries).get())
          .singleWhere((row) => row.id == 'entry-from-v10');

      expect(stored.value, 'Sinh nhật người ấy');
      expect(stored.eventOn, '2026-11-02');
      expect(stored.originCheckInRef, isNull);
      expect(stored.originCardId, isNull);
      expect(stored.originCardTitle, isNull);
    });
  });

  group('v6 on a fresh install', () {
    test('onCreate emits all three tables without a migration', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      await fresh.select(fresh.notebookEntries).get();
      await fresh.select(fresh.skillProfileEntries).get();
      await fresh.select(fresh.askPromptState).get();

      expect(await readUserVersion(fresh), 11);
      expect(fresh.schemaVersion, 11);
    });

    test('ask_prompt_state is keyed by (owner_key, question_id)', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      final rows =
          await fresh.customSelect("PRAGMA table_info('ask_prompt_state')").get();
      final primaryKey = rows
          .where((row) => row.read<int>('pk') > 0)
          .map((row) => row.read<String>('name'))
          .toSet();

      expect(primaryKey, <String>{'owner_key', 'question_id'});
    });
  });

  group('cột bị cấm vĩnh viễn (R-1b / AC-12 / AC-25)', () {
    late CupidDatabase database;

    setUp(() {
      database = CupidDatabase(NativeDatabase(databaseFile));
    });

    tearDown(() async {
      await database.close();
    });

    test('skill_profile_entries carries no proficiency dimension (AC-12)',
        () async {
      final columns = await columnNames(database, 'skill_profile_entries');

      expect(columns, <String>{
        'id',
        'owner_key',
        'label',
        'seed_id',
        'source',
        'created_at',
        'updated_at',
      });
      for (final banned in const <String>[
        'level',
        'star',
        'stars',
        'score',
        'rank',
        'rating',
        'proficiency',
      ]) {
        expect(
          columns,
          isNot(contains(banned)),
          reason: 'AC-12 forbids grading a skill; "$banned" reintroduces it',
        );
      }
    });

    test('notebook_entries measures nothing about the partner (AC-25)',
        () async {
      final columns = await columnNames(database, 'notebook_entries');

      expect(columns, <String>{
        'id',
        'owner_key',
        'kind',
        'value',
        'detail',
        'event_on',
        'source',
        'question_id',
        'origin_check_in_ref',
        'origin_card_id',
        'origin_card_title',
        'created_at',
        'updated_at',
      });
      for (final prefix in const <String>[
        'partner_',
        'seen_',
        'reply_',
        'frequency_',
      ]) {
        expect(
          columns.where((column) => column.startsWith(prefix)),
          isEmpty,
          reason: 'AC-25 forbids partner-behavior columns ("$prefix*")',
        );
      }
    });

    test('ask_prompt_state has no counter column', () async {
      final columns = await columnNames(database, 'ask_prompt_state');

      expect(columns, <String>{
        'owner_key',
        'question_id',
        'state',
        'updated_at',
      });
    });
  });
}
