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
- Outcome: P2 scope DELIVERED and green, story lane BLOCKED. The first run left
  `OS_BACKUP_EXCLUSION_UNVERIFIED` open because research tools were disabled; a
  second run with `WebSearch`/`WebFetch` enabled did the lookup and shipped both
  platforms' config. Command results below are from the second run and supersede
  the first run's counts. Every P2 acceptance criterion passes. The story's
  design reference was also resolved and rendered here (`s1:diary`, iOS). One
  blocker remains and it is outside this run's Write Scope:
  `PREEXISTING_TEST_FAILURE` — `flutter build ios` cannot exit 0 for any flavor
  on this project, because the Xcode project has no `Debug-<flavor>`
  configuration and is unchanged since BaseHead. That needs Scrum Master.

### Commands run

| Command | Result |
|---|---|
| `flutter analyze lib/core/journal lib/features/journal lib/core/di/service_locator.dart test/core/journal test/features/journal` | 4 issues, all `info • prefer_initializing_formals`; 0 errors, 0 warnings |
| `flutter analyze lib test` (full phase-required scope) | **0 errors** repo-wide; 192 issues total (35 warnings, rest info) — all pre-existing except the 4 infos above. The only other journal-adjacent hit is a pre-existing `unused_import` of `service_locator.dart` in `test/features/expenses/expenses_entry_point_test.dart`, a file P2 never touched. |
| `flutter test test/core/journal/journal_media_store_test.dart test/features/journal/journal_repository_test.dart` | **30/30 passed** (28 + the 2 new backup-exclusion cases) |
| `flutter test --reporter compact test/core/database/journal_dao_test.dart test/core/database/cupid_database_migration_v3_test.dart test/features/reminders/reminder_entry_point_test.dart test/features/pairing/presentation/pair_gate_cubit_test.dart` | **36/36 passed** (P1 regression + the `setupServiceLocator` consumers touched by the DI edit) |
| `flutter build apk --debug --flavor local` | **built** `build/app/outputs/flutter-apk/app-local-debug.apk` in 61.5s — proves both new `res/xml` rule files parse and that `@xml/backup_rules` / `@xml/data_extraction_rules` resolve, which is a hard AAPT2 error when they do not |
| `xcrun swiftc -typecheck -sdk $(xcrun --sdk iphoneos --show-sdk-path) -target arm64-apple-ios13.0 -F <flutter>/bin/cache/artifacts/engine/ios/Flutter.xcframework/ios-arm64 -import-objc-header Runner-Bridging-Header.h AppDelegate.swift SceneDelegate.swift` | **no diagnostics** |

Run from `mobile/` with `PATH="$HOME/flutter/bin:$PATH"` (Flutter 3.44.1).

The merged manifest was read back at
`build/app/intermediates/merged_manifests/localDebug/processLocalDebugManifest/AndroidManifest.xml:82-92`
to confirm no library manifest overrides the three attributes. It carries
`android:allowBackup="true"`, `android:dataExtractionRules="@xml/data_extraction_rules"`,
and `android:fullBackupContent="@xml/backup_rules"`, at `minSdkVersion="24"` /
`targetSdkVersion="36"` — which is why both attributes are declared rather than
only the Android 12+ one.

`flutter build ios` could NOT be run, for a reason unrelated to this phase: the
iOS project defines build configurations `Debug/Release/Profile` and a single
`Runner` scheme, with no counterpart to the Android `local`/`prod` flavors, so
`flutter build ios --debug --no-codesign` stops at *"You must specify a
--flavor option"* and `--flavor Runner` then stops at *"Flutter expects a build
configuration named Debug-Runner or similar"*. That is a pre-existing iOS
project-configuration gap, not a defect introduced here. The direct `swiftc
-typecheck` above is the substitute, run against the real Flutter iOS engine
framework and the project's own bridging header. It is a real check, not a
no-op: the identical command on a control file with
`values.isExcludedFromBackupTYPO = true` exits 1 with *"value of type
'URLResourceValues' has no member 'isExcludedFromBackupTYPO'"*.

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
| Media root resolves to the configured directory | `journal_media_store_test.dart` "media root resolves under the configured base directory" | PASS |
| Media root is in a location excluded from OS auto-backup, mechanism + doc source recorded | `journal_media_store_test.dart` group "backup exclusion (AC-9)", plus the Android APK build / merged-manifest read and the Runner `swiftc -typecheck` above | PASS |
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

### `OS_BACKUP_EXCLUSION_UNVERIFIED` — RESOLVED (section 3 lookup sub-task)

The first P2 run recorded this blocker because `ToolSearch`, `WebSearch`, and
`WebFetch` all returned `disabled for this session`, and the phase forbids
guessing from memory. Research tools were enabled for the follow-up run, the
lookup was performed against live vendor documentation, and both mechanisms are
now implemented. Nothing below is recalled; each claim traces to a fetched page.

**Chosen mechanism — Android: Auto Backup rules XML referenced from the
manifest.**

Two rule files are required, because the schema changed at Android 12 and the
app runs on both sides of that line (merged manifest: `minSdkVersion="24"`,
`targetSdkVersion="36"`):

- `mobile/android/app/src/main/res/xml/backup_rules.xml` — `<full-backup-content>`,
  wired as `android:fullBackupContent`, for API 30 and lower.
- `mobile/android/app/src/main/res/xml/data_extraction_rules.xml` —
  `<data-extraction-rules>` with `<cloud-backup>` and `<device-transfer>`,
  wired as `android:dataExtractionRules`, for API 31+.

Both exclude the same two paths, and both are exclude-only so every other app
file stays backed up:

| Rule | Resolves to | Contains |
|---|---|---|
| `<exclude domain="file" path="journal_media"/>` | `getFilesDir()`, which is what `getApplicationSupportDirectory()` returns on Android | the journal media root |
| `<exclude domain="root" path="app_flutter"/>` | private app storage root; `app_flutter` is `Context.getDir("flutter")`, which is what `getApplicationDocumentsDirectory()` returns | `cupid.sqlite` and its `-wal`/`-shm` sidecars |

Three decisions worth recording, each forced by something the docs say:

1. The DB is excluded as a *directory*, not as `app_flutter/cupid.sqlite`,
   because `path` supports no wildcard or regex syntax, so a file-level rule
   would leave the `-wal`/`-shm` sidecars backed up.
2. `<device-transfer>` repeats the excludes rather than being omitted. Omitting
   a section means that mode "is fully enabled for all content except for
   `no-backup` and `cache` directories", which would let a device-to-device
   migration carry the journal off the device. The pre-12 schema has no
   cloud/D2D split, so repeating them keeps one behaviour across all API levels.
3. `allowBackup` stays `true` with targeted excludes rather than flipping to
   `false`. That is Google's explicit recommendation for sensitive data, and it
   preserves backup for the rest of the app.

Doc sources (fetched):
- <https://developer.android.com/identity/data/autobackup> — manifest
  attributes, both XML schemas, the domain table, the no-wildcard rule, the
  omitted-section behaviour, and exclude-only semantics.
- <https://developer.android.com/privacy-and-security/risks/backup-best-practices>
  — exclude rules over `allowBackup=false`, and separate rule files per API era.
- <https://pub.dev/documentation/path_provider/latest/path_provider/getApplicationSupportDirectory.html>
  and `.../getApplicationDocumentsDirectory.html` — the Android mappings to
  `PathUtils.getFilesDir` and `PathUtils.getDataDirectory`.
- `flutter/engine` `shell/platform/android/io/flutter/util/PathUtils.java` —
  read to pin `getDataDirectory` to `getDir("flutter")`, i.e. the literal
  directory name `app_flutter`, which no prose doc states.

**Chosen mechanism — iOS: `URLResourceValues.isExcludedFromBackup`.**

iOS has no declarative equivalent of the Android rules file, so the attribute is
set per URL at runtime. `AppDelegate.swift` registers a
`com.snapsofts.cupid/backup_exclusion` method channel whose `excludeFromBackup`
handler applies `isExcludedFromBackup = true` via `url.setResourceValues(_:)`;
`service_locator.dart` injects a Dart wrapper (a no-op off iOS) into
`JournalMediaStore`, which calls it for every directory it creates.

Two decisions worth recording:

1. **Both the media root and each entry directory are tagged.** Apple documents
   the property per URL and never states that it descends into a directory's
   contents, so relying on recursion would be a guess. Tagging both is correct
   under either behaviour.
2. **The tag is applied at directory-creation time, not once at launch.**
   Deleting a directory discards its attributes, and `deleteRoot()` /
   `deleteEntryDir()` do exactly that, so a one-shot setup step in
   `AppDelegate` would silently stop protecting the journal after the first
   "delete all". `journal_media_store_test.dart` locks both points in.

The base directory stays `getApplicationSupportDirectory` — the first run's
provisional choice turns out to be the documented-correct one. Apple's own
guidance names `Application Support` as a location you exclude *from*, and
warns the property "should not be used on user documents"; the alternative
non-backed-up location, `Library/Caches`, is purgeable by the system and would
mean silent journal loss.

Doc sources (fetched):
- <https://developer.apple.com/documentation/foundation/urlresourcevalues/isexcludedfrombackup>
  — `var isExcludedFromBackup: Bool? { get set }`, Foundation, iOS 8.0+, plus
  the "cache and other application support files" / "should not be used on user
  documents" discussion.
- <https://developer.apple.com/library/archive/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/FileSystemOverview/FileSystemOverview.html>
  — Table 1-1 backup status per directory (`Library` except `Caches` is backed
  up; `Documents` is backed up), and the `NSURLIsExcludedFromBackupKey`
  instruction for `Documents/` and `Application Support/`.
- <https://pub.dev/documentation/path_provider/latest/path_provider/getApplicationSupportDirectory.html>
  — the iOS mapping to `NSApplicationSupportDirectory`.

### BLOCKER: `PREEXISTING_TEST_FAILURE` — `flutter build ios` cannot pass here

Command: `PATH="$HOME/flutter/bin:$PATH" flutter build ios --debug --no-codesign`
Result: non-zero exit, both ways it can be invoked. Re-run and re-confirmed at
the current branch head `2a357a2e` (the branch moved on twice while this run was
open: `b081f408` -> `040d53bf` -> `2a357a2e`, both new commits made by Scrum
Master), exit code 1, byte-identical failure, with Flutter naming the cause:

```
The Xcode project defines schemes: firebase-auth, firebase-core,
firebase-messaging, flutter-facebook-auth, flutter-secure-storage-darwin,
FlutterFramework, FlutterGeneratedPluginSwiftPackage, google-sign-in-ios,
image-picker-ios, mobile-scanner, permission-handler-apple, Runner, share-plus,
shared-preferences-foundation, sign-in-with-apple, sqflite-darwin,
sqlite3-flutter-libs
You must specify a --flavor option to select one of the available schemes.
EXIT=1
```

Sixteen of those seventeen "schemes" are Swift Package Manager packages.

- with no flavor — `You must specify a --flavor option to select one of the
  available schemes.`
- with `--flavor Runner` — `The Xcode project defines build configurations:
  Debug, Release, Profile` / `Flutter expects a build configuration named
  Debug-Runner or similar.`

Proof this is pre-existing, not caused by this story:

- `xcodebuild -list -project mobile/ios/Runner.xcodeproj` reports exactly three
  build configurations: `Debug`, `Release`, `Profile`. There is no
  `Debug-<flavor>` configuration for **any** flavor, so no `--flavor` value can
  make the command exit 0.
- The 17 "schemes" it lists are not app flavors. Only one scheme is actually
  shared by the project — `Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme`
  is the single file there. The other 16 (`firebase-auth`, `FlutterFramework`,
  `share-plus`, …) are Swift Package Manager package schemes that leak into the
  project listing. Flutter infers flavors from the scheme list, sees more than
  one, and therefore demands a `--flavor` this project has no configuration for.
  That is the root cause, and it is an iOS project/tooling configuration issue
  rather than anything this story can express.
- `git diff --name-only <BaseHead> -- mobile/ios` returns only
  `mobile/ios/Runner/AppDelegate.swift`. `Runner.xcodeproj/project.pbxproj` is
  byte-identical to BaseHead, and the failure is emitted while Flutter inspects
  the Xcode project, before a single Swift file is compiled.

Owner of the fix, out of this run's Write Scope:
`mobile/ios/Runner.xcodeproj/project.pbxproj`. This run's Write Scope covers
`mobile/ios/Runner`, the source directory — not the sibling `.xcodeproj`.
Android has `local`/`prod` flavors; iOS was never given matching build
configurations, so the two platforms' flavor setups have drifted apart. That is
a DevOps / project-configuration item, worth a bug rather than a silent patch.

Substitute evidence that the Swift this story added actually compiles:
`xcrun swiftc -typecheck` against the real Flutter iOS engine framework plus the
project's bridging header, clean, with a deliberate negative control (a
misspelled `isExcludedFromBackupTYPO`) proving the check is not a no-op.

### `DEV_DESIGN_RENDER` — design reference rendered, screen id resolved

The story had no `visual-fidelity/` directory and no `Design-Screen:` line, so
the reference was resolved and rendered here rather than left for P3.

`design-reference-s1:diary-ios.png` (416x900) is now in
`../visual-fidelity/`, and `Design-Screen: s1:diary` is recorded in
`../story_master.md`.

**How the id was confirmed, not guessed.** `--list-screens` on the `cupid-app`
surface returned 120 ids; `s1:diary`, `s1:notebook` and `s1:memory` were the
plausible ones for a private journal. The rendered `s1:diary` iOS frame shows
the heading `Nhật ký`, the subtitle `chỉ mình đọc · 9 dòng`, three dated entries,
a compose FAB, and the note *"Nhật ký không xuất ra được, không có nút chia sẻ.
Xoá một dòng hay xoá cả sổ cũng chỉ một thao tác."* — no export, no share,
one-tap delete of an entry or the whole book. That is this story's AC-11/AC-12
verbatim, so the id is confirmed by content.

**Android canvas defect found while resolving it — matters for P3.** On
`--platform=android`, `s1:diary`, `s1:notebook`, `s1:memory` and `s1:list` all
render a byte-identical placeholder (`md5 a48a85efb7621d618ccf799aa31fe67d`)
reading *"Chặng 1 chỉ có một máy"* — the screen id has no effect. A control
render of `login` on the same platform produced a different, correct image, so
the renderer works; it is the canvas's `s1:*` android states that do not
resolve. **Render this story's references on iOS.** Rendering android here would
have produced a believable wrong reference and a meaningless comparison.

The renderer also warns that the configured `hide_selectors`
(`[data-plat] [style*="z-index: 95"]`) match nothing and may be stale after a
design update — worth a UX check, since a stale selector means references can
carry prototype chrome.

**Still open for P3:** there is no `implemented-*.png` and no
`visual-fidelity-report.md` verdict, because no screen has been built. P2 is the
data layer and its phase file declares `Per-story visual fidelity:
NOT_APPLICABLE`. The P3 run must capture `implemented-s1:diary-*` against this
reference and write the `VISUAL_FIDELITY:` verdict. No verdict was written here:
a PASS or FAIL without a capture would assert a comparison nobody made.

### Residual, out of P2 Write Scope — needs Scrum Master

The iOS side of the **database** exclusion is not shipped. Android covers the DB
declaratively (`app_flutter` above, one line in a file this phase owns), but on
iOS the DB path is decided by `_openConnection()` in
`mobile/lib/core/database/cupid_database.dart:73-79` — a P1 file outside this
phase's Write Scope — which puts `cupid.sqlite` in
`getApplicationDocumentsDirectory()`, i.e. `Documents/`, which Apple documents
as backed up by default.

This matters because `architecture/solution.md` section 4 states the AC-9
requirement as "media root **và file DB** phải nằm ở vị trí bị loại khỏi sao lưu
tự động trên cả hai nền tảng", while the P2 phase file's own acceptance criteria
only cover the media root. So the gap is between two artifacts, not a missed
task: P2 delivered its stated AC in full.

Closing it is a small, well-understood change, deliberately not made here rather
than widening scope unilaterally: have the DB open path call the same
`excludeFromBackup` channel on the sqlite file (and, because the attribute is
per URL, on its `-wal`/`-shm` companions), or move the DB under the already
covered support directory. Excluding the DB loses nothing recoverable — the v1/v2
tables are server-authoritative refetchable caches, and journal rows are
device-authoritative by design (AC-9 chooses privacy over cloud recoverability).

## Phase P3 — Journal list screen + delete flows

Status: **COMPLETE**. Implementation, both declared test files, the scoped
analyzer and the per-story visual-fidelity gate are done and green. An earlier
revision of this section reported `MOBILE_VISUAL_AUDIT_SCREEN_UNREACHABLE`; that
blocker is **resolved and withdrawn** — see "Visual fidelity" below for how the
capture was obtained without touching an out-of-scope file.

### Files delivered

- `mobile/lib/features/journal/presentation/journal_list_cubit.dart` (new)
- `mobile/lib/features/journal/presentation/screens/journal_screen.dart` (new)
- `mobile/lib/l10n/arb/app_vi.arb`, `mobile/lib/l10n/arb/app_en.arb` — 14 new
  keys each (template locale is `app_vi.arb`)
- `mobile/test/features/journal/journal_list_cubit_test.dart` (new)
- `mobile/test/features/journal/journal_screen_test.dart` (new)

### Commands run

All from the story worktree, `mobile/` as cwd, with
`export PATH="$HOME/flutter/bin:$PATH"` (the SDK is not on the default PATH and
`FLUTTER_SDK_PATH` is empty — see `coding-agent-guide.md` section 5).

1. `flutter pub get` — OK.
2. `flutter gen-l10n` — OK. `mobile/l10n-untranslated.json` is `{}`, so the two
   ARB files stayed key-identical and `test/l10n/arb_parity_test.dart` has
   nothing to report.
3. `flutter analyze lib/features/journal lib/l10n test/features/journal`
   → `3 issues found`, all `info`, all three pre-existing in
   `lib/features/journal/data/journal_repository.dart:25-27` (a P2 file, not in
   this phase's Write Scope, and unmodified here — `git diff --stat` against
   `BaseHead` lists only the two ARB files plus the four new untracked files).
   **Zero issues in any file this phase owns.**
4. `flutter test test/features/journal/journal_list_cubit_test.dart test/features/journal/journal_screen_test.dart`
   → `+19 ~2: All tests passed!` (10 cubit + 9 widget; the 2 skips are the
   capture tests, which run only under `--dart-define=CAPTURE_VISUALS=true`).
5. `flutter test test/features/journal/journal_screen_test.dart --dart-define=CAPTURE_VISUALS=true`
   → `+11: All tests passed!`, writing both `implemented-s1:diary-*.png` files.

Re-run and re-verified in the session that closed this phase; results identical.

Only the two phase test files were run, per `coding-agent-guide.md` section 5:
the repo carries pre-existing red tests and one red combined run would lock the
phase evidence gate.

### Test coverage against the declared scope

`journal_list_cubit_test.dart` (10 tests) runs the **real** `JournalRepository`
over a real in-memory drift database, so the paging and delete assertions are
against the shipped query, not against a fake:

- empty emission, and data emission ordered newest-first
- `sweepOrphans` called exactly once, on open (AC-13's compensating half)
- pagination: one page window held, `loadMore` widens by one page, `loadMore`
  on the last page is a no-op
- `deleteEntry` (AC-11) removes the row and updates the list
- `deleteAll` (AC-12) empties the repository **and** resets the window, so the
  screen returns to the first-open empty state rather than a scrolled-open one
- privacy egress gate over both new source files: no `share_plus`, `dio`,
  `cupid_api`, `RealtimeCoordinator`, `Clipboard`, `hydrated_bloc` or
  `cached_network_image` import (AC-6, AC-7, AC-10)

`journal_screen_test.dart` (9 tests):

- renders the neutral empty state with the single compose CTA
- renders two entries as list rows
- **absence gate, AC-1/BR-4:** with 0 and with 3 entries, no rendered `Text`
  matches a count pattern (`\d+\s*(mục|dòng|ngày|bài|entr(y|ies)|days?|notes?)`)
  or a streak/goal pattern (`chuỗi|liên tiếp|mục tiêu|streak|goal|progress|in a
  row`), and there is no `LinearProgressIndicator`/`CircularProgressIndicator`
- **absence gate, AC-6:** no `Icon` in the tree — list, entry menu or header
  menu — carries a share/export/copy/send/download/link glyph, and no rendered
  label matches `chia sẻ|xuất|sao chép|gửi|share|export|copy|send|download`.
  Both popup menus are opened and asserted to hold exactly one row
  (`PopupMenuEntry` count == 1), which is what makes "no hidden export row
  beside delete" checkable rather than assumed.
- delete-one through the confirm dialog (AC-11), including the cancel path
- delete-all through the confirm dialog (AC-12), returning to the empty state
  with no `SnackBar` undo affordance left behind (AC-13)

Minimum gates from the phase file: `PRIVACY_EGRESS_GATE_UNRUNNABLE` — not hit,
the gate runs (cubit test file, `privacy egress gate` group).
`STREAK_ABSENCE_TEST_UNRUNNABLE` — not hit, the gate runs (widget test file,
`absence gates` group).

### Why the widget test uses a fake repository, and the cubit test does not

The widget test drives `_FakeJournalRepository`, an in-memory subclass. This is
a forced choice, not a shortcut: drift schedules a zero-duration `Timer` in
`StreamQueryStore.markAsClosed` when a query stream is cancelled, and that timer
outlives the disposed widget tree, so `testWidgets` fails every test with
`A Timer is still pending even after the widget tree was disposed`
(`AutomatedTestWidgetsFlutterBinding._verifyInvariants`, binding.dart:2542) and
the run then hangs. Observed on the first attempt at the real repository here.

The real repository is therefore covered where it can be: by
`journal_list_cubit_test.dart` (real DB, this phase) and by
`journal_repository_test.dart` (real DB, P2). The widget test covers wiring and
the absence gates, which is what it is for.

### Defect found and fixed while writing the tests

Both popup menus were first written as `PopupMenuButton<void>` with
`PopupMenuItem<void>(value: null)`. `PopupMenuButton` treats a null menu result
as a **dismissal** and calls `onCanceled`, not `onSelected` — so neither delete
row would ever have fired. Fixed by giving the rows real values through a closed
`_JournalMenuAction` enum. It is recorded because the failure mode is silent in
manual use: the menu closes and nothing happens.

### Visual fidelity — `VISUAL_FIDELITY: PASS`

Full comparison: `../visual-fidelity/visual-fidelity-report.md`.

Artefacts in `../visual-fidelity/`:

- `design-reference-s1:diary-ios.png` (416x900, resolved by the P2 run)
- `implemented-s1:diary-ios.png` (393x852, populated state)
- `implemented-s1:diary-empty-ios.png` (393x852, empty state)

Capture command (from `mobile/`):

```
flutter test test/features/journal/journal_screen_test.dart \
  --dart-define=CAPTURE_VISUALS=true
```
→ `+11: All tests passed!` (the 9 behavioural tests plus the 2 capture tests,
which are `skip:`-ped in the ordinary run so the default suite stays hermetic).

**Why not `capture-mobile-screen.sh`.** That tool photographs a screen a device
is already showing, and nothing can put `JournalScreen` on a device from this
phase: there is no `journal`/`diary` key in `previewScreens`
(`mobile/lib/main_preview.dart:145`) and no route, because section 6 of the phase
file assigns the navigation entry point to P5. Both files are outside this
phase's Write Scope, and `main_preview.dart` is on the handoff's do-not-touch
list.

**What was done instead.** The screen was rendered directly through
`RepaintBoundary.toImage` at the iOS reference viewport, inside
`journal_screen_test.dart` — a Write Scope file — with the real
`buildCupidTheme(platform: CupidPlatform.ios, brightness: Brightness.dark)` and
real fonts loaded off disk via `FontLoader`. This follows the existing in-repo
precedent for exactly this situation,
`mobile/test/features/reminders/visual_capture_support.dart` (STORY-021). So the
gate is satisfied with a genuine implemented capture and no scope violation; the
earlier `MOBILE_VISUAL_AUDIT_SCREEN_UNREACHABLE` blocker is withdrawn, and no
Scrum Master decision is outstanding.

**Verdict summary.** PASS. Everything the ACs and `../ux/uiux-spec.md` bind is
present and correct. Three differences against the design canvas are recorded as
`DESIGN_SPEC_CONFLICT` — the canvas contradicts binding requirements and must not
be implemented: the `· 9 dòng` entry counter (forbidden by AC-1/BR-4 and spec
lines 20-21, 27), the rendered `originRef` chip (forbidden by
`../architecture/solution.md` section 4), and the bottom tab bar (this story is a
pushed full-screen surface; its entry point is P5's). Five remaining deltas are
cosmetic, none AC-bearing, all listed in the report for the designer and P5.

**Disclosure.** In the captures the two `Icons.more_horiz` menu glyphs rasterise
as empty squares: `MaterialIcons` is not a pubspec-declared font family, so a
widget render cannot load it. Text and design-system glyphs render correctly. On
device the icon is normal. The captures also carry no device chrome.
