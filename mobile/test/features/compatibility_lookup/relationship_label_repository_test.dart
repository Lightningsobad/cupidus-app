import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/compatibility_lookup/data/relationship_label_repository.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Schema v8 adds `relationship_labels`
/// (`architecture/contract-summary.md` §4): the zodiac/MBTI labels the user
/// declares for themselves and for the other person. The table is
/// device-authoritative, so the migration is `CREATE TABLE` only and every
/// older table must come through untouched.
///
/// The v6 fixture is built by opening the current schema on a file and removing
/// exactly the v8 addition, so it tracks the real table definitions instead of
/// being retyped by hand.
///
/// Landing at v8, not v7: a sibling story (STORY-009) also added a schema step
/// (`calendar_event_state`/`portrait_answers`) at v7, so this story's own
/// addition renumbered to v8 when both merged into the integration branch.
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

  late Directory tempDir;
  late File databaseFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cupid_db_migration_v7');
    databaseFile = File('${tempDir.path}${Platform.pathSeparator}cupid.sqlite');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  RelationshipLabelRepository repositoryFor(
    CupidDatabase database, {
    String ownerKey = 'user-1',
    DateTime Function()? now,
    String Function()? newId,
  }) {
    var counter = 0;
    return RelationshipLabelRepository(
      dao: database.relationshipLabelsDao,
      ownerKeyStore:
          BackendUserIdStore(readPersistedUserId: () async => ownerKey),
      newId: newId ?? () => 'id-${++counter}',
      now: now ?? () => DateTime.utc(2026, 9, 12),
    );
  }

  group('migration v6 -> current', () {
    /// Seeds one row in each pre-existing client-owned table, then strips the
    /// v8 addition and rewinds `user_version`, leaving a database that looks
    /// exactly like one that stopped at v6.
    setUp(() async {
      final seeded = CupidDatabase(NativeDatabase(databaseFile));
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
      // A real v6 `notebook_entries` has no origin columns, and the v11 step
      // adds them with a plain `ADD COLUMN` that fails on one already there.
      for (final column in const <String>[
        'origin_check_in_ref',
        'origin_card_id',
        'origin_card_title',
      ]) {
        await seeded.customStatement(
          'ALTER TABLE notebook_entries DROP COLUMN $column',
        );
      }
      // Also the closure ledger: its upgrade step builds an index, and
      // `Migrator.createIndex` emits a plain `CREATE INDEX` that fails on one
      // the fixture left behind. Items first — it holds the cascading key.
      await seeded.customStatement('DROP TABLE chapter_closure_items');
      await seeded.customStatement('DROP TABLE chapter_closures');
      await seeded.customStatement('PRAGMA user_version = 6');
      await seeded.close();
    });

    test('lands on the current schema with relationship_labels present',
        () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      expect(await readUserVersion(upgraded), 11);
      expect(await tableNames(upgraded), contains('relationship_labels'));
    });

    test('every pre-existing client-owned row survives the upgrade intact',
        () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final cards = await upgraded.select(upgraded.activityCards).get();
      final entries = await upgraded.select(upgraded.notebookEntries).get();

      expect(cards, hasLength(1));
      expect(cards.single.title, 'Đi ăn lẩu');
      expect(cards.single.note, 'thẻ viết từ hồi v6');
      expect(entries, hasLength(1));
      expect(entries.single.value, 'Trà sữa');
    });

    test('the new table is writable right after the upgrade', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final saved = await repositoryFor(upgraded).saveLabel(
        subject: LabelSubject.partner,
        system: LabelSystem.zodiac,
        value: 'taurus',
        certainty: LabelCertainty.guess,
      );

      expect(saved.value, 'taurus');
    });
  });

  group('a fresh install', () {
    test('onCreate emits relationship_labels without a migration', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      await fresh.select(fresh.relationshipLabels).get();

      expect(await readUserVersion(fresh), 11);
      expect(fresh.schemaVersion, 11);
    });

    test('the natural key (owner_key, subject, system) is UNIQUE in the DDL',
        () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      final indexes = await fresh
          .customSelect("PRAGMA index_list('relationship_labels')")
          .get();
      final uniqueIndexes =
          indexes.where((row) => row.read<int>('unique') == 1).toList();

      final coveredColumns = <Set<String>>[];
      for (final index in uniqueIndexes) {
        final columns = await fresh
            .customSelect("PRAGMA index_info('${index.read<String>('name')}')")
            .get();
        coveredColumns.add(
          columns.map((row) => row.read<String>('name')).toSet(),
        );
      }

      expect(
        coveredColumns,
        anyElement(equals(<String>{'owner_key', 'subject', 'system'})),
      );
    });
  });

  group('repository', () {
    late CupidDatabase database;

    setUp(() {
      database = CupidDatabase(NativeDatabase(databaseFile));
    });

    tearDown(() async {
      await database.close();
    });

    test('a second declaration of the same label edits the one row (AC-9)',
        () async {
      var clock = DateTime.utc(2026, 9, 12, 8);
      final repository = repositoryFor(database, now: () => clock);

      final first = await repository.saveLabel(
        subject: LabelSubject.partner,
        system: LabelSystem.zodiac,
        value: 'aries',
        certainty: LabelCertainty.guess,
      );
      clock = DateTime.utc(2026, 9, 12, 9);
      final second = await repository.saveLabel(
        subject: LabelSubject.partner,
        system: LabelSystem.zodiac,
        value: 'taurus',
        certainty: LabelCertainty.known,
      );

      final rows = await database.select(database.relationshipLabels).get();

      expect(rows, hasLength(1));
      expect(second.value, 'taurus');
      expect(second.certainty, LabelCertainty.known);
      // Drift stores these as unix seconds and hands them back in local time,
      // so compare instants rather than DateTime objects.
      expect(second.updatedAt.toUtc(), DateTime.utc(2026, 9, 12, 9));
      // An edit keeps the row's identity: same id, original created_at. A new
      // id would turn a correction into a second label plus a history of what
      // the user used to think.
      expect(second.id, first.id);
      expect(second.createdAt.toUtc(), DateTime.utc(2026, 9, 12, 8));
    });

    test('the same value under a different subject or system is a second row',
        () async {
      final repository = repositoryFor(database);

      await repository.saveLabel(
        subject: LabelSubject.self,
        system: LabelSystem.zodiac,
        value: 'aries',
        certainty: LabelCertainty.known,
      );
      await repository.saveLabel(
        subject: LabelSubject.partner,
        system: LabelSystem.zodiac,
        value: 'aries',
        certainty: LabelCertainty.guess,
      );
      await repository.saveLabel(
        subject: LabelSubject.self,
        system: LabelSystem.mbti,
        value: 'intj',
        certainty: LabelCertainty.known,
      );

      expect(await repository.labels(), hasLength(3));
    });

    test('reading by owner returns the self/partner pair', () async {
      final repository = repositoryFor(database);

      await repository.saveLabel(
        subject: LabelSubject.self,
        system: LabelSystem.zodiac,
        value: 'aries',
        certainty: LabelCertainty.known,
      );
      await repository.saveLabel(
        subject: LabelSubject.partner,
        system: LabelSystem.zodiac,
        value: 'taurus',
        certainty: LabelCertainty.guess,
      );

      final self = await repository.label(
        subject: LabelSubject.self,
        system: LabelSystem.zodiac,
      );
      final partner = await repository.label(
        subject: LabelSubject.partner,
        system: LabelSystem.zodiac,
      );

      expect(self!.value, 'aries');
      expect(self.certainty, LabelCertainty.known);
      expect(partner!.value, 'taurus');
      expect(partner.certainty, LabelCertainty.guess);
    });

    test('an owner with no labels reads empty rather than failing', () async {
      final repository = repositoryFor(database);

      expect(await repository.labels(), isEmpty);
      expect(
        await repository.label(
          subject: LabelSubject.partner,
          system: LabelSystem.mbti,
        ),
        isNull,
      );
    });

    test('a second user on the same device sees none of the first user\'s '
        'labels', () async {
      await repositoryFor(database, ownerKey: 'user-1').saveLabel(
        subject: LabelSubject.partner,
        system: LabelSystem.zodiac,
        value: 'aries',
        certainty: LabelCertainty.guess,
      );

      final second = repositoryFor(database, ownerKey: 'user-2');

      expect(await second.labels(), isEmpty);
      expect(
        await second.label(
          subject: LabelSubject.partner,
          system: LabelSystem.zodiac,
        ),
        isNull,
      );
    });

    test('deleting a label leaves nothing behind', () async {
      final repository = repositoryFor(database);
      await repository.saveLabel(
        subject: LabelSubject.partner,
        system: LabelSystem.mbti,
        value: 'enfp',
        certainty: LabelCertainty.guess,
      );

      final removed = await repository.deleteLabel(
        subject: LabelSubject.partner,
        system: LabelSystem.mbti,
      );

      expect(removed, 1);
      expect(await repository.labels(), isEmpty);
    });

    test('a blank value is rejected rather than stored', () async {
      final repository = repositoryFor(database);

      expect(
        () => repository.saveLabel(
          subject: LabelSubject.self,
          system: LabelSystem.zodiac,
          value: '   ',
          certainty: LabelCertainty.known,
        ),
        throwsArgumentError,
      );
    });

    test('the repository is unusable before a backend user id resolves',
        () async {
      final repository = RelationshipLabelRepository(
        dao: database.relationshipLabelsDao,
        ownerKeyStore: BackendUserIdStore(),
      );

      expect(repository.labels(), throwsStateError);
    });
  });

  group('ranh giới lưu trữ (AC-30 / AC-31 / AC-33)', () {
    late CupidDatabase database;

    setUp(() {
      database = CupidDatabase(NativeDatabase(databaseFile));
    });

    tearDown(() async {
      await database.close();
    });

    test('relationship_labels carries exactly the contracted columns',
        () async {
      expect(await columnNames(database, 'relationship_labels'), <String>{
        'id',
        'owner_key',
        'subject',
        'system',
        'value',
        'certainty',
        'created_at',
        'updated_at',
      });
    });

    test('no column can hold a lookup result (AC-31)', () async {
      final columns = await columnNames(database, 'relationship_labels');

      for (final banned in const <String>[
        'band',
        'band_id',
        'fit',
        'friction',
        'activity',
        'question',
        'result',
        'match',
        'compat',
        'compatibility',
        'score',
        'rank',
        'rating',
        'level',
        'verdict',
      ]) {
        expect(
          columns.where((column) => column.contains(banned)),
          isEmpty,
          reason: 'AC-31 forbids storing a lookup result; "$banned" leaks it '
              'into the storage layer',
        );
      }
    });

    test('no column measures the other person (AC-30)', () async {
      final columns = await columnNames(database, 'relationship_labels');

      for (final prefix in const <String>[
        'partner_',
        'seen_',
        'reply_',
        'frequency_',
      ]) {
        expect(
          columns.where((column) => column.startsWith(prefix)),
          isEmpty,
          reason: 'AC-30 forbids partner-behaviour columns ("$prefix*")',
        );
      }
    });

    test('no column counts lookups (AC-33)', () async {
      final columns = await columnNames(database, 'relationship_labels');

      for (final banned in const <String>[
        'count',
        'streak',
        'times',
        'opened',
        'viewed',
        'last_seen',
      ]) {
        expect(
          columns.where((column) => column.contains(banned)),
          isEmpty,
          reason: 'AC-33 forbids lookup counters and streaks; "$banned" '
              'reintroduces one',
        );
      }
    });

    test('saving a label writes zero bytes to the notebook (AC-31)', () async {
      await repositoryFor(database).saveLabel(
        subject: LabelSubject.partner,
        system: LabelSystem.zodiac,
        value: 'taurus',
        certainty: LabelCertainty.guess,
      );

      expect(await database.select(database.notebookEntries).get(), isEmpty);
      expect(
        await database.select(database.skillProfileEntries).get(),
        isEmpty,
      );
    });

    test('notebook_entries.kind stays the closed interest|event enum '
        'STORY-004 owns', () async {
      // STORY-010 storing its labels in `notebook_entries` would have meant
      // widening this enum, which rewrites another story's contract (BR-10).
      // The check is here so a later shortcut into the notebook fails loudly.
      await database.into(database.notebookEntries).insert(
            NotebookEntriesCompanion.insert(
              id: 'entry-1',
              ownerKey: 'user-1',
              kind: 'interest',
              value: 'Trà sữa',
              source: 'manual',
              createdAt: DateTime.utc(2026, 9, 12),
              updatedAt: DateTime.utc(2026, 9, 12),
            ),
          );

      final kinds = (await database.select(database.notebookEntries).get())
          .map((row) => row.kind)
          .toSet();

      expect(kinds.difference(<String>{'interest', 'event'}), isEmpty);
    });
  });
}
