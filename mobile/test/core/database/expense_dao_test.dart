import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late CupidDatabase database;

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  ExpenseCacheRow buildRow({
    required String id,
    String userId = 'user-1',
    String category = 'food',
    double amount = 100000,
    String? description,
    required DateTime date,
    required DateTime createdAt,
  }) {
    return ExpenseCacheRow(
      id: id,
      userId: userId,
      category: category,
      amount: amount,
      description: description,
      date: date,
      createdAt: createdAt,
    );
  }

  test('opens at the current schema version with both tables present',
      () async {
    expect(database.schemaVersion, 3);
    await database.select(database.expenses).get();
    await database.select(database.expenseSyncMetadata).get();
  });

  group('ExpenseDao.upsertAll', () {
    test('upserting the same server id twice leaves exactly one row with '
        "the second write's values", () async {
      final dao = database.expenseDao;
      final date = DateTime.utc(2026, 7, 1);
      final createdAt = DateTime.utc(2026, 7, 1, 9);

      await dao.upsertAll([
        buildRow(
          id: 'exp-1',
          description: 'first',
          date: date,
          createdAt: createdAt,
        ),
      ]);
      await dao.upsertAll([
        buildRow(
          id: 'exp-1',
          description: 'second',
          date: date,
          createdAt: createdAt,
        ),
      ]);

      final page = await dao.getPage(limit: 10, offset: 0);

      expect(page, hasLength(1));
      expect(page.single.description, 'second');
    });
  });

  group('ExpenseDao.getPage / watchPage', () {
    test('returns rows ordered date DESC, createdAt DESC and honors '
        'limit/offset', () async {
      final dao = database.expenseDao;
      final base = DateTime.utc(2026, 7, 1);

      await dao.upsertAll([
        buildRow(id: 'exp-1', date: base, createdAt: base),
        buildRow(
          id: 'exp-2',
          date: base.add(const Duration(days: 2)),
          createdAt: base.add(const Duration(days: 2)),
        ),
        buildRow(
          id: 'exp-3',
          date: base.add(const Duration(days: 2)),
          createdAt: base.add(const Duration(days: 2, hours: 1)),
        ),
      ]);

      final fullPage = await dao.getPage(limit: 10, offset: 0);
      expect(fullPage.map((row) => row.id), ['exp-3', 'exp-2', 'exp-1']);

      final secondRowOnly = await dao.getPage(limit: 1, offset: 1);
      expect(secondRowOnly.single.id, 'exp-2');
    });

    test('watchPage emits on upsertAll and orders newest-first', () async {
      final dao = database.expenseDao;
      final base = DateTime.utc(2026, 7, 1);
      final emissions = <List<ExpenseCacheRow>>[];
      final subscription =
          dao.watchPage(limit: 10, offset: 0).listen(emissions.add);
      addTearDown(subscription.cancel);

      await dao.upsertAll([
        buildRow(id: 'exp-1', date: base, createdAt: base),
        buildRow(
          id: 'exp-2',
          date: base.add(const Duration(days: 1)),
          createdAt: base.add(const Duration(days: 1)),
        ),
      ]);
      await pumpEventQueue();

      expect(emissions, isNotEmpty);
      expect(emissions.last.map((row) => row.id), ['exp-2', 'exp-1']);
    });
  });

  group('ExpenseDao.monthRows', () {
    test('returns only rows whose date falls within the given month',
        () async {
      final dao = database.expenseDao;

      await dao.upsertAll([
        buildRow(
          id: 'june',
          date: DateTime.utc(2026, 6, 30),
          createdAt: DateTime.utc(2026, 6, 30),
        ),
        buildRow(
          id: 'july-1',
          date: DateTime.utc(2026, 7, 1),
          createdAt: DateTime.utc(2026, 7, 1),
        ),
        buildRow(
          id: 'july-31',
          date: DateTime.utc(2026, 7, 31),
          createdAt: DateTime.utc(2026, 7, 31),
        ),
        buildRow(
          id: 'august',
          date: DateTime.utc(2026, 8, 1),
          createdAt: DateTime.utc(2026, 8, 1),
        ),
      ]);

      final rows = await dao.monthRows(DateTime.utc(2026, 7, 15));

      expect(rows.map((row) => row.id), ['july-31', 'july-1']);
    });
  });

  group('ExpenseDao sync metadata (ADR-015.5)', () {
    test('lastSuccessfulSyncAt is null on a fresh database and non-null '
        'only after markSyncedNow', () async {
      final dao = database.expenseDao;

      expect(await dao.lastSuccessfulSyncAt, isNull);

      await dao.markSyncedNow();

      expect(await dao.lastSuccessfulSyncAt, isNotNull);
    });

    test('countAll == 0 with null lastSuccessfulSyncAt is distinguishable '
        'from countAll == 0 with a non-null timestamp', () async {
      final dao = database.expenseDao;

      expect(await dao.countAll(), 0);
      expect(await dao.lastSuccessfulSyncAt, isNull);

      await dao.markSyncedNow();

      expect(await dao.countAll(), 0);
      expect(await dao.lastSuccessfulSyncAt, isNotNull);
    });
  });

  group('ExpenseDao.countAll', () {
    test('counts rows without reading them into memory', () async {
      final dao = database.expenseDao;
      final date = DateTime.utc(2026, 7, 1);

      await dao.upsertAll([
        buildRow(id: 'exp-1', date: date, createdAt: date),
        buildRow(id: 'exp-2', date: date, createdAt: date),
      ]);

      expect(await dao.countAll(), 2);
    });
  });

  group('expenses schema (ADR-007 gate)', () {
    test('exposes no column whose name matches an offline-write-queue '
        'concept', () {
      final forbiddenFragments = [
        'pending',
        'queued',
        'outbox',
        'retry',
        'sendState',
      ];
      final columnNames = database.expenses.$columns
          .map((column) => column.name.toLowerCase())
          .toList();

      expect(columnNames, isNotEmpty);
      for (final fragment in forbiddenFragments) {
        expect(
          columnNames.where((name) => name.contains(fragment.toLowerCase())),
          isEmpty,
          reason: 'expenses table must never contain a "$fragment" column',
        );
      }
    });
  });
}
