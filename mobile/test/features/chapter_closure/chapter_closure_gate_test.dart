import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/features/chapter_closure/domain/chapter_closure_gate.dart';
import 'package:drift/drift.dart' hide isNotNull, isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// `ChapterClosureGate` is the only read API for "what is currently closed"
/// (`architecture/contract-summary.md` §3). These tests run against a real
/// in-memory `CupidDatabase` rather than a mocked DAO, because the part that
/// can silently go wrong is the SQL — an anti-join that does not exclude, or a
/// kind filter that leaks another kind's ids.
void main() {
  late CupidDatabase database;
  late ChapterClosureGate gate;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
    gate = ChapterClosureGate(database.chapterClosureDao);
  });

  tearDown(() async {
    await database.close();
  });

  Future<void> insertCard(String id) {
    return database.activityCardDao.upsertCard(
      ActivityCardsCompanion.insert(
        id: id,
        ownerKey: 'user-1',
        title: 'Thẻ $id',
        origin: 'manual',
        createdAt: DateTime.utc(2026, 9, 1),
        updatedAt: DateTime.utc(2026, 9, 1),
      ),
    );
  }

  Future<void> closeChapter(
    String id,
    Map<String, Set<String>> itemIdsByKind,
  ) {
    return database.chapterClosureDao.createClosure(
      id: id,
      ownerKey: 'user-1',
      closedAt: DateTime.utc(2026, 9, 11),
      itemIdsByKind: itemIdsByKind,
    );
  }

  group('trạng thái rỗng', () {
    test('closedIdsOf returns an empty set for every kind and does not throw',
        () async {
      for (final kind in ChapterClosureItemKind.values) {
        expect(await gate.closedIdsOf(kind), isEmpty);
      }
    });

    test('hasAnyClosure is false before the first closure', () async {
      expect(await gate.hasAnyClosure(), isFalse);
    });
  });

  group('một closure', () {
    setUp(() async {
      await closeChapter('closure-1', const <String, Set<String>>{
        'activity_card': <String>{'card-a', 'card-b'},
      });
    });

    test('hasAnyClosure flips to true', () async {
      expect(await gate.hasAnyClosure(), isTrue);
    });

    test('closedIdsOf returns only the requested kind', () async {
      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.activityCard),
        <String>{'card-a', 'card-b'},
      );
      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.notebookEntry),
        isEmpty,
      );
      expect(await gate.closedIdsOf(ChapterClosureItemKind.askPrompt), isEmpty);
    });
  });

  group('nhiều kind và nhiều closure', () {
    setUp(() async {
      await closeChapter('closure-1', const <String, Set<String>>{
        'activity_card': <String>{'card-a'},
        'notebook_entry': <String>{'entry-a', 'entry-b'},
        'ask_prompt': <String>{'q-1'},
      });
      await closeChapter('closure-2', const <String, Set<String>>{
        'activity_card': <String>{'card-b'},
      });
    });

    test('ids from different closures merge into one set per kind', () async {
      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.activityCard),
        <String>{'card-a', 'card-b'},
      );
      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.notebookEntry),
        <String>{'entry-a', 'entry-b'},
      );
      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.askPrompt),
        <String>{'q-1'},
      );
    });

    test('reopening one closure releases only its own ids (AC-17)', () async {
      await database.chapterClosureDao.deleteClosure('closure-1');

      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.activityCard),
        <String>{'card-b'},
      );
      expect(
        await gate.closedIdsOf(ChapterClosureItemKind.notebookEntry),
        isEmpty,
      );
      expect(await gate.hasAnyClosure(), isTrue);
    });

    test('reopening every closure returns the gate to its empty state',
        () async {
      await database.chapterClosureDao.deleteClosure('closure-1');
      await database.chapterClosureDao.deleteClosure('closure-2');

      expect(await gate.hasAnyClosure(), isFalse);
      for (final kind in ChapterClosureItemKind.values) {
        expect(await gate.closedIdsOf(kind), isEmpty);
      }
    });
  });

  group('anti-join dùng lại được (§3)', () {
    setUp(() async {
      for (final id in const <String>['card-a', 'card-b', 'card-c']) {
        await insertCard(id);
      }
      await closeChapter('closure-1', const <String, Set<String>>{
        'activity_card': <String>{'card-a', 'card-b'},
        // Same raw id under a different kind must not hide the card.
        'notebook_entry': <String>{'card-c'},
      });
    });

    Future<List<String>> pagedOpenCardIds({required int limit}) async {
      final query = database.select(database.activityCards)
        ..where(
          (row) => ChapterClosureGate.notClosed(
            kind: ChapterClosureItemKind.activityCard,
            itemId: row.id,
            closureItems: database.chapterClosureItems,
          ),
        )
        ..orderBy([(row) => OrderingTerm.asc(row.id)])
        ..limit(limit);
      final rows = await query.get();
      return rows.map((row) => row.id).toList();
    }

    test('excludes closed ids inside SQL, so LIMIT still fills the page',
        () async {
      // Filtering in Dart after a `LIMIT 1` read would have returned an empty
      // page here, because card-a sorts first and is closed.
      expect(await pagedOpenCardIds(limit: 1), <String>['card-c']);
      expect(await pagedOpenCardIds(limit: 10), <String>['card-c']);
    });

    test('an id closed under another kind is not excluded', () async {
      await database.chapterClosureDao.deleteClosure('closure-1');
      await closeChapter('closure-2', const <String, Set<String>>{
        'notebook_entry': <String>{'card-a', 'card-b', 'card-c'},
      });

      expect(
        await pagedOpenCardIds(limit: 10),
        <String>['card-a', 'card-b', 'card-c'],
      );
    });

    test('with nothing closed the anti-join excludes nothing', () async {
      await database.chapterClosureDao.deleteClosure('closure-1');

      expect(
        await pagedOpenCardIds(limit: 10),
        <String>['card-a', 'card-b', 'card-c'],
      );
    });
  });

  group('vocabulary (§2)', () {
    test('the wire values are exactly the three contracted kinds', () async {
      expect(
        ChapterClosureItemKind.values.map((kind) => kind.wireValue).toList(),
        <String>['activity_card', 'notebook_entry', 'ask_prompt'],
      );
    });
  });
}
