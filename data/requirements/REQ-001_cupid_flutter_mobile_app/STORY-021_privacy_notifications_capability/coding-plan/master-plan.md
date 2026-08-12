# Master Coding Plan – STORY-021 Privacy/Notifications Capability

## 1. Planning Metadata

- Story ID: STORY-021_privacy_notifications_capability
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes.

## 2. Planning Goal

- Shared contract owner: `AccountRepository` (mobile lane) for
  `PATCH /users/me {isGhostModeEnabled}`.
- Contract-first phase required: NO — the repository parameter's only in-story
  consumer is `privacy_screen.dart`, same specialist, same lane, in sequence.
  Folded into P1 per the contract-phase condition.
- Parallel execution possible: NO — single mobile lane, single phase.
- Critical path: P1.
- Parallelism notes: none.

## 3A. Risk Surface To Phase Mapping

> Authoritative risk table: `../architecture/solution.md` section 4.

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Two client writers of `isGhostModeEnabled` | P1 |
| AC3 device-local notification behavior | P1 |
| AC4 no admin/data-export affordance | P1 |
| Static tier cards must not hide behind a spinner | P1 |
| Stale view-only invariant in source | P1 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    `data/devops/system/runtime-command-registry.json` → `mobile-app`
    (`testCommand: flutter test`). Flutter is not on PATH here; resolve via
    `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter`.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-privacy-ghost-toggle.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- Mobile implementation phases must fit one specialist lifecycle (roughly six
  source/test files max) or be split; P1's sizing rationale is recorded in its
  `Phase Sizing` block.
- No trailing verification/testing phase exists; P1 owns its own tests and
  static-analysis gate.
- Implementation phase test scopes exclude e2e, Playwright, emulator/simulator
  lifecycle, signing, and runtime startup smoke.

## 6. Notes

- AC3 carries no implementation work by design. Its resolution is the AC3
  Feasibility Finding in `../architecture/solution.md` section 3; P1 only proves
  non-regression of the existing device-local screen.
