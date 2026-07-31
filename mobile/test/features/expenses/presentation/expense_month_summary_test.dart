import 'package:cupid_mobile/core/database/cupid_database.dart';
import 'package:cupid_mobile/features/expenses/presentation/expense_month_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ExpenseCacheRow buildRow({
    required String id,
    String userId = 'user-1',
    String category = 'food',
    double amount = 100000,
    String? description,
    required DateTime date,
  }) {
    return ExpenseCacheRow(
      id: id,
      userId: userId,
      category: category,
      amount: amount,
      description: description,
      date: date,
      createdAt: date,
    );
  }

  group('ExpenseMonthSummary.compute totals', () {
    test('totalVnd and itemCount sum only currentMonthRows', () {
      final summary = ExpenseMonthSummary.compute(
        month: DateTime.utc(2026, 7, 1),
        currentMonthRows: [
          buildRow(id: 'a', amount: 100000, date: DateTime.utc(2026, 7, 1)),
          buildRow(id: 'b', amount: 250000, date: DateTime.utc(2026, 7, 15)),
        ],
        previousMonthRows: const [],
        oldestCachedDate: null,
      );

      expect(summary.totalVnd, 350000);
      expect(summary.itemCount, 2);
    });

    test('weekdayTotalsVnd buckets each row under its weekday index', () {
      // 2026-07-01 is a Wednesday (weekday 3) -> bucket index 2.
      // 2026-07-04 is a Saturday (weekday 6) -> bucket index 5.
      final summary = ExpenseMonthSummary.compute(
        month: DateTime.utc(2026, 7, 1),
        currentMonthRows: [
          buildRow(id: 'wed', amount: 40000, date: DateTime.utc(2026, 7, 1)),
          buildRow(id: 'sat-1', amount: 10000, date: DateTime.utc(2026, 7, 4)),
          buildRow(id: 'sat-2', amount: 5000, date: DateTime.utc(2026, 7, 4)),
        ],
        previousMonthRows: const [],
        oldestCachedDate: null,
      );

      expect(summary.weekdayTotalsVnd, hasLength(7));
      expect(summary.weekdayTotalsVnd[2], 40000);
      expect(summary.weekdayTotalsVnd[5], 15000);
      expect(
        summary.weekdayTotalsVnd
            .where((total) => total != 40000 && total != 15000),
        everyElement(0),
      );
    });
  });

  group('ExpenseMonthSummary.compute delta visibility (ADR-015.3)', () {
    test(
      'delta is shown when the oldest cached row is on/before the first '
      'day of the previous month',
      () {
        final summary = ExpenseMonthSummary.compute(
          month: DateTime.utc(2026, 7, 15),
          currentMonthRows: [
            buildRow(id: 'jul', amount: 200000, date: DateTime.utc(2026, 7, 1)),
          ],
          previousMonthRows: [
            buildRow(id: 'jun', amount: 150000, date: DateTime.utc(2026, 6, 10)),
          ],
          // On the first day of June: the previous month is fully covered.
          oldestCachedDate: DateTime.utc(2026, 6, 1),
        );

        expect(summary.previousMonthTotalVnd, 150000);
        expect(summary.deltaVnd, 50000);
      },
    );

    test(
      'delta is hidden when the oldest cached row falls inside the '
      'current month (previous month not demonstrably covered)',
      () {
        final summary = ExpenseMonthSummary.compute(
          month: DateTime.utc(2026, 7, 15),
          currentMonthRows: [
            buildRow(id: 'jul', amount: 200000, date: DateTime.utc(2026, 7, 1)),
          ],
          previousMonthRows: const [],
          oldestCachedDate: DateTime.utc(2026, 7, 1),
        );

        expect(summary.previousMonthTotalVnd, isNull);
        expect(summary.deltaVnd, isNull);
      },
    );

    test('delta is hidden when nothing has ever been cached', () {
      final summary = ExpenseMonthSummary.compute(
        month: DateTime.utc(2026, 7, 15),
        currentMonthRows: const [],
        previousMonthRows: const [],
        oldestCachedDate: null,
      );

      expect(summary.previousMonthTotalVnd, isNull);
      expect(summary.deltaVnd, isNull);
    });

    test('deltaVnd is negative when spending decreased vs. last month', () {
      final summary = ExpenseMonthSummary.compute(
        month: DateTime.utc(2026, 7, 15),
        currentMonthRows: [
          buildRow(id: 'jul', amount: 50000, date: DateTime.utc(2026, 7, 1)),
        ],
        previousMonthRows: [
          buildRow(id: 'jun', amount: 200000, date: DateTime.utc(2026, 6, 10)),
        ],
        oldestCachedDate: DateTime.utc(2026, 6, 1),
      );

      expect(summary.deltaVnd, -150000);
    });
  });
}
