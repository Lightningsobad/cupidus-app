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

**DNS (found missing at live cutover, 2026-08-22):** unlike `api.cupidus.app`
(created in REQ-005), no `cupidus.app` apex or `www.cupidus.app` record
existed on the Cloudflare zone before this deploy — `dig` returned nothing
for both, confirmed against the zone's own nameservers first. Created via
the same Cloudflare API mechanism REQ-005 used (`CLOUDFLARE_API_TOKEN`,
`CLOUDFLARE_ZONE_ID` for `cupidus.app`, resolved the same way): two new
`A` records, `cupidus.app` and `www.cupidus.app` → `84.247.140.178`,
DNS-only/unproxied (`proxied:false`), matching `create-api-dns-record.sh`'s
posture so Caddy's HTTP-01 challenge could reach the origin directly for
first cert issuance. No existing record was overwritten (both were absent,
verified before create). The `VPS_WEB_DEPLOY_PATH` directory itself
(`/var/www/web`) also had to be pre-created out-of-band before the first CI
run, for an unrelated reason tied to the forced-command key scope — see §5.

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

**Status: APPLIED to the live VPS (2026-08-22).** Backed up
`/etc/caddy/Caddyfile` to a timestamped `.bak`, appended this block below the
`vocabik`/`api.cupidus.app` blocks, ran `caddy validate` (exit 0), then
`systemctl reload caddy` (never `restart`). `vocabik.com` (200),
`api.vocabik.com` (404, unchanged pre-existing baseline), and
`api.cupidus.app` (200) were re-verified unaffected. `cupidus.app` and
`www.cupidus.app` DNS did not exist yet at cutover time — see the DNS note
added to §3 below — so both were created (DNS-only, unproxied) before this
reload. Full evidence: `deployment/deployment-log.md`.

### 5. GitHub Actions secrets

| Secret | Status | Purpose | Notes |
|---|---|---|---|
| `VPS_SSH_HOST` | Reused | VPS address | `84.247.140.178`, same as `deploy-backend.yml` |
| `VPS_SSH_USER` | Reused | VPS login user | `root` |
| `VPS_SSH_PORT` | Reused | VPS SSH port | `22` |
| `VPS_SSH_PRIVATE_KEY` | **Not used by this pipeline** | Backend deploy private key | Confirmed still forced-command-scoped to `/var/www/backend` only (see finding below); `deploy-web.yml` does not reference it. |
| `VPS_WEB_SSH_PRIVATE_KEY` | **NEW — provisioned 2026-08-22** | Web deploy private key, dedicated to `VPS_WEB_DEPLOY_PATH` | Fresh `ed25519` keypair, comment `github-actions-deploy-cupidus-web`. Private key bytes never printed/echoed/committed. |
| `VPS_SSH_KNOWN_HOSTS` | Reused | Pinned host key | Prevents MITM; `StrictHostKeyChecking=no` is prohibited in `vps-deploy-web.sh`, same as `vps-deploy.sh`. |
| `VPS_WEB_DEPLOY_PATH` | **NEW — provisioned 2026-08-22** | Deploy directory root on the VPS for the web static release-swap layout (§3) | `/var/www/web`, sibling convention to backend's `VPS_DEPLOY_PATH=/var/www/backend`. |

No other secret is read by `deploy-web.yml` or `vps-deploy-web.sh`. There is
no GHCR/container secret for this pipeline (§3).

**Finding — forced-command key scope, confirmed real and resolved
(2026-08-22):** the risk this section previously flagged as unverified was
checked directly against the live VPS before the first real deploy attempt.
Reading (read-only) `/root/.ssh/authorized_keys` and
`/root/.ssh/deploy-wrapper.sh` confirmed `VPS_SSH_PRIVATE_KEY`'s
`authorized_keys` entry is restricted server-side by a forced-command
wrapper that only executes commands prefixed with the literal, unquoted
string `cd /var/www/backend && ` — exactly the risk this section had
flagged, not a false alarm. Reusing this key for `vps-deploy-web.sh`
(prefixed `cd ${VPS_WEB_DEPLOY_PATH} && `) would have been rejected at the
first remote command.

Per explicit user decision (relayed by Scrum Master/team-lead), resolved by
provisioning a **second, dedicated key** rather than widening the backend's
wrapper or its `authorized_keys` line:
- Generated a fresh `ed25519` keypair in scratch space (never inside the
  repo/worktree), comment `github-actions-deploy-cupidus-web`.
- Installed a new, separate wrapper `/root/.ssh/deploy-web-wrapper.sh` (mode
  700, owner root:root) mirroring `deploy-wrapper.sh`'s structure, with
  `ALLOWED_PREFIX="cd /var/www/web && "`.
- Appended one new `authorized_keys` line —
  `command="/root/.ssh/deploy-web-wrapper.sh",no-port-forwarding,no-agent-forwarding,no-pty ssh-ed25519 <key> github-actions-deploy-cupidus-web`
  — without modifying the pre-existing backend key line or
  `deploy-wrapper.sh` at all (file grew from 3 to 4 lines, backed up first).
- Verified end-to-end before wiring GitHub secrets: allowed-prefix commands
  (`cd /var/www/web && ...`) succeed; commands outside that prefix, and
  commands using the *backend's* prefix from this *new* key, are both
  rejected with `deploy-web-wrapper: command not permitted for this key`.
- Also found and fixed two related `vps-deploy-web.sh` bugs during this
  same verification: (1) its original pre-deploy command started with
  `mkdir -p ${VPS_WEB_DEPLOY_PATH} && cd ... && `, which can never match a
  literal `cd ${VPS_WEB_DEPLOY_PATH} && ` prefix regardless of wrapper
  scope — fixed by pre-creating `/var/www/web` out-of-band (same bootstrap
  convention as the backend path) and dropping the leading `mkdir -p`; (2)
  its upload/count commands used `cd ${VPS_WEB_DEPLOY_PATH}/incoming && `,
  a different literal prefix than the wrapper allows — fixed to
  `cd ${VPS_WEB_DEPLOY_PATH} && cd incoming && `. Committed at `4517954`.

`deploy-web.yml` now maps `VPS_SSH_PRIVATE_KEY` (script env var name,
unchanged) from `secrets.VPS_WEB_SSH_PRIVATE_KEY`, not
`secrets.VPS_SSH_PRIVATE_KEY`.

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
- **First live run: `4517954` (push to `main`), completed `success` in 57s**
  — the same push that fixed the §5 forced-command bugs also matched this
  trigger's paths and auto-deployed. Health gate passed against the live
  Caddy site added in §4. See `deployment/deployment-log.md`.
