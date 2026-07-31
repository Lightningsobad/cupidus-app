# Phase P3 – Shared History Screen, Offline States, Month Summary

## 1. Objective

Build the `expense` history screen: paged read-through list from Drift, the
client-side month summary (total, delta, 7-bar chart), category filter chips, the
offline freshness caption, and the two non-interchangeable empty states.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-history-screen.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/expenses/presentation/expense_strings.dart`
  - `mobile/lib/features/expenses/presentation/expense_month_summary.dart`
  - `mobile/lib/features/expenses/presentation/expense_history_cubit.dart`
  - `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart`
  - `mobile/lib/features/expenses/presentation/widgets/expense_list_item.dart`
  - `mobile/test/features/expenses/presentation/expense_month_summary_test.dart`
  - `mobile/test/features/expenses/presentation/expense_history_cubit_test.dart`
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
  - `ExpenseHistoryCubit` states (loading, loaded+page, never-synced, empty, offline-with-cache, error)
  - `ExpenseMonthSummary` aggregation result
  - `expense_strings.dart` — the single copy source for this feature
- Shared Interfaces Consumed:
  - P1 `ExpensesRepository`, `Expense`, `ExpenseCategory`
  - P2 `ExpenseDao` (paging, `monthRows`, `lastSuccessfulSyncAt`, `countAll`)
  - `CupidHeader`, design-system tokens, `CupidIcons`
- Risk Surfaces:
  - Offline read (AC3)
  - Money-number correctness under a partial cache (R-015.5)
  - Shared-not-per-user dataset (AC2)
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §4, §5, §7; `../architecture/solution.md` ADR-015.2, ADR-015.3, ADR-015.5
  - consumer contract: P4 and P5 mount into this screen; they do not restate its state model
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC2, AC3
  - architecture: ADR-015.2 (`who` derivation), ADR-015.3 (client-side aggregation, hide delta when incomplete), ADR-015.5 (two empty states)
  - OQ constraints: ADR-007 — read-through cache; never render "queued"/"will sync" copy anywhere
  - upstream phase outputs: P1 repository/models, P2 DAO
  - UX constraints: §4 (shared dataset, no per-partner filter, paged list), §5 (freshness caption only while offline; distinct never-synced copy), §7 (no colour/icon-only signals)
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: readable shared history with correct offline and empty states
  - Source/Test File Count: 5 source + 2 test
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §4, §5, §7 (do not read the whole spec; §3 belongs to P4 and §6 to P5)
- `../architecture/solution.md` ADR-015.2, ADR-015.3, ADR-015.5
- `mobile/lib/features/auth/presentation/auth_strings.dart` — the strings-file convention to mirror
- `mobile/lib/design_system/design_system.dart` — available tokens and adaptive widgets

## 3. Tasks

- Create `expense_strings.dart` holding every VN/EN string this feature needs,
  including the two distinct empty-state messages from UX §5. The never-synced
  copy and the zero-expenses copy must **not** share a constant.
- Create `ExpenseMonthSummary` (pure function / value type) computing from cached
  rows: current-month total, per-day buckets for the 7-bar chart, item count, and
  the vs-last-month delta. Per ADR-015.3, return the delta as **absent** unless
  the cached rows demonstrably cover the whole previous month — never emit a
  delta computed from a partial cache.
- Create `ExpenseHistoryCubit` implementing read-through:
  1. emit cached page immediately from `ExpenseDao`;
  2. attempt `ExpensesRepository.fetchPage`; on success `upsertAll` + `markSyncedNow()` and re-emit;
  3. on failure keep the cached page and mark the state offline/stale rather than erroring out;
  4. expose `loadMore()` for offset paging and `refresh()` for pull-to-refresh and screen-focus refresh;
  5. distinguish never-synced (`lastSuccessfulSyncAt == null` and `countAll() == 0`) from genuinely empty (`countAll() == 0` with a timestamp).
- Create `expense_list_item.dart` rendering icon, title, `who · date`, and amount.
  `who` is derived per ADR-015.2 — `You/Bạn` vs `Partner/Người ấy` by comparing
  `expense.userId` to the id from `BackendUserIdStore`. **Do not** render literal
  partner names; no partner-profile endpoint exists.
- Create `expense_history_screen.dart` with the month summary header, freshness
  caption (visible only while offline, always paired with text per UX §7), 7-bar
  chart, category filter chips (client-side filter over the loaded dataset, no new
  query), paged list, and both empty states. Amounts render in VND as a fixed
  unit (ADR-015.4) using the monospace amount styling.
- Category chips filter by category only. **Never** add a "my expenses" /
  "partner's expenses" filter (UX §4 — the dataset is shared).
- Do not render any balance, split, percentage, "who owes whom", or Dream-Jar-style
  comparative standing (ADR-015.4a).
- Leave a mount point for P4's add action and P5's gate; do not implement either here.

## 4. Acceptance Criteria

- With cached rows and no connectivity, the list renders normally plus the
  freshness caption (AC3).
- Never-synced state shows the "connect to load for the first time" copy; a
  synced-but-empty couple shows the ordinary "no expenses yet" copy. The two are
  different strings.
- The delta is hidden when the cache does not cover the previous month, and shown
  when it does.
- `loadMore()` appends the next offset page; the whole table is never held in
  Cubit state.
- `who` shows You/Partner correctly for both own and partner rows.
- No "queued"/"will sync later" copy exists anywhere in the phase output.
- `flutter analyze` clean.

## 5. Planned Outputs

- Code directories or files: the seven Write Scope files
- Contracts or schemas: `ExpenseHistoryCubit` state model, `ExpenseMonthSummary`
- Requirement configuration guide updates: none
- Notes or evidence: test output in §7

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, presentation
- Required levels:
  - unit: `ExpenseMonthSummary` — total, per-day buckets, delta present with a
    full-previous-month fixture, delta **absent** with a partial-cache fixture
  - `bloc_test`: cached-first emission; success path upserts + marks synced;
    fetch failure keeps cached page and flags offline; never-synced vs empty
    discrimination; `loadMore` offset progression
  - widget: never-synced empty state, zero-expenses empty state, offline freshness
    caption present/absent, `who` label for own vs partner row
  - mobile build/type-check/static-analysis: `flutter analyze`
- Required checks: grep the phase output for "queued"/"sẽ đồng bộ"-style copy and
  assert absence; assert no per-partner filter control exists
- Mobile discoverability / navigation integration: deferred to P5 (this screen is
  not yet routed)
- Minimum gates by risk surface: AC3 ⇒ offline widget test; R-015.5 ⇒
  partial-cache delta unit test; AC2 ⇒ shared-dataset widget assertion
- Required regression or contract coverage: the two empty-state strings must not
  be equal
- Evidence format: `flutter test` + `flutter analyze` output excerpt in §7
- Verification strategy:
  - Targeted tests/regression/contract checks: the two test files above plus
    widget tests colocated per repo convention
  - Build/type-check/lint command when required: `flutter analyze`, `flutter test test/features/expenses/`
  - Required assertion evidence: passing partial-cache delta test and both
    empty-state widget tests

## 7. Status

- Status: DONE
- Last updated: 2026-08-01
- Evidence: `flutter test test/features/expenses/` 27/27 passed, exit 0
  (includes new `expense_month_summary_test.dart` and
  `expense_history_cubit_test.dart`); `flutter test
  test/core/database/timeline_dao_test.dart` 6/6 passed, exit 0 (collateral
  R-015.6 schema-version fix); scoped `flutter analyze lib/features/expenses
  test/features/expenses test/core/database/timeline_dao_test.dart` — **No
  issues found!**, exit 0 (two initial `prefer_initializing_formals` info
  lints on `expense_history_cubit.dart`'s constructor resolved via inline
  `// ignore:` comments). Unscoped `flutter analyze lib test` still exits 1
  on pre-existing, out-of-WriteScope issues only (pervasive
  `prefer_initializing_formals` elsewhere, one pre-existing
  `deprecated_member_use` info, and the 3 pre-existing
  `pair_gate_cubit_test.dart` errors already documented out-of-scope in P2's
  checkpoint) — not fixed here as out of this phase's WriteScope.
- Scope note: the WriteScope for this phase names two test files (no
  dedicated widget-test file) despite §6 nominally calling for `bloc_test`
  and widget-level tests. `bloc_test` is not a dependency anywhere in this
  repo (matches the repo's established anti-mocking-package convention,
  e.g. `chat_cubit_test.dart`), so every derived-state assertion in §6
  (both empty states, freshness caption, who-label for own vs. partner row)
  is instead covered with plain `flutter_test` against `ExpenseHistoryCubit`
  state and a public static `ExpenseListItem.isOwnRow(row, store)` helper
  extracted specifically to be unit-testable without a widget pump. Flagged
  for Scrum Master/Reviewer awareness as a scope-interpretation decision,
  not a blocker — the substance of every §6 assertion is covered.
