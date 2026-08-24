# Phase P0 – Android Flavor-Driven Backend Selection

## 1. Objective

Declare `local`/`prod` Android product flavors that appear in Android Studio's
Build Variants panel, and make the selected flavor resolve the app's API base
URL through REQ-007's existing dart-define keys — with no second config system
and no regression to the unflavored local build path.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-android-flavor-backend-selection.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/android/app/build.gradle.kts`
  - `mobile/pubspec.yaml`
  - `mobile/lib/core/config/cupid_api_config.dart`
  - `mobile/test/core/config/cupid_api_config_test.dart`
  - `data/requirements/REQ-008_android_build_variants_local_prod/deployment/configuration-guide.md`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `runCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - flavor-name -> (`CUPID_ENV`, `CUPID_API_BASE_URL`) const mapping in
    `CupidApiConfig`
- Risk Surfaces:
  - Build Variants panel exposure (AC1)
  - Per-variant base URL resolution (AC2-AC4)
  - Existing local build path (AC5)
  - Google Sign-In package match
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` sections 1 and 4
  - consumer contract: REQ-007's existing `CUPID_API_BASE_URL` / `CUPID_ENV`
    dart-define keys, unchanged
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC1-AC6, Edge Cases
  - architecture: `../architecture/solution.md` sections 1 (Key Discovery), 4
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: YES
  - Sections To Update: how to select a backend target (Build Variants panel as
    the primary path, `--dart-define` as the explicit override), and the
    `default-flavor` entry's role in keeping bare `flutter run`/`flutter build`
    working.

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`

## 3. Tasks

- Add `flavorDimensions += "backend"` and product flavors `local` and `prod`
  (both `dimension = "backend"`) to `mobile/android/app/build.gradle.kts`.
  Set no `applicationIdSuffix` and no `versionNameSuffix` on either flavor.
- Add `default-flavor: local` under the existing `flutter:` key in
  `mobile/pubspec.yaml`.
- In `mobile/lib/core/config/cupid_api_config.dart`, derive const defaults from
  `appFlavor` (`package:flutter/services.dart`): keep the existing
  `String.fromEnvironment('CUPID_API_BASE_URL', ...)` and
  `String.fromEnvironment('CUPID_ENV', ...)` calls and their key names, and
  replace only each `defaultValue` with the flavor-derived const. A `prod`
  flavor defaults to `productionEnvironment` / `productionBaseUrl`; `local` and
  a null `appFlavor` both default to `localEnvironment` /
  `http://localhost:3000`.
- Extend `CupidApiConfig.validationError` to take the flavor and return an
  error when the flavor and the resolved environment contradict each other, so
  the requirements.md edge case ("prod flavor silently resolves to local")
  fails loudly at startup. Keep it a pure function.
- Extend `mobile/test/core/config/cupid_api_config_test.dart` to cover the
  flavor mapping and the mismatch error for `local`, `prod`, and null flavor.
- Update the requirement configuration guide sections named in 1B.

## 4. Acceptance Criteria

- `local` and `prod` are selectable variants for the `android/app` module after
  a Gradle sync (AC1).
- With no CLI dart-define flag, `local` resolves to `http://localhost:3000` and
  `prod` resolves to `https://api.cupidus.app` (AC2, AC3, AC4).
- `flutter build apk --debug` with no `--flavor` still produces an installable
  artifact (AC5).
- `applicationId` remains `com.snapsofts.cupid` for every variant, and the
  `google-services` plugin resolves a client for both flavored variants.
- `CUPID_API_BASE_URL` and `CUPID_ENV` remain the only base-URL config keys, and
  `https://api.cupidus.app` still appears exactly once in `lib/` (AC6).
- `CupidApiConfig.baseUrl` and `.environment` remain compile-time `const` and
  non-writable.

## 5. Planned Outputs

- Code files: the four `mobile/` paths in Write Scope.
- Requirement configuration guide updates: as named in 1B.
- Notes or evidence: `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Android host project and Flutter build-time config.
- Required levels:
  - unit: `CupidApiConfig` flavor mapping and mismatch validation for `local`,
    `prod`, and null flavor.
  - mobile build/type-check/static-analysis: registry `mobile-app.buildCommand`
    (`flutter build apk --debug`) and `flutter analyze`.
- Required checks:
  - Gradle configuration resolves and lists `localDebug` and `prodDebug`.
  - Flavored builds for both `local` and `prod` configure without a
    `google-services` "no matching client" failure.
- Minimum gates by risk surface:
  - Build Variants panel exposure: flavored assemble tasks exist for both flavors.
  - Per-variant base URL resolution: the unit tests above pass.
  - Existing local build path: unflavored `buildCommand` still produces an artifact.
  - Google Sign-In package match: both flavored variants configure cleanly.
- Required regression or contract coverage: the existing assertions that pin
  `https://api.cupidus.app` to one occurrence in
  `lib/core/config/cupid_api_config.dart` and that forbid a writable API origin
  must still pass unmodified.
- Evidence format: command plus captured pass/fail output in
  `coding-plan/test-results.md`.

## 7. Status

- Status: DONE
- Last updated: 2026-08-24
- Evidence: `coding-plan/test-results.md` (Result: PASS — analyze, 3 flavored
  unit-test runs, unflavored + flavored builds, plain-Gradle
  `assembleLocalDebug`/`assembleProdDebug`, `applicationId` check)
- Deviation logged for Tech Lead confirmation: the flavor/environment
  contradiction check is asymmetric rather than the literal "(and vice versa)"
  wording in `../architecture/solution.md` section 4, because `default-flavor:
  local` would otherwise make REQ-007's define-only production build throw at
  startup. Rationale and the replacement rule set: `coding-plan/test-results.md`
  section 8.
