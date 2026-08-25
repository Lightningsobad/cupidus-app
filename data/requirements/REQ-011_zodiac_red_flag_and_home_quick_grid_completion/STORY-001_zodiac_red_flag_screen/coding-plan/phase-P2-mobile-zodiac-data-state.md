# Phase P2 – Mobile Zodiac Data, Domain And State

## 1. Objective

Land the Dart side of the response union — models, the single path/key-aware
repository, and the cubit/state that drives the screen — so the presentation
phase renders a typed payload and never a raw map.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-mobile-zodiac-data-state.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None — depends on the published contract document, not on merged backend code
- Parallelizable: YES (with P0, P1)
- Write Scope:
  - `mobile/lib/features/zodiac/domain/zodiac_red_flag.dart`
  - `mobile/lib/features/zodiac/data/zodiac_repository.dart`
  - `mobile/lib/features/zodiac/presentation/zodiac_cubit.dart`
  - `mobile/lib/features/zodiac/presentation/zodiac_state.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/zodiac/**`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` — not run by this phase; static analysis and `flutter test` only
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ZodiacRedFlagToday` union type and `ZodiacCubit` state surface consumed by P3
- Shared Interfaces Consumed:
  - `GET /zodiac/red-flag/today` response union (`../architecture/contract-summary.md` sections 1-4)
- Risk Surfaces:
  - None (the mobile halves of Degraded payload honesty, Design fidelity, and Reachability are gated in P3)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md`; `VibesRepository` as the structural precedent
  - consumer contract: P3 presentation
- Primary Inputs Summary:
  - requirements: AC1, AC2, AC3
  - architecture: `../architecture/contract-summary.md` sections 1-4, 6; `../architecture/solution.md` section 4 Mobile Lane guardrails
  - OQ constraints: OQ2 RESOLVED — never re-derive the sign from `birthday` or `zodiacSignFor()`
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: data + domain + state for one screen
  - Source/Test File Count: 4 source + 1 edit + 1-2 tests
  - Split Required: NO
  - Split Rationale: the screen and its widgets are P3.

## 2. Required Reads

- `../requirements/` (AC1, AC2, AC3)
- `../architecture/contract-summary.md` sections 1-4 and 6
- `../architecture/solution.md` section 4 Mobile Lane

## 3. Tasks

- Model the response as a sealed/union Dart type with a `ready` variant (`contentDate`, `conflictIndex`, `partners`, `dailyTips`) and an `incompleteProfile` variant (`contentDate`, `missing`).
- Parse `status` textually and map any unrecognised value to `incompleteProfile` — fail honest, never `ready`.
- Treat a `ready` body missing a required key as a contract violation that surfaces the generic error state; do not substitute defaults.
- Parse `tint` and `icon` with a `default:` branch (neutral `colorTextMuted` tile + `favorite` glyph) rather than an exhaustive `switch` that throws.
- Feed `zodiacSign` to `CupidZodiacSign.tryParse` unchanged, lowercase, with no TitleCasing.
- Implement `ZodiacRepository` as the only Dart file that knows the `/zodiac` path and the JSON keys, rethrowing the mapped `CupidApiFailure` from `DioException.error` exactly as `VibesRepository` does.
- Implement `ZodiacCubit`/`ZodiacState` with loading, ready, incomplete-profile, and error states; no refresh-on-resume and no shuffle/regenerate affordance.
- Register the repository and cubit in `service_locator.dart` following the existing registration pattern.

## 4. Acceptance Criteria

- `zodiac_repository.dart` is the only file under `mobile/lib` containing the string `/zodiac/red-flag/today` or the payload JSON keys.
- Parsing a `ready` fixture yields exactly 2 partners with `partners[0].role == 'self'` and exactly 3 tips in wire order.
- Parsing an `incomplete_profile` fixture, and parsing an unknown `status`, both yield the incomplete-profile state with no fabricated content.
- An unknown `tint` or `icon` parses to the neutral fallback without throwing.
- No score, blurb, or tip selection is computed on device; no `DateTime.now()` is used for `contentDate`.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/zodiac/{domain,data,presentation}` state layer plus the `service_locator.dart` registration
- Contracts or schemas: Dart mirror of `../architecture/contract-summary.md` sections 3 and 4
- Notes or evidence: results appended to `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Flutter unit tests, no device)
- Required levels:
  - unit: model parsing (`ready`, `incomplete_profile`, unknown `status`, unknown `tint`/`icon`, missing required key) and cubit state transitions with a mocked repository
  - mobile build/type-check/static-analysis: `flutter analyze` on `mobile`
- Required checks: grep proof that `/zodiac` paths and JSON keys appear only in `zodiac_repository.dart`
- Required regression or contract coverage: fixtures copied verbatim from `../architecture/contract-summary.md` section 1
- Evidence format: `flutter test` summary plus `flutter analyze` exit status recorded in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/features/zodiac`
  - Build/type-check/lint command when required: `flutter analyze`
  - Required assertion evidence: the five parsing assertions above, each named in the test output

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
