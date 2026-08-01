import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/core/realtime/backend_user_id_store.dart';
import 'package:cupid_mobile/features/expenses/data/expense_category.dart';
import 'package:cupid_mobile/features/expenses/data/expense_models.dart';
import 'package:cupid_mobile/features/expenses/data/expenses_repository.dart';
import 'package:cupid_mobile/features/expenses/presentation/expense_history_cubit.dart';
import 'package:cupid_mobile/features/expenses/presentation/widgets/expense_list_item.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// Hand-rolled fake — "no mocking package is a dependency of this repo"
/// (`test/features/expenses/data/expenses_repository_test.dart`). [fetchPage]
/// delegates to an injected closure so each test controls exactly what a
/// given `limit`/`offset` call returns (a fixed page, an empty page, or a
/// thrown failure to simulate offline).
class _FakeExpensesRepository implements ExpensesRepository {
  _FakeExpensesRepository(this._fetchPage);

  final Future<List<Expense>> Function({
    required int limit,
    required int offset,
  })
  _fetchPage;

  @override
  Future<List<Expense>> fetchPage({int limit = 50, int offset = 0}) {
    return _fetchPage(limit: limit, offset: offset);
  }

  @override
  Future<Expense> create({
    required ExpenseCategory category,
    required num amountVnd,
    String? description,
    required DateTime date,
  }) => throw UnimplementedError('not used by ExpenseHistoryCubit');
}

void main() {
  late CupidDatabase database;

  ExpenseCacheRow buildCacheRow({
    required String id,
    String userId = 'user-1',
    String category = 'food',
    double amount = 100000,
    required DateTime date,
  }) {
    return ExpenseCacheRow(
      id: id,
      userId: userId,
      category: category,
      amount: amount,
      description: null,
      date: date,
      createdAt: date,
    );
  }

  Expense buildExpense({
    required String id,
    String userId = 'user-1',
    ExpenseCategory category = ExpenseCategory.food,
    num amountVnd = 100000,
    required DateTime date,
  }) {
    return Expense(
      id: id,
      userId: userId,
      category: category,
      amountVnd: amountVnd,
      description: null,
      date: date,
      createdAt: date,
    );
  }

  setUp(() {
    database = CupidDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await database.close();
  });

  group('read-through construction (AC3, ADR-007)', () {
    test(
      'emits the cached page immediately, then a synced page once the '
      'network fetch resolves',
      () async {
        final date = DateTime.utc(2026, 7, 1);
        await database.expenseDao.upsertAll([
          buildCacheRow(id: 'cached-1', date: date),
        ]);

        final repository = _FakeExpensesRepository(
          ({required limit, required offset}) async => const <Expense>[],
        );
        final cubit = ExpenseHistoryCubit(
          repository: repository,
          dao: database.expenseDao,
        );
        addTearDown(cubit.close);
        await pumpEventQueue();

        expect(cubit.state.rows.map((row) => row.id), ['cached-1']);
        expect(cubit.state.hasCompletedInitialFetch, isTrue);
        expect(cubit.state.isOffline, isFalse);
      },
    );

    test(
      'a failed fetch keeps the cached page and flags offline rather than '
      'erroring out',
      () async {
        final date = DateTime.utc(2026, 7, 1);
        await database.expenseDao.upsertAll([
          buildCacheRow(id: 'cached-1', date: date),
        ]);
        await database.expenseDao.markSyncedNow();

        final repository = _FakeExpensesRepository(
          ({required limit, required offset}) async =>
              throw Exception('network down'),
        );
        final cubit = ExpenseHistoryCubit(
          repository: repository,
          dao: database.expenseDao,
        );
        addTearDown(cubit.close);
        await pumpEventQueue();

        expect(cubit.state.rows.map((row) => row.id), ['cached-1']);
        expect(cubit.state.isOffline, isTrue);
        expect(cubit.state.hasCompletedInitialFetch, isTrue);
        expect(cubit.state.showFreshnessCaption, isTrue);
      },
    );

    test(
      'a successful fetch upserts into the cache, marks synced, and '
      're-emits the merged page',
      () async {
        final date = DateTime.utc(2026, 7, 1);
        final repository = _FakeExpensesRepository(
          ({required limit, required offset}) async => [
            buildExpense(id: 'server-1', date: date),
          ],
        );
        final cubit = ExpenseHistoryCubit(
          repository: repository,
          dao: database.expenseDao,
        );
        addTearDown(cubit.close);
        await pumpEventQueue();

        expect(cubit.state.rows.map((row) => row.id), contains('server-1'));
        expect(cubit.state.isOffline, isFalse);
        expect(await database.expenseDao.lastSuccessfulSyncAt, isNotNull);
        expect(await database.expenseDao.countAll(), 1);
      },
    );
  });

  group('never-synced vs. genuinely-empty (ADR-015.5)', () {
    test(
      'offline on a completely fresh cache is never-synced, not '
      'genuinely-empty',
      () async {
        final repository = _FakeExpensesRepository(
          ({required limit, required offset}) async =>
              throw Exception('offline'),
        );
        final cubit = ExpenseHistoryCubit(
          repository: repository,
          dao: database.expenseDao,
        );
        addTearDown(cubit.close);
        await pumpEventQueue();

        expect(cubit.state.isNeverSynced, isTrue);
        expect(cubit.state.isGenuinelyEmpty, isFalse);
      },
    );

    test(
      'zero expenses after at least one prior successful sync is '
      'genuinely-empty, not never-synced',
      () async {
        await database.expenseDao.markSyncedNow();
        final repository = _FakeExpensesRepository(
          ({required limit, required offset}) async => const <Expense>[],
        );
        final cubit = ExpenseHistoryCubit(
          repository: repository,
          dao: database.expenseDao,
        );
        addTearDown(cubit.close);
        await pumpEventQueue();

        expect(cubit.state.isGenuinelyEmpty, isTrue);
        expect(cubit.state.isNeverSynced, isFalse);
      },
    );
  });

  group('loadMore pagination', () {
    test(
      'fetches the next offset window and appends without ever holding '
      'the whole table',
      () async {
        final firstPage = List<Expense>.generate(
          50,
          (i) => buildExpense(
            id: 'p1-$i',
            date: DateTime.utc(2026, 7, 1).subtract(Duration(days: i)),
          ),
        );
        final secondPage = [
          buildExpense(id: 'p2-0', date: DateTime.utc(2026, 5, 1)),
        ];

        final repository = _FakeExpensesRepository(({
          required limit,
          required offset,
        }) async {
          if (offset == 0) return firstPage;
          if (offset == 50) return secondPage;
          return const <Expense>[];
        });
        final cubit = ExpenseHistoryCubit(
          repository: repository,
          dao: database.expenseDao,
        );
        addTearDown(cubit.close);
        await pumpEventQueue();

        expect(cubit.state.rows, hasLength(50));
        expect(cubit.state.hasMore, isTrue);

        await cubit.loadMore();
        await pumpEventQueue();

        expect(cubit.state.rows, hasLength(51));
        expect(cubit.state.hasMore, isFalse);
      },
    );
  });

  group('category filter (AC2 — category-only, never a who/partner filter)', () {
    test('filteredRows narrows by category and "All" restores every row', () async {
      final repository = _FakeExpensesRepository(
        ({required limit, required offset}) async => [
          buildExpense(
            id: 'food-1',
            userId: 'user-1',
            category: ExpenseCategory.food,
            date: DateTime.utc(2026, 7, 1),
          ),
          buildExpense(
            id: 'travel-1',
            userId: 'user-2',
            category: ExpenseCategory.travel,
            date: DateTime.utc(2026, 7, 2),
          ),
        ],
      );
      final cubit = ExpenseHistoryCubit(
        repository: repository,
        dao: database.expenseDao,
      );
      addTearDown(cubit.close);
      await pumpEventQueue();

      cubit.categorySelected(ExpenseCategory.food);
      expect(cubit.state.filteredRows.map((row) => row.id), ['food-1']);

      cubit.categorySelected(null);
      expect(cubit.state.filteredRows, hasLength(2));
    });
  });

  group('ExpenseListItem.isOwnRow (ADR-015.2 "who" derivation)', () {
    test('true only when the row userId matches the own backend user id', () {
      final store = BackendUserIdStore()
        ..updateFromLoginResponse({'id': 'user-1'});
      final ownRow = buildCacheRow(
        id: 'own',
        userId: 'user-1',
        date: DateTime.utc(2026, 7, 1),
      );
      final partnerRow = buildCacheRow(
        id: 'partner',
        userId: 'user-2',
        date: DateTime.utc(2026, 7, 1),
      );

      expect(ExpenseListItem.isOwnRow(ownRow, store), isTrue);
      expect(ExpenseListItem.isOwnRow(partnerRow, store), isFalse);
    });
  });
}
