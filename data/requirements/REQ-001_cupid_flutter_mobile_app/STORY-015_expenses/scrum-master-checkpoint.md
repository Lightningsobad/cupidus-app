# Scrum Master Checkpoint — STORY-015 (Expenses)

- Requirement: REQ-001_cupid_flutter_mobile_app
- Story: STORY-015_expenses
- Last phase executed: P4 — Add-Expense Sheet With Fail-Fast Offline Write
- Phase status: DONE
- Next valid step: dispatch P5 (`phase-P5-pairing-gate-entry-point.md`), depends
  on P4, DONE.

## P4 changed files

- `mobile/lib/features/expenses/presentation/add_expense_cubit.dart` (new)
- `mobile/lib/features/expenses/presentation/widgets/add_expense_sheet.dart`
  (new; adds `Key('addExpenseAmountField')`,
  `Key('addExpenseDescriptionField')`, `Key('addExpenseDateField')` for
  test-targeting)
- `mobile/test/features/expenses/presentation/add_expense_cubit_test.dart` (new)
- `mobile/test/features/expenses/presentation/add_expense_sheet_test.dart` (new)
- `mobile/lib/features/expenses/presentation/expense_strings.dart` (additive
  strings only, for the add-expense sheet's field labels, validation
  messages, and offline/error copy)
- `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart`
  (additive edit: mounts the add-expense action that opens
  `AddExpenseSheet.show`)
- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/coding-plan/master-plan.md` (P4 row → DONE)
- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/coding-plan/phase-P4-add-expense-sheet.md` (§7 Status → DONE)

## P4 Evidence

- `flutter test test/features/expenses/` — 46/46 passed, exit code 0 (27
  pre-existing P1-P3 tests + 8 new `add_expense_cubit_test.dart` tests + 11
  new `add_expense_sheet_test.dart` tests). Zero regressions in any
  pre-existing test.
  - Cubit tests (real in-memory Drift `ExpenseDao`, no mocking package —
    matches this repo's established Dio-`HttpClientAdapter`-fake
    convention): submit success emits `AddExpenseSubmitting` →
    `AddExpenseSuccess` and sends exactly the four contract fields;
    connection error and timeout both map to `AddExpenseFailedOffline` with
    zero Drift rows written (ADR-007 bound (b)); a 404 maps to
    `AddExpensePairingRequired`; a future date is rejected client-side before
    any request is sent (`AddExpenseFutureDate`); an unexpected 500 maps to
    `AddExpenseFailed`; a 401 rethrows rather than emitting a failed state;
    Retry re-invoking `submit()` with the same draft succeeds once
    connectivity returns, with exactly one network attempt per call.
  - Widget tests: sheet reachability and field rendering; Save disabled
    until amount/description/category are all set; offline banner shown
    non-blockingly when offline and absent while online; Save is gated only
    on field validity, never on offline status (`ux/uiux-spec.md` §5 —
    deliberately diverges from `create_memory_sheet.dart`'s
    disable-when-offline precedent); a failed offline submit keeps entered
    data, shows inline retry copy, and writes no Drift row; a 404 shows the
    pairing-required message with data intact; the "Paid by" row is
    non-interactive per ADR-015.2 (verified via `SemanticsNode` flags —
    `isButton`/`isToggled` both false — not via text absence, since
    `ExcludeSemantics` only removes the semantics tree, not the widget
    tree); the date field defaults to today and the calendar cannot navigate
    to a future month; focus returns to the trigger affordance after the
    sheet is dismissed; a successful submit sends exactly the four contract
    fields and pops the sheet.
- `flutter analyze lib/features/expenses/presentation/add_expense_cubit.dart
  lib/features/expenses/presentation/widgets/add_expense_sheet.dart
  lib/features/expenses/presentation/expense_strings.dart
  lib/features/expenses/presentation/screens/expense_history_screen.dart
  test/features/expenses/presentation/add_expense_cubit_test.dart
  test/features/expenses/presentation/add_expense_sheet_test.dart` (scoped to
  this phase's WriteScope files) — **No issues found!**, exit code 0. Initial
  run surfaced 2 `deprecated_member_use` info lints in
  `add_expense_sheet_test.dart` (`SemanticsNode.hasFlag` deprecated since
  Flutter 3.32 in favor of `flagsCollection`); resolved by switching the
  ADR-015.2 assertions to `node.flagsCollection.isButton` /
  `node.flagsCollection.isToggled` (the current `SemanticsFlags` API exposes
  named fields directly rather than a flag set), which required adding
  `import 'dart:ui' show Tristate;` since `Tristate` is imported but not
  re-exported by `package:flutter/semantics.dart`.

## P4 scope note for Scrum Master / Reviewer

- No open items. All 8 required Cubit-level behaviors and all UX §3/§5/§7/§8
  assertions in the phase file's §6 are covered from files inside the
  declared WriteScope, using the same real-Drift / scripted-Dio-adapter,
  no-mocking-package convention established in P1-P3.

## P3 changed files

- `mobile/lib/features/expenses/presentation/expense_strings.dart` (additive
  edit: `weekdayShortLabel` for the 7-bar chart)
- `mobile/lib/features/expenses/presentation/expense_month_summary.dart` (new)
- `mobile/lib/features/expenses/presentation/expense_history_cubit.dart` (new)
- `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart` (new)
- `mobile/lib/features/expenses/presentation/widgets/expense_list_item.dart` (new)
- `mobile/test/features/expenses/presentation/expense_month_summary_test.dart` (new)
- `mobile/test/features/expenses/presentation/expense_history_cubit_test.dart` (new)
- `mobile/test/core/database/timeline_dao_test.dart` (R-015.6 collateral
  one-line fix: `expect(database.schemaVersion, 1)` → `expect(database.schemaVersion, 2)`)
- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/coding-plan/master-plan.md` (P3 row → DONE)
- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/coding-plan/phase-P3-history-screen.md` (§7 Status → DONE)

## P3 Evidence

- `flutter test test/features/expenses/` — 27/27 passed, exit code 0 (6
  pre-existing `expenses_repository_test.dart` + 6 pre-existing
  `expense_models_test.dart` + 6 new `expense_month_summary_test.dart` + 9
  new `expense_history_cubit_test.dart`).
- `flutter test test/core/database/timeline_dao_test.dart` — 6/6 passed,
  exit code 0, confirming the R-015.6 collateral fix resolves P2's documented
  open item with no other regressions.
- `flutter analyze lib/features/expenses test/features/expenses
  test/core/database/timeline_dao_test.dart` (scoped to this phase's
  WriteScope files) — **No issues found!**, exit code 0. Initial run
  surfaced 2 `prefer_initializing_formals` info lints on
  `expense_history_cubit.dart`'s constructor (`_repository`, `_dao`);
  resolved with inline `// ignore: prefer_initializing_formals` comments
  (keeps the named-parameter API as `repository`/`dao` rather than exposing
  private field names as external parameter names) so this scoped gate
  passes cleanly rather than relying on "pre-existing pattern" reasoning
  against a non-zero exit code.
  - Unscoped `flutter analyze lib test` still exits 1 with pre-existing,
    unrelated issues outside this phase's WriteScope: the pervasive
    `prefer_initializing_formals` info lint across dozens of pre-existing
    files, one pre-existing `deprecated_member_use` info, and the 3
    pre-existing `error`-level `undefined_named_parameter` errors in
    `test/features/pairing/presentation/pair_gate_cubit_test.dart` already
    documented out-of-scope in P2's own checkpoint evidence above. Not
    fixed here — outside this phase's WriteScope.

## P3 scope note for Scrum Master / Reviewer

- WriteScope named exactly 2 test files (no dedicated widget-test file),
  while phase file §6 nominally calls for `bloc_test`-based Cubit tests and
  separate widget-level tests (both empty states, freshness caption
  present/absent, who-label for own vs. partner row). `bloc_test` is not a
  dependency anywhere in this repo — matches this codebase's established
  anti-mocking-package convention (e.g. `chat_cubit_test.dart` tests its
  Cubit with plain `test()`, not `blocTest()`). I covered every derived-state
  assertion in §6 using only plain `flutter_test` inside
  `expense_history_cubit_test.dart` (exhaustive coverage of
  `isNeverSynced`/`isGenuinelyEmpty`/`showFreshnessCaption`), and extracted
  the "who" derivation into a public static `ExpenseListItem.isOwnRow(row,
  store)` helper specifically so it is unit-testable without a widget pump
  from the same permitted file. This satisfies the substance of every §6
  assertion from files inside the declared WriteScope. Flagging for
  visibility in case a genuine widget-test-file WriteScope extension is
  wanted as a follow-up — this was not treated as a blocker.

## P2 changed files

- `mobile/lib/core/database/tables/expenses_table.dart` (new)
- `mobile/lib/core/database/daos/expense_dao.dart` (new)
- `mobile/lib/core/database/daos/expense_dao.g.dart` (generated, new)
- `mobile/lib/core/database/cupid_database.dart` (additive edit: register
  `Expenses`, `ExpenseSyncMetadata`, `ExpenseDao`; `schemaVersion` 1 → 2; added
  `MigrationStrategy.onUpgrade` additive upgrade path)
- `mobile/lib/core/database/cupid_database.g.dart` (generated, regenerated)
- `mobile/test/core/database/expense_dao_test.dart` (new)
- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/coding-plan/master-plan.md` (P2 row → DONE, R-015.6 added)
- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/coding-plan/phase-P2-drift-cache-additive.md` (§7 Status → DONE)

## Evidence

- `flutter pub run build_runner build --delete-conflicting-outputs` — codegen
  succeeded (delete-conflicting-outputs flag itself was reported removed/
  ignored by the current build_runner version, no functional impact);
  regenerated `cupid_database.g.dart`, `expense_dao.g.dart`.
- `flutter test test/core/database/expense_dao_test.dart` — 9/9 passed.
- `flutter test test/core/database/` (full directory) — 19/20 passed. Sole
  failure: `timeline_dao_test.dart:36` stale `schemaVersion` literal (`1`,
  should be `2`), STORY-007-owned file outside P2's `WriteScope`. See
  master-plan.md R-015.6. Not fixed here — needs a Scrum Master-routed
  one-line follow-up before this directory's gate is fully green.
- `flutter analyze lib test` — clean for all P2 files (no errors/warnings in
  `expenses_table.dart`, `expense_dao.dart`, `cupid_database.dart`,
  `expense_dao_test.dart`). Remaining findings are pre-existing and unrelated:
  `info`-level lints across the codebase, plus the already-known
  `pair_gate_cubit_test.dart` errors (`createPairGateCubit`/
  `createInviteCubit`/`createJoincodeCubit` undefined named parameters) named
  in this story's handoff as pre-existing/out of scope.
  - Scoped to `lib test` (not bare `flutter analyze`) to skip `build/` — a
    gitignored, untracked iOS SwiftPM checkout artifact under
    `build/ios/SourcePackages/checkouts/flutterfire/...` containing that
    package's own example/test Dart sources, which the analyzer otherwise
    picks up and reports thousands of unrelated errors for. Not deleted
    (destructive `rm -rf` was blocked by the sandbox's safety guard and no
    explicit user confirmation was available in this session); simply
    excluded from the analyze path.

## Open item for Scrum Master

- R-015.6: one-line follow-up needed in
  `mobile/test/core/database/timeline_dao_test.dart:36` — change
  `expect(database.schemaVersion, 1)` to `expect(database.schemaVersion, 2)`.
  Caused by P2's mandated additive `schemaVersion` bump; outside P2's
  `WriteScope` so left untouched by design.
