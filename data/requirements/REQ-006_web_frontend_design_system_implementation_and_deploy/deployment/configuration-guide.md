# REQ-006 Deployment Configuration Guide

## STORY-001 P6 — `web-frontend` runtime, local commands, deploy to `cupidus.app`

Owner: DevOps. Last updated: 2026-08-21.

### 1. `web-frontend` runtime registry entry

`data/devops/system/runtime-command-registry.json` `runtimes.web-frontend`:
static Astro build (`output: 'static'`), no API/database dependency
(OQ-REQ006-2 RESOLVED), `requiredEnv`/`requiredSecrets`/`dependsOn` all empty.
Shape mirrors `runtimes.backend-api`.

| Field | Value |
|---|---|
| `path` | `web` |
| `installCommand` | `npm ci` |
| `checkCommand` | `npm run check` (astro check — type-checks; `astro build` alone does not) |
| `buildCommand` | `npm run build` (astro build) |
| `devCommand` | `npm run dev` (invoked by `scripts/start-dev.sh` with `--port "$DEVSTACK_PORT_WEB" --host 127.0.0.1`) |
| `prodCommand` | `npm run preview` (astro preview; not wired into any script by this phase) |
| Local port | `DEVSTACK_PORT_WEB`, claimed via `devstack port claim --role web`, recorded in `sharedInfra.reservedPorts.web` — **21021** on this machine at claim time. Never Astro's default `4321`, never scanned. |
| Readiness (local) | `GET http://127.0.0.1:${DEVSTACK_PORT_WEB}/` expects `200` |
| Readiness (production) | `GET https://cupidus.app/` expects `200` |
| Engine | Node `>=22.12.0` (astro@6.0.5 requirement); this machine's ambient default is v20.20.2, so `scripts/build.sh`/`scripts/start-dev.sh` must run under a Node that satisfies the pin, and CI pins `actions/setup-node` to `22.12.0` — do not rely on the runner's default Node. |

### 2. Local commands

- `scripts/build.sh` now also runs, after the backend build and before the
  mobile build: `npm ci`, `npm run check`, `npm run build` in `web/`.
- `scripts/start-dev.sh` now also starts the web dev server (after the
  backend readiness gate, before the mobile readiness check) on
  `127.0.0.1:${DEVSTACK_PORT_WEB}`, sourced from `.env.devstack` via the
  existing `require_devstack_env` helper, and waits for `GET /` to return
  `200` before continuing. It is stopped by the same `cleanup`/`trap` the
  backend process already uses.
- `scripts/start-prod.sh` is unchanged by this phase (out of P6 write scope);
  `web-frontend`'s `prodCommand` is registry-documented only.

### 3. Deploy target: `cupidus.app`

Static build output only — no container, no GHCR, no `api.cupidus.app`
wiring (OQ-REQ006-2). Ships the same way `deploy-backend.yml` ships the
backend (GitHub Actions → SSH → the shared VPS at `84.247.140.178`), reusing
the REQ-005 secret shape, but transfers a tarred static directory over SSH
stdin instead of pulling a container image.

**VPS remote layout** (`<VPS_WEB_DEPLOY_PATH>`, a new secret — see §5):

| Path | Purpose |
|---|---|
| `<VPS_WEB_DEPLOY_PATH>/current` | Live directory. The VPS Caddy site block's `root` points here. |
| `<VPS_WEB_DEPLOY_PATH>/previous` | Backup of the release being replaced, used only for rollback. |
| `<VPS_WEB_DEPLOY_PATH>/incoming` | Staging area for the new build while it uploads; swapped into `current` only after the full tar upload succeeds. |

Deploy sequence (`.github/workflows/scripts/vps-deploy-web.sh`): back up
`current` to `previous` → tar `web/dist` over SSH stdin into `incoming` →
swap `incoming` into `current` → poll `https://cupidus.app/` for `200` with
bounded retries → on failure, swap `previous` back into `current` and exit
non-zero (the run goes red, the site stays up), mirroring
`vps-deploy.sh`'s record/deploy/health-gate/rollback posture for the
backend.

### 4. VPS web server: host Caddy, not a new server

The shared VPS already runs `cupidus.app`'s TLS terminator as **host-level
Caddy** (`/etc/caddy/Caddyfile`, systemd unit `caddy`) — the same instance
REQ-005 appended `api.cupidus.app`'s `reverse_proxy` block to
(`deployment/caddy/api.cupidus.app.caddy`, `STORY-001/devops/vps-caddy-edge-evidence.md`
in REQ-005). No second web server is introduced; the apex domain gets its own
site block on that same Caddy instance, serving static files instead of
proxying.

Astro's `build.format: 'directory'` output means an extensionless link like
`<a href="/pets">` must resolve to `/pets/index.html`. Caddy's documented
`try_files` + `file_server` pair (the Caddy-native equivalent of nginx's
`try_files $uri $uri/index.html $uri/ =404`) handles this: `try_files` first
checks for a file/directory match and rewrites the request path to it, and
`file_server`'s directory index behavior serves `index.html` when the
rewritten path is a directory, `=404` when nothing matched.

Site block to append below the existing `vocabik`/`api.cupidus.app` blocks in
`/etc/caddy/Caddyfile` (same apply procedure as REQ-005 §1: timestamped
backup, `caddy validate`, `systemctl reload` — never `restart` — then
re-verify `vocabik.com`/`api.vocabik.com`/`api.cupidus.app` are unaffected):

```caddyfile
cupidus.app, www.cupidus.app {
	root * <VPS_WEB_DEPLOY_PATH>/current
	try_files {path} {path}/ =404
	file_server
}
```

**Status: NOT applied to the live VPS by this phase.** Per this phase's
scope (repository configuration + CI authoring only, no live deploy or VPS
mutation), this block is documentation only. Applying it is the same
manual/SSH operational step REQ-005 §1 performed for `api.cupidus.app`, to be
run once this pipeline is ready for a live cutover.

### 5. GitHub Actions secrets

| Secret | Status | Purpose | Notes |
|---|---|---|---|
| `VPS_SSH_HOST` | Reused | VPS address | `84.247.140.178`, same as `deploy-backend.yml` |
| `VPS_SSH_USER` | Reused | VPS login user | `root` |
| `VPS_SSH_PORT` | Reused | VPS SSH port | `22` |
| `VPS_SSH_PRIVATE_KEY` | Reused | Deploy private key | See finding below — REQ-005 documented this key's server-side forced command as scoped to the backend's own path only. |
| `VPS_SSH_KNOWN_HOSTS` | Reused | Pinned host key | Prevents MITM; `StrictHostKeyChecking=no` is prohibited in `vps-deploy-web.sh`, same as `vps-deploy.sh`. |
| `VPS_WEB_DEPLOY_PATH` | **NEW — placeholder only, not provisioned by this phase** | Deploy directory root on the VPS for the web static release-swap layout (§3) | Exact new secret to provision, e.g. `gh secret set VPS_WEB_DEPLOY_PATH --body <path>`. No value invented here. |

No other secret is read by `deploy-web.yml` or `vps-deploy-web.sh`. There is
no GHCR/container secret for this pipeline (§3).

**Finding — forced-command key scope (report only, not fixed by this
phase):** REQ-005's `vps-deploy.sh` documents that `VPS_SSH_PRIVATE_KEY`'s
`authorized_keys` entry is restricted server-side by a forced-command
wrapper (`/root/.ssh/deploy-wrapper.sh`) that only executes commands
prefixed with the literal, unquoted string `cd ${VPS_DEPLOY_PATH} && `
(currently `cd /var/www/backend && `), and REQ-005's own configuration guide
notes this key was "Scoped to this backend deploy unit only — do not reuse
for a second deploy unit." `vps-deploy-web.sh` runs every remote command
prefixed with `cd ${VPS_WEB_DEPLOY_PATH} && ` instead, which — if the
wrapper is exactly that single hardcoded prefix — the same key will not be
authorized to run. This phase was instructed to reuse `VPS_SSH_PRIVATE_KEY`
exactly and not attempt a live deploy or SSH into the VPS, so this was not
verified against the live wrapper. Before the first real run of
`deploy-web.yml`, either confirm the wrapper accepts the web deploy path too,
widen it to allow both prefixes, or provision a second key
(`VPS_WEB_SSH_PRIVATE_KEY`) scoped to `VPS_WEB_DEPLOY_PATH` the same way the
backend key is scoped to `VPS_DEPLOY_PATH`.

### 6. Deploy trigger and rollback behavior

- Trigger: `push` to `main` (paths scoped to `web/**`,
  `.github/workflows/deploy-web.yml`,
  `.github/workflows/scripts/vps-deploy-web.sh`) plus manual
  `workflow_dispatch`. No overlap with `deploy-backend.yml`'s `backend/**` +
  its own workflow/script paths.
- `concurrency: group: deploy-web-production, cancel-in-progress: false`
  serializes runs, same posture as `deploy-backend-production`.
- `build` must fully succeed (install, `astro check`, `astro build`) before
  `deploy-and-verify` starts; a build or type-check failure never reaches the
  VPS.
- On the VPS: back up `current` to `previous` → upload to `incoming` → swap
  `incoming` into `current` → poll `https://cupidus.app/` with bounded
  retries → on failure, swap `previous` back into `current` and exit
  non-zero (the run goes red, the site stays up).
