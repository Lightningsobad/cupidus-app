# System DevOps Memory

## 1. Metadata

- Status: Bootstrap
- Last Updated: 2026-07-29
- Updated By: devops (system-foundation mode)
- Related Inputs Reviewed: `data/intake/bootstrap/bootstrap_master.md`, `data/intake/bootstrap/source_register.md`, `data/intake/bootstrap/business_context.md`, `data/intake/bootstrap/technical_context.md`, `data/intake/bootstrap/conflicts_open_questions.md`, `data/requirements/master_requirements_list.md`, `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`, `backend/Dockerfile`, `backend/docker-compose.yml`, `backend/nginx/default.conf`, `backend/package.json`, `backend/src/main.ts`

## 2. Environment Matrix

| Environment | Exists | Deployment Trigger | Deployment Method | Verification Method | Rollback / Recovery | Required User Inputs / Secrets | Required Setup Steps | Confirmation Status | Notes |
|-------------|--------|--------------------|-------------------|---------------------|---------------------|-------------------------------|----------------------|---------------------|-------|
| development-local | NO | automatic after requirement DONE, once entrypoints exist and pass verification | repo-root `scripts/start-dev.sh` over Docker Compose (Postgres, Redis) + Node backend + Flutter mobile app | registry-backed readiness probe against `backend-api` (e.g. `/api-docs-json`) and `mobile-app` build/run check | idempotent rerun of `scripts/setup.sh` / `docker compose down && up` once scripts exist | `backend/service-account.json` (Firebase Admin credential) | initial repo-root git commit (Scrum Master-owned); Flutter mobile scaffold at `mobile/` (mobile-dev-owned, ADR-009); root scripts + runtime registry (devops-owned, `local-environment-scripts-update` / `runtime-registry-update` mode — not built in this pass) | pending | Two runnable surfaces: `backend-api` (adopt existing `backend/`, needs multi-project-safety remediation — see §3) and `mobile-app` (not yet scaffolded) |
| staging | NO | direct instruction only | undetermined — no staging target confirmed | n/a | n/a | undetermined | VPS stack confirmation gate (skill rule 8a) if a VPS is chosen | pending | `backend/docker-compose.yml` + `backend/nginx/default.conf` (server_name `api-cupid.tikup.me`) look like a pre-existing VPS-oriented artifact, not a local-dev compose file. This is NOT adopted as a confirmed staging/production target — see §4/§7 |
| production | NO | direct instruction only | undetermined — no production target confirmed | n/a | n/a | undetermined | same VPS stack confirmation gate as staging | pending | Same ambiguity as staging; must not be inferred from the existing nginx/compose artifact without explicit user confirmation |

## 3. Development-Local Policy

- Current machine expectation: a single developer machine that may run several generated projects concurrently, so local infrastructure must be multi-project safe.
- Deploy entrypoint: `scripts/start-dev.sh` (not yet created — deferred to `local-environment-scripts-update` mode; out of scope for this `system-foundation` pass by explicit handoff instruction).
- Required local dependencies or services: Postgres 16, Redis 7 (per `backend/docker-compose.yml`), Node 22 (backend build/run), Flutter SDK + Android/iOS toolchains (mobile, once `mobile/` is scaffolded), Docker/Compose.
- Local Compose project naming: **`backend/docker-compose.yml` as authored is NOT multi-project safe.** It uses fixed `container_name` values (`cupid-postgres`, `cupid-redis`, `cupid-backend`, `cupid-nginx`) and fixed host port bindings (`5432:5432`, `6379:6379`, `3000:3000`, `80:80`) that will collide with any other generated project — or any pre-existing local Postgres/Redis — on the same machine, regardless of Compose project name used at invocation time, because `container_name` overrides project-scoped naming. When `local-environment-scripts-update` mode builds the real local entrypoints, it must remediate this by: setting a project-specific `COMPOSE_PROJECT_NAME` (derived from the repo/project identifier), dropping the fixed `container_name` overrides (or deriving them from the project identifier), and excluding the `nginx` service from the local-dev Compose path entirely — that service is bound to the external domain `api-cupid.tikup.me`, which is a production/VPS concern, not a local-dev concern.
- Dependency host port policy: Postgres and Redis must be internal-only by default (Compose DNS `postgres`/`redis`, no published host ports). Only the backend app's own port should be published, bound to `127.0.0.1` at a per-project configurable value (for example `127.0.0.1:${BACKEND_HOST_PORT:-3000}:3000`), not the fixed `5432:5432` / `6379:6379` bindings currently in the file.
- Project-local port config path: not yet created — to be established by `local-environment-scripts-update` mode (e.g. a project-local `.env` consumed by `scripts/setup.sh` / `scripts/start-dev.sh`).
- Smoke or verification expectation: once the runtime registry exists, `backend-api` readiness should be a Swagger/JSON probe (e.g. `GET /api-docs-json` returns 200); `mobile-app` readiness is a successful `flutter build`/`flutter run` against the vendored OpenAPI spec (ADR-009), not a live backend dependency, since the backend cannot boot without a real `service-account.json`.
- Common recovery or rerun notes: `scripts/setup.sh` must converge local infrastructure idempotently (safe to rerun without duplicating containers/volumes) once it is built.

## 3.1 Local Environment Scripts

| Script | Required | Purpose | Hook / Guard Status | Verification Status | Last Verified | Blocker |
|--------|----------|---------|---------------------|---------------------|---------------|---------|
| `scripts/setup.sh` | YES | Local infrastructure setup: Docker/Compose containers, volumes, dependency services, readiness waits | missing | not run | | Deferred to `local-environment-scripts-update` mode per this handoff's explicit scope; also blocked on `mobile/` scaffold not existing yet and on zero repo-root git commits |
| `scripts/build.sh` | YES | Dependency installation and build for all project components | missing | not run | | same as above |
| `scripts/start-dev.sh` | YES | Local dev startup for all required modules with infra checks and watch/dev mode | missing | not run | | same as above |
| `scripts/start-prod.sh` | YES | Production-mode startup from built artifacts or production commands | missing | not run | | same as above; production-mode start additionally requires direct user instruction before execution |

- Script contract source: `.agents/skills/devops/references/local-environment-scripts.md`
- Required script checks: strict Bash mode, error trap, preflight checks, readiness verification, cleanup/shutdown handling where applicable
- Multi-project safety checks: project-specific Compose naming, no fixed local dependency host port bindings, internal dependency networking by default, per-project loopback host ports when required — see §3 remediation notes for `backend/docker-compose.yml`

## 3.2 Runtime Command Registry

- Registry path: `data/devops/system/runtime-command-registry.json`
- Registry owner: DevOps
- Registry status: missing (not created in this `system-foundation` pass — deferred to `runtime-registry-update` / `runnable-foundation-verify` mode once the mobile scaffold exists)
- Runtime ids anticipated:
  - `backend-api`: NestJS service at `backend/`, build `npm run build`, dev `npm run start:dev`, prod `npm run start:prod`, readiness `GET /api-docs-json`, required env includes `PORT` (default 3000), `POSTGRES_*`, `REDIS_*`, and the `backend/service-account.json` credential file
  - `mobile-app`: Flutter app at `mobile/` (ADR-009, not yet scaffolded — cannot register a real command until `mobile-dev` creates the project)
- Registry update rule: when Bug Fixer reports `BLOCKER: START_COMMAND_UNKNOWN`, DevOps must add or correct the impacted runtime entry before Scrum Master resumes bugfix work.

## 4. Staging Policy

- Exists: NO
- Deploy model: undetermined. `backend/docker-compose.yml` (fixed prod-style ports) plus `backend/nginx/default.conf` (`server_name api-cupid.tikup.me`) suggest a previously intended VPS deployment target, but this repository has no confirmed staging environment and no record of who owns `api-cupid.tikup.me`. This artifact must not be silently adopted as the staging target.
- Access or approval model: direct-instruction-only; if a VPS is chosen, the `vps-deployment` mode's stack confirmation gate (skill rule 8a) applies before any infrastructure choice is assumed.
- Required user-provided inputs or external setup: VPS host/access details, confirmation of `api-cupid.tikup.me` DNS ownership (or a different target), TLS/cert strategy, remote secret handling for `service-account.json`, database/cache hosting decision.
- Verification or rollback expectations: undefined until the user explicitly requests staging/VPS deployment and confirms the stack.

## 5. Production Policy

- Exists: NO
- Deploy model: undetermined, same ambiguity as staging (§4).
- Access or approval model: direct-instruction-only; production start additionally requires explicit approval per skill rule 8.
- Required user-provided inputs or external setup: same category as staging — VPS/hosting decision, DNS/TLS, secret store, migration/backup posture — none confirmed yet.
- Verification or rollback expectations: undefined until the user explicitly requests production deployment and confirms the stack.

## 6. Shared Deployment Rules

- Direct-instruction-only environments: staging, production, and any VPS deployment target.
- Automatic post-requirement local deployment rule: once `development-local` scripts and the runtime registry exist and pass verification, local deployment runs automatically after a requirement reaches `DONE` (skill rule 7). This is **not active today** because the scripts and registry do not exist yet.
- Requirement-level configuration guide path: `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` (not yet created; created only when configuration/setup guidance is required for the requirement).
- Secrets and configuration ownership: `backend/service-account.json` (Firebase Admin SDK credential, loaded via hardcoded `require('../service-account.json')` in `backend/src/main.ts`) is a required local secret the user must supply directly under `backend/`; no agent may generate, guess, or commit this value. `POSTGRES_USER`/`POSTGRES_PASSWORD`/`POSTGRES_DB` and Redis in `backend/docker-compose.yml` currently default to placeholder local values (`postgres`/`password`/`cupid`) — acceptable for local-only use, must never be reused for staging/production. No staging/production secret store has been decided.
- Observability and operational readiness expectations: none configured yet; no logging/metrics/tracing stack decided. Swagger UI (`/api-docs`) is the only current API-contract observability surface.
- Release and rollback posture: none defined for staging/production yet. Local rollback, once scripts exist, is idempotent `scripts/setup.sh` rerun / `docker compose down && up` recreation.

## 7. User Confirmation Gate

- Final confirmation required: YES
- Items the user must confirm:
  - Accept the `development-local` environment matrix above and the multi-project-safety remediation plan for `backend/docker-compose.yml` (project-scoped Compose naming, drop fixed container names, internal-only Postgres/Redis, exclude the `nginx` service from local dev).
  - Confirm `staging` and `production` remain direct-instruction-only with no environment currently created.
  - Confirm whether the existing `backend/nginx/default.conf` (`api-cupid.tikup.me`) represents a real, currently-owned VPS target for a future `Deploy lên VPS` request, or should be treated as legacy/unused and ignored by DevOps going forward.
  - Acknowledge that `backend/service-account.json` must be supplied manually by the user before any backend runtime start (local or remote) — DevOps cannot generate or infer this credential.
- Items the user must provide or set up:
  - `backend/service-account.json` (Firebase Admin credential).
  - Flutter SDK and Android/iOS toolchains on the local dev machine, once the `mobile/` scaffold exists.
  - VPS access details, only if/when a VPS deployment is explicitly requested.
- Confirmation status: pending
- Notes: Repository root currently has **zero git commits** (`data/intake/bootstrap/bootstrap_master.md` Git Safety Note). An initial commit is a prerequisite this DevOps memory depends on for `git-story-boundary.sh` tooling; it is owned by Scrum Master as part of the Runnable Project Foundation gate and is not performed by DevOps in this pass. Root scripts and the runtime command registry are intentionally not built in this `system-foundation` pass — they are the `local-environment-scripts-update` / `runtime-registry-update` follow-on, to be delegated after this memory exists and after the `mobile/` scaffold is created.
