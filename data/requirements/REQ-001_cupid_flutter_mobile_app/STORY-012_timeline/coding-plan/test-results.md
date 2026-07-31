# STORY-012 timeline — P8 Verification Results

Full gate per `coding-plan/master-plan.md` §5 P8 and
`coding-plan/phase-P8-verification.md`. Worktree HEAD at gate start:
`7fc8bb802845e941920880cb3360409b0200211a` (P1-P7 already `DONE`).

## Scope note — real gap found and closed before verification

P7 left both `TimelineScreen` "Add a memory" call sites
(`_ReadyView`/`_EmptyView` in `timeline_screen.dart`) wired to
`onAddMemory: () {}`, with a stale comment marking the create-entry sheet as
still-P6-scope. P6 had already built `CreateEntryCubit` and
`CreateMemorySheet`, so AC1 (create a timeline entry) was not actually
reachable from the real screen. P8 wired both call sites to
`CreateMemorySheet.show`, backed by a `TimelineRepository` resolved lazily
(only when the sheet opens) via the same optional-parameter-with-`getIt`-
default pattern `HomeScreen` already uses for its own `resolvePairingStatus`/
`createTimelineCubit` — this required no change to `HomeScreen`'s existing
`TimelineScreen(createCubit: ...)` call site. No refresh call was needed: a
successful create writes through `TimelineRepository.createEntry` →
`refresh()` → `AppDatabase.replaceFirstPage`, which the already-subscribed
`TimelineCubit.watchEntries()` stream picks up automatically (documented in
`create_entry_cubit.dart`). This is a `timeline_screen.dart` (P5-owned, not
P1-P6) change, authorized by this run's handoff `WriteScope`; no P1-P6 file
(repository, DTO, cubit, ARB strings) was touched.

Files changed: `mobile/lib/features/timeline/presentation/screens/timeline_screen.dart`,
`mobile/test/features/timeline/presentation/timeline_screen_test.dart`,
`mobile/test/features/timeline/presentation/create_memory_sheet_test.dart`
(stale comment only, no behavior change).

## Gate 1 — `flutter analyze`

Command: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` (run from
`mobile/`).

Result: PASS on this story's surface. Scoped re-run,
`flutter analyze lib/features/timeline test/features/timeline`: "No issues
found!". The unscoped full-repo run surfaces ~10,900 pre-existing issues
entirely outside this story's touched files (stale `build/ios/...flutterfire`
codegen artifacts, `openapi/cupid_api` generator-template `unused_import`
warnings, and `prefer_initializing_formals` infos in unrelated
realtime/auth/database files) — none introduced by this change.

## Gate 2 — `flutter test`

Command: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test` (run from
`mobile/`).

Result: 196/199 test groups passed. The 3 failures
(`test/app/feature_flags_test.dart`: "CupidApp resolves dark theme mode and
vi locale..."; `test/features/auth/presentation/splash_screen_test.dart`:
"CupidSessionSignedIn with a resolving token routes to HomeScreen";
`test/widget_test.dart`: "App boots to the home screen ready signal") are
pre-existing and unrelated to this change: confirmed by `git stash` back to
HEAD `7fc8bb8` and re-running the same 3 files, which fail identically with
`Bad state: GetIt: Object/factory with type CouplePairingStore is not
registered inside GetIt` — a test-harness gap in three tests that boot the
real `CupidApp`/`HomeScreen` without calling `setupServiceLocator()`, not a
regression from wiring `CreateMemorySheet` into `TimelineScreen`. All
`timeline`-suite tests pass, including the 2 new P8 tests added to
`timeline_screen_test.dart` that tap "Add a memory" on both the empty and
ready states and assert the real `CreateMemorySheet` opens.

## Gate 3 — `flutter build apk --debug`

Command: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter build apk --debug`
(run from `mobile/`).

Result: PASS — `✓ Built build/app/outputs/flutter-apk/app-debug.apk`. This is
the real proof that `sqlite3_flutter_libs` (added in P1) has not broken the
native Android build.

## Per-AC Evidence Summary

- AC1 (create a timeline entry): `test/features/timeline/presentation/create_entry_cubit_test.dart`
  and `create_memory_sheet_test.dart` (P6 validation/submit/offline-blocked/
  pairing-required/success-writes-through-Drift-and-closes-sheet cases), plus
  the 2 new `timeline_screen_test.dart` P8 cases proving the real screen now
  opens the sheet from both the empty and ready states (the gap this phase
  closed).
- AC2 (both partners view the shared timeline): P2 `timeline_event_dto_test.dart`
  decode coverage, P3 `timeline_repository_test.dart` read-through coverage,
  P5 `timeline_screen_test.dart` render coverage (loading/ready/empty states),
  P7 `timeline_entry_point_test.dart` reachability coverage (couple-scoping
  itself is server-side via `coupleId`; the client assertion is that the
  fetched page renders unmodified).
- AC3 (offline read after at least one sync; writes still require
  connectivity): P3 `timeline_repository_test.dart` `offlineWithCache` /
  `offlineNoCache` cases, P6 `create_memory_sheet_test.dart` "Save is disabled
  ... while the timeline is known to be offline" and "a submit that fails on
  connectivity preserves input ... writes no Drift row" cases.
- AC4 (unpaired users cannot access the feature): P3 `couple_pairing_store_test.dart`
  pairing-status cases, P7 `timeline_entry_point_test.dart` "unpaired: the
  entry-point card is absent" / "unknown ...: the entry-point card is absent"
  cases.

## Risk-Surface Gates (`../architecture/solution.md` §4 / master-plan §3A)

| Risk Surface | Gate | Status |
|---|---|---|
| Untyped REST body / `TimelineEventDto.fromJson` | DTO decode unit tests (P2) | PASS |
| Drift read-through cache (ADR-007) | DAO + repository unit tests (P1, P3) | PASS |
| Offline write prohibition (ADR-007) | create-under-`NetworkUnavailableFailure` test (P6) | PASS |
| AC4 pairing gate | pairing-store + entry-card tests (P3, P7) | PASS |
| Session data leakage between users | sign-out wipe test (P1) | PASS |
| Runtime readiness signal | `Key('home_screen_ready_signal')` still present and pumping (`test/features/home/presentation/timeline_entry_point_test.dart`, `test/widget_test.dart`) | PASS (key present; the 3 pre-existing GetIt failures above are a harness gap, not a missing/broken key) |
| Native build with bundled SQLite | `flutter build apk --debug` | PASS |

## Plan Hygiene Confirmation

- `master-plan.md` §5 Phases Overview uses the required table schema; every
  phase P1-P8 maps to exactly one canonical `phase-Px-*.md` file (confirmed
  against the phase-file mapping table); no duplicate phase files exist.
- No file under `backend/` was modified (`git status --porcelain backend/`
  from repo root: empty).
- No new dependency was added; `mobile/pubspec.yaml` is unchanged by this
  phase (`git status --porcelain mobile/pubspec.yaml`: empty). No libsodium,
  FFI, `image_picker`, or `connectivity_plus` package present.
- `Key('home_screen_ready_signal')` is unchanged and still pumps in
  `test/widget_test.dart` / `timeline_entry_point_test.dart`.
- Both `.arb` files carry the same key set; unchanged by this phase and
  implicitly reverified by a clean `flutter build apk --debug` (generated
  `AppL10n` codegen would fail on a key-set mismatch).
- Requirement-level mobile visual audit remains deferred, to run after all
  REQ-001 stories are otherwise complete (per phase-P8-verification.md §4A).
- Mobile e2e, emulator/simulator lifecycle, signing, store upload, and
  `scripts/start-dev.sh` were not planned or run, per phase-P8-verification.md
  §3.

## Toolchain Versions Observed

- Flutter (resolved via `FLUTTER_SDK_PATH=/Users/alantravala/flutter`)
- Gradle `assembleDebug` completed in ~60.7s for the debug APK build

All 3 required gates (`flutter analyze`, `flutter test`, `flutter build apk
--debug`) PASS on this story's own surface. Next owner: Reviewer.
