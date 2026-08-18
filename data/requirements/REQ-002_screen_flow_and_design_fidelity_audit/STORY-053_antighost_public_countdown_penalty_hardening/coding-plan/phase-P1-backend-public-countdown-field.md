# Phase P1 – Backend `publicCountdown` field

## 1. Objective

`publicCountdown` is accepted on `POST /ghost-config`, persisted on the
`ghost_configs` record, and returned by every endpoint that returns a
`GhostConfig` — defaulting to `true` when the client omits it (AC1).

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-backend-public-countdown-field.md`
- Owner: Backend Developer
- Lane: Backend

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: YES
- Write Scope:
  - `backend/src/modules/ghost-config/entities/ghost-config.entity.ts`
  - `backend/src/modules/ghost-config/dto/create-ghost-config.dto.ts`
  - `backend/src/modules/ghost-config/ghost-config.service.ts`
  - `backend/src/modules/ghost-config/ghost-config.service.spec.ts`
- Impacted Runtime Service/App:
  - Name: backend-api
  - Runtime Registry Id: `backend-api`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: backend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (`npm run build`)
  - Startup Command Source: N/A for this phase
  - Readiness Check: N/A
  - Port Contract: per-project loopback host binding (unchanged)
- Shared Interfaces Produced:
  - `publicCountdown` on the `GhostConfig` wire record
    (`../architecture/contract-summary.md` sections 1-3)
- Shared Interfaces Consumed:
  - None
- Risk Surfaces:
  - Service drops submitted value
- Source Of Truth:
  - authoritative artifact or convention:
    `../architecture/contract-summary.md`
  - consumer contract: P2 (mobile) reads the field per contract summary
    section 4
- Primary Inputs Summary:
  - requirements: `../requirements/` — In Scope items 1 and 7, AC1, AC4
  - architecture: `../architecture/contract-summary.md`,
    `../architecture/solution.md` sections 1 (Key Discovery) and 4
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: none
- Phase Sizing:
  - Behavior Slice: one additive persisted field on one existing module
  - Source/Test File Count: 4
  - Split Required: NO
  - Split Rationale: single behavior cluster well inside one lifecycle

## 2. Required Reads

- `../requirements/`
- `../architecture/contract-summary.md`
- `../architecture/solution.md` sections 1 and 4

## 3. Tasks

- Add `@Column({ type: 'boolean', default: true }) publicCountdown: boolean;` to
  `GhostConfig`, placed immediately after the `penalty` column so the entity
  field order matches the wire record documented in the contract summary.
- Add the DTO field with `@ApiProperty({ description: ..., required: false,
  example: true })`, `@IsOptional()`, `@IsBoolean()`, typed
  `publicCountdown?: boolean;`. Import `IsBoolean` and `IsOptional` from
  `class-validator`.
- **Thread the value through `GhostConfigService.create()`**: add
  `publicCountdown: dto.publicCountdown ?? true,` to the
  `this.configRepository.create({ ... })` object literal. That literal
  whitelists fields explicitly, so the entity column default alone would not
  persist a submitted `false` (`../architecture/solution.md` Key Discovery 1).
- Extend `ghost-config.service.spec.ts` `describe('create')` with two cases:
  a submitted `publicCountdown: false` reaches `configRepository.create`, and an
  omitted `publicCountdown` reaches it as `true`. Assert on the argument passed
  to the `configRepoMock.create` spy, not on the mock's return value — the mock
  returns whatever the test hands it, so asserting the return value would pass
  even if the service dropped the field.
- Do not author a migration file: the schema is `synchronize: true`
  (`backend/src/app.module.ts:38`) and no `backend/src/migrations/` directory
  exists.
- Do not modify `approve()`, `reject()`, `getActive()`, `getPending()`, or
  `getStormStatus()` — they carry or query the whole record and already return
  the new column. `getStormStatus`'s `{eligible, penalty}` shape must not gain
  the field.

## 4. Acceptance Criteria

- `POST /ghost-config` with `publicCountdown: false` persists `false`; the same
  request omitting the key persists `true` (AC1).
- Every endpoint returning a `GhostConfig` includes `publicCountdown`; the
  `storm-status` response shape is unchanged.
- `Penalty`, `ConfigStatus`, and the approval state machine are untouched (AC5).
- `npm run build` passes with no new type errors.

## 5. Planned Outputs

- Code directories or files: the four paths in `Write Scope`
- Contracts or schemas: implements `../architecture/contract-summary.md`
  sections 1-3
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: NestJS backend, `ghost-config` module
- Required levels:
  - unit: `ghost-config.service.spec.ts` — `create()` default and explicit-false
    cases
  - backend build/type-check: `npm run build`
- Required checks: the two new `create()` assertions target the
  `configRepoMock.create` call argument
- Minimum gates by risk surface:
  - Service drops submitted value: both new unit cases pass
- Required regression or contract coverage: the pre-existing `create`,
  `approve`, `reject`, `getActive`, `getPending`, and `getStormStatus` specs
  continue to pass unmodified
- Evidence format: test command + pass/fail summary recorded in
  `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `npm test -- ghost-config.service.spec` from `backend/`
  - Build/type-check: `npm run build` from `backend/`
  - Required assertion evidence: quoted assertion showing
    `configRepoMock.create` received `publicCountdown: false` in one case and
    `publicCountdown: true` in the omitted-key case

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-18
