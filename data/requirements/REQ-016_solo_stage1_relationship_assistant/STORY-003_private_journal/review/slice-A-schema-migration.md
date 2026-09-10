# STORY-003 Scoped Review — Slice A: Schema / Migration / DAO

- Reviewer: Iris-QC
- Date: 2026-09-08
- Mode: scoped-slice (Slice A of A–E + synthesis pass F)
- Outcome: `PARTIAL_SLICE_ONLY` — 1 must-fix, 1 known merge-time item, 2 deferred
- Story: STORY-003 (REQ-016)
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-003`
- BaseHead: `62f451733d191b666b718b595ead4621676e3e1c`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-003`

This slice does NOT issue a story-level verdict. It covers only the P1
schema/migration/DAO surface. Repository, media store, cubits, screens, entry
point, and visual fidelity belong to slices B–E.

## Files reviewed (diff-scoped)

| File | Δ |
|---|---|
| `mobile/lib/core/database/cupid_database.dart` | +26 −6 |
| `mobile/lib/core/database/tables/journal_entries.dart` | +38 (new) |
| `mobile/lib/core/database/tables/journal_photos.dart` | +25 (new) |
| `mobile/lib/core/database/daos/journal_dao.dart` | +102 (new) |
| `mobile/test/core/database/cupid_database_migration_v3_test.dart` | +124 (new) |
| `mobile/test/core/database/journal_dao_test.dart` | +268 (new) |
| `mobile/lib/core/database/cupid_database.g.dart`, `daos/journal_dao.g.dart` | generated; not line-reviewed |

Generated `.g.dart` output was not line-reviewed. Its correctness is asserted
indirectly: `database.journalDao`, `database.journalEntries`,
`database.journalPhotos`, and `JournalPhotosCompanion.insert` all resolve and
execute in the 21 passing P1 cases, which cannot happen if codegen were stale.

## Risk items

### RA-1 — schemaVersion 2 → 3 migration is additive, no data loss — PASS

`cupid_database.dart:47` bumps `schemaVersion` to 3. The `onUpgrade` branch at
`cupid_database.dart:57-61` is strictly additive: `if (from < 3)` then
`m.createTable(journalEntries)` + `m.createTable(journalPhotos)`. No `drop`,
no `deleteAll`, no recreate anywhere in the strategy. The v2 branch is left
untouched, so a v1 device still walks v1→v2→v3 in one open.

Evidence that the v2 data actually survives is empirical, not asserted:
`cupid_database_migration_v3_test.dart:10-38` builds a REAL on-disk v2 file by
writing genuine timeline and expense rows through the existing DAOs, dropping
the two journal tables, and rewinding `PRAGMA user_version` to 2 — so the
reopen exercises the true `onUpgrade(2 → 3)` branch rather than a hand-written
DDL approximation of v2. `cupid_database_migration_v3_test.dart:69-83` then
asserts `tl-1` and `exp-1` still exist with intact field values after the
upgrade, and `:62-66` asserts `PRAGMA user_version == 3`.

`cupid_database.dart:31-46` documents WHY recreate is now forbidden: v3 is the
first device-authoritative data in this database (journal rows exist on no
server). That constraint is the right one and is stated where the next
migration author will read it.

### RA-2 — `PRAGMA foreign_keys = ON` / cascade actually fires — PASS

`journal_photos.dart:12-13` declares
`text().references(JournalEntries, #id, onDelete: KeyAction.cascade)`, which
SQLite ignores unless foreign keys are enabled per connection.
`cupid_database.dart:62-66` adds the `beforeOpen` hook that issues the pragma.

Not accepted on inspection alone — verified empirically:
`journal_dao_test.dart:176-186` deletes a `journal_entries` row DIRECTLY
(bypassing the DAO) and asserts `journal_photos` is then empty. That case
passes, so the pragma is in force at runtime.

### RA-3 — DAO correctness: owner isolation — PASS

Every read/write/delete in `journal_dao.dart` takes `ownerUserId` as a
required positional and filters on it; there is no unfiltered `clearAll()` and
no method that omits the parameter. `upsertEntry` (`journal_dao.dart:52-53`)
forces `entry.copyWith(ownerUserId: ownerUserId)`, so a caller cannot smuggle a
different owner in through the row object.

Covered by `journal_dao_test.dart:79-88` (owner comes from the parameter, not
the row), `:90-102` (an id owned by another user is left untouched — the
`InsertMode.insertOrIgnore` path no-ops instead of overwriting), `:111-133`
(user B cannot read user A through `entryById` or `watchEntries`; an unknown
owner sees empty, not everyone else's).

This is the only multi-account isolation on a shared device, because the DAO
deliberately is not a `SessionScopedStore` (see RA-5) — the coupling is
correct and is called out in the source doc comment at `journal_dao.dart:9-17`.

### RA-4 — DAO correctness: AC-3 / AC-11 / AC-12 / AC-13 delete + edit semantics — PASS

- **AC-3** (edit replaces, no parallel copy): `upsertEntry` reuses the row when
  the id already belongs to this owner (`journal_dao.dart:54-68`). Asserted at
  `journal_dao_test.dart:63-77` — one row after two upserts, body and
  `updatedAt` updated, id unchanged.
- **AC-11 / AC-13** (single delete, no hidden copy): `deleteEntry`
  (`journal_dao.dart:74-86`) deletes photo rows and the entry in ONE
  transaction, and deletes photos explicitly rather than trusting the FK
  cascade — so an environment that opens without `foreign_keys` still cannot
  leave orphan rows. Asserted at `journal_dao_test.dart:162-174` and
  `:188-196` (a delete requested by the wrong owner is a no-op).
- **AC-12** (delete everything, one operation, one owner): `deleteAllEntries`
  (`journal_dao.dart:89-100`) is one transaction scoped to a single owner.
  Asserted at `journal_dao_test.dart:200-217` — user A cleared, user B's entry
  AND user B's photo row both survive.

Note: the doc comment on `deleteEntry` (`journal_dao.dart:70-73`) cites AC-13;
the primary anchor for single-entry delete is AC-11, with AC-13 the
no-hidden-copy corollary. Comment-level nit only, no behavioural impact.

Deletion of photo FILES on disk (the other half of AC-13, "không file ảnh mồ
côi trên thiết bị") is media-store scope. `liveEntryIds`
(`journal_dao.dart:96-101`) is the hook the orphan sweep consumes and is
correct and owner-scoped here; whether the sweep actually runs is Slice B/C.

### RA-5 — BR-2 / BR-4 absence-as-requirement, and sign-out safety — PASS

`journal_entries.dart:8-9` states the absence of `deletedAt`, streak, goal,
counter, and share-state columns is itself the requirement. This is enforced at
runtime, not by convention: `journal_dao_test.dart:234-257` enumerates
`$columns` of BOTH generated tables and asserts no name contains `deletedat`,
`streak`, `goal`, `count`, `shared`, or `sharestate` — which catches a
forbidden column even if introduced via codegen rather than table source.

`journal_dao_test.dart:259-262` asserts
`expect(dao, isNot(isA<SessionScopedStore>()))`, so a future sign-out clear
cannot silently wipe device-authoritative journal content. This is the
correct inversion of the `TimelineDao` / message-store pattern and is
stronger evidence than the text-grep the phase spec originally asked for.

`journal_dao_test.dart:264-266` asserts `ownerUserId` is non-nullable.

### RA-6 — P1 test evidence exists and passes — PASS

`coding-plan/test-results.md` `## Phase P1 – Journal persistence schema (Drift v3)`:

- `:34-39` — `flutter test test/core/database/journal_dao_test.dart test/core/database/cupid_database_migration_v3_test.dart` → **`All tests passed!` (21/21)**, with the full per-test roster enumerated at `:44-69` and matching the two test files line-for-line as reviewed above.
- `:80-83` — `flutter analyze lib/core/database test/core/database` → `No issues found!`
- `:86-97` — repo-wide `flutter analyze lib test` → 188 issues, **0 error-severity**, zero of them referencing any file under `core/database`; tracked as BUG-20260907-001.
- `:19-22` — `dart run build_runner build` completed, so the reviewed `.g.dart` is current.
- Re-confirmed green in the later P2 run (`test-results.md:155`): the same two P1 files pass inside a 36/36 regression batch.

### RA-7 — schemaVersion bump left two sibling tests red — FAIL (must-fix, slice-scoped)

The `schemaVersion` 2 → 3 bump invalidates hard-coded version literals in two
pre-existing test files that were NOT updated on this branch:

- `mobile/test/core/database/timeline_dao_test.dart:36` — `expect(database.schemaVersion, 2);`
- `mobile/test/core/database/expense_dao_test.dart:37` — `expect(database.schemaVersion, 2);`

Both still read `2` at branch HEAD (confirmed by direct read, not inference),
while `cupid_database.dart:47` now returns `3`. These are deterministic
failures, and the P1 run observed them directly: `test-results.md:122-129`
records `Expected: <2> Actual: <3>` for both and reports `test/core/database`
as 40 passing / 2 failing.

Impact: `flutter test test/core/database` is RED on this branch. No behavioural
assertion regressed — both are pure version-literal assertions, and each needs
a one-token edit to `3`. The implementer deliberately declined to widen its
declared `WriteScope`, which is the right instinct, but the branch cannot merge
with a red suite in the directory it just changed.

Recommended resolution: Scrum Master applies the two one-token edits at merge
time (they are outside every story lane's WriteScope). The fix does not collide
with STORY-001 — the post-merge correct literal is `3` under either story's
bump, so both files converge on the same value.

### RA-8 — KNOWN MERGE COLLISION with STORY-001 — non-blocking, informational

STORY-001 independently bumps `schemaVersion` 2 → 3 on its own branch and adds
its own `onUpgrade` work. Both branches therefore claim version 3 and both edit
`cupid_database.dart` in the same region (`schemaVersion` getter + the
`onUpgrade` chain + the `@DriftDatabase` `tables:`/`daos:` lists).

Per the review handoff this is explicitly NOT a finding to block STORY-003 on;
Scrum Master resolves it directly at integration merge. Recorded here so the
merge is not surprised:

- the two `createTable` calls in STORY-003's `if (from < 3)` branch and
  STORY-001's additions must end up in the SAME version branch, or one story's
  tables will never be created on an upgrading device;
- if the merged result advances to version 4, the `if (from < 3)` guard and
  both `expect(..., 3)` assertions in
  `cupid_database_migration_v3_test.dart:66` and `:117` must move with it;
- `beforeOpen` `PRAGMA foreign_keys = ON` must survive the merge — dropping it
  silently disables the `journal_photos` cascade (RA-2), and only the DAO's
  explicit photo delete would still protect against orphans;
- `dart run build_runner build` must be re-run post-merge; both branches carry
  independently generated `cupid_database.g.dart`, which will conflict.

### RA-9 — Missing indexes on the journal query paths — DEFERRED (low)

No index backs `watchEntries`' `where(ownerUserId) + orderBy(createdAt desc)`
(`journal_dao.dart:21-35`), and `journal_photos.entryId` has no index
(`journal_photos.dart:12-13`) — SQLite does not auto-index FK child columns, so
`delete(journalPhotos)..where(entryId.isIn(ids))` full-scans.

Deferred, not must-fix: a single-user on-device private journal has a row count
where this is unmeasurable. Worth revisiting only if journal ever gains bulk
import or a photo-heavy history.

## Slice A summary

| Item | Verdict |
|---|---|
| RA-1 additive 2→3 migration, no data loss | PASS |
| RA-2 FK pragma + cascade fires at runtime | PASS |
| RA-3 DAO owner isolation | PASS |
| RA-4 AC-3 / AC-11 / AC-12 / AC-13 DAO semantics | PASS |
| RA-5 BR-2 / BR-4 absent columns, not SessionScopedStore | PASS |
| RA-6 P1 test + analyze evidence | PASS |
| RA-7 sibling tests still assert schemaVersion 2 | **FAIL (must-fix)** |
| RA-8 STORY-001 schemaVersion collision | KNOWN MERGE ITEM (non-blocking) |
| RA-9 missing indexes | DEFERRED (low) |

Slice A outcome: `PARTIAL_SLICE_ONLY`. The schema, migration, and DAO work is
correct and well-evidenced; RA-7 is the only item that must be closed before
this branch can merge, and it is a two-line edit owned by Scrum Master.
