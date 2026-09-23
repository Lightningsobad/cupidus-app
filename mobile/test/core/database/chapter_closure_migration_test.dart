import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Schema v9 adds `chapter_closures` and `chapter_closure_items`
/// (`architecture/contract-summary.md` §1). Both are device-authoritative, so
/// the migration is `CREATE TABLE` only and every pre-existing client-owned row
/// must come through untouched.
///
/// The fixture is built by opening the current schema on a file and then
/// removing exactly the closure-ledger additions, so the pre-ledger shape
/// tracks the real table definitions instead of being retyped by hand.
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

  /// Seeds one row in each of the five client-owned tables that already existed
  /// at v6, then strips the v7 additions and rewinds `user_version`, leaving a
  /// database that looks exactly like one that stopped at v6.
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
            bodyText: 'Nhật ký riêng, không bao giờ bị đóng',
            createdAt: 1757462400000,
            updatedAt: 1757462400000,
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
    await seeded.into(seeded.skillProfileEntries).insert(
          SkillProfileEntriesCompanion.insert(
            id: 'skill-old',
            ownerKey: 'user-1',
            label: 'Lắng nghe',
            source: 'manual',
            createdAt: DateTime.utc(2026, 9, 1),
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
        );
    await seeded.into(seeded.askPromptState).insert(
          AskPromptStateCompanion.insert(
            ownerKey: 'user-1',
            questionId: 'q-1',
            state: 'answered',
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
        );
    // Items first: it holds the cascading foreign key onto chapter_closures.
    // Dropping a table also drops its indexes, so the v7 index needs no
    // separate statement here.
    await seeded.customStatement('DROP TABLE chapter_closure_items');
    await seeded.customStatement('DROP TABLE chapter_closures');
    await seeded.customStatement('PRAGMA user_version = 6');
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

  group('pre-ledger -> current', () {
    setUp(() async {
      await seedV6(databaseFile);
    });

    test('lands on the current schema with both closure-ledger tables present',
        () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      expect(await readUserVersion(upgraded), 10);
      expect(
        await tableNames(upgraded),
        containsAll(<String>['chapter_closures', 'chapter_closure_items']),
      );
    });

    test('every pre-existing client-owned row survives the upgrade intact',
        () async {
      final beforeUpgrade = CupidDatabase(NativeDatabase(databaseFile));
      final countsBefore = <String, int>{};
      for (final table in const <String>[
        'activity_cards',
        'notebook_entries',
        'skill_profile_entries',
        'ask_prompt_state',
        'journal_entries',
      ]) {
        countsBefore[table] = await beforeUpgrade
            .customSelect('SELECT COUNT(*) AS c FROM $table')
            .map((row) => row.read<int>('c'))
            .getSingle();
      }
      await beforeUpgrade.close();

      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);
      final countsAfter = <String, int>{};
      for (final table in countsBefore.keys) {
        countsAfter[table] = await upgraded
            .customSelect('SELECT COUNT(*) AS c FROM $table')
            .map((row) => row.read<int>('c'))
            .getSingle();
      }

      expect(countsBefore, <String, int>{
        'activity_cards': 1,
        'notebook_entries': 1,
        'skill_profile_entries': 1,
        'ask_prompt_state': 1,
        'journal_entries': 1,
      });
      expect(countsAfter, countsBefore);

      final cards = await upgraded.select(upgraded.activityCards).get();
      final entries = await upgraded.select(upgraded.notebookEntries).get();
      final journals = await upgraded.select(upgraded.journalEntries).get();
      expect(cards.single.title, 'Đi ăn lẩu');
      expect(cards.single.note, 'thẻ viết từ hồi v6');
      expect(entries.single.value, 'Trà sữa');
      expect(journals.single.bodyText, 'Nhật ký riêng, không bao giờ bị đóng');
    });

    test('the ledger is writable right after the upgrade', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      await upgraded.chapterClosureDao.createClosure(
        id: 'closure-1',
        ownerKey: 'user-1',
        closedAt: DateTime.utc(2026, 9, 11),
        itemIdsByKind: const <String, Set<String>>{
          'activity_card': <String>{'card-old'},
        },
      );

      expect(
        await upgraded.chapterClosureDao.closedItemIds('activity_card'),
        <String>{'card-old'},
      );
    });
  });

  group('a fresh install', () {
    test('onCreate emits both tables without a migration', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      await fresh.select(fresh.chapterClosures).get();
      await fresh.select(fresh.chapterClosureItems).get();

      expect(await readUserVersion(fresh), 10);
      expect(fresh.schemaVersion, 10);
    });

    test('chapter_closure_items is keyed by (closure_id, item_kind, item_id)',
        () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      final rows = await fresh
          .customSelect("PRAGMA table_info('chapter_closure_items')")
          .get();
      final primaryKey = rows
          .where((row) => row.read<int>('pk') > 0)
          .map((row) => row.read<String>('name'))
          .toSet();

      expect(primaryKey, <String>{'closure_id', 'item_kind', 'item_id'});
    });

    test('the (item_kind, item_id) index exists, so a card page is not a table '
        'scan', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      final rows = await fresh
          .customSelect("PRAGMA index_list('chapter_closure_items')")
          .get();
      final indexNames =
          rows.map((row) => row.read<String>('name')).toSet();

      expect(indexNames, contains('chapter_closure_items_kind_item'));

      final columns = await fresh
          .customSelect(
              "PRAGMA index_info('chapter_closure_items_kind_item')")
          .get();
      expect(
        columns.map((row) => row.read<String>('name')).toList(),
        <String>['item_kind', 'item_id'],
      );
    });

    test('deleting a closure cascades its items away (AC-17)', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      for (final id in const <String>['closure-a', 'closure-b']) {
        await fresh.chapterClosureDao.createClosure(
          id: id,
          ownerKey: 'user-1',
          closedAt: DateTime.utc(2026, 9, 11),
          itemIdsByKind: <String, Set<String>>{
            'activity_card': <String>{'card-$id'},
            'notebook_entry': <String>{'entry-$id'},
          },
        );
      }

      await fresh.chapterClosureDao.deleteClosure('closure-a');
      final remaining = await fresh.select(fresh.chapterClosureItems).get();

      expect(
        remaining.map((row) => row.closureId).toSet(),
        <String>{'closure-b'},
      );
      expect(remaining, hasLength(2));
    });

    test('an item cannot reference a closure that does not exist', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      await expectLater(
        fresh.into(fresh.chapterClosureItems).insert(
              ChapterClosureItemsCompanion.insert(
                closureId: 'closure-missing',
                itemKind: 'activity_card',
                itemId: 'card-1',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('cột bị cấm vĩnh viễn (AC-5 / BR-9 / BR-7)', () {
    late CupidDatabase database;

    setUp(() {
      database = CupidDatabase(NativeDatabase(databaseFile));
    });

    tearDown(() async {
      await database.close();
    });

    /// AC-5 forbids storing *why* a chapter was closed or any judgement about
    /// the other person; BR-7 forbids a reopen history.
    const bannedExactColumns = <String>[
      'reason',
      'label',
      'note',
      'sentiment',
      'reopened_at',
    ];
    const bannedPrefixes = <String>['person'];
    const bannedSubstrings = <String>['count'];

    void expectNoBannedColumn(Set<String> columns, String table) {
      for (final banned in bannedExactColumns) {
        expect(
          columns,
          isNot(contains(banned)),
          reason: 'AC-5/BR-9 forbid "$banned" on $table',
        );
      }
      for (final prefix in bannedPrefixes) {
        expect(
          columns.where((column) => column.startsWith(prefix)),
          isEmpty,
          reason: 'AC-5/BR-9 forbid "$prefix*" columns on $table',
        );
      }
      for (final fragment in bannedSubstrings) {
        expect(
          columns.where((column) => column.contains(fragment)),
          isEmpty,
          reason: 'BR-7 forbids "*$fragment*" columns on $table',
        );
      }
    }

    test('chapter_closures carries nothing beyond id/owner/closed_at', () async {
      final columns = await columnNames(database, 'chapter_closures');

      expect(columns, <String>{'id', 'owner_key', 'closed_at'});
      expectNoBannedColumn(columns, 'chapter_closures');
    });

    test('chapter_closure_items carries no judgement about the other person',
        () async {
      final columns = await columnNames(database, 'chapter_closure_items');

      expect(columns, <String>{'closure_id', 'item_kind', 'item_id'});
      expectNoBannedColumn(columns, 'chapter_closure_items');
    });
  });
}
