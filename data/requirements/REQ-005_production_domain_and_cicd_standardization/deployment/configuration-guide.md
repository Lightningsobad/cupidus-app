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
package is **private**; the VPS authenticates the pull with `GHCR_PULL_TOKEN`.

**F2 fix (requirement-integration review rework):** provisioning
`GHCR_PULL_TOKEN` as a secret was necessary but not sufficient — nothing in
`vps-deploy.sh` ever consumed it, so `docker compose pull` on the VPS ran
unauthenticated against a private package. Fixed by adding a `docker login
ghcr.io` step to `vps-deploy.sh`, run over SSH before the pull, with the
token piped on stdin (`--password-stdin`) so it never appears in the command
string or logs. Chose "keep private + VPS login" over "flip the package
public" because OID-3 already decided private is the safer default (image
contains built application code) and login-side is the smaller-risk change —
it needs no GHCR visibility change and no re-decision of OID-3. The login
username is `GHCR_PULL_USER`, a non-secret workflow env var set from
`${{ github.repository_owner }}` (not a new required secret); this assumes
the real `GHCR_PULL_TOKEN` value the user provisioned belongs to that GitHub
account. If it does not, `docker login` will fail visibly at deploy time and
the fix is to re-provision `GHCR_PULL_TOKEN` under that account, not to
change this file.

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

## STORY-001 — `api.cupidus.app` hostname, origin TLS, Cloudflare edge

Owner: DevOps. Revision: R2 (Caddy host site block; see
`STORY-001/architecture/solution.md` section 1A for why the original
containerized-nginx-on-443 design was replaced). Last updated: 2026-08-21.

### 1. TLS terminator

`api.cupidus.app` is terminated by the shared VPS's **existing host Caddy**
instance (`/etc/caddy/Caddyfile`, systemd unit `caddy`), not by a container in
this repository. This is the same Caddy instance already serving the
unrelated live production site `vocabik.com` / `www.vocabik.com` /
`api.vocabik.com` — it is shared, multi-tenant infrastructure, not owned
solely by this project.

In-repo source of truth for the installed block:
`deployment/caddy/api.cupidus.app.caddy`:
```
api.cupidus.app {
	reverse_proxy 127.0.0.1:3010 {
		header_up X-Forwarded-For {remote_host}
		header_up X-Real-IP {remote_host}
		header_up Host {host}
	}
}
```
Re-apply after drift: back up `/etc/caddy/Caddyfile` on
`root@84.247.140.178` (timestamped copy), append this block below the
existing `vocabik` blocks (never edit or reorder them), `caddy validate
--config /etc/caddy/Caddyfile`, and only if that exits 0, `systemctl reload
caddy` (never `restart`). Immediately re-check
`curl -sSI https://vocabik.com` and `https://api.vocabik.com` still return
their pre-change status.

**Status: installed and reloaded on the live VPS (2026-08-21).** Backup at
`/etc/caddy/Caddyfile.bak.20260821104848` on the VPS. `caddy validate`
exited 0; `systemctl reload caddy` succeeded (`ExecReload ... status=0`,
service uptime unaffected — confirmed a reload, not a restart). Co-tenant
regression gate passed: `vocabik.com` and `api.vocabik.com` returned
identical HTTP status before and after.

### 2. Backend published host port (cross-story contract value)

**3010** — `127.0.0.1:3010:3000`, loopback-only. Owned by STORY-001
(selected and recorded here), consumed by STORY-002's
`backend/docker-compose.prod.yml` and its health gate. **Not `3000`** — that
port is held by the live `vocabik` tenant on this shared host. Confirmed
free by two independent `ss -ltnp` checks (STORY-001 and STORY-002).

### 3. Certificate lifecycle

Caddy's automatic HTTPS obtains a **publicly trusted** ACME certificate
(Let's Encrypt) — not a Cloudflare Origin CA certificate. No certificate or
key material is ever committed to this repository; nothing is mounted from
this repo for TLS. Renewal is automatic, beginning ~30 days before expiry.

**Renewal-failure recovery runbook (mandatory to know before it's needed):**
TLS-ALPN-01 cannot succeed while the record is Cloudflare-proxied (the
Cloudflare edge, not the origin, terminates the ALPN handshake seen by
challengers). Caddy falls back to HTTP-01 automatically, which generally
still works behind the proxy because Cloudflare forwards `.well-known`
ACME challenge paths. If a renewal ever fails and the certificate is close
to expiry: set the `api.cupidus.app` DNS record back to DNS-only (grey
cloud, `scripts/cloudflare/` — invert `set-api-dns-proxied.sh`'s logic or
edit via API directly), let Caddy renew against the direct HTTP-01
challenge, confirm with `openssl s_client -connect 84.247.140.178:443
-servername api.cupidus.app`, then re-run `set-api-dns-proxied.sh` to
re-proxy.

**Status: ISSUED (2026-08-21).** `api.cupidus.app` holds a production Let's
Encrypt certificate (`issuer: acme-v02.api.letsencrypt.org-directory`,
confirmed via the origin's Caddy journal: `"certificate obtained
successfully"`), obtained automatically once the DNS record existed. During
issuance a stray, long-lived (pre-existing, host-setup-time) background retry
goroutine was found attempting the **staging** ACME endpoint for this host —
fully investigated and root-caused as unrelated to any current config (no
`acme_ca`/staging directive exists anywhere on this host); a second graceful
`systemctl reload caddy` cleared it and the fresh attempt correctly used
production. See `STORY-001/coding-plan/test-results.md` section 11b and
`STORY-001/devops/vps-caddy-edge-evidence.md` for the full investigation and
raw journal evidence.

### 4. Zone SSL/TLS mode

Target (user decision, 2026-08-21, superseding the original Full (strict)
target): **Flexible**. Neither value can be set via the API — the token's
"SSL and Certificates" permission gap blocks `GET`/`PATCH
/zones/:zone_id/settings/ssl` for every value, confirmed against both
`strict` and `flexible` (same 9109 permission error both times, not
value-specific).

**Status: cannot be changed via API (permission-blocked); current live mode
determined non-mutatingly and found to already exceed the Flexible target.**
Live traffic evidence (tailing the origin's Caddy journal during a real
request through the Cloudflare edge) shows Cloudflare connecting to the
origin over **HTTPS/TLS 1.3 on port 443** with a completed handshake and
correct SNI — not plaintext HTTP on port 80, which rules out Flexible/Off and
confirms the zone is already behaving as Full or Full (strict) (traffic
alone cannot distinguish the two, but the origin's certificate is now a
genuine publicly trusted Let's Encrypt cert, so Full-strict-level validation
would also pass). `https://api.cupidus.app` now returns a live `HTTP/2 200`
through the Cloudflare edge — STORY-002 has since deployed the backend on
`127.0.0.1:3010`; the earlier `502 dial tcp 127.0.0.1:3010: connect:
connection refused` was transient (that backend was not yet deployed) and
confirmed the TLS layer already worked end-to-end even before the backend
went live. See `STORY-001/coding-plan/test-results.md` section 11c for the
original TLS-layer evidence and the review report's Independent Verification
(2026-08-21) for the current live `200`.

### 5. DNS record

`scripts/cloudflare/create-api-dns-record.sh`: idempotent, fail-closed
script. Enumerates existing `cupidus.app` records for `api.cupidus.app`
first; refuses to mutate (non-zero exit, prints the conflicting record
verbatim) if a non-matching record already exists; re-running against an
already-correct record is a no-op success. Creates the record **DNS-only**
(`proxied: false`) on first creation — required because the stock Caddy
binary on the VPS has no DNS-01 ACME plugin, so the first HTTP-01 challenge
must reach the origin directly.

Ordered sequence (each script is independently idempotent):
1. `scripts/cloudflare/create-api-dns-record.sh` — create DNS-only.
2. Confirm certificate issuance (`openssl s_client -connect
   84.247.140.178:443 -servername api.cupidus.app`, `curl -sS
   https://api.cupidus.app`).
3. `scripts/cloudflare/set-api-dns-proxied.sh` — flip to proxied; re-verify
   `https://api.cupidus.app` through the Cloudflare edge.
4. ~~`scripts/cloudflare/set-zone-ssl-full-strict.sh` — raise zone SSL
   mode.~~ **Superseded, do not run.** This script's name and intent
   (Full (strict)) no longer match section 4's target (Flexible), and it is
   not currently executable against *either* value regardless: the token
   lacks the "SSL and Certificates" permission group needed by
   `GET`/`PATCH /zones/:zone_id/settings/ssl` for any target mode (see D1 in
   `STORY-001/review/review-report.md` and section 7 below). Tracked for
   cleanup (rename or replace) once that permission gap is resolved.

**Status: steps 1-3 EXECUTED and verified; step 4 SUPERSEDED/BLOCKED** (token
permission gap — see section 7). `CLOUDFLARE_API_TOKEN` is exported in
`~/.zshrc` (interactive shells only) with `Zone:DNS:Edit` on `cupidus.app`,
sufficient for steps 1 and 3, but lacks any "SSL and Certificates" permission
needed by step 4, for either the superseded `strict` value or the current
Flexible target. `CLOUDFLARE_ZONE_ID` is looked up at run time via `GET
/zones?name=cupidus.app` rather than hardcoded. The DNS record now exists,
is proxied through Cloudflare, and resolves publicly to Cloudflare anycast
IPs (`172.67.141.59`, `104.21.62.250`). No dashboard step was used at any
point (AC1) — all mutations went through the four scripts in this section.

### 6. `api-cupid.tikup.me` legacy hostname

Disposition: **kept, unchanged, byte-for-byte** (AC3). Read-only VPS
inspection (`STORY-002/devops/vps-inspection.md`) found it has **no live
routing anywhere on this VPS** and the `cupid-nginx` container that would
have served it has never run. There is nothing to overwrite. Its final
keep/merge/remove disposition remains an open item, not decided by this
story.

### 7. Open blocker

1. ~~`CLOUDFLARE_TOKEN_IP_RESTRICTED`~~ — RESOLVED (2026-08-21): user widened
   the token's IP Address Filtering allow-list; DNS record creation and the
   proxy flip both succeeded from this environment afterward.
2. `CLOUDFLARE_TOKEN_MISSING_SSL_PERMISSION` (current, narrowed impact) —
   the same token cannot read or write the zone's SSL/TLS mode
   (`GET`/`PATCH /zones/:zone_id/settings/ssl`), failing with Cloudflare
   error 9109 `"Unauthorized to access requested resource"` for every value
   attempted (`strict` and `flexible` both fail identically) — a
   **permission** rejection (the zone's "SSL and Certificates" permission
   group, distinct from "Zone Settings"), not the already-resolved
   IP-location rejection that reused the same error code with a different
   message. `dns_records:edit`/`read` are unaffected. Non-mutating traffic
   evidence (section 4) shows this is not blocking AC2's practical outcome:
   the zone is already completing successful HTTPS connections to the
   origin's valid certificate today. **Needs a decision from the
   user/Scrum Master only if an exact API-confirmed mode name is still
   required, or if the mode needs to change again in the future**: add the
   "SSL and Certificates" Edit permission to this token (scoped to
   `cupidus.app` only), or issue a replacement token that includes it, then
   re-run `scripts/cloudflare/set-zone-ssl-full-strict.sh` (or a
   Flexible-mode variant of it).

`https://api.cupidus.app` is live and reachable through Cloudflare with a
publicly trusted origin certificate (sections 1 and 3) and now returns a live
`HTTP/2 200` end-to-end — STORY-002 has deployed the backend listening on
`127.0.0.1:3010` on the VPS and is `DONE`. The earlier hold on REQ-006/REQ-007
client builds pointing at this host as "fully live" is lifted: both this
blocker (narrowed to a non-blocking exact-mode-name gap, see D1 in
`STORY-001/review/review-report.md`) and STORY-002's backend deploy are now
resolved.

### 8. Secret handling (AC5)

No Cloudflare credential value was invented, guessed, reused from an
unrelated purpose, or written to any tracked file in this change. The one
Cloudflare-adjacent value found locally (`~/.zshrc`'s `cf-tunnel` alias, a
Cloudflare Tunnel/Argo token) is a different credential type for a different
product and was not used.
