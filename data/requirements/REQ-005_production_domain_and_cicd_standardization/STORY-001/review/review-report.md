# STORY-001 Review Report — Point api.cupidus.app at the production backend API

Outcome: PATCH_REQUIRED

Review type: `compact-story-review`
Story: STORY-001 (REQ-005), Complexity `standard`, Implementation Lane `shared`
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-005_production_domain_and_cicd_standardization-STORY-001`
Diff baseline: `e34385af8c9579b3ee33fdf4f3c6bb8b47665097..HEAD` (11 files)

## Scope Gate

- Review report path: `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-001/review/review-report.md`
- Source/config files in scope (6): `scripts/cloudflare/create-api-dns-record.sh`,
  `scripts/cloudflare/set-api-dns-proxied.sh`,
  `scripts/cloudflare/set-zone-ssl-full-strict.sh`,
  `deployment/caddy/api.cupidus.app.caddy`, `backend/nginx/default.conf`,
  `backend/docker-compose.yml` (+ `.gitignore`, revert-only)
- Evidence files in scope: `STORY-001/coding-plan/test-results.md` (§0-§9, §11a-§11c, §11, §12),
  `STORY-001/devops/vps-caddy-edge-evidence.md` (headings + Session 4),
  `REQ-005/deployment/configuration-guide.md` (§4-§8),
  `STORY-001/architecture/solution.md` (§1, §1A), `STORY-001/coding-plan/master-plan.md` (§4)
- Touched risk surfaces: runtime/configuration (edge routing, TLS termination),
  external integration (Cloudflare API), operational command (three DNS/SSL scripts),
  security/auth (zone SSL mode, credential handling)
- Critical gates verified: live HTTPS edge response, origin/edge certificate validity,
  co-tenant non-regression on the shared VPS, scripted-not-dashboard DNS mutation,
  no credential/key material in the diff, configuration-guide accuracy
- UX / visual fidelity: NOT APPLICABLE — UX-Spec WAIVED, no operator-facing UI surface;
  rules 12e1/12e2 do not apply to a DNS/edge-routing story.

## Independent Verification Performed

Re-verified live rather than taken from evidence (2026-08-21):

```
curl -sS -D - -o /dev/null https://api.cupidus.app/
  HTTP/2 200
  via: 1.1 Caddy
  x-powered-by: Express
  server: cloudflare
  cf-ray: a2e7e17f8abb10a2-HKG
openssl s_client -servername api.cupidus.app -connect api.cupidus.app:443
  subject= /CN=cupidus.app   issuer= /C=US/O=Google Trust Services/CN=WE1
  notBefore=Aug 20 2026   notAfter=Nov 18 2026
dig +short api.cupidus.app A   -> 172.67.141.59, 104.21.62.250 (Cloudflare anycast)
dig +short api-cupid.tikup.me A -> 172.67.161.85, 104.21.9.213 (unchanged, separate)
```

The `via: 1.1 Caddy` + `x-powered-by: Express` header pair on a `200` proves the full
chain end-to-end: Cloudflare edge -> origin Caddy -> the backend Express app. This is
direct proof of AC2, independent of the SSL-mode permission gap.

## Acceptance Criteria Verdicts

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 — scripted DNS record creation, conflict-checked | PASS | `create-api-dns-record.sh` enumerates first and exits non-zero without mutating on conflict; executed live (record `facd411fe80be1d51cc4110f1fd5aff9`), then `set-api-dns-proxied.sh` flipped to proxied. `dig` confirms anycast. No dashboard step. test-results §5, §11b.1/.3 |
| AC2 — hostname serves the backend over HTTPS | PASS | Independently re-verified above: `HTTP/2 200` with a valid publicly trusted edge cert and origin-Caddy/Express provenance headers |
| AC3 — legacy vhost inspected, not blindly overwritten | PASS (with recorded deviation, see below) | `backend/nginx/default.conf` restored byte-for-byte to pre-story state (test-results §0, empty verification diff); disposition recorded in configuration-guide §6 |
| AC4 — no SSH key rotation | PASS | `ssh -o BatchMode=yes root@84.247.140.178` succeeded on the existing authorized key; no key generated or rotated (test-results §1) |
| AC5 — secrets handling | PASS (conditional not triggered) | `CLOUDFLARE_API_TOKEN` was already available to the operator's local shell, so the `gh secret set` placeholder branch never applied. Diff scanned: no token, private key, or certificate material committed; scripts read only from env |

### AC3 deviation — reviewed and accepted

AC3's literal text anticipates "extending or replacing this vhost". The delivered
solution instead moves TLS termination out of the container nginx entirely, to the
host Caddy. Under core rule 14 this is an approved-architecture deviation, not a
substitute slipped in silently: `architecture/solution.md` §1A establishes that host
Caddy is the sole listener on `:80`/`:443` for a live third-party tenant, so the
container-nginx approach could not bind at all. The requirements' own Out-of-scope
section leaves the legacy hostname's disposition to a "Tech Lead/DevOps implementation
call". AC3's enforceable obligations — inspect before changing, do not blindly
overwrite, record the disposition — are all met.

## Blocking Findings

### F1 — Mandatory story-level runtime startup smoke is not declared (rule 12g)

This is a non-trivial story with Implementation Lane `shared`, so it requires either a
`## Story Runtime Startup Smoke` section in `coding-plan/test-results.md` or a
`Runtime-Smoke: WAIVED — <reason>` line in `story_master.md`. Neither exists.
`coding-plan/master-plan.md:43` records `startup smoke NOT_APPLICABLE` with a sound
rationale, but that is a third location that neither the reviewer gate nor the
independent DONE gate reads.

The underlying substance is already present and passing (`caddy validate` exit 0,
graceful `systemctl reload` with PID unchanged, co-tenant regression curls, `ss -ltnp`
listener check, and the live edge `200`). This is a declaration gap, not a missing
verification — but it will reject the story at the DONE gate as it stands.

Action (owner: DevOps, or Scrum Master for the waiver line): either add a
`## Story Runtime Startup Smoke` section to `test-results.md` citing the existing Caddy
validate/reload + co-tenant + live-edge evidence, or record
`Runtime-Smoke: WAIVED — <reason>` in `story_master.md`. Reviewer must not write either.

### F2 — Canonical evidence and the configuration guide contradict the live state

Both artifacts still describe the pre-STORY-002 world and were not refreshed after the
backend went live:

- `coding-plan/test-results.md:459` — `DEVOPS_COMPLETE: NO`. The story's own completion
  marker still reads NO while `story_master.md` asserts all ACs pass.
- `deployment/configuration-guide.md` §4, §5, §7 — assert `https://api.cupidus.app`
  returns `502` "because STORY-002 has not yet deployed a backend listening on
  `127.0.0.1:3010`". It returns `200`.
- `configuration-guide.md` §7 closes with an instruction to downstream requirements:
  "No REQ-006/REQ-007 client build should point at this host as 'fully live' until both
  this blocker and STORY-002's backend deploy are resolved." That instruction is now
  false and would incorrectly gate REQ-006 and REQ-007.

Per rule 12a, stale setup/configuration guidance is `PATCH_REQUIRED`. The operational
impact here is concrete, not cosmetic: the guide is the artifact two downstream
requirements will read to decide whether this host is usable.

Action (owner: DevOps): refresh §4, §5, §7 and test-results §12 to the verified live
state (`200`, backend reachable on `127.0.0.1:3010`), and lift the REQ-006/REQ-007
hold that no longer applies.

### F3 — Configuration guide gives contradictory instructions for the zone SSL mode

`configuration-guide.md` §4 records the target mode as **Flexible** (user decision,
superseding Full (strict)). §5's ordered sequence step 4 still instructs the operator to
run `scripts/cloudflare/set-zone-ssl-full-strict.sh` to "raise zone SSL mode". The two
sections point at opposite settings for a security-relevant control, in the same
document, with no note reconciling them.

Action (owner: DevOps): make §5 step 4 consistent with the §4 decision — either mark
step 4 superseded/not-to-be-run, or state explicitly which script is now correct.

## Deferred Findings

- **D1 — `CLOUDFLARE_TOKEN_MISSING_SSL_PERMISSION` (accepted, non-blocking).** The token
  lacks the "SSL and Certificates" group, so the exact zone SSL-mode value cannot be
  read or written for any target. I evaluated the underlying evidence as instructed and
  find it sufficient for AC2: the Session 4 journal capture shows a completed TLS 1.3
  handshake with correct SNI arriving at the origin from a Cloudflare edge IP, and my own
  live `200` with origin-Caddy provenance confirms the full path works today. The
  permission gap costs an exact recorded mode name, not a security property.
- **D2 — `set-zone-ssl-full-strict.sh` is retained while the chosen target is Flexible.**
  The script is well-guarded (idempotent, documents its ordering hazard) and running it
  today would be safe given the origin's valid Let's Encrypt cert, but its name and intent
  no longer match the recorded decision. Related to F3; track for cleanup when D1 resolves.
- **D3 — `www.vocabik.com` ACME failure on the shared host.** Pre-existing NXDOMAIN on a
  co-tenant domain, present since host setup in 2026-06. Out of scope, investigated and
  documented, not worsened by this story.

## Traceability

- Requirements: `STORY-001/requirements/requirements.md` AC1-AC5; Open Question Impact
  records no BLOCKED scope items, and the four NOT_BLOCKED entries are correctly triaged.
- Architecture: `STORY-001/architecture/solution.md` §1, §1A — implementation matches the
  R2 host-Caddy design; the R1 container-nginx prep was fully reverted and verified with
  an empty diff against the pre-story parent.
- UX: WAIVED, no UI surface. Rules 12e1/12e2 not applicable.
- Configuration guide: exists and is structurally complete, but stale on live state (F2)
  and internally contradictory on SSL mode (F3).
- Shared-infrastructure safety (rule 12h): PASS. The Caddy site block proxies to
  `127.0.0.1:3010` (loopback-only, not `0.0.0.0`), `3010` was confirmed free before use,
  `3000` was deliberately avoided because a live co-tenant holds it, and the co-tenant
  regression gate passed twice. `backend/docker-compose.yml` removing `443:443` is correct
  and required — host Caddy owns that port.
- Secret hygiene: PASS. Diff scanned for private keys, bearer tokens, and certificate
  material; none present.

## State Recommendation

- Uncheck `Implementation (Development)`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Route F1, F2, F3 back to DevOps (F1's waiver-line variant is Scrum Master's to write).
  All three are documentation-level corrections against an implementation that is already
  live and verified correct; no code, script, or VPS change is required.
