import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Schema v10 adds `thank_you_activations` (`architecture/solution.md` §4).
/// The table is device-authoritative, so the migration is `CREATE TABLE` only
/// and every pre-existing client-owned row must come through untouched.
///
/// The v9 fixture is built by opening the current schema on a file and then
/// removing exactly the v10 addition, so it tracks the real table definitions
/// instead of being retyped by hand.
void main() {
  Future<int> readUserVersion(CupidDatabase database) async {
    final row = await database.customSelect('PRAGMA user_version').getSingle();
    return row.read<int>('user_version');
  }

  Future<Set<String>> columnNames(CupidDatabase database, String table) async {
    final rows =
        await database.customSelect("PRAGMA table_info('$table')").get();
    return rows.map((row) => row.read<String>('name')).toSet();
  }

  Future<void> seedV9(File file) async {
    final seeded = CupidDatabase(NativeDatabase(file));
    await seeded.into(seeded.activityCards).insert(
          ActivityCardsCompanion.insert(
            id: 'card-old',
            ownerKey: 'user-1',
            title: 'Đi ăn lẩu',
            origin: 'manual',
            note: const Value('thẻ viết từ hồi v9'),
            createdAt: DateTime.utc(2026, 9, 1),
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
        );
    await seeded.customStatement('DROP TABLE thank_you_activations');
    await seeded.customStatement('PRAGMA user_version = 9');
    await seeded.close();
  }

  late Directory tempDir;
  late File databaseFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cupid_db_migration_v10');
    databaseFile = File('${tempDir.path}${Platform.pathSeparator}cupid.sqlite');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  group('v9 -> v10', () {
    setUp(() async {
      await seedV9(databaseFile);
    });

    test('lands on v10 with the activation ledger present', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      expect(await readUserVersion(upgraded), 10);
      expect(await upgraded.select(upgraded.thankYouActivations).get(), isEmpty);
    });

    test('the pre-existing client-owned card survives the upgrade intact',
        () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final cards = await upgraded.select(upgraded.activityCards).get();
      expect(cards.single.title, 'Đi ăn lẩu');
      expect(cards.single.note, 'thẻ viết từ hồi v9');
    });

    test('the ledger is writable right after the upgrade', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      await upgraded.into(upgraded.thankYouActivations).insert(
            ThankYouActivationsCompanion.insert(
              cardId: 'card-old',
              status: 'armed',
              armedOn: '2026-09-20',
            ),
          );

      final rows = await upgraded.select(upgraded.thankYouActivations).get();
      expect(rows.single.cardId, 'card-old');
    });
  });

  group('v10 on a fresh install', () {
    test('onCreate emits the table without a migration', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      await fresh.select(fresh.thankYouActivations).get();

      expect(await readUserVersion(fresh), 10);
      expect(fresh.schemaVersion, 10);
    });

    test('thank_you_activations is keyed by card_id, so a card can never hold '
        'two turns (BR-2)', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      final rows = await fresh
          .customSelect("PRAGMA table_info('thank_you_activations')")
          .get();
      final primaryKey = rows
          .where((row) => row.read<int>('pk') > 0)
          .map((row) => row.read<String>('name'))
          .toSet();

      expect(primaryKey, <String>{'card_id'});
    });

    test('deleting a card cascades its activation away', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      await fresh.into(fresh.activityCards).insert(
            ActivityCardsCompanion.insert(
              id: 'card-1',
              ownerKey: 'user-1',
              title: 'Đi xem phim',
              origin: 'manual',
              createdAt: DateTime.utc(2026, 9, 1),
              updatedAt: DateTime.utc(2026, 9, 1),
            ),
          );
      await fresh.into(fresh.thankYouActivations).insert(
            ThankYouActivationsCompanion.insert(
              cardId: 'card-1',
              status: 'armed',
              armedOn: '2026-09-20',
            ),
          );

      await (fresh.delete(fresh.activityCards)
            ..where((row) => row.id.equals('card-1')))
          .go();

      expect(await fresh.select(fresh.thankYouActivations).get(), isEmpty);
    });

    test('an activation cannot reference a card that does not exist', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      await expectLater(
        fresh.into(fresh.thankYouActivations).insert(
              ThankYouActivationsCompanion.insert(
                cardId: 'card-missing',
                status: 'armed',
                armedOn: '2026-09-20',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('cột bị cấm vĩnh viễn (AC-25 / BR-3)', () {
    test('thank_you_activations carries nothing that can become a shortfall',
        () async {
      final database = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(database.close);

      final columns = await columnNames(database, 'thank_you_activations');

      expect(
        columns,
        <String>{'card_id', 'status', 'armed_on', 'consumed_at'},
      );
      for (final banned in const <String>[
        'missed',
        'skipped',
        'streak',
        'badge',
        'expires_at',
        'reminder_at',
      ]) {
        expect(
          columns,
          isNot(contains(banned)),
          reason: 'AC-25/BR-3 forbid "$banned" on thank_you_activations',
        );
      }
      expect(
        columns.where((column) => column.contains('count')),
        isEmpty,
        reason: 'AC-25 forbids "*count*" columns on thank_you_activations',
      );
    });
  });
}
