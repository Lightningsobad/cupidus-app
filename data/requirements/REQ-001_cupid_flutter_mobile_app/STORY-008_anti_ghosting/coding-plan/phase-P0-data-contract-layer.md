# Phase P0 – Ghost-Config Data Contract Layer

## 1. Objective

Give every later phase one typed, tested Dart consumer of the frozen
`ghost-config` REST contract, registered in `get_it`.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-data-contract-layer.md`
- Owner: Mobile Developer
- Lane: Contract

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/anti_ghosting/data/ghost_config_models.dart`
  - `mobile/lib/features/anti_ghosting/data/ghost_config_repository.dart`
  - `mobile/lib/core/di/service_locator.dart` (additive registration only)
  - `mobile/test/features/anti_ghosting/data/ghost_config_repository_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A for this phase
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `GhostConfig`, `Penalty`, `ConfigStatus`, `StormStatus` models
  - `GhostConfigRepository`
- Shared Interfaces Consumed:
  - frozen `ghost-config` REST contract
  - `CupidApi` (shared `Dio`) and `CupidApiFailure` from `core/network/`
  - `BackendUserIdStore` from `core/realtime/`
- Risk Surfaces:
  - Frozen `ghost-config` wire contract
- Source Of Truth:
  - authoritative artifact or convention: `backend/src/modules/ghost-config/`
    (`ghost-config.controller.ts` routes, `entities/ghost-config.entity.ts`,
    `dto/create-ghost-config.dto.ts`); `../architecture/solution.md` §2
  - consumer contract: exact paths, HTTP methods, request body keys, and
    `penalty` / `status` wire strings
- Primary Inputs Summary:
  - requirements: `../story_master.md` In Scope, AC1
  - architecture: `../architecture/solution.md` §2 Downstream Contract Summary,
    §4 Contracts And Integrations, ADR-1, ADR-4
  - OQ constraints: none
  - upstream phase outputs: none
  - UX constraints, if truly required: none for this phase
  - review findings: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: data access + model mapping only, no UI and no state machine
  - Source/Test File Count: 4
  - Split Required: NO
  - Split Rationale: N/A

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md` §2, §4 Contracts And Integrations, §6 ADR-1, ADR-4
- `backend/src/modules/ghost-config/ghost-config.controller.ts`,
  `entities/ghost-config.entity.ts`, `dto/create-ghost-config.dto.ts`
- `mobile/lib/features/auth/data/auth_repository.dart` (the Dio + failure-handling
  precedent, especially `_syncBackendProfile`)
- `mobile/lib/core/di/service_locator.dart`

## 3. Tasks

- Add `ghost_config_models.dart` with immutable `GhostConfig`
  (`id`, `coupleId`, `timeoutMinutes`, `penalty`, `proposedBy`, `approvedBy`,
  `status`, `createdAt`, `updatedAt`), a `Penalty` enum
  (`emojiStorm`/`noise`/`none`) and a `ConfigStatus` enum
  (`active`/`pendingApproval`/`rejected`/`superseded`), each with an explicit
  wire-string mapping (`emoji_storm`, `pending_approval`, ...) and an
  unknown-value fallback that does not throw. Add a `StormStatus`
  (`eligible`, `penalty`) model.
- Add `GhostConfigRepository` taking the injected `CupidApi`, exposing
  `fetchActive()` -> `GhostConfig?`, `fetchPending()` -> `List<GhostConfig>`,
  `propose({required int timeoutMinutes, required Penalty penalty})`,
  `approve(String id)`, `reject(String id)`, and
  `fetchStormStatus(String partnerId)` -> `StormStatus`. Call the shared `Dio`
  directly (`_api.dio.get<Object?>('/ghost-config')` etc.) per ADR-1; do not use
  the generated `Epic23GhostConfigAntiGhostingApi`.
- Treat a null/empty body from `GET /ghost-config` as "no active config" and an
  empty array from `GET /ghost-config/pending` as "no pending proposal" — empty
  states, never errors. Let `CupidApiFailure` propagate; catch nothing else.
- Clamp `timeoutMinutes` to 1-120 before `propose()` and reject out-of-range
  input with an argument error rather than sending an invalid body.
- Register `GhostConfigRepository` as a lazy singleton in
  `service_locator.dart`, appended after the existing registrations without
  reordering or modifying any existing registration.
- Add `ghost_config_repository_test.dart` using a hand-written fake `Dio`
  (no `mocktail`, which is not a dependency), following
  `mobile/test/features/auth/data/auth_repository_test.dart`.

## 4. Acceptance Criteria

- Every repository method issues the exact path and HTTP method from
  `../architecture/solution.md` §2, asserted by test.
- `propose()` sends exactly `{"timeoutMinutes": <int>, "penalty": "<wire>"}` and
  nothing else, asserted by test.
- `Penalty` and `ConfigStatus` round-trip their exact wire strings
  (`emoji_storm`, `noise`, `none`, `active`, `pending_approval`, `rejected`,
  `superseded`), asserted by test.
- `fetchActive()` returns null and `fetchPending()` returns `[]` for empty
  responses without throwing, asserted by test.
- An unknown enum wire value does not throw.
- `mobile/lib/openapi` and `mobile/openapi/**` are untouched.
- No new entry in `pubspec.yaml`.
- No raw colour literal, `Colors.`, `Platform.is`, or `defaultTargetPlatform`
  is introduced (`no_fork_guard_test` stays green).

## 5. Planned Outputs

- Code directories or files: the four paths in Write Scope
- Contracts or schemas: `GhostConfigRepository` + models as the shared contract
  for P1, P2, P3
- Requirement configuration guide updates: none
- Notes or evidence: repository test assertions recorded for P4

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, data layer
- Required levels:
  - unit: `ghost_config_repository_test.dart` — paths, methods, request body,
    enum wire mapping, empty-state handling, range clamping
  - mobile build/type-check/static-analysis: `flutter analyze` on `mobile/`
- Required checks: `flutter test test/features/anti_ghosting/`,
  `flutter analyze`, and the existing `mobile/test/design_system/no_fork_guard_test.dart`
- Minimum gates by risk surface: frozen wire contract -> repository unit test
  asserting each path/method/body/enum
- Required regression or contract coverage: `mobile/test/openapi/cupid_api_smoke_test.dart`
  and `mobile/test/design_system/no_fork_guard_test.dart` stay green
- Evidence format: concise rows appended to `coding-plan/test-results.md` in P4
- Verification strategy:
  - Targeted tests/regression/contract checks: as above
  - Build/type-check/lint command when required:
    `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` in `mobile/`
  - Required assertion evidence: request path, method, and body-key assertions
    per endpoint

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
