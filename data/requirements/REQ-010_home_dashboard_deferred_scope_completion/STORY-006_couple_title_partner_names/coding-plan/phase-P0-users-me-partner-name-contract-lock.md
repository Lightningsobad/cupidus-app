# Phase P0 – Lock `partnerDisplayName` Into The `GET /users/me` Contract

## 1. Objective

Make the partner display name a declared, test-protected part of the
`GET /users/me` contract instead of an undocumented byproduct of the service's
object spread, without changing the response body by a single byte.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-users-me-partner-name-contract-lock.md`
- Owner: Backend Developer
- Lane: Backend

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: YES
- Write Scope:
  - `backend/src/modules/users/users.controller.ts`
  - `backend/src/modules/users/dto/me-profile-response.dto.ts` (new)
  - `backend/src/modules/users/users.controller.spec.ts` (new)
- Impacted Runtime Service/App:
  - Name: backend-api
  - Runtime Registry Id: `backend-api`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: backend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: per-project loopback host binding
- Shared Interfaces Produced:
  - `GET /users/me` `partnerDisplayName` (`../architecture/contract-summary.md` §1-§3)
- Risk Surfaces:
  - Undeclared `/users/me` partner key
  - Response-shape narrowing
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md`
  - consumer contract: mobile phase P1
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1-AC3
  - architecture: `../architecture/solution.md` §1 Key Discovery, §4 Backend Lane
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: publish + regression-lock one existing response field
  - Source/Test File Count: 3
  - Split Required: NO

## 2. Required Reads

- `../architecture/contract-summary.md`
- `../architecture/solution.md` §1 Key Discovery and §4 Backend Lane
- `backend/src/modules/users/users.controller.ts`
- `backend/src/modules/users/users.service.ts` lines 30-40

## 3. Tasks

1. Read `users.service.ts:30-40` and confirm `getProfileWithPartner` still
   returns `partnerDisplayName`, and that `users.service.spec.ts:69-131` still
   covers paired / unpaired / dangling-`partnerId` / null-`displayName`. Do not
   modify either file — this phase adds coverage above them, not inside them.
2. Add `MeProfileResponseDto` in `backend/src/modules/users/dto/me-profile-response.dto.ts`
   describing the `GET /users/me` payload with `@ApiProperty` entries,
   including `partnerDisplayName` as `string | null` with the nullable
   semantics from `../architecture/contract-summary.md` §3. This class is a
   **Swagger schema type only**.
3. Annotate `UsersController.getProfile` with
   `@ApiOkResponse({ type: MeProfileResponseDto })` and keep the method body
   delegating to `usersService.getProfileWithPartner(req.user.uid)` unchanged.
4. Add `users.controller.spec.ts` with a mocked `UsersService` asserting that
   `getProfile` returns the value from `getProfileWithPartner` (not
   `findByFirebaseUid`), that `partnerDisplayName` is present on the result,
   and that the caller's existing keys (`id`, `displayName`, `partnerId`,
   `isGhostModeEnabled`) survive alongside it.
5. Run the targeted spec, then the build.

## 4. Acceptance Criteria

- `GET /users/me` is documented in Swagger with `partnerDisplayName` and its
  nullable contract.
- The runtime response body is unchanged: no interceptor, no `plainToInstance`,
  no `@Exclude`/`@Expose`, no serialization option is introduced by this phase.
- A controller-level spec fails if `getProfile` stops delegating to
  `getProfileWithPartner` or if `partnerDisplayName` disappears from its result.
- `users.service.ts` and `users.service.spec.ts` are untouched.

## 5. Planned Outputs

- Code files: `users.controller.ts`, `dto/me-profile-response.dto.ts`,
  `users.controller.spec.ts`
- Contracts: `GET /users/me` Swagger schema for `MeProfileResponseDto`
- Notes or evidence: results recorded in `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: NestJS backend, `modules/users`
- Required levels:
  - unit: `users.controller.spec.ts` — delegation to `getProfileWithPartner`,
    `partnerDisplayName` present, caller identity keys preserved
  - backend build/type-check: `npm run build`
- Required checks: no serialization/transform behavior added to `GET /users/me`
- Minimum gates by risk surface:
  - Undeclared `/users/me` partner key -> controller spec green
  - Response-shape narrowing -> caller-identity-keys assertion green
- Required regression or contract coverage: existing
  `users.service.spec.ts` `getProfileWithPartner` block must still pass unmodified
- Required runtime signals: jest assertion output for the new spec
- Evidence format: exact command + pass/fail counts in
  `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `cd backend && npx jest src/modules/users`
  - Build/type-check: `cd backend && npm run build`
  - Required assertion evidence: the four new controller assertions named above
- Do not run `npm run test:e2e` or the full jest suite for this phase.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
