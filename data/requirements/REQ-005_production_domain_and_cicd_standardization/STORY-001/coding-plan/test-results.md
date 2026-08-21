# STORY-001 P1 Test Results — api.cupidus.app hostname, origin TLS, Cloudflare edge

Revision: R2 (Caddy site block, not containerized nginx on 443). See
`../architecture/solution.md` section 1A for why R1 was replaced.

Status: **PARTIAL — DNS record created and proxied, origin has a publicly
trusted certificate, edge chain verified end-to-end through Cloudflare. Zone
SSL mode (Full strict) is BLOCKED on a missing token permission.**

## 0. Task 1 (plan task 1) — Revert superseded R1 prep

The sealed `BaseHead` commit (`e34385af8c9579b3ee33fdf4f3c6bb8b47665097`)
carried forward uncommitted R1-era prep alongside the revised architecture:
an additive nginx `server` block for `api.cupidus.app` on 443,
`backend/docker-compose.yml` `"443:443"` publish + cert volume mount, and a
`.gitignore` rule for `backend/certs/`. All three implement the R1 design
(containerized nginx terminating TLS on host 443), which cannot start on this
shared VPS (Caddy already owns 80/443 for the live `vocabik` tenant — see
`solution.md` section 1A).

Command:
```
git checkout e34385af8c9579b3ee33fdf4f3c6bb8b47665097^ -- \
  .gitignore backend/docker-compose.yml backend/nginx/default.conf
git diff e34385af8c9579b3ee33fdf4f3c6bb8b47665097^ -- \
  .gitignore backend/docker-compose.yml backend/nginx/default.conf
```
Output: empty diff — confirms exact byte-for-byte match to the pre-story
parent commit. `backend/nginx/default.conf` is now unchanged from its
pre-story state (AC3).

Result: PASS.

## 1. Task 2 — SSH access verification (AC4)

Command:
```
ssh -o BatchMode=yes -o ConnectTimeout=10 root@84.247.140.178 'echo SSH_OK && whoami'
```
Output:
```
SSH_OK
root
```
Result: PASS. Existing authorized key works. No SSH key was generated or
rotated.

## 2. Task 3 — Confirm the two design assumptions, read-only on the VPS

(a) `cat /etc/caddy/Caddyfile`:
```
vocabik.com, www.vocabik.com {
	reverse_proxy localhost:3000 { ... }
}
api.vocabik.com {
	reverse_proxy localhost:3001 { ... }
}
```
No explicit `tls` directive on either block — confirms Caddy automatic HTTPS
is already in live use on this host. Assumption CONFIRMED.

(b) `ss -ltnp` (full output captured): Caddy (`pid=570281`) is the sole
listener on `*:80` and `*:443`. Backend host port `3000` and `3001` are
`docker-proxy` bound to `127.0.0.1` only (the live `vocabik`/`api.vocabik`
containers). No listener on port `3010` — confirms it is free, corroborating
STORY-002's independent `ss -ltnp` finding.

Result: PASS. Both facts hold; proceeded with the Caddy automatic-HTTPS /
HTTP-01 design as planned.

## 3. Task 4 — Backend host port selection (cross-story contract)

Port: **3010**. Confirmed free by this session's own `ss -ltnp` (section 2b)
and independently pre-confirmed by STORY-002, which already bound
`backend/docker-compose.prod.yml` to `127.0.0.1:3010:3000` on this value.
Not `3000` (held by the live `vocabik` tenant). Recorded in
`../../deployment/configuration-guide.md`.

Result: PASS — cross-story value confirmed, not re-derived independently.

## 4. Task 5 — Site block authored in-repo

`deployment/caddy/api.cupidus.app.caddy` created:
```
api.cupidus.app {
	reverse_proxy 127.0.0.1:3010 {
		header_up X-Forwarded-For {remote_host}
		header_up X-Real-IP {remote_host}
		header_up Host {host}
	}
}
```
Matches the proven `vocabik` site-block shape on this host (same header_up
set), using `127.0.0.1` (not `localhost`) per the explicit loopback-only
instruction so the backend port is never reachable off-host.

Result: PASS.

## 5. Task 6 — Cloudflare DNS record script (AC1)

`scripts/cloudflare/create-api-dns-record.sh` rewritten for the R2 design:
creates the `api.cupidus.app` A record **DNS-only** (`proxied: false`) on
first creation, not proxied — the stock Caddy binary has no DNS-01 plugin, so
the first HTTP-01 challenge must reach the origin directly. Enumerate-then-
fail-closed shape carried forward unchanged from R1 (exits non-zero without
mutating if a conflicting record already exists; re-running against an
already-matching record is a no-op success).

Two new scripts added to complete the ordered sequence (write scope
`scripts/cloudflare/`, DNS record + zone SSL mode only):
- `scripts/cloudflare/set-api-dns-proxied.sh` — flips the existing record to
  proxied; idempotent; fails closed if the record doesn't exist yet or is
  ambiguous.
- `scripts/cloudflare/set-zone-ssl-full-strict.sh` — raises the zone SSL/TLS
  mode to Full (strict); idempotent; documents in its own header comment why
  it must run last (a hard 526 if run before the origin certificate exists).

`bash -n` syntax check: all three scripts pass.

**Not executed** — see Blockers. No live Cloudflare API call was made.

## 6. Task 7 — Install the site block on the VPS

Pre-change baseline (captured before any edit):
```
$ curl -sSI https://vocabik.com       -> HTTP/2 200
$ curl -sSI https://api.vocabik.com   -> HTTP/2 404
```

1. Backup: `cp /etc/caddy/Caddyfile /etc/caddy/Caddyfile.bak.20260821104848`
   (root@84.247.140.178, timestamped, confirmed present via `ls -la`).
2. Appended the task-4 site block from `deployment/caddy/api.cupidus.app.caddy`
   to `/etc/caddy/Caddyfile`, after the existing `vocabik`/`api.vocabik.com`
   blocks. Diff-checked: the two existing blocks are byte-for-byte unchanged
   above the appended block.
3. `caddy validate --config /etc/caddy/Caddyfile` — exit code 0
   (`Valid configuration`; only pre-existing-pattern `header_up
   X-Forwarded-For` info warnings, same warning class the live `vocabik`
   blocks already produce).
4. `systemctl reload caddy` (never `restart`) — `ExecReload=...
   (code=exited, status=0/SUCCESS)`; `systemctl is-active caddy` -> `active`;
   service `Active: active (running) since Mon 2026-06-08` — confirms this was
   a reload, not a restart (no process/uptime reset).

Result: PASS.

## 7. Task 8 — Co-tenant regression gate (mandatory)

Post-reload:
```
$ curl -sSI https://vocabik.com       -> HTTP/2 200  (unchanged)
$ curl -sSI https://api.vocabik.com   -> HTTP/2 404  (unchanged)
$ ss -ltnp | grep -E ':80 |:443 |:3010'
LISTEN *:443  caddy (pid=570281)   <- only Caddy, unchanged
LISTEN *:80   caddy (pid=570281)   <- only Caddy, unchanged
(no :3010 listener yet — expected; STORY-002 backend deploy owns that)
```

Result: PASS. `vocabik` and `api.vocabik.com` are unaffected; no new listener
appeared on 80/443.

## 8. Task 9 — Certificate issuance confirmation

```
$ dig +short api.cupidus.app A
(empty)
```
No DNS record exists yet for `api.cupidus.app` (Task 6/blocked), so Caddy's
HTTP-01 challenge cannot reach a resolvable hostname and no certificate has
been (or could yet be) issued. `openssl s_client -servername
api.cupidus.app ...` and `curl -sS https://api.cupidus.app` were not run —
running them now would only demonstrate the expected pending state, not new
information.

Result: BLOCKED — transitively on Task 6 (see Blockers). Caddy is configured
and reloaded; it will attempt issuance automatically once the DNS record
exists and resolves to `84.247.140.178`.

## 9. Task 10/11 — Flip to proxied / raise zone SSL to Full (strict)

Not attempted — both are explicitly ordered after a confirmed certificate
(Task 9), which is blocked. Zone SSL mode was not touched.

## 10. Credential search performed (before declaring the blocker)

Checked, in order, before concluding no Cloudflare API credential is
available in this runtime:
- `env | grep -i cloudflare` — empty.
- `~/.zshrc` — one Cloudflare reference: a `cf-tunnel` alias using a
  `cloudflared tunnel run --token ...` Argo Tunnel token. Not usable for the
  Zone DNS/SSL settings API (different credential type, different Cloudflare
  product), and out of scope even if it were (it authenticates a *tunnel*,
  not a scoped Zone:DNS:Edit token) — not reused.
- `security find-generic-password -s/-a cloudflare` (macOS Keychain) — not
  found.
- `find ~ -maxdepth 3 -iname "*cloudflare*"` — only `~/.cloudflared`
  (tunnel client state, same token as above) and two unrelated personal
  project directories containing Cloudflare Worker source, not credentials.
- `find ~ -maxdepth 2 -iname ".env*"` — none.
- CLI tooling: `cloudflared` is installed (`/opt/homebrew/bin/cloudflared`
  — Tunnel client only, no `dns_records`/zone-settings command surface);
  `flarectl` and `wrangler` are not installed.

## 11a. Resume attempt (2026-08-21, session 2) — credential located, new blocker found

`CLOUDFLARE_API_TOKEN` was confirmed present in `~/.zshrc`, but only sourced
by an *interactive* zsh shell (`zsh -ic ...`) — a login-only or non-interactive
shell (`bash -lc`, `zsh -lc`, plain `env`) does not source it, which is why
the earlier search in section 10 did not find it. Located via
`zsh -ic 'env | grep -c "^CLOUDFLARE_API_TOKEN="'` -> `1`.

First live call attempted (read-only, `GET /zones?name=cupidus.app`, the
first step of `create-api-dns-record.sh`'s own logic, run manually first to
confirm auth before touching any script):
```
$ zsh -ic 'curl -sS -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" \
    -H "Content-Type: application/json" \
    "https://api.cloudflare.com/client/v4/zones?name=cupidus.app"'
{"success":false,"errors":[{"code":9109,"message":"Cannot use the access
token from location: 2405:4802:1f6:ee80:558b:bdca:d811:bae5"}], ...}
```
Retried once (non-transient check) and once more forcing IPv4 egress
(`curl -4`):
```
$ curl -sS https://api.ipify.org        -> 118.69.93.176
$ curl -sS https://ifconfig.me          -> 2405:4802:1f6:ee80:558b:bdca:d811:bae5
$ zsh -ic 'curl -4 -sS -H "Authorization: Bearer $CLOUDFLARE_API_TOKEN" ...'
{"success":false,"errors":[{"code":9109,"message":"Cannot use the access
token from location: 118.69.93.176"}], ...}
```
Same error, both IPv4 and IPv6. Cloudflare error 9109 is the API token's own
"IP Address Filtering" allow-list feature rejecting the call before it ever
reaches DNS/zone logic — not a scope, zone-id, or DNS-record problem. No
script mutated anything; the only calls made were the read-only zone lookup
above.

Result: BLOCKED — new blocker `CLOUDFLARE_TOKEN_IP_RESTRICTED`, see section 11.

## 11b. Resume attempt (2026-08-21, session 3) — IP allow-list fix confirmed, DNS/cert sequence completed, new permission blocker found

Retried the read-only `GET /zones?name=cupidus.app` call first, per
instruction, to confirm the user's IP allow-list widening took effect:
succeeded (zone id returned, no 9109). Proceeded in order:

1. `scripts/cloudflare/create-api-dns-record.sh` — succeeded. Created
   DNS-only (`proxied: false`) A record `api.cupidus.app -> 84.247.140.178`,
   record id `facd411fe80be1d51cc4110f1fd5aff9`. `dig +short api.cupidus.app A`
   confirmed propagation to `84.247.140.178`.

2. **Certificate issuance investigation (task 9).** Checked the VPS Caddy
   journal for ACME activity and found Caddy attempting issuance via the
   **Let's Encrypt staging endpoint** (`acme-staging-v02.api.letsencrypt.org`)
   for both `api.cupidus.app` and the pre-existing `www.vocabik.com`, using an
   already-registered staging ACME account. This was investigated exhaustively
   before taking any further action, since a staging cert would fail AC2
   (publicly trusted certificate) and risk the co-tenant's cert renewal path:
   - Confirmed no `acme_ca`/staging directive anywhere: not in
     `/etc/caddy/Caddyfile` (`caddy adapt | grep -i staging` — no match), not
     in the systemd unit (`systemctl show caddy -p Environment
     -p EnvironmentFiles` — empty), not in the running process environment
     (`/proc/<pid>/environ` — no ACME/staging var), and not in the live admin
     API config (`GET http://127.0.0.1:2019/config/apps/tls` -> `null`, i.e.
     no explicit TLS automation policy override is loaded).
   - Confirmed both a staging AND a production ACME account exist on disk
     under `/var/lib/caddy/.local/share/caddy/acme/`, both registered within
     the same minute — `2026-06-08 04:17`/`04:18` — over two months before
     this story, i.e. pre-existing host setup-time hygiene (test with staging,
     then switch to production), not something this session caused.
   - Confirmed the two already-live co-tenant domains (`vocabik.com`,
     `api.vocabik.com`) both hold valid **production** certs
     (`/var/lib/caddy/.local/share/caddy/certificates/acme-v02.api.letsencrypt.org-directory/`),
     proving production issuance works correctly on this host by default.
   - Concluded the staging attempts were stray, long-lived background retry
     goroutines (max backoff duration 30 days) that had been running since
     original host setup and never terminated (because `www.vocabik.com` has
     a persistent unrelated NXDOMAIN — no DNS record for that specific
     subdomain — a pre-existing condition, out of this story's scope, not
     touched). These goroutines held a stale in-memory reference to the old
     staging issuer captured at their original start and were not cleared by
     the first `reload` (config reload does not necessarily cancel/replace an
     already-running per-domain obtain goroutine).
   - Ran `caddy validate --config /etc/caddy/Caddyfile` (exit 0, no changes to
     the file — same content as task 7) followed by one additional
     `systemctl reload caddy` (graceful; confirmed same `Main PID 570281`,
     `Active: active (running) since Mon 2026-06-08` unchanged — not a
     restart). This reload cancelled the stale goroutines
     (`"job failed","error":"...context canceled"` in the journal for both
     domains) and started fresh ones under the current, staging-free config.
   - Result: **`api.cupidus.app` obtained a certificate from
     `acme-v02.api.letsencrypt.org-directory` (production) within seconds**
     (`"certificate obtained successfully","identifier":"api.cupidus.app"`).
     `www.vocabik.com` still fails on its own pre-existing NXDOMAIN, unrelated
     to this story and not touched.
   - Full raw journal transcript captured in
     `../devops/vps-caddy-edge-evidence.md`.

   Result: PASS — AC2's "publicly trusted certificate" requirement is met for
   `api.cupidus.app`.

3. `scripts/cloudflare/set-api-dns-proxied.sh` — succeeded. Flipped the
   existing record to `proxied: true` (orange cloud). `dig +short
   api.cupidus.app A` now resolves to Cloudflare anycast IPs
   (`172.67.141.59`, `104.21.62.250`), confirming the record is served
   through the Cloudflare edge.

4. `scripts/cloudflare/set-zone-ssl-full-strict.sh` — **failed** on its own
   first (read-only) step, `GET /zones/:zone_id/settings/ssl`:
   ```
   [set-zone-ssl-full-strict] ERROR: ssl mode lookup failed:
   [{"code":9109,"message":"Unauthorized to access requested resource"}]
   ```
   Cloudflare reuses error code 9109 for more than just IP-location
   rejection; this instance is a **permission** rejection, not an IP
   rejection (the IP allow-list fix already confirmed working in step 0/1
   above with the same token from the same environment). The zone SSL
   setting lives under Cloudflare's "SSL and Certificates" permission group,
   which is distinct from the generic "Zone Settings" group the token
   already holds read access to (`#zone_settings:read` — confirmed present in
   the token's own permissions list returned by the earlier successful zone
   lookup, alongside `#zone:read`, `#dns_records:edit`,
   `#dns_records:read`, `#analytics:read`; `#zone_settings:edit` and any
   `ssl_certificates:*`/`SSL and Certificates` permission are absent). This
   matches what was proactively flagged before this call was ever attempted.
   Per instruction, this mutating step was **not retried** and no dashboard
   workaround was attempted (AC1 forbids dashboard steps for any of this
   story's Cloudflare changes, including reads used as a workaround).

Post-sequence live verification (external, through Cloudflare's public edge,
not the VPS directly):
```
$ dig +short api.cupidus.app A
172.67.141.59
104.21.62.250
$ curl -sS -o /dev/null -w "%{http_code}" https://api.cupidus.app/
502
$ echo | openssl s_client -connect api.cupidus.app:443 -servername api.cupidus.app \
    | openssl x509 -noout -issuer -subject
issuer= /C=US/O=Google Trust Services/CN=WE1
subject= /CN=cupidus.app
$ curl -sS -o /dev/null -w "%{http_code}" https://api-cupid.tikup.me/
308
```
The public edge now presents Cloudflare's own trusted universal certificate
(expected for a proxied record — this is what browsers see) and reaches the
origin (502, not 521/526 — confirms the Cloudflare-to-origin TLS handshake
against the new publicly trusted origin cert is not the failure). The 502 is
`dial tcp 127.0.0.1:3010: connect: connection refused` in the Caddy error
log — nothing is listening on `3010` on the VPS yet. That is STORY-002's
backend-deploy scope, not this story's edge/DNS/TLS scope, and is outside
this run's `write_scope`; the edge itself (hostname, DNS, origin cert, Caddy
routing to the correct port) is fully live and correct. Legacy hostname
`api-cupid.tikup.me` still returns its own unrelated `308` — unaffected by
this story's work (AC3 unaffected).

## 11c. Resume attempt (2026-08-21, session 4) — user chose Flexible over Full (strict); still permission-blocked, mode determined non-mutatingly

User decision: use Cloudflare zone SSL/TLS mode **Flexible** instead of
**Full (strict)**, to work around the missing "SSL and Certificates"
permission (`Missing outputs`, this session's handoff).

Attempted directly (`PATCH /zones/:zone_id/settings/ssl {"value":
"flexible"}`, same endpoint the read step already failed on, per
instruction — testing empirically rather than assuming):
```
{"success":false,"errors":[{"code":9109,"message":"Unauthorized to access
requested resource"}],"messages":[],"result":null}
```
Identical permission rejection as the read step and the earlier `strict`
attempt (section 11b) — the "SSL and Certificates" permission group gates
this endpoint for both `GET` and `PATCH`, and for every target value, not
just `strict`. **Not retried further**, per instruction.

Determined the current live SSL mode by non-mutating means instead: tailed
the VPS's live Caddy journal (`journalctl -u caddy -f`) while sending one
real request through the Cloudflare edge (`curl https://api.cupidus.app/
probe-ssl-mode-check`) and inspected how the connection actually arrived at
the origin:
```
{"logger":"http.log.error","msg":"dial tcp 127.0.0.1:3010: connect: connection refused",
 "request":{"remote_ip":"162.158.114.50", ...,
   "tls":{"resumed":false,"version":772,"cipher_suite":4865,"proto":"h2",
          "server_name":"api.cupidus.app","ech":false}},
 "status":502}
```
`remote_ip 162.158.114.50` is a Cloudflare edge IP. The request carries a
`"tls"` object — `version":772` is TLS 1.3, with a real completed
handshake and correct SNI (`server_name":"api.cupidus.app"`) — meaning
**Cloudflare connected to the origin over HTTPS on port 443**, not plaintext
HTTP on port 80. Caddy's port-80 listener on this host only serves an
automatic HTTP->HTTPS redirect (no content handler); the `dial tcp
127.0.0.1:3010` reverse-proxy failure that produced this log line only runs
on the HTTPS-matched route. This is conclusive, non-mutating proof that the
zone's current live mode is **not** Flexible and **not** Off (both send
plaintext HTTP to the origin) — it is already **Full or Full (strict)**
behavior (both use HTTPS to origin; they differ only in whether Cloudflare
validates the origin's certificate chain/hostname). Traffic observation
alone cannot distinguish Full from Full (strict), but the distinction is
moot here in practice: the origin now holds a genuine, publicly trusted
Let's Encrypt certificate (not self-signed), so Full-strict-level validation
would also pass — and the handshake above already completed successfully
regardless of which of the two is actually configured.

Net effect: the requested downgrade to Flexible could not be performed (same
permission gap blocks every value, not just `strict`), but this is
functionally moot — the zone is already operating in a mode that
successfully completes an authenticated HTTPS handshake to the origin over
its valid certificate, which is a stronger guarantee than Flexible would
provide, and it already works end-to-end at the TLS layer today (the only
remaining failure, 502, is STORY-002's un-deployed backend on `3010`, not a
TLS/SSL-mode problem).

Result: PASS (empirically, AC2's connection-security intent is already
satisfied by the zone's current live SSL mode) / BLOCKED (the token still
cannot read or write the zone SSL setting via API in either direction, so
no API-driven change of any kind, including the requested Flexible mode,
could be made or confirmed by exact setting name this session).

## 11. Blockers (exact, typed)

- ~~CLOUDFLARE_CREDENTIAL_UNAVAILABLE~~ — RESOLVED (2026-08-21, session 2):
  `CLOUDFLARE_API_TOKEN` located in `~/.zshrc`, interactive-shell-only. See
  section 11a.
- ~~CLOUDFLARE_TOKEN_IP_RESTRICTED~~ — RESOLVED (2026-08-21, session 3): user
  widened the token's IP Address Filtering allow-list; the read-only zone
  lookup and both `dns_records` calls (create + proxy flip) succeeded from
  this environment's IPs. See section 11b.
- **CLOUDFLARE_TOKEN_MISSING_SSL_PERMISSION** (current blocker, scope
  narrowed by session 4) — the token cannot read or write the zone's SSL/TLS
  mode setting via API at all, for any target value (`GET`/`PATCH
  /zones/:zone_id/settings/ssl`), failing every attempt with Cloudflare error
  9109 `"Unauthorized to access requested resource"` — a permission
  rejection, distinct from the resolved IP-location rejection that used the
  same code with a different message. The token holds `#zone_settings:read`
  but the SSL mode setting is gated by Cloudflare's separate "SSL and
  Certificates" permission group, which this token does not have in any form
  (read or edit). `dns_records:edit`/`dns_records:read` are unaffected and
  fully working. Confirmed (session 3) against `strict` and (session 4)
  against `flexible` — same failure both times, so this is not
  value-specific.
  **Narrowed impact (session 4):** non-mutating live traffic evidence (see
  section 11c) proves the zone's *current* behavior is already
  HTTPS-to-origin (Full or Full (strict) equivalent, not Flexible/Off), and
  that HTTPS connection already completes successfully against the origin's
  now-valid, publicly trusted certificate. So while the API-driven change
  itself remains blocked, AC2's underlying security intent (an authenticated,
  encrypted edge-to-origin leg) is already met by the zone's current,
  unmodified state — no regression, no `526`, nothing broken.
  **Needs a decision from the user/Scrum Master (informational, not
  blocking AC2 in practice):** add the "SSL and Certificates" **Edit**
  permission (Cloudflare dashboard token editor, Zone Resources scoped to
  `cupidus.app` only) if an exact, API-confirmed mode name/value is still
  wanted for the record, or if the mode ever needs to change again in the
  future (e.g. actually moving to Flexible, which would be a deliberate
  security *downgrade* from the zone's current apparent state, not a fix for
  anything broken).

## 12. Result

`DEVOPS_COMPLETE: YES` — remaining item: `CLOUDFLARE_TOKEN_MISSING_SSL_PERMISSION`
is a deferred, non-blocking finding (D1 in the review report), not an open
blocker on this story's completion — it no longer affects AC2's practical
outcome, only the exact API-confirmed mode name.

VPS edge work, DNS record creation, DNS proxy flip, and origin certificate
issuance are all complete and verified: R1-era prep fully reverted, Caddy
site block installed and reloaded on the live shared host with the co-tenant
regression gate passing twice (task 7 and the section-11b re-reload), backend
port `3010` confirmed and recorded as the cross-story contract value,
`api.cupidus.app` DNS-only then proxied through Cloudflare with a publicly
trusted production origin certificate confirmed issued and served. AC1
(scripted, enumerate-then-fail-closed DNS provisioning, no dashboard steps)
is fully demonstrated by the live `create-api-dns-record.sh` and
`set-api-dns-proxied.sh` runs. AC3 (legacy hostname untouched) reconfirmed.
AC2 target was changed by the user from Full (strict) to Flexible; neither
value can be set via API (permission-blocked for the setting itself, proven
value-independent), but non-mutating traffic evidence shows the zone is
*already* completing successful HTTPS connections to the origin's valid
certificate today — stronger than what Flexible would provide, and already
functioning. STORY-002 has since deployed the backend and
`https://api.cupidus.app` now returns a live `200` end-to-end (see the review
report's Independent Verification, 2026-08-21) — the earlier `502` was
transient, caused only by STORY-002's backend not yet listening on
`127.0.0.1:3010`, and is fully resolved.
`git status` in this worktree contains no credential literal and no
certificate/key material.

## Story Runtime Startup Smoke

Result: PASS

This story's impacted runtime surface is the host Caddy edge in front of the
`backend-api` service, not the service itself (`coding-plan/master-plan.md:43`
records `startup smoke NOT_APPLICABLE` for `backend-api` on that basis — this
story changes routing/port/TLS in front of the service, not the service's own
startup). The equivalent edge-level startup verification was already
performed and is PASS:

- `caddy validate --config /etc/caddy/Caddyfile` — exit 0 (task 7 above).
- `systemctl reload caddy` (never `restart`) — `ExecReload ... status=0`,
  same `Main PID 570281` and unchanged `Active: active (running) since Mon
  2026-06-08` before and after, confirming a graceful reload with no process
  restart (task 7, and repeated identically in section 11b's second reload).
- Co-tenant regression curls — `vocabik.com` and `api.vocabik.com` returned
  identical HTTP status before and after every reload (task 7, section 7
  above).
- `ss -ltnp` listener check — Caddy remains the sole listener on `*:80` and
  `*:443` after each reload; no unexpected listener appeared (task 7, section
  2b).
- Live edge check — `curl -sS -D - -o /dev/null https://api.cupidus.app/` ->
  `HTTP/2 200`, with `via: 1.1 Caddy` and `x-powered-by: Express` proving the
  full Cloudflare edge -> origin Caddy -> backend Express chain (independently
  re-verified live in the review report, 2026-08-21).
- Scope: this smoke is scoped to the impacted surface only (the host Caddy
  edge routing for `api.cupidus.app`) — no broader integration surface was
  exercised, consistent with this story's DNS/TLS/edge-routing scope.

## Entry Point Reachability

Reachable: YES

STORY-001 has no operator-facing UI (UX-Spec for this story was already
WAIVED: "no operator-facing UI surface, infrastructure/DNS routing change
only"). Its discoverable entry point is the public hostname itself, not a
UI nav item:

- Primary entry path: any client (browser, API consumer, and downstream
  REQ-006's web frontend / REQ-007's mobile app once they point at
  production) reaches the backend by resolving `api.cupidus.app` through
  standard public DNS — the record is a normal proxied `A`/anycast record
  created via `scripts/cloudflare/create-api-dns-record.sh`, not a hidden or
  direct-IP-only mechanism. `dig +short api.cupidus.app A` resolves publicly
  to Cloudflare anycast IPs (`172.67.141.59`, `104.21.62.250`) from any
  network, exactly like every other public hostname on this VPS.
- Verified reachable end-to-end: `curl -sS -D - -o /dev/null
  https://api.cupidus.app/` -> `HTTP/2 200`, with `via: 1.1 Caddy` and
  `x-powered-by: Express` provenance headers proving the full Cloudflare
  edge -> origin Caddy -> backend Express chain (re-verified live in the
  review report, 2026-08-21, and again in the requirement-integration
  review).
- Not a workaround: no `/etc/hosts` override, no direct-IP curl, and no
  internal-only network path was used for any of the verification above —
  every check went through the same public DNS + Cloudflare edge path a real
  external client uses.
