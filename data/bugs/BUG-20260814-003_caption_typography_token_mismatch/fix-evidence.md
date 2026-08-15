# Fix Evidence: BUG-20260814-003 Caption Typography Token Mismatch

Bug id: BUG-20260814-003_caption_typography_token_mismatch
Worktree: `.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Runtime registry: `data/devops/system/runtime-command-registry.json` (`mobile-app`)

## Patch Summary

5 files, `+57 -3`.

```
 mobile/lib/design_system/tokens/cupid_typography_tokens.dart           |  9 ++++++++-
 mobile/lib/features/account/.../profile_edit_screen.dart               | 10 +++++++++-
 mobile/lib/features/onboarding/.../onboarding_profile_setup_screen.dart| 10 +++++++++-
 mobile/test/design_system/theme_matrix_test.dart                       | 17 +++++++++++++++++
 mobile/test/features/onboarding/.../onboarding_profile_setup_screen_test.dart | 14 ++++++++++++++
```

Core change — `cupid_typography_tokens.dart`:

```dart
caption: TextStyle(
  fontFamily: uiFontFamily,
  fontWeight: FontWeight.w400,
  fontSize: 13,
),
```

The 11.5px inline-helper role that STORY-033 AC3 depended on now states its own
size at both consumers instead of borrowing the shared token.

## Original Failure Recheck Gate — PASS

Same modality as reported (design-fidelity widget assertions), all four
originally-RED assertions in one run:

```
flutter test test/features/auth/presentation/screens/login_screen_test.dart \
             test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart \
             test/features/pairing/presentation/screens/joincode_screen_design_test.dart \
             test/features/pet/presentation/pet_design_fidelity_test.dart \
  --reporter failures-only
```

`+36: All tests passed!` (exit 0).

| Anchor | Before | After |
|---|---|---|
| `login_screen_test.dart:91` | `Expected <13> Actual <11.5>` | PASS |
| `waiting_screen_design_fidelity_test.dart:188` | `Expected <13> Actual <11.5>` | PASS |
| `joincode_screen_design_test.dart:107` | `Expected <13> Actual <11.5>` | PASS |
| `pet_design_fidelity_test.dart:150` | `Expected ~<0.65> Actual <0.575…>` | PASS |

## Static Analysis Gate — PASS

```
flutter analyze lib/design_system/tokens/cupid_typography_tokens.dart \
  lib/features/onboarding/presentation/screens/onboarding_profile_setup_screen.dart \
  lib/features/account/presentation/screens/profile_edit_screen.dart \
  test/design_system/theme_matrix_test.dart \
  test/features/onboarding/presentation/screens/onboarding_profile_setup_screen_test.dart
```

`Analyzing 5 items... No issues found! (ran in 1.5s)` (exit 0).

## Build Gate — PASS

```
cd mobile && flutter build apk --debug
```

`✓ Built build/app/outputs/flutter-apk/app-debug.apk` (exit 0).

## Runtime Startup Gate — PASS

Device `emulator-5560`.

| Step | Command | Result |
|---|---|---|
| Install | `adb -s emulator-5560 install -r mobile/build/app/outputs/flutter-apk/app-debug.apk` | `Success` |
| Start | `adb -s emulator-5560 shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` | `Status: ok`, `LaunchState: COLD`, `TotalTime: 6515` |
| Readiness | `dumpsys activity activities` → `ResumedActivity` poll | `READY_OK` on attempt 1 |
| Error scan | `adb logcat -d -t 400`, count of `FATAL EXCEPTION|E/flutter` | `0` |
| Shutdown | `adb -s emulator-5560 shell am force-stop com.snapsofts.cupid` | exit 0; `topResumedActivity` returns to `NexusLauncherActivity` |

Registry correction: the registry's start command targets
`com.snapsofts.cupid/.MainActivity`, which fails with
`Error type 3 … Activity class {com.snapsofts.cupid/com.snapsofts.cupid.MainActivity} does not exist.`
The real launcher, from
`adb shell cmd package resolve-activity --brief com.snapsofts.cupid`, is
`com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`. Flagged for
DevOps; not changed here (registry is outside this bug's write scope).

Rendered visual recheck: screenshot captured while resumed
(`adb exec-out screencap -p`). The pair-gate screen renders the STORY-032 sky
wash and twinkle stars, the gradient CTA and the pink text link, with no
overflow stripes and no red error box — the token change causes no layout
breakage at runtime.

## Regression Evidence — PASS

Scope: the **entire** mobile suite, not a subset. The caption token has 179 call
sites across 60 files under `mobile/lib`, so a scoped run could not have proven
absence of fallout.

```
cd mobile && flutter test --reporter failures-only
```

`+1240 ~2 -2: Some tests failed.` — 1240 passed, 2 skipped, 2 failed of 1242.

Both remaining failures are pre-existing and owned elsewhere:

| Failing test | Owner | Attribution |
|---|---|---|
| `widget_test.dart` — `App boots to the home screen ready signal` | BUG-20260814-002 | Named in that bug's report; present in BUG-20260815-001's pre-patch full-suite baseline and in BUG-20260815-002's post-fix run |
| `feature_flags_test.dart` — `CupidApp resolves dark theme mode and vi locale with flags off, and the runtime readiness key still resolves` | BUG-20260814-002 | Same; both assert `home_screen_ready_signal`, unrelated to typography |

Net effect on the branch: **4 failures fixed, 0 introduced.** BUG-20260815-002's
post-fix run recorded 4 failures (2 caption + 2 `home_screen_ready_signal`);
this run records 2, and the 2 that remain are the same two. No test anywhere in
the suite regressed on the token change.

## Residual Risk

Three design-source deltas found during diagnosis are deliberately **not** fixed
here (`diagnosis.md` § Not In Scope): the Love Pet eyebrow and its three sibling
eyebrows are 12px in the canvas (F-1), uppercase field labels are 11px (F-2),
and the avatar crop hint is 12.5px (F-3). All three inherit `caption` and are
now 13px. None is asserted RED and none is named by this bug; they are the
role-split follow-up STORY-033 explicitly deferred. Recommend a single new bug
covering the small-text scale rather than widening this fix.
