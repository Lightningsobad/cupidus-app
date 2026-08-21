# Phase P1 – api.cupidus.app hostname, origin TLS, and Cloudflare edge

## 1. Objective

`https://api.cupidus.app` resolves through Cloudflare and serves live backend
API responses, terminated by a new site block on the VPS's existing host Caddy,
with the edge->origin leg encrypted and authenticated under Full (strict), the
co-tenant `vocabik` site undisturbed, and no SSH key generated or rotated.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-api-hostname-tls-edge.md`
- Owner: DevOps Engineer
- Lane: DevOps
- Revision: R2 (2026-08-21) — retargeted from a containerized nginx TLS edge to
  a host Caddy site block. See `../architecture/solution.md` section 1A.

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `deployment/caddy/api.cupidus.app.caddy` (new; in-repo source of truth for
    the site block installed on the VPS)
  - `scripts/cloudflare/` (DNS record + zone SSL mode only)
  - `deployment/configuration-guide.md`
  - `backend/nginx/default.conf`, `backend/docker-compose.yml`, `.gitignore`
    — **revert only**, to back out superseded R1 prep (task 1)
- Impacted Runtime Service/App:
  - Name: `backend`
  - Runtime Registry Id: `backend-api`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: backend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (unchanged by this phase)
  - Startup Command Source: runtime registry `startCommand` (unchanged by this phase)
  - Readiness Check: HTTPS response from `https://api.cupidus.app` served by the
    VPS backend container via the Caddy site block
  - Port Contract: the VPS backend publishes on `127.0.0.1:<selected free
    port>:3000`. **Not `3000`** — the live `vocabik` tenant holds host `3000`.
    No container binds host 80 or 443.
- Shared Interfaces Produced:
  - `../architecture/contract-summary.md` (production API base URL; origin-side
    port fact consumed by STORY-002)
- Risk Surfaces:
  - Third-party tenant disruption
  - Backend host-port collision
  - Origin TLS trust chain
  - ACME renewal behind the Cloudflare proxy
  - Cloudflare DNS zone mutation
  - VPS access credential handling
  - Secret exposure
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md`
    sections 1, 1A, 4
  - live VPS state: `../../STORY-002/devops/vps-inspection.md` (read-only
    reference; do NOT re-run discovery)
  - consumer contract: `../architecture/contract-summary.md`
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC1-AC5
  - architecture: `../architecture/solution.md` sections 1 (invariants), 1A
    (why R1 was replaced), 4 (risk table, DevOps guardrails)
  - OQ constraints: `../architecture/solution.md` section 3 table
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: YES
  - Sections To Update: the installed Caddy site block and how to re-apply it;
    the selected backend host port (as a cross-story contract value); Caddy
    certificate issuance and the renewal-failure recovery runbook; zone SSL/TLS
    mode and proxy status; how the Cloudflare DNS change was executed and with
    which credential mechanism; disposition status of the legacy
    `api-cupid.tikup.me` name
- Phase Sizing:
  - Behavior Slice: one behavior cluster — make one hostname reach the backend
    over authenticated TLS. Revert, port selection, site block, and DNS are
    steps of it, not separate clusters.
  - Source/Test File Count: 3 authored + 3 reverted
  - Split Required: NO
  - Split Rationale: fits one specialist lifecycle in one lane; splitting would
    add a dispatch and a verification pass without removing any dependency.

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../architecture/contract-summary.md`
- `../../STORY-002/devops/vps-inspection.md` sections "Legacy
  `api-cupid.tikup.me` vhost/compose inventory" and "Critical finding"

## 3. Tasks

Execute in this order. The ordering is load-bearing twice over: a Caddyfile
edit applied without validation can take down a third party's live site, and
raising the SSL mode before the origin serves a certificate produces a hard 526.

1. **Revert the superseded R1 prep.** In this worktree, back out the
   uncommitted changes to `backend/nginx/default.conf`,
   `backend/docker-compose.yml` (443 publish, certificate mount), `.gitignore`
   (certificate-directory rule), and any Origin CA provisioning under
   `scripts/cloudflare/`. They implement a design that cannot start on this
   host. Do not build on top of them. `backend/nginx/default.conf` must end up
   byte-for-byte at its pre-story state (AC3 is now satisfied by leaving the
   legacy vhost entirely alone).
2. **Verify access without changing it.** Confirm `ssh root@84.247.140.178`
   works with the existing authorized key. Do NOT generate or rotate any key.
   If access fails, STOP and report — rotation needs explicit user confirmation
   (AC4).
3. **Confirm the two facts this design rests on, read-only, on the VPS.**
   (a) `cat /etc/caddy/Caddyfile` — confirm the `vocabik` site blocks carry no
   explicit `tls` directive, i.e. Caddy automatic HTTPS is already in use on
   this host. (b) `ss -ltnp` — capture the full listener list. If (a) is false
   (the blocks do pin explicit certificate files), STOP and report before
   choosing an issuance mechanism; do not guess. Record both outputs as
   evidence.
4. **Select the backend host port.** From the task 3 listener list, choose a
   free port (`3000` is taken by the live `vocabik` app and is forbidden).
   Record it in the configuration guide as a cross-story contract value, and
   flag it to Scrum Master for STORY-002, whose `docker-compose.prod.yml` and
   health gate must use the identical port. Publish it as
   `127.0.0.1:<port>:3000` — loopback only, so the plaintext backend port is
   never reachable from the internet.
5. **Author the site block in the repo first.** Write
   `deployment/caddy/api.cupidus.app.caddy` containing the intended block,
   matching the proven co-tenant shape:
   `api.cupidus.app { reverse_proxy localhost:<port> }`. This is the in-repo
   source of truth; the VPS copy is installed from it so drift is detectable.
6. **Create the DNS record via script, DNS-only for now.** Add an idempotent
   script under `scripts/cloudflare/` that enumerates existing `cupidus.app`
   records, exits non-zero without mutating if a conflicting `api` record
   exists, and otherwise creates an A record targeting `84.247.140.178`.
   Create it **un-proxied (grey cloud) initially** so the first ACME challenge
   reaches the origin directly — the stock Caddy binary has no DNS plugin, so
   only HTTP-01/TLS-ALPN-01 are available. Run it from the operator's local
   Cloudflare CLI per the user's decision; no GitHub Actions secret is involved
   and none should be created. No dashboard steps (AC1).
7. **Install the site block on the VPS, safely.** Back up
   `/etc/caddy/Caddyfile` to a timestamped copy first. Append the block from
   task 5 without touching the `vocabik` blocks. Run
   `caddy validate --config /etc/caddy/Caddyfile`; only if it exits 0, run
   `systemctl reload caddy`. **Never `restart`.** If validation or reload
   fails, restore the backup immediately and STOP.
8. **Verify the co-tenant is undisturbed.** `curl -sSI https://vocabik.com` and
   `https://api.vocabik.com` must still return their pre-change status. This
   check is mandatory and is the gate on continuing.
9. **Confirm certificate issuance.** Wait for Caddy to obtain the certificate,
   then verify with `openssl s_client -connect 84.247.140.178:443 -servername
   api.cupidus.app` that a publicly trusted certificate with a real chain is
   presented, and that `curl -sS https://api.cupidus.app` returns a backend
   response. If issuance fails, read the Caddy journal and report the actual
   ACME error — do not retry blindly against Let's Encrypt rate limits.
10. **Flip the record to proxied**, then re-verify `https://api.cupidus.app`
    still serves the backend through the Cloudflare edge.
11. **Raise the zone SSL/TLS mode to Full (strict)** only after step 9 passed
    and step 10 verified. Re-check the endpoint immediately afterwards.
12. **Write `deployment/configuration-guide.md`** covering every section listed
    in `1B`. The renewal-failure recovery runbook is mandatory: TLS-ALPN-01
    cannot succeed behind the Cloudflare proxy, Caddy falls back to HTTP-01,
    and if a renewal ever fails the recovery is to set the record DNS-only,
    let Caddy renew, then re-proxy. Also record that no Cloudflare credential
    was written to any tracked file (AC5) and the disposition of the legacy
    `api-cupid.tikup.me` name (AC3).

## 4. Acceptance Criteria

- `https://api.cupidus.app` returns a live backend API response (AC2).
- `https://vocabik.com` and `https://api.vocabik.com` are unaffected, verified
  after the Caddy reload.
- The DNS record was created by a re-runnable script whose output shows the
  pre-creation conflict check; re-running it is a no-op success (AC1).
- The record ends Cloudflare-proxied and the zone SSL mode is Full (strict).
- No container binds host port 80 or 443; the backend publishes on loopback on
  a port that is not `3000`, and that port is recorded as a contract value.
- `backend/nginx/default.conf` is unchanged from its pre-story state, and the
  legacy name's disposition is recorded in the configuration guide (AC3).
- No SSH key was generated or rotated; if any rotation occurred, the proof of
  breakage and rationale are recorded (AC4).
- No credential value appears in any tracked file, and no placeholder GitHub
  secret was created for this story (AC5 — see `../architecture/solution.md`
  section 7).

## 5. Planned Outputs

- Code directories or files: `deployment/caddy/api.cupidus.app.caddy`;
  `scripts/cloudflare/` DNS provisioning script
- Reverted files: `backend/nginx/default.conf`, `backend/docker-compose.yml`,
  `.gitignore`
- Contracts or schemas: satisfies `../architecture/contract-summary.md`
  sections 1-3 and populates its section 6 port value
- Requirement configuration guide updates: `deployment/configuration-guide.md`
  (new)
- Notes or evidence: `cat /etc/caddy/Caddyfile` and `ss -ltnp` output;
  `caddy validate` output; pre/post co-tenant curl checks; DNS script pre-check
  and creation output; certificate and endpoint check output — recorded in
  `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: VPS host Caddy edge + Cloudflare `cupidus.app` zone
- Required levels (omit N/A levels):
  - integration: endpoint and certificate checks against the deployed host
  - backend build/type-check: `caddy validate --config /etc/caddy/Caddyfile`
    (the config-syntax equivalent for this lane)
- Required checks:
  - `caddy validate` exits 0 before any reload
  - `curl -sSI https://vocabik.com` and `https://api.vocabik.com` return their
    pre-change status after the reload (co-tenant regression gate)
  - `ss -ltnp` shows the selected backend port free before and bound after, and
    shows no new listener on 80/443 beyond the existing Caddy process
  - `dig +short api.cupidus.app` returns Cloudflare proxy addresses at the end
    state (a bare `84.247.140.178` answer means the final proxy flip was missed)
  - `openssl s_client -connect 84.247.140.178:443 -servername api.cupidus.app`
    presents a publicly trusted certificate chain
  - `curl -sS https://api.cupidus.app` returns a backend response, not a
    Cloudflare 5xx interstitial
  - `git status` and the staged diff contain no credential literal and no
    certificate/key material
  - the diff shows `backend/nginx/default.conf` back at its pre-story state
- Minimum gates by risk surface: as defined in `../architecture/solution.md`
  section 4 — do not restate the gate text here
- Required runtime signals:
  - HTTP status and response body from `https://api.cupidus.app`
  - certificate issuer and expiry date from the `openssl` output
  - co-tenant HTTP status before and after the Caddy reload
- Evidence format: command plus captured output recorded in
  `coding-plan/test-results.md`
- Verification strategy:
  - Targeted checks: the `Required checks` list above
  - Build/type-check command: `caddy validate --config /etc/caddy/Caddyfile`
  - Required assertion evidence: a successful HTTPS response, the certificate
    issuer/expiry line, and the co-tenant before/after status pair

## 7. Status

- Status: NOT_STARTED (R2 — replanned; ready for DevOps dispatch)
- Blockers: NONE. The two R1 blockers are dissolved rather than deferred:
  `ORIGIN_CERT_PROVISION_FAILED` (no Origin CA certificate is issued in this
  design) and `SECRET_REQUIRED` (Cloudflare DNS runs once from the operator's
  local CLI; no GitHub Actions secret is needed). See
  `../architecture/solution.md` section 7.
- Superseded R1 work to revert (task 1): `api.cupidus.app` 443 nginx server
  block, Compose 443 publish + cert mount, `.gitignore` cert rule, and any
  Origin CA provisioning. R1's verified SSH access finding still stands and
  need not be re-proven beyond task 2's one-line check.
- Carried forward unchanged: the Cloudflare DNS provisioning script's
  enumerate-then-fail-closed shape, which this revision still requires.
- Last updated: 2026-08-21
