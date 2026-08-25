# Phase P0 – Zodiac Content Tables And Pure Selector

## 1. Objective

Land the curated static content and the pure, clock-injected domain functions
that make AC1 (real per-pair content) and AC2 (per-day determinism) provable
properties of pure functions, with no entity, table, or migration.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-zodiac-content-domain.md`
- Owner: Backend Developer
- Lane: Backend

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: YES (with P2)
- Write Scope:
  - `backend/src/modules/zodiac/content/zodiac-sign.ts`
  - `backend/src/modules/zodiac/content/conflict-index.content.ts`
  - `backend/src/modules/zodiac/content/daily-tips.content.ts`
  - `backend/src/modules/zodiac/content/daily-tip.selector.ts`
  - `backend/src/modules/zodiac/content/*.spec.ts`
- Impacted Runtime Service/App:
  - Name: `backend-api`
  - Runtime Registry Id: `backend-api`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: backend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (`npm run build`)
  - Startup Command Source: N/A for this phase
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - canonical sign keys `aries`…`pisces`, `normalizeZodiacSign`
  - tint/icon vocabularies used by `dailyTips[]`
- Shared Interfaces Consumed:
  - None
- Risk Surfaces:
  - Content-table completeness (AC1)
  - Per-day determinism (AC2)
  - Tip-row-count guarantee (AC2/UX §2 Card 3)
  - Free-string `zodiacSign` normalization (AC3)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` section 4 "Contracts And Integrations" and "Risk Surfaces And Source Of Truth"
  - consumer contract: `../architecture/contract-summary.md` section 2
- Primary Inputs Summary:
  - requirements: AC1, AC2, AC3
  - architecture: `../architecture/solution.md` section 4; `../architecture/contract-summary.md` section 2
  - OQ constraints: OQ1 RESOLVED — curated static content, no CMS, no persistence
  - upstream phase outputs: none
  - UX constraints, if truly required: `../ux/ux-spec.md` §2 Card 3 only, for the tip row count
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: pure content + pure domain functions, no Nest wiring
  - Source/Test File Count: 4 source + 2-3 spec
  - Split Required: NO
  - Split Rationale: this is already the first half of the split of the backend chunk; the HTTP surface is P1.

## 2. Required Reads

- `../requirements/` (AC1, AC2, AC3)
- `../architecture/solution.md` section 4
- `../architecture/contract-summary.md` section 2
- `../ux/ux-spec.md` §2 Card 3 (tip row count only)

## 3. Tasks

- Define the 12 canonical lowercase sign keys plus each sign's element and `viLabel`, and `normalizeZodiacSign(input)` that trims, lowercases, and returns `null` for empty, unknown, or non-zodiac input (`ophiuchus` included).
- Author `conflict-index.content.ts` as a table keyed by the two sign keys sorted and joined, covering all 78 unordered pairs, each with an integer `score` in `0..10`, `scoreMax`, and non-empty `vi` `headline` and `body`.
- Author `daily-tips.content.ts` as an append-only pool of at least 12 tips, each with a stable `id`, an `icon` and `tint` drawn only from the vocabularies in contract-summary section 2, and non-empty `vi` `title` and `body`.
- Implement `selectDailyTips(coupleKey, contentDate, pool)` in `daily-tip.selector.ts` seeding `FNV-1a-32(sortedUserIdPair + '#' + contentDate)` and resolving three distinct pool indices by linear probing. No `Math.random()`, no `Date.now()`, no `new Date()` inside the selector — the date arrives as an argument.
- Write specs proving the four risk-surface gates listed above.

## 4. Acceptance Criteria

- Every one of the 78 sorted sign-pair keys resolves to an entry with non-empty `headline`/`body` and `0 <= score <= scoreMax`.
- `selectDailyTips` returns the identical 3 ids across 100 calls for a fixed `(coupleKey, contentDate)`, always 3 distinct ids, and a different `contentDate` changes the selection for at least one sampled couple.
- `normalizeZodiacSign` maps `'Aries'`, `'aries'`, `' ARIES '` to `aries`, and `''`, `null`, `undefined`, `'ophiuchus'` to `null`.
- No entity, migration, seed script, or persistence is introduced.

## 5. Planned Outputs

- Code directories or files: `backend/src/modules/zodiac/content/` (4 source modules + specs)
- Contracts or schemas: sign-key, tint, and icon vocabularies matching `../architecture/contract-summary.md` section 2 exactly
- Notes or evidence: results appended to `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: backend (NestJS, Jest unit)
- Required levels:
  - unit: content-table completeness, selector determinism, tip-pool size, sign normalization
  - backend build/type-check: `npm run build` in `backend`
- Required checks: selector source contains no `Math.random`, no `Date.now`, no `new Date()`
- Minimum gates by risk surface: as specified in `../architecture/solution.md` section 4 for Content-table completeness (AC1), Per-day determinism (AC2), Tip-row-count guarantee (AC2/UX §2 Card 3), and Free-string `zodiacSign` normalization (AC3)
- Required regression or contract coverage: identifier spellings match `../architecture/contract-summary.md` section 2
- Evidence format: Jest summary lines plus the build exit status recorded in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests/regression/contract checks: `npx jest src/modules/zodiac` in `backend`
  - Build/type-check/lint command when required: `npm run build` in `backend`
  - Required assertion evidence: the four gate assertions above, each named in the test output

## 7. Status

- Status: DONE
- Last updated: 2026-08-25
- Evidence: `npx jest src/modules/zodiac` — 4 suites, 14 tests passed (all 4
  risk-surface gates named in section 4 above are each proven by a passing
  test); `npm run build` in `backend` exited 0. Details in
  `coding-plan/test-results.md`.
