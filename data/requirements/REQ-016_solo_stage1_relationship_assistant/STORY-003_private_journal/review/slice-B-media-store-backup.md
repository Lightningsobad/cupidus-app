# STORY-003 Scoped Review — Slice B: Media store / Repository / Backup exclusion

- Reviewer: Iris-QC
- Date: 2026-09-08
- Mode: scoped-slice (Slice B of A–E + synthesis pass F)
- Outcome: `PARTIAL_SLICE_ONLY` — 3 must-fix, 1 deferred, 1 known item now RESOLVED
- Story: STORY-003 (REQ-016)
- Branch: `codex/REQ-016_solo_stage1_relationship_assistant-STORY-003`
- BaseHead: `62f451733d191b666b718b595ead4621676e3e1c`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-003`

This slice does NOT issue a story-level verdict. It covers only the P2 media
store, repository, DI registration, and OS backup-exclusion configuration.
Schema/DAO is slice A; cubits, screens, entry point, and visual fidelity are
slices C–E.

## Files reviewed (diff-scoped)

| File | Δ |
|---|---|
| `mobile/lib/core/journal/journal_media_store.dart` | +107 (new) |
| `mobile/lib/features/journal/data/journal_repository.dart` | +192 (new) |
| `mobile/lib/features/journal/domain/journal_entry.dart` | +94 (new) |
| `mobile/lib/core/di/service_locator.dart` | journal block `:438-461`, `_excludeFromOsBackup` `:570-581` |
| `mobile/android/app/src/main/AndroidManifest.xml` | +4 −1 |
| `mobile/android/app/src/main/res/xml/backup_rules.xml` | +23 (new) |
| `mobile/android/app/src/main/res/xml/data_extraction_rules.xml` | +22 (new) |
| `mobile/ios/Runner/AppDelegate.swift` | +46 |

Evidence read: `coding-plan/test-results.md` `## Phase P2` (`:133-307`, ranged);
`mobile/test/core/journal/journal_media_store_test.dart`;
`mobile/test/features/journal/journal_repository_test.dart`.
`mobile/lib/core/database/cupid_database.dart:73-79` was read out-of-slice for
one fact only: which directory holds `cupid.sqlite` (needed by RB-3).

## Risk items

| Id | Item | Verdict |
|---|---|---|
| RB-1 | Private media store — photos copied into a non-shared, per-user media root (AC-2) | **FAIL** (privacy half PASS; per-user scoping absent) |
| RB-2 | Cascade delete — entry / whole-journal delete removes media, no orphans (AC-4/AC-5) | **PASS** with one gap (see F-B2) |
| RB-3 | OS backup exclusion — Android rules actually exclude the journal media root | **PASS** (Android); iOS media PASS, iOS DB **FAIL** |
| RB-4 | P2 test evidence exists and passes for this slice's files | **PASS** |

### RB-1 — private media store — FAIL (narrow)

Privacy half PASSES. `journal_media_store.dart:46-55` `importPhoto` performs a
real `File(sourcePath).copy(...)` into `<base>/journal_media/<entryId>/<uuid4>.<ext>`
and returns a path *relative* to the root, which is what `journal_photos` stores
(`journal_repository.dart:90-100`). The base is
`getApplicationSupportDirectory` (`service_locator.dart:450`) — app-private on
both platforms, never a shared/external location. Nothing outside
`JournalMediaStore` builds a journal path; `journal_entry.dart:24-26` documents
`relativePath` as resolve-only-through-the-store. Copy independence is proven in
both directions (`journal_media_store_test.dart:98-119`). No cross-account
*read* is possible: `resolvePhoto` is only ever reached from DB rows already
filtered by `ownerUserId` (`journal_repository.dart:39-42,167-191`).

The per-user half does NOT hold, and it has a concrete consequence. The media
root is one flat, device-wide `journal_media/` keyed by entry id only — there is
no owner segment anywhere in the path. `journal_entry.dart:57` states
`ownerUserId` "is the only isolation between two accounts sharing one device",
and `service_locator.dart:438-443` deliberately does NOT register the journal as
a `CupidSession` scoped store, precisely so journal data survives sign-out
("clearing it on sign-out would be permanent data loss"). Both statements are
true of the DB rows and false of the files:

- `journal_repository.dart:159-165` `sweepOrphans()` passes only the *current*
  owner's `liveEntryIds`. Sign in as account B, open the journal → every entry
  directory belonging to account A has a non-live id and is deleted
  (`journal_media_store.dart:80-91`). Account A's rows survive and now point at
  missing files.
- `journal_repository.dart:148-155` `deleteAll()` calls `mediaStore.deleteRoot()`,
  which removes the whole device-wide root — account B's "delete my journal"
  deletes account A's photos too, while leaving A's rows.

Not a privacy leak; a durability defect that reintroduces exactly the permanent
data loss the DI comment says it is avoiding. No test covers two owners: the
`without a backend user id` group (`journal_repository_test.dart:210-248`)
covers `owner == null` only, and every other case uses the single `user-a`.

### RB-2 — cascade delete — PASS

- Single entry: `journal_repository.dart:137-144` commits the row delete first,
  then `deleteEntryDir(id)` removes the directory recursively
  (`journal_media_store.dart:62-67`). Verified end to end at
  `journal_repository_test.dart:138-159` — `e-1` dir gone, `e-2` untouched,
  `entryById('e-1')` null.
- Whole journal: `journal_repository.dart:148-155` then
  `journal_media_store.dart:69-74` `deleteRoot()`. Verified at
  `journal_repository_test.dart:162-181` — table empty AND root non-existent.
- Crash window: the DB-row-first order can only ever leave surplus files, never
  a row pointing at a missing photo. The compensating sweep is real and
  fault-injected, not asserted: `journal_repository_test.dart:183-207` commits
  `dao.deleteEntry` alone, asserts the directory still exists, then sweeps.
- Rollback on failed save is also fault-injected (`DROP TABLE journal_photos`,
  `journal_repository_test.dart:106-123`) and leaves no file.

Gap, not a failure of this gate: the sweep is directory-granular only — see F-B2.

### RB-3 — OS backup exclusion — PASS (Android), iOS DB FAIL

Android is correct and the path mapping was verified against the real
directories, not assumed:

- `AndroidManifest.xml:19-25` declares `allowBackup="true"` with both
  `fullBackupContent="@xml/backup_rules"` (API ≤30) and
  `dataExtractionRules="@xml/data_extraction_rules"` (API 31+). Both are needed
  at `minSdkVersion=24` / `targetSdkVersion=36`.
- `backup_rules.xml:20-22` and `data_extraction_rules.xml:12-21` exclude
  `domain="file" path="journal_media"` — `domain="file"` is `getFilesDir()`,
  which is what `getApplicationSupportDirectory` returns on Android, and
  `journal_media` is exactly `JournalMediaStore.mediaRootName`
  (`journal_media_store.dart:24`). The media root is genuinely covered.
- `domain="root" path="app_flutter"` covers the DB. Confirmed independently:
  `cupid_database.dart:73-79` opens `cupid.sqlite` under
  `getApplicationDocumentsDirectory()`, which on Android is
  `Context.getDir("flutter")` → `app_flutter`. Directory-level exclusion is the
  right choice — `path` takes no wildcards, so a file-level rule would leave the
  `-wal`/`-shm` sidecars backed up.
- `<device-transfer>` repeats the excludes rather than being omitted; an omitted
  section is fully enabled, which would let a D2D migration carry the journal
  off the device.
- Build-level proof that the rules parse and resolve:
  `flutter build apk --debug --flavor local` built (unresolved `@xml/...` is a
  hard AAPT2 error), and the merged manifest was read back at
  `build/app/intermediates/merged_manifests/localDebug/.../AndroidManifest.xml:82-92`
  to confirm no library manifest overrides the three attributes
  (`test-results.md:156,161-167`).

iOS media — the known gap is RESOLVED, not open. `AppDelegate.swift:24-60`
registers the `com.snapsofts.cupid/backup_exclusion` channel and applies
`URLResourceValues.isExcludedFromBackup = true` via `url.setResourceValues`;
`service_locator.dart:575-581` injects the Dart wrapper (no-op off iOS) and
`journal_media_store.dart:93-97` `_createExcluded` calls it for every directory
it creates. Two subtleties are handled correctly and locked by tests: root AND
entry dir are both tagged, because the resource key is documented per URL and
not as recursive (`journal_media_store_test.dart:50-59`); and the tag is
re-applied at creation time rather than once at launch, because `deleteRoot()`
discards it (`journal_media_store_test.dart:61-71`). `test-results.md:212-307`
records the second P2 run that closed `OS_BACKUP_EXCLUSION_UNVERIFIED` with
fetched vendor sources, plus a `swiftc -typecheck` against the real Flutter iOS
engine framework, negative-controlled with a deliberate typo. Carried-forward
note only: `flutter build ios` still cannot exit 0 on this project
(`PREEXISTING_TEST_FAILURE`, tracked separately, fixed for the Xcode
configuration half at `62f4517`), so the Swift handler has never been executed
on a device — the mechanism is verified by documentation and type-check, not by
runtime observation.

iOS DB — FAIL, and this is NOT the carried-forward iOS gap. Android excludes the
journal *text* by excluding `app_flutter`; iOS excludes only `journal_media`.
`cupid.sqlite` lives in `getApplicationDocumentsDirectory()`
(`cupid_database.dart:75-76`) = `NSDocumentDirectory`, which is backed up to
iCloud by default, and nothing in the diff tags it. The entry bodies — the
primary private content of this story — therefore still leave an iOS device via
Auto Backup. `test-results.md:236-239` shows the DB was consciously in scope for
AC-9 on Android; the iOS section (`:268-294`) covers only the directories
`JournalMediaStore` creates. See F-B3.

### RB-4 — P2 test evidence — PASS

`test-results.md:154` records
`flutter test test/core/journal/journal_media_store_test.dart test/features/journal/journal_repository_test.dart` → **30/30 passed**.
Static analysis over the same scope (`:152-153`) is 0 errors / 0 warnings; the 4
`prefer_initializing_formals` infos are structural (Dart forbids `this._x` in a
named parameter) and match pre-existing repo usage. Both test files were read
directly, not taken on trust — the assertions match the claimed coverage rows,
including the two fault-injected cases.

## Findings

### F-B1 — must-fix — journal media root is not owner-scoped, so a second account destroys the first's photos

`journal_media_store.dart:80-91` + `journal_repository.dart:148-165`. Path is
`journal_media/<entryId>/...` with no owner segment. `sweepOrphans()` (called on
journal open) and `deleteAll()` both operate device-wide while their live-id /
authorization input is owner-filtered. Result: account B opening or clearing the
journal deletes account A's photo files, leaving A's rows dangling. Contradicts
`service_locator.dart:440-443` (journal is deliberately not session-scoped to
avoid permanent data loss) and `journal_entry.dart:57`.
Fix direction (owner's choice): put the owner id in the path
(`journal_media/<ownerUserId>/<entryId>/`), or make `sweepOrphans`/`deleteRoot`
operate on the owner's subtree only. Add a two-owner test — none exists.
Owner: mobile-dev.

### F-B2 — must-fix — re-saving an entry orphans its previous photo files, and the sweep cannot reach them

`journal_repository.dart:117-122` deletes all `journal_photos` rows for the id
and re-inserts, but never deletes the corresponding files; `importPhoto` always
mints a fresh uuid, so a re-import lands beside the old file
(`journal_media_store_test.dart:87-96` proves two files accumulate in one entry
dir). `sweepOrphans` only removes *directories* whose name is not a live entry
id (`journal_media_store.dart:86-90`), so it never inspects files inside a live
entry. A photo the user removes from an entry stays on disk for the entry's
whole life — against In Scope §3 "không giữ bản sao ẩn". Bounded: the residue
does go away when the entry itself is deleted (`deleteEntryDir` is recursive).
Whether this is reachable today depends on how the P4 composer re-saves an
edited entry, which is slice D scope — synthesis should resolve F-B2 against the
slice D finding before choosing severity.
Fix direction: delete files for rows being replaced inside `saveEntry`, or make
`sweepOrphans` also drop files under a live entry dir that no row references.
Owner: mobile-dev.

### F-B3 — must-fix — iOS journal database is not excluded from iCloud backup

`cupid_database.dart:75-76` puts `cupid.sqlite` in `NSDocumentDirectory`, which
iOS backs up. Only `journal_media` is tagged on iOS
(`journal_media_store.dart:93-97`). Android excludes both
(`backup_rules.xml:21-22`). Net effect: journal *text* still reaches iCloud on
iOS, which is the risk surface "Sao lưu tự động của OS đẩy nhật ký lên cloud".
Distinct from the carried-forward `OS_BACKUP_EXCLUSION_UNVERIFIED` item (which
concerned the iOS *media* mechanism and is now resolved); this one is a real
coverage asymmetry visible in the delivered config.
Caveat for triage: the DB file location is pre-existing (REQ-002 era), but this
story is what put private journal content into it, and the Android side of the
same story treats the DB as in scope for AC-9 — so it is a half-implemented gate
of this story, not untouched legacy. Note also that tagging
`Documents/` conflicts with Apple's own "should not be used on user documents"
guidance quoted at `test-results.md:290-294`; moving the DB is a
cross-requirement change, so escalate rather than patch blind.
Fix direction: escalate to Tech Lead for a scoped decision (tag the sqlite file
+ sidecars, or relocate the DB to Application Support with a migration).
Owner: tech-lead, then mobile-dev.

## Deferred

### D-B1 — deferred — iOS backup exclusion has never executed at runtime

`flutter build ios` cannot exit 0 on this project, so the `AppDelegate` handler
and the Dart channel call have only been type-checked, never run. If the
`registrar(forPlugin: "CupidBackupExclusion")` lookup ever returns nil, the Dart
side would throw `MissingPluginException` out of `importPhoto` and every photo
save on iOS would fail — the failure mode is loud, not silent, but it is
unproven. Re-verify when an iOS build/run becomes possible.

## Carried forward (not re-litigated)

- `OS_BACKUP_EXCLUSION_UNVERIFIED` (iOS media mechanism) — recorded RESOLVED by
  the second P2 run, `test-results.md:212-307`. Confirmed present in code, not
  re-opened. The scope note in the handoff (expecting no iOS code) is stale.
- `PREEXISTING_TEST_FAILURE` / `flutter build ios` — out of slice.
- Slice A's schemaVersion literal fix (`fcc5066`) — out of slice, not re-checked.

REVIEW_SLICE_COMPLETE: YES
