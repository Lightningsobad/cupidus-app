# Retro-Audit: STORY-015 Epic-5 — Chi Tiêu Chung (Shared Expenses)

Run Key: 2026-08-12:REQ-001:STORY-015:retro-audit
Independent requirement-authority audit against current `main`
(`f7d06fd4737cc7edbe6f6e33c205bf77fdf26f67` — matches this handoff's `BaseHead`).
Prior `review/review-report.md` (`Outcome: CLEAN`, Tier-3 five-slice synthesis)
used as context only; every finding below is re-derived from direct
source/test inspection or a fresh command execution, not from re-reading and
trusting that report.

## Method

Read `story_master.md`, `ux/uiux-spec.md` (§1-§9), `architecture/solution.md`
(§0-§9, full file, 167 lines), `coding-plan/master-plan.md`,
`coding-plan/test-results.md`, `review/review-report.md`, `req_master.md`,
`data/intake/bootstrap/conflicts_open_questions.md`,
`data/devops/system/design-fidelity-config.json`, and
`integration-review/mobile-visual-audit.md`.

Cross-checked against current source (all read in full, not excerpted):
`mobile/lib/features/expenses/data/{expenses_repository.dart,expense_models.dart,pairing_state_reader.dart}`,
`mobile/lib/features/expenses/presentation/{add_expense_cubit.dart,expense_history_cubit.dart,expense_strings.dart}`,
`mobile/lib/features/expenses/presentation/widgets/add_expense_sheet.dart`,
`mobile/lib/features/expenses/expenses_route.dart`,
`mobile/lib/core/database/daos/expense_dao.dart`,
`mobile/lib/core/database/tables/expenses_table.dart`,
`mobile/lib/core/database/cupid_database.dart`,
`mobile/lib/features/home/presentation/home_screen.dart` (full file, 325 lines),
plus `git blame` on the shared `home_screen.dart` constructor and
`git show HEAD:mobile/test/core/database/timeline_dao_test.dart` for the
R-015.6 collateral-fix claim.

**Unlike prior story-level audits in this wave, `flutter`/`dart` were
available in this session** (`$HOME/flutter/bin/flutter`, not on `PATH`),
so the two claimed P6 gates were re-run directly rather than taken on faith:

- `flutter analyze lib/features/expenses test/features/expenses lib/core/database test/core/database lib/core/di/service_locator.dart lib/features/home/presentation/home_screen.dart` — re-run, full untruncated output captured.
- `flutter test test/features/expenses test/core/database test/features/home` — re-run, full untruncated output captured.

`git ls-files` confirms the story's full implementation file set (14
`lib/` files, 8 `test/` files) and that no `backend/` path appears anywhere
in it — independently corroborating the review report's diff-coverage claim
without re-trusting its narrative.

## Acceptance Criteria — independently re-verified

| AC | Result | Evidence |
|----|--------|----------|
| AC1 — a paired user can add an expense entry | PASS | `expenses_repository.dart:33-59` `create()` posts exactly `{category, amount, description?, date}` via `_api.dio.post` (Dio-direct, ADR-015.1) and rejects a future date client-side before the request is issued. `add_expense_cubit.dart:101-124` `submit()` calls it once, mapping `ExpensesFutureDateFailure`/`ExpensesNotPairedFailure`/network failures to distinct states. `add_expense_sheet.dart` wires a real `AddExpenseSheet` with amount/description/category/date fields and a Save button gated on `_fieldsValid`. Re-ran `add_expense_sheet_test.dart` myself — `"a successful submit sends exactly the four contract fields and pops the sheet"` passed against a real (mocked-HTTP) `POST /expenses` → 201. |
| AC2 — both partners can view shared expense history | PASS | `expense_history_cubit.dart`'s `ExpenseHistoryState.filteredRows` (`:83-89`) filters by `selectedCategory` only — no `userId` parameter reaches `ExpenseDao.getPage`/`watchPage` (`expense_dao.dart:26-45`) or `ExpensesRepository.fetchPage` anywhere. `expense_strings.dart` `whoYou`/`whoPartner` are read-only attribution labels, never a filter predicate. |
| AC3 — history readable offline after ≥1 sync; new entries still require connectivity | PASS | Read half: `_emitFromCache()` (`expense_history_cubit.dart:180-199`) renders from `ExpenseDao` before any network call; `_syncPage()`'s `catch` (`:237-243`) keeps the cached page and only flips `isOffline`, never surfaces an error state (ADR-007). `isNeverSynced`/`isGenuinelyEmpty`/`showFreshnessCaption` getters (`:64-79`) correctly discriminate the two empty states on `lastSuccessfulSyncAt`+`cachedRowCount`, matching ADR-015.5. Write half is a **structural** guarantee: `ExpenseDao` (`expense_dao.dart`) exposes only `upsertAll` (server-fetched rows), `getPage`/`watchPage`/`monthRows` (reads), `lastSuccessfulSyncAt`/`markSyncedNow`, `countAll` — no user-authored insert method exists anywhere in the class. `AddExpenseCubit` (`add_expense_cubit.dart:92-125`) holds no `ExpenseDao` field at all — confirmed by reading the full class, not just its dartdoc claim. |
| AC4 — unpaired users cannot access this feature | PASS | `expenses_route.dart`'s `ExpensesEntryPoint` (`:28-95`) resolves `PairingStateReader.isPaired()` once per mount and renders `PairingRequiredGate` instead of `ExpenseHistoryScreen` when `false`; `PairingStateReader.isPaired()` (`pairing_state_reader.dart:17-20`) returns `false` for both `unpaired` and `unknown`, never optimistic. A secondary corroborating signal (`_NotPairedWatchingRepository`, `:104-139`) flips an already-open screen back to the gate if any wrapped call later 404s. `home_screen.dart:140-147` `_ExpensesEntryCard` always navigates to `ExpensesEntryPoint` — it does not duplicate or bypass the gate. |

All four ACs independently confirmed PASS from current source and, for AC1,
from a test I re-ran myself against a live HTTP mock rather than trusting
the prior report's description of it.

## Governing Constraints — spot-checked against current source

- **ADR-007** (read-through server-authoritative cache; no offline
  write/outbox) — HOLDS. `expenses_table.dart` has cache columns only, no
  pending/outbox column; `expense_dao.dart` has no user-write method;
  `add_expense_cubit.dart` holds no DAO reference; `expense_strings.dart`'s
  `addSaveFailedOffline` renders "No connection — try again" /
  "Không có kết nối — thử lại" — I read every string in `expense_strings.dart`
  end to end and found no "queued"/"will sync" copy anywhere in the file.
- **ADR-015.2** (no client-settable "paid by", no partner display names) —
  HOLDS. `add_expense_sheet.dart`'s `_PaidByRow` (`:308-340`) is a plain
  `Row` inside `Semantics`+`ExcludeSemantics` with no `onTap`/`InkWell`/
  `GestureDetector` anywhere — confirmed by reading the whole widget, not
  just its doc comment. `whoYou`/`whoPartner` always resolve to "Bạn"/
  "Người ấy" ("You"/"Partner"), never a literal name.
- **ADR-015.3** (client-side monthly aggregation, not `/expenses/report`) —
  HOLDS. `expenses_repository.dart` exposes only `fetchPage`/`create`; no
  `/expenses/report` call exists anywhere in the file. `_computeSummary()`
  (`expense_history_cubit.dart:251-276`) aggregates from `ExpenseDao.monthRows`.
- **R-015.1** (one canonical Drift owner) — HOLDS. `cupid_database.dart:21-30`
  — exactly one `@DriftDatabase` class, `CupidDatabase`, with `Expenses`/
  `ExpenseSyncMetadata`/`ExpenseDao` appended to the existing `Messages`/
  `TimelineEntries`/... lists. `schemaVersion => 2` (`:35`), additive
  `onUpgrade` (`:44-49`) only creates the two new tables — no destructive
  change to schema-v1 tables.
- **R-015.6** (schema-bump collateral fix) — CONFIRMED landed.
  `git show HEAD:mobile/test/core/database/timeline_dao_test.dart` line 36
  reads `expect(database.schemaVersion, 2)` — the literal was updated to
  match the additive bump, exactly as `review-report.md` NOTE-3 claims.
- **R-015.2** (`home_screen.dart` shared-file edit) — HOLDS. Read the full
  325-line file: `Key('home_screen_ready_signal')` is intact (`:97`),
  `_ExpensesEntryCard` (`:225-279`) is purely additive and appended after
  the pre-existing Timeline entry, and every other story's entry card
  (anti-ghost, vibe, reminder, dream jar, pet, love contract, timeline) is
  still present and wired.

## Independent gate re-execution (new evidence this session — flutter was available)

- `flutter test test/features/expenses test/core/database test/features/home`
  → **`00:02 +81: All tests passed!`** (full untruncated output). Confirms
  `test-results.md`'s 81/81 claim by direct re-run, not by re-reading the
  document.
- `flutter analyze lib/features/expenses test/features/expenses lib/core/database test/core/database lib/core/di/service_locator.dart lib/features/home/presentation/home_screen.dart`
  → **1 issue found** (not the "No issues found!" `test-results.md`/
  `review-report.md` both claim for this exact scoped command):
  `info • prefer_initializing_formals … lib/features/home/presentation/home_screen.dart:64:8`.
  `git blame` on that line shows it is STORY-012's `_resolvePairingStatus`
  constructor field (commit `20874d69`, 2026-08-01), not STORY-015 code —
  the line already carries a `// ignore: prefer_initializing_formals`
  comment one line above it (`:63`) that evidently does not suppress the
  diagnostic in this analyzer/lint-rule version. **This is not a
  STORY-015-introduced defect** (STORY-015's own diff never touches
  `_resolvePairingStatus`/`_createTimelineCubit`), but it is a genuine,
  reproducible discrepancy against this story's own P6 evidence and the
  reviewer's synthesis, both of which asserted a clean scoped-analyze run
  for a command that also covers this shared file. Non-blocking (info-level
  lint, pre-existing field, not an AC or ADR violation), but recorded
  because "No issues found!" is not currently reproducible verbatim for
  this exact command on current `main`.

## Design Fidelity

**UNVERIFIED — not PASS.** `integration-review/mobile-visual-audit.md`
(Result: FAIL overall) captured exactly 10 of the design's 37 screens:
`alarm`, `antighost`, `gallery`, `home`, `invite`, `joincode`, `paired`,
`pet`, `privacy`, `vibe`. Neither the design's `jar`-entry `expense` screen
nor its Add-Expense bottom sheet (this story's UX-spec screens, per
`ux/uiux-spec.md` §1) appears among those 10 captured pairs or the 8
"captured, not yet reviewed" ratio-only pairs — `expense` has **zero**
capture evidence of any kind (not even a weak size-ratio signal). Per the
reuse instruction, this is marked UNVERIFIED, not PASS: a missing render is
never a PASS. This is a requirement-level capture-tooling gap (27 of 37
screens are currently uncapturable per the audit's own recommendation #4),
not evidence of a STORY-015-specific implementation defect — but it is also
not evidence that the implementation matches the design, and the audit's
`home` finding (the entry-point screen `_ExpensesEntryCard` is mounted on)
is independently confirmed FAIL (still the STORY-001 placeholder), which
means the expenses feature's real-world discovery surface does not resemble
the design either, independent of whether `ExpenseHistoryScreen` itself
would render faithfully.

## Open Question Relevance

| OQ / Constraint | Status | Relevance To STORY-015 | Correctly Honored? |
|---|---|---|---|
| OQ4 — Offline storage strategy | RESOLVED (ADR-007) | Directly governs AC3's cache/no-outbox design | YES — see Governing Constraints above |
| A1 — Backend frozen | FROZEN | Story is a pure `expenses` consumer | YES — no `backend/` path in the story's file set (`git ls-files` cross-check) or anywhere in the 4 repository methods read |
| OQ5 — Light theme & EN locale in v1 | UNRESOLVED (deferred to PO) | Not implicated — `expense_strings.dart` uses the existing ambient-`Locale` vi/en pattern (ADR precedent from other features), no new theme/locale toggle logic introduced | N/A |
| R8 — Socket.IO auth gap | Open, non-blocking for this story | Not implicated — expenses has no realtime/socket channel (ADR §2: "no events, no realtime... pull-only") | N/A |
| D1 — No Critical Alerts / alarm rename | Resolved (D1) | Not implicated — expenses has no alarm/notification surface | N/A |

## OQ Discipline Findings

- The story's own `story_master.md` "Open Items For Downstream Roles"
  section explicitly delegated the exact `expenses` contract-field question
  (currency, splitting logic, "paid by" settability) to Tech Lead before
  coding-plan — this is a pre-authorized condition, not a silent scope cut.
  ADR-015.2/015.4/015.4a are Tech Lead's technical determinations *inside*
  that delegated authority (the contract genuinely has no `currency`,
  `paidBy`, or split/settlement field — verified against
  `architecture/solution.md` §2's confirmed backend surface), matching the
  same governance shape independently confirmed for STORY-007's analogous
  attachments-scope delegation.
  `req_master.md` was read in full: no `## Open Question Triage` or
  `## Approved Scope Change` section exists for STORY-015, and none was
  needed — the scope reduction traces to the story's own pre-authorized
  delegation plus a frozen-contract technical fact, not to an
  undocumented downstream decision.
- No new open question was raised or left silently unresolved by
  STORY-015's own scope. Expense **delete** exists in the contract but is
  correctly left unshipped (not an AC; `master-plan.md` §6 documents this
  explicitly rather than silently omitting it).
- `data/bugs/master_bugs_list.md` (checked via `git show HEAD:...`) contains
  no bug referencing `expenses` or STORY-015; the 7 REQ-001 bugs on record
  are unrelated (readiness-gate/copy-guard issues from other stories).

## Non-Blocking Observations

- The `flutter analyze` scoped-command discrepancy above (info-level,
  pre-existing STORY-012 field, `// ignore:` comment present but apparently
  ineffective for this rule/version) — recorded for evidence-quality
  traceability, does not affect any AC or ADR verdict.
- `NOTE-1`/`NOTE-2` from `review-report.md` (decode-failure exception type,
  unvalidated `amount` bounds client-side) were spot-checked against
  `expense_models.dart` and confirmed accurately described; both remain
  non-blocking UX-polish items, not defects.

## Summary

All four acceptance criteria independently re-verify PASS from direct source
reading and, for AC1's core assertion, from a test I re-ran myself this
session rather than trusting the prior report's description. The full
81/81 scoped test suite was independently re-executed and passed. ADR-007's
two bounds and the ADR-015.2/015.3/015.4/015.4a "no invented financial
capability" constraints all hold on direct inspection, with the two
highest-risk guarantees (no offline write, no partner toggle) enforced
structurally rather than only by convention. R-015.1, R-015.2, and R-015.6
are each independently confirmed closed. OQ discipline is clean: the three
deliberate UX-spec deviations trace to a pre-authorized delegation plus a
frozen-contract technical fact, not to a silent scope cut. The one new,
previously-unrecorded finding is a reproducible discrepancy in the scoped
`flutter analyze` gate (1 info-lint now surfaces where "No issues found!"
was claimed) — non-blocking and not attributable to STORY-015's own diff,
but worth Scrum Master's awareness for evidence hygiene. The sole
substantive gap is Design Fidelity, UNVERIFIED rather than PASS because the
`expense` screen was never in the visual audit's capture scope at all (not
even ratio-only evidence) — a REQ-001-wide tooling gap, not a
STORY-015-specific implementation defect, but real enough (compounded by
the confirmed-FAIL `home` entry screen this feature is discovered through)
to withhold GREEN.

Story-level Substantive Verdict: CLEAN
Classification Impact: AMBER
REVIEW_COMPLETE: YES
