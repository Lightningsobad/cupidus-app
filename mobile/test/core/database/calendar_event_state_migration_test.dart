import 'dart:io';

import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Schema v7 adds `calendar_event_state` and nothing else
/// (`coding-plan/phase-P2-calendar-event-state-drift.md`). The table is
/// device-authoritative, so the migration is `CREATE TABLE` only: every
/// client-owned table from v6 must come through untouched.
///
/// The fixture is built by opening the current schema on a file and then
/// removing exactly the v7 addition, so the v6 shape tracks the real table
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

  Future<Set<String>> columnNames(CupidDatabase database, String table) async {
    final rows =
        await database.customSelect("PRAGMA table_info('$table')").get();
    return rows.map((row) => row.read<String>('name')).toSet();
  }

  /// Seeds one row in each client-owned table that already existed at v6, then
  /// strips the v7 addition and rewinds `user_version`.
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
            createdAt: DateTime.utc(2026, 9, 10),
            updatedAt: DateTime.utc(2026, 9, 10),
          ),
        );
    await seeded.into(seeded.skillProfileEntries).insert(
          SkillProfileEntriesCompanion.insert(
            id: 'skill-old',
            ownerKey: 'user-1',
            label: 'Nấu ăn',
            source: 'manual',
            createdAt: DateTime.utc(2026, 9, 10),
            updatedAt: DateTime.utc(2026, 9, 10),
          ),
        );
    await seeded.customStatement('DROP TABLE calendar_event_state');
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

  group('v6 -> v7', () {
    setUp(() async {
      await seedV6(databaseFile);
    });

    test('lands on v7 with calendar_event_state present', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      expect(await readUserVersion(upgraded), 7);
      expect(await tableNames(upgraded), contains('calendar_event_state'));
    });

    test('every pre-existing client-owned row survives the upgrade intact',
        () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      final cards = await upgraded.select(upgraded.activityCards).get();
      final journals = await upgraded.select(upgraded.journalEntries).get();
      final invites = await upgraded.select(upgraded.inviteMessages).get();
      final entries = await upgraded.select(upgraded.notebookEntries).get();
      final skills = await upgraded.select(upgraded.skillProfileEntries).get();

      expect(cards, hasLength(1));
      expect(cards.single.title, 'Đi ăn lẩu');
      expect(cards.single.note, 'thẻ viết từ hồi v6');
      expect(journals, hasLength(1));
      expect(journals.single.bodyText, 'Hôm nay trời đẹp');
      expect(invites, hasLength(1));
      expect(invites.single.presetId, 'invite.rap_phim.v1');
      expect(entries, hasLength(1));
      expect(entries.single.value, 'Trà sữa');
      expect(skills, hasLength(1));
      expect(skills.single.label, 'Nấu ăn');
    });

    test('the new table is writable right after the upgrade', () async {
      final upgraded = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(upgraded.close);

      await upgraded.into(upgraded.calendarEventState).insert(
            CalendarEventStateCompanion.insert(
              ownerKey: 'user-1',
              eventId: 'req016.event.tet',
              state: 'converted',
              updatedAt: DateTime.utc(2026, 9, 11),
            ),
          );

      final stored = await upgraded.select(upgraded.calendarEventState).get();

      expect(stored.single.eventId, 'req016.event.tet');
    });
  });

  group('v7 on a fresh install', () {
    test('onCreate emits calendar_event_state without a migration', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      await fresh.select(fresh.calendarEventState).get();

      expect(await readUserVersion(fresh), 7);
      expect(fresh.schemaVersion, 7);
    });

    test('calendar_event_state is keyed by (owner_key, event_id)', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      final rows = await fresh
          .customSelect("PRAGMA table_info('calendar_event_state')")
          .get();
      final primaryKey = rows
          .where((row) => row.read<int>('pk') > 0)
          .map((row) => row.read<String>('name'))
          .toSet();

      expect(primaryKey, <String>{'owner_key', 'event_id'});
    });

    test('calendar_event_state measures nothing and counts nothing '
        '(R-1b / AC-12 / AC-25)', () async {
      final fresh = CupidDatabase(NativeDatabase(databaseFile));
      addTearDown(fresh.close);

      final columns = await columnNames(fresh, 'calendar_event_state');

      expect(columns, <String>{
        'owner_key',
        'event_id',
        'state',
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
          reason: 'AC-25 cấm cột hành vi người kia ("$prefix*")',
        );
      }
    });
  });

  test('nhánh migration v7 chỉ CREATE TABLE, không có DROP', () async {
    final source =
        await File('lib/core/database/cupid_database.dart').readAsString();
    final int start = source.indexOf('if (from < 7) {');
    expect(start, isNot(-1), reason: 'không tìm thấy nhánh nâng cấp v7');
    final int end = source.indexOf('}', start);
    final String branch = source.substring(start, end);

    expect(branch, contains('createTable(calendarEventState)'));
    for (final forbidden in const <String>[
      'DROP',
      'deleteTable',
      'drop(',
      'destructivelyRecreate',
    ]) {
      expect(
        branch,
        isNot(contains(forbidden)),
        reason: 'bảng dữ liệu gốc không được huỷ-tạo-lại ("$forbidden")',
      );
    }
  });
}
