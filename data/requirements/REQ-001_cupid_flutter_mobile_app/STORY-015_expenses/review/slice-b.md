# STORY-015 Reviewer Slice B — Drift Persistence/Schema Layer

Reviewer: Iris-QC (Tier 3 scoped-slice review, RunId
RUN-REQ-001_cupid_flutter_mobile_app-STORY-015-reviewer-slice-b)
Note: persisted by Helen-SC on Iris-QC's behalf — Iris-QC's own Write of this
file (and its RunState update) was blocked by `guard-parallel-worktree-scope.sh
[OUT_OF_SCOPE]` (9x identical block, retry budget exhausted), caused by the
spawn mistakenly using isolation: worktree which put the agent in a private
worktree disconnected from the declared shared story Worktree (same pattern
as Slices C, D, and E). Content below is verbatim from Iris-QC's completed
review analysis, transcribed unedited from the blocked Write tool call's
content.

## Files reviewed

- `mobile/lib/core/database/tables/expenses_table.dart`
- `mobile/lib/core/database/daos/expense_dao.dart`
- `mobile/lib/core/database/daos/expense_dao.g.dart` (generated)
- `mobile/lib/core/database/cupid_database.dart` (shared file, additive edit)
- `mobile/lib/core/database/cupid_database.g.dart` (generated)
- `mobile/test/core/database/expense_dao_test.dart`

Diff method: `git diff 0a467d03babf1ed4102c3fab09c61b2dec941a0b -- <6 files
above>`. `cupid_database.dart`/`.g.dart` showed as "new file" against that
BaseHead because the story branch has an intermediate commit `b1389f3`
("sync mobile/ tree from integration HEAD to unblock P2") that predates
BaseHead's knowledge of the file; cross-checked the true STORY-015-only delta
via `git diff b1389f3 428222b -- <path>` (428222b = "P2 additive Drift cache
for expenses" commit), which isolates exactly what STORY-015 P2 added on top
of the already-merged STORY-007/012 baseline.

## R-015.1 — canonical Drift database class

CLEAN. `git show b1389f3:mobile/lib/core/database/cupid_database.dart` (the
pre-STORY-015 baseline synced from integration) shows exactly one
`@DriftDatabase`-annotated class, `CupidDatabase`, with
`tables: [Messages, TimelineEntries, TimelineSyncState]`,
`daos: [MessageDao, TimelineDao]`, `schemaVersion => 1`. STORY-015's P2 commit
(428222b) only adds `Expenses`, `ExpenseSyncMetadata` to the `tables` list and
`ExpenseDao` to `daos` on the same `CupidDatabase` class — no second
`AppDatabase`-style class is introduced or referenced anywhere in the Slice B
diff. Matches the test-results.md R-015.1 note.

## R-015.6 — schemaVersion bump / additive-only migration

CLEAN, but with a documentation-completeness NOTE (see Findings). The diff
shows `schemaVersion` bumped `1 -> 2`, with a `MigrationStrategy.onUpgrade`
that only does `if (from < 2) { createTable(expenses);
createTable(expenseSyncMetadata); }` — purely additive, no `dropTable`,
`deleteColumn`, or any touch of the pre-existing `Messages`/
`TimelineEntries`/`TimelineSyncState` tables. Cross-checked the generated
`cupid_database.g.dart` diff (`b1389f3` -> `428222b`): `grep -E "^-[^-]"`
against that diff returns zero removed lines — the entire generated-file
delta is pure addition (new `$ExpensesTable`/`$ExpenseSyncMetadataTable`
classes and companions appended after the existing generated
`TimelineSyncStateCompanion` class). No destructive schema change found.

## AC3 — offline read after sync / write requires connectivity

CLEAN for Slice B's scope (persistence layer). `expense_dao.dart` exposes
only read/cache-maintenance operations: `upsertAll` (writes only from
server-fetched rows, via `insertAllOnConflictUpdate`), `getPage`/`watchPage`
(paged reads, `date DESC, createdAt DESC`), `monthRows` (bounded read for
client-side aggregation), `lastSuccessfulSyncAt`/`markSyncedNow` (single-row
sync marker distinguishing never-synced from synced-zero), and `countAll`
(aggregate read). There is no insert/write method a caller could use to
create a brand-new user-authored expense row through this DAO — enforcing
that new-entry writes must go through the network-only repository path
(outside this slice's scope, corroborated by test-results.md's ADR-007 note
that `AddExpenseCubit` holds no `ExpenseDao` reference at all). The test file
directly exercises the read side: schema-version-2 open sanity check,
upsert-then-read idempotency, `getPage`/`watchPage` ordering and
limit/offset, `monthRows` boundary filtering, `lastSuccessfulSyncAt`/
`markSyncedNow` null-vs-non-null transition, `countAll`, and an explicit
ADR-007 gate test asserting no column name matches
`pending|queued|outbox|retry|sendState`. This meaningfully covers the
read-after-sync half of AC3 for this layer; the write-requires-connectivity
half is satisfied by the DAO's write-surface having no such method at all
(a structural, not merely tested, guarantee) and is otherwise out of this
slice's file scope (repository/cubit layer belongs to a different slice).

## Generated-file consistency

`expense_dao.g.dart`: entirely new 23-line file, standard Drift
`DatabaseAccessor` mixin + manager boilerplate (`_$ExpenseDaoMixin`,
`ExpenseDaoManager`), consistent with the `@DriftAccessor(tables: [Expenses,
ExpenseSyncMetadata])` annotation on the hand-written `ExpenseDao` class. No
manual-edit markers, no stale references.

`cupid_database.g.dart`: diff is purely additive (see R-015.6 above), new
`$ExpensesTable`/`$ExpenseSyncMetadataTable` table classes, row classes, and
companions consistent with the hand-written `Expenses`/`ExpenseSyncMetadata`
table definitions (column names/types/nullability all match). Indirect
corroboration: test-results.md records `flutter analyze` clean and
`flutter test` 81/81 passing for this story's scope, including this slice's
own `expense_dao_test.dart`, which directly exercises
`database.expenses`/`database.expenseSyncMetadata`/`database.expenseDao` —
generated/hand-written code could not be inconsistent and still pass that
suite.

## Findings

- NOTE (non-blocking, process): the handoff instructed grepping
  `test-results.md` for an "already-recorded verification note" on R-015.6
  (schemaVersion bump), matching the format already present for R-015.1.
  `test-results.md` has a dedicated `## R-015.1 — Canonical Drift database
  class` section but no equivalent dedicated R-015.6 section — "R-015.6" is
  only mentioned once, in an unrelated out-of-scope-findings paragraph. The
  actual schemaVersion-bump evidence had to be independently re-derived from
  the diff/commit history rather than read off an existing recorded note.
  Recommend Scrum Master ask backend/mobile-dev (or note in a future pass) to
  add an explicit `## R-015.6` section to `test-results.md` mirroring the
  R-015.1 one, for traceability parity — does not block this story's merge
  since the underlying migration itself is verified additive-only by direct
  inspection above.
- NOTE (non-blocking, forward-looking): `onUpgrade`'s `if (from < 2)` branch
  only handles the single currently-possible upgrade path (v1 -> v2). This is
  correct today (v1 is the only prior schema version that has shipped), but
  is a single-step-only migration; a future schema bump will need to either
  chain additional `if` branches or restructure this into a loop/switch. Not
  a defect in this story's scope.

No BLOCKING findings in Slice B.

Slice-Verdict: CLEAN
