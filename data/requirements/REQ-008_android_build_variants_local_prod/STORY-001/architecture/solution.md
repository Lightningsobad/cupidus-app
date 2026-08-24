# 001_android-build-variants-local-prod-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-24

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC1 (native Gradle flavors visible in Android Studio's
  Build Variants panel), AC2-AC4 (flavor alone resolves the backend base URL
  with no CLI flag), AC5 (no regression to the existing local build path),
  AC6 (no second base-URL config system alongside REQ-007's dart-defines).
- Architectural invariants / non-goals:
  - `CUPID_API_BASE_URL` and `CUPID_ENV` stay the only base-URL config keys, and
    `https://api.cupidus.app` / `http://localhost:3000` stay the only values.
  - `CupidApiConfig.baseUrl` / `.environment` stay compile-time `const`; no
    runtime/native channel lookup is introduced.
  - `applicationId` stays `com.snapsofts.cupid` for every flavor.
  - No iOS, CI/CD, domain, or signing change.
- Proposed technical direction: declare `local`/`prod` product flavors on one
  `backend` dimension and let Flutter's **already-existing** flavor propagation
  carry the selection into Dart. The Gradle plugin reads `variant.flavorName`,
  passes `-dFlavor=<name>` to `flutter assemble`, and the KernelSnapshot target
  injects `FLUTTER_APP_FLAVOR=<name>` as a dart-define that the framework
  exposes as the `const String? appFlavor`. `CupidApiConfig` then uses
  `appFlavor` as the **const default** for its two existing keys.
- Why this fits the current system: the bridge is zero custom glue — it reuses
  the same `String.fromEnvironment` dart-define channel REQ-007 established, so
  the flavor drives REQ-007's mechanism instead of competing with it (AC6).

### Key Discovery

The intuitive bridge — mutating the `dart-defines` Gradle property from
`build.gradle.kts` — **cannot** satisfy AC2/AC3. `FlutterPlugin.kt:608` reads it
with `project.findProperty("dart-defines")`: one project-scoped, base64-encoded
value resolved identically for every variant, so it cannot differ between
`localDebug` and `prodDebug`. Deriving the flavor from
`gradle.startParameter.taskNames` would be the only way to fake per-variant
behaviour. None of that is needed: `FlutterPlugin.kt:662` already sets
`flavorValue = variant.flavorName` per variant, and that path is live for a
plain Gradle `:app:assembleProdDebug` invoked from the Build Variants panel with
no Flutter CLI involved. That is exactly AC2/AC3's "no CLI dart-define flag
supplied" case.

Second discovery, load-bearing for AC5: `gradle.dart:111,143` compute the
expected artifact as `app-$flavor-$buildType.apk` with `flavor ?? ''`. Once
flavors exist, a `flutter run` that resolves **no** flavor still looks for
`app-debug.apk`, which flavored Gradle no longer produces. So AC5 is not
automatic — it requires `flutter: default-flavor: local` in
`mobile/pubspec.yaml` (`flutter_manifest.dart:439`,
`flutter_command.dart:1481-1483`: `flavor = cliFlavor ?? defaultFlavor`).

## 3. Scope And Assumptions

- In Scope: `mobile/android/app/build.gradle.kts` flavor block,
  `mobile/pubspec.yaml` `default-flavor`, `mobile/lib/core/config/cupid_api_config.dart`
  default resolution + mismatch validation, and its unit test.
- Out Of Scope: iOS/Xcode schemes, `google-services.json`, CI/CD, domain,
  signing, and the REQ-007 key/value contract itself.
- Assumptions affecting design:
  - Flavor names are literally `local` and `prod` (AC1); `appFlavor` returns
    them verbatim, so the Dart mapping keys off those two strings.
  - Local Flutter SDK supports `default-flavor` (verified present) and
    `appFlavor` (`packages/flutter/lib/src/services/flavor.dart`).
  - A build with no flavor at all (`appFlavor == null`) keeps resolving to
    local — REQ-007's frozen localhost default is preserved, not removed.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/` (Android host project + `lib/core/config`).
- New boundary: the Android build variant becomes the **default** supplier of
  the two REQ-007 define values. Explicit `--dart-define` still overrides, and
  a flavor/define contradiction is a hard startup error rather than a silent win.
- Shared patterns reused: `String.fromEnvironment` const config; Flutter's
  built-in `--flavor` → `FLUTTER_APP_FLAVOR` → `appFlavor` propagation.

### Affected Modules

- Mobile: `android/app` Gradle config, `pubspec.yaml`, `lib/core/config`.

### Contracts And Integrations

- Precedence contract: explicit `--dart-define` > flavor-derived default >
  no-flavor local default. `CupidApiConfig.validationError` is extended to take
  the flavor and reject a `prod` flavor resolving to a non-production origin
  (and vice versa), so the requirements.md edge case "prod flavor silently
  resolves to local" fails loudly at startup instead of shipping.
- Compatibility posture: additive. Every pre-existing invocation — bare
  `flutter run`, and REQ-007's documented
  `--dart-define=CUPID_API_BASE_URL=... --dart-define=CUPID_ENV=production`
  build — keeps its exact prior behaviour.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Build Variants panel exposure (AC1) | `mobile/android/app/build.gradle.kts` | One `backend` dimension, flavors named exactly `local`/`prod` | Gradle sync succeeds and `localDebug`/`prodDebug` are listed as variants | Android Studio/Gradle sync unavailable |
| Per-variant base URL resolution (AC2-AC4) | `mobile/lib/core/config/cupid_api_config.dart` | `appFlavor`-derived const defaults for the two REQ-007 keys | Unit test asserts the flavor→(env, baseUrl) mapping and the mismatch error, for `local`, `prod`, and `null` | — |
| Existing local build path (AC5) | `mobile/pubspec.yaml` | `flutter: default-flavor: local` | Bare `flutter build apk --debug` still produces an installable artifact | Android SDK/emulator unavailable |
| Google Sign-In package match | `mobile/android/app/google-services.json` | No `applicationIdSuffix`; both flavors keep `com.snapsofts.cupid` | `google-services` plugin resolves a client for both flavored variants at build time | — |

### Lane Handoff

#### Mobile Lane

- Responsibilities: Gradle flavor block, `default-flavor`, `CupidApiConfig`
  default + validation change, unit-test update, and the developer-facing
  build/run documentation for switching variants.
- Authoritative inputs: this section 4, `requirements/requirements.md` AC1-AC6.
- Guardrails:
  - Do NOT add `applicationIdSuffix` or `versionNameSuffix` to either flavor —
    `google-services.json` registers only `com.snapsofts.cupid`, and suffixing
    breaks the Google Sign-In wiring fixed in BUG-20260823-001.
  - Do NOT read, write, or decode the `dart-defines` Gradle property, and do
    NOT branch on `gradle.startParameter.taskNames`.
  - Do NOT pass `FLUTTER_APP_FLAVOR` as a `--dart-define`; flutter_tools
    rejects it as framework-reserved (`flutter_command.dart:1488`).
  - Do NOT add a second literal of `https://api.cupidus.app` in `lib/` — an
    existing test pins it to exactly one occurrence in `cupid_api_config.dart`.
  - Do NOT make `baseUrl` / `environment` non-const or writable.

## 5. Non-Functional Impact

- Accepted limitation: without `applicationIdSuffix`, `local` and `prod` cannot
  be installed side by side on one device; switching variants reinstalls over
  the other. Accepted deliberately to protect the Firebase/Google Sign-In
  package registration.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Gradle flavors + built-in `appFlavor` propagation + flavor-derived const defaults on REQ-007's keys | Only option that is per-variant, needs no custom glue, and reuses REQ-007's exact keys/values | ACCEPTED | Resolves req_master.md inline OQ: dimension `backend`, flavors `local`/`prod`, no id/version suffix |
| `buildConfigField` / `manifestPlaceholders` read over a MethodChannel | Obvious native-Gradle way to hand a value to the app | REJECTED | Runtime-only, so it cannot feed a `const` config; would be a genuine second config system (AC6) |
