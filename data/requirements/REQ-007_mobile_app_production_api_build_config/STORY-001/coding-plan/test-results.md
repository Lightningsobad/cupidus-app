# STORY-001 Phase P1 — Test Results

Result: PASS

- Phase: P1 (`phase-P1-production-api-build-config.md`)
- Lane: Mobile
- Date: 2026-08-22
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-007_mobile_app_production_api_build_config-STORY-001`
- Branch: `codex/REQ-007_mobile_app_production_api_build_config-STORY-001`
- BaseHead: `9ca07e436f0ae15ff103c39b84cede3f6e7612ec`
- Toolchain: Flutter 3.44.1 stable / Dart 3.12.1, resolved from
  `$HOME/flutter/bin` per the runtime registry `mobile-app.sdk.resolutionOrder`
  (`onPathOnThisMachine: false` — `flutter` is not on the shell PATH here).
- Runtime registry id: `mobile-app`; `buildCommand: flutter build apk --debug`.
- Startup smoke: NOT_APPLICABLE for this phase.

All commands were run from the story worktree's `mobile/` directory.

## 1. Unit Tests

Command:

```bash
flutter test test/core/config/cupid_api_config_test.dart
```

Exit status: `0`

Assertion output:

```
00:00 +0: CupidApiConfig constants production origin is the live TLS origin
00:00 +1: CupidApiConfig constants local-dev defaults are unchanged (AC2)
00:00 +2: CupidApiConfig constants assertValidConfig is a no-op on the default local build
00:00 +3: CupidApiConfig.validationError accepts the default local pair
00:00 +4: CupidApiConfig.validationError accepts the production pair
00:00 +5: CupidApiConfig.validationError rejects an unknown environment value
00:00 +6: CupidApiConfig.validationError rejects production paired with the local-dev origin
00:00 +7: CupidApiConfig.validationError rejects a cleartext production origin
00:00 +8: CupidApiConfig.validationError rejects a wrong production host
00:00 +9: CupidApiConfig.validationError rejects production with an empty origin
00:00 +10: source guards production origin appears in lib/ only as the named constant
00:00 +11: source guards no writable API origin is exposed anywhere in lib/ (AC5)
00:00 +12: source guards AppConfig stays unreferenced scaffolding
00:00 +13: All tests passed!
```

Required-level coverage map:

| Required case | Test |
|---------------|------|
| valid local default pair | `accepts the default local pair` |
| valid production pair | `accepts the production pair` |
| unknown environment value | `rejects an unknown environment value` |
| production + local-dev origin (silent-fallback case) | `rejects production paired with the local-dev origin` |
| production + cleartext origin | `rejects a cleartext production origin` |
| production + wrong host | `rejects a wrong production host` |

## 2. Static Analysis

Command:

```bash
flutter analyze lib test
```

Exit status: `1` — **pre-existing, unchanged by this phase.** `flutter analyze`
exits non-zero when any issue exists, including `info`-level lints. The run
reports `80 issues found`: `0 error`, `0 warning`, `80 info`
(`prefer_initializing_formals` and similar, none in files touched by this phase).

Baseline proof: the same command was run at BaseHead (this phase's three files
stashed with `git stash push -u`, then restored with `git stash pop`) and the
output is byte-identical to the post-change run apart from the trailing timing
value:

```
$ diff analyze-libtest-before.txt analyze-libtest-final.txt
130c130
< 80 issues found. (ran in 2.3s)
---
> 80 issues found. (ran in 2.1s)
```

Zero analyzer issues reference `cupid_api_config.dart`, `lib/main.dart`, or the
new test file.

Scope note: the bare project-wide `flutter analyze` (no path argument) reports
`11030 issues found` because it also walks `build/ios/SourcePackages/checkouts/`
— vendored FlutterFire example/dartpad sources pulled in by a previous iOS
build. That directory is generated build output, is present at BaseHead, and is
unrelated to this phase, so analysis was scoped to the real source roots
`lib test`.

## 3. Build Type-Check — No Defines (Local-Dev Path, AC2)

Command:

```bash
flutter build apk --debug
```

Exit status: `0`

Assertion output:

```
Running Gradle task 'assembleDebug'...                             54.6s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

## 4. Build Type-Check — Production Defines (AC1)

Command:

```bash
flutter build apk --debug \
  --dart-define=CUPID_ENV=production \
  --dart-define=CUPID_API_BASE_URL=https://api.cupidus.app
```

Exit status: `0`

Assertion output:

```
Running Gradle task 'assembleDebug'...                             13.5s
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

## 5. Source Check — Production Origin Appears Once In `lib/`

The platform `Grep` tool is unavailable in this session and the repository's
query-first Bash guard blocks shell `grep`/`git grep` over source paths, so this
required check is implemented as an executable source-guard test inside the
in-scope test file rather than as a one-shot manual grep. It scans every
`lib/**/*.dart` file and asserts an exact map of hits:

Test: `source guards production origin appears in lib/ only as the named constant`

```dart
expect(hits, <String, int>{'lib/core/config/cupid_api_config.dart': 1});
```

Exit status: `0` (passes as case `+10` in section 1).

Companion check `source guards no writable API origin is exposed anywhere in
lib/ (AC5)` asserts no `set baseUrl` / `set apiBaseUrl` / `set environment`
accessor and no `CupidApiConfig.baseUrl =` or `CupidApiConfig.environment =`
assignment exists anywhere in `lib/` — the origin is representable only as a
compile-time `static const`, so no runtime toggle exists. Passes as case `+11`.

## 6. Source Check — `AppConfig` Unreferenced And `app_config.dart` Unmodified

Unreferenced: test `source guards AppConfig stays unreferenced scaffolding`
scans every `lib/**/*.dart` except `lib/core/config/app_config.dart` and asserts
no file mentions `AppConfig`. Exit status `0` (case `+12` in section 1).

Unmodified, verified against BaseHead:

```bash
git diff 9ca07e436f0ae15ff103c39b84cede3f6e7612ec -- mobile/lib/core/config/app_config.dart
```

Exit status: `0`, empty diff — the decoy config file is byte-identical to
BaseHead.

Whole-phase diff scope, same baseline:

```
$ git diff 9ca07e43 --stat -- mobile/lib mobile/test
 mobile/lib/core/config/cupid_api_config.dart | 37 ++++++++++++++++++++++++++++
 mobile/lib/main.dart                         |  4 +++
 2 files changed, 41 insertions(+)
```

(`mobile/test/core/config/cupid_api_config_test.dart` is new and therefore
untracked at the time of the diff.)

## 7. Regression — Existing Mobile Suites

Command:

```bash
flutter test --reporter compact
```

Exit status: `0`

Assertion output:

```
00:28 +1348 ~2: All other tests passed!
```

1348 passed, 2 skipped, 0 failed. Suites that construct clients against
`CupidApiConfig.baseUrl` (including `test/openapi/cupid_api_smoke_test.dart` and
`test/core/realtime/socket_transport_test.dart`) pass unchanged.

## 8. Not Run In This Phase

- Emulator/simulator install-and-observe verification of AC3 and AC4 belongs to
  the requirement-level mobile runtime/visual audit gate, per the phase file's
  `Requirement mobile visual audit` entry. It is out of this phase's scope, not
  a skipped gate.
- Amended in patch cycle 1: the *startup* half of that work is no longer
  deferred. Review finding B1 required a story-level runtime startup smoke
  because `assertValidConfig()` now runs on every launch; it is recorded in
  section 9 below. What remains deferred to the requirement-level gate is
  finding D1 only — observing actual REST/socket traffic destinations.

## Summary

| Test Scope item | Command | Exit | Outcome |
|-----------------|---------|------|---------|
| Unit tests | `flutter test test/core/config/cupid_api_config_test.dart` | 0 | 13/13 pass |
| Static analysis | `flutter analyze lib test` | 1 (pre-existing, byte-identical to BaseHead) | 0 errors, 0 warnings, 80 pre-existing infos |
| Build, no defines | `flutter build apk --debug` | 0 | APK built |
| Build, production defines | `flutter build apk --debug --dart-define=CUPID_ENV=production --dart-define=CUPID_API_BASE_URL=https://api.cupidus.app` | 0 | APK built |
| Grep: production origin once in `lib/` | source-guard test case `+10` | 0 | exactly one occurrence, in `CupidApiConfig` |
| Grep: `AppConfig` unreferenced + file unchanged | source-guard test case `+12` and `git diff <BaseHead> -- mobile/lib/core/config/app_config.dart` | 0 | unreferenced, empty diff |
| Regression | `flutter test` | 0 | 1348 pass, 2 skip, 0 fail |

Result: PASS

## Story Runtime Startup Smoke

Added in patch cycle 1 for review finding B1. Sections 1-7 are unchanged.

- Runtime id: `mobile-app` (`data/devops/system/runtime-command-registry.json`)
- Build command source: registry `buildCommand` = `flutter build apk --debug`
- Launch/readiness source: registry `mobile-app.readiness` — `platform: android`,
  `applicationId: com.snapsofts.cupid`,
  `launcherActivity: com.snapsofts.cupid_mobile.MainActivity`, `expectExitCode: 0`,
  `timeoutSecs: 90`, plus its `shutdownCommand`.
- Device: `emulator-5560`, Android 16, already booted and visible to adb
  (`sys.boot_completed=1`), so `scripts/run-mobile.sh android` had no emulator to
  boot. The registry marks that script `interactive: true` / `ciSafe: false`
  because it hands off to a foreground `flutter run`; the registry's own
  `readiness` block is the non-interactive probe and is what was executed here.
- Install per the registry `readiness.preconditions`: package uninstalled, then
  the freshly built debug APK installed with `adb install -r`, so each launch is
  provably the flavor just built.
- Worktree HEAD at smoke time: `b7f93da37cc70acb08434aed30634bd7a1d0236d`

Readiness probe executed verbatim from the registry, with
`MOBILE_DEVICE_SERIAL=emulator-5560`:

```bash
adb -s "$MOBILE_DEVICE_SERIAL" shell am start -W -n com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity >/dev/null \
  && for _ in $(seq 1 30); do
       adb -s "$MOBILE_DEVICE_SERIAL" shell dumpsys activity activities \
         | grep -q "ResumedActivity.*com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity" && exit 0
       sleep 2
     done; exit 1
adb -s "$MOBILE_DEVICE_SERIAL" shell am force-stop com.snapsofts.cupid   # shutdownCommand
```

### A. Local-Dev Build (No Defines)

```bash
flutter build apk --debug
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
# registry readiness probe above
```

| Step | Exit |
|------|------|
| build | 0 |
| install | 0 (`Success`) |
| readiness probe | 0 |
| shutdown | 0 |

`am start -W` output:

```
Starting: Intent { cmp=com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity }
Status: ok
LaunchState: COLD
Activity: com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
TotalTime: 11147
WaitTime: 11176
Complete
```

Observed first screen: the Welcome screen renders fully — "Cupid", tagline
"Yêu nghiêm túc. / Chia tay đàng hoàng.", body "App cho hai người. Không có
newsfeed, không có người thứ ba.", and both auth actions ("Tiếp tục với Google",
"Dùng email") with the debug banner. No crash, no red error screen, no
grey/blank screen.

Crash check on the launch's logcat (buffer cleared immediately before launch):
`FATAL EXCEPTION`, `StateError`, and `E/flutter` all matched **0** lines.

### B. Production Build (Both Defines)

```bash
flutter build apk --debug \
  --dart-define=CUPID_ENV=production \
  --dart-define=CUPID_API_BASE_URL=https://api.cupidus.app
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
# registry readiness probe above
```

| Step | Exit |
|------|------|
| build | 0 |
| install | 0 (`Success`) |
| readiness probe | 0 |
| shutdown | 0 |

`am start -W` output:

```
Starting: Intent { cmp=com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity }
Status: ok
LaunchState: COLD
Activity: com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity
TotalTime: 8675
WaitTime: 9093
Complete
```

Observed first screen: identical Welcome screen, fully rendered. No crash, no
red error screen. Crash check on the launch's logcat: `FATAL EXCEPTION`,
`StateError`, `E/flutter` all matched **0** lines.

### C. Negative Control — Production Declared, URL Define Missing

The two smokes above render identically, so on their own they cannot distinguish
"the production define was applied and the guard passed" from "the define never
reached the binary and the local defaults passed". This third launch removes that
ambiguity, and is the runtime counterpart of the unit case for the silent
local-dev fallback:

```bash
flutter build apk --debug --dart-define=CUPID_ENV=production   # URL define deliberately omitted
adb -s emulator-5560 install -r build/app/outputs/flutter-apk/app-debug.apk
# same registry readiness probe
```

Build exit `0`, install exit `0`. The app never reaches the first screen: it
stalls on the Flutter splash and logcat carries the guard's own message:

```
E flutter : [ERROR:flutter/runtime/dart_vm_initializer.cc(40)] Unhandled Exception:
Bad state: CUPID_ENV=production requires CUPID_API_BASE_URL=https://api.cupidus.app,
but this build resolves to "http://localhost:3000".
Rebuild with --dart-define=CUPID_API_BASE_URL=https://api.cupidus.app.
```

This proves three things at runtime, not just in unit tests:

1. `--dart-define=CUPID_ENV` genuinely reaches the compiled binary — the guard
   could not have fired otherwise.
2. `assertValidConfig()` really executes on every launch, before any transport
   exists, and fails loudly on the silent-fallback case.
3. Therefore smoke B's clean launch is itself runtime evidence that
   `CupidApiConfig.baseUrl` resolved to `https://api.cupidus.app` in the
   production build: the guard compares the two resolved consts and would have
   thrown for any other origin.

### D. Honest Limitation Of The Registry Readiness Probe

In the negative control the registry probe still exited `0`: the Android activity
is `ResumedActivity` even though the Dart entrypoint threw and no app UI ever
rendered. The `ResumedActivity` check alone therefore cannot prove "first screen
reached" for a Flutter app whose failure mode is an unhandled Dart exception.
The pass/fail judgement for A and B above rests on the screenshot plus the
cleared-buffer logcat crash check, with the probe as a supporting signal. Worth
noting for whoever owns the registry, since the probe is documented as the
readiness contract for `mobile-app`.

### E. Deferred Finding D1 — Not Closed Here

While the emulator was up, no REST/socket destination could be observed: both
builds sit on the pre-auth Welcome screen, which issues no API call, and the
app's Dio/socket stack does not log request URLs. `api.cupidus.app`,
`localhost:3000`, and `10.0.2.2` each matched 0 logcat lines in both runs —
absence of traffic, not evidence of correct traffic. D1 therefore remains owed at
the requirement-level mobile visual/runtime audit gate, where an authenticated
session actually exercises the transports. No extra emulator cycles were spent
chasing it, per the patch instruction.

### Emulator State Left Behind

The knowingly broken negative-control APK was uninstalled and the production
build (both defines) was rebuilt and reinstalled on `emulator-5560`, so no
deliberately misconfigured artifact is left on the device.

Result: PASS
