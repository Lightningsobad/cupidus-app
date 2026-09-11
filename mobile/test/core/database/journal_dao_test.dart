import 'package:cupid_mobile/core/auth/cupid_session.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/journal_dao.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CupidDatabase database;
  late JournalDao dao;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    dao = database.journalDao;
  });

  tearDown(() async {
    await database.close();
  });

  JournalEntry buildEntry({
    required String id,
    String ownerUserId = 'user-a',
    String bodyText = 'hôm nay trời đẹp',
    int createdAt = 1000,
    int? updatedAt,
    String origin = 'manual',
    String? originRef,
  }) {
    return JournalEntry(
      id: id,
      ownerUserId: ownerUserId,
      bodyText: bodyText,
      createdAt: createdAt,
      updatedAt: updatedAt ?? createdAt,
      origin: origin,
      originRef: originRef,
    );
  }

  Future<void> insertPhoto({
    required String id,
    required String entryId,
    int sortIndex = 0,
  }) {
    return database.into(database.journalPhotos).insert(
          JournalPhotosCompanion.insert(
            id: id,
            entryId: entryId,
            relativePath: '$entryId/$id.jpg',
            sortIndex: sortIndex,
            createdAt: 1000,
          ),
        );
  }

  test('opens at the current schema version with both journal tables present',
      () async {
    expect(database.schemaVersion, 7);
    await database.select(database.journalEntries).get();
    await database.select(database.journalPhotos).get();
  });

  group('JournalDao.upsertEntry', () {
    test('editing an entry rewrites the same row instead of minting a new id '
        '(AC-3)', () async {
      await dao.upsertEntry('user-a', buildEntry(id: 'e-1', bodyText: 'bản 1'));
      await dao.upsertEntry(
        'user-a',
        buildEntry(id: 'e-1', bodyText: 'bản 2', updatedAt: 2000),
      );

      final rows = await database.select(database.journalEntries).get();

      expect(rows, hasLength(1));
      expect(rows.single.id, 'e-1');
      expect(rows.single.bodyText, 'bản 2');
      expect(rows.single.updatedAt, 2000);
    });

    test('stores the owner from the parameter, not from the passed row',
        () async {
      await dao.upsertEntry(
        'user-a',
        buildEntry(id: 'e-1', ownerUserId: 'user-b'),
      );

      expect(await dao.entryById('user-a', 'e-1'), isNotNull);
      expect(await dao.entryById('user-b', 'e-1'), isNull);
    });

    test('leaves an entry owned by another user untouched', () async {
      await dao.upsertEntry('user-a', buildEntry(id: 'e-1', bodyText: 'của A'));

      await dao.upsertEntry(
        'user-b',
        buildEntry(id: 'e-1', bodyText: 'ghi đè của B'),
      );

      final rows = await database.select(database.journalEntries).get();
      expect(rows, hasLength(1));
      expect(rows.single.ownerUserId, 'user-a');
      expect(rows.single.bodyText, 'của A');
    });

    test('accepts an empty body for a photo-only entry', () async {
      await dao.upsertEntry('user-a', buildEntry(id: 'e-1', bodyText: ''));

      expect((await dao.entryById('user-a', 'e-1'))!.bodyText, isEmpty);
    });
  });

  group('owner isolation on a shared device', () {
    test('user B cannot read user A entries through entryById or watchEntries',
        () async {
      await dao.upsertEntry('user-a', buildEntry(id: 'a-1'));
      await dao.upsertEntry(
        'user-b',
        buildEntry(id: 'b-1', ownerUserId: 'user-b'),
      );

      expect(await dao.entryById('user-b', 'a-1'), isNull);
      expect(await dao.entryById('user-a', 'a-1'), isNotNull);

      final bEntries = await dao.watchEntries('user-b').first;
      expect(bEntries.map((entry) => entry.id), ['b-1']);
    });

    test('an unknown owner id sees an empty journal, not everyone else\'s',
        () async {
      await dao.upsertEntry('user-a', buildEntry(id: 'a-1'));

      expect(await dao.watchEntries('user-unknown').first, isEmpty);
      expect(await dao.liveEntryIds('user-unknown'), isEmpty);
    });
  });

  group('JournalDao.watchEntries', () {
    test('emits newest-first and honors limit/offset', () async {
      await dao.upsertEntry('user-a', buildEntry(id: 'e-1', createdAt: 1000));
      await dao.upsertEntry('user-a', buildEntry(id: 'e-2', createdAt: 3000));
      await dao.upsertEntry('user-a', buildEntry(id: 'e-3', createdAt: 2000));

      final page = await dao.watchEntries('user-a').first;
      expect(page.map((entry) => entry.id), ['e-2', 'e-3', 'e-1']);

      final second = await dao.watchEntries('user-a', limit: 1, offset: 1).first;
      expect(second.single.id, 'e-3');
    });

    test('re-emits after a write', () async {
      final emissions = <List<JournalEntry>>[];
      final subscription = dao.watchEntries('user-a').listen(emissions.add);
      addTearDown(subscription.cancel);

      await dao.upsertEntry('user-a', buildEntry(id: 'e-1'));
      await pumpEventQueue();

      expect(emissions.last.map((entry) => entry.id), ['e-1']);
    });
  });

  group('JournalDao.deleteEntry', () {
    test('removes the entry together with its photo rows (AC-13)', () async {
      await dao.upsertEntry('user-a', buildEntry(id: 'e-1'));
      await dao.upsertEntry('user-a', buildEntry(id: 'e-2'));
      await insertPhoto(id: 'p-1', entryId: 'e-1');
      await insertPhoto(id: 'p-2', entryId: 'e-1', sortIndex: 1);
      await insertPhoto(id: 'p-3', entryId: 'e-2');

      await dao.deleteEntry('user-a', 'e-1');

      expect(await dao.entryById('user-a', 'e-1'), isNull);
      final photos = await database.select(database.journalPhotos).get();
      expect(photos.map((photo) => photo.id), ['p-3']);
    });

    test('cascades photo rows when the entry row is deleted directly',
        () async {
      await dao.upsertEntry('user-a', buildEntry(id: 'e-1'));
      await insertPhoto(id: 'p-1', entryId: 'e-1');

      await (database.delete(database.journalEntries)
            ..where((t) => t.id.equals('e-1')))
          .go();

      expect(await database.select(database.journalPhotos).get(), isEmpty);
    });

    test('does nothing when the entry belongs to another user', () async {
      await dao.upsertEntry('user-a', buildEntry(id: 'e-1'));
      await insertPhoto(id: 'p-1', entryId: 'e-1');

      await dao.deleteEntry('user-b', 'e-1');

      expect(await dao.entryById('user-a', 'e-1'), isNotNull);
      expect(await database.select(database.journalPhotos).get(), hasLength(1));
    });
  });

  group('JournalDao.deleteAllEntries', () {
    test('clears exactly one owner and leaves other owners intact (AC-12)',
        () async {
      await dao.upsertEntry('user-a', buildEntry(id: 'a-1'));
      await dao.upsertEntry('user-a', buildEntry(id: 'a-2'));
      await dao.upsertEntry(
        'user-b',
        buildEntry(id: 'b-1', ownerUserId: 'user-b'),
      );
      await insertPhoto(id: 'p-a1', entryId: 'a-1');
      await insertPhoto(id: 'p-b1', entryId: 'b-1');

      await dao.deleteAllEntries('user-a');

      expect(await dao.liveEntryIds('user-a'), isEmpty);
      expect(await dao.liveEntryIds('user-b'), ['b-1']);
      final photos = await database.select(database.journalPhotos).get();
      expect(photos.map((photo) => photo.id), ['p-b1']);
    });
  });

  group('JournalDao.liveEntryIds', () {
    test('returns only the requested owner ids for the orphan sweep', () async {
      await dao.upsertEntry('user-a', buildEntry(id: 'a-1'));
      await dao.upsertEntry('user-a', buildEntry(id: 'a-2'));
      await dao.upsertEntry(
        'user-b',
        buildEntry(id: 'b-1', ownerUserId: 'user-b'),
      );

      expect((await dao.liveEntryIds('user-a'))..sort(), ['a-1', 'a-2']);
    });
  });

  group('journal schema and lifecycle gates', () {
    test('journal tables expose no soft-delete, streak, goal, counter, or '
        'share-state column (BR-2, BR-4)', () {
      const forbiddenFragments = [
        'deletedat',
        'streak',
        'goal',
        'count',
        'shared',
        'sharestate',
      ];
      final columnNames = [
        ...database.journalEntries.$columns,
        ...database.journalPhotos.$columns,
      ].map((column) => column.name.toLowerCase()).toList();

      expect(columnNames, isNotEmpty);
      for (final fragment in forbiddenFragments) {
        expect(
          columnNames.where((name) => name.contains(fragment)),
          isEmpty,
          reason: 'journal tables must never contain a "$fragment" column',
        );
      }
    });

    test('JournalDao is not a SessionScopedStore, so signing out cannot wipe '
        'the journal (Key Discovery 2)', () {
      expect(dao, isNot(isA<SessionScopedStore>()));
    });

    test('ownerUserId is mandatory on every journal entry row', () {
      expect(database.journalEntries.ownerUserId.$nullable, isFalse);
    });
  });
}
