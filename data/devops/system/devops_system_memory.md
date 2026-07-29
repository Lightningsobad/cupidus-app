# System DevOps Memory

## 1. Metadata

- Status: Bootstrap
- Last Updated: 2026-07-29
- Updated By: devops (local-environment-scripts-update mode)
- Related Inputs Reviewed: `data/intake/bootstrap/bootstrap_master.md`, `data/intake/bootstrap/source_register.md`, `data/intake/bootstrap/business_context.md`, `data/intake/bootstrap/technical_context.md`, `data/intake/bootstrap/conflicts_open_questions.md`, `data/requirements/master_requirements_list.md`, `data/requirements/REQ-001_cupid_flutter_mobile_app/req_master.md`, `backend/Dockerfile`, `backend/docker-compose.yml`, `backend/nginx/default.conf`, `backend/package.json`, `backend/src/main.ts`, `backend/src/app.module.ts`, `mobile/pubspec.yaml`

## 2. Environment Matrix

| Environment | Exists | Deployment Trigger | Deployment Method | Verification Method | Rollback / Recovery | Required User Inputs / Secrets | Required Setup Steps | Confirmation Status | Notes |
|-------------|--------|--------------------|-------------------|---------------------|---------------------|-------------------------------|----------------------|---------------------|-------|
| development-local | YES | automatic after requirement DONE, once entrypoints exist and pass verification | repo-root `scripts/start-dev.sh` over Docker Compose (Postgres, Redis, loopback-only) + host Node backend (`npm run start:dev`) + Flutter mobile app | registry-backed readiness probe against `backend-api` (`GET /api-docs-json`, verified live) and `mobile-app` (`flutter test` widget-test signal, verified live) | idempotent rerun of `scripts/setup.sh` / `docker compose down && up` (verified idempotent) | `backend/service-account.json` (Firebase Admin credential) | root scripts + runtime registry built and live-verified this pass (`local-environment-scripts-update` mode) | confirmed by live verification (see §3/§3.1) | Two runnable surfaces, both live-verified: `backend-api` (`backend/`, multi-project-safety remediation applied — see §3) and `mobile-app` (`mobile/`, ADR-009 scaffold) |
| staging | NO | direct instruction only | undetermined — no staging target confirmed | n/a | n/a | undetermined | VPS stack confirmation gate (skill rule 8a) if a VPS is chosen | pending | `backend/docker-compose.yml` + `backend/nginx/default.conf` (server_name `api-cupid.tikup.me`) look like a pre-existing VPS-oriented artifact, not a local-dev compose file. This is NOT adopted as a confirmed staging/production target — see §4/§7 |
| production | NO | direct instruction only | undetermined — no production target confirmed | n/a | n/a | undetermined | same VPS stack confirmation gate as staging | pending | Same ambiguity as staging; must not be inferred from the existing nginx/compose artifact without explicit user confirmation |

## 3. Development-Local Policy

- Current machine expectation: a single developer machine that may run several generated projects concurrently, so local infrastructure must be multi-project safe. Confirmed live on this machine: ports 5432 and 3000 were already occupied by other local projects/processes at verification time, and the resolution logic below handled both without collision.
- Deploy entrypoint: `scripts/start-dev.sh`, live-verified.
- Required local dependencies or services: Postgres 16, Redis 7 (per `backend/docker-compose.yml`), Node 20/22 (backend build/run; verified against host Node 20.20.2), Flutter SDK + Android/iOS toolchains (mobile, `mobile/` scaffold present), Docker/Compose (verified: Docker 29.4.0, Compose v5.1.2).
- Local Compose project naming: remediation applied to `backend/docker-compose.yml`. `COMPOSE_PROJECT_NAME` is derived from the repo directory name (`cupid-apps`) by `scripts/lib/common.sh` `compose_project_name()` and persisted to the project-local `.env`; fixed `container_name` overrides were removed (containers are now `cupid-apps-postgres-1` / `cupid-apps-redis-1`, verified live); the `nginx` service (bound to `api-cupid.tikup.me`) was moved behind `profiles: ["vps"]` so it is excluded from the default local-dev Compose path and only starts with `docker compose --profile vps up`.
- Dependency host port policy: Postgres and Redis are published to `127.0.0.1` only, on non-fixed configurable ports (`POSTGRES_HOST_PORT` default `15432`, `REDIS_HOST_PORT` default `16379`, no more `5432:5432`/`6379:6379`) — host-loopback access is required because the backend runs directly on the host (`npm run start:dev`) in dev mode, not inside Compose, so it must reach Postgres/Redis via a host port; `scripts/setup.sh` auto-resolves to the next free port when the default is busy and persists the resolution. The backend's own port (`BACKEND_HOST_PORT`, default `3000`) is also configurable and auto-resolved the same way — verified live: default `3000` was already occupied by an unrelated local process, and `scripts/setup.sh` auto-resolved to `3004` without any manual intervention.
- Project-local port config path: repo-root `.env` (gitignored via the existing `*.env` pattern), created/upserted idempotently by `scripts/setup.sh` via `env_get`/`env_set` in `scripts/lib/common.sh`. Holds `COMPOSE_PROJECT_NAME`, `POSTGRES_USER`/`PASSWORD`/`DB`, `POSTGRES_HOST_PORT`, `REDIS_HOST_PORT`, `BACKEND_HOST_PORT`.
- Smoke or verification expectation: `backend-api` readiness is a live Swagger/JSON probe (`GET /api-docs-json` returns 200) — verified against a real `npm run start:dev` process; `mobile-app` readiness is `flutter test` exercising the `Key('home_screen_ready_signal')` widget test — verified live (1/1 pass), not a live backend dependency.
- Common recovery or rerun notes: `scripts/setup.sh` verified idempotent (rerun against already-running containers reused them, no duplication, same resolved ports).

## 3.1 Local Environment Scripts

| Script | Required | Purpose | Hook / Guard Status | Verification Status | Last Verified | Blocker |
|--------|----------|---------|---------------------|---------------------|---------------|---------|
| `scripts/setup.sh` | YES | Local infrastructure setup: Docker/Compose containers, volumes, dependency services, readiness waits | present, executable | executed live twice (initial bring-up + idempotent rerun), both passed | 2026-07-29 | none |
| `scripts/build.sh` | YES | Dependency installation and build for all project components | present, executable | executed live: `npm ci` + `nest build` (backend), `flutter pub get` + `flutter build apk --debug` (mobile, real APK produced) | 2026-07-29 | none |
| `scripts/start-dev.sh` | YES | Local dev startup for all required modules with infra checks and watch/dev mode | present, executable | executed live with bounded timeout: infra up, backend reached `/api-docs-json` 200, mobile `flutter test` 1/1 pass, controlled shutdown via trap on timeout signal confirmed clean | 2026-07-29 | none |
| `scripts/start-prod.sh` | YES | Production-mode startup from built artifacts or production commands | present, executable | executed live with bounded timeout (local production-mode only, not a staging/production deploy): backend built, started with `NODE_ENV=production`, reached `/api-docs-json` 200, controlled shutdown confirmed clean | 2026-07-29 | none — note: any real staging/production (VPS) deployment remains direct-instruction-only per §4/§5, unaffected by this local smoke |

- Script contract source: `.agents/skills/devops/references/local-environment-scripts.md`
- Shared helper library: `scripts/lib/common.sh` (logging, error trap, `.env` get/set, free-port resolution, `docker compose` wrapper, `flutter_bin()` resolution, `wait_for` readiness polling) — sourced by all four scripts to avoid duplicating this logic.
- Required script checks: strict Bash mode, error trap, preflight checks, readiness verification, cleanup/shutdown handling where applicable — all present and live-verified.
- Multi-project safety checks: project-specific Compose naming, no fixed local dependency host port bindings, internal dependency networking by default, per-project loopback host ports when required — applied and live-verified against real port collisions on this machine (see §3).
- `shellcheck` was not available in this environment; verification relied on `bash -n` syntax checks (all four scripts + the shared lib passed) plus live execution of every script.
- Flutter SDK resolution: `flutter` is not on PATH on this machine; `scripts/lib/common.sh` `flutter_bin()` resolves PATH first, then `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter` (matches this machine's actual install at `/Users/alantravala/flutter`), overridable via `FLUTTER_SDK_PATH`. Verified live in `build.sh` and `start-dev.sh`.

## 3.2 Runtime Command Registry

- Registry path: `data/devops/system/runtime-command-registry.json`
- Registry owner: DevOps
- Registry status: created and populated with both runtime ids.
- Runtime ids:
  - `backend-api`: NestJS service at `backend/`, build `npm run build`, dev `npm run start:dev`, prod `npm run start:prod`, readiness `GET /api-docs-json` (verified live, 200), required env `PORT`/`POSTGRES_HOST`/`POSTGRES_PORT`/`POSTGRES_USER`/`POSTGRES_PASSWORD`/`POSTGRES_DB`, required secret `backend/service-account.json`. Runs on the host directly in `start-dev.sh`/`start-prod.sh`, not via the `backend` Compose service, so watch mode works and the Firebase secret is never baked into a local Docker image build.
  - `mobile-app`: Flutter app at `mobile/`, install `flutter pub get`, build `flutter build apk --debug` (verified live), test `flutter test`, readiness type `widget-test` on `Key('home_screen_ready_signal')` in `mobile/lib/features/home/presentation/home_screen.dart` (verified live, 1/1 pass) — not an HTTP probe. Launching the app itself (`flutter run`) needs a connected device/emulator and stays interactive/manual.
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
  - Accept the `development-local` environment matrix above; the multi-project-safety remediation for `backend/docker-compose.yml` is now applied and live-verified (project-scoped Compose naming, dropped fixed container names, loopback-only non-fixed Postgres/Redis/backend ports, `nginx` excluded from local dev via `profiles: ["vps"]`).
  - Confirm `staging` and `production` remain direct-instruction-only with no environment currently created.
  - Confirm whether the existing `backend/nginx/default.conf` (`api-cupid.tikup.me`) represents a real, currently-owned VPS target for a future `Deploy lên VPS` request, or should be treated as legacy/unused and ignored by DevOps going forward.
  - Acknowledge that `backend/service-account.json` must be supplied manually by the user before any backend runtime start (local or remote) — DevOps cannot generate or infer this credential.
  - **Security note for user decision (not a DevOps action):** `backend/service-account.json` already exists in this working tree with real, live Firebase Admin private key material (project `gen-lang-client-0644970375`). The bootstrap checkpoint also notes the original nested `backend/.git` history (backed up to `/tmp/cupid-backend-nested-git-backup-20260729`) had a commit message suggesting this credential was committed there too. Given it is in cleartext on disk and possibly in prior git history, rotating this Firebase Admin key is worth the user's consideration. DevOps did not generate, copy, or persist this key anywhere; it was only used via existence checks (`test -f`) in the scripts.
- Items the user must provide or set up:
  - `backend/service-account.json` (Firebase Admin credential) — already present locally on this machine; confirmed working via live `scripts/start-dev.sh`/`scripts/start-prod.sh` runs.
  - Flutter SDK and Android/iOS toolchains on the local dev machine — confirmed present (`/Users/alantravala/flutter`, not on PATH, handled via `FLUTTER_SDK_PATH` resolution in `scripts/lib/common.sh`).
  - VPS access details, only if/when a VPS deployment is explicitly requested.
- Confirmation status: CONFIRMED by user 2026-07-29. Development-local baseline accepted; staging/production remain direct-instruction-only; `api-cupid.tikup.me` kept as future VPS reference only; user will supply `backend/service-account.json` manually; user will rotate the exposed Firebase Admin key later, on their own.
- Notes: Root scripts (`scripts/setup.sh`, `build.sh`, `start-dev.sh`, `start-prod.sh`), the shared `scripts/lib/common.sh` helper, and `data/devops/system/runtime-command-registry.json` were built and live-verified in the `local-environment-scripts-update` pass (2026-07-29) — see §3/§3.1/§3.2 for full verification evidence.
