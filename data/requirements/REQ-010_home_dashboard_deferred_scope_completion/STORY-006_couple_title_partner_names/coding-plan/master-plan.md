# Master Coding Plan – Couple Title Shows Both Partner Names

## 1. Planning Metadata

- Story ID: REQ-010 / STORY-006
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes.

## 2. Planning Goal

- Shared contract owner: Backend Developer (`GET /users/me` response).
- Contract-first phase required: YES — the contract's consumer sits in a
  different lane (mobile), in a different deploy unit, and runs in parallel.
- Parallel execution possible: YES
- Critical path: P1 (mobile) — it is the only phase that changes observable
  behavior.
- Parallelism notes: P1 does **not** depend on P0. `partnerDisplayName` is
  already returned by `GET /users/me` at `BaseHead`
  (`../architecture/solution.md` §1 Key Discovery), so the mobile lane consumes
  already-available data. P0 hardens that contract against silent regression
  and is bound by an invariant not to rename, remove, or reshape the key, which
  is what makes concurrent execution safe. Write scopes are disjoint
  (`backend/src/modules/users/**` vs `mobile/lib/**` + `mobile/test/**`).

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|----------------------|-------|----------------|----------------|-----------------|
| `GET /users/me` `partnerDisplayName` | Backend Developer | P0 | P1 | `../architecture/contract-summary.md` sections 1-3 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Undeclared `/users/me` partner key | P0 |
| Response-shape narrowing | P0 |
| Fabricated partner name (AC3) | P1 |
| Combined-title overflow in the header row | P1 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `backend-api`: `backend`, startup smoke `NOT_APPLICABLE`, build command
    source runtime registry `buildCommand` (`npm run build`)
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, test command
    source runtime registry `testCommand` (`flutter test`)

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P0 | Backend Developer | Backend | None | YES | NOT_STARTED |
| P1 | Mobile Developer | Mobile | None | YES | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-users-me-partner-name-contract-lock.md` |
| P1 | `phase-P1-home-couple-title-partner-name.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- Both phases fit one specialist lifecycle (P0: 3 files, P1: 4 files) against
  the roughly-six source/test file cap; neither needs splitting.
- The two phases are separated by lane and deploy unit, not by shared files —
  their write scopes do not intersect.
- No trailing verification/testing phase exists; each phase owns its own
  targeted tests and build/type-check.

## 6. Notes

- The mobile lane is the only phase whose absence leaves the story's ACs
  unmet. If P0 must be deferred for any reason, the story still demos, and the
  deferral is a regression-protection gap to record — not an AC failure.
