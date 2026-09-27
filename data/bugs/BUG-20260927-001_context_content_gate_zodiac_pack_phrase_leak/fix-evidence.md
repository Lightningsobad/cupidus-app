# Fix Evidence: BUG-20260927-001 `context_content_gate_test.dart` BR-16 Zodiac Pack-Phrase Leak

Bug: BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak
Diagnosis: `data/bugs/BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak/diagnosis.md`
Mode: fix-bug
Date: 2026-09-28
Branch: `main` (control checkout `/Users/alantravala/workspace/snapsofts/cupid-apps`, HEAD `908d22d8`)

BUG_FIX_COMPLETE: YES

## Fix Branch Placement

Patched on `main` in the control checkout, as the checkpoint's Fix Branch
Guidance requires. The root-cause file belongs to REQ-016/STORY-011 and is
outside REQ-017/STORY-001 Phase P1's WriteScope, so neither REQ-017 worktree was
touched. `git worktree list` confirms the two REQ-017 worktrees are untouched by
this change.

Not committed: per repository convention a specialist edits its scoped files and
leaves `git commit` to Scrum Master. The patch is present and unstaged in the
control checkout.

## Files Changed

- `mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart` — doc
  comment on `zodiacNotebookTagsIn` reworded to drop the display-form literal
  `"Cà phê sáng"` (a shipped pack seed chip) and to name the BR-16 constraint.
  Documentation-only; no executable code, no signature, no behavior change.

Total source/test files touched: 1 (budget 12).

## Regression Coverage

No new test was added, and none was needed: **BR-16 itself is the regression
test.** `mobile/test/features/context_notebook/context_content_gate_test.dart:159`
(`no pack wording is written into any Dart or l10n file (BR-16)`) fails on the
pre-fix tree and passes on the post-fix tree, which is exactly the coverage a new
test would duplicate.

Deliberately NOT done: no allowlist/exclusion entry was added to BR-16, and the
gate's scan surface was not narrowed. Weakening that gate would remove a control
owned by another story; see `diagnosis.md` → "Why the gate is correct and was not
changed".

## Pre-Fix Reproduction

Recorded in `diagnosis.md` → `## Pre-Fix Reproduction Gate`, `Result: REPRODUCED`
(same modality, exit 1, `+27 -1`, offender list naming
`zodiac_shell_resolver.dart`).

## Original Failure Recheck Gate

- Original anchor: `mobile/test/features/context_notebook/context_content_gate_test.dart:159`, BR-16 case, `Expected: empty` / `Actual: ['lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart contains "Cà phê sáng"']`
- Recheck modality: `flutter test` execution of the same suite with the same reporter as the bug report
- Same modality as original: YES
- Exact proof path:
  `cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile && PATH="$HOME/flutter/bin:$PATH" flutter test test/features/context_notebook/context_content_gate_test.dart --no-pub --reporter compact`
- Expected result: BR-16 passes, suite exits 0, offender list empty
- Actual result: `00:03 +28: All tests passed!`, `EXIT=0`. The BR-16 case is named
  in the run output as `+6: ... no pack wording is written into any Dart or l10n
  file (BR-16)`, so the previously failing case is proven to have executed and
  passed rather than being skipped.
- Result: PASS

## Targeted Verification

Adjacent-suite run covering both the reporting suite's directory and the feature
that owns the patched file:

- Command:
  `cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile && PATH="$HOME/flutter/bin:$PATH" flutter test test/features/context_notebook test/features/zodiac_shell --no-pub --reporter failures-only`
- Result: `+240 ~8: All other tests passed!` (240 passed, 8 pre-existing skips, 0 failures)

This is the suite set REQ-017/STORY-001 Phase P1 needs green, so the blocking
path named in `bug_master.md` → Second Occurrence is cleared.

### Environment preparation (not a code failure)

The first attempt at the adjacent-suite run failed to compile in the control
checkout with `Couldn't resolve the package 'flutter_local_notifications'` /
`'timezone'` / `'home_widget'` plus ~100 `AppL10n` getter errors. That was stale
dependency resolution and missing generated l10n in this checkout, not the patch:
the single-file recheck above already passed before it, and the errors name
`phase_status` and l10n files the patch never touches.

- Fix: `cd mobile && PATH="$HOME/flutter/bin:$PATH" flutter pub get` → `Got dependencies!`
- Side effects: none tracked. `git status` after it reports no change to
  `mobile/pubspec.lock` or any other tracked file; `mobile/lib/l10n/generated/`
  is gitignored.
- Scope classification: distinct family (see `diagnosis.md` → Root-Cause Family
  And Cluster Boundary).

## Build Gate

- Runtime Id: `mobile-app`
- Registry: `data/devops/system/runtime-command-registry.json` → `runtimes.mobile-app.buildCommand` = `flutter build apk --debug`
- Command:
  `cd /Users/alantravala/workspace/snapsofts/cupid-apps/mobile && PATH="$HOME/flutter/bin:$PATH" flutter build apk --debug --split-per-abi --dart-define=CUPID_API_BASE_URL=http://10.0.2.2:21020`
- Deviation from the bare registry command, and why: `--split-per-abi` because
  the all-ABI debug APK is too large to install on this emulator, and
  `--dart-define=CUPID_API_BASE_URL=http://10.0.2.2:21020` because
  `CupidApiConfig` still defaults to `http://localhost:3000`, which on an
  emulator is the emulator's own loopback. Both flags only narrow/parameterize
  the registry command; neither substitutes a different build system.
- Result: PASS — `Running Gradle task 'assembleLocalDebug'... 39.9s`, then
  `✓ Built build/app/outputs/flutter-apk/app-arm64-v8a-local-debug.apk`
  (plus `armeabi-v7a` and `x86_64`). Exit 0.
- Warnings present but non-blocking and pre-existing: Kotlin Gradle Plugin
  deprecation notice for `home_widget`, `mobile_scanner`, `sign_in_with_apple`.

## Runtime Startup Gate

- Runtime Id: `mobile-app`
- Registry: `data/devops/system/runtime-command-registry.json` → `runtimes.mobile-app.readiness`
- Device: `emulator-5554` (`sdk_gphone64_arm64`). No adb device was attached at
  the start of this run, so one was booted:
  `/Users/alantravala/Library/Android/sdk/emulator/emulator -avd Medium_Phone_API_36.0 -no-snapshot-save -no-boot-anim`,
  then polled `adb shell getprop sys.boot_completed` until `1`.
- Install: `adb -s emulator-5554 install -r build/app/outputs/flutter-apk/app-arm64-v8a-local-debug.apk` → `Success`
- Permission: `adb -s emulator-5554 shell pm grant com.snapsofts.cupid android.permission.POST_NOTIFICATIONS` (keeps the OS notification dialog from occluding the first frame)
- Command: `adb -s emulator-5554 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`
  → `Status: ok`, `Activity: com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`, `TotalTime: 2536`, `Complete`
- Ready Check (registry `readiness.command`, `expectExitCode: 0`):
  `adb -s emulator-5554 shell "dumpsys activity activities | grep -q 'ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity'"`
  → exit 0 on the first poll. Confirming dump:
  `topResumedActivity=ActivityRecord{203547491 u0 com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity t175}`
- Live process confirmed: `adb shell pidof com.snapsofts.cupid` → `26757`
- Error log check: `adb -s emulator-5554 logcat -d -s AndroidRuntime:E flutter:E FlutterError:E DartError:E` → empty (logcat was cleared with `logcat -c` immediately before launch)
- Result: PASS
- Shutdown: PASS — `adb -s emulator-5554 shell am force-stop com.snapsofts.cupid` exit 0, and `pidof com.snapsofts.cupid` afterwards exits 1 (no process).
- Port conflicts: none. A Flutter app exposes no listening socket, and no port was contended.

## Same-Family Downstream Failures

None. The BR-16 family had exactly one member at this HEAD and it is cleared. No
`BLOCKER: BUGFIX_CLUSTER_CONTINUE_REQUIRED` is needed.

## Working Tree State At Handoff

`git status --porcelain` in the control checkout:

```
 M data/bugs/BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak/bug_master.md
 M data/bugs/master_bugs_list.md
 M mobile/lib/features/zodiac_shell/domain/zodiac_shell_resolver.dart
?? data/bugs/BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak/diagnosis.md
?? data/bugs/BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak/scrum-master-checkpoint.md
```

Exactly one source file changed. The two `data/bugs/` modifications and the
checkpoint are Scrum Master's pre-existing dispatch edits, not this run's. No
visual-fidelity PNG or other story's artifact was dirtied by the test runs.

## Remaining Risks And Unrelated Failures

- `mobile/test/design_system/` is red at this baseline for reasons unrelated to
  this bug and was deliberately not run; it is outside the BR-16 family and
  outside the blocking P1 regression scope.
- BR-16 remains recurrence-prone by construction: a future pack chip can collide
  with an existing source literal. Not in scope for this narrow bugfix; raised in
  `diagnosis.md` → Risk Notes for Scrum Master's judgement.
- The emulator `emulator-5554` was left booted. It is a shared device on this
  machine and another mobile lane may want it; the app itself is force-stopped.

## Reviewer Handoff Recommendation

Ready for bugfix review. Recommended review depth: minimal — a single
documentation-only line range plus four passing gates.

Review report path:
`data/bugs/BUG-20260927-001_context_content_gate_zodiac_pack_phrase_leak/review/review-report.md`

Suggested reviewer focus:
1. Confirm the doc comment still describes `zodiacNotebookTagsIn` accurately.
2. Confirm BR-16 was not weakened — the gate test file is unmodified.
3. Confirm the patch landed on `main`, not on a REQ-017 branch.
