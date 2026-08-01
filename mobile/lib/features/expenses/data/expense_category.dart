import 'package:cupid_mobile/core/network/cupid_api.dart'
    show CreateExpenseDtoCategoryEnum;

/// Expense category, derived from the generated
/// `CreateExpenseDtoCategoryEnum` so a regenerated client cannot drift the
/// value set (`coding-plan/phase-P1-expense-contract-repository.md` §3).
/// `label` is a plain fallback name, not user-facing copy — P3 owns the
/// localized strings in `expense_strings.dart`.
enum ExpenseCategory {
  food(CreateExpenseDtoCategoryEnum.food, 'Food', 'restaurant'),
  date(CreateExpenseDtoCategoryEnum.date, 'Date', 'favorite'),
  travel(CreateExpenseDtoCategoryEnum.travel, 'Travel', 'flight'),
  shopping(CreateExpenseDtoCategoryEnum.shopping, 'Shopping', 'shopping_bag'),
  other(CreateExpenseDtoCategoryEnum.other, 'Other', 'category');

  const ExpenseCategory(this._wireEnum, this.label, this.iconKey);

  final CreateExpenseDtoCategoryEnum _wireEnum;

  /// Fallback display label for P3/P4; not localized (see class dartdoc).
  final String label;

  /// Icon identifier for P3/P4 to resolve to a concrete icon widget.
  final String iconKey;

  /// The exact `CreateExpenseDto.category` wire value.
  String get wireValue => _wireEnum.value;

  /// Falls back to [other] for any category value the client does not
  /// recognize, so a decode never throws on an unrecognized category
  /// (phase P1 acceptance criteria).
  factory ExpenseCategory.fromWire(String? value) {
    for (final category in values) {
      if (category.wireValue == value) {
        return category;
      }
    }
    return ExpenseCategory.other;
  }
}
