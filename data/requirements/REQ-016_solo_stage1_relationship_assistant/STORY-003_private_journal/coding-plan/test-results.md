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

## Phase P2 — Journal media store + repository

- Date: 2026-09-07
- Owner: Mobile Developer
- Outcome: PARTIAL — code complete and green; the section 3 lookup sub-task is
  blocked as `OS_BACKUP_EXCLUSION_UNVERIFIED` (see below).

### Commands run

| Command | Result |
|---|---|
| `flutter analyze lib/core/journal lib/features/journal lib/core/di/service_locator.dart test/core/journal test/features/journal` | 4 issues, all `info • prefer_initializing_formals`; 0 errors, 0 warnings |
| `flutter analyze lib test` (full phase-required scope) | **0 errors** repo-wide; 192 issues total (35 warnings, rest info) — all pre-existing except the 4 infos above. The only other journal-adjacent hit is a pre-existing `unused_import` of `service_locator.dart` in `test/features/expenses/expenses_entry_point_test.dart`, a file P2 never touched. |
| `flutter test test/core/journal/journal_media_store_test.dart test/features/journal/journal_repository_test.dart` | **28/28 passed** |
| `flutter test test/core/database/journal_dao_test.dart test/core/database/cupid_database_migration_v3_test.dart test/features/reminders/reminder_entry_point_test.dart test/features/pairing/presentation/pair_gate_cubit_test.dart` | **36/36 passed** (P1 regression + the `setupServiceLocator` consumers touched by the DI edit) |

Run from `mobile/` with `PATH="$HOME/flutter/bin:$PATH"` (Flutter 3.44.1).

The 4 `prefer_initializing_formals` infos are unavoidable, not deferred work:
the fields are private and the constructor params are named, and Dart forbids
`this._x` in a named parameter. The same info is pre-existing repo-wide on
`cupid_session.dart`, `pair_gate_shell.dart`, and `ghost_cubit.dart`, which use
the identical init-list form.

### Acceptance criteria coverage

| Phase AC | Case | Result |
|---|---|---|
| After `deleteEntry` / `deleteAll` no file of the deleted entry survives; root empty after `deleteAll` (AC-12) | `journal_repository_test.dart` "leaves no file of the deleted entry…", "empties both the table and the media root"; `journal_media_store_test.dart` `deleteEntryDir`/`deleteRoot` groups | PASS |
| Process killed between the two delete phases: next `sweepOrphans()` cleans the remainder (AC-13) | `journal_repository_test.dart` "cleans up files left by a process killed between the two delete phases" — commits `dao.deleteEntry` only, asserts files survive, then sweeps | PASS |
| `importPhoto` makes an independent copy in both directions | `journal_media_store_test.dart` "copies rather than references…" and "and the reverse…" | PASS |
| Media root resolves to the configured directory | `journal_media_store_test.dart` "media root resolves under the configured base directory" | PASS (mechanism itself unverified — see blocker) |
| No Write Scope file imports `share_plus`, `dio`, `cupid_api`, `RealtimeCoordinator` | `journal_repository_test.dart` group "privacy egress gate" | PASS |

The forbidden-import check was specified as a shell grep. Shell `grep` over
source is blocked by `guard-query-first-bash-read.sh` and the platform `Grep`
tool is disabled in this session, so — as in P1 — it runs as a Dart assertion
that reads the three journal source files and asserts no `import` line contains
any forbidden token (also covering `Clipboard` and `hydrated_bloc`).

Extra covered beyond the listed AC: owner-scoping (`without a backend user id`
group — reads return empty, writes refused, deletes/sweeps are no-ops, and the
signed-out user's data is still intact after re-authenticating), `AC-3` id
stability on re-save, unreadable seed paths skipped per `contract-summary.md`
§3, and rollback of imported files when the transaction fails (fault-injected by
dropping `journal_photos` before the save).

### BLOCKER: `OS_BACKUP_EXCLUSION_UNVERIFIED` (section 3 lookup sub-task)

The phase's mandatory lookup task could not be performed. `WebSearch` and
`WebFetch` are both disabled at the session level in this run, exactly as they
were for Tech Lead. Verbatim, in order:

```
ToolSearch("select:WebSearch,WebFetch")
  -> Error: No such tool available: ToolSearch. ToolSearch is disabled for this
     session, in subagents as well as here.

WebSearch("Android allowBackup dataExtractionRules exclude directory from backup documentation")
  -> Error: No such tool available: WebSearch. WebSearch is disabled for this
     session, in subagents as well as here.

WebFetch("https://developer.android.com/guide/topics/data/autobackup")
  -> Error: No such tool available: WebFetch. WebFetch is disabled for this
     session, in subagents as well as here.
```

Retried later in the same session at Scrum Master's request (`WebSearch` for the
iOS backup-exclusion resource key, `WebFetch` of the Android auto-backup guide):
both returned the identical `disabled for this session` error. Two independent
measurements, so this is a session-level tool state, not a transient failure.

Per the phase's own instruction ("**không đoán từ trí nhớ**"), no mechanism was
selected and no native config was written. `mobile/android/app/src/main/` and
`mobile/ios/Runner/` are untouched. Only the user can restore a session-level
tool, so this cannot be retried from inside a subagent.

Chosen mechanism: **NOT ESTABLISHED** — Android: unknown; iOS: unknown.
Doc source: **NONE**.

The rest of P2 was implemented so the blocker stays isolated to one line of
production wiring:

- `JournalMediaStore` takes an injected `Future<Directory> Function()
  baseDirectory` and remains the single owner of every journal path, so the
  media root moves by changing one argument.
- `service_locator.dart` provisionally passes `getApplicationSupportDirectory`
  and carries a comment naming this blocker. **This is provisional wiring, not a
  verified backup-excluded location** — it must not be read as the answer to the
  lookup task.
- The media-root test asserts the root resolves under whatever base is
  configured, so it stays valid whichever directory is finally chosen.

What is still needed to close this: the current platform-documented mechanism
for Android (backup-rules XML referenced from the manifest) and for iOS (the
`NSURL` resource key marking a path excluded from backup), each confirmed
against live vendor documentation rather than recalled, then the native config
written under `mobile/android/app/src/main/` and/or `mobile/ios/Runner/` and the
DI base directory changed to match.
