import 'dart:io';

import 'package:cupid_mobile/core/auth/cupid_session.dart';
import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/database/daos/activity_card_dao.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Stands in for the repo convention this story deliberately opts out of: a
/// store holding authenticated data that wipes itself on sign-out. Registering
/// the card DAO alongside one of these is what AC-22 forbids.
class _CacheClearingStore implements SessionScopedStore {
  _CacheClearingStore(this.database);

  final CupidDatabase database;

  @override
  Future<void> clearOnSignOut() async {
    await database.delete(database.messages).go();
    await database.delete(database.timelineEntries).go();
    await database.delete(database.expenses).go();
  }
}

void main() {
  late CupidDatabase database;
  late ActivityCardDao dao;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    dao = database.activityCardDao;
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> seedCard({
    required String id,
    String ownerKey = 'user-1',
    String title = 'Đi ăn lẩu',
    String status = 'idea',
    String origin = 'manual',
    DateTime? updatedAt,
  }) {
    final now = updatedAt ?? DateTime.utc(2026, 9, 7, 10);
    return dao.upsertCard(
      ActivityCardsCompanion.insert(
        id: id,
        ownerKey: ownerKey,
        title: title,
        origin: origin,
        status: Value(status),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  test('opens at the current schema version with both activity card tables',
      () async {
    expect(database.schemaVersion, 9);
    await database.select(database.activityCards).get();
    await database.select(database.activityCardPhotos).get();
  });

  group('activity_cards schema (contract-summary.md §3 allowlist)', () {
    test('exposes exactly the agreed column set and nothing more', () {
      const allowlist = {
        'id',
        'owner_key',
        'title',
        'status',
        'origin',
        'activity_type',
        'scheduled_on',
        'price_vnd',
        'distance_km',
        'needs_booking',
        'indoor_outdoor',
        'note',
        'source_link',
        'invited',
        'reply_state',
        'created_at',
        'updated_at',
        // Ruling B-1 — the complete set the ruling allows, no sixth column.
        'duration_minutes',
        'time_of_day_slot',
        'note_keywords',
        'link_source_label',
        'link_saved_at',
        // Schema v5 — free text the user typed, the source of the `place`
        // mad-libs variable (STORY-002 AC-4). Not geocoded, not structured.
        'location',
      };

      final actual =
          database.activityCards.$columns.map((column) => column.name).toSet();

      expect(actual, allowlist);
      expect(actual, hasLength(23));
    });

    test('carries no column that measures the partner behind their back '
        '(R-1b, contract-summary.md §4)', () {
      const forbiddenFragments = [
        'partner',
        'seen',
        'viewed',
        'opened',
        'open_times',
        'latency',
        'response_rate',
        'last_seen',
      ];
      final columnNames = database.activityCards.$columns
          .map((column) => column.name.toLowerCase())
          .toList();

      for (final fragment in forbiddenFragments) {
        expect(
          columnNames.where((name) => name.contains(fragment)),
          isEmpty,
          reason: 'activity_cards must never carry a "$fragment" column',
        );
      }
    });

    test('activity_card_photos exposes exactly its agreed columns', () {
      final actual = database.activityCardPhotos.$columns
          .map((column) => column.name)
          .toSet();

      expect(actual, {'id', 'card_id', 'local_path', 'sort_index'});
    });

    test('lib declares exactly one @DriftDatabase (ADR-010)', () {
      final libDir = Directory('lib');
      expect(libDir.existsSync(), isTrue);

      final owners = libDir
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'))
          .where((file) => !file.path.endsWith('.g.dart'))
          .where((file) => file.readAsStringSync().contains('@DriftDatabase'))
          .map((file) => file.path)
          .toList();

      expect(owners, hasLength(1));
    });
  });

  group('ActivityCardDao CRUD', () {
    test('upsertCard inserts, then a second write on the same id updates '
        'in place', () async {
      await seedCard(id: 'card-1', title: 'Đi ăn lẩu');
      await seedCard(id: 'card-1', title: 'Đi ăn lẩu Thái');

      final cards = await dao.cardsByStatus(
        ownerKey: 'user-1',
        status: 'idea',
        limit: 10,
      );

      expect(cards, hasLength(1));
      expect(cards.single.title, 'Đi ăn lẩu Thái');
    });

    test('optional fields default to null rather than being rejected',
        () async {
      await seedCard(id: 'card-1');

      final card = await dao.cardById(ownerKey: 'user-1', id: 'card-1');

      expect(card, isNotNull);
      expect(card!.activityType, isNull);
      expect(card.scheduledOn, isNull);
      expect(card.priceVnd, isNull);
      expect(card.needsBooking, isNull);
      expect(card.status, 'idea');
      expect(card.invited, isFalse);
      expect(card.replyState, 'not_answered');
    });

    test('updateCard moves a card between status panes', () async {
      await seedCard(id: 'card-1');

      final written = await dao.updateCard(
        ownerKey: 'user-1',
        id: 'card-1',
        changes: const ActivityCardsCompanion(status: Value('scheduled')),
      );

      expect(written, 1);
      expect(
        await dao.cardsByStatus(
          ownerKey: 'user-1',
          status: 'idea',
          limit: 10,
        ),
        isEmpty,
      );
      expect(
        await dao.cardsByStatus(
          ownerKey: 'user-1',
          status: 'scheduled',
          limit: 10,
        ),
        hasLength(1),
      );
    });

    test('cardsByStatus pages newest-updated first', () async {
      await seedCard(id: 'old', updatedAt: DateTime.utc(2026, 9, 1));
      await seedCard(id: 'new', updatedAt: DateTime.utc(2026, 9, 5));

      final firstPage = await dao.cardsByStatus(
        ownerKey: 'user-1',
        status: 'idea',
        limit: 1,
      );
      final secondPage = await dao.cardsByStatus(
        ownerKey: 'user-1',
        status: 'idea',
        limit: 1,
        offset: 1,
      );

      expect(firstPage.single.id, 'new');
      expect(secondPage.single.id, 'old');
    });

    test('watchCardsByStatus emits the pane again after a write', () async {
      final emissions = <List<ActivityCardRow>>[];
      final subscription = dao
          .watchCardsByStatus(ownerKey: 'user-1', status: 'idea', limit: 10)
          .listen(emissions.add);
      addTearDown(subscription.cancel);

      await seedCard(id: 'card-1');
      await pumpEventQueue();

      expect(emissions.last, hasLength(1));
    });
  });

  group('ActivityCardDao.countsByStatus', () {
    test('counts each pane for one owner without loading the rows', () async {
      await seedCard(id: 'a', status: 'idea');
      await seedCard(id: 'b', status: 'idea');
      await seedCard(id: 'c', status: 'scheduled');
      await seedCard(id: 'd', ownerKey: 'user-2', status: 'idea');

      final counts = await dao.countsByStatus('user-1');

      expect(counts['idea'], 2);
      expect(counts['scheduled'], 1);
      expect(counts.containsKey('done'), isFalse);
    });
  });

  group('owner_key isolation', () {
    test('a different owner_key sees none of the cards', () async {
      await seedCard(id: 'card-1', ownerKey: 'user-1');

      expect(
        await dao.cardsByStatus(
          ownerKey: 'user-2',
          status: 'idea',
          limit: 10,
        ),
        isEmpty,
      );
      expect(await dao.cardById(ownerKey: 'user-2', id: 'card-1'), isNull);
      expect(await dao.countsByStatus('user-2'), isEmpty);
    });

    test('deleting under the wrong owner_key writes nothing', () async {
      await seedCard(id: 'card-1', ownerKey: 'user-1');

      expect(await dao.deleteCard(ownerKey: 'user-2', id: 'card-1'), 0);
      expect(await dao.cardById(ownerKey: 'user-1', id: 'card-1'), isNotNull);
    });
  });

  group('photo cascade', () {
    test('deleting a card deletes its photo rows', () async {
      await seedCard(id: 'card-1');
      await seedCard(id: 'card-2');
      await dao.upsertPhoto(
        ActivityCardPhotosCompanion.insert(
          id: 'photo-1',
          cardId: 'card-1',
          localPath: '/app/photos/photo-1.jpg',
        ),
      );
      await dao.upsertPhoto(
        ActivityCardPhotosCompanion.insert(
          id: 'photo-2',
          cardId: 'card-2',
          localPath: '/app/photos/photo-2.jpg',
        ),
      );

      expect(await dao.deleteCard(ownerKey: 'user-1', id: 'card-1'), 1);

      expect(await dao.photosForCard('card-1'), isEmpty);
      expect(await dao.photosForCard('card-2'), hasLength(1));
    });
  });

  group('sign-out survival (AC-22)', () {
    test('ActivityCardDao does not implement SessionScopedStore', () {
      expect(dao, isNot(isA<SessionScopedStore>()));
    });

    test('running every registered clearOnSignOut leaves the cards intact',
        () async {
      await seedCard(id: 'card-1');

      final registeredStores = <Object>[
        _CacheClearingStore(database),
        database.messageDao,
        database.timelineDao,
        database.expenseDao,
        dao,
      ].whereType<SessionScopedStore>().toList();

      expect(registeredStores, isNotEmpty);
      for (final store in registeredStores) {
        await store.clearOnSignOut();
      }

      expect(
        await dao.cardsByStatus(
          ownerKey: 'user-1',
          status: 'idea',
          limit: 10,
        ),
        hasLength(1),
      );
    });
  });
}
