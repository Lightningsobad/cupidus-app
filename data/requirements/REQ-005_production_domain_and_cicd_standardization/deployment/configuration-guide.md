# REQ-005 Deployment Configuration Guide

## GitHub Actions secrets (backend deploy, STORY-002)

All values below are placeholders provisioned with
`gh secret set <NAME> --body <placeholder>`. The user populates the real
values; this pipeline never sources or guesses a value discovered on the VPS.

| Secret | Purpose | Notes |
|---|---|---|
| `VPS_SSH_HOST` | VPS address | `84.247.140.178` |
| `VPS_SSH_USER` | VPS login user | `root` |
| `VPS_SSH_PORT` | VPS SSH port | `22` |
| `VPS_SSH_PRIVATE_KEY` | Deploy private key | OID-1: dedicated least-privilege key, constrained in `authorized_keys` with `command=`, `no-port-forwarding`, `no-agent-forwarding`, `no-pty`. Scoped to this backend deploy unit only — do not reuse for a second deploy unit. |
| `VPS_SSH_KNOWN_HOSTS` | Pinned host key | Prevents MITM; `StrictHostKeyChecking=no` is prohibited everywhere in this pipeline. |
| `VPS_DEPLOY_PATH` | Deploy directory on the VPS | `cd` target for `docker compose`; VPS-owned machine-local state, never written by CI. |
| `GHCR_PULL_TOKEN` | GHCR pull credential | Required because OID-3 keeps the package private (image contains built application code). |

Not a secret: `GITHUB_TOKEN` is injected by Actions with `packages: write` in
the `build-and-push` job's `permissions:` block.

## Container registry dependency

Images are built off-box in `build-and-push` and pushed to
`ghcr.io/<owner>/<repo>-backend`, tagged with the full commit SHA (plus a
`latest` convenience pointer that nothing deploys from). Per OID-3, the
package is **private**; the VPS authenticates the pull with
`GHCR_PULL_TOKEN`.

## VPS runtime file layout

| Path | Owner | Notes |
|---|---|---|
| `<VPS_DEPLOY_PATH>/docker-compose.prod.yml` | delivered by this pipeline as a one-time write (task 7) | Compose project name `backend`, volumes `backend_postgres_data` / `backend_redis_data` — must match the VPS's existing project/volume names verbatim. |
| `<VPS_DEPLOY_PATH>/.env` | VPS (machine-local) | `POSTGRES_USER` / `POSTGRES_PASSWORD`. Never written by CI. |
| `<VPS_DEPLOY_PATH>/service-account.json` | VPS (machine-local) | Firebase Admin SDK key, bind-mounted read-only into the backend container. Never baked into the image. |
| `<VPS_DEPLOY_PATH>/backups/` | created by `vps-deploy.sh` | Pre-deploy `pg_dumpall` output, one file per deploy run, non-zero size asserted before promotion. |

No containerized `nginx` is deployed: host-level Caddy already owns ports
`80`/`443` on this shared VPS for an unrelated production site
(`vocabik`). The health gate polls `127.0.0.1:<backend port>` directly,
bypassing nginx entirely.

### Backend host port

`cupid-backend` publishes `127.0.0.1:3010:3000` — loopback-only, **not**
`0.0.0.0`. Read-only `ss -ltnp` on the VPS (2026-08-21) found ports `3000`
and `3001` already loopback-bound by the unrelated live `vocabik` app's own
containers (matching its Caddy `reverse_proxy localhost:3000` /
`localhost:3001` blocks), so `cupid-backend` cannot reuse either. `3010` was
free at inspection time. Binding loopback-only (not publishing to all
interfaces) keeps the backend off the open internet; only the host-level
reverse proxy (Caddy, STORY-001 scope — should target `127.0.0.1:3010` for
`api.cupidus.app`) or this pipeline's in-VPS health gate can reach it.

## Deploy trigger and rollback behavior

- Trigger: `push` to `main` (paths scoped to `backend/**` and the workflow
  itself) plus manual `workflow_dispatch`.
- Order: `build-and-push` must fully succeed before `deploy-and-verify`
  starts; a build failure never reaches the VPS.
- On the VPS: `docker compose pull` → pre-deploy database dump (non-zero
  size required) → `up` the replacement → poll `GET http://127.0.0.1:<port>/`
  with bounded retries → on failure, restore the prior recorded image
  reference and exit non-zero (the run goes red, the site stays up).
- `concurrency: group: deploy-backend-production, cancel-in-progress: false`
  serializes runs so two merges cannot interleave a `pull` with an `up`.
  Re-running an already-deployed SHA is a no-op that still runs the health
  gate.
- Legacy deploy trigger: disabled (not deleted) only after one green
  Actions run is verified serving traffic, with a dated note left beside it.
  Exactly one enabled deploy trigger must remain after cutover.

## OID-1/OID-2/OID-3 decisions

- **OID-1 (deploy key)**: dedicated least-privilege key minted for GitHub
  Actions, not reuse of the operator's personal key — no Actions-specific
  key existed on the VPS at inspection time. Full rationale:
  `STORY-002/devops/cutover-evidence.md`.
- **OID-2 (SSH mechanism)**: runner's own OpenSSH client driven by
  `.github/workflows/scripts/vps-deploy.sh` — no third-party action sits in
  the SSH credential path, so there is no supply-chain surface to pin.
  Decided because live `WebSearch`/`WebFetch` verification of a maintained,
  SHA-pinnable marketplace SSH action was unavailable in this run; this is
  the phase's own documented fallback, not a downgrade.
- **OID-3 (GHCR visibility)**: package stays **private**; `GHCR_PULL_TOKEN`
  is required. The image contains built application code.
