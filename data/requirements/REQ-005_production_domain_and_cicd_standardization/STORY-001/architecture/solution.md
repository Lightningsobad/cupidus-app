# STORY-001 Solution: Point api.cupidus.app at the production backend API

## 0. Metadata

- Complexity: standard
- Date: 2026-08-21

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC1 (scripted Cloudflare DNS), AC2 (HTTPS on
  `api.cupidus.app`), AC3 (inspect, do not blindly overwrite the legacy vhost),
  AC4 (no SSH key rotation), AC5 (placeholder-secret handling).
- Architectural invariants / non-goals:
  - The Cloudflare edge -> origin leg crosses the public internet and MUST be
    encrypted **and** authenticated. This API carries auth tokens and member
    PII; a plaintext or unauthenticated origin leg is not acceptable.
  - The `api.cupidus.app` DNS record MUST stay Cloudflare-**proxied**. See the
    trust-chain consequence in section 4.
  - No SSH key is generated or rotated (AC4). No change to how the backend is
    built or deployed (that is STORY-002).
  - No origin private key or certificate is ever committed to this repository.
- Proposed technical direction: terminate TLS at the VPS nginx using a
  **Cloudflare Origin CA certificate**, and set the `cupidus.app` zone SSL/TLS
  mode to **Full (strict)**. DNS is a scripted, idempotent Cloudflare API call
  that refuses to act when a conflicting record already exists.
- Why this fits the current system: the VPS already runs an nginx reverse proxy
  container in front of `backend:3000`. This story upgrades that existing edge
  rather than introducing a new component.

### Key Discovery

`backend/docker-compose.yml` shows the origin **cannot terminate TLS at all
today**: the `nginx` service publishes only `"80:80"`, mounts only
`./nginx/default.conf`, and has no certificate volume. The requirement framed
this story as "a DNS change plus a vhost edit", but the real work is adding a
443 listener, a certificate material path, and a certificate lifecycle to a
container that has none. Any plan that only edits `server_name` produces a
record that resolves and then fails the TLS handshake at the origin.

Second discovery: a Cloudflare **Origin CA** certificate is not publicly
trusted — it is trusted only by the Cloudflare proxy. That makes "keep the
record proxied" a hard runtime invariant, not a preference: greying out the
orange cloud later turns AC2 into a browser certificate error. This is the
single most likely way this story silently regresses after it is marked DONE.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (consumed by REQ-006
  web and REQ-007 mobile, which set this host as their production API base URL).

## 3. Scope And Assumptions

- In Scope: `cupidus.app` Cloudflare zone DNS + SSL mode; the VPS nginx vhost,
  443 listener, and certificate material path; the scripts that perform both.
- Out Of Scope: backend build/deploy mechanism (STORY-002), backend application
  code, REQ-006/REQ-007 client configuration.
- Assumptions affecting design:
  - The operator has Cloudflare API access to the `cupidus.app` zone and
    existing working SSH access to `root@84.247.140.178` (AC4 forbids minting a
    new key unless the existing one is proven broken).
  - **Unverified third-party mechanics.** `WebSearch`/`WebFetch` were not
    callable in this planning session (`ToolSearch` is disabled), so the exact
    Cloudflare Origin CA issuance mechanics for 2026 — API endpoint, whether it
    requires an Origin CA Key rather than a scoped API token, and the offered
    certificate validity periods — are **not** verified here and are
    deliberately not written into the plan as fact. P1 resolves them against
    the live Cloudflare API and current documentation at execution time and
    records the result in `deployment/configuration-guide.md`. The *decision*
    below does not depend on those mechanics; only the provisioning steps do.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| Nginx VPS-target ambiguity | UNRESOLVED | Deleting/retargeting the `api-cupid.tikup.me` vhost | Adding a second `api.cupidus.app` server block alongside it | Keep the legacy server block byte-for-byte; add a new one. Disposition of the legacy name stays an open item recorded in the config guide, not decided here. |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: the `nginx` service in `backend/docker-compose.yml`
  (VPS-only, `vps` Compose profile) and its mounted `backend/nginx/` config.
- New or changed boundaries: the VPS edge becomes a TLS terminator. A new
  trust boundary appears between the Cloudflare proxy and the origin, secured
  by the Origin CA certificate under Full (strict).
- Shared patterns reused or introduced: certificate material is mounted
  read-only from a gitignored host path, never baked into an image.

### Affected Modules

- Infrastructure: `backend/nginx/` (vhost + certificate mount),
  `backend/docker-compose.yml` (443 publish + volume), `scripts/cloudflare/`
  (new; DNS and certificate provisioning), `deployment/` (new config guide).

### Contracts And Integrations

- Error and empty-state contract: the DNS script MUST be idempotent and
  fail-closed — it enumerates existing `cupidus.app` records first and **exits
  non-zero without mutating** when a record for `api` already exists with a
  different target or proxy status (AC1). Re-running against an already-correct
  record is a no-op success, not a duplicate record.
- Compatibility posture: additive only. The existing `api-cupid.tikup.me`
  server block is preserved unchanged so the legacy name keeps working on
  port 80 (AC3).
- Trust-boundary implications: Full (strict) means Cloudflare validates the
  origin certificate on every request. A missing, expired, or mismatched origin
  certificate is a hard 526 outage, not a degraded mode — so the certificate
  must be installed and `nginx -t` clean **before** the SSL mode is raised.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Origin TLS trust chain | Cloudflare zone SSL mode + origin cert on VPS | Origin CA cert installed and nginx serving 443 *before* raising mode to Full (strict); record stays proxied | `curl -sSI https://api.cupidus.app` returns a backend response; `openssl s_client` against the origin IP:443 presents the Origin CA cert | Stop; leave SSL mode unchanged and report — do not leave the zone in Full (strict) with no origin cert |
| Legacy vhost regression | `backend/nginx/default.conf` | Add a new server block; leave the `api-cupid.tikup.me` block untouched | `nginx -t` passes and the legacy block is unchanged in the diff | Stop and report the conflict rather than editing the legacy block |
| Cloudflare DNS zone mutation | `cupidus.app` zone via Cloudflare API | Enumerate-then-create; fail-closed on any conflicting `api` record | Script run shows the pre-check output and either a created record id or a no-op | Stop and report the conflicting record verbatim; do not overwrite or delete |
| VPS access credential handling | Existing authorized keys on `root@84.247.140.178` | Reuse existing keys; generate nothing (AC4) | A plain `ssh` command succeeds with existing credentials | If SSH fails, stop and report — a rotation needs explicit user confirmation first |
| Secret and key material exposure | Cloudflare API credential; Origin CA private key | Credential supplied via env var and, if absent, a placeholder GitHub secret per AC5; private key generated on the VPS and gitignored | `git status` clean of key/cert material; no credential literal in any tracked file | Stop; never inline a real credential to unblock |

### Lane Handoff

#### DevOps Lane

- Responsibilities: certificate provisioning, nginx vhost + 443 listener,
  Compose port/volume change, scripted DNS record, SSL mode change, config guide.
- Authoritative inputs: `../requirements/requirements.md` (AC1-AC5), this
  document, `backend/nginx/default.conf`, `backend/docker-compose.yml`.
- Guardrails:
  - Do NOT generate or rotate any SSH key unless existing access is proven
    broken; if it is, stop and get user confirmation before rotating (AC4).
  - Do NOT edit or delete the `api-cupid.tikup.me` server block (AC3).
  - Do NOT commit any `.key`, `.pem`, `.crt`, or credential value; add the
    certificate directory to `.gitignore` in the same change.
  - Do NOT raise the zone SSL mode to Full (strict) before the origin serves a
    valid certificate on 443.
  - Do NOT use the Cloudflare dashboard for the DNS record (AC1).
- Requirement configuration guide update (DevOps lane only): REQUIRED

## 5. Non-Functional Impact

- Certificate expiry is a scheduled outage source: whatever validity the Origin
  CA issues, the expiry date and the renewal command must be recorded in
  `deployment/configuration-guide.md` — an unrecorded expiry is the failure
  mode this design otherwise has no defence against.
- Publishing 443 widens the VPS network surface; the 443 listener must serve
  only this vhost and must not become a default catch-all server.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Full (strict) + Cloudflare Origin CA cert at the VPS nginx | Encrypts *and* authenticates the origin leg; long-lived cert avoids an ACME renewal path that would need un-proxied port 80 | ACCEPTED | Cost: origin must gain a 443 listener and cert volume (see Key Discovery). Binds the host to proxied mode. |
| Flexible (Cloudflare edge cert only, plaintext to origin) | Cheapest — needs no origin change at all, satisfies "HTTPS in the browser" literally | REJECTED | Sends auth tokens and member PII in cleartext across the public internet on the edge->origin hop. Violates the section 1 invariant. |
