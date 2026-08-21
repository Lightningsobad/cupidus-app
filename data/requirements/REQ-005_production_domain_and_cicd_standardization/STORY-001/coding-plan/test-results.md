# STORY-001 P1 Test Results — api.cupidus.app hostname, origin TLS, Cloudflare edge

Status: BLOCKED (partial progress — repo-side prep complete; live Cloudflare
provisioning not attempted due to two independent, confirmed environment
blockers below).

## 1. Task 1 — SSH access verification (AC4)

Command:
```
ssh -o BatchMode=yes -o ConnectTimeout=8 -o StrictHostKeyChecking=accept-new \
  root@84.247.140.178 'echo SSH_OK && hostname && whoami'
```
Output:
```
SSH_OK
vmi3120552
root
```
Result: PASS. Existing authorized key works. No SSH key was generated or
rotated.

## 2. Task 2 — Cloudflare credential resolution (AC5)

- No `CLOUDFLARE_API_TOKEN` / `CF_*` env var is present in this runtime.
- No `wrangler` CLI installed, no cached Cloudflare API auth state
  (`~/.cloudflared/cert.pem` exists but is a `cloudflared` Tunnel/Argo login
  certificate, not a Zone API credential — not usable for DNS/Origin CA API
  calls; not reused).
- Per AC5, the fallback is `gh secret set <NAME> --body <placeholder>`. This
  is blocked by a **separate** environment gap: this `cupid-apps` checkout
  has **no git remote configured at all** (`git remote -v` empty in both the
  story worktree and the control checkout; `gh repo view` / `gh secret list`
  both report `no git remotes found`). `gh auth status` confirms the
  authenticated account (`hoak57uet`) has ~20 private/public repos, including
  several plausible-but-unconfirmed CI targets (`cupid-backend`,
  `cupid-app-android`, `cupid-app-ios`); none is wired to this checkout as a
  remote, so there is no non-guessed way to pick the repo that would receive
  a `CLOUDFLARE_API_TOKEN` placeholder secret.
- Result: BLOCKED — see "Blockers" below. No secret was created (creating one
  in an unconfirmed/guessed repo risks placing a credential placeholder,
  later populated with a real token, in the wrong repository).

## 3. Task 3 — Origin CA issuance mechanics (live verification)

- `WebSearch` / `WebFetch` / `ToolSearch` are not present in this agent's
  available tool set (confirmed: not in the function list provided to this
  session; no tool named `ToolSearch` could be invoked to load them).
- Per the handoff's explicit instruction ("if genuinely unavailable in this
  runtime too, do not guess the mechanics — record the exact blocker and
  stop rather than inventing an issuance flow"), the Origin CA issuance
  endpoint, required credential type (scoped API token vs. Origin CA Key),
  and available certificate validity periods are **not verified** and are
  **not recorded as fact** anywhere in this change.
- Result: BLOCKED — see "Blockers" below.

## 4. Task 4/8 — Certificate provisioning and install

- Not attempted. Blocked transitively by Task 2 (no credential) and Task 3
  (no verified issuance mechanics). Per the coding-agent-guide hard stop:
  "The origin certificate cannot be installed or `nginx -t` fails -> STOP and
  leave the Cloudflare zone SSL mode unchanged." No certificate material was
  generated, and nothing was copied to or reloaded on the live VPS nginx —
  the VPS was touched only for the read-only SSH check in section 1.

## 5. Task 5 — `.gitignore` rule

Added `backend/certs/` to `.gitignore` (in the same change as the vhost/compose
edits, before anything cert-related exists) so future Origin CA key/cert
material provisioned on the VPS can never be committed.

## 6. Task 6 — Vhost extension (AC3)

Added a new `server { listen 443 ssl; server_name api.cupidus.app; ... }`
block to `backend/nginx/default.conf`, alongside the existing
`api-cupid.tikup.me` block, which is unchanged.

Diff-level check — legacy block unchanged:
```
$ git diff -- backend/nginx/default.conf
```
confirms the diff is a pure addition after the closing `}` of the
`api-cupid.tikup.me` block; no lines inside that block were touched.

Local syntax validation (throwaway self-signed cert, generated in
`/private/tmp/...scratchpad`, never committed, never copied to the VPS — used
only so `nginx -t` can evaluate the new block's directives):
```
$ docker run --rm --add-host backend:127.0.0.1 \
    -v <scratch>/default.conf:/etc/nginx/conf.d/default.conf:ro \
    -v <scratch>/certs:/etc/nginx/certs:ro \
    nginx:alpine nginx -t
...
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```
Result: PASS (syntax only — this validates the new server block is
well-formed nginx config; it does NOT validate against the real Origin CA
certificate, which does not exist yet).

## 7. Task 7 — Compose 443 publish + cert mount

Added `"443:443"` to the `nginx` service's `ports` and a read-only
`./certs:/etc/nginx/certs:ro` volume mount in `backend/docker-compose.yml`,
inside the existing `vps` profile (local dev compose path unaffected).

`docker compose --profile vps config` was attempted and fails with:
```
service "backend" depends on undefined service "postgres": invalid compose
project
```
Confirmed via `git stash` / `stash pop` that this error is **pre-existing**
and unrelated to this change (reproduces identically on the unmodified file —
`postgres` is gated behind the `legacy` profile while `backend.depends_on`
references it unconditionally). Out of scope for STORY-001; not touched.
The `nginx` service section itself was validated in isolation via the `nginx
-t` run in section 6, which mounts exactly this compose file's
`default.conf`.

## 8. Task 8 — Validate and reload on VPS

Not attempted — see section 4. The live VPS nginx config/container was not
touched beyond the read-only SSH check in section 1.

## 9. Task 9 — DNS record script (AC1)

Wrote `scripts/cloudflare/create-api-dns-record.sh`: enumerates existing
`api.cupidus.app` records via `GET /zones/:zone_id/dns_records?name=...`
first; if a record exists and does not already match
type=A/content=84.247.140.178/proxied=true, it exits non-zero without
mutating and prints the conflicting record verbatim; if a matching record
already exists, it exits 0 as a no-op; otherwise it creates a new proxied A
record via `POST /zones/:zone_id/dns_records`.

Not executed — requires `CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ZONE_ID`, which
are unavailable (Task 2). `bash -n` syntax check passed.

## 10. Task 10 — Raise zone SSL mode to Full (strict)

Not attempted — blocked by sections 2-4, and per the hard stop rule this must
only happen after the origin is confirmed serving a valid certificate on 443.
Zone SSL mode was not touched.

## 11. Blockers (exact, typed)

- **SECRET_REQUIRED** — `CLOUDFLARE_API_TOKEN` (scoped `Zone:DNS:Edit` on
  `cupidus.app`, and separately: whatever credential type Task 3 would have
  determined is required for Origin CA issuance — possibly an Origin CA Key,
  not a scoped token). Cannot create the AC5 placeholder GitHub secret
  without a confirmed target repo (`gh secret set` needs `--repo owner/repo`;
  none is configured or unambiguous — see section 2). **Needs user/Scrum
  Master decision: which GitHub repo's Actions secrets should hold this
  credential** (best-guess candidate: `hoak57uet/cupid-backend`, unconfirmed).
- **ORIGIN_CERT_PROVISION_FAILED** (root cause: unverifiable mechanics, not a
  failed API call) — `WebSearch`/`WebFetch`/`ToolSearch` are not available in
  this runtime, so the Origin CA issuance endpoint, required credential type,
  and certificate validity period could not be verified against live
  Cloudflare sources as the phase required. No issuance was attempted.

## 12. Result

`DEVOPS_COMPLETE: NO` — blockers: `SECRET_REQUIRED`, `ORIGIN_CERT_PROVISION_FAILED`.

Repo-side prep is complete and safe to review/merge independently: `.gitignore`
rule, new additive nginx server block (legacy block byte-for-byte unchanged),
Compose 443 publish + cert mount (profile-gated, local dev unaffected), and
the untested-but-syntax-valid Cloudflare DNS provisioning script. No
certificate/key material exists anywhere in the working tree; `git status`
shows only the files listed above.
