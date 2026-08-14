# Fix Evidence: BUG-20260814-004 Triage-Pending — Guard-Red / Registry Mismatch / Splash Compile Error

Bug id: BUG-20260814-004_triage_pending_guard_registry_splash_family
Owner: bug-fixer (Justin-BugFixer)
Work location: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
State: changes left uncommitted in the integration worktree for Scrum Master.

## Patch Summary

| Anchor | File:line | Before | After |
| --- | --- | --- | --- |
| (a) | `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart:80` | `'Synced Alarm và Emoji Storm cần cái này. Tối đa 15 cái/ngày.'` | `'Nhắc nhở đồng bộ và Emoji Storm cần cái này. Tối đa 15 cái/ngày.'` |
| (a) | `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart:81` | `'Synced Alarm and Emoji Storm need this. Max 15 a day.'` | `'Synced Reminder and Emoji Storm need this. Max 15 a day.'` |
| (b) | — | — | No change; anchor does not reproduce (see `diagnosis.md` → `## Anchor (b) Evidence`). |
| (c) | — | — | No change; anchor does not reproduce (see `diagnosis.md` → Pre-Fix Reproduction Gate, Anchor (c)). |

Total: 1 changed file, 2 changed lines. The replacement wording is the branch's
existing canonical ADR-002 string
(`mobile/lib/features/reminders/presentation/reminder_strings.dart:19,145`
`viEn('Nhắc nhở đồng bộ', 'Synced Reminder')`), not a newly invented phrase.

## Original Failure Recheck Gate

Original anchor: `permissions_screen.dart:80-81` reported by
`mobile/test/features/reminders/reminder_copy_guard_test.dart` as
`forbidden token "synced alarm"` (test-execution failure, exit code 1).

Recheck modality: test execution.
Same modality as original: YES.

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter test test/features/reminders/reminder_copy_guard_test.dart
```

Proof path: `mobile/test/features/reminders/reminder_copy_guard_test.dart`
(the exact suite that reported the failure, run against the exact
`permissions_screen.dart:80-81` anchor lines).

Expected result: guard reports no forbidden tokens; suite green, exit 0.

Actual result:
```
00:00 +0: mobile/lib string literals never say "báo thức"/"Synced Alarm"/"Do Not Disturb" (AC2/AC3, ADR-002)
00:00 +1: pubspec.yaml declares no native-alarm/local-notification dependency (AC4)
00:00 +2: All tests passed!
RECHECK_EXIT=0
```

Result: PASS

## Build Gate

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter build apk --debug
```

Actual result:
```
Running Gradle task 'assembleDebug'...                              9.0s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
EXIT=0
```

Result: PASS

Static analysis of the changed file:
```
/Users/alantravala/flutter/bin/flutter analyze lib/features/onboarding/presentation/screens/permissions_screen.dart
-> No issues found!
```

## Runtime Startup Gate

Registry: `data/devops/system/runtime-command-registry.json`
Runtime Id: `mobile-app`
Device: `emulator-5560`

Install command:
```
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
-> Performing Streamed Install
   Success
```

Startup command:
```
adb -s emulator-5560 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
```

Ready Check (registry readiness probe — poll `dumpsys activity activities` for
the resumed activity, 30 attempts × 2s):
```
adb -s emulator-5560 shell dumpsys activity activities \
  | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity"
-> READY_OK
```

Result: PASS

Shutdown:
```
adb -s emulator-5560 shell am force-stop com.snapsofts.cupid
-> FORCE_STOP_EXIT=0
adb -s emulator-5560 shell dumpsys activity activities | grep -c "ResumedActivity.*com.snapsofts.cupid/..."
-> 0
```

Shutdown: PASS

## Regression Evidence

Scoped to the changed screen's feature area plus the suites named in the three
anchors (onboarding, navigation, reminders, splash, no-fork guard):

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter test --reporter failures-only \
  test/features/onboarding \
  test/core/navigation \
  test/features/reminders \
  test/features/auth/presentation/splash_screen_test.dart \
  test/design_system/no_fork_guard_test.dart
```

Actual result:
```
+156 ~2: 2 skipped tests.
+156 ~2: All other tests passed!
EXIT=0
```

Result: PASS — 156 passing, 0 failing, 2 pre-existing skips (unrelated to this
patch; skips were present before the change).

Risk of regression from this patch is confined to displayed copy in one
onboarding card. No widget tree, API, token, route, or behavior was touched.

## Triage Outcome

Not one root cause but three independent findings; only anchor (a) was a live
defect and it is fixed here. Anchors (b) and (c) were each verified
non-reproducing with evidence recorded in `diagnosis.md`, so there is no
residual defect to split into a follow-up bug and no `TRIAGE_SPLIT_REQUIRED`
blocker.

Two accuracy corrections to the bug report are recorded in `diagnosis.md`:
`no_fork_guard_test.dart` does not carry anchor (a) (it was RED for
`BUG-20260815-001`, now DONE), and anchor (c) names a test file
(`splash_design_fidelity_test.dart`) that does not exist on this branch plus a
parameter (`resolvePairingStatus`) that belongs to `HomeScreen`, where it is
present and green.
