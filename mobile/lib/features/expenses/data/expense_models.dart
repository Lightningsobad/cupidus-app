import 'expense_category.dart';

/// Domain model for one shared expense row (`architecture/solution.md` §2
/// `Expense` row; `coding-plan/master-plan.md` §3 contract).
class Expense {
  const Expense({
    required this.id,
    required this.userId,
    required this.category,
    required this.amountVnd,
    required this.description,
    required this.date,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final ExpenseCategory category;
  final num amountVnd;
  final String? description;
  final DateTime date;
  final DateTime createdAt;

  /// Tolerant of both wire shapes for `amount`: a `String` from
  /// `GET /expenses` (`decimal` column) and a `num` from `POST /expenses`
  /// (TypeORM `save()` echoes the in-memory value) — see R-015.3. Falls back
  /// to [ExpenseCategory.other] for an unrecognized `category` rather than
  /// throwing.
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      userId: json['userId'] as String,
      category: ExpenseCategory.fromWire(json['category'] as String?),
      amountVnd: _decodeAmount(json['amount']),
      description: json['description'] as String?,
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static num _decodeAmount(Object? raw) {
    return switch (raw) {
      num value => value,
      String value => num.parse(value),
      _ => throw FormatException('Unexpected amount wire type: $raw'),
    };
  }
}
