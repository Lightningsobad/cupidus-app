# STORY-003 – Test Results

## Phase P1 – Journal persistence schema (Drift v3)

- Date: 2026-09-07
- Lane: Mobile
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-003`
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-003`
- Flutter SDK: `/Users/alantravala/flutter/bin` (prefixed on `PATH`; not a bare
  `flutter` from the ambient shell)

### Codegen prerequisite

```
$ flutter pub get
Got dependencies!
77 packages have newer versions incompatible with dependency constraints.

$ dart run build_runner build
  8s drift_dev on 2108 inputs: 527 skipped, 1032 output, 549 no-op; spent 5s analyzing, 1s resolving
  0s source_gen:combining_builder on 1054 inputs: 527 skipped, 5 output, 522 no-op
  Built with build_runner/aot in 25s; wrote 1037 outputs.

$ flutter gen-l10n
Because l10n.yaml exists, the options defined there will be used instead.
```

`--delete-conflicting-outputs` was accepted but reported as removed/ignored by
`build_runner` 2.15.1; the build completed without conflicts regardless.

### Unit + integration tests (declared phase test scope)

```
$ flutter test test/core/database/journal_dao_test.dart test/core/database/cupid_database_migration_v3_test.dart
00:00 +0: loading .../journal_dao_test.dart
00:00 +1: journal_dao_test.dart: opens at schema version 3 with both journal tables present
00:00 +2: journal_dao_test.dart: JournalDao.upsertEntry editing an entry rewrites the same row instead of minting a new id (AC-3)
...
00:00 +21: All tests passed!
```

Full per-test roster, 21 passing cases:

`journal_dao_test.dart` (17)

1. opens at schema version 3 with both journal tables present
2. `upsertEntry` editing an entry rewrites the same row instead of minting a new id (AC-3)
3. `upsertEntry` stores the owner from the parameter, not from the passed row
4. `upsertEntry` leaves an entry owned by another user untouched
5. `upsertEntry` accepts an empty body for a photo-only entry
6. owner isolation: user B cannot read user A entries through `entryById` or `watchEntries`
7. owner isolation: an unknown owner id sees an empty journal, not everyone else's
8. `watchEntries` emits newest-first and honors limit/offset
9. `watchEntries` re-emits after a write
10. `deleteEntry` removes the entry together with its photo rows (AC-13)
11. `deleteEntry` cascades photo rows when the entry row is deleted directly
12. `deleteEntry` does nothing when the entry belongs to another user
13. `deleteAllEntries` clears exactly one owner and leaves other owners intact (AC-12)
14. `liveEntryIds` returns only the requested owner ids for the orphan sweep
15. journal tables expose no soft-delete, streak, goal, counter, or share-state column (BR-2, BR-4)
16. `JournalDao` is not a `SessionScopedStore`, so signing out cannot wipe the journal (Key Discovery 2)
17. `ownerUserId` is mandatory on every journal entry row

`cupid_database_migration_v3_test.dart` (4)

1. upgrading v2 -> v3 creates both journal tables (asserts `PRAGMA user_version` == 3)
2. v2 rows are still intact after the upgrade (additive migration only)
3. journal rows written after the upgrade round-trip on the same file
4. a fresh v3 database creates every table without a migration

The migration test does not hand-write v2 DDL. It builds a real on-disk
database, writes genuine v2 timeline/expense rows through the existing DAOs,
drops the two journal tables, rewinds `PRAGMA user_version` to 2, and reopens —
so the assertions exercise the actual `onUpgrade(2 -> 3)` branch rather than an
approximation of the v2 schema.

### Static analysis

```
$ flutter analyze lib/core/database test/core/database
Analyzing 2 items...
No issues found! (ran in 1.6s)
```

```
$ flutter analyze lib test
Analyzing 2 items...
188 issues found. (ran in 3.7s)
```

Breakdown of the repo-wide run: 0 error-severity findings, 35 warnings, 153
info. **Zero of the 188 findings reference any file under `core/database`**, and
the entire P1 diff is confined to `core/database`, so none of them can originate
from this phase. They are the pre-existing repo-wide baseline
(`deprecated_member_use`, `prefer_initializing_formals`, `unused_import` in
`features/chat`, `features/dream_jar`, and similar), tracked separately as
BUG-20260907-001.

### Required checks

| Check | Result | How it was run |
|---|---|---|
| No `deletedAt` / `streak*` / `goal*` / `count*` / share-state column in the journal schema | PASS | `journal_dao_test.dart` case 15 |
| `JournalDao` carries no `SessionScopedStore` registration | PASS | `journal_dao_test.dart` case 16 |

Both required checks were specified as text greps. Shell `grep` over source is
blocked in this session by `guard-query-first-bash-read.sh` and the platform
`Grep` tool is disabled, so each check was run as a runtime assertion instead.
This is strictly stronger evidence than a text grep: case 15 enumerates
`$columns` of the generated Drift schema (catching a forbidden column even if it
were introduced through codegen rather than the table source), and case 16 does
an `isNot(isA<SessionScopedStore>())` type test on the live DAO instance
(catching the registration even if it arrived through a mixin or superclass
rather than a literal `implements` clause).

### Collateral regression outside P1 write scope — needs Scrum Master

Bumping `schemaVersion` 2 -> 3, which this phase mandates, invalidates a
hard-coded version assertion in two sibling test files that are NOT in the P1
write scope:

- `mobile/test/core/database/timeline_dao_test.dart:36` — `expect(database.schemaVersion, 1)`, now `Expected: <2> Actual: <3>`
- `mobile/test/core/database/expense_dao_test.dart:37` — `expect(database.schemaVersion, 2)`, now `Expected: <2> Actual: <3>`

Each needs a one-token edit to `3`. Both are pure version-literal assertions;
no behavioural assertion in either file regressed, and every other case in
`test/core/database` passes (40 passing, these 2 failing). These files are
outside the declared `WriteScope` and outside the phase spec's own Write Scope,
so P1 deliberately left them untouched rather than widening scope unilaterally.
STORY-001 is bumping the same `schemaVersion` on its own branch, so this belongs
in the same reconciliation.
