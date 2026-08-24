# Test Results — REQ-008 / STORY-001 / Phase P0

- Date: 2026-08-24
- Lane: Mobile
- Toolchain: Flutter 3.44.1 stable, Dart 3.12.1, Gradle 9.1.0, AGP via Flutter
- Working dir for every command: `/Users/alantravala/workspace/snapsofts/cupid-apps/mobile`
  (Gradle commands run from `mobile/android`)
- Result: PASS
- Startup Smoke: PASS — both flavors launched on Pixel 2 `HT7AH1A02116`
  (see `## Story Runtime Startup Smoke`)

## 1. Static Analysis

| # | Command | Result |
|---|---------|--------|
| 1 | `flutter analyze lib/core/config/cupid_api_config.dart test/core/config/cupid_api_config_test.dart lib/main.dart` | PASS — `No issues found! (ran in 1.0s)` |

`flutter analyze lib test` reports 80 pre-existing `info`-level lints
(`prefer_initializing_formals`, `deprecated_member_use`, …) in files this phase
does not touch. None are in the changed files; the scoped run above is clean.

A bare `flutter analyze` additionally surfaces errors from vendored third-party
sources under `mobile/build/ios/SourcePackages/checkouts/flutterfire/`. Those
are pre-existing build-directory artifacts, not repository source, and are
unrelated to this phase.

## 2. Unit Tests — `CupidApiConfig`

Run three times, once per flavor resolution, because `appFlavor` is a
compile-time const and can only be varied across processes.

| # | Command | Result |
|---|---------|--------|
| 2 | `flutter test test/core/config/cupid_api_config_test.dart` | PASS — 21/21, `All tests passed!` |
| 3 | `flutter test test/core/config/cupid_api_config_test.dart --flavor local` | PASS — 21/21, `All tests passed!` |
| 4 | `flutter test test/core/config/cupid_api_config_test.dart --flavor prod` | PASS — 21/21, `All tests passed!` |
| 5 | `flutter test test/features/gallery/gallery_repository_test.dart` | PASS — 5/5, `All tests passed!` (only other test file reading `CupidApiConfig.baseUrl`) |

Run 4 is the direct AC3 evidence. With **no** `--dart-define` flag supplied, the
assertion `expect(CupidApiConfig.environment, CupidApiConfig.productionEnvironment)`
and `expect(CupidApiConfig.baseUrl, CupidApiConfig.productionBaseUrl)` both hold
under `--flavor prod`. Runs 2 and 3 are the matching AC2 evidence for `local`.

Recorded observation from an intermediate run: before the assertions were made
flavor-aware, run 4 failed with `Expected: 'local' / Actual: 'production'`. That
failure is itself the proof that the flavor — and nothing else — moved the
resolved environment.

Regression coverage retained and passing unmodified:

- `source guards production origin appears in lib/ only as the named constant`
  — `https://api.cupidus.app` still occurs exactly once in `lib/`
  (`lib/core/config/cupid_api_config.dart`), AC6.
- `source guards no writable API origin is exposed anywhere in lib/` —
  `baseUrl`/`environment` remain compile-time `const` and non-writable.
- All seven pre-existing `CupidApiConfig.validationError` cases, unchanged: the
  new `flavor` parameter is optional and named.

## 3. Mobile Build — Flutter CLI

| # | Command | Result |
|---|---------|--------|
| 6 | `flutter build apk --debug` (registry `mobile-app.buildCommand`, no `--flavor`) | PASS — ran `assembleLocalDebug`, `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` |
| 7 | `flutter build apk --debug --flavor prod` | PASS — ran `assembleProdDebug`, `✓ Built build/app/outputs/flutter-apk/app-prod-debug.apk` |

Run 6 is the AC5 gate: the unmodified registry build command still produces an
installable artifact after flavors exist, because `default-flavor: local`
resolves the flavor Gradle now requires.

## 4. Mobile Build — Plain Gradle (Build Variants Panel Path)

This is the AC1 gate. Android Studio's Build Variants panel invokes these Gradle
tasks directly, with no Flutter CLI in the loop.

| # | Command (from `mobile/android`) | Result |
|---|---------------------------------|--------|
| 8 | `./gradlew :app:assembleProdDebug --console=plain` | PASS — `BUILD SUCCESSFUL in 20s`, 312 actionable tasks |
| 9 | `./gradlew :app:assembleLocalDebug --console=plain -q` | PASS — exit 0, warnings only |
| 12 | `./gradlew :app:tasks --group=build --console=plain` | PASS — `BUILD SUCCESSFUL in 2s`, exit 0 |
| 13 | `./gradlew :app:tasks --all --console=plain 2>&1 \| grep -E "assemble(Local\|Prod)(Debug\|Release\|Profile)"` | PASS — exit 0, 10 matching variant tasks |

Both flavored assemble tasks exist and configure, which is what makes `local`
and `prod` selectable variants for the `app` module after a Gradle sync.

Runs 12 and 13 are the direct variant-registration evidence. Run 12's grouped
listing shows the aggregate variant groups:

```text
assembleLocal - Assembles main outputs for all Local variants.
assembleProd - Assembles main outputs for all Prod variants.
bundleLocal - Assembles bundles for all Local variants.
bundleProd - Assembles bundles for all Prod variants.
compileLocalDebugSources
compileProdDebugSources
```

Run 13 enumerates the per-variant tasks the Build Variants panel maps onto,
verbatim:

```text
assembleLocalDebug - Assembles main output for variant localDebug
assembleLocalDebugAndroidTest - Assembles main output for variant localDebugAndroidTest
assembleLocalDebugUnitTest - Assembles main output for variant localDebugUnitTest
assembleLocalProfile - Assembles main output for variant localProfile
assembleLocalRelease - Assembles main output for variant localRelease
assembleProdDebug - Assembles main output for variant prodDebug
assembleProdDebugAndroidTest - Assembles main output for variant prodDebugAndroidTest
assembleProdDebugUnitTest - Assembles main output for variant prodDebugUnitTest
assembleProdProfile - Assembles main output for variant prodProfile
assembleProdRelease - Assembles main output for variant prodRelease
```

Every build type is crossed with both flavors, and no unflavored `assembleDebug`
variant task remains — which is precisely why `pubspec.yaml` needs
`default-flavor: local` for AC5.

Scope note for anyone reproducing run 13: `--all` is required. Re-measured on
2026-08-24, run 12's grouped listing emits only aggregate and compile task
names — `assemble`, `assembleAndroidTest`, `assembleDebug`, `assembleLocal`,
`assembleProd`, `assembleProfile`, `assembleRelease`, `assembleUnitTest`,
`build`, `buildDependents`, `buildKotlinToolingMetadata`, `buildNeeded`,
`bundle`, `bundleDebug`, `bundleLocal`, `bundleProd`, `bundleProfile`,
`bundleRelease`, `clean`, and the ten `compileLocal*`/`compileProd*` entries.
Per-variant `assembleLocalDebug`-style names appear only under `--all`, so
narrowing run 13 to `--group=build` would return an empty result set even
though the variants are correctly registered.

Artifacts produced by the plain-Gradle path:

```text
mobile/build/app/outputs/apk/prod/debug/app-prod-debug.apk
mobile/build/app/outputs/apk/local/debug/app-local-debug.apk
```

Neither run reported a `google-services` "No matching client found" failure, so
the plugin resolved a client for both flavored variants.

Flavor propagation on this path is not inferred: `FlutterPlugin.kt:662` sets
`val flavorValue: String = variant.flavorName`, i.e. the flavor is derived from
the Gradle variant itself, so a panel-launched build and a
`flutter build --flavor` build feed `flutter assemble` the same value.

## 5. Google Sign-In Package Match

| # | Command | Result |
|---|---------|--------|
| 10 | `aapt2 dump packagename` on `app-prod-debug.apk` | PASS — `com.snapsofts.cupid` |
| 11 | `aapt2 dump packagename` on `app-local-debug.apk` | PASS — `com.snapsofts.cupid` |

`applicationId` is byte-identical across variants. No `applicationIdSuffix` or
`versionNameSuffix` was introduced, so the BUG-20260823-001 Google Sign-In
wiring is untouched.

## 6. Acceptance Criteria Coverage

| AC | Evidence |
|----|----------|
| AC1 | Runs 12, 13 — Gradle lists `localDebug`/`prodDebug` (and every other flavor×buildType) variant task for the `app` module; runs 8, 9 — both flavored variants actually build from plain Gradle |
| AC2 | Runs 2, 3 — `local` resolves `http://localhost:3000` with no dart-define |
| AC3 | Run 4 — `prod` resolves `https://api.cupidus.app` with no dart-define |
| AC4 | Run 4 plus the `prod flavor silently resolving to local fails loudly` and `a local-declared build pointed at production fails loudly` cases |
| AC5 | Run 6 — bare `flutter build apk --debug` still produces an installable APK |
| AC6 | Run 1 source-guard tests — one `https://api.cupidus.app` literal in `lib/`, `CUPID_API_BASE_URL`/`CUPID_ENV` still the only keys, no runtime channel added |

## 7. Not Run, And Why

- Device/emulator install and launch: superseded. This was originally recorded
  as out of scope (`Startup Smoke: NOT_APPLICABLE`); Reviewer finding F-001
  rejected that call, correctly, because `assertValidConfig()` is now
  flavor-dependent at startup. Both flavors are now launched on a real device —
  see `## Story Runtime Startup Smoke`.
- Visual fidelity capture: no UI surface — `story_master.md` records
  `UX-Spec: WAIVED`.
- iOS build: explicitly out of scope.
- Full `flutter test` suite: the change is confined to `CupidApiConfig`; both
  test files that read it were run individually (runs 2-5).

## 8. Deviation From `architecture/solution.md`

`solution.md` section 4 asks for a symmetric contradiction check — reject a
`prod` flavor resolving to a non-production origin "(and vice versa)" — while
the same section also promises that REQ-007's define-only production build
"keeps its exact prior behaviour".

Those two statements cannot both hold once `default-flavor: local` exists. That
entry (required by AC5) means REQ-007's documented command —

```bash
flutter build apk --debug \
  --dart-define=CUPID_ENV=production \
  --dart-define=CUPID_API_BASE_URL=https://api.cupidus.app
```

— now silently carries `appFlavor == 'local'`. A literal symmetric
flavor-vs-environment check would build fine and then throw `StateError` on
launch, i.e. ship a production build that crashes at startup.

Implemented instead, satisfying both the requirements edge case and the
compatibility promise:

1. `prod` flavor + environment != `production` → error. (AC4; the named edge
   case "prod flavor must not silently resolve to the local base URL")
2. environment == `local` + baseUrl == `https://api.cupidus.app` → error. This
   is the "or vice versa" direction, expressed flavor-independently so it fires
   on a local-labelled build reaching production without penalising REQ-007's
   define-only production command.
3. environment == `production` + baseUrl != production origin → the pre-existing
   REQ-007 rule, unchanged.

The `local` flavor deliberately imposes no constraint, because it is also the
`default-flavor` and therefore is not a deliberate assertion of intent. Both
directions of the requirements.md edge case remain covered; the rationale is
documented in the requirement configuration guide and is flagged for Tech Lead
confirmation.

## Story Runtime Startup Smoke

Added for Reviewer finding F-001. Every gate above proves the pure config
function and the *build*; none of them launched a flavored binary.
`lib/main.dart:20` calls `CupidApiConfig.assertValidConfig()` before
`Firebase.initializeApp`, and that call is now flavor-dependent, so a bad
flavor default would throw `StateError` at startup and never show up in a build
gate. Both flavors are therefore launched on real hardware.

Device: **Pixel 2, `HT7AH1A02116`, Android 11 (API 30)**, physical device over
USB. Run order: `prod` first, then `local`.

| # | Flavor | Command (from `mobile/`) | Outcome |
|---|--------|--------------------------|---------|
| 14 | `prod` | `flutter run --flavor prod -d HT7AH1A02116` | PASS — first screen reached, no crash, no error screen |
| 15 | `local` | `flutter run --flavor local -d HT7AH1A02116` | PASS — first screen reached, no crash, no error screen |

### Run 14 — `prod`

`Running Gradle task 'assembleProdDebug'... 19.4s`, `✓ Built
build/app/outputs/flutter-apk/app-prod-debug.apk`, `Installing ... 10.7s`, then
`Syncing files to device Pixel 2... 118ms` and a live Dart VM Service. The app
rendered the login screen ("Đăng nhập lại để tiếp tục" with the email/password
form and the Google/Facebook buttons). No Dart exception appeared anywhere in
the run output, so `assertValidConfig()` did not throw on the `prod` flavor
default — the AC3 pairing (`production` + `https://api.cupidus.app`) validates
at runtime, not just in unit tests. `flutter run` exited 0.

### Run 15 — `local`

`Running Gradle task 'assembleLocalDebug'... 15.4s`, `✓ Built
build/app/outputs/flutter-apk/app-local-debug.apk`, `Installing ... 7.7s`, then
`Syncing files to device Pixel 2... 127ms` and a live Dart VM Service. The same
login screen rendered, again with no Dart exception, confirming the `local`
flavor default (`local` + `http://localhost:3000`) also passes the startup
guard.

A `Phiên đăng nhập đã hết hạn` snackbar appeared on this run. That is ordinary
auth-state behaviour for a stored expired session on this device — it is
rendered *by* the first screen, not an error screen, and is unrelated to
REQ-008. The `prod` run reached the identical screen without it.

### Incidental confirmation

The focused window was
`com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity` on both runs. This
re-confirms at runtime what runs 10-11 showed statically: neither flavor
suffixes `applicationId`, so the `google-services.json` package match survives
(BUG-20260823-001).
