# Phase P1 – Zodiac Module, Endpoint And Response Union

## 1. Objective

Expose `GET /zodiac/red-flag/today` as the authoritative implementation of the
published response union, including the honest `incomplete_profile` state, and
register the module in the application.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-zodiac-api-surface.md`
- Owner: Backend Developer
- Lane: Backend

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: YES (with P2, P3)
- Write Scope:
  - `backend/src/modules/zodiac/zodiac.module.ts`
  - `backend/src/modules/zodiac/zodiac.controller.ts`
  - `backend/src/modules/zodiac/zodiac.service.ts`
  - `backend/src/modules/zodiac/dto/zodiac-red-flag-today.dto.ts`
  - `backend/src/modules/zodiac/zodiac.service.spec.ts`
  - `backend/src/app.module.ts`
- Impacted Runtime Service/App:
  - Name: `backend-api`
  - Runtime Registry Id: `backend-api`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: backend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (`npm run build`)
  - Startup Command Source: runtime registry `devCommand` (`npm run start:dev`) — not run by this phase
  - Readiness Check: N/A for this phase
  - Port Contract: per-project loopback host binding (`DEVSTACK_PORT_API`), unchanged by this phase
- Shared Interfaces Produced:
  - `GET /zodiac/red-flag/today` response union (`ready` | `incomplete_profile`)
- Shared Interfaces Consumed:
  - P0 sign keys, `normalizeZodiacSign`, conflict-index table, `selectDailyTips`
- Risk Surfaces:
  - Degraded payload honesty (AC3)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` sections 1, 3, 4; `VibesModule` as the structural precedent
  - consumer contract: `../architecture/contract-summary.md`
- Primary Inputs Summary:
  - requirements: AC1, AC2, AC3
  - architecture: `../architecture/solution.md` section 4 "Boundaries And Ownership", "Contracts And Integrations", Backend Lane handoff
  - OQ constraints: OQ2 RESOLVED — read the existing profile `zodiacSign` field only; do not add a profile input path
  - upstream phase outputs: P0 content modules and selector
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: HTTP surface + service orchestration for one endpoint
  - Source/Test File Count: 5 source (1 an edit) + 1 spec
  - Split Required: NO
  - Split Rationale: fits one lifecycle; the content/domain half is P0.

## 2. Required Reads

- `../requirements/` (AC1, AC2, AC3)
- `../architecture/contract-summary.md` sections 1-4
- `../architecture/solution.md` section 4 Backend Lane
- P0 outputs under `backend/src/modules/zodiac/content/`

## 3. Tasks

- Create `ZodiacModule` with `@Controller('zodiac')` and `@UseGuards(JwtAuthGuard)`, following the `VibesModule` module/controller/service shape and the `findByFirebaseUid` lookup pattern.
- Implement the service: resolve self and partner, normalize both signs through P0, compute `contentDate` as the server-local calendar day at the service boundary with the clock injected so tests can pin the day, and pass it to `selectDailyTips`.
- Return `status: "ready"` with `contentDate`, `conflictIndex`, exactly 2 `partners` (`partners[0].role === "self"`), and exactly 3 `dailyTips` with distinct ids in a stable order.
- Return HTTP `200` with `status: "incomplete_profile"`, `contentDate`, and a non-empty ascending-stable `missing` subset of `partner_link` / `self_zodiac` / `partner_zodiac` when the user is unpaired, or either sign is unset or unrecognised. The body must omit `conflictIndex`, `partners`, and `dailyTips` entirely.
- Declare the response union in `dto/zodiac-red-flag-today.dto.ts`; expose the shape via Swagger consistent with existing modules.
- Register `ZodiacModule` in `app.module.ts`.

## 4. Acceptance Criteria

- `GET /zodiac/red-flag/today` returns `200` for any authenticated caller; `401` only on a missing or invalid token.
- Unpaired, self-unset, and partner-unset each return `200` with `status: "incomplete_profile"` and no `conflictIndex`, `partners`, or `dailyTips` key present.
- A `ready` body carries exactly 2 partners with `partners[0].role === "self"` and exactly 3 distinct tips.
- Field names, `status` values, `missing` reasons, sign keys, tints, and icons match `../architecture/contract-summary.md` section 2 character for character.
- No entity, table, migration, seed script, or write path is added; the profile write path for `zodiacSign` is untouched.

## 5. Planned Outputs

- Code directories or files: `backend/src/modules/zodiac/` (module, controller, service, DTO, spec) and the `app.module.ts` registration
- Contracts or schemas: the response union implementing `../architecture/contract-summary.md` sections 1, 3, 4
- Notes or evidence: results appended to `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: backend (NestJS, Jest unit/service-level with mocked repositories and an injected clock)
- Required levels:
  - unit: service-level tests for the `ready` path and all three `incomplete_profile` reasons
  - backend build/type-check: `npm run build` in `backend`
- Required checks: `incomplete_profile` responses assert key *absence*, not falsy values; pinning the clock produces a stable `contentDate`
- Minimum gates by risk surface: as specified in `../architecture/solution.md` section 4 for Degraded payload honesty (AC3), payload half only — the widget half is P3
- Required regression or contract coverage: identifier spellings asserted against `../architecture/contract-summary.md` section 2
- Required runtime signals: none for this phase
- Evidence format: Jest summary lines plus the build exit status recorded in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests/regression/contract checks: `npx jest src/modules/zodiac` in `backend`
  - Build/type-check/lint command when required: `npm run build` in `backend`
  - Required assertion evidence: the four `status`-path assertions plus the key-absence assertion

## 7. Status

- Status: DONE
- Last updated: 2026-08-25
