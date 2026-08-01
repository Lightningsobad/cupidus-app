# Fix Evidence: BUG-20260801-002_test_harness_getit_registration_gaps

See diagnosis.md for full root-cause analysis and the newly-unmasked
out-of-scope findings.

## Patch

Files changed (worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`,
branch `codex/REQ-001_cupid_flutter_mobile_app-integration`). No production
code changed — `service_locator.dart` was confirmed correct and left
untouched; every change is test-only.

Two remediation patterns were applied, chosen per how each test mounts the
widget tree:

- **Tests that mount `HomeScreen` directly** (`vibe_screen_test.dart`,
  `pet_entry_point_test.dart`): pass
  `resolvePairingStatus: () async => PairingStatus.unknown` into
  `HomeScreen`'s existing override hook, mirroring the established
  `home_screen_test.dart` / `timeline_entry_point_test.dart` precedent
  (STORY-012 P3/P7). Avoids `getIt` entirely; no GetIt registration needed.
- **Tests that mount `AppShell`** (which has no override hook for
  `HomeScreen`'s internal `CouplePairingStore` need):
  `widget_test.dart`, `feature_flags_test.dart`, `app_shell_test.dart`,
  `gallery_cubit_test.dart`, `reminder_entry_point_test.dart` — register a
  real `CouplePairingStore`/`ChatPartnerStore` instance backed by a fake,
  non-throwing `HttpClientAdapter`-based `Dio` directly into `getIt`
  (`getIt.registerSingleton<CouplePairingStore>(CouplePairingStore(api:
  CupidApi(dio: dio, interceptors: const []), backendUserIdStore:
  BackendUserIdStore()))`), scoped per-test via `setUp`/`tearDown` (adding
  `await getIt.reset();` to `tearDown` where it was missing), reusing each
  file's existing fake-adapter pattern where one already existed.

File-by-file:

- `mobile/test/widget_test.dart` — added imports
  (`couple_pairing_store.dart`, `network/cupid_api.dart`,
  `realtime/backend_user_id_store.dart`); added `CouplePairingStore`
  registration in `setUp` alongside the existing `ChatPartnerStore`
  registration, reusing the same fake `dio`.
- `mobile/test/app/feature_flags_test.dart` — identical pattern (this file
  had a duplicated `setUp` block matching `widget_test.dart`'s original).
- `mobile/test/core/navigation/app_shell_test.dart` — added imports; added
  `getIt.registerSingleton<CouplePairingStore>(...)` inside the shared
  `_harness()` function, using the per-test `dio`/`backendUserIdStore`
  already built there so it reflects the `paired` bool via the fake
  `/users/me` response; added `await getIt.reset();` to the existing
  `tearDown` (previously missing).
- `mobile/test/features/gallery/gallery_cubit_test.dart` — added imports;
  in the "AppShell gallery destination" group's `setUp`, registered
  `ChatPartnerStore` and `CouplePairingStore` via a shared fake `dio`
  alongside the group's existing Gallery-related registrations.
- `mobile/test/features/reminders/reminder_entry_point_test.dart` — added
  imports and a new private `_FakeHttpClientAdapter`
  (always returns `'{}'` 200 JSON, mirroring
  `feature_flags_test.dart`/`widget_test.dart`); updated `setUp` to
  additionally register `ChatPartnerStore` and `CouplePairingStore` via a
  shared fake `dio`.
- `mobile/test/features/vibes/presentation/vibe_screen_test.dart` — added
  `couple_pairing_store.dart` import; switched the "tapping the vibe entry
  card" test to
  `HomeScreen(resolvePairingStatus: () async => PairingStatus.unknown)`.
- `mobile/test/features/pet/presentation/pet_entry_point_test.dart` — added
  `couple_pairing_store.dart` import; switched the
  "regression: home_screen_ready_signal" test the same way.

## Verification

- `grep "is not registered inside GetIt"` over three consecutive full
  `flutter test` runs (baseline, post-fix, and a final confirmation run):
  baseline showed 8 hits across the 7 files above; both post-fix runs show
  **zero** hits anywhere in the suite.
- **Runtime Startup Gate** (per `runtime-command-registry.json`
  `runtimes.mobile-app.readiness`): `flutter test test/widget_test.dart` →
  ```
  00:00 +0: App boots to the home screen ready signal
  00:00 +1: All tests passed!
  ```
  Exit code 0. This is the highest-priority item named in the handoff and
  is fully green.
- **Build Gate**: `flutter build apk --debug` in the worktree's `mobile/`
  dir → exit code 0 (PASS).
- Full-suite `flutter test` (final confirmation run): `874 passed, 8
  failed`. All 8 remaining failures are pre-existing/newly-unmasked and
  explicitly out of this bug's scope (see diagnosis.md's "Newly-unmasked,
  out-of-scope findings" section and the Blocker note below) — none of them
  are `"is not registered inside GetIt"` errors, and none touch
  `CouplePairingStore` or `ChatPartnerStore` registration.
- `git status --porcelain` in the worktree, pre-commit, showed exactly the
  7 files listed above as modified (plus one pre-existing untracked
  directory, `data/requirements/REQ-001_cupid_flutter_mobile_app/integration-review/`,
  not created by this fix and left untouched).

## Blocker / handoff note for the remaining 8 full-suite failures

Both named GetIt errors are fully resolved for every file they affected
(verified zero remaining occurrences across three consecutive full runs),
the Runtime Startup Gate (`widget_test.dart`) passes cleanly, and the Build
Gate passes. The full suite is not 100% green, but the remaining 8
failures are not this bug's defect:

1. `pair_gate_cubit_test.dart` / `reminder_copy_guard_test.dart` — the two
   already-triaged, explicitly out-of-scope items named in bug_master.md's
   Constraints section (left untouched, as instructed).
2. `app_shell_test.dart` (both paired and unpaired) — stale `InkWell`
   tab-count assertion, unrelated to GetIt (diagnosis.md item 1).
3. `gallery_cubit_test.dart`, `vibe_screen_test.dart`,
   `pet_entry_point_test.dart` — `AppL10n.of` null-check crashes, same
   defect pattern as `BUG-20260801-003` but via additional crash sites not
   yet listed in that bug's record (diagnosis.md item 2).
4. `reminder_entry_point_test.dart` — asserts on a widget
   (`ReminderOverlayHost`) that is structurally absent from this test's
   harness regardless of GetIt state (diagnosis.md item 3) — needs a new
   bug record.

Recommend Scrum Master update `BUG-20260801-003`'s `bug_master.md` with the
two additional confirmed crash sites/files, and file one new bug record for
the `reminder_entry_point_test.dart` structural gap, before REQ-001's
Integration Build & Runtime evidence gate can go fully green. This bug
(BUG-20260801-002) is complete for its own declared scope (test-harness
GetIt registration gaps for `CouplePairingStore`/`ChatPartnerStore`).

BUG_FIX_COMPLETE: YES
