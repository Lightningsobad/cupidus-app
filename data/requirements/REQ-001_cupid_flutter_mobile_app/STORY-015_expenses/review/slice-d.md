# STORY-015 Tier 3 Scoped-Slice Review — Slice D (P4 add-expense flow)

Reviewer: Iris-QC (`RUN-REQ-001_cupid_flutter_mobile_app-STORY-015-reviewer-slice-d`)
BaseHead: `0a467d03babf1ed4102c3fab09c61b2dec941a0b`
Note: persisted by Helen-SC on Iris-QC's behalf — Iris-QC's own write of this
file (and its RunState update) was blocked by `guard-parallel-worktree-scope.sh
[OUT_OF_SCOPE]` / an isolation-worktree mismatch (shared worktree concurrent-
sibling-write false positive; RunState edit also rejected because the agent's
own isolated worktree did not have that control file materialized). Content
below is verbatim from Iris-QC's completed review analysis, transcribed
unedited.

## Files reviewed
(all net-new under BaseHead)
- `mobile/lib/features/expenses/presentation/add_expense_cubit.dart`
- `mobile/lib/features/expenses/presentation/widgets/add_expense_sheet.dart`
- `mobile/test/features/expenses/presentation/add_expense_cubit_test.dart`
- `mobile/test/features/expenses/presentation/add_expense_sheet_test.dart`

## AC1 (add an expense entry)
`AddExpenseCubit.submit()` calls `ExpensesRepository.create(category:,
amountVnd:, description:, date:)` — exactly four fields. Both test files
assert the outgoing request body key set is exactly `{category, amount,
description, date}`. No invented `currency`/split/settlement field. PASS.

## ADR-007 (fail-fast-offline, no optimistic write)
`AddExpenseCubit` holds no `ExpenseDao`/Drift reference at all; on
`NetworkUnavailableFailure`/`TimeoutFailure` it emits `AddExpenseFailedOffline`
directly with no prior local write. Both test files use a real in-memory Drift
database + real `ExpenseDao` and assert `await dao.countAll() == 0` (one also
checks the raw table is empty) after every failure path including
offline/timeout, which is a stronger guarantee than a mocked `verifyNever`.
PASS.

## "Paid by" (ADR-015.2/015.4/015.4a display-only)
`_PaidByRow` is a plain `Row` with no `onTap`/`InkWell`/`GestureDetector`,
wrapped in `Semantics(label: ...)` + `ExcludeSemantics`, exposing no
`button`/`toggled` trait. A dedicated widget test asserts via
`SemanticsNode.flagsCollection` that `isButton == false` and `isToggled !=
Tristate.isTrue`. Confirmed non-interactive/display-only as expected; not
BLOCKING. PASS.

## Test coverage
Both cubit- and widget-level tests cover success, offline/timeout fail-fast,
404 pairing-required, client-side future-date rejection (with a `fail()` guard
against any request being sent), generic 500 failure, 401 rethrow, and a
retry-after-offline-success sequence. Coverage is meaningful, not superficial.
PASS.

## Findings
None (no BLOCKING or NOTE items).

Slice-Verdict: CLEAN
