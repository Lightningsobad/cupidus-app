# Master Coding Plan – STORY-002 Standardize VPS backend deploys onto GitHub Actions CI/CD

## 1. Planning Metadata

- Story ID: STORY-002 (REQ-005_production_domain_and_cicd_standardization)
- Complexity: complex
- OQ Constraints Source: `../requirements/requirements.md` `## Open Question Impact` (no scope BLOCKED)
- Requirement Configuration Guide impact: REQUIRED — new GitHub Actions secrets, a new GHCR registry dependency, and a changed VPS runtime file layout. Owning phase: **P2**.
- Input deviation: UX is WAIVED (no operator-facing UI surface); no `../ux/` artifact exists and no phase may require one.

## 2. Planning Goal

- Shared contract owner: DevOps Engineer (`../architecture/contract-summary.md`)
- Contract-first phase required: NO — one lane, one specialist, strictly sequential; the contract's in-story consumer (P2) is implemented by the same owner directly after P1.
- Parallel execution possible: NO
- Critical path: P1 → P2
- Parallelism notes: single DevOps lane end-to-end. P2 must not start before P1's VPS inspection output exists, because the deploy contract's shape (compose vs. systemd/PM2) is an assumption until then.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|----------------------|-------|----------------|----------------|-----------------|
| Backend deploy pipeline contract (secret names, VPS runtime layout, health gate, rollout order) | DevOps Engineer | P1 (runtime layout + image contract) | P2 (workflow + cutover); REQ-006 / REQ-007 inherit it | `../architecture/contract-summary.md` sections 2, 3, 4, 5 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| HEAD compose file is not runnable | P1 |
| Production data loss at cutover (AC6) | P1 (volume/state inventory) then P2 (cutover) |
| TypeORM `synchronize: true` mutating live schema (AC6) | P2 |
| Credential leakage / over-privileged access (AC4/AC5) | P1 (existence-only inspection) then P2 (placeholder secrets) |
| Partially-deployed / broken VPS after failed run (AC7) | P2 |
| Two competing deploy paths live (AC3) | P1 (mechanism inventory) then P2 (ordered cutover) |
| First-merge self-trigger | P2 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `backend-api`: `backend`, startup smoke `NOT_APPLICABLE` (no local runtime start in this story; the only readiness signal is the in-pipeline VPS health gate defined in `../architecture/contract-summary.md` section 4), command/source runtime registry `backend-api.buildCommand` = `npm run build`, `prodCommand` = `npm run start:prod`

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|-------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P1 | DevOps Engineer | DevOps | None | NO | `STORY-002/devops/vps-inspection.md`, `backend/Dockerfile`, `backend/docker-compose.prod.yml`, `coding-plan/test-results.md` | requirements AC1/AC5/AC6, solution.md §4 Investigation Findings + Contracts And Integrations, contract-summary.md §3 | Completed VPS inspection record, Firebase-key-free Dockerfile, runnable production compose overlay | `docker compose config` exit 0, local `docker build` of the runtime image, existence-only credential checks | NOT_STARTED |
| P2 | DevOps Engineer | DevOps | P1 | NO | `.github/workflows/deploy-backend.yml`, `.github/workflows/scripts/vps-deploy.sh`, `<REQ>/deployment/configuration-guide.md`, `STORY-002/devops/cutover-evidence.md`, `coding-plan/test-results.md` | P1 outputs, requirements AC2/AC3/AC4/AC7, solution.md §4 Contracts And Integrations + Risk Surfaces, contract-summary.md §2/§4/§5/§6 | Build-and-push + deploy-and-verify workflow, placeholder secret set, configuration guide update, ordered cutover with legacy decommission, negative rollback proof | Workflow static lint, `docker compose config` exit 0 in CI, health-gate poll observed, deliberate failing-image rollback test, post-cutover single-trigger re-inspection, `gh secret list` name-set check | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-vps-inspection-and-deploy-artifacts.md` |
| P2 | `phase-P2-actions-pipeline-cutover-and-rollback-proof.md` |

Artifact hygiene:

- Each phase id above maps to exactly one canonical `phase-Px-*.md` file; no duplicates exist.
- DevOps implementation phases fit one specialist lifecycle (roughly six source/test files max) or are split. P1 = 4 files, P2 = 5 files.
- No two phases are separated only because they would write the same file. P1 and P2 write disjoint files; the split is a real gate — the workflow may only be authored after AC1 confirms the deploy mechanism, and the cutover may only run after the workflow is on the production branch and has produced one verified green deploy.
- No standalone contract phase exists; the contract and its only in-story consumer share the owner and lane in sequence.
- No trailing verification/testing phase exists. The negative rollback test and post-cutover verification are inside P2's own `## 6. Test Scope`, because P2 also owns the AC3 decommissioning change they gate.
- Implementation phase test scopes contain no backend e2e/test_e2e, Playwright/browser e2e, mobile e2e, traces, scenario reruns, or local runtime startup smoke.

## 6. Notes

- Phase Overview column set follows the Tech Lead SKILL rule 14 schema (with `Write Scope`, `Primary Inputs`, `Planned Outputs`, `Test Scope`), which this story's completion gate requires. The narrower `master_plan_template.md` guidance that forbids those columns is overridden here by that gate.
- The merge that lands P2's workflow on `main` is itself the first production deploy. Schedule it as an observed run; do not let it happen as an incidental side effect of a routine merge.
- OID-1, OID-2, and OID-3 (`../architecture/solution.md` `### Open Implementation Decisions`) stay open through planning and are recorded with rationale during implementation.
