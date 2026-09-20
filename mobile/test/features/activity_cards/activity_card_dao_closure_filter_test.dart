import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// `ActivityCardDao` must drop closed cards **inside** the SQL, before
/// `LIMIT`/`OFFSET` (`architecture/contract-summary.md` §3).
///
/// The fixture is deliberately larger than one page: 25 cards with 10 closed.
/// A fixture smaller than `pageSize` would pass with a Dart-side filter too,
/// which is exactly the bug this phase has to rule out — it returns short pages
/// and makes `ActivityCardListCubit` stop paging early.
void main() {
  late CupidDatabase database;

  const owner = 'user-1';
  const pageSize = 10;
  final base = DateTime.utc(2026, 9, 1);

  /// `card-00` .. `card-24`, newest-updated last, so the DAO's newest-first
  /// order returns them in descending index order.
  String cardId(int index) => 'card-${index.toString().padLeft(2, '0')}';

  /// Ten closed cards spread across both pages, not clustered in one page: a
  /// closed block confined to page 2 would leave page 1 correct by accident.
  const closedIndexes = <int>[0, 2, 4, 6, 8, 10, 12, 14, 16, 18];

  List<String> expectedOpenIdsNewestFirst() => [
        for (var index = 24; index >= 0; index--)
          if (!closedIndexes.contains(index)) cardId(index),
      ];

  Future<void> insertCard(
    int index, {
    String status = 'idea',
    String ownerKey = owner,
  }) {
    return database.into(database.activityCards).insert(
          ActivityCardsCompanion.insert(
            id: cardId(index),
            ownerKey: ownerKey,
            title: 'Thẻ ${cardId(index)}',
            origin: 'manual',
            status: Value(status),
            createdAt: base,
            updatedAt: base.add(Duration(minutes: index)),
          ),
        );
  }

  Future<void> closeCards(Iterable<int> indexes) {
    return database.chapterClosureDao.createClosure(
      id: 'closure-1',
      ownerKey: owner,
      closedAt: DateTime.utc(2026, 9, 12),
      itemIdsByKind: <String, Set<String>>{
        'activity_card': {for (final index in indexes) cardId(index)},
      },
    );
  }

  setUp(() async {
    database = CupidDatabase(NativeDatabase.memory());
    for (var index = 0; index < 25; index++) {
      await insertCard(index);
    }
  });

  tearDown(() async {
    await database.close();
  });

  Future<List<String>> pageIds({required int offset}) async {
    final rows = await database.activityCardDao.cardsByStatus(
      ownerKey: owner,
      status: 'idea',
      limit: pageSize,
      offset: offset,
    );
    return rows.map((row) => row.id).toList();
  }

  group('chưa đóng gì', () {
    test('anti-join không loại trừ gì và phân trang giữ nguyên', () async {
      expect(await pageIds(offset: 0), hasLength(10));
      expect(await pageIds(offset: 10), hasLength(10));
      expect(await pageIds(offset: 20), hasLength(5));
      expect(
        await database.activityCardDao.countsByStatus(owner),
        <String, int>{'idea': 25},
      );
    });
  });

  group('phân trang sau khi đóng 10/25 thẻ', () {
    setUp(() async {
      await closeCards(closedIndexes);
    });

    test('hai trang liên tiếp trả 10 rồi 5, không trùng, không sót', () async {
      final firstPage = await pageIds(offset: 0);
      final secondPage = await pageIds(offset: pageSize);

      expect(firstPage, hasLength(10));
      expect(secondPage, hasLength(5));
      expect(firstPage.toSet().intersection(secondPage.toSet()), isEmpty);
      expect(
        <String>[...firstPage, ...secondPage],
        expectedOpenIdsNewestFirst(),
      );
    });

    test('cờ hasMore đúng ở cả hai trang', () async {
      // Cách `ActivityCardListCubit._fetchPage` suy ra hasMore.
      final firstPage = await pageIds(offset: 0);
      final secondPage = await pageIds(offset: pageSize);

      expect(firstPage.length == pageSize, isTrue);
      expect(secondPage.length == pageSize, isFalse);
    });

    test('không thẻ đã đóng nào lọt vào bất kỳ trang nào', () async {
      final everything = <String>[
        ...await pageIds(offset: 0),
        ...await pageIds(offset: pageSize),
        ...await pageIds(offset: pageSize * 2),
      ];

      for (final index in closedIndexes) {
        expect(everything, isNot(contains(cardId(index))));
      }
      expect(everything, hasLength(15));
    });

    test('countsByStatus đếm theo tập đã lọc (AC-11)', () async {
      expect(
        await database.activityCardDao.countsByStatus(owner),
        <String, int>{'idea': 15},
      );
    });

    test('watchCardsByStatus phát ra cùng tập đã lọc', () async {
      final firstEmission = await database.activityCardDao
          .watchCardsByStatus(
            ownerKey: owner,
            status: 'idea',
            limit: pageSize,
          )
          .first;

      expect(
        firstEmission.map((row) => row.id).toList(),
        expectedOpenIdsNewestFirst().take(pageSize).toList(),
      );
    });

    test('mở lại đưa đủ 25 thẻ trở lại mọi đường đọc (AC-17)', () async {
      await database.chapterClosureDao.deleteClosure('closure-1');

      expect(await pageIds(offset: 0), hasLength(10));
      expect(await pageIds(offset: 20), hasLength(5));
      expect(
        await database.activityCardDao.countsByStatus(owner),
        <String, int>{'idea': 25},
      );
    });
  });

  group('ảnh chụp tại thời điểm đóng, không tính lại lúc đọc (AC-9)', () {
    test('thẻ sống sót được mời cho người mới vẫn ở luồng thường ngày',
        () async {
      await closeCards(closedIndexes);
      // card-01 sống sót; giờ người dùng mời một người mới vào đúng thẻ đó.
      await database.activityCardDao.updateCard(
        ownerKey: owner,
        id: cardId(1),
        changes: const ActivityCardsCompanion(
          invited: Value(true),
          replyState: Value('answered'),
        ),
      );

      final everything = <String>[
        ...await pageIds(offset: 0),
        ...await pageIds(offset: pageSize),
      ];

      expect(everything, contains(cardId(1)));
      expect(
        await database.activityCardDao.countsByStatus(owner),
        <String, int>{'idea': 15},
      );
    });
  });

  group('phạm vi lọc', () {
    test('pane khác và chủ khác không bị ảnh hưởng', () async {
      for (var index = 30; index < 33; index++) {
        await insertCard(index, status: 'done');
      }
      await insertCard(40, ownerKey: 'user-2');
      await closeCards(closedIndexes);

      expect(
        await database.activityCardDao.countsByStatus(owner),
        <String, int>{'idea': 15, 'done': 3},
      );
      expect(
        await database.activityCardDao.countsByStatus('user-2'),
        <String, int>{'idea': 1},
      );
    });

    test('id đóng dưới kind khác không ẩn thẻ trùng id', () async {
      await database.chapterClosureDao.createClosure(
        id: 'closure-2',
        ownerKey: owner,
        closedAt: DateTime.utc(2026, 9, 12),
        itemIdsByKind: <String, Set<String>>{
          'notebook_entry': {cardId(0), cardId(1)},
        },
      );

      expect(
        await database.activityCardDao.countsByStatus(owner),
        <String, int>{'idea': 25},
      );
    });
  });
}
