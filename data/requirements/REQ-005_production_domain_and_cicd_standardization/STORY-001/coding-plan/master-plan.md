# Master Coding Plan – Point api.cupidus.app at the production backend API

## 1. Planning Metadata

- Story ID: STORY-001
- Complexity: standard
- OQ Constraints Source: `../architecture/solution.md` section 3
  (`Open Question Constraints`)
- Requirement Configuration Guide impact: REQUIRED — this story introduces a
  Cloudflare API credential, an origin certificate with an expiry, and a new
  published port; all three need a documented owner and renewal path.
- Input deviation: UX is WAIVED per `../story_master.md` — infrastructure/DNS
  routing change with no operator-facing UI surface.

## 2. Planning Goal

- Shared contract owner: DevOps Engineer (`../architecture/contract-summary.md`)
- Contract-first phase required: NO — the contract this story publishes is a
  production hostname. Its only consumers are REQ-006 and REQ-007, which are
  separate requirements; there is no in-story consumer phase to unblock, so a
  standalone contract phase would produce nothing another phase waits on.
- Parallel execution possible: NO — single lane, single phase.
- Critical path: P1.
- Parallelism notes: none. The ordering that matters is *inside* P1 (origin
  certificate and 443 listener must be serving before the zone SSL mode is
  raised to Full (strict)); that ordering is a task sequence for one specialist,
  not a phase boundary.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|----------------------|-------|----------------|----------------|-----------------|
| Production API base URL `https://api.cupidus.app` | DevOps Engineer | P1 | none in this story (REQ-006 web, REQ-007 mobile) | `../architecture/contract-summary.md` sections 1-3 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `backend-api`: `backend`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry id `backend-api` in
    `data/devops/system/runtime-command-registry.json`. This story changes the
    nginx edge in front of the service, not the service itself; verification is
    an endpoint/certificate check against the deployed host, not a local
    dev-server startup.

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|-------|-------|------|------------|----------------|-------------|----------------|-----------------|------------|--------|
| P1 | DevOps Engineer | DevOps | None | NO | `backend/nginx/`, `backend/docker-compose.yml`, `scripts/cloudflare/`, `deployment/configuration-guide.md`, `.gitignore` | `../requirements/requirements.md` (AC1-AC5); `../architecture/solution.md` sections 1, 4 | Origin CA cert provisioning script; scripted idempotent DNS record; `api.cupidus.app` TLS vhost on 443; 443 publish + cert volume; configuration guide | `nginx -t` config validation; DNS resolution check; origin `openssl s_client` cert check; `curl https://api.cupidus.app` backend response; `git status` clean of key material | NOT_STARTED |

> Note: this plan carries the `Write Scope` / `Primary Inputs` / `Planned
> Outputs` / `Test Scope` columns because the Tech Lead skill rule 14 and this
> story's handoff completion gate both require them. The bundled
> `master_plan_template.md` currently instructs the opposite ("Do not add
> `Write Scope`, `Primary Inputs`, `Planned Outputs`, or `Test Scope`
> columns"). That contradiction is real and is flagged for the Scrum Master;
> the enforced gate wins here. The phase file remains the authoritative
> detail — these cells are routing summaries, not a second source of truth.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-api-hostname-tls-edge.md` |

Artifact hygiene:

- Each phase id in the table above maps to exactly one canonical
  `phase-Px-*.md` file.
- Do not leave duplicate files for the same phase id.
- Implementation phases must fit one specialist lifecycle (roughly six
  source/test files max) or be split. P1 writes five files and is not split.
- No two phases are separated only because they would write the same file, and
  no phase repeats a sibling phase's pattern for another variant of the same
  behavior cluster while both fit one lifecycle.
- No standalone contract phase exists when the same specialist implements the
  contract and all of its in-story consumers in sequence in one lane.
- No trailing verification/testing phase exists; P1 owns its own checks.
- Implementation phase test scopes must not include backend e2e/test_e2e,
  Playwright/browser e2e, traces, or scenario reruns.

## 6. Notes

- Rollback for P1 is not a plain revert of the repository diff: the Cloudflare
  zone SSL mode and the DNS record are external state. If P1 must be backed
  out, lower the SSL mode before reverting the nginx change, otherwise the
  origin stops presenting a certificate while the edge still requires one and
  the host returns 526.
