# Master Coding Plan – Anti-Ghosting `publicCountdown` Setting

## 1. Planning Metadata

- Story ID: STORY-053_antighost_public_countdown_penalty_hardening
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no new env var,
  secret, port, or deploy step; the column is created by the existing
  `synchronize: true` boot path.

## 2. Planning Goal

- Shared contract owner: Tech Lead (`../architecture/contract-summary.md`)
- Contract-first phase required: NO — the contract is a single additive field
  whose producer (P1, backend) and consumer (P2, mobile) each own it inside
  their own lane. No third phase would have anything left to write.
- Parallel execution possible: YES
- Critical path: neither. P1 and P2 are both leaves; the story completes when
  the slower of the two lands.
- Parallelism notes: P1 and P2 write disjoint trees (`backend/src/**` vs
  `mobile/**`) with zero shared files. The field name and default are frozen in
  `../architecture/contract-summary.md` before either phase starts, and P2's
  `?? true` tolerant read removes deploy-order coupling in both directions
  (contract summary section 5). P2's tests use a fake `HttpClientAdapter` and
  P1's spec mocks the TypeORM repository, so neither phase needs the other's
  runtime.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|----------------------|-------|----------------|----------------|-----------------|
| `publicCountdown` on the `GhostConfig` wire record | Tech Lead | P1 | P2 | `../architecture/contract-summary.md` sections 1-5 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Service drops submitted value | P1 |
| Missing field crashes settings screen | P2 |
| Regression in `_PenaltyRadioGroup` (AC5) | P2 |
| l10n keys absent from generated Dart | P2 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `backend-api`: `backend`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `backend-api.buildCommand` (`npm run build`)
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `mobile-app.testCommand` (`flutter test`)

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Backend Developer | Backend | None | YES | DONE |
| P2 | Mobile Developer | Mobile | None | YES | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-backend-public-countdown-field.md` |
| P2 | `phase-P2-mobile-public-countdown-row.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- Backend/mobile implementation phases must fit one specialist lifecycle
  (roughly six source/test files max) or be split. P1 is 4 files. P2 is 8
  hand-authored files of which three are single-line/single-entry edits; its
  `Phase Sizing` block records why it is not split.
- No two phases are separated only because they would write the same file.
- No standalone contract phase exists — the same specialist owns the contract
  and all of its in-lane consumers in each of P1 and P2.
- No trailing verification/testing phase exists; each phase owns its own
  targeted tests and build/type-check.

## 6. Notes

- P2 carries the RWB-20260816-019 fold-in (AC6). It is a one-value edit in a
  file P2 already opens for the new keys and must not be deferred to a follow-up
  — Scrum Master verifies it as part of this story's DONE gate.
