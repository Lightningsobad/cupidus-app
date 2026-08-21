# STORY-002 Standardize VPS backend deploys onto GitHub Actions CI/CD — solution.md

## 0. Metadata

- Complexity: complex
- Date: 2026-08-21

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: replace an undocumented tribal-knowledge deploy path
  with one auditable pipeline (AC2/AC3); never take the production API down or
  lose data during cutover (AC6/AC7); never let a real VPS credential enter the
  repository or CI (AC4/AC5).
- Architectural invariants / non-goals:
  - I-1: CI builds, the VPS only pulls. No `git` checkout and no image build
    ever runs on the VPS. A build that fails must fail on the runner, before
    anything on the VPS is touched.
  - I-2: The previously-running container keeps serving until a replacement
    passes a health gate. Deploy is promote-after-health, never
    stop-then-start.
  - I-3: Exactly one deploy path is live at the end of the story. Cutover is
    ordered: Actions proven green first, legacy path decommissioned second.
  - I-4: No real credential value is read from the VPS, guessed, or committed.
    Every pipeline credential is a GitHub Actions secret created with a
    placeholder body; the user populates real values.
  - I-5: Non-goal — no backend application/business-logic change, no
    `api.cupidus.app` DNS/TLS/vhost work (STORY-001 owns that), no dependency
    service topology change.

### Key Discovery

Read-only inspection of the repository (see section 4, Investigation Findings)
contradicts the premise that the current VPS deploy is merely *undocumented*.
It is **already broken at HEAD**, in three independent ways, and each one turns
a naive "wire up Actions and push" into an outage:

1. `backend/docker-compose.yml` moved `postgres` and `redis` to
   `profiles: ["legacy"]` during the devstack migration, but the `backend`
   service still declares `depends_on: [postgres, redis]`. A plain
   `docker compose up -d` from HEAD on the VPS does not start a
   profile-disabled dependency — it errors out. Whatever runs on the VPS today
   is therefore an **older compose file than HEAD**, and the delta is a
   dependency-topology change, not a cosmetic one. The pipeline cannot assume
   HEAD's compose file is deployable.
2. `backend/Dockerfile:20` does `COPY service-account.json ./`, and
   `.gitignore:29-30` excludes that file from the repository. A GitHub Actions
   build from a clean checkout **cannot build the image at all** as written.
   This is the single hardest blocker to AC2 and it is invisible from the VPS
   side, because the VPS has the file sitting in its working directory.
3. `backend/src/app.module.ts:38` sets TypeORM `synchronize: true` with the
   comment "Auto-create tables for dev", against the production database. Every
   deploy of changed entity code silently mutates the live schema, and TypeORM
   sync will drop columns/tables it believes are no longer mapped. Automating
   deploys **increases the frequency** of this hazard from "whenever someone
   remembers to deploy" to "every merge". AC6 (no data loss) cannot be honestly
   claimed while this is true.

Consequence for the design: the story is not "add a workflow file". It is
"make the repository's deploy artifacts actually deployable, then automate
them". Finding (2) is resolved architecturally below (the Firebase key becomes
a runtime mount, not a build input) which also removes a baked credential from
the image. Findings (1) and (3) are handled as explicit gated obligations.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` — the reusable
  build-and-deploy contract (image coordinates, secret names, health gate) that
  REQ-006 (web deploy) and REQ-007 (mobile production API base URL) build on.

## 3. Scope And Assumptions

- In Scope: `.github/workflows/` (new), `backend/Dockerfile`, the VPS-side
  compose/runtime layout, GitHub Actions secret declarations, and
  decommissioning of the prior deploy trigger.
- Out Of Scope: `backend/nginx/default.conf` and any TLS/vhost/DNS change
  (STORY-001 writes that file — STORY-002 must not, or the two story branches
  conflict on the integration branch); backend source under `backend/src/`.
- Assumptions affecting design:
  - A-1: The VPS runs the backend under Docker Compose. Supported by the repo
    shipping a `vps`-profile nginx service, a production `Dockerfile`, and
    fixed prod-style host ports. **Must be confirmed by the AC1 read-only
    inspection before any workflow is authored.** If the inspection instead
    finds systemd/PM2/manual `node dist/main`, section 4's deploy contract
    changes shape and this solution needs a revision pass.
  - A-2: The VPS holds machine-local state not present in git: a
    `backend/.env` (or equivalent) supplying `POSTGRES_*`, a real
    `service-account.json`, and Docker named volumes. The deploy must treat
    all of it as **read-only, never overwritten**.
  - A-3: The production branch is `main`.
  - A-4: The current 2026 recommendation for the SSH step could not be
    verified this run — `WebSearch`/`WebFetch` are disabled for this session
    (`ToolSearch select:WebSearch,WebFetch` returned "disabled for this
    session, in subagents as well as here"). The contract below therefore
    specifies the *mechanism* (OpenSSH client + `docker compose pull/up` over
    a non-interactive SSH session) rather than pinning a marketplace action.
    Selecting and pinning the concrete action is OID-2.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| Dedicated deploy SSH key vs. reuse | OPEN | Nothing | All of AC1-AC7 | Deliberately unresolved here; see OID-1. Both branches produce the same workflow shape, differing only in which private key populates `VPS_SSH_PRIVATE_KEY`. |
| Nginx VPS-target ambiguity (`api-cupid.tikup.me`) | OPEN | Nothing in this story | All of AC1-AC7 | Inventory-only. The legacy vhost is documented by AC1 and left running untouched; its disposition belongs to STORY-001's domain work, not to this deploy-path change. |

## 4. Architecture Delta

### Investigation Findings (AC1 — repository side)

Recorded from the repository at `BaseHead` 236454f. This is the **prerequisite
half** of AC1; the VPS-side read-only SSH inspection is a DevOps phase and its
output must be appended to this section (or to the story's devops artifact)
before the workflow is authored.

| Artifact | State at HEAD | Consequence |
|----------|---------------|-------------|
| `.github/workflows/` | Does not exist | CI is greenfield; no existing pipeline to reconcile or disable. |
| `backend/Dockerfile` | Node 22 alpine, multi-stage, `npm ci` → `npm run build` → runtime stage; `COPY service-account.json` | Image build is sound except for the gitignored secret file (Key Discovery 2). |
| `backend/docker-compose.yml` | `backend` + `vps`-profile `nginx`; `postgres`/`redis` demoted to `profiles: ["legacy"]` while still in `depends_on` | HEAD compose is not runnable as-is (Key Discovery 1). |
| `backend/docker-compose.yml.devstack-backup.1787195883` | Pre-devstack copy: same services, no `legacy` profile | Best available proxy for what the VPS actually runs; use it to diff against live VPS state during AC1. |
| `backend/nginx/default.conf` | `server_name api-cupid.tikup.me`, `listen 80` only, proxies to `backend:3000` | Legacy domain, plain HTTP, no `api.cupidus.app`. Inventory only; STORY-001 owns the change. |
| `backend/src/main.ts:11` | `require('../service-account.json')` at bootstrap, before `NestFactory.create` | The key is needed at **runtime**, and its absence crashes the process at startup — a clean, loud failure the health gate will catch. |
| `backend/src/main.ts:40` | `app.listen(PORT ?? 3000)`, no global prefix, Swagger at `/api-docs` | `GET /` is a valid unauthenticated liveness target. |
| `backend/src/app.controller.ts:8` | Root `@Get()` returning a string | No dedicated `/health` route exists. Adding one is a backend source change and is **out of scope**; the health gate uses `GET /`. |
| `backend/src/app.module.ts:38` | TypeORM `synchronize: true` | Live-schema auto-mutation on every deploy (Key Discovery 3). |

Required VPS-side inspection checklist for the AC1 phase (all read-only — `ls`,
`cat`, `docker ps`, `systemctl status`, `crontab -l`, `docker volume ls`; no
writes, no `docker` state changes, and **no reading of credential values into
the transcript** — record that a file exists and its shape, never its
contents):

- Which mechanism actually starts the process: `docker compose` project name
  and file path, or a systemd unit, or PM2, or a cron/manual script.
- The deployed compose file's content, diffed against both repo copies.
- Named volumes and bind mounts in use (this is the AC6 data-loss surface).
- Whether `postgres`/`redis` run as compose services on the VPS, as host
  packages, or as managed/external services.
- Location and existence (not contents) of `.env` and `service-account.json`.
- What terminates TLS for `api-cupid.tikup.me`, if anything, given the vhost
  listens on port 80 only.
- Any `authorized_keys` entries already present for GitHub Actions (AC5 input:
  reuse is only on the table if such a key already exists and works).

### Boundaries And Ownership

- Owning module / service: `backend` deploy unit (image + compose runtime) and
  the new repository-level `.github/workflows/` CI surface.
- New or changed boundaries: a **registry boundary** is introduced between CI
  and the VPS. CI is the only producer of runnable artifacts; the VPS becomes
  a consumer that pulls an immutable, digest-addressed image. The VPS stops
  being a build host, which is what makes I-1 and AC7 enforceable rather than
  aspirational.
- Shared patterns reused or introduced: this is the first CI/CD pipeline in the
  repository. Its job layout (build-and-push → deploy-and-verify) is the
  pattern REQ-006 and REQ-007 inherit; that is why `contract-summary.md` exists.

### Affected Modules

- Infrastructure: `.github/workflows/`, `backend/Dockerfile`,
  `backend/docker-compose.yml` (or a VPS-side production overlay), VPS runtime
  layout, GitHub Actions secret set.

### Contracts And Integrations

- Trigger and idempotency: `push` to `main` plus `workflow_dispatch`. The
  workflow must be safe to re-run on the same commit — image tags are content
  addressed by commit SHA, and re-deploying an already-current SHA is a no-op
  that still runs the health gate. Concurrency must be serialized per
  environment (one in-flight production deploy at a time, later runs cancel or
  queue) so two merges landing close together cannot interleave a pull with an
  `up`.
- Deploy failure semantics: the deploy step is **not** allowed to leave the
  stack down. `docker compose pull` happens first and is side-effect-free with
  respect to the running container; only after the pull succeeds does the
  replacement start. If the post-start health gate fails, the step must
  restore the previously-recorded image reference and exit non-zero, so the run
  is red *and* the site is up. "Failed deploy" and "site down" must be
  independent outcomes.
- Health gate: poll `GET http://127.0.0.1:<backend port>/` from inside the VPS
  (not through nginx, so the gate tests the app rather than the proxy), with a
  bounded retry window and an explicit timeout. Startup failure modes it must
  catch: missing `service-account.json` (crash in `bootstrap()` before
  listen), unreachable Postgres/Redis, and a port that never binds.
- Credential trust boundary: the runner receives a private SSH key and,
  conditionally, a Firebase service-account JSON. Neither may be echoed, and
  the SSH session must verify the host key from `VPS_SSH_KNOWN_HOSTS` —
  `StrictHostKeyChecking=no` is prohibited, since it turns every deploy into an
  unauthenticated push of production code to whatever answers on that IP.
- Registry: GitHub Container Registry (`ghcr.io`), pushed with the workflow's
  built-in `GITHUB_TOKEN` (`packages: write`). The VPS pull needs either a
  read-scoped token or a public package — see OID-3.
- Firebase key relocation: `backend/Dockerfile` drops
  `COPY service-account.json`; the file is supplied at runtime as a bind mount
  to `/usr/src/app/service-account.json`. `main.ts` resolves
  `../service-account.json` from `dist/`, so the mount path satisfies the
  existing `require` **with no source change**. This makes the CI build
  possible (Key Discovery 2) and removes a credential from every image layer.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Production data loss at cutover (AC6) | VPS volume/bind-mount inventory from AC1 | Cutover reuses the existing volumes and named compose project verbatim; no volume is renamed, recreated, or pruned. Any compose project-name change is treated as a data migration, not a deploy. | Before cutover: record `docker volume ls` + row counts on a key table; after: re-verify identical volume names and non-decreasing row counts. | `DEPLOY_STATE_UNVERIFIED` — do not cut over if the live volume/state inventory cannot be captured read-only. |
| TypeORM `synchronize: true` mutating live schema (AC6) | `backend/src/app.module.ts:38` | Out of scope to fix here (backend source). Mitigate operationally: a pre-deploy database dump on the VPS is a **required** step of the deploy job, retained across at least the last N deploys. | Deploy run log shows a dump file written with non-zero size before the new image starts. | `SCHEMA_SAFETY_UNMET` — escalate to Scrum Master to open a follow-up story for migrations; do not silently accept. |
| Partially-deployed / broken VPS after failed run (AC7) | Workflow deploy job definition | Build fully off-box (I-1); pull-then-promote; health gate with automatic restore of the prior image reference. | Deliberate negative test: run the pipeline against a commit whose image fails its health gate, and observe the prior version still answering `GET /`. | `ROLLBACK_UNPROVEN` — AC7 may not be claimed on reasoning alone; it requires this observed negative test. |
| Two competing deploy paths live (AC3) | AC1 mechanism inventory | Strict ordering: legacy trigger is disabled only **after** one green Actions deploy is verified serving traffic. Disable by neutralizing the trigger (cron entry, unit `WantedBy`, webhook) — not by deleting the artifact, so it stays inspectable. | Post-cutover re-inspection shows exactly one enabled trigger; the legacy one is present-but-disabled with a dated note. | `CUTOVER_INCOMPLETE` |
| Credential leakage / over-privileged access (AC4/AC5) | GitHub secret list in `contract-summary.md` | Every secret created with a placeholder body via `gh secret set <NAME> --body <placeholder>`; no VPS-discovered value is read, echoed, or committed. Host-key pinning mandatory. | `gh secret list` shows the full required name set; workflow source contains no literal credential and no `StrictHostKeyChecking=no`; run logs contain no key material. | `SECRETS_UNPROVISIONED` — report the exact missing names to the user rather than substituting a real value. |
| HEAD compose file is not runnable | `backend/docker-compose.yml` `depends_on` vs `profiles: ["legacy"]` | Resolve before automating: either a production compose overlay that declares the real dependency topology found in AC1, or corrected `depends_on`. The pipeline must deploy a file that has been proven to `docker compose config` cleanly. | `docker compose -f <deployed file> config` exits 0 in CI as a pre-deploy validation step. | `COMPOSE_INVALID` |
| First-merge self-trigger | Workflow `on:` block | The merge that lands the workflow will itself fire a production deploy. Intended, but it must be the *verification* run, executed with the operator watching, not an unattended surprise. | Cutover is scheduled, not incidental; the first run is observed end-to-end. | — |

### Lane Handoff

#### DevOps Lane

- Responsibilities: read-only VPS inspection and completion of the
  Investigation Findings table; the `.github/workflows/` pipeline; the
  Dockerfile Firebase-key relocation; the production compose overlay; secret
  provisioning with placeholders; the ordered cutover and legacy
  decommissioning; the negative rollback test.
- Authoritative inputs: this file, `requirements/requirements.md` (AC1-AC7),
  and the AC1 VPS inspection output.
- Guardrails:
  - Do not write `backend/nginx/default.conf` — STORY-001 owns it; writing it
    here creates an integration-branch conflict.
  - Do not modify anything under `backend/src/`.
  - Do not read, echo, copy, or reuse any credential **value** found on the
    VPS. Record existence and path only.
  - Do not generate or rotate an SSH key until an existing authorized key has
    been demonstrated broken (AC5).
  - Do not build on the VPS, and do not `git clone`/`git pull` on the VPS.
  - Do not run `docker system prune`, `docker compose down -v`, or any volume
    removal on the VPS at any point.
  - Do not disable the legacy path before a green Actions deploy is verified.
  - Do not use `StrictHostKeyChecking=no`.
- Requirement configuration guide update (DevOps lane only): REQUIRED — new
  secrets, a new registry dependency, and a changed runtime file layout all
  land in `deployment/configuration-guide.md`.

### Open Implementation Decisions

Named deliberately, to be decided and recorded by DevOps during
implementation — not resolved here.

- OID-1 (AC5): dedicated least-privilege deploy key vs. reuse of the existing
  authorized key. Decide *for reuse* only if AC1 finds an
  Actions-specific key already in `authorized_keys` that works. Decide *for a
  new dedicated key* if the only authorized key is the operator's personal key
  — a personal key in CI means every workflow contributor inherits the
  operator's shell access and revocation forces a human key rotation. If a new
  key is minted, constrain it in `authorized_keys` (`command=`,
  `no-port-forwarding`, `no-agent-forwarding`, `no-pty`) so a leaked CI secret
  buys a deploy, not a root shell. Record the decision and rationale.
- OID-2 (A-4): which SSH mechanism the workflow uses — a pinned third-party
  marketplace action vs. the runner's own OpenSSH client driven by a
  repository-owned script. Criteria: any third-party action in the credential
  path must be pinned to a full commit SHA (not a floating tag) and must be
  currently maintained; if that cannot be established, prefer the OpenSSH
  path, which has no supply-chain surface. Verify current guidance at
  implementation time — this run could not.
- OID-3: GHCR package visibility — private package plus a read-scoped
  `GHCR_PULL_TOKEN` on the VPS, vs. a public package with no pull credential.
  Criterion: the image contains built application code; if that is not
  acceptable to publish, the package stays private and the token is required.

## 5. Non-Functional Impact

- Availability: the deploy is the only planned production interruption in this
  requirement. Container replacement is a brief restart, bounded by the health
  gate; a failed deploy must produce **zero** additional downtime (I-2).
- Security posture improves in two concrete ways: the Firebase service-account
  key stops being baked into image layers, and production access becomes
  attributable to a named GitHub secret with a revocation path.
- Auditability: the deployed artifact becomes traceable to a commit SHA and a
  workflow run, which is the actual business value of AC2 over the status quo.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| CI builds + pushes image to GHCR; VPS pulls by SHA and promotes after health gate | Keeps builds off the production host, gives immutable rollback targets, and makes AC7 structurally true rather than best-effort | ACCEPTED | Costs one registry dependency and OID-3. |
| SSH to VPS, `git pull`, `docker compose up -d --build` | Simplest to write; no registry | REJECTED | Directly violates AC7: the build runs on the production host, so a compile error, an OOM, or a broken `npm ci` leaves the VPS mid-deploy. It also needs a repo credential on the VPS and cannot roll back to a prior artifact. |
