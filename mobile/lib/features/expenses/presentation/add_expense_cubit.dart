import 'package:cupid_mobile/core/network/cupid_api_failure.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/expense_category.dart';
import '../data/expense_models.dart';
import '../data/expenses_failure.dart';
import '../data/expenses_repository.dart';

/// Draft form values for the Add-Expense sheet
/// (`coding-plan/phase-P4-add-expense-sheet.md` §3). Never persisted
/// anywhere -- the sheet's own [TextEditingController]s are the only place
/// these values live, so a failed submit preserves them simply by never
/// clearing the controllers (ADR-007). Re-submitting the same [category]/
/// [amountVnd]/[description]/[date] after a failure *is* the Retry
/// affordance; there is no separate cubit-side draft cache.
class AddExpenseDraft {
  const AddExpenseDraft({
    required this.category,
    required this.amountVnd,
    this.description,
    required this.date,
  });

  final ExpenseCategory category;
  final num amountVnd;
  final String? description;
  final DateTime date;
}

/// States for [AddExpenseCubit]
/// (`coding-plan/phase-P4-add-expense-sheet.md` §3/§4).
sealed class AddExpenseState {
  const AddExpenseState();
}

/// The sheet is open and awaiting input, or a submit was rejected client
/// -side (empty/invalid fields) before any request was made.
class AddExpenseEditing extends AddExpenseState {
  const AddExpenseEditing();
}

/// A create request is in flight.
class AddExpenseSubmitting extends AddExpenseState {
  const AddExpenseSubmitting();
}

/// The create succeeded. The history list refreshes through the caller's
/// own `ExpenseHistoryCubit.refresh()` call (P3), not through this cubit --
/// [AddExpenseCubit] never touches `ExpenseDao`/Drift itself.
class AddExpenseSuccess extends AddExpenseState {
  const AddExpenseSuccess(this.expense);

  final Expense expense;
}

/// The submit failed on connectivity (ADR-007 bound (b): fail fast, no
/// offline write/outbox queue). Reached only after a real
/// [ExpensesRepository.create] attempt -- never a proactive pre-check --
/// because the sheet is not disabled while offline
/// (`ux/uiux-spec.md` §5: connectivity can change mid-form).
class AddExpenseFailedOffline extends AddExpenseState {
  const AddExpenseFailedOffline();
}

/// The backend 404d the create because the user is not paired.
class AddExpensePairingRequired extends AddExpenseState {
  const AddExpensePairingRequired();
}

/// Rejected client-side for a future calendar date. The sheet's own date
/// picker already blocks selecting a future date, so this is a defensive
/// fallback (e.g. the device clock advances past midnight while the sheet
/// stays open), not the primary future-date guard.
class AddExpenseFutureDate extends AddExpenseState {
  const AddExpenseFutureDate();
}

/// Any other [CupidApiFailure]; generic error copy applies.
class AddExpenseFailed extends AddExpenseState {
  const AddExpenseFailed(this.failure);

  final CupidApiFailure failure;
}

/// Drives the Add-Expense sheet's submit flow
/// (`coding-plan/phase-P4-add-expense-sheet.md`). Calls
/// [ExpensesRepository.create] directly and holds no `ExpenseDao` reference
/// at all -- ADR-007 bound (b) (no offline write/outbox queue, no
/// optimistic insert) is proven by construction rather than by convention:
/// there is no DAO handle anywhere in this class for a bug to accidentally
/// write through on a failed submit.
class AddExpenseCubit extends Cubit<AddExpenseState> {
  AddExpenseCubit(this._repository) : super(const AddExpenseEditing());

  final ExpensesRepository _repository;

  /// Calls [ExpensesRepository.create] at most once per invocation. This
  /// cubit holds no draft state of its own, so re-invoking [submit] with
  /// the same [draft] after a failure *is* the entire Retry affordance --
  /// no separate `retry()` method exists.
  Future<void> submit(AddExpenseDraft draft) async {
    emit(const AddExpenseSubmitting());
    try {
      final Expense expense = await _repository.create(
        category: draft.category,
        amountVnd: draft.amountVnd,
        description: draft.description,
        date: draft.date,
      );
      emit(AddExpenseSuccess(expense));
    } on ExpensesFutureDateFailure {
      emit(const AddExpenseFutureDate());
    } on ExpensesNotPairedFailure {
      emit(const AddExpensePairingRequired());
    } on UnauthorizedFailure {
      rethrow;
    } on CupidApiFailure catch (failure) {
      if (failure is NetworkUnavailableFailure || failure is TimeoutFailure) {
        emit(const AddExpenseFailedOffline());
      } else {
        emit(AddExpenseFailed(failure));
      }
    }
  }
}
