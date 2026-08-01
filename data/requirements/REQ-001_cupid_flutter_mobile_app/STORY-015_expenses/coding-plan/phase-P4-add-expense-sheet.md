# Phase P4 – Add-Expense Sheet With Fail-Fast Offline Write

## 1. Objective

Build the Add-Expense bottom sheet (AC1): amount, title, category chips,
display-only "Paid by", date, and the ADR-007 fail-fast offline save with an
explicit user-initiated Retry — no queue, no optimistic insert.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-add-expense-sheet.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/expenses/presentation/add_expense_cubit.dart`
  - `mobile/lib/features/expenses/presentation/widgets/add_expense_sheet.dart`
  - `mobile/test/features/expenses/presentation/add_expense_cubit_test.dart`
  - `mobile/test/features/expenses/presentation/add_expense_sheet_test.dart`
  - `mobile/lib/features/expenses/presentation/expense_strings.dart` (additive strings only)
  - `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart` (mount the add action only)
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A for this phase
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `AddExpenseCubit` states (editing, submitting, failed-offline, success)
  - `AddExpenseSheet` presented from the existing add action
- Shared Interfaces Consumed:
  - P1 `ExpensesRepository.create`, `ExpenseCategory`
  - P3 `ExpenseHistoryCubit.refresh()` (post-success refresh), `expense_strings.dart`
  - `CupidAddAction` (platform-adaptive FAB vs full-width CTA), `CupidPrimaryButton`
- Risk Surfaces:
  - Offline write fail-fast (ADR-007 bound (b)) — the highest-risk surface in this story
  - Contract-field discipline (no invented fields)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §3, §5, §7, §8; `../architecture/solution.md` ADR-015.2, ADR-015.4, ADR-015.4a
  - consumer contract: P5/P6 rely on this sheet's success path refreshing the history list
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1
  - architecture: ADR-015.2 (Paid by is display-only), ADR-015.4 (VND fixed unit), ADR-015.4a (no split), §8 R-015.6 (date handling)
  - OQ constraints: **ADR-007 bound (b) — no offline write queue.** No idempotency field exists in the contract, so a replay queue cannot be duplicate-safe. Fail fast; the only retry is user-initiated.
  - upstream phase outputs: P1 repository, P3 screen + strings
  - UX constraints: §3 (fields, sheet chrome, save enablement), §5 (non-blocking offline banner, fail-fast error + Retry, data preserved, never "queued"), §7 (focus trap, return focus, numeric keyboard, currency in accessible label, selected-state semantics), §8 (44pt/48dp targets)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: create one expense, correctly bounded offline
  - Source/Test File Count: 2 new source + 2 additive edits + 2 test
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §3, §5, §7, §8
- `../architecture/solution.md` ADR-015.2, ADR-015.4, ADR-015.4a and §8 R-015.6
- `mobile/lib/design_system/adaptive/cupid_add_action.dart` — the existing adaptive add affordance to reuse
- `mobile/lib/features/auth/presentation/sign_out_confirm_dialog.dart` — existing modal focus-handling convention

## 3. Tasks

- Create `AddExpenseCubit`:
  - form state for amount (numeric, VND), title/description, category, date
    (defaults to today, future dates blocked);
  - Save enabled once amount + title + category are set (UX §3);
  - `submit()` calls `ExpensesRepository.create` **once**;
  - on success: emit success so the sheet closes and P3's `refresh()` runs;
  - on failure: emit a failed state that **preserves all entered field values**
    and exposes `retry()` for an explicit user-initiated re-attempt;
  - **never** insert into Drift, never emit an optimistic row, never schedule a
    background retry, never persist a draft (ADR-007).
- Create `add_expense_sheet.dart`:
  - bottom sheet with the drag handle, `--r-sheet`-equivalent radius, dismiss via
    drag-down / backdrop tap / close button;
  - amount field with numeric keyboard and the currency unit in the **accessible
    label**, not only as trailing visual text (UX §7);
  - category chips reusing the P3 filter-chip style, driven by `ExpenseCategory`
    (all five values: food, date, travel, shopping, other) with semantic selected
    state exposed to assistive tech, not colour-only;
  - **"Paid by" is a non-interactive display row reading "You/Bạn"** — per
    ADR-015.2 the server derives `userId` from the JWT and the contract has no
    `paidBy` field. Do **not** build a partner toggle even though UX §3 describes
    one; that is a resolved contract conflict, not an omission.
  - date field defaulting to today, future dates not selectable;
  - non-blocking informational banner when the device is already offline as the
    sheet opens (the sheet is **not** disabled — connectivity can change mid-form);
  - inline error + Retry on save failure, with entered data intact;
  - focus trap while open, return focus to the triggering add action on dismiss.
- Mount the add action in `expense_history_screen.dart` via `CupidAddAction` so
  Android gets the FAB and iOS the full-width CTA from one widget instance. Do not
  add a second, separately-styled entry point.
- Copy discipline: no "queued", "will sync", "saved locally", or "pending" wording
  anywhere in this phase (UX §5, ADR-007). No split, share, percentage, or balance
  control (ADR-015.4a). No currency selector (ADR-015.4).

## 4. Acceptance Criteria

- A paired user online can add an expense and see it at the top of the list, with
  the month total and chart updating (AC1).
- The `POST` body contains exactly `category`, `amount`, `description`, `date` —
  no `userId`, `paidBy`, `currency`, or split field.
- Offline save fails fast: no spinner persists, no row is inserted into Drift, no
  optimistic list entry appears, and the sheet stays open with data intact plus a
  Retry affordance.
- Retry re-attempts the same submission and succeeds once connectivity returns.
- "Paid by" is present but non-interactive.
- Future dates cannot be selected or submitted.
- Sheet traps focus and returns focus to the add action on dismiss.
- `flutter analyze` clean.

## 5. Planned Outputs

- Code directories or files: the Write Scope files
- Contracts or schemas: `AddExpenseCubit` state model
- Requirement configuration guide updates: none
- Notes or evidence: test output in §7

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, presentation
- Required levels:
  - `bloc_test`: success path emits success once; failure path preserves field
    values and exposes retry; **assert no optimistic state emission and no
    `ExpenseDao` write on failure** (mock DAO with `verifyNever`)
  - widget: Save disabled until amount+title+category set; offline banner present
    when starting offline; inline error + Retry after a failed save with fields
    still populated; "Paid by" row is non-interactive; future date not selectable;
    focus returns to the add action on dismiss
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: assert the outgoing request body key set equals the four
  contract fields; assert absence of "queued"/"will sync"-style copy; assert no
  split/balance/currency-selector widget exists
- Mobile discoverability / navigation integration: the add action is reachable from
  the history screen via one `CupidAddAction` instance (single entry point)
- Minimum gates by risk surface: ADR-007 ⇒ the `verifyNever` no-write/no-optimistic
  test is mandatory and is the phase's blocking gate
- Required regression or contract coverage: request-body key-set assertion against
  `CreateExpenseDto`
- Evidence format: `flutter test` + `flutter analyze` output excerpt in §7
- Verification strategy:
  - Targeted tests/regression/contract checks: the two test files above
  - Build/type-check/lint command when required: `flutter analyze`, `flutter test test/features/expenses/`
  - Required assertion evidence: passing no-optimistic-write test and the
    offline-error-with-data-intact widget test

## 7. Status

- Status: DONE
- Last updated: 2026-08-01
- Evidence: `flutter test test/features/expenses/` -> `00:02 +46: All tests passed!`
  (8 new cubit tests in `add_expense_cubit_test.dart`, 11 new widget tests in
  `add_expense_sheet_test.dart`, zero regressions in the 27 pre-existing
  P1-P3 tests). `flutter analyze` scoped to the phase's WriteScope files ->
  `No issues found!`. Full evidence recorded in
  `scrum-master-checkpoint.md` under "P4".
