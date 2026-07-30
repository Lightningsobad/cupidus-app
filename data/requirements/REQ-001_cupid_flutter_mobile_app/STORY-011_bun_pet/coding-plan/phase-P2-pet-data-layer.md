# Phase P2 – Pet Data Layer And DI

## 1. Objective

Implement `PetRepository` over the shared `Dio` instance for the four consumed
endpoints plus the pairing read, and register it in the composition root.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-pet-data-layer.md`
- Owner: Mobile Developer
- Lane: Mobile / Data

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/pet/data/pet_repository.dart`
  - `mobile/lib/core/di/service_locator.dart` (additive registration only)
  - `mobile/test/features/pet/data/pet_repository_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `PetRepository.readPairing()`, `readStatus()`, `interact()`,
    `adopt({species, name})`
  - `getIt<PetRepository>()` lazy-singleton registration
- Shared Interfaces Consumed:
  - P1 models (`Pet`, `PetStatus`, `PetPairing`, `PetSpecies`)
  - `mobile/lib/core/network/cupid_api.dart` barrel (`CupidApi`,
    `CupidApiFailure` family)
- Risk Surfaces:
  - Untyped `pets` REST parsing
  - Pairing hard gate (AC3) — data half
- Source Of Truth:
  - authoritative artifact: `backend/src/modules/pets/pets.controller.ts`,
    `backend/src/modules/users/users.controller.ts`
  - consumer contract: `../architecture/solution.md` D1, D2, D4 and §4
    Contracts And Integrations
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` D1-D4, §4 Contracts And
    Integrations, §4 Mobile Lane Handoff
  - upstream phase outputs: P1 models
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: REST access + error mapping + DI wiring
  - Source/Test File Count: 2 source (1 new, 1 additive edit) + 1 test
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` D1-D4, §4
- P1 outputs
- `mobile/lib/features/auth/data/auth_repository.dart:88-112` (the shared-`Dio`
  untyped-read precedent)
- `mobile/lib/core/di/service_locator.dart`
- `mobile/lib/core/network/cupid_api_failure.dart`

## 3. Tasks

- Implement `PetRepository` taking `CupidApi` by constructor injection and using
  `_api.dio` directly:
  - `readPairing()` → `GET /users/me`, read `partnerId` only.
  - `readStatus()` → `GET /pets/status`; a `null`/empty response body is HTTP 200
    meaning "no pet yet" and must return `null`, not throw.
  - `interact()` → `PATCH /pets/interact`, then re-read `GET /pets/status` and
    return that `PetStatus` (architecture D4).
  - `adopt({required PetSpecies species, required String name})` → `POST
    /pets/adopt` with the `AdoptPetDto` body shape, then re-read
    `GET /pets/status` and return it.
- Do not call `Epic4LovePetApi`; document the `Response<void>` reason inline in
  one short comment referencing architecture D1.
- Rethrow `DioException.error` (the mapped `CupidApiFailure`) so callers only
  ever catch `CupidApiFailure`; fall back to `UnexpectedFailure()` when
  `DioException.error` is null. Do not catch or inspect `DioExceptionType`.
- Register `PetRepository` as a `getIt.registerLazySingleton` in
  `setupServiceLocator()`, resolving `getIt<CupidApi>()`. Keep the edit to one
  additive block at the end of the function to minimise merge conflicts.
- Unit tests as described in Test Scope.

## 4. Acceptance Criteria

- Each method issues exactly the documented verb and path; asserted in tests.
- `readStatus()` returns `null` for a 200 with an empty/`null` body and never
  throws for that case.
- `interact()` and `adopt()` return the status fetched *after* the mutation.
- Every thrown error is a `CupidApiFailure` subtype; no `DioException` escapes
  the repository.
- No automatic retry of `interact()` or `adopt()`.
- `PetRepository` contains no widget, cubit, or mood-threshold logic.
- `service_locator.dart` still compiles with all existing registrations intact.

## 5. Planned Outputs

- Code files: the three files in Write Scope.
- Contracts: `PetRepository` public surface, `getIt<PetRepository>()`.
- Requirement configuration guide updates: none.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile`), data layer
- Required levels:
  - unit: `pet_repository_test.dart` against a stubbed `Dio`
    `HttpClientAdapter` (no real network): verb/path/body assertions, full
    payload parse, empty-body → `null`, `400` on interact → `HttpStatusFailure`,
    `409` on adopt → `HttpStatusFailure`, `interact()` triggers the follow-up
    status read
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: `cd mobile && flutter test test/features/pet/data` and
  `cd mobile && flutter analyze`
- Minimum gates by risk surface:
  - Untyped REST parsing: verb/path/body + payload parse unit tests
  - Pairing gate data half: `readPairing()` test for present, null, and empty
    `partnerId`
- Required regression or contract coverage: existing
  `service_locator` consumers must still resolve; run the full
  `flutter test test/core` suite once after the DI edit.
- Evidence format: concise rows in `coding-plan/test-results.md` at P9.
- Verification strategy:
  - Targeted tests: `test/features/pet/data`, plus `test/core` regression
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: request verb/path/body and mapped failure type

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
