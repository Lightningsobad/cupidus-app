import 'package:cupid_mobile/features/expenses/data/expense_category.dart';
import 'package:cupid_mobile/features/expenses/data/expense_models.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _json({
  Object? amount,
  String? category,
  String? description,
}) {
  return {
    'id': 'e1',
    'coupleId': 'c1',
    'userId': 'u1',
    'category': category ?? 'food',
    'amount': amount ?? '250000.00',
    'description': description,
    'date': '2026-07-30',
    'createdAt': '2026-07-30T09:12:44.101Z',
  };
}

void main() {
  group('Expense.fromJson', () {
    test('decodes a String amount', () {
      final expense = Expense.fromJson(_json(amount: '250000.00'));
      expect(expense.amountVnd, 250000.0);
    });

    test('decodes a num amount to the same value as the String shape', () {
      final expense = Expense.fromJson(_json(amount: 250000));
      expect(expense.amountVnd, 250000.0);
    });

    test('treats description as nullable', () {
      final expense = Expense.fromJson(_json(description: null));
      expect(expense.description, isNull);
    });

    test('falls back to other for an unrecognized category', () {
      final expense = Expense.fromJson(_json(category: 'unknown-thing'));
      expect(expense.category, ExpenseCategory.other);
    });

    test('parses the date-only value and the ISO createdAt timestamp', () {
      final expense = Expense.fromJson(_json());
      expect(expense.date.year, 2026);
      expect(expense.date.month, 7);
      expect(expense.date.day, 30);
      expect(expense.createdAt, DateTime.parse('2026-07-30T09:12:44.101Z'));
    });
  });

  group('ExpenseCategory.fromWire', () {
    test('maps every generated wire value', () {
      expect(ExpenseCategory.fromWire('food'), ExpenseCategory.food);
      expect(ExpenseCategory.fromWire('date'), ExpenseCategory.date);
      expect(ExpenseCategory.fromWire('travel'), ExpenseCategory.travel);
      expect(ExpenseCategory.fromWire('shopping'), ExpenseCategory.shopping);
      expect(ExpenseCategory.fromWire('other'), ExpenseCategory.other);
    });

    test('falls back to other for null or unrecognized input', () {
      expect(ExpenseCategory.fromWire(null), ExpenseCategory.other);
      expect(ExpenseCategory.fromWire('made-up'), ExpenseCategory.other);
    });
  });
}
