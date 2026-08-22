# Phase P1 – Production API Build Configuration

## 1. Objective

Add a build-time "production" configuration that points the Flutter app at
`https://api.cupidus.app`, make a misconfigured production build fail at startup
instead of silently falling back to local dev, and leave the local-dev build path
byte-for-byte unchanged.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-production-api-build-config.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/config/cupid_api_config.dart`
  - `mobile/lib/main.dart`
  - `mobile/test/core/config/cupid_api_config_test.dart`
  - `data/requirements/REQ-007_mobile_app_production_api_build_config/deployment/configuration-guide.md`
- Impacted Runtime Service/App:
  - Name: `mobile` (Cupid Flutter app)
  - Runtime Registry Id: UNRESOLVED — resolve the `mobile` app entry id from the
    registry at execution time. Tech Lead planning was instructed not to read the
    registry, so this is deliberately unresolved rather than guessed.
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `CupidApiConfig.environment` and `CupidApiConfig.validationError(environment, baseUrl)`
- Shared Interfaces Consumed:
  - existing `CupidApiConfig.baseUrl`
- Risk Surfaces:
  - Production origin resolution
  - Silent local-dev fallback
  - Local-dev build regression
  - Dual-transport origin leak
  - Build-time-only selection (AC5)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` section 4
  - consumer contract: `mobile/lib/core/network/cupid_api_client.dart` and
    `mobile/lib/core/di/service_locator.dart` both read `CupidApiConfig.baseUrl`
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC1–AC5, `Business Rules`, `Edge Cases`
  - architecture: `../architecture/solution.md` sections 1 and 4
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: YES
  - Sections To Update: build-time values (`CUPID_API_BASE_URL`, `CUPID_ENV`),
    the exact local-dev and production build/run invocations, and the meaning of
    the startup guard failure.
- Phase Sizing:
  - Behavior Slice: one build-time origin switch plus its guard, tests, and docs
  - Source/Test File Count: 4
  - Split Required: NO
  - Split Rationale: the constant, its only call site, and its test are one
    behavior cluster well inside a single specialist lifecycle.

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md` (sections 1 and 4)

## 3. Tasks

- Extend `CupidApiConfig` with `static const String environment =
  String.fromEnvironment('CUPID_ENV', defaultValue: 'local')`. Leave `baseUrl`
  and its `defaultValue: 'http://localhost:3000'` untouched.
- Add the production origin as a named constant in the same class (the single
  place `https://api.cupidus.app` appears in code).
- Add `static String? validationError(String environment, String baseUrl)` as a
  pure function returning a human-readable reason, or `null` when valid. It must
  reject: an `environment` outside `{local, production}`; `environment ==
  'production'` paired with any `baseUrl` other than the production origin
  constant. It must accept the default `local` + `http://localhost:3000` pair
  unchanged.
- Add `static void assertValidConfig()` that reads the two consts and throws
  `StateError` with the `validationError` message when non-null.
- Call `CupidApiConfig.assertValidConfig()` in `mobile/lib/main.dart` before
  `setupServiceLocator()`. Keep it synchronous and side-effect free — no network
  probe, no logging framework dependency.
- Write unit tests over the pure `validationError` function (the consts are
  compile-time and cannot be varied in-test).
- Author `deployment/configuration-guide.md` with both invocations, including the
  production build command carrying both defines.

## 4. Acceptance Criteria

- Building with no defines produces the same local-dev origin and behavior as
  before this phase (AC2).
- Building with `--dart-define=CUPID_ENV=production
  --dart-define=CUPID_API_BASE_URL=https://api.cupidus.app` resolves the origin
  to `https://api.cupidus.app` for both the REST client and the socket transport
  (AC1).
- Declaring `CUPID_ENV=production` while the origin is missing, cleartext, or a
  different host throws at startup before any network call (requirements
  `Edge Cases`).
- No runtime-writable API origin exists anywhere in the app; selection is
  build-time only (AC5).
- `mobile/lib/core/config/app_config.dart` is unmodified.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/core/config/cupid_api_config.dart`,
  `mobile/lib/main.dart`
- Contracts or schemas: `CupidApiConfig.environment`,
  `CupidApiConfig.validationError`, `CupidApiConfig.assertValidConfig`
- Requirement configuration guide updates:
  `data/requirements/REQ-007_mobile_app_production_api_build_config/deployment/configuration-guide.md`
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `lib/core/config`
- Required levels:
  - unit: `mobile/test/core/config/cupid_api_config_test.dart` covering the
    valid local default pair, the valid production pair, an unknown environment
    value, `production` with the local-dev origin (the silent-fallback case),
    `production` with a cleartext origin, and `production` with a wrong host.
  - mobile build/type-check/static-analysis: `flutter analyze`; `flutter build`
    with no defines; `flutter build` with both production defines. Both builds
    must compile.
- Required checks:
  - grep confirms `https://api.cupidus.app` appears in `lib/` only as the single
    named constant in `CupidApiConfig`.
  - grep confirms `AppConfig` remains unreferenced and `app_config.dart` is
    unchanged.
- Minimum gates by risk surface:
  - Silent local-dev fallback: the unit case pairing `production` with
    `http://localhost:3000` must fail validation.
  - Build-time-only selection (AC5): static analysis plus the grep check that no
    setter or mutable field exposes the origin.
- Required regression or contract coverage: existing `mobile/test` suites that
  construct clients against `CupidApiConfig.baseUrl` must still pass unchanged.
- Evidence format: command, exit status, and assertion output recorded in
  `coding-plan/test-results.md`.
- Requirement mobile visual audit: YES — AC3 and AC4 (install and run both
  flavors on a real emulator/simulator, observe the production build reaching
  `api.cupidus.app` and the local-dev build still reaching local dev, with no
  `localhost` / `10.0.2.2` attempt from either the REST or the socket transport
  in the production build) belong to the requirement-level mobile runtime audit
  gate, not to this phase.

## 7. Status

- Status: DONE
- Last updated: 2026-08-22
- Evidence: `coding-plan/test-results.md` (Result: PASS)
