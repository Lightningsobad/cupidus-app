# Phase P0 – Contract And Data Layer

## 1. Objective

Own the client side of the frozen `love-contracts` contract: a defensive `LoveContract` model, a
repository for the three endpoints, a pairing-gate repository over `GET /users/me`, and their
`get_it` registrations — so every later phase consumes typed Dart values, never raw JSON.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-contract-data-layer.md`
- Owner: Mobile Developer
- Lane: Mobile (contract-first)

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/love_contracts/data/love_contract.dart`
  - `mobile/lib/features/love_contracts/data/love_contract_repository.dart`
  - `mobile/lib/features/love_contracts/data/love_contract_gate_repository.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/test/features/love_contracts/data/love_contract_repository_test.dart`
  - `mobile/test/features/love_contracts/data/love_contract_gate_repository_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (`flutter build apk --debug`) — not run in this phase
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `LoveContract`, `ContractSignStatus`
  - `LoveContractRepository` (`fetchCurrent`, `saveClauses`, `sign`)
  - `LoveContractGateRepository` (`fetchPairingState`)
  - `PartnerDisplayName` provider typedef registered in `service_locator.dart`
- Shared Interfaces Consumed:
  - `mobile/lib/core/network/cupid_api.dart` (shared `Dio`, `CupidApiFailure` hierarchy)
- Risk Surfaces:
  - Untyped response bodies (`Response<void>`)
  - Creator-only backend capability (ADR-006c)
  - Clause constraints 1..20
  - AC4 pairing gate data source
- Source Of Truth:
  - authoritative artifact: `backend/src/modules/love-contracts/` (read-only) and
    `backend/src/modules/users/entities/user.entity.ts`
  - consumer contract: `LoveContract.fromJson` plus the mapped `CupidApiFailure` returned to callers
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` §2 Downstream Contract Summary, ADR-006b, ADR-006c
  - backend reference: `backend/src/modules/love-contracts/entities/love-contract.entity.ts`,
    `dto/create-contract.dto.ts`, `love-contracts.service.ts`,
    `backend/src/modules/users/entities/user.entity.ts`
  - pattern reference: `mobile/lib/features/auth/data/auth_repository.dart` lines 88-112
  - OQ constraints: `../architecture/solution.md` §3 (no persistence per OQ4)
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: the complete client contract boundary for this feature
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../architecture/solution.md` §2, ADR-006b, ADR-006c
- the four backend files named above (read-only reference)
- `mobile/lib/features/auth/data/auth_repository.dart` (the established untyped-body pattern)
- `mobile/lib/core/network/cupid_api_failure.dart`

## 3. Tasks

- Add `ContractSignStatus { unsigned, signedByMe, awaitingPartner }` and an immutable
  `LoveContract { id, clauses, status, signedAtRequester }` with `LoveContract.fromJson`.
  Map the server's `status` strings (`created`, `signed_requester`, `signed_partner`) defensively:
  unknown or missing values fall back to `unsigned`; a missing `clauses` array becomes `const []`;
  missing timestamps stay `null`. Never throw from `fromJson`.
- Add `LoveContractRepository` taking the injected `CupidApi`:
  - `Future<LoveContract?> fetchCurrent()` → `_api.dio.get<Object?>('/love-contracts/my-pending')`;
    a `null`/empty body returns `null` (the empty state), not an error.
  - `Future<LoveContract> saveClauses(List<String> clauses)` →
    `_api.dio.post<Object?>('/love-contracts', data: {'clauses': clauses})`.
  - `Future<LoveContract> sign()` → `_api.dio.patch<Object?>('/love-contracts/sign')`.
- Catch `DioException` in each method and rethrow `e.error` when it is a `CupidApiFailure`,
  otherwise `const UnexpectedFailure()` — callers must only ever see `CupidApiFailure`.
  Add a dedicated `SignUnavailableFailure` (or an equivalent named result) for the
  `HttpStatusFailure(404, ...)` case on `sign()` so P3 can render the ADR-006c copy without
  inspecting status codes in the UI.
- Add `LoveContractGateRepository.fetchPairingState()` → `_api.dio.get<Object?>('/users/me')`
  returning a small `PairingState { myDisplayName, partnerId }`. A failure returns an
  unpaired `PairingState` (see architecture §4 Pairing Gate) rather than throwing.
- Register both repositories as `registerLazySingleton` in `service_locator.dart`, plus
  `PartnerDisplayName` (`typedef PartnerDisplayName = String? Function();`) with a default
  implementation returning `null`.
- Write the two unit test files using the existing test style (no `mocktail`; use a
  `DioAdapter`-free approach consistent with `mobile/test/features/auth/data/auth_repository_test.dart`).

## 4. Acceptance Criteria

- No file under `backend/` is modified.
- No `package:cupid_api/...` import appears in the new files and no `Dio` is constructed.
- `LoveContract.fromJson` never throws for a `null` body, an unknown `status`, a missing
  `clauses` key, or missing timestamps.
- Every repository method surfaces only `CupidApiFailure` subtypes.
- `sign()`'s 404 is distinguishable from a network failure at the repository boundary.
- `fetchPairingState()` returns an unpaired state instead of throwing on failure.
- No local persistence (no `shared_preferences`, no Drift, no `hydrated_bloc`) is introduced.

## 5. Planned Outputs

- Code files: the four `lib/` paths in Write Scope
- Contracts: `LoveContract`, `ContractSignStatus`, `PairingState`, both repositories,
  `PartnerDisplayName`
- Requirement configuration guide updates: none
- Notes or evidence: one concise row per check in `test-results.md` (written in P5)

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter (`mobile` package), data layer only — no widgets
- Required levels:
  - unit: `LoveContract.fromJson` (happy path, `null` body, unknown `status`, missing `clauses`);
    each repository method's success path and failure mapping; `sign()` 404 →
    sign-unavailable failure; `fetchPairingState()` paired / unpaired / failure
  - mobile build/type-check/static-analysis: `flutter analyze` clean for the touched files
- Required checks:
  - `flutter test test/features/love_contracts/data/`
  - `flutter analyze`
- Mobile discoverability / navigation integration: N/A for this phase (owned by P4)
- Minimum gates by risk surface:
  - untyped response bodies → the `fromJson` unit tests above
  - creator-only capability → the `sign()` 404 mapping test
  - clause constraints → repository passes `clauses` through unchanged; bounds are enforced in P1
  - pairing gate data source → `fetchPairingState()` tests
- Required regression or contract coverage: existing `mobile/test/openapi/cupid_api_smoke_test.dart`
  and `mobile/test/core/network/` tests must stay green after the `service_locator.dart` edit
- Evidence format: concise rows in `coding-plan/test-results.md` (P5 consolidates)
- Verification strategy:
  - Targeted tests: the two new data test files plus the `core/network` regression files
  - Build/type-check command: `flutter analyze`
  - Required assertion evidence: mapped failure type per case and parsed field values

## 7. Status

- Status: DONE
- Last updated: 2026-07-30
- Evidence: `flutter analyze` clean for touched files; `flutter test
  test/features/love_contracts/data/ test/core/network/
  test/openapi/cupid_api_smoke_test.dart` — 28 passed, 0 failed.
