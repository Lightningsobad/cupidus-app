# Phase P0 – `GET /users/me` partner display name

## 1. Objective

`GET /users/me` returns an additional `partnerDisplayName` key resolved from the
paired partner's `User` row, so the mobile lane has a real source for the
partner half of the chat header pairing title. Every existing key keeps its
current name, type, and meaning.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-users-me-partner-display-name.md`
- Owner: Backend Developer
- Lane: Backend

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `backend/src/modules/users/users.service.ts`
  - `backend/src/modules/users/users.controller.ts`
  - `backend/src/modules/users/users.service.spec.ts`
- Impacted Runtime Service/App:
  - Name: `backend-api`
  - Runtime Registry Id: `backend-api`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: backend
  - Startup Smoke: OPTIONAL — not run by this phase; Scrum Master/DevOps owns it
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `devCommand`
  - Readiness Check: `GET /api-docs-json`
  - Port Contract: per-project loopback host binding
- Shared Interfaces Produced:
  - `GET /users/me` `partnerDisplayName` (`../architecture/contract-summary.md`)
- Risk Surfaces:
  - Partner identity sourcing
  - Self-vs-partner name plumbing (latent defect, Key Discovery item 3)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md`
    sections 2-3
  - consumer contract: mobile P1 `ChatPartnerStore`
- Primary Inputs Summary:
  - requirements: `../story_master.md` AC1
  - architecture: `../architecture/solution.md` §4 Backend Lane;
    `../architecture/contract-summary.md`
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one additive response field on one existing endpoint
  - Source/Test File Count: 3
  - Split Required: NO

## 2. Required Reads

- `../architecture/contract-summary.md`
- `../architecture/solution.md` §4 Backend Lane

## 3. Tasks

- Add a `UsersService` method that returns the caller's `User` row plus the
  resolved `partnerDisplayName`. Resolve the partner with a **non-throwing**
  repository lookup keyed on the caller's existing `partnerId`. Do not call
  `UsersService.findOne`: it raises `NotFoundException`, which would turn an
  unpaired or dangling-partner profile request into a failure.
- Return `null` for `partnerDisplayName` in all three cases named in
  `../architecture/contract-summary.md` section 3: `partnerId` is null, the
  partner row is absent, or the partner's own `displayName` is null.
- Expose only the partner's `displayName`. Do not spread or return the partner
  `User` row, and do not add the partner's `email`, `firebaseUid`, or
  `photoUrl`.
- Point `UsersController.getProfile` at the new method. Leave `PATCH /users/me`
  and `POST /users/vow` untouched.
- Add unit coverage in `users.service.spec.ts` for the paired, unpaired,
  dangling-`partnerId`, and null-partner-`displayName` cases, including an
  assertion that the caller's own identity keys are unchanged.

## 4. Acceptance Criteria

- A paired caller's `GET /users/me` response contains `partnerDisplayName` set
  to the partner's `displayName`.
- An unpaired caller, a caller whose `partnerId` points at a deleted row, and a
  caller whose partner has a null `displayName` each receive
  `partnerDisplayName: null` with HTTP 200 — not an error and not an empty
  string.
- `displayName`, `id`, `partnerId`, and `isGhostModeEnabled` keep their existing
  names, types, and meanings in the response.
- No new endpoint, controller, module, entity, migration, or `@ApiResponse` DTO
  is introduced.

## 5. Planned Outputs

- Code directories or files: `backend/src/modules/users/`
- Contracts or schemas: implements `../architecture/contract-summary.md`
  sections 2-3
- Notes or evidence: test run recorded in `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: NestJS service layer, `backend-api`
- Required levels:
  - unit: `users.service.spec.ts` — paired, unpaired, dangling `partnerId`,
    null partner `displayName`
  - backend build/type-check: runtime registry `buildCommand`
- Required checks: assert the caller's own identity keys are byte-unchanged
  alongside the new key, so a future refactor cannot silently repoint
  `displayName` at the partner.
- Minimum gates by risk surface:
  - Partner identity sourcing: the four unit cases above pass
  - Self-vs-partner name plumbing: the unchanged-self-keys assertion passes
- Required regression or contract coverage: existing `users.service.spec.ts`
  cases pass unmodified.
- Evidence format: test command plus pass/fail summary in
  `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests/regression/contract checks: `npm test -- users.service`
  - Build/type-check/lint command when required: `npm run build`
  - Required assertion evidence: the null-case assertions and the
    unchanged-self-keys assertion quoted in `test-results.md`

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-18
