# Fix Evidence: BUG-20260814-002 `waiting` Screen Used As Login-Resume Target

Bug id: BUG-20260814-002_waiting_screen_not_valid_login_resume_target
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Fixed by: Bug Fixer (Justin-BugFixer)
Work location: REQ-002 integration worktree, branch
`codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`, from HEAD `2da7d19`.
Changes left uncommitted for Scrum Master.

## Scope Correction Applied

No production routing code was changed, because the reported cause does not
exist. See `diagnosis.md`: `waiting` is structurally unreachable as a
login-resume target, a runtime probe showed the seeded boot resolves correctly
to `HomeScreen`, and the 2 RED tests trace to a pump-ordering frame lost in an
integration merge between STORY-001 and STORY-032.

## Change Set

2 files changed, 10 insertions(+), 6 deletions(-) — both test-only.

- `mobile/test/widget_test.dart`
- `mobile/test/app/feature_flags_test.dart`

Both received the same correction (indentation aside):

```dart
// Not pumpAndSettle: CupidAppBackground twinkles forever at the
// composition root, so the tree never settles. Order matters: clear the
// splash's 2s dwell (AC4) first so it calls pushReplacement, then pump
// the frame that builds the pushed route plus its 300ms transition.
await tester.pump(const Duration(seconds: 3));
await tester.pump();
await tester.pump(const Duration(seconds: 1));
```

This is the merge resolution that should have happened: it keeps STORY-001's
dwell-clearing `pump(3s)` and STORY-032's `pump()` + `pump(1s)` settle pair,
in the order each requires. `pumpAndSettle` is still not used, honouring
STORY-032's never-settling composition root.

A temporary diagnostic probe (`mobile/test/zz_bug002_probe_test.dart`) was
created during diagnosis and deleted before verification; it is not part of the
change set (`git status` shows only the 2 files above).

## Gate: Original Failure Recheck

Same modality as reported (`flutter test`, the two named files).

```
cd mobile && /Users/alantravala/flutter/bin/flutter test \
  test/widget_test.dart test/app/feature_flags_test.dart
```

PASS:

```
00:00 +1: .../test/widget_test.dart: App boots to the home screen ready signal
00:01 +2: .../test/app/feature_flags_test.dart: CupidApp resolves dark theme mode and vi locale with flags off, and the runtime readiness key still resolves
00:01 +3: .../test/app/feature_flags_test.dart: light ThemeData stays directly constructible with flags off (flags gate exposure, never existence, per OQ5)
00:01 +4: .../test/app/feature_flags_test.dart: AppL10n under Locale(en) stays directly constructible with flags off
00:01 +5: All tests passed!
```

Both originally-RED assertions on `home_screen_ready_signal` now find the
widget.

## Gate: Analyze

```
cd mobile && /Users/alantravala/flutter/bin/flutter analyze test/widget_test.dart test/app/feature_flags_test.dart
```

PASS: `No issues found! (ran in 1.7s)`

Repo-wide `flutter analyze lib test` reports `80 issues found`, all `info`
severity (`prefer_initializing_formals`, `use_null_aware_elements`, one
`deprecated_member_use`), all pre-existing in `lib/`, none in the 2 touched
files. Bare `flutter analyze` additionally reports errors under
`build/ios/SourcePackages/checkouts/flutterfire/` — a vendored third-party
checkout inside `build/`, not project source.

## Gate: Regression Evidence

FULL suite, not scoped, as required for a routing-class report:

```
cd mobile && /Users/alantravala/flutter/bin/flutter test --reporter=failures-only
```

PASS:

```
+1242 ~2: 2 skipped tests.
+1242 ~2: All other tests passed!
```

Zero failures. Baseline at HEAD `2da7d19` (recorded during BUG-20260814-003)
was `+1240 ~2 -2`. Net: the 2 pre-existing failures — the
`home_screen_ready_signal` pair, already attributed to this bug — are fixed,
and 0 new failures were introduced.

## Gate: Build

```
cd mobile && /Users/alantravala/flutter/bin/flutter build apk --debug
```

PASS: `✓ Built build/app/outputs/flutter-apk/app-debug.apk`

## Gate: Runtime Startup

Runtime id `mobile-app`, device `emulator-5560`
(`sdk_gphone64_arm64`, `sys.boot_completed=1`).

Install: `adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk` → `Success`

Launch used the resolved launcher activity, not the registry-declared one
(see `diagnosis.md` F-1):

```
adb -s emulator-5560 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
```

PASS on the registry's ResumedActivity readiness poll:

```
topResumedActivity=ActivityRecord{151358839 u0 com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity t66}
  ResumedActivity: ActivityRecord{151358839 u0 com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity t66}
```

Process alive: `pidof com.snapsofts.cupid` → `24766`.

Error-level logcat (`AndroidRuntime:E flutter:E FlutterJNI:E DartVM:E`) after
launch: empty — no crash, no Dart exception.

`am start -W` itself printed `Status: timeout / WaitTime: 21368`. That is the
never-idle composition root described in `diagnosis.md` F-2, not a startup
failure: the activity is resumed, the process is alive, and logcat is clean.

Shutdown per registry: `adb -s emulator-5560 shell am force-stop com.snapsofts.cupid`.

## Result

BUG_FIX_COMPLETE: YES
