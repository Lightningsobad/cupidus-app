# Phase P1 – api.cupidus.app hostname, origin TLS, and Cloudflare edge

## 1. Objective

`https://api.cupidus.app` resolves through Cloudflare and serves live backend
API responses, with the edge->origin leg encrypted and authenticated under
Full (strict), the legacy `api-cupid.tikup.me` vhost untouched, and no SSH key
generated or rotated.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-api-hostname-tls-edge.md`
- Owner: DevOps Engineer
- Lane: DevOps

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `backend/nginx/` (vhost config; certificate mount path)
  - `backend/docker-compose.yml`
  - `scripts/cloudflare/`
  - `deployment/configuration-guide.md`
  - `.gitignore`
- Impacted Runtime Service/App:
  - Name: `backend`
  - Runtime Registry Id: `backend-api`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: backend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (unchanged by this phase)
  - Startup Command Source: runtime registry `startCommand` (unchanged by this phase)
  - Readiness Check: HTTPS response from `https://api.cupidus.app` served by the
    already-running VPS backend container
  - Port Contract: external — the VPS nginx service gains a published `443`
    alongside the existing `80`
- Shared Interfaces Produced:
  - `../architecture/contract-summary.md` (production API base URL)
- Risk Surfaces:
  - Origin TLS trust chain
  - Legacy vhost regression
  - Cloudflare DNS zone mutation
  - VPS access credential handling
  - Secret and key material exposure
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md`
    sections 1 and 4
  - consumer contract: `../architecture/contract-summary.md`
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC1-AC5
  - architecture: `../architecture/solution.md` sections 1 (invariants, Key
    Discovery), 4 (risk table, DevOps guardrails)
  - OQ constraints: `../architecture/solution.md` section 3 table
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: YES
  - Sections To Update: Cloudflare API credential (name, scope, where stored);
    Origin CA certificate location, issued/expiry date, and renewal command;
    zone SSL/TLS mode; published VPS ports; disposition status of the legacy
    `api-cupid.tikup.me` name
- Phase Sizing:
  - Behavior Slice: one behavior cluster — make one hostname reach the backend
    over authenticated TLS. DNS, certificate, and vhost are steps of it, not
    separate clusters.
  - Source/Test File Count: 5
  - Split Required: NO
  - Split Rationale: fits one specialist lifecycle in one lane; splitting would
    add a dispatch and a verification pass without removing any dependency.

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../architecture/contract-summary.md`
- `../requirements/requirements.md` `## Open Question Impact`

## 3. Tasks

Execute in this order. The ordering is load-bearing: raising the SSL mode before
the origin serves a certificate produces a hard 526 outage.

1. **Verify access without changing it.** Confirm `ssh root@84.247.140.178`
   works with the existing authorized key. Do NOT generate or rotate any key.
   If access fails, STOP and report — rotation needs explicit user confirmation
   (AC4).
2. **Resolve the Cloudflare credential.** Determine whether the operator's
   local Cloudflare CLI/API session can already read and write the
   `cupidus.app` zone. If a credential is missing, create a placeholder GitHub
   Actions secret with `gh secret set <NAME> --body <placeholder>` and report
   the exact secret name for the user to populate. Never invent or reuse a real
   credential value (AC5).
3. **Resolve Origin CA issuance mechanics against live sources.** The planning
   session could not verify these (see `../architecture/solution.md` section 3,
   `Unverified third-party mechanics`). Determine from the current Cloudflare
   API and documentation: the Origin CA issuance endpoint, which credential
   type it requires (a scoped API token may NOT be sufficient — an Origin CA
   Key may be required), and the available certificate validity periods. Record
   what you find in the configuration guide.
4. **Provision the origin certificate.** Generate the private key and CSR **on
   the VPS**, request the Origin CA certificate, and install the certificate and
   key under the nginx certificate mount path with restrictive permissions. The
   private key must never leave the VPS and must never enter the repository.
5. **Add the gitignore rule in the same change** as step 4, before anything is
   staged, so certificate material cannot be committed.
6. **Extend the vhost.** In `backend/nginx/default.conf`, add a *new* server
   block for `server_name api.cupidus.app` listening on 443 with TLS, proxying
   to `http://backend:3000` using the same proxy headers as the existing block.
   Leave the existing `api-cupid.tikup.me` block byte-for-byte unchanged (AC3).
   Ensure the new block is not a default catch-all server.
7. **Publish 443 and mount the certificates** in the `nginx` service of
   `backend/docker-compose.yml` (the service is behind the `vps` Compose
   profile; keep it that way so local dev is unaffected). Mount certificate
   material read-only.
8. **Validate and reload** the nginx config on the VPS, then confirm the origin
   presents the Origin CA certificate on 443 **before** touching Cloudflare.
9. **Create the DNS record via script.** Add an idempotent script under
   `scripts/cloudflare/` that first enumerates existing `cupidus.app` records,
   exits non-zero without mutating if a conflicting `api` record exists, and
   otherwise creates a **proxied** record targeting `84.247.140.178` (AC1). No
   dashboard steps.
10. **Raise the zone SSL/TLS mode to Full (strict)** only after step 8 passed.
11. **Write `deployment/configuration-guide.md`** covering every section listed
    in `1B`, including the certificate expiry date and the exact renewal
    command, and the recorded disposition of the legacy `api-cupid.tikup.me`
    name (AC3).

## 4. Acceptance Criteria

- `https://api.cupidus.app` returns a live backend API response (AC2).
- The DNS record was created by a re-runnable script whose output shows the
  pre-creation conflict check; re-running it is a no-op success (AC1).
- The record is Cloudflare-proxied and the zone SSL mode is Full (strict).
- The `api-cupid.tikup.me` server block is unchanged in the diff, and its
  disposition is recorded in the configuration guide (AC3).
- No SSH key was generated or rotated; if any rotation occurred, the proof of
  breakage and rationale are recorded (AC4).
- No real credential value and no certificate/key material appears in any
  tracked file; any required secret is a named placeholder reported to the user
  (AC5).

## 5. Planned Outputs

- Code directories or files: `scripts/cloudflare/` provisioning scripts;
  `backend/nginx/default.conf`; `backend/docker-compose.yml`; `.gitignore`
- Contracts or schemas: satisfies `../architecture/contract-summary.md`
- Requirement configuration guide updates: `deployment/configuration-guide.md`
  (new)
- Notes or evidence: script output for the DNS pre-check and creation;
  certificate and endpoint check output, recorded in `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: VPS nginx edge + Cloudflare `cupidus.app` zone
- Required levels (omit N/A levels):
  - integration: endpoint and certificate checks against the deployed host
  - backend build/type-check: `nginx -t` config validation inside the nginx
    container (the config-syntax equivalent for this lane)
- Required checks:
  - `nginx -t` exits 0 after the vhost change
  - `dig +short api.cupidus.app` returns Cloudflare proxy addresses (not the
    origin IP — a bare `84.247.140.178` answer means the record is not proxied,
    which breaks the Origin CA trust chain)
  - `openssl s_client -connect 84.247.140.178:443 -servername api.cupidus.app`
    presents the Cloudflare Origin CA certificate
  - `curl -sS https://api.cupidus.app` returns a backend response, not a
    Cloudflare 5xx interstitial
  - `git status` and the staged diff contain no `.key`, `.pem`, `.crt`, or
    credential literal
  - the diff shows the `api-cupid.tikup.me` server block unchanged
- Minimum gates by risk surface: as defined in `../architecture/solution.md`
  section 4 — do not restate the gate text here
- Required runtime signals:
  - HTTP status and response body from `https://api.cupidus.app`
  - certificate issuer and expiry date from the `openssl` output
- Evidence format: command plus captured output recorded in
  `coding-plan/test-results.md`
- Verification strategy:
  - Targeted checks: the `Required checks` list above
  - Build/type-check command: `nginx -t`
  - Required assertion evidence: a successful HTTPS response plus the
    certificate issuer/expiry line

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-21
