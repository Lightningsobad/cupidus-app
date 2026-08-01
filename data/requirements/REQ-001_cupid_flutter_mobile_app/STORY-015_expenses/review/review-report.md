# STORY-015 Review Report — Chi Tiêu Chung (Shared Expenses)

Reviewer: Iris-QC (Tier 3 final synthesis)
Story: STORY-015 (`standard`, Epic-5 finance)
Requirement: REQ-001_cupid_flutter_mobile_app
RunId: `RUN-REQ-001_cupid_flutter_mobile_app-STORY-015-reviewer-final-synthesis`
BaseHead: `0a467d03babf1ed4102c3fab09c61b2dec941a0b`
Worktree HEAD at review: `4c472cc8c3542c7f21b3ac139de15e0ecb6521fd` (working tree clean)
MergeTarget: `codex/REQ-001_cupid_flutter_mobile_app-integration`

## 1. Method

This is a synthesis pass over five completed Tier-3 scoped-slice reviews, not a
re-review of the implementation from scratch. Each slice diffed its own file set
against `BaseHead` with an explicit pathspec (an unscoped diff was intentionally
avoided: `BaseHead` predates the merges of sibling stories STORY-007/012, so an
unscoped diff shows large unrelated already-merged deltas).

| Slice | Scope | Verdict | Findings |
|-------|-------|---------|----------|
| A | P1 expense contract / domain layer | CLEAN | 2 NOTE |
| B | P2 Drift persistence / schema layer | CLEAN | 2 NOTE |
| C | P3 expense history screen | CLEAN | none |
| D | P4 add-expense flow | CLEAN | none |
| E | P5 pairing gate, entry point, DI wiring | CLEAN | none |

No slice returned a BLOCKING finding.

### Diff-coverage cross-check

I verified that the five slices collectively cover every source file STORY-015
changed, rather than assuming it. Two files touched by this story's commits fell
outside all five slices' declared file lists; I inspected both directly:

- `mobile/test/core/database/timeline_dao_test.dart` (+1/-1) — exactly the
  planned **R-015.6** collateral fix: `expect(database.schemaVersion, 1)` →
  `2`, matching P2's additive schema bump. Nothing else in the file changed.
  See NOTE-3 for the write-scope technicality.
- `mobile/ios/Runner.xcworkspace/.../Package.resolved` (+8/-0) — an additive
  SwiftPM pin for `CSQLite` (`simolus3/CSQLite`), the native SQLite dependency
  pulled in transitively by Drift and written by the toolchain during
  `flutter build`. No existing pin was changed or removed. Expected collateral
  of P2 introducing Drift usage on iOS; benign.

All other changed paths are documentation artifacts under
`data/requirements/.../STORY-015_expenses/`, not implementation.

## 2. Acceptance Criteria

| AC | Verdict | Supporting slices | Basis |
|----|---------|-------------------|-------|
| AC1 — a paired user can add an expense entry | PASS | A, D | `ExpensesRepository.create()` posts exactly the four contract fields (`category`, `amount`, `description?`, `date`); `AddExpenseCubit.submit()` calls it with no additional field. Both the repository test and both P4 test files assert the exact outgoing key set, giving a regression guard against a forbidden field being added later. |
| AC2 — both partners can view shared expense history | PASS | C | `ExpenseHistoryState.filteredRows` filters by category only; no `userId` argument reaches `ExpenseDao`/`ExpensesRepository` anywhere. The "You"/"Partner" label is display-only provenance, not a data filter, and a cubit test seeds two distinct `userId`s and asserts both stay visible. |
| AC3 — history readable offline after one sync; writes need connectivity | PASS | B, C, D | Read half: cache-first emit then network sync; a failed fetch keeps the cached page and only flips `isOffline`. Write half is a **structural** guarantee, not merely a tested one — `ExpenseDao` exposes no user-authored insert method at all (only `upsertAll` from server-fetched rows), and `AddExpenseCubit` holds no `ExpenseDao` reference, so no handle exists to write through. P4 tests assert `dao.countAll() == 0` against a real in-memory Drift DB after every failure path. |
| AC4 — unpaired users cannot access this feature | PASS | A, E | Full path traced end-to-end with no bypass: `HomeScreen._ExpensesEntryCard.onTap` → `ExpensesEntryPoint` → `PairingStateReader.isPaired()` → `PairingRequiredGate` (unpaired) or `ExpenseHistoryScreen` (paired). `isPaired()` returns `false` for both `unpaired` and `unknown` (never optimistic). A mid-session `ExpensesNotPairedFailure` (404) flips an already-open screen back to the gate. |

No AC is left partially covered, and no slice claimed coverage that another
slice contradicted.

## 3. Governing Constraints

- **ADR-007** (read-through server-authoritative cache; no offline write/outbox)
  — HOLDS. No outbox table, no optimistic insert, no background retry, and no
  "queued"/"will sync" copy. Enforced structurally by the DAO write surface, and
  the offline copy is asserted as "No connection — try again".
- **ADR-015.2 / 015.4 / 015.4a** (no client-settable `paidBy`, no `currency`, no
  split/settlement/balance) — HOLD. "Paid by" ships display-only: a plain `Row`
  with no `onTap`/`InkWell`/`GestureDetector`, and a widget test asserts via
  `SemanticsNode.flagsCollection` that it exposes neither a button nor a toggled
  trait. VND is a fixed display unit, never a selector.
- **ADR-015.3** (client-side monthly aggregation, not `/expenses/report`) —
  HOLDS. The repository exposes only `fetchPage`/`create`. The aggregator sums
  once per row with no double-counting and hides the month-over-month delta when
  the cache demonstrably does not cover the previous month — failing closed on
  money numbers, per R-015.5.
- **A1** (frozen `expenses` backend) — HOLDS. No `backend/` path appears in this
  story's diff.
- **R-015.1** (one canonical Drift owner) — RESOLVED and verified. Exactly one
  `@DriftDatabase` class, `CupidDatabase`; STORY-015 only appends `Expenses`,
  `ExpenseSyncMetadata`, and `ExpenseDao` to its existing lists. No second
  database class is created or referenced.
- **R-015.2** (`home_screen.dart` shared-file edit) — HOLDS. Every pre-existing
  entry point survives in its original order with original keys, and
  `Key('home_screen_ready_signal')` — the `mobile-app` runtime readiness
  contract — is intact. The 5 deleted lines are that same `Center`/`Text`/key
  trio re-nested verbatim inside a new scroll wrapper, not a feature removal;
  three independent tests still locate the key after the edit.
  `service_locator.dart` is +244/-0, additive only.
- **R-015.6** (schema bump collateral) — RESOLVED in-branch. The bump is
  `schemaVersion 1 → 2` with an `onUpgrade` that only calls `createTable` for
  the two new tables; the generated-file delta contains zero removed lines. The
  sibling test literal was updated to match (see NOTE-3).

The three deliberate UX-spec deviations (non-interactive "Paid by", no literal
partner display names, client-side summary instead of `/expenses/report`) were
reviewed against the solution ADRs rather than the UX spec verbatim, as
`master-plan.md` §6 directs. All three ship as decided.

## 4. Test Evidence

Gates recorded in `coding-plan/test-results.md`:

| Gate | Scope | Result |
|------|-------|--------|
| `flutter analyze` | STORY-015 write-scope files | No issues found |
| `flutter test` | `test/features/expenses`, `test/core/database`, `test/features/home` | 81/81 passed, 0 failures |
| `flutter build apk --debug` | whole app | Built successfully |

Test quality was assessed per slice rather than by count. The suites assert
decoded values, exact request bodies, ordering/paging boundaries, both empty
states, navigation destinations, and semantics flags — including negative
assertions that fail if a request is ever sent (future-date short-circuit) or if
a row is ever written locally on a failed submit. These are behavioral, not
render-smoke, tests. The scoped run covers `test/core/database`, which is what
confirms the R-015.6 literal fix landed and the schema-2 branch is green.

## 5. Findings Carried Forward

All findings are non-blocking. None requires rework before merge.

- **NOTE-1 (Slice A, robustness)** — `Expense.fromJson` decode failures (e.g. the
  `FormatException` from `_decodeAmount` on an unrecognized `amount` wire type)
  are raised inside the `try` block but are not `DioException`s, so they escape
  the `on DioException` clause and surface as raw exceptions rather than a typed
  `ExpensesFailure`/`CupidApiFailure`. Consistent with treating a decode failure
  as a contract-violation bug rather than a recoverable failure, but downstream
  presentation code should be aware raw exceptions can surface from this
  repository.
- **NOTE-2 (Slice A, validation)** — the contract's `amount` bounds (`>=1`,
  `<=999999999999`) are not validated client-side. Not required by AC1, and the
  frozen backend validates server-side, so the failure mode is a rejected
  request rather than bad data. Candidate for a later UX polish pass.
- **NOTE-3 (write-scope technicality)** — the R-015.6 fix to
  `mobile/test/core/database/timeline_dao_test.dart` was applied in-branch
  (commit `6c6893c`) even though `master-plan.md` §6 had routed it to Scrum
  Master as a trivial follow-up outside P2's declared `WriteScope`. I consider
  this the correct call rather than a defect: the assertion and the schema bump
  must change together or `flutter test test/core/database/` cannot be green on
  this branch. Recorded for scope traceability only.
- **NOTE-4 (Slice B, traceability)** — `test-results.md` has a dedicated
  `## R-015.1` section but no equivalent `## R-015.6` section, so the
  schemaVersion-bump evidence had to be re-derived from the diff. Recommend
  adding a mirror section for traceability parity. Documentation only.
- **NOTE-5 (Slice B, forward-looking)** — `onUpgrade`'s `if (from < 2)` handles
  the only upgrade path that can exist today (v1 → v2). A future schema bump
  will need chained branches or a loop/switch. Not a defect in this story.

## 6. Out-of-Scope Items For Scrum Master

These are recorded in `test-results.md`, confirmed pre-existing on the
integration branch, and **proven not caused by STORY-015**. They do not gate
this story, but they should not be lost:

- 8 full-project test failures sharing one root cause: `CouplePairingStore is
  not registered inside GetIt`, thrown via `HomeScreen._defaultResolvePairingStatus`
  → `_TimelineEntryPointGate` (a STORY-012 default dependency). A direct diff of
  P5's `home_screen.dart` commit shows the STORY-015 change is purely additive
  and never touches that code path. **`test/widget_test.dart` — the app's own
  root boot smoke test — is among the affected files**, which makes this worth
  prioritizing in the pairing/timeline lane.
- `test/features/pairing/presentation/pair_gate_cubit_test.dart` fails to load:
  it passes `AppShell(createPairGateCubit: ...)`, but those constructor params
  belong to `PairGateShell`. A separate small fix.
- 79 whole-project `flutter analyze` info-lints/warnings across other feature
  lanes, inherited from the integration branch.

## 7. Conclusion

All five Tier-3 slices returned CLEAN, their file lists plus my two-file
coverage check account for the complete STORY-015 implementation delta, and
AC1-AC4 are each satisfied with behavioral test evidence and no gaps between
slices. The governing ADR-007 bounds and the ADR-015.2/015.4/015.4a
"no invented financial capability" constraints hold — in the two highest-risk
places (no offline write, no partner toggle) they are enforced structurally
rather than only by convention, which is the stronger outcome. R-015.1, R-015.2,
and R-015.6 are each closed. The five NOTEs are informational or documentation
items; none describes a defect in shipped behavior and none requires rework.

Outcome: CLEAN
