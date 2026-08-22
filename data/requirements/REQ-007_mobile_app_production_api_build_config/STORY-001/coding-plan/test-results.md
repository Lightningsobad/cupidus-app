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
