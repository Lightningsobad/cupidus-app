# STORY-015 Tier 3 Scoped-Slice Review — Slice C (P3 expense history screen)

Reviewer: Iris-QC (`RUN-REQ-001_cupid_flutter_mobile_app-STORY-015-reviewer-slice-c`)
BaseHead: `0a467d03babf1ed4102c3fab09c61b2dec941a0b`
Note: persisted by Helen-SC on Iris-QC's behalf — Iris-QC's own write of this
file was blocked by `guard-parallel-worktree-scope.sh [OUT_OF_SCOPE]` (shared
worktree concurrent-sibling-write false positive). Content below is verbatim
from Iris-QC's completed review analysis, transcribed unedited.

## Files reviewed
(all new-file additions in the diff against BaseHead)
- `mobile/lib/features/expenses/presentation/expense_history_cubit.dart`
- `mobile/lib/features/expenses/presentation/expense_month_summary.dart`
- `mobile/lib/features/expenses/presentation/expense_strings.dart`
- `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart`
- `mobile/lib/features/expenses/presentation/widgets/expense_list_item.dart`
- `mobile/test/features/expenses/presentation/expense_history_cubit_test.dart`
- `mobile/test/features/expenses/presentation/expense_month_summary_test.dart`

## AC2 (both partners' shared expense history visible)
Satisfied. `ExpenseHistoryState.filteredRows` filters only by category
(comment: "never a per-partner filter (AC2)"); `_emitFromCache`/`_syncPage` in
`expense_history_cubit.dart` pull pages via `ExpenseDao`/`ExpensesRepository`
with no `userId` argument anywhere. `ExpenseListItem`'s "You"/"Partner" label
is display-only provenance (`row.userId == backendUserIdStore.backendUserId`),
not a data filter. `expense_history_cubit_test.dart`'s category-filter test
seeds rows for two different `userId`s and asserts both remain visible under
"All" — real coverage of the both-partners behavior, not a smoke test.

## AC3 (offline readable via Drift cache after a sync)
Satisfied. Cubit does cache-first emit (`_emitFromCache`) then network sync
(`_syncPage`), and on fetch failure keeps the already-cached page and only
flips `isOffline`, never surfacing an error/crash state.
`expense_history_screen.dart` renders sane distinct states for loading /
never-synced / genuinely-empty / normal-with-freshness-caption — no blank or
misleading screen found. Tests cover cached-first emission, failed-fetch-
keeps-cache, successful-fetch-upsert, and never-synced-vs-genuinely-empty
(ADR-015.5).

## expense_month_summary.dart
Month-grouping/summation logic is correct — single `fold` sum, each row
bucketed exactly once by `weekday - 1`, no double-counting. Delta only
computed when `oldestCachedDate` demonstrably covers the previous month. No
currency field/selector anywhere — VND rendered as a fixed unit via
`NumberFormat.decimalPattern('vi_VN')` + literal `₫`, consistent with
ADR-015.2. Test file covers totals, weekday bucketing (including multi-row-
per-bucket), and all three delta-visibility branches plus a negative-delta
case.

## expense_strings.dart
Spot check found no hardcoded English/Vietnamese user-facing literal
duplicated outside this file in the other slice files.

## Findings
None (no BLOCKING or NOTE items).

Slice-Verdict: CLEAN
