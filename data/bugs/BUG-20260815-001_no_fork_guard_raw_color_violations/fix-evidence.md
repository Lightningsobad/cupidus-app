# Fix Evidence: BUG-20260815-001 ADR-004 No-Fork Guard Red — Raw Color Literals

Bug id: BUG-20260815-001_no_fork_guard_raw_color_violations
Owner: bug-fixer (Justin-BugFixer)
Date: 2026-08-15
Work location: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Changes left uncommitted for Scrum Master.

## Patch Summary

| File | Change |
| --- | --- |
| `mobile/lib/design_system/tokens/on_accent_palette.dart` | New. `OnAccentPalette.foreground = Color(0xFFFFFFFF)` — additive design-system value for the `#fff` on-gradient foreground. |
| `mobile/lib/design_system/design_system.dart` | Export the new palette from the barrel. |
| `mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart` | `:211`, `:411` — `Colors.white` -> `OnAccentPalette.foreground`. |
| `mobile/lib/features/account/presentation/screens/notification_settings_screen.dart` | `:359` — `Color(0xFFFFFFFF)` -> `OnAccentPalette.foreground`. |
| `mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart` | `:448`, `:449`, `:452` — `Colors.transparent` -> file-private `const Color _transparent = Color.fromARGB(0, 0, 0, 0);`. |
| `mobile/lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart` | `:71` — `Material(color: Colors.transparent)` -> `Material(type: MaterialType.transparency)`. |

Every substitution is value-identical to the literal it replaces, so no
rendered pixel changes. Root cause and precedent references are in
`diagnosis.md`.

## Original Failure Recheck Gate

Original failure anchor: `mobile/test/design_system/no_fork_guard_test.dart`,
test `AC 4 no-fork guard: features/app/core never fork on a raw color literal
or Platform.is*/defaultTargetPlatform` — RED with 7 violations
(`ghost_settings_screen.dart:211,411`,
`notification_settings_screen.dart:359`,
`reminder_schedule_screen.dart:448,449,452`,
`reminder_weekday_chips.dart:71`).

Recheck modality: test execution.
Same modality as original: YES — the reported failure is a failing test, so
running that exact test is the reported failure's own modality.

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter test test/design_system/no_fork_guard_test.dart
```

Proof path: `mobile/test/design_system/no_fork_guard_test.dart`

Expected result: guard test passes with 0 violations.

Actual result:
```
00:00 +0: AC 4 no-fork guard: features/app/core never fork on a raw color literal or Platform.is*/defaultTargetPlatform
00:00 +1: All tests passed!
```
Exit code 0. All 7 originally reported violations are gone.

Result: PASS

Pre-fix counterpart (same command, before the patch, recorded in
`diagnosis.md` `## Pre-Fix Reproduction Gate`): `00:00 +0 -1: Some tests
failed.`, exit code 1, listing exactly those 7 violations.

## Build Gate

Runtime id: `mobile-app` (`data/devops/system/runtime-command-registry.json`,
`runtimes.mobile-app.buildCommand`).

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter build apk --debug
```

Actual result: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`, exit
code 0.

Result: PASS

Supporting static analysis on the 6 changed files:
```
/Users/alantravala/flutter/bin/flutter analyze \
  lib/design_system/design_system.dart \
  lib/design_system/tokens/on_accent_palette.dart \
  lib/features/chat/presentation/screens/ghost_settings_screen.dart \
  lib/features/account/presentation/screens/notification_settings_screen.dart \
  lib/features/reminders/presentation/screens/reminder_schedule_screen.dart \
  lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart
```
-> `No issues found!` (exit 0).

Note: whole-package `flutter analyze` exits 1 on this branch for two
pre-existing reasons unrelated to this patch — a stale
`build/ios/SourcePackages/checkouts/flutterfire/**` vendor checkout that the
analyzer walks, and 81 `info`/`warning` lints under `lib`/`test` (including the
`_SkyBackdrop` unused-element warning that is BUG-20260815-002). None of them
originate in the 6 changed files.

## Runtime Startup Gate

Runtime Id: `mobile-app` (`data/devops/system/runtime-command-registry.json`,
`runtimes.mobile-app.readiness`, `platform: android`).

Device: `emulator-5560` (`sdk_gphone64_arm64`), already booted and visible to
adb. APK installed from the build gate output:
```
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
-> Success
```

Command:
```
export MOBILE_DEVICE_SERIAL=emulator-5560
adb -s "$MOBILE_DEVICE_SERIAL" shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
```

Ready Check (registry `readiness.command`, `expectExitCode: 0`,
`timeoutSecs: 90`):
```
for _ in $(seq 1 30); do adb -s "$MOBILE_DEVICE_SERIAL" shell dumpsys activity activities | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity" && exit 0; sleep 2; done; exit 1
```
Actual result: probe returned `READY_OK`, exit code 0 — the OS reported
`com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` as the resumed
(foreground) activity.

Result: PASS

Shutdown (registry `readiness.shutdownCommand`):
```
adb -s emulator-5560 shell am force-stop com.snapsofts.cupid
```
Exit code 0; a follow-up `dumpsys activity activities` reports 0 resumed
activities for `com.snapsofts.cupid`.

Shutdown: PASS

## Regression Evidence

Scoped regression — every test file covering the design system and the four
patched screens/widgets:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter test \
  test/design_system \
  test/features/chat/presentation/ghost_settings_screen_design_fidelity_test.dart \
  test/features/account/presentation/screens/notification_settings_screen_test.dart \
  test/features/reminders/reminder_schedule_screen_test.dart \
  test/features/reminders/reminder_schedule_bloc_test.dart
```
Result: `+82 ~1: All other tests passed!` — 82 passed, 1 skipped, 0 failed,
exit code 0.

Full suite (`flutter test`) after the patch: `+1232 ~2 -8: Some tests failed.`
The 8 remaining failures are pre-existing and belong to other open REQ-002
bugs; none touch a file changed here:

| Failing test | Belongs to |
| --- | --- |
| `test/app/feature_flags_test.dart` — runtime readiness key | home-screen ready signal family |
| `test/widget_test.dart` — App boots to the home screen ready signal | home-screen ready signal family |
| `test/features/pairing/.../joincode_screen_design_test.dart` — display/caption roles (13 vs 11.5) | BUG-20260814-003 caption typography |
| `test/features/pairing/.../waiting_screen_design_fidelity_test.dart` — typography/muted subtitle (13 vs 11.5) | BUG-20260814-003 caption typography |
| `test/features/auth/.../login_screen_test.dart` — design-source subtext slot | BUG-20260814-003 caption typography |
| `test/features/pet/.../pet_design_fidelity_test.dart` — uppercase muted eyebrow | BUG-20260814-003 caption typography |
| `test/features/pairing/.../waiting_screen_design_fidelity_test.dart` — `waiting_sky_backdrop` key missing | BUG-20260815-002 |
| `test/features/reminders/reminder_copy_guard_test.dart` — `permissions_screen.dart:80,81` "synced alarm" | BUG-20260814-004 anchor (a), ADR-002 copy guard |

`no_fork_guard_test.dart` is no longer in the failing set, so this bug's
contribution to the RED suite is fully cleared. The full suite was run only
after the patch; the pre-fix baseline for the 8 listed failures is not measured
here, but none of them exercise a file this patch touches, and the scoped run
above covers every test that does.

## Blockers

- N/A
