import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Schema v7 adds `relationship_labels` (`architecture/contract-summary.md` §4).
/// The table is device-authoritative, so the upgrade path is the only thing
/// standing between a user who installed v6 and the labels feature; the
/// `onCreate` path exercised by the repository tests proves nothing about it.
///
/// The v6 fixture is built by opening the current schema on a file and then
/// dropping exactly the v7 addition, so the v6 shape tracks the real table
/// definitions instead of being retyped by hand. Dropping matters: drift emits
/// `CREATE TABLE IF NOT EXISTS`, so a fixture that leaves the table in place
/// passes whether or not `onUpgrade` ever runs the step.
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

  /// Seeds one row in each family of client-owned tables that existed at v6,
  /// then strips the v7 addition and rewinds `user_version`, leaving a database
  /// that looks exactly like one that stopped at v6.
  Future<void> seedV6(File file) async {
    final seeded = CupidDatabase(NativeDatabase(file));
    await seeded.activityCardDao.upsertCard(
      ActivityCardsCompanion.insert(
        id: 'card-old',
        ownerKey: 'user-1',
        title: 'Đi ăn lẩu',
        origin: 'manual',
        note: const Value('thẻ viết từ hồi v6'),
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
    await seeded.into(seeded.notebookEntries).insert(
          NotebookEntriesCompanion.insert(
            id: 'entry-old',
            ownerKey: 'user-1',
            kind: 'interest',
            value: 'Trà sữa',
            source: 'manual',
            createdAt: DateTime.utc(2026, 9, 1),
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
        );
    await seeded.customStatement('DROP TABLE relationship_labels');
    await seeded.customStatement('PRAGMA user_version = 6');

    // Asserted on the seeding connection, before it closes: reopening the file
    // to check would run the migration under test and the fixture would look
    // correct no matter what happened here.
    expect(await tableNames(seeded), isNot(contains('relationship_labels')));
    expect(await readUserVersion(seeded), 6);

    await seeded.close();
  }

  late Directory tempDir;
  late File databaseFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cupid_db_migration_v7');
    databaseFile = File('${tempDir.path}${Platform.pathSeparator}cupid.sqlite');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('v6 -> v7', () {
    setUp(() async {
      await seedV6(databaseFile);
    });

    test('lands on v7 with relationship_labels present', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      expect(await readUserVersion(upgraded), 7);
      expect(
        await tableNames(upgraded),
        containsAll(<String>[
          'relationship_labels',
          'notebook_entries',
          'skill_profile_entries',
          'ask_prompt_state',
          'invite_messages',
          'activity_cards',
          'journal_entries',
        ]),
      );
    });

    test('the migrated table carries the full v7 column set', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      expect(
        await columnNames(upgraded, 'relationship_labels'),
        <String>{
          'id',
          'owner_key',
          'subject',
          'system',
          'value',
          'certainty',
          'created_at',
          'updated_at',
        },
      );
    });

    test('every pre-existing client-owned row survives the upgrade intact',
        () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final cards = await upgraded.select(upgraded.activityCards).get();
      final journals = await upgraded.select(upgraded.journalEntries).get();
      final invites = await upgraded.select(upgraded.inviteMessages).get();
      final notebook = await upgraded.select(upgraded.notebookEntries).get();

      expect(cards, hasLength(1));
      expect(cards.single.title, 'Đi ăn lẩu');
      expect(cards.single.note, 'thẻ viết từ hồi v6');
      expect(journals, hasLength(1));
      expect(journals.single.bodyText, 'Hôm nay trời đẹp');
      expect(invites, hasLength(1));
      expect(invites.single.presetId, 'invite.rap_phim.v1');
      expect(notebook, hasLength(1));
      expect(notebook.single.value, 'Trà sữa');
    });

    test('relationship_labels is writable right after the upgrade', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      await upgraded.into(upgraded.relationshipLabels).insert(
            RelationshipLabelsCompanion.insert(
              id: 'label-1',
              ownerKey: 'user-1',
              subject: 'self',
              system: 'zodiac',
              value: 'leo',
              certainty: 'known',
              createdAt: DateTime.utc(2026, 9, 10),
              updatedAt: DateTime.utc(2026, 9, 10),
            ),
          );

      final stored = await upgraded.select(upgraded.relationshipLabels).get();

      expect(stored.single.value, 'leo');
      expect(stored.single.certainty, 'known');
    });

    test('the (owner_key, subject, system) unique key survives the migration',
        () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      RelationshipLabelsCompanion label(String id, String value) =>
          RelationshipLabelsCompanion.insert(
            id: id,
            ownerKey: 'user-1',
            subject: 'partner',
            system: 'mbti',
            value: value,
            certainty: 'guess',
            createdAt: DateTime.utc(2026, 9, 10),
            updatedAt: DateTime.utc(2026, 9, 10),
          );

      await upgraded.into(upgraded.relationshipLabels).insert(
            label('label-a', 'infp'),
          );

      await expectLater(
        upgraded.into(upgraded.relationshipLabels).insert(
              label('label-b', 'entj'),
            ),
        throwsA(isA<SqliteException>()),
      );
    });
  });
}
