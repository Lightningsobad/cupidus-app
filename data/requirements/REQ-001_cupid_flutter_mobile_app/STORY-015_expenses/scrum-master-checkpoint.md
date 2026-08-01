# Scrum Master Checkpoint — STORY-015 (Expenses)

- Requirement: REQ-001_cupid_flutter_mobile_app
- Story: STORY-015_expenses
- Last phase executed: P6 — Verification (final phase)
- Phase status: DONE
- Next valid step: all phases P1-P6 DONE. Scrum Master to commit P6, refresh
  Story Git Boundary base, verify review-readiness, and route the standard-tier
  Reviewer story gate to Iris-QC.

## P5 changed files

- `mobile/lib/features/expenses/data/pairing_state_reader.dart` (new) —
  ADR-015.7 seam consuming STORY-012's `CouplePairingStore.resolve()`
  (`GET /users/me`, `partnerId != null` ⇒ paired); never optimistic (returns
  `false` for both `unpaired` and `unknown`).
- `mobile/lib/features/expenses/presentation/widgets/pairing_required_gate.dart`
  (new) — dedicated AC4 gate screen (`ux/uiux-spec.md` §6 copy), one primary
  action opening `InviteScreen`.
- `mobile/lib/features/expenses/expenses_route.dart` (new) — `expensesRoute`
  constant, `ExpensesEntryPoint` composition root (resolves the gate once per
  mount, mirrors `SplashScreen`/`_TimelineEntryPointGate`), and the
  `_NotPairedWatchingRepository` decorator wiring ADR-015.7's secondary
  corroborating signal (a mid-session `ExpensesNotPairedFailure` flips an
  already-open screen to the gate).
- `mobile/lib/features/expenses/presentation/expense_strings.dart` (additive:
  `pairingGateMessage`, `pairingGateActionLabel`).
- `mobile/lib/core/di/service_locator.dart` (additive registrations:
  `ExpenseDao`, `ExpensesRepository`, `PairingStateReader`,
  `ExpenseHistoryCubit` factory, `AddExpenseCubit` factory).
- `mobile/lib/features/home/presentation/home_screen.dart` (additive edit:
  `_ExpensesEntryCard` appended after the Timeline entry, navigating to
  `ExpensesEntryPoint`; `Key('home_screen_ready_signal')` untouched. Also
  fixed a pre-existing `prefer_initializing_formals` lint on the
  `_resolvePairingStatus` field by moving its `// ignore:` comment to a
  trailing inline position on the first initializer-list assignment,
  matching the placement rule already used in `pairing_state_reader.dart`
  and `expenses_route.dart` — this file is in this phase's own Write Scope,
  so fixing it here is in-scope, not a sibling-file fix).
- `mobile/test/features/expenses/pairing_gate_test.dart` (new).
- `mobile/test/features/expenses/expenses_entry_point_test.dart` (new).
- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/coding-plan/master-plan.md` (P5 row → DONE)
- `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/coding-plan/phase-P5-pairing-gate-entry-point.md` (§7 Status → DONE)

## P5 Evidence

- `flutter test test/features/expenses/ test/features/home/` — 61/61 passed,
  exit code 0 (all pre-existing P1-P4 tests plus the two new P5 test files;
  zero regressions).
  - `PairingStateReader.isPaired`: true when `CouplePairingStore` resolves
    `paired`; false when it resolves `unpaired`; false (never optimistic)
    when it cannot confirm a status (a `DioException`/`UnexpectedFailure`).
  - `PairingRequiredGate`: shows the dedicated message + action (never a
    generic error/empty state); tapping the action navigates into
    `InviteScreen`.
  - `ExpensesEntryPoint`: unpaired ⇒ gate only, never `ExpenseHistoryScreen`;
    paired ⇒ `ExpenseHistoryScreen`, never the gate; a mid-session
    `ExpensesNotPairedFailure` from a wrapped repository call flips an
    already-open screen to the gate (ADR-015.7 secondary corroborating
    signal).
  - `HomeScreen` entry affordance: `home_screen_ready_signal` and
    `home_expenses_entry_card` both render; tapping the card navigates into
    `ExpensesEntryPoint`.
  - Two test-authoring issues found and fixed during verification, both
    isolated to the new test files (no production-code changes):
    1. `expenses_entry_point_test.dart`'s mid-session-flip test originally
       asserted an intermediate "still showing `ExpenseHistoryScreen`" state
       after a single `pumpAndSettle()`; `pumpAndSettle()` had already
       drained the full async chain to completion by the time it returned,
       so only the final settled state (gate shown) is asserted now.
    2. `pairing_gate_test.dart`'s InviteScreen-navigation test used
       `pumpAndSettle()` after the tap, which timed out: `InviteScreen`'s
       loading state renders a `CircularProgressIndicator`, whose implicit
       repeating animation never settles while
       `_NeverReadyPairingRepository.generateInvitation()`'s intentionally
       never-completing future stays unresolved. Fixed by using a single
       `pump()` (process the tap) followed by a bounded
       `pump(Duration(milliseconds: 300))` (complete the
       `MaterialPageRoute` push transition) instead of `pumpAndSettle()`.
    3. `expenses_entry_point_test.dart`'s `HomeScreen` entry-affordance test
       initially failed a hit-test: `_ExpensesEntryCard` sits below the fold
       of the default 800x600 test viewport once appended after the
       Timeline entry inside `home_screen.dart`'s `SingleChildScrollView`
       (by design — see that file's doc comment). Fixed by calling
       `tester.ensureVisible(find.byKey(Key('home_expenses_entry_card')))`
       before the tap; no production-code change.
- `flutter analyze lib/features/expenses/data/pairing_state_reader.dart
  lib/features/expenses/presentation/widgets/pairing_required_gate.dart
  lib/features/expenses/expenses_route.dart
  lib/features/expenses/presentation/expense_strings.dart
  lib/core/di/service_locator.dart
  lib/features/home/presentation/home_screen.dart
  test/features/expenses/pairing_gate_test.dart
  test/features/expenses/expenses_entry_point_test.dart` (the full phase
  Write Scope, including `home_screen.dart`) — **No issues found!**, exit
  code 0. All new code in this phase's own files (`pairing_state_reader.dart`,
  `expenses_route.dart`) is lint-clean, using
  `// ignore: prefer_initializing_formals` comments where a
  multi-parameter nullable-override constructor pattern (matching P3's
  precedent) would otherwise trigger the same lint; the correct placement
  for a multi-line initializer list is a trailing inline comment on the
  *first* assignment plus a comment on its own line above each subsequent
  assignment — placing the comment above the constructor declaration
  itself does not suppress any of the initializer-list lines. This same
  placement rule was also applied to `home_screen.dart`'s pre-existing
  `_resolvePairingStatus` field, which carried this lint with an
  ineffective (wrongly placed) `// ignore:` comment predating this phase;
  since `home_screen.dart` is in this phase's own Write Scope, fixing it
  is in-scope. `flutter analyze` now reports zero issues across the full
  Write Scope, satisfying §4 AC "`flutter analyze` clean" without
  exception.

## P5 scope note for Scrum Master / Reviewer

- No named-routes table exists anywhere in this codebase (confirmed per
  §1C's Entry-Point Constraint), so `expensesRoute` is a plain string
  constant for future use, not a live `MaterialApp.routes` entry; the actual
  navigation is a direct `MaterialPageRoute` push, matching every other
  entry card in `home_screen.dart`.
- `PairingRequiredGate`'s primary action always opens `InviteScreen`
  regardless of which pairing state (`unpaired` vs. an invitation already in
  progress) the account is actually in. This is intentional:
  `PairingRepository.generateInvitation()` is idempotent (returns the
  existing active code if one exists), so a single fixed target already
  covers every underlying pairing state without the gate needing to
  distinguish them — confirmed by reading `pairing_repository.dart` before
  this decision was made, not assumed.
- ADR-015.7's secondary corroborating signal is implemented as a
  repository-level decorator (`_NotPairedWatchingRepository implements
  ExpensesRepository`) inside `expenses_route.dart`, rather than inside
  `expense_history_cubit.dart` itself. `ExpenseHistoryCubit`'s
  construction-time auto-fetch swallows all fetch failures with a generic
  `catch (_)`, and that file was outside this phase's `WriteScope`, so the
  decorator is the seam that lets a 404 surfaced mid-session still flip the
  gate without touching frozen P3 code.
- `expenses_entry_point_test.dart`'s `HomeScreen` entry-affordance test
  verifies the tap reaches the real `ExpensesEntryPoint` navigation target
  and that its own gate resolves (using an unpaired fake, since setting up a
  paired `CouplePairingStore` fixture from `HomeScreen`'s constructor-level
  seam is out of this phase's scope). The paired path all the way to
  `ExpenseHistoryScreen` is separately covered by
  `ExpensesEntryPoint`'s own "paired" test in the same file — combined,
  both phase-file §4/§6 requirements ("reachable by tapping a visible
  affordance" and "entry → history screen" navigation coverage) are met,
  just split across two tests rather than one single test walking
  `HomeScreen` → `ExpenseHistoryScreen` end to end.

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

## P6 verification (final phase)

- Status: DONE. Evidence in
  `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-015_expenses/coding-plan/test-results.md`.
- Scoped `flutter analyze` (STORY-015 write-scope files) — clean, no issues.
- Scoped `flutter test test/features/expenses test/core/database test/features/home`
  — 81/81 passed, 0 failures.
- `flutter build apk --debug` — succeeded,
  `build/app/outputs/flutter-apk/app-debug.apk` built.
- AC1-AC4 traceability table filled in `test-results.md`, all PASS.
- R-015.1: exactly one `@DriftDatabase` class (`CupidDatabase`) — not blocked.
- `home_screen_ready_signal` key confirmed intact.
- ADR-007 bounds verified by inspection (no outbox table, no optimistic
  insert, no background retry, no "queued"/"will sync" copy).
- 3 deliberate UX deviations (non-interactive "Paid by", no partner display
  names, client-side summary not `/expenses/report`) confirmed shipped as
  decided.
- `master-plan.md` P6 row → DONE; `phase-P6-verification.md` §5 Status → DONE.

### Open items for Scrum Master (pre-existing, out of scope, not fixed here)

- 8 `flutter test` failures (full-project run only, none in STORY-015's own
  scoped run) share root cause `StateError: CouplePairingStore is not
  registered inside GetIt`, from `HomeScreen._defaultResolvePairingStatus`
  (introduced by STORY-012's Timeline feature, confirmed via diff of P5's
  `home_screen.dart` commit — P5's change is purely additive and never
  touches that code path). Affects `test/widget_test.dart` (top-level app-boot
  smoke test — flagged prominently), `app_shell_test.dart` (×2),
  `feature_flags_test.dart`, `gallery_cubit_test.dart`, `vibe_screen_test.dart`,
  `pet_entry_point_test.dart`, `reminder_entry_point_test.dart`.
- 1 `flutter test` failure + 3 `flutter analyze` errors:
  `test/features/pairing/presentation/pair_gate_cubit_test.dart` calls
  `AppShell(createPairGateCubit: ..., createInviteCubit: ...,
  createJoincodeCubit: ...)` — those constructor params belong to
  `PairGateShell`, not `AppShell`. Confirmed pre-existing on
  `codex/REQ-001_cupid_flutter_mobile_app-integration` via `git show`.
- 1 `flutter test` failure: `reminder_copy_guard_test.dart` scans a generated
  l10n file for a forbidden reminders-feature term — unrelated to expenses.
- 76 `prefer_initializing_formals` info-lints + 1 `use_null_aware_elements`
  info + 1 `deprecated_member_use` warning scattered across other feature
  lanes (pairing, reminders, vibes, chat, anti_ghosting, auth, dream_jar,
  gallery, core/realtime, core/navigation) — pre-existing, not STORY-015.
- Recommend routing the `CouplePairingStore`/GetIt registration gap and the
  `pair_gate_cubit_test.dart` constructor mismatch as separate follow-up work
  (pairing/timeline lane) — not blocking STORY-015.

`MOBILE_COMPLETE: YES` reported to team-lead for RunId
`RUN-REQ-001_cupid_flutter_mobile_app-STORY-015-mobile-dev-p6`. Scrum Master
still owns commit/merge for this story.
