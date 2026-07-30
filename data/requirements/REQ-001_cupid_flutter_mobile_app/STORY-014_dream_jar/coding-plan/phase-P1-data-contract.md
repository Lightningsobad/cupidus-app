# Phase P1 – Dream Jar Data Contract And Amount Formatting

## 1. Objective

Land the single HTTP boundary and shared value types every UI phase consumes:
`DreamJar` / `Contribution` models with tolerant numeric decoding, a
`DreamJarRepository` over the frozen `dream-jar` endpoints, the AC3
`DreamJarUnpairedFailure`, and VND amount formatting.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-data-contract.md`
- Owner: Mobile Developer
- Lane: Mobile (contract-first)

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/dream_jar/data/dream_jar.dart`
  - `mobile/lib/features/dream_jar/data/contribution.dart`
  - `mobile/lib/features/dream_jar/data/dream_jar_repository.dart`
  - `mobile/lib/features/dream_jar/data/dream_jar_amount_format.dart`
  - `mobile/test/features/dream_jar/data/dream_jar_model_test.dart`
  - `mobile/test/features/dream_jar/data/dream_jar_repository_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A for this phase (no UI surface)
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `DreamJar`, `Contribution`, `DreamJarStatus`
  - `DreamJarRepository`
  - `DreamJarUnpairedFailure`
  - `DreamJarAmountFormat`
- Shared Interfaces Consumed:
  - `CupidApi` (`mobile/lib/core/network/cupid_api.dart`) shared `Dio`
  - `CupidApiFailure` hierarchy (`core/network/cupid_api_failure.dart`)
- Risk Surfaces:
  - Decimal-as-string JSON decoding
  - Unpaired access (AC3)
  - Progress / liquid-fill bounds
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §2 and §4 `Contracts And Integrations`
  - consumer contract: cubits in P2-P4 call only `DreamJarRepository` and catch only `CupidApiFailure` subtypes
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §2, §4 `Contracts And Integrations`, §4 `Risk Surfaces And Source Of Truth`
  - OQ constraints: ADR-014a (no encryption, no new dependency), ADR-014c (tolerant numeric decoding), ADR-014g (use `CupidApi.dio`, not the generated `Epic5DreamJarApi`)
  - existing pattern to mirror: `mobile/lib/features/auth/data/auth_repository.dart` and `mobile/test/features/auth/data/auth_repository_test.dart`
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: complete, independently testable data access layer with no UI
  - Source/Test File Count: 4 source + 2 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §2, §3 `Open Question Constraints`, §4 `Contracts And Integrations`, §4 `Risk Surfaces And Source Of Truth`
- `mobile/lib/features/auth/data/auth_repository.dart` (the `_api.dio` + failure-rethrow precedent)
- `mobile/lib/core/network/cupid_api_failure.dart`

## 3. Tasks

- Add `DreamJarStatus { active, completed, archived }` decoded from the lowercase wire value, falling back to `active` for an unrecognized value.
- Add `DreamJar` and `Contribution` with `fromJson`, using one shared private numeric parser that accepts `num`, numeric `String`, and null (default 0) — the backend `decimal` columns serialize as strings.
- Expose `DreamJar.progressPercent` clamped to `0..100`: prefer the server-provided `progress`, and when it is absent compute `min(100, round(current / target * 100))` guarding `target <= 0` as `0`.
- Add `DreamJarRepository(CupidApi api)` with: `fetchJars({int limit = 50, int offset = 0})`, `fetchJar(String id)`, `createJar({required String name, required num targetAmount, DateTime? deadline})`, `addContribution({required String jarId, required num amount})`, `fetchContributions(String jarId, {int limit = 50, int offset = 0})`. Call `api.dio` directly with `<Object?>` typing; do not use `Epic5DreamJarApi`.
- On `DioException`, rethrow `e.error` (already a mapped `CupidApiFailure`), substituting `UnexpectedFailure()` when it is null — mirroring `AuthRepository`.
- Before rethrowing, translate `HttpStatusFailure(404, message)` whose message contains `not paired` (case-insensitive) into `DreamJarUnpairedFailure`; leave any other 404 as the original failure so a missing jar stays distinguishable.
- Declare `DreamJarUnpairedFailure` as a `CupidApiFailure` subtype in `dream_jar_repository.dart`.
- Add `DreamJarAmountFormat.vnd(num)` using `intl` `NumberFormat` for grouped VND output, plus `DreamJarAmountFormat.grouped(String digits)` for as-you-type grouping used by P3's amount field.
- Send `deadline` as an ISO-8601 string only when non-null; never send `currency` (backend defaults to VND per ADR).

## 4. Acceptance Criteria

- `DreamJar.fromJson` and `Contribution.fromJson` produce identical values for `"50000000.00"` and `50000000`.
- `progressPercent` returns 0 for `targetAmount = 0`, 0 for `currentAmount = 0`, and 100 when `currentAmount > targetAmount`.
- A 404 carrying `User not found or not paired` surfaces as `DreamJarUnpairedFailure`; a 404 carrying `Dream Jar not found` does not.
- Every repository method throws a `CupidApiFailure` subtype and never a raw `DioException`.
- No file outside this phase's write scope changes; no backend, `mobile/openapi/**`, or `pubspec.yaml` edit.

## 5. Planned Outputs

- Code files: the six paths listed in `Write Scope`
- Contracts: `DreamJarRepository`, `DreamJar`, `Contribution`, `DreamJarStatus`, `DreamJarUnpairedFailure`, `DreamJarAmountFormat`
- Requirement configuration guide updates: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, data layer only
- Required levels:
  - unit: model decoding (both numeric shapes, null deadline, unknown status), progress clamp edge cases, repository failure mapping and the 404 message split, VND formatting
  - mobile build/type-check/static-analysis: `flutter analyze` clean for the touched files
- Required checks: repository tests use a mocked/`DioAdapter`-style `Dio` (no live network); assert request path, query parameters, and body for each method
- Minimum gates by risk surface: decimal-as-string decoding → both-shape fixtures; AC3 → 404 message split test; progress bounds → edge-case unit tests
- Required regression or contract coverage: existing `mobile/test/openapi/cupid_api_smoke_test.dart` and `core/network/cupid_error_interceptor_test.dart` must stay green
- Evidence format: concise rows in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/dream_jar/data`
  - Static analysis: `flutter analyze`
  - Required assertion evidence: decoded amount values, thrown failure types, and request path/body assertions

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
