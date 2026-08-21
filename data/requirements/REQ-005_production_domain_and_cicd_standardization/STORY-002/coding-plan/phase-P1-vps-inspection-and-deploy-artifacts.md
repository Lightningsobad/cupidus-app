# Phase P1 – VPS read-only inspection and deployable build artifacts

## 1. Objective

Complete AC1's VPS-side read-only inspection, then — using what it proves —
produce the two artifacts the pipeline will deploy: a `backend/Dockerfile` with
no baked Firebase credential, and a production compose overlay that
`docker compose config` accepts. Nothing in `.github/workflows/` is authored in
this phase.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-vps-inspection-and-deploy-artifacts.md`
- Owner: DevOps Engineer
- Lane: DevOps

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-002/devops/vps-inspection.md`
  - `backend/Dockerfile`
  - `backend/docker-compose.prod.yml`
  - `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-002/coding-plan/test-results.md`
- Impacted Runtime Service/App:
  - Name: `backend-api`
  - Runtime Registry Id: `backend-api`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: backend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `backend-api.buildCommand` (`npm run build`, executed inside the image build)
  - Startup Command Source: runtime registry `backend-api.prodCommand` (`npm run start:prod`)
  - Readiness Check: `GET /` on the container port (per `../architecture/solution.md` — no dedicated `/health` route exists and adding one is out of scope)
  - Port Contract: external on the VPS (existing published host port), internal-only in the compose network
- Shared Interfaces Produced:
  - Confirmed VPS runtime layout backing `../architecture/contract-summary.md` section 3
  - Image contract: Firebase key supplied at runtime as a bind mount to `/usr/src/app/service-account.json`, never a layer
- Shared Interfaces Consumed:
  - `../architecture/contract-summary.md` section 3 (VPS-side runtime layout)
- Risk Surfaces:
  - HEAD compose file is not runnable
  - Production data loss at cutover (AC6)
  - Credential leakage / over-privileged access (AC4/AC5)
  - Two competing deploy paths live (AC3)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` section 4 (`Investigation Findings`, required VPS-side inspection checklist)
  - consumer contract: `../architecture/contract-summary.md` section 3
- Primary Inputs Summary:
  - requirements: AC1, AC5, AC6 and `## Business Rules / Guardrails`
  - architecture: section 4 `Investigation Findings`, `Contracts And Integrations` (Firebase key relocation), `Risk Surfaces And Source Of Truth`
  - OQ constraints: `../requirements/requirements.md` `## Open Question Impact` — nothing BLOCKED; the SSH-key question is OID-1 and is decided in P2
  - upstream phase outputs: none
  - review findings: none yet
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO (P2 owns the single consolidated update)
  - Sections To Update: —
- Phase Sizing:
  - Behavior Slice: "know what actually runs on the VPS, and make the repo produce something deployable to it"
  - Source/Test File Count: 4
  - Split Required: NO
  - Split Rationale: one specialist lifecycle; the inspection has no standalone phase because it produces no code — it is folded into the phase that consumes it.

## 2. Required Reads

- `../requirements/requirements.md` (AC1, AC5, AC6, Business Rules)
- `../architecture/solution.md` section 4
- `../architecture/contract-summary.md` section 3
- `../requirements/requirements.md` `## Open Question Impact`

## 3. Tasks

1. Run the AC1 read-only VPS inspection over `root@84.247.140.178`, covering
   every item in the architecture's required checklist: what actually starts the
   process (compose project name and file path, or systemd unit, or PM2, or
   cron/manual script); the deployed compose file diffed against both repo
   copies; named volumes and bind mounts; whether `postgres`/`redis` are compose
   services, host packages, or external; existence and path (never contents) of
   `.env` and `service-account.json`; what terminates TLS for
   `api-cupid.tikup.me`; and any `authorized_keys` entry already present for
   GitHub Actions. Use only `ls`, `cat` of non-credential files, `docker ps`,
   `docker compose config`, `docker volume ls`, `systemctl status`, `crontab -l`.
   No writes, no Docker state changes.
2. Record the results in `STORY-002/devops/vps-inspection.md` as a table mirroring
   the architecture's Investigation Findings shape (Artifact | State on VPS |
   Consequence), plus a dated legacy-vhost/compose inventory for
   `api-cupid.tikup.me` (AC1 explicitly requires it). Record credential files as
   "present at `<path>`, shape `<key names only>`" — never a value.
3. Capture the AC6 pre-cutover baseline in the same file: `docker volume ls`
   output, the compose project name, bind-mount source paths, and a row count on
   at least one key table. This baseline is what P2's cutover is compared against.
4. Reconcile assumption A-1. If the inspection finds compose, continue. If it
   finds systemd/PM2/manual `node dist/main`, stop and escalate — the deploy
   contract changes shape and the architecture needs a revision pass before P2.
5. Edit `backend/Dockerfile`: remove `COPY service-account.json`. Change nothing
   else about the multi-stage build; `main.ts` resolves `../service-account.json`
   from `dist/`, so the runtime bind mount satisfies the existing `require` with
   no source change.
6. Author `backend/docker-compose.prod.yml` as the production overlay/file that
   the pipeline will deploy. It must declare the real dependency topology the
   inspection found (HEAD's `depends_on` vs. `profiles: ["legacy"]` mismatch is
   not deployable), bind-mount `service-account.json` and `.env` from the VPS
   deploy path read-only, reference the GHCR image by tag/digest rather than
   `build:`, and reuse the existing named volumes and compose project name
   verbatim.
7. Verify: `docker compose -f backend/docker-compose.prod.yml config` exits 0,
   and a local `docker build -f backend/Dockerfile backend/` succeeds without
   `service-account.json` present. Record both in `coding-plan/test-results.md`.
8. Record any OID-1 input the inspection produced (does an Actions-specific
   authorized key already exist and work?) in `vps-inspection.md` as evidence for
   P2's decision. Do not decide OID-1 here and do not generate or rotate a key.

## 4. Acceptance Criteria

- `STORY-002/devops/vps-inspection.md` exists and answers every checklist item,
  including the `api-cupid.tikup.me` legacy vhost/compose inventory (AC1).
- No credential value appears in the inspection record, in any command output
  pasted into it, or in any committed file.
- No write, no `docker` state change, and no key generation or rotation occurred
  on the VPS during this phase.
- `backend/Dockerfile` contains no `COPY service-account.json` and builds
  successfully without that file on disk.
- `backend/docker-compose.prod.yml` exits 0 under `docker compose config` and
  reuses the existing volume names and compose project name unchanged.
- `backend/nginx/default.conf` and everything under `backend/src/` are untouched.

## 5. Planned Outputs

- Code directories or files: `backend/Dockerfile`, `backend/docker-compose.prod.yml`
- Contracts or schemas: confirmed VPS runtime layout backing `../architecture/contract-summary.md` section 3
- Requirement configuration guide updates: none (P2 owns them)
- Notes or evidence: `STORY-002/devops/vps-inspection.md`, `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Docker build + compose validation, local; read-only remote inspection
- Required levels:
  - backend build/type-check: `docker build -f backend/Dockerfile backend/` (runs the registry `buildCommand` inside the image build)
- Required checks:
  - `docker compose -f backend/docker-compose.prod.yml config` exits 0
  - image build succeeds with no `service-account.json` on the build context
  - `grep` of the final Dockerfile shows no credential `COPY`
  - inspection record contains no credential value (self-review before commit)
- Minimum gates by risk surface:
  - HEAD compose file is not runnable → `docker compose config` exit 0; blocker `COMPOSE_INVALID`
  - Production data loss at cutover (AC6) → volume/bind-mount/row-count baseline captured; blocker `DEPLOY_STATE_UNVERIFIED`
  - Credential leakage (AC4/AC5) → existence-only evidence; blocker `SECRETS_UNPROVISIONED` if a value would have to be read
- Evidence format: command + exit code + trimmed output in `coding-plan/test-results.md`, with credential-bearing lines redacted at capture time
- Verification strategy:
  - Targeted checks: compose config validation, image build
  - Build command when required: `docker build -f backend/Dockerfile backend/`
  - Required assertion evidence: both commands' exit codes recorded

## 7. Stop-And-Ask Rules

- Stop if the inspection contradicts assumption A-1 (no Docker Compose on the
  VPS). The deploy contract's shape changes; escalate for an architecture
  revision instead of improvising a systemd/PM2 pipeline.
- Stop if the live compose project name or volume names cannot be captured
  read-only (`DEPLOY_STATE_UNVERIFIED`). Do not proceed toward cutover on a
  guessed inventory.
- Never read, echo, copy, paste, or commit any credential **value** found on the
  VPS — not the `.env` body, not `service-account.json`, not a private key.
  Record existence, path, and key names only.
- Do not generate or rotate an SSH key. AC5 permits it only after an existing
  authorized key is demonstrated broken, and that decision belongs to P2.
- Do not write `backend/nginx/default.conf` — STORY-001 owns it, and writing it
  here creates an integration-branch conflict.
- Do not modify anything under `backend/src/`.
- Do not run `docker system prune`, `docker compose down -v`, or any volume
  removal on the VPS at any point.

## 8. Status

- Status: NOT_STARTED
- Last updated: 2026-08-21
