# Cross-Lane Contract — REQ-005 STORY-002 GitHub Actions VPS deploy

Authoritative source: `.github/workflows/` + `backend/` deploy unit (STORY-002).
Consumers: REQ-006 (web frontend deploy pipeline — reuses this job layout and
secret naming), REQ-007 (mobile production builds — depends on the deployed API
being reachable and versioned), and STORY-001 (points `api.cupidus.app` at the
host this pipeline deploys to).

## 1. Envelope

Transport is a GitHub Actions workflow triggered by `push` to `main` and by
`workflow_dispatch`, running two jobs in sequence:

```text
build-and-push   ->  ghcr.io/<owner>/<repo>-backend:<git-sha>  (+ :latest)
deploy-and-verify->  ssh <user>@<host> : docker compose pull && up -d && health gate
```

The image tag is the **full git commit SHA**, not a branch name or `latest`
alone. Matching is textual and exact: the deploy job passes the same SHA it
built, so a tag typo produces a loud `manifest unknown` pull failure on the VPS
before anything is stopped — never a silent deploy of the wrong build.

`latest` is published as a convenience pointer only. Nothing may deploy *from*
`latest`; a rollback target must be a SHA.

## 2. Identifiers — copy exactly

Required GitHub Actions secrets. Create every one with a placeholder body
(`gh secret set <NAME> --body PLACEHOLDER`); the user populates real values.

| Purpose | Identifier | Bound config key / route |
|---------|------------|--------------------------|
| VPS address | `VPS_SSH_HOST` | `84.247.140.178` |
| VPS login user | `VPS_SSH_USER` | `root` |
| VPS SSH port | `VPS_SSH_PORT` | `22` |
| Deploy private key (OID-1 decides which key) | `VPS_SSH_PRIVATE_KEY` | ssh-agent / `~/.ssh/id_deploy` on the runner |
| Pinned host key, prevents MITM | `VPS_SSH_KNOWN_HOSTS` | `~/.ssh/known_hosts` on the runner |
| Deploy directory on the VPS | `VPS_DEPLOY_PATH` | `cd` target for `docker compose` |
| GHCR pull credential (only if OID-3 keeps the package private) | `GHCR_PULL_TOKEN` | `docker login ghcr.io` on the VPS |
| Firebase key (only if AC1 finds no usable file on the VPS) | `FIREBASE_SERVICE_ACCOUNT_JSON` | bind-mounted to `/usr/src/app/service-account.json` |

Not a secret, and deliberately absent from this table: `GITHUB_TOKEN` is
injected by Actions. Grant it `packages: write` in the job's `permissions:`
block instead of minting a PAT for the push side.

Rules for the consumer side:

- Names are exact and shared. REQ-006's web pipeline must reuse
  `VPS_SSH_HOST` / `VPS_SSH_USER` / `VPS_SSH_PORT` / `VPS_SSH_KNOWN_HOSTS`
  rather than introducing `SSH_HOST`, `DEPLOY_HOST`, or a second copy of the
  same value — divergent names are how one rotation silently half-lands.
- `VPS_SSH_PRIVATE_KEY` is scoped to the backend deploy. A second deploy unit
  gets its own key secret; do not widen this one.
- Do not add a `CLOUDFLARE_API_TOKEN` here. Cloudflare credentials belong to
  STORY-001's DNS scope.

## 3. VPS-side runtime layout the pipeline depends on

| Path | Owner | Value contract |
|------|-------|----------------|
| `<VPS_DEPLOY_PATH>/docker-compose.yml` | VPS (machine-local) | Production compose/overlay. Must `docker compose config` cleanly — the repo's HEAD file does not (see `solution.md` Key Discovery 1). |
| `<VPS_DEPLOY_PATH>/.env` | VPS (machine-local) | `POSTGRES_*` and any runtime env. **Never written by the pipeline.** |
| `<VPS_DEPLOY_PATH>/service-account.json` | VPS (machine-local) | Firebase key, bind-mounted into the container. No longer baked into the image. |
| Docker named volumes | VPS (machine-local) | Persistent data. Never renamed, recreated, or pruned by a deploy. |

- The VPS owns all of this. CI owns only the image. A deploy that would create
  or overwrite any row above is a defect, not a feature.
- A missing `service-account.json` crashes the app inside `bootstrap()` before
  it listens, so the health gate catches it as a hard failure rather than a
  degraded start.

## 4. Health gate

- Target: `GET http://127.0.0.1:<backend port>/` from inside the VPS,
  bypassing nginx. There is no `/health` route and adding one is out of scope.
- Pass condition: HTTP 200 within a bounded retry window.
- On failure: restore the previously-recorded image SHA and exit non-zero. The
  run goes red; the site stays up.

## 5. Deploy / rollout order

1. `build-and-push` must fully succeed before `deploy-and-verify` starts. A
   build failure must never reach the VPS.
2. On the VPS: `docker compose pull` (no effect on the running container) →
   then start the replacement → then health-gate → then accept.
3. Legacy deploy path is disabled **only after** one green Actions run is
   verified serving production traffic (AC3 ordering).
4. STORY-001's `api.cupidus.app` DNS/TLS work is independent and may land in
   either order; this pipeline does not read or write the vhost config.

Wrong order is not silent: deploying before a successful build fails at
`docker pull` with `manifest unknown`, and disabling the legacy path first
leaves a window with no working deploy mechanism at all.

## 6. What the consumer must NOT do

- Do not deploy from the `latest` tag or from a branch-named tag.
- Do not add `StrictHostKeyChecking=no` or drop `VPS_SSH_KNOWN_HOSTS` to make
  a first connection work — pin the host key instead.
- Do not have CI write `.env`, `service-account.json`, or the compose file onto
  the VPS; those are machine-local state.
- Do not reuse `VPS_SSH_PRIVATE_KEY` for a non-backend deploy unit.
- Do not run `docker compose down -v`, `docker volume rm`, or
  `docker system prune` from any pipeline step.
