# Phase P6 – Runtime Registry, Local Scripts, And Deploy To cupidus.app

## 1. Objective

`web-frontend` is a first-class runtime in this repository — registered, locally
runnable on a devstack-claimed port, and deployed to the apex domain
`cupidus.app` by a GitHub Actions pipeline that reuses REQ-005's VPS pattern.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-runtime-registry-and-deploy.md`
- Owner: DevOps Engineer
- Lane: DevOps

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: YES (runs alongside P2–P5; an end-to-end deploy run is
  meaningful only after P5 lands)
- Write Scope:
  - `data/devops/system/runtime-command-registry.json`
  - `.github/workflows/deploy-web.yml`
  - `.github/workflows/scripts/vps-deploy-web.sh`
  - `scripts/build.sh`
  - `scripts/start-dev.sh`
  - `../deployment/configuration-guide.md`
- Impacted Runtime Service/App:
  - Name: `web-frontend`
  - Runtime Registry Id: `web-frontend` (**created by this phase**)
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: frontend
  - Startup Smoke: NOT_APPLICABLE for this phase's test scope; `web-frontend`
    startup smoke belongs to the DevOps runnable-foundation gate
  - Build Command Source: runtime registry `buildCommand` (this phase defines it)
  - Startup Command Source: runtime registry `devCommand` (this phase defines it)
  - Readiness Check: HTTP 200 on `/` at the claimed loopback port locally; HTTP
    200 on `https://cupidus.app/` in the deploy gate
  - Port Contract: per-project loopback host binding, `devstack port claim
    --role web`, read from `.env.devstack`
- Shared Interfaces Produced:
  - `web-frontend` registry entry consumed by P1–P5 build/dev commands
- Shared Interfaces Consumed:
  - `web/package.json` build script (P1)
- Risk Surfaces:
  - Deploy parity with REQ-005
- Source Of Truth:
  - authoritative artifact: `.github/workflows/deploy-backend.yml`,
    `.github/workflows/scripts/vps-deploy.sh`,
    `.claude/skills/devops/references/shared-local-infrastructure.md`
  - consumer contract: `data/devops/system/runtime-command-registry.json`
- Primary Inputs Summary:
  - requirements: AC-1, AC-8
  - architecture: `../architecture/solution.md` §4 DevOps Lane guardrails
  - OQ constraints: OQ-REQ006-2 resolved — static artifact, no backend
    dependency, no `api.cupidus.app` wiring
  - upstream phase outputs: P1 build command
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: YES
  - Sections To Update: new `web-frontend` runtime and local commands; the
    `cupidus.app` deploy target and its web-server root; the full GitHub Actions
    secret list for this pipeline, marking which are reused from REQ-005 and
    which are new placeholders
- Phase Sizing:
  - Behavior Slice: register, run locally, and deploy one new static runtime
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (AC-1, AC-8)
- `../architecture/solution.md` §4 DevOps Lane
- `.github/workflows/deploy-backend.yml` and
  `.github/workflows/scripts/vps-deploy.sh`
- `data/devops/system/runtime-command-registry.json` `runtimes` and
  `sharedInfra` sections
- `.claude/skills/devops/references/shared-local-infrastructure.md`

## 3. Tasks

- Add a `web-frontend` entry under `runtimes` following the shape of the
  existing `backend-api` entry: `path: "web"`, `type` frontend/static,
  `installCommand`, `buildCommand`, `devCommand`, `prodCommand` (preview), the
  port record, and a readiness check. `requiredEnv` and `dependsOn` are empty —
  this runtime has no dependency services.
- Claim the local dev-server port with `devstack port claim --role web` and
  record it in `sharedInfra.reservedPorts` plus the runtime's `hostPortEnv`
  (`DEVSTACK_PORT_WEB`). Do not hardcode Astro's default port and do not scan
  for a free one.
- Extend `scripts/build.sh` to build `web/` alongside the backend, and
  `scripts/start-dev.sh` to start the web dev server on the claimed port sourced
  from `.env.devstack`.
- Author `.github/workflows/deploy-web.yml` modeled on `deploy-backend.yml`:
  trigger on push to `main` under `web/**` plus the workflow and script paths,
  a `deploy-web-production` concurrency group, `permissions: contents: read`, a
  build job, and a `deploy-and-verify` job in the `production` environment.
- The backend pipeline ships a container image through GHCR; a static site does
  not need one. Build `web/` in the workflow and ship the output directory to
  the VPS over the same SSH mechanism. Do not introduce a container or a second
  registry unless the VPS web server genuinely cannot serve a static root —
  report that finding first rather than expanding scope.
- Reuse the existing secret names exactly: `VPS_SSH_HOST`, `VPS_SSH_USER`,
  `VPS_SSH_PORT`, `VPS_SSH_PRIVATE_KEY`, `VPS_SSH_KNOWN_HOSTS`. Any genuinely
  new secret (for example a web-specific deploy path) gets a placeholder and
  must be reported to the user by exact name — do not invent a value.
- Configure the VPS web server to serve `cupidus.app` from the deployed static
  root with TLS, following whatever server REQ-005 already runs on that host.
  Do not add a second web server.
- End the deploy job with an HTTP health gate against `https://cupidus.app/`
  and a rollback path, matching the backend pipeline's posture.
- Write `../deployment/configuration-guide.md` covering the sections listed in
  `## 1B`.

## 4. Acceptance Criteria

- `data/devops/system/runtime-command-registry.json` stays valid JSON and
  contains a `web-frontend` entry whose port comes from a devstack claim.
- `scripts/build.sh` and `scripts/start-dev.sh` handle `web/` and read the port
  from `.env.devstack`, with no hardcoded or scanned port.
- `.github/workflows/deploy-web.yml` is valid YAML, triggers only on `web/**`
  and its own paths, and reuses the REQ-005 secret names.
- The deploy job fails loudly when the post-deploy HTTP gate on
  `https://cupidus.app/` does not return success.
- `../deployment/configuration-guide.md` exists and lists every secret this
  pipeline reads, marking reused versus new.
- Any new placeholder secret is reported to the user by exact name.

## 5. Planned Outputs

- Code directories or files: the six paths in `## 1B Write Scope`.
- Contracts or schemas: the `web-frontend` runtime registry entry.
- Requirement configuration guide updates: as listed in `## 1B`.
- Notes or evidence: validation output and the exact new-secret list in
  `test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: DevOps (repository configuration and CI)
- Required checks:
  - `bash -n .github/workflows/scripts/vps-deploy-web.sh` and `bash -n` on both
    modified `scripts/*.sh`; shellcheck when available; executable bit set
  - workflow YAML parses, and its `paths` filter does not overlap the backend
    pipeline's trigger
  - `data/devops/system/runtime-command-registry.json` parses as JSON and the
    new entry matches the shape of the existing `backend-api` entry
  - grep the workflow, both scripts, and the registry entry for a hardcoded
    application port or a port-scanning construct — must return none
  - grep the workflow and scripts for a literal secret value — must return none
- Minimum gates by risk surface:
  - Deploy parity with REQ-005: the secret names in `deploy-web.yml` are a
    subset of `deploy-backend.yml`'s plus an explicitly reported new list
- Evidence format: command output, the registry diff, and the exact new-secret
  list in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted checks: the syntax, schema, and grep checks above
  - Required assertion evidence: exit codes plus the new-secret list

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-21
