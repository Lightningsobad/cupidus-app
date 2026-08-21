# Phase P2 – Actions pipeline, ordered cutover, and rollback proof

## 1. Objective

Author the GitHub Actions pipeline that builds the backend image off-box, pushes
it to GHCR, and deploys it to the VPS behind a health gate with automatic
restore; provision every required secret as a placeholder; then perform the
ordered cutover — one verified green Actions deploy first, legacy trigger
decommissioned second — and prove AC7 with a deliberate failing-deploy test.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-actions-pipeline-cutover-and-rollback-proof.md`
- Owner: DevOps Engineer
- Lane: DevOps

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `.github/workflows/deploy-backend.yml`
  - `.github/workflows/scripts/vps-deploy.sh` (only if OID-2 selects the OpenSSH path)
  - `data/requirements/REQ-005_production_domain_and_cicd_standardization/deployment/configuration-guide.md`
  - `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-002/devops/cutover-evidence.md`
  - `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-002/coding-plan/test-results.md`
- Impacted Runtime Service/App:
  - Name: `backend-api`
  - Runtime Registry Id: `backend-api`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: backend
  - Startup Smoke: NOT_APPLICABLE (no local runtime start; readiness is the in-pipeline VPS health gate)
  - Build Command Source: runtime registry `backend-api.buildCommand` (`npm run build`, inside the CI image build)
  - Startup Command Source: runtime registry `backend-api.prodCommand` (`npm run start:prod`, via the container entrypoint)
  - Readiness Check: `GET http://127.0.0.1:<backend port>/` polled from inside the VPS, bounded retries and explicit timeout
  - Port Contract: external on the VPS (existing published host port), polled on loopback so the gate tests the app, not nginx
- Shared Interfaces Produced:
  - The build-and-push → deploy-and-verify job layout REQ-006 and REQ-007 inherit
  - The provisioned GitHub Actions secret name set
- Shared Interfaces Consumed:
  - `../architecture/contract-summary.md` sections 2 (identifiers/secret names), 3 (VPS runtime layout), 4 (health gate), 5 (rollout order), 6 (prohibitions)
  - P1 outputs: `STORY-002/devops/vps-inspection.md`, `backend/Dockerfile`, `backend/docker-compose.prod.yml`
- Risk Surfaces:
  - Partially-deployed / broken VPS after failed run (AC7)
  - Two competing deploy paths live (AC3)
  - Credential leakage / over-privileged access (AC4/AC5)
  - Production data loss at cutover (AC6)
  - TypeORM `synchronize: true` mutating live schema (AC6)
  - First-merge self-trigger
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` section 4 `Contracts And Integrations` and `Risk Surfaces And Source Of Truth`
  - consumer contract: `../architecture/contract-summary.md` sections 2, 4, 5, 6
- Primary Inputs Summary:
  - requirements: AC2, AC3, AC4, AC5, AC7 and `## Business Rules / Guardrails`
  - architecture: section 4 `Contracts And Integrations`, `Risk Surfaces And Source Of Truth`, `Lane Handoff`, `Open Implementation Decisions`
  - OQ constraints: `../requirements/requirements.md` `## Open Question Impact` — nothing BLOCKED
  - upstream phase outputs: P1 inspection record, Dockerfile, production compose overlay
  - review findings: none yet
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: YES
  - Sections To Update: GitHub Actions secret names and their purpose (placeholder values only); GHCR registry dependency and package visibility per OID-3; VPS runtime file layout (`<VPS_DEPLOY_PATH>/docker-compose.yml`, `.env`, `service-account.json` bind mount); deploy trigger and rollback behavior; the recorded OID-1/OID-2/OID-3 decisions
- Phase Sizing:
  - Behavior Slice: "one automated deploy path, live and proven safe"
  - Source/Test File Count: 5
  - Split Required: NO
  - Split Rationale: one specialist lifecycle. The cutover and the rollback test are not a separate verification phase — this phase also owns the AC3 decommissioning change they gate, so splitting would separate a change from its own gate.

## 2. Required Reads

- `master-plan.md` and this phase file
- `../requirements/requirements.md` (AC2-AC7, Business Rules)
- `../architecture/solution.md` section 4
- `../architecture/contract-summary.md` sections 2, 3, 4, 5, 6
- `STORY-002/devops/vps-inspection.md` (P1 output)
- `../requirements/requirements.md` `## Open Question Impact`

## 3. Tasks

1. Decide and record OID-2 (SSH mechanism) before writing the workflow. A
   third-party action in the credential path must be pinned to a full commit SHA
   and be currently maintained; verify current guidance at implementation time
   with `WebSearch`/`WebFetch` (load with `ToolSearch select:WebSearch,WebFetch`
   if deferred). If that cannot be established, use the runner's OpenSSH client
   driven by `.github/workflows/scripts/vps-deploy.sh`, which has no
   supply-chain surface.
2. Decide and record OID-1 (dedicated least-privilege deploy key vs. reuse) using
   P1's `authorized_keys` evidence. Reuse only if an Actions-specific key already
   exists and works; if the only authorized key is the operator's personal key,
   mint a dedicated key and constrain it in `authorized_keys` with `command=`,
   `no-port-forwarding`, `no-agent-forwarding`, `no-pty`. Record the rationale in
   `cutover-evidence.md` (AC5 requires a recorded judgment call).
3. Decide and record OID-3 (GHCR package visibility): private package plus a
   read-scoped `GHCR_PULL_TOKEN` on the VPS, vs. public package with no pull
   credential. Criterion: the image contains built application code.
4. Author `.github/workflows/deploy-backend.yml` with two jobs. `build-and-push`:
   trigger `push` to `main` plus `workflow_dispatch`, `packages: write`, build
   `backend/Dockerfile`, tag by commit SHA, push to `ghcr.io`, and run
   `docker compose -f backend/docker-compose.prod.yml config` as a pre-deploy
   validation step. `deploy-and-verify`: SSH to the VPS with the host key pinned
   from `VPS_SSH_KNOWN_HOSTS`, `docker compose pull` first, take a pre-deploy
   database dump and assert non-zero size, record the currently-running image
   reference, then `up` the replacement, then poll the health gate; on gate
   failure restore the recorded image reference and exit non-zero. Serialize with
   a per-environment `concurrency` group so two merges cannot interleave a pull
   with an `up`. Re-running the same SHA must be a no-op that still runs the gate.
5. Provision every required secret as a placeholder with
   `gh secret set <NAME> --body <placeholder>`: `VPS_SSH_HOST`, `VPS_SSH_USER`,
   `VPS_SSH_PORT`, `VPS_SSH_PRIVATE_KEY`, `VPS_SSH_KNOWN_HOSTS`,
   `VPS_DEPLOY_PATH`, and `GHCR_PULL_TOKEN` only if OID-3 keeps the package
   private. Report the exact final name list back to the user so they populate
   the real values themselves (AC4).
6. Update `../../deployment/configuration-guide.md` with the sections listed in
   `1B` above. Placeholder/shape only — no real value.
7. Deliver `backend/docker-compose.prod.yml` to `<VPS_DEPLOY_PATH>` as a
   deliberate, recorded, one-time write that preserves the existing compose
   project name and volume names. If the live file diverges in project name or
   volume names, stop — that is a data migration, not a deploy.
8. Run the ordered cutover in this sequence and record each step with a timestamp
   in `cutover-evidence.md`: (a) merge the workflow to `main` as a scheduled,
   observed run — never an incidental merge; (b) watch the first pipeline run end
   to end and confirm the health gate passes and the VPS serves `GET /`; (c) only
   then neutralize the legacy trigger found in P1 (cron entry, unit `WantedBy`,
   or webhook) by disabling it, not deleting it, and leave a dated note beside it;
   (d) re-inspect and confirm exactly one enabled deploy trigger remains.
9. Run the AC7 negative rollback test: trigger the pipeline against a commit whose
   image deliberately fails the health gate (for example a temporary branch or
   `workflow_dispatch` input that starts the container without the
   `service-account.json` mount, which crashes in `bootstrap()` before listen).
   Observe that the run goes red, the prior version still answers `GET /`, and
   the running image reference is the prior one. Record the evidence; revert the
   deliberate break immediately afterward.
10. Re-verify the AC6 baseline from P1: identical volume names and non-decreasing
    row counts on the key table after cutover.

## 4. Acceptance Criteria

- `.github/workflows/deploy-backend.yml` exists; a push/merge to `main` builds
  and deploys the backend to `root@84.247.140.178` (AC2).
- The workflow contains no literal credential and no `StrictHostKeyChecking=no`;
  the host key is pinned from `VPS_SSH_KNOWN_HOSTS`; run logs contain no key
  material (AC4).
- `gh secret list` shows the full required name set with placeholder bodies, and
  the exact name list has been reported to the user (AC4).
- The OID-1 key decision and its rationale are recorded (AC5); no key was
  generated or rotated unless an existing authorized key was demonstrated broken.
- The legacy deploy trigger is disabled-but-present with a dated note, and
  re-inspection shows exactly one enabled trigger (AC3).
- Volume names are unchanged and key-table row counts are non-decreasing versus
  P1's baseline; a pre-deploy dump of non-zero size is written on every deploy
  run (AC6).
- The negative rollback test is recorded: run red, prior version still serving
  `GET /`, prior image reference still running (AC7).
- `../../deployment/configuration-guide.md` is updated with secrets, registry,
  runtime layout, trigger, and rollback behavior.
- `backend/nginx/default.conf` and `backend/src/` remain untouched; nothing was
  built or `git clone`d on the VPS.

## 5. Planned Outputs

- Code directories or files: `.github/workflows/deploy-backend.yml`, and
  `.github/workflows/scripts/vps-deploy.sh` if OID-2 selects OpenSSH
- Contracts or schemas: the provisioned secret name set and the job layout
  REQ-006/REQ-007 inherit, matching `../architecture/contract-summary.md`
- Requirement configuration guide updates: `../../deployment/configuration-guide.md`
- Notes or evidence: `STORY-002/devops/cutover-evidence.md`,
  `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: GitHub Actions workflow, GHCR, VPS deploy target
- Required levels:
  - backend build/type-check: image build inside the `build-and-push` job (runs the registry `buildCommand`)
- Required checks:
  - workflow static lint (`actionlint` when available, otherwise YAML parse) exits 0
  - `docker compose -f backend/docker-compose.prod.yml config` exits 0 as a CI pre-deploy step
  - workflow source contains no literal credential and no `StrictHostKeyChecking=no`
  - `gh secret list` shows the full required name set
  - health-gate poll observed passing on the first green production run
  - pre-deploy database dump written with non-zero size in the run log
  - post-cutover re-inspection shows exactly one enabled deploy trigger
  - deliberate negative rollback test: red run, prior version still answering `GET /`
  - post-cutover volume names identical and key-table row counts non-decreasing
- Minimum gates by risk surface:
  - Partially-deployed / broken VPS (AC7) → the observed negative rollback test; blocker `ROLLBACK_UNPROVEN`. AC7 may not be claimed on reasoning alone.
  - Two competing deploy paths live (AC3) → post-cutover single-trigger re-inspection; blocker `CUTOVER_INCOMPLETE`
  - Credential leakage (AC4/AC5) → secret-name-set check plus clean workflow source and run logs; blocker `SECRETS_UNPROVISIONED`
  - Production data loss (AC6) → volume/row-count re-verification; blocker `DEPLOY_STATE_UNVERIFIED`
  - TypeORM `synchronize: true` (AC6) → dump-before-start evidence; blocker `SCHEMA_SAFETY_UNMET`
  - HEAD compose file is not runnable → CI `docker compose config` exit 0; blocker `COMPOSE_INVALID`
- Required regression or contract coverage: re-running the pipeline on an
  already-deployed SHA is a no-op that still runs the health gate
- Evidence format: command/run URL + exit code + trimmed log excerpt in
  `coding-plan/test-results.md`; timestamped cutover steps in
  `cutover-evidence.md`; all credential-bearing lines redacted at capture time
- Verification strategy:
  - Targeted checks: workflow lint, compose config, secret name set, health gate, negative rollback test, single-trigger re-inspection
  - Build command when required: image build in CI via `backend/Dockerfile`
  - Required assertion evidence: the red-run-plus-still-serving observation for AC7 and the one-enabled-trigger observation for AC3

## 7. Stop-And-Ask Rules

- Never read, echo, copy, or commit a real credential value. Every secret is
  created with `gh secret set <NAME> --body <placeholder>`; if a step would
  require a real value, stop and report the exact missing secret names to the
  user (`SECRETS_UNPROVISIONED`) rather than substituting one.
- Report the exact required GitHub Actions secret name list to the user before
  claiming AC4 — this reporting obligation is part of the AC, not a courtesy.
- Do not disable the legacy deploy path before a green Actions deploy has been
  verified serving traffic (`CUTOVER_INCOMPLETE`).
- Do not claim AC7 without the observed negative rollback test
  (`ROLLBACK_UNPROVEN`).
- Stop if the live VPS compose project name or volume names would have to change
  (`DEPLOY_STATE_UNVERIFIED`) — that is a data migration and needs user sign-off.
- Stop and escalate to Scrum Master for a follow-up migrations story if the
  pre-deploy dump cannot be made a required step (`SCHEMA_SAFETY_UNMET`); do not
  silently accept `synchronize: true` on live schema.
- Do not use `StrictHostKeyChecking=no`, and do not pin a third-party action to a
  floating tag.
- Do not build on the VPS and do not `git clone` / `git pull` on the VPS.
- Do not run `docker system prune`, `docker compose down -v`, or any volume
  removal on the VPS at any point.
- Do not write `backend/nginx/default.conf` (STORY-001 owns it) and do not modify
  `backend/src/`.
- Schedule the first production run as an observed cutover; do not let the
  workflow-landing merge fire an unattended production deploy.

## 8. Status

- Status: NOT_STARTED
- Last updated: 2026-08-21
