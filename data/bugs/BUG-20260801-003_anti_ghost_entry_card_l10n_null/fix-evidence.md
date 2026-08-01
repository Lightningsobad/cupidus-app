# Fix Evidence: BUG-20260801-003_anti_ghost_entry_card_l10n_null

## Scope

- Branch: `codex/REQ-001_cupid_flutter_mobile_app-integration`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`
- No production code touched. `service_locator.dart` and `app_shell.dart`'s
  tab composition were not modified.

## Patch

Same remediation pattern as `BUG-20260801-001`: add the `AppL10n` import and
wire `localizationsDelegates`/`supportedLocales` into each affected test
harness's `MaterialApp`.

1. `mobile/test/features/gallery/gallery_cubit_test.dart`
   - Added `import 'package:cupid_mobile/l10n/generated/app_l10n.dart';`.
   - Added `localizationsDelegates: AppL10n.localizationsDelegates,` and
     `supportedLocales: AppL10n.supportedLocales,` to the `MaterialApp` in
     the "AppShell gallery destination" test group (the only `MaterialApp`
     in this file that mounts `AppShell()`). Other `MaterialApp` instances
     in the file (e.g. the `GalleryLockedView` test) were left untouched —
     they never reach `AppL10n.of`.

2. `mobile/test/features/pet/presentation/pet_entry_point_test.dart`
   - Added `import 'package:cupid_mobile/l10n/generated/app_l10n.dart';`.
   - Added the same two lines to the shared `_harness(Widget child)` helper
     used by every test in the file, including the readiness-gate
     regression test ("regression: home_screen_ready_signal still pumps
     after mounting PetPreviewCard").

3. `mobile/test/features/vibes/presentation/vibe_screen_test.dart`
   - Added `import 'package:cupid_mobile/l10n/generated/app_l10n.dart';`.
   - Added the same two lines to the shared `_materialHarness(Widget home)`
     helper used by every test in the file, including the previously-
     crashing "tapping the vibe entry card pushes VibeScreen" test.

## Verification

### Targeted re-run (3 target files)

```
flutter test test/features/vibes/presentation/vibe_screen_test.dart \
  test/features/gallery/gallery_cubit_test.dart \
  test/features/pet/presentation/pet_entry_point_test.dart
```

Result: `00:01 +16: All tests passed!`, exit 0. All three previously-
crashing tests now pass:
- "tapping the vibe entry card pushes VibeScreen and the ready signal
  remains present beforehand"
- "AppShell gallery destination exposes a labelled gallery destination
  reachable by tap, opening GalleryScreen"
- "regression: home_screen_ready_signal still pumps after mounting
  PetPreviewCard"

### Full-suite regression check

```
flutter test
```

Result: `877` total, `872` passed, `5` failed, exit 1 (expected — failures
below are all pre-existing/explicitly out-of-scope). Zero occurrences of
`AppL10n.of`, `Null check operator`, or `is not registered inside GetIt`
anywhere in the full-suite log (confirmed via grep on the captured log; no
regression introduced by this fix). The 5 failures exactly match the
expected out-of-scope set, with no unexpected new failures:

- `app_shell_test.dart` — "paired: Home renders with the readiness key,
  Chat is reachable, and the ghostset action opens GhostSettingsScreen from
  Chat" — `BUG-20260801-004`, not in scope.
- `app_shell_test.dart` — "unpaired: Chat is hidden, Home still renders
  with the readiness key, no pet/money/me destinations exist" —
  `BUG-20260801-004`, not in scope.
- `pair_gate_cubit_test.dart` — pre-existing constructor mismatch, not in
  scope.
- `reminder_copy_guard_test.dart` — pre-existing, not in scope.
- `reminder_entry_point_test.dart` — "home affordance navigates from
  AppShell to ReminderScheduleScreen (P4 AC)" — `BUG-20260801-005`, not in
  scope.

### Runtime Startup Gate

```
flutter test test/widget_test.dart
```

Exit 0 — "App boots to the home screen ready signal" still passes; no
regression from BUG-002's fix.

### Build Gate

```
flutter build apk --debug
```

Exit 0.

## Git state

Worktree diff limited to the 3 test files listed under Patch above. The
pre-existing untracked `data/requirements/REQ-001_cupid_flutter_mobile_app/integration-review/`
directory was left untouched. Commit made directly on
`codex/REQ-001_cupid_flutter_mobile_app-integration`.

BUG_FIX_COMPLETE: YES
