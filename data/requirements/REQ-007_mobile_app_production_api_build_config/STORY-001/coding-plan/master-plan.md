# Master Coding Plan – Production API Build Flavor For Mobile App

## 1. Planning Metadata

- Story ID: STORY-001 (REQ-007_mobile_app_production_api_build_config)
- Complexity: standard
- Requirement Configuration Guide impact: REQUIRED — the story introduces two
  build-time values (`CUPID_API_BASE_URL`, `CUPID_ENV`) and a second documented
  build invocation.
- Input deviation: `../ux/` is absent by design. Product Owner recorded UX Design
  as SKIPPED in `story_master.md` (build-time-only change, no new screens or UI
  states). Tech Lead planning surfaced no UI need, so the skip stands.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (`mobile/lib/core/config/cupid_api_config.dart`)
- Contract-first phase required: NO — single lane, and the same specialist writes
  the config surface and both of its in-story consumers back to back.
- Parallel execution possible: NO — one lane, one phase.
- Critical path: P1.
- Parallelism notes: none; splitting this story would separate a constant from
  its only call site.

## 3A. Risk Surface To Phase Mapping

> Authoritative risk table: `../architecture/solution.md` section 4
> (`Risk Surfaces And Source Of Truth`).

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Production origin resolution | P1 merged; requirement-level mobile runtime audit |
| Silent local-dev fallback | P1 |
| Local-dev build regression | P1 merged; requirement-level mobile runtime audit |
| Dual-transport origin leak | P1 merged; requirement-level mobile runtime audit |
| Build-time-only selection (AC5) | P1 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile` (Cupid Flutter app): `mobile`, startup smoke `NOT_APPLICABLE` for
    P1, command/source: Mobile Developer must resolve the exact
    `mobile` entry id and its `buildCommand` from
    `data/devops/system/runtime-command-registry.json` at execution time — this
    planning run was instructed not to read the registry, so the id is
    deliberately unresolved here rather than guessed.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|-------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | `mobile/lib/core/config/cupid_api_config.dart`, `mobile/lib/main.dart`, `mobile/test/core/config/cupid_api_config_test.dart`, `data/requirements/REQ-007_mobile_app_production_api_build_config/deployment/configuration-guide.md` | `../requirements/requirements.md` AC1–AC5; `../architecture/solution.md` sections 1, 4 | production/local build-time config surface, fail-fast startup guard, unit tests, requirement configuration guide | unit + `flutter analyze` + production-define and default `flutter build` type-check | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-production-api-build-config.md` |

Artifact hygiene:

- Each phase id above maps to exactly one canonical `phase-Px-*.md` file.
- P1 writes 4 source/test/doc files, well inside the roughly-six-file single
  specialist lifecycle cap; no split required.
- No trailing verification/testing phase exists. Emulator/simulator install-and-
  observe for AC3/AC4 is the requirement-level mobile runtime audit gate, not a
  phase.

## 6. Notes

- The `Write Scope`, `Primary Inputs`, `Planned Outputs`, and `Test Scope`
  columns in section 5 are present because `tech-lead/SKILL.md` Core Rule 14
  mandates them; `assets/master_plan_template.md` currently forbids the same four
  columns. The two are in conflict — see the Tech Lead report for the drift flag.
- `deployment/configuration-guide.md` sits outside this story directory. Scrum
  Master must include that path in the Mobile Developer handoff `WriteScope` or
  P1 cannot complete its assigned documentation output.
