import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Schema v5 adds `activity_cards.location` and the `invite_messages` table,
/// both additive: `activity_cards` is client-owned data with no server copy,
/// so a recreate would destroy the only copy that exists
/// (`architecture/solution.md` §1 Key Discovery 1).
///
/// The two upgrade paths are tested separately on purpose. A v4 machine takes
/// neither the `from < 3` create branch nor the `from < 4` B-1 branch, so it
/// is the group that a chained `else if (from < 4) ... else if (from < 5)`
/// would silently skip — and it is by far the largest population in the field.
///
/// Both fixtures are built by opening the current schema on a file and then
/// removing exactly the v5 additions, so the older shapes track the real table
/// definitions instead of being retyped by hand.
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

  Future<Set<String>> cardColumns(CupidDatabase database) async {
    final rows =
        await database.customSelect("PRAGMA table_info('activity_cards')").get();
    return rows.map((row) => row.read<String>('name')).toSet();
  }

  /// Writes a real card through the DAO, then strips the v5 additions and
  /// rewinds `user_version`, leaving a database that looks exactly like one
  /// that stopped at [version].
  Future<void> seedPreV5(File file, {required int version}) async {
    final seeded = CupidDatabase(NativeDatabase(file));
    await seeded.activityCardDao.upsertCard(
      ActivityCardsCompanion.insert(
        id: 'card-old',
        ownerKey: 'user-1',
        title: 'Đi ăn lẩu',
        origin: 'manual',
        note: Value('thẻ viết từ hồi v$version'),
        scheduledOn: const Value('2026-09-20'),
        priceVnd: const Value(250000),
        createdAt: DateTime.utc(2026, 9, 1),
        updatedAt: DateTime.utc(2026, 9, 1),
      ),
    );
    await seeded.customStatement('DROP TABLE invite_messages');
    await seeded
        .customStatement('ALTER TABLE activity_cards DROP COLUMN location');
    if (version < 4) {
      for (final column in const <String>[
        'duration_minutes',
        'time_of_day_slot',
        'note_keywords',
        'link_source_label',
        'link_saved_at',
      ]) {
        await seeded
            .customStatement('ALTER TABLE activity_cards DROP COLUMN $column');
      }
    }
    await seeded.customStatement('PRAGMA user_version = $version');
    await seeded.close();
  }

  late Directory tempDir;
  late File databaseFile;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('cupid_db_migration_v5');
    databaseFile = File('${tempDir.path}${Platform.pathSeparator}cupid.sqlite');
  });

  tearDown(() async {
    await tempDir.delete(recursive: true);
  });

  for (final from in const <int>[3, 4]) {
    group('v$from -> v5', () {
      setUp(() async {
        await seedPreV5(databaseFile, version: from);
      });

      test('lands on v5 with location and invite_messages present', () async {
        final upgraded = CupidDatabase(NativeDatabase(databaseFile));
        addTearDown(upgraded.close);

        expect(await readUserVersion(upgraded), 5);
        expect(await cardColumns(upgraded), contains('location'));
        expect(await tableNames(upgraded), contains('invite_messages'));
      });

      test('the pre-upgrade row survives intact, with location null', () async {
        final beforeUpgrade = CupidDatabase(NativeDatabase(databaseFile));
        final rowsBefore = await beforeUpgrade
            .customSelect('SELECT COUNT(*) AS c FROM activity_cards')
            .map((row) => row.read<int>('c'))
            .getSingle();
        await beforeUpgrade.close();

        final upgraded = CupidDatabase(NativeDatabase(databaseFile));
        addTearDown(upgraded.close);
        final cards = await upgraded.select(upgraded.activityCards).get();

        expect(rowsBefore, 1);
        expect(cards, hasLength(1));
        expect(cards.single.title, 'Đi ăn lẩu');
        expect(cards.single.note, 'thẻ viết từ hồi v$from');
        expect(cards.single.scheduledOn, '2026-09-20');
        expect(cards.single.priceVnd, 250000);
        expect(cards.single.location, isNull);
      });

      test('location round-trips through ActivityCardEdit after the upgrade',
          () async {
        final upgraded = CupidDatabase(NativeDatabase(databaseFile));
        addTearDown(upgraded.close);

        await upgraded.activityCardDao.updateCard(
          ownerKey: 'user-1',
          id: 'card-old',
          changes: const ActivityCardsCompanion(location: Value('Rạp CGV')),
        );
        final written = await upgraded.activityCardDao
            .cardById(ownerKey: 'user-1', id: 'card-old');

        // A full-snapshot edit writes `null` as a real NULL — clearing the
        // column, not "leave it alone".
        await upgraded.activityCardDao.updateCard(
          ownerKey: 'user-1',
          id: 'card-old',
          changes: const ActivityCardsCompanion(location: Value(null)),
        );
        final cleared = await upgraded.activityCardDao
            .cardById(ownerKey: 'user-1', id: 'card-old');

        expect(written!.location, 'Rạp CGV');
        expect(cleared!.location, isNull);
      });
    });
  }

  group('v5 on a fresh install', () {
    test('onCreate emits location and invite_messages without a migration',
        () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      await fresh.select(fresh.inviteMessages).get();

      expect(await readUserVersion(fresh), 5);
      expect(fresh.schemaVersion, 5);
      expect(await cardColumns(fresh), contains('location'));
      expect(await tableNames(fresh), contains('invite_messages'));
    });
  });

  group('invite_messages cascade (BR-2)', () {
    late CupidDatabase database;

    setUp(() async {
      database = CupidDatabase(NativeDatabase(databaseFile));
      for (final id in const <String>['card-a', 'card-b']) {
        await database.activityCardDao.upsertCard(
          ActivityCardsCompanion.insert(
            id: id,
            ownerKey: 'user-1',
            title: 'Xem phim $id',
            origin: 'manual',
            createdAt: DateTime.utc(2026, 9, 1),
            updatedAt: DateTime.utc(2026, 9, 1),
          ),
        );
        await database.into(database.inviteMessages).insert(
              InviteMessagesCompanion.insert(
                id: 'invite-$id',
                cardId: id,
                categoryId: 'invite',
                presetId: 'invite.rap_phim.v1',
                packVersion: '1.0.0',
                filledValues: '{"activity":"Xem phim"}',
                createdAt: 1757462400000,
              ),
            );
      }
    });

    tearDown(() async {
      await database.close();
    });

    test('deleting a card deletes only its own invites', () async {
      await database.activityCardDao.deleteCard(ownerKey: 'user-1', id: 'card-a');

      final remaining = await database.select(database.inviteMessages).get();

      expect(remaining.map((row) => row.id), <String>['invite-card-b']);
    });

    test('an invite cannot reference a card that does not exist', () async {
      await expectLater(
        database.into(database.inviteMessages).insert(
              InviteMessagesCompanion.insert(
                id: 'invite-orphan',
                cardId: 'card-missing',
                categoryId: 'invite',
                presetId: 'invite.rap_phim.v1',
                packVersion: '1.0.0',
                filledValues: '{}',
                createdAt: 1757462400000,
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });
}
