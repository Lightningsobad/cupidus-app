# Fix Evidence: BUG-20260801-004_app_shell_test_stale_inkwell_tab_count

## Scope

- Branch: `codex/REQ-001_cupid_flutter_mobile_app-integration`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`
- No production code touched. `app_shell.dart`'s tab composition and
  `service_locator.dart`/AppL10n wiring were not modified.

## Patch

`mobile/test/core/navigation/app_shell_test.dart` — updated the two stale
`InkWell`-under-`CupidTabBar` count expectations to match the current,
intended production tab composition (Home always, Chat gated by pairing,
Gallery always present per STORY-013):

- "paired: Home renders with the readiness key, Chat is reachable, and the
  ghostset action opens GhostSettingsScreen from Chat": `findsNWidgets(2)`
  -> `findsNWidgets(3)` (Home + Chat + Gallery).
- "unpaired: Chat is hidden, Home still renders with the readiness key, no
  pet/money/me destinations exist": `findsNWidgets(1)` -> `findsNWidgets(2)`
  (Home + Gallery).

## Verification

### Targeted re-run

```
flutter test test/core/navigation/app_shell_test.dart
```

Result: `00:00 +4: All tests passed!`, exit 0. All 4 tests in the file pass,
including both previously-failing "paired"/"unpaired" tests and the
STORY-005 pairing-source isolation guard tests (untouched, unaffected).

### Full-suite regression check

```
flutter test
```

Result: `879` total, `876` passed, `3` failed, exit 1 (expected — the 3
remaining failures are all pre-existing/explicitly out-of-scope, and
`app_shell_test.dart` no longer appears in the failing list):

- `pair_gate_cubit_test.dart` — pre-existing constructor mismatch, not in
  scope.
- `reminder_copy_guard_test.dart` — pre-existing, not in scope.
- `reminder_entry_point_test.dart` — "home affordance navigates from
  AppShell to ReminderScheduleScreen (P4 AC)" — `BUG-20260801-005`, not in
  scope.

No new or unexpected failures. Failure count dropped from 5 (post-BUG-003)
to 3, exactly the 2 `app_shell_test.dart` cases this bug fixed.

### Runtime Startup Gate

```
flutter test test/widget_test.dart
```

Exit 0 — "App boots to the home screen ready signal" still passes; no
regression.

### Build Gate

```
flutter build apk --debug
```

Exit 0.

## Git state

Worktree diff limited to `mobile/test/core/navigation/app_shell_test.dart`.
The pre-existing untracked
`data/requirements/REQ-001_cupid_flutter_mobile_app/integration-review/`
directory was left untouched. Commit made directly on
`codex/REQ-001_cupid_flutter_mobile_app-integration`.

BUG_FIX_COMPLETE: YES
