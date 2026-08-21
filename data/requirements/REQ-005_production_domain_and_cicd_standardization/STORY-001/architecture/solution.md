# STORY-001 Solution: Point api.cupidus.app at the production backend API

## 0. Metadata

- Complexity: standard
- Date: 2026-08-21
- Revision: R2 (2026-08-21). R1 terminated TLS at a containerized nginx
  publishing host port 443 with a Cloudflare Origin CA certificate. That
  mechanism is structurally impossible on this host and has been replaced —
  see section 1A.

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC1 (scripted Cloudflare DNS), AC2 (HTTPS on
  `api.cupidus.app`), AC3 (inspect, do not blindly overwrite the legacy vhost),
  AC4 (no SSH key rotation), AC5 (placeholder-secret handling).
- Architectural invariants / non-goals:
  - The Cloudflare edge -> origin leg crosses the public internet and MUST be
    encrypted **and** authenticated. This API carries auth tokens and member
    PII; a plaintext or unauthenticated origin leg is not acceptable.
  - This VPS is **shared, multi-tenant infrastructure**. An unrelated live
    production site (`vocabik.com`, `www.vocabik.com`, `api.vocabik.com`) is
    served by the host Caddy on ports 80/443 and MUST NOT be disrupted. No
    artifact of this story may bind host port 80 or 443.
  - No SSH key is generated or rotated (AC4). No change to how the backend is
    built or deployed (that is STORY-002).
  - No private key or certificate material is ever committed to this repository.
- Proposed technical direction: add an `api.cupidus.app` **site block to the
  existing host Caddy** (`/etc/caddy/Caddyfile`), reverse-proxying over loopback
  to the backend container's published host port. Caddy's built-in automatic
  HTTPS obtains and renews a **publicly trusted** certificate; the Cloudflare
  record stays **proxied** and the zone SSL/TLS mode is set to **Full (strict)**.
  DNS is a scripted, idempotent Cloudflare API call that refuses to act when a
  conflicting record already exists.
- Why this fits the current system: the VPS already terminates TLS for a live
  production site with exactly this pattern. This story adds one more site block
  to a proven, running edge instead of introducing a second, competing one.

### 1A. Why R1 Was Replaced

R1 assumed the repo's `nginx` service was the live VPS edge and only needed a
443 listener bolted on. Read-only inspection of the live VPS (STORY-002,
`../../STORY-002/devops/vps-inspection.md`, sections "Legacy
`api-cupid.tikup.me` vhost/compose inventory" and "Critical finding") proved
otherwise:

- Host **Caddy** (`systemctl status caddy`: active since 2026-06-08, config
  `/etc/caddy/Caddyfile`) is the **sole listener** on `:80` and `:443`
  (`ss -ltnp`, pid 570281). It serves the unrelated live `vocabik` site.
- The `cupid-nginx` container R1 planned to extend **has never run on this
  VPS** — it is absent even from `docker ps -a`. The repo config and the live
  host have simply never matched.
- Therefore a container publishing `80:80` or `443:443` **cannot start** here;
  it would collide with the port Caddy holds for a live third-party site.

R1's TLS mechanism was not merely suboptimal — it could not have started. This
revision changes the terminator, not the story's goal or its security posture.

### Key Discovery 1 — the edge already exists and is not ours alone

The TLS edge for this host is a shared, already-running system component owned
by no story in this requirement. The unit of work is therefore *one additive
site block plus a validated graceful reload*, and the dominant risk shifts from
"can we terminate TLS at all" to "can we change a shared config without taking
down someone else's production site". Every VPS-side step below is shaped by
that: backup, `caddy validate`, `reload` (never `restart`), and a post-change
check that `vocabik` still answers.

### Key Discovery 2 — the backend's host port collides with the live tenant

The deployed VPS compose publishes the backend as `3000:3000`
(`vps-inspection.md` line 18), and the live Caddyfile already routes
`vocabik.com` to `localhost:3000`. Because `cupid-backend` has been down for
~2 months, that port was free to be taken and now is. Restarting the backend on
`3000:3000` will fail to bind, or — worse if ordering ever changes — shadow a
live third-party service.

Consequence: **this story must select and publish a free loopback host port**
for the backend and make it the value Caddy proxies to. Binding it to
`127.0.0.1` (not `0.0.0.0`) additionally removes the raw, un-TLS'd backend port
from the public internet, which the R1 design left exposed. The chosen port is a
cross-story contract value — STORY-002's `docker-compose.prod.yml` must publish
exactly the same port. See section 4 `Cross-Story Dependency`.

### Key Discovery 3 — a publicly trusted origin certificate removes R1's worst failure mode

R1 flagged that a Cloudflare Origin CA certificate is trusted **only** by the
Cloudflare proxy, making "keep the record proxied" a hard runtime invariant
whose later violation (greying out the orange cloud) silently turns AC2 into a
browser certificate error. Caddy's automatic HTTPS issues a **publicly trusted**
certificate instead, which validates in *both* proxy modes. The deployed state
is still proxied, but proxy mode is no longer a trap that a future operator can
spring by accident. This is a strict improvement on R1, not a trade-off.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (consumed by REQ-006
  web and REQ-007 mobile, which set this host as their production API base URL).

## 3. Scope And Assumptions

- In Scope: `cupidus.app` Cloudflare zone DNS record + SSL mode; the
  `api.cupidus.app` site block in the VPS `/etc/caddy/Caddyfile`; the backend's
  published loopback host port on the VPS; the scripts and config guide for both.
- Out Of Scope: backend build/deploy mechanism and `docker-compose.prod.yml`
  (STORY-002), backend application code, REQ-006/REQ-007 client configuration.
- Assumptions affecting design:
  - The operator has existing working SSH access to `root@84.247.140.178` (AC4
    forbids minting a new key unless the existing one is proven broken), and
    root-level ability to edit `/etc/caddy/Caddyfile` and reload Caddy.
  - The host Caddy is the stock distribution binary
    (`ExecStart=/usr/bin/caddy run --config /etc/caddy/Caddyfile`) and therefore
    has **no DNS-provider plugin**. The design must not require a DNS-01 ACME
    challenge, which that binary cannot perform. HTTP-01 / TLS-ALPN-01 only.
  - The live `vocabik` site blocks carry no explicit `tls` directive
    (`vps-inspection.md` lines 36-39), i.e. the host is already successfully
    running Caddy automatic HTTPS. This is corroborating evidence, not a
    dependency: the mechanism chosen below is decided on its own merits and the
    P1 task list verifies the assumption before relying on it.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| Nginx VPS-target ambiguity | RESOLVED by inspection | — | — | Resolved, not decided: `api-cupid.tikup.me` has **no live routing anywhere on this VPS** and the `cupid-nginx` container never ran. There is nothing to overwrite, so AC3 is satisfied by leaving `backend/nginx/default.conf` untouched and recording the finding. Retiring the legacy name is a separate decision, still not made here. |
| Backend host port on the shared VPS | OPEN — resolved at execution | Reusing `3000` | Selecting any port verified free by `ss -ltnp` | P1 selects one free port, binds it to `127.0.0.1`, and records it as a contract value. See Key Discovery 2. |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: the **host Caddy instance** on the VPS
  (`/etc/caddy/Caddyfile`, systemd unit `caddy`) — a system component outside
  this repository. Its in-repo source of truth for our site block is
  `deployment/caddy/api.cupidus.app.caddy`.
- New or changed boundaries: the trust boundary between the Cloudflare proxy
  and the origin is now secured by a publicly trusted, ACME-issued certificate
  under Full (strict). A second new boundary is the loopback hop from Caddy to
  the backend container, which is plaintext but never leaves the host.
- Removed from R1: the `nginx` container as TLS terminator, the host 443
  publish, the certificate volume mount, and the Cloudflare Origin CA
  certificate lifecycle. None of these exist in this design.
- Shared patterns reused: the exact `reverse_proxy localhost:PORT` site-block
  shape already proven by the `vocabik` blocks on this host.

### Affected Modules

- VPS system config (not in repo): `/etc/caddy/Caddyfile` — one appended site
  block; the backend's published host port in the deployed compose.
- Repository: `deployment/caddy/api.cupidus.app.caddy` (new; authoritative text
  of the site block, for traceability and drift detection),
  `scripts/cloudflare/` (DNS record + SSL mode, no certificate work),
  `deployment/configuration-guide.md` (new).
- Explicitly NOT changed: `backend/nginx/default.conf`,
  `backend/docker-compose.yml`. See `Lane Handoff` — R1-era prep touching these
  must be reverted.

### Contracts And Integrations

- Error and empty-state contract: the DNS script MUST be idempotent and
  fail-closed — it enumerates existing `cupidus.app` records first and **exits
  non-zero without mutating** when a record for `api` already exists with a
  different target or proxy status (AC1). Re-running against an already-correct
  record is a no-op success, not a duplicate record.
- Compatibility posture: additive only, on two axes. The Caddyfile gains a site
  block and loses nothing; the repository's legacy nginx config is untouched.
- Trust-boundary implications: Full (strict) means Cloudflare validates the
  origin certificate on every request. The origin must already be serving a
  valid certificate **before** the mode is raised, or the host returns a hard
  526.

### Cross-Story Dependency

| Value | Owner | Consumer | Rule |
|-------|-------|----------|------|
| Backend published host port on the VPS | STORY-001 (selected and recorded in `deployment/configuration-guide.md`) | STORY-002 `backend/docker-compose.prod.yml`; the STORY-002 health gate `GET http://127.0.0.1:<backend port>/` | Must be identical in both. It must NOT be `3000` (taken by the live `vocabik` tenant) and must be published on `127.0.0.1`, not all interfaces. |

STORY-002's `backend/docker-compose.prod.yml` intentionally **omits an nginx
service entirely** (`vps-inspection.md`, Critical finding item 2) for exactly
the reason established in section 1A. This revision is consistent with that
decision and completes it: STORY-002 ships no edge, STORY-001 supplies the edge
as a Caddy site block. Neither story ships a container bound to 80/443, and
STORY-002 does not touch VPS-side Caddy config — that remains STORY-001's scope.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Third-party tenant disruption (highest severity) | Live `/etc/caddy/Caddyfile` and the running `caddy` unit | Timestamped backup before edit; append-only site block; `caddy validate` before applying; `systemctl reload caddy` (graceful), never `restart`; no change to the `vocabik` blocks | `caddy validate` exits 0; after reload, `curl -sSI https://vocabik.com` and `https://api.vocabik.com` still return their pre-change status | Stop and restore the backup Caddyfile immediately; do not iterate on a live shared edge |
| Backend host-port collision | `ss -ltnp` on the VPS + live Caddyfile | Select a port proven free; bind `127.0.0.1:<port>:3000`; never reuse `3000` | `ss -ltnp` shows the chosen port free before, and bound by the backend after; `vocabik` still answers | Stop and report; do not free a port by stopping another tenant's process |
| Origin TLS trust chain | Caddy-managed certificate + Cloudflare zone SSL mode | Obtain the certificate with the record **DNS-only**, verify, then flip to proxied and raise to Full (strict) — in that order | `openssl s_client -connect 84.247.140.178:443 -servername api.cupidus.app` presents a publicly trusted certificate with a real chain; then `curl -sSI https://api.cupidus.app` returns a backend response | Stop; leave the SSL mode unchanged — never leave the zone in Full (strict) with no valid origin certificate |
| ACME renewal behind the Cloudflare proxy | Caddy logs / certificate expiry | TLS-ALPN-01 cannot succeed behind the proxy; Caddy falls back to HTTP-01 automatically. Record the documented recovery: set the record DNS-only, let Caddy renew, re-proxy | First issuance verified; renewal path and recovery runbook recorded in the configuration guide | Not a launch blocker; an unrecorded recovery path is |
| Legacy vhost regression | `backend/nginx/default.conf` | Do not modify it at all; the legacy name has no live routing to regress | The file is unchanged in the story diff | — |
| Cloudflare DNS zone mutation | `cupidus.app` zone via Cloudflare API/CLI | Enumerate-then-create; fail-closed on any conflicting `api` record | Script run shows the pre-check output and either a created record id or a no-op | Stop and report the conflicting record verbatim; do not overwrite or delete |
| VPS access credential handling | Existing authorized keys on `root@84.247.140.178` | Reuse existing keys; generate nothing (AC4) | A plain `ssh` command succeeds with existing credentials | If SSH fails, stop and report — a rotation needs explicit user confirmation first |
| Secret exposure | Cloudflare API credential used by the local CLI | Credential stays in the operator's local CLI/env and is never written to a tracked file (AC5) | `git status` and the staged diff contain no credential literal | Stop; never inline a real credential to unblock |

### Lane Handoff

#### DevOps Lane

- Responsibilities: revert R1-era prep; select and publish the backend loopback
  host port; author and install the Caddy site block; scripted DNS record; zone
  SSL mode; configuration guide.
- Authoritative inputs: `../requirements/requirements.md` (AC1-AC5), this
  document, `../../STORY-002/devops/vps-inspection.md` (ground truth for VPS
  state — do not re-run discovery).
- Guardrails:
  - Do NOT bind host port 80 or 443 from any container. That is the defect this
    revision exists to remove.
  - Do NOT `systemctl restart caddy` and do NOT edit or reorder the `vocabik`
    site blocks. Reload gracefully after `caddy validate` passes.
  - Do NOT reuse backend host port `3000`, and do NOT publish the backend on
    all interfaces — `127.0.0.1` only.
  - Do NOT generate or rotate any SSH key unless existing access is proven
    broken; if it is, stop and get user confirmation before rotating (AC4).
  - Do NOT modify `backend/nginx/default.conf` (AC3 is satisfied by leaving it
    alone).
  - Do NOT raise the zone SSL mode to Full (strict) before the origin serves a
    valid certificate.
  - Do NOT use the Cloudflare dashboard for the DNS record (AC1).
  - **Revert the uncommitted R1-era prep** in this worktree under
    `backend/nginx/default.conf`, `backend/docker-compose.yml` (443 publish and
    certificate mount), and any Origin CA provisioning under
    `scripts/cloudflare/`. It implements the superseded design. Reconcile
    against this document rather than building on top of it.
- Requirement configuration guide update (DevOps lane only): REQUIRED

## 5. Non-Functional Impact

- Certificate lifecycle becomes automatic rather than a diarised manual task.
  The residual risk moves from "someone forgets a 15-year renewal" to "a
  renewal fails silently behind the proxy". Caddy begins renewing ~30 days
  before expiry, so this fails with a wide margin rather than at the wire — but
  the recovery runbook must be written down, because nothing else in this
  system will notice.
- No new host port is exposed to the public internet. The backend port is
  loopback-only, and 443 is already open for the existing tenant. This design
  narrows the public surface relative to both R1 and the current deployed
  compose (which publishes `3000` on all interfaces).
- A shared-config edit carries blast radius beyond this project. Backup +
  validate + graceful reload is the entire mitigation, and it is mandatory.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Caddy site block + Caddy automatic HTTPS (publicly trusted cert), record proxied, Full (strict) | Uses the edge that already exists and works on this host; auto-renewing; the certificate is valid in either proxy mode | **ACCEPTED** | Cost: depends on ACME HTTP-01 reachability at renewal time behind the proxy; recovery runbook required. Removes the Origin CA lifecycle and the R1 secret dependency entirely. |
| Caddy site block + explicit `tls` with a Cloudflare Origin CA certificate | Preserves R1's exact trust model with only the terminator swapped; no ACME dependency; very long validity | REJECTED | Keeps R1's trap that proxy mode is load-bearing for client-visible TLS (Key Discovery 3), adds manual key/CSR/install state on a shared host, and retains the `ORIGIN_CERT_PROVISION_FAILED` blocker — issuance mechanics remain unverifiable in this runtime (section 7). Strictly more work for strictly less robustness. |
| Caddy site block + automatic HTTPS with the record left **DNS-only** permanently | Simplest possible; no proxy interaction at renewal at all | REJECTED | Publishes the origin IP, drops Cloudflare DDoS/WAF protection, and breaks the published consumer contract (`contract-summary.md` section 3: proxied, client IP via `X-Forwarded-For`). DNS-only is used only as a transient bootstrap step. |
| Containerized nginx terminating TLS on host 443 (R1) | Was the accepted R1 design | REJECTED — not implementable | Cannot bind 80/443 on this host; would collide with the live `vocabik` tenant. See section 1A. |
| Flexible SSL (plaintext to origin) | Cheapest; satisfies "HTTPS in the browser" literally | REJECTED | Sends auth tokens and member PII in cleartext across the public internet on the edge->origin hop. Violates the section 1 invariant. |

## 7. Verification Debt Carried Into P1

- `WebSearch`/`WebFetch` are not reachable in this planning session: the
  documented loader `ToolSearch("select:WebSearch,WebFetch")` returns
  `No such tool available: ToolSearch. ToolSearch is disabled for this session`.
  So no third-party mechanic below is asserted as verified fact here.
- Deliberately, **this design's correctness does not depend on any unverified
  third-party mechanic.** Caddy automatic HTTPS is the stock default behaviour
  of the binary already running and already issuing certificates on this exact
  host — the P1 task list confirms it against the live Caddyfile before relying
  on it, rather than against documentation.
- The R1 blocker `ORIGIN_CERT_PROVISION_FAILED` is **dissolved, not deferred**:
  no Origin CA certificate is issued in this design.
- The R1 blocker `SECRET_REQUIRED` is **dissolved**: per the user's decision,
  Cloudflare DNS work runs once from the operator's local Cloudflare CLI, so no
  `CLOUDFLARE_API_TOKEN` GitHub Actions secret and no placeholder secret are
  needed for this story. AC5 is satisfied by the negative case — no credential
  enters a tracked file — and that must be recorded in the configuration guide.
