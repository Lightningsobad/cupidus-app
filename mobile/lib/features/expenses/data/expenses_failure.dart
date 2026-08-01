/// The `expenses`-scoped failure family (`architecture/solution.md` §2,
/// ADR-015.7). Kept separate from `CupidApiFailure` — that family is
/// `sealed` to its own library, so a new case cannot be declared here —
/// but callers still only ever catch a typed failure, never a raw
/// `DioException`.
sealed class ExpensesFailure implements Exception {
  const ExpensesFailure();
}

/// AC4: any `/expenses` 404 means "the caller has no partner"
/// (`expenses.service.ts:20-26`), not a generic HTTP error.
class ExpensesNotPairedFailure extends ExpensesFailure {
  const ExpensesNotPairedFailure();
}

/// Client-side guard: a future `date` is rejected before any request is
/// sent (R-015.6), so the server's own future-date check is a backstop,
/// not the primary UX.
class ExpensesFutureDateFailure extends ExpensesFailure {
  const ExpensesFutureDateFailure();
}
