# REQ-006 Production Deployment Log — `cupidus.app`

Owner: DevOps. Executed: 2026-08-22. Environment: production. Platform: VPS
(`84.247.140.178`, shared with `vocabik.com`/`api.vocabik.com`/`api.cupidus.app`).

## Authorization

Direct user instruction, relayed by Scrum Master/team-lead: *"Tôi cần
cupidus.app hoạt động production trên đó"*. Handoff also carried
user-confirmed stack decisions (same VPS, same host Caddy, reuse
`VPS_SSH_PRIVATE_KEY` shape, DevOps chooses `VPS_WEB_DEPLOY_PATH`).

## Blocker found and resolved: forced-command key scope

The handoff's assumption that `VPS_SSH_PRIVATE_KEY` has no server-side
forced-command restriction was checked directly against the live VPS
(read-only) and found to be **incorrect** — the key is restricted to
`cd /var/www/backend && ` via `/root/.ssh/deploy-wrapper.sh`, exactly the
risk `configuration-guide.md` §5 had flagged as unverified. This was
reported to team-lead before any secret/Caddy/CI mutation; the user decided
option 2 (provision a second, dedicated key) over widening the backend
wrapper. Full narrative and fix details: `configuration-guide.md` §5.

## Blocker found and resolved: missing DNS

`cupidus.app` and `www.cupidus.app` had no DNS record on the Cloudflare
zone (confirmed via `dig` against the zone's own nameservers, then a second
provider). Created both as DNS-only (unproxied) `A` records to
`84.247.140.178`, via the same `CLOUDFLARE_API_TOKEN`/`CLOUDFLARE_ZONE_ID`
mechanism REQ-005 used for `api.cupidus.app`, matching its
DNS-only-first-then-verify-cert posture. Neither record was overwritten
(both confirmed absent before create). Full narrative:
`configuration-guide.md` §3.

## Execution sequence

1. Verified SSH access to `84.247.140.178` (read-only `whoami` check).
2. Read `/root/.ssh/authorized_keys` and `/root/.ssh/deploy-wrapper.sh` —
   found the forced-command blocker above. Reported to team-lead, held all
   mutations pending a decision.
3. Received decision: provision `VPS_WEB_SSH_PRIVATE_KEY`.
4. Resolved Cloudflare zone id for `cupidus.app`, confirmed no existing
   `cupidus.app`/`www.cupidus.app` records, created both DNS-only.
5. Generated a fresh `ed25519` keypair in scratch space (never committed),
   comment `github-actions-deploy-cupidus-web`.
6. Installed `/root/.ssh/deploy-web-wrapper.sh` (mode 700, root:root),
   `ALLOWED_PREFIX="cd /var/www/web && "`, mirroring the backend wrapper's
   structure without touching it.
7. Backed up `/root/.ssh/authorized_keys`, appended one new constrained
   entry for the new public key (file: 3 lines → 4 lines). Pre-existing
   lines unmodified.
8. Verified the new key end-to-end before wiring secrets: allowed-prefix
   command succeeds; disallowed command rejected; backend-prefix command
   from the new key rejected. Found the directory (`/var/www/web`) did not
   exist and `vps-deploy-web.sh`'s `mkdir -p ... && cd ... && ` first
   command could never match the wrapper's literal `cd ... && ` prefix
   regardless — pre-created `/var/www/web` out-of-band (same convention as
   backend) and fixed the script (commit `4517954`, see below). Also found
   and fixed the `.../incoming` prefix mismatch in the upload/count
   commands in the same commit.
9. Provisioned GitHub Actions secrets: `VPS_WEB_SSH_PRIVATE_KEY` (private
   key content, never echoed), `VPS_WEB_DEPLOY_PATH=/var/www/web`.
10. Updated `.github/workflows/deploy-web.yml` to source
    `VPS_SSH_PRIVATE_KEY` (script env var name, unchanged) from
    `secrets.VPS_WEB_SSH_PRIVATE_KEY` instead of the shared
    `secrets.VPS_SSH_PRIVATE_KEY`.
11. Committed and pushed both script/workflow fixes to `main`
    (`4517954`) — this push's changed paths matched `deploy-web.yml`'s own
    trigger paths and auto-started the first live deploy run.
12. In parallel with that run's build phase: backed up
    `/etc/caddy/Caddyfile` (timestamped), appended the `cupidus.app,
    www.cupidus.app { root * /var/www/web/current; try_files {path} {path}/
    =404; file_server }` block below the existing `vocabik`/
    `api.cupidus.app` blocks, ran `caddy validate` (exit 0), then
    `systemctl reload caddy` (never `restart`).
13. Re-verified `vocabik.com` (200), `api.vocabik.com` (404 — unchanged
    pre-existing baseline per REQ-005 evidence, not a regression), and
    `api.cupidus.app` (200) all unaffected by the reload.
14. Confirmed GitHub Actions run `32569499081` (push, commit `4517954`)
    completed `success` in 57s.
15. Verified the live site directly:
    - `https://cupidus.app/` → `200`, real Astro build HTML (`<title>Cupid</title>`).
    - `https://www.cupidus.app/` → `200`.
    - TLS: issuer `Let's Encrypt`, subject `CN=cupidus.app` (auto-issued by
      Caddy on first request, no manual cert step needed).
    - `/var/www/web/current/` on the VPS contains the deployed build
      (`_astro/`, `about/`, etc.).
16. Deleted local key material from scratch space after secret provisioning
    (never written into the repository or an evidence file).

## Final verification (all four production domains, 2026-08-22)

| Domain | Status | Note |
|---|---|---|
| `vocabik.com` | 200 | unaffected |
| `api.vocabik.com` | 404 | unaffected, pre-existing baseline |
| `api.cupidus.app` | 200 | unaffected |
| `cupidus.app` | 200 | **newly live** |
| `www.cupidus.app` | 200 | **newly live** |

## Secrets touched

- `VPS_WEB_SSH_PRIVATE_KEY` — created. Value never printed/echoed/committed.
- `VPS_WEB_DEPLOY_PATH` — created, value `/var/www/web` (not sensitive,
  recorded here for operability).
- `VPS_SSH_PRIVATE_KEY` — untouched, still backend-only.

## Result

`DEVOPS_COMPLETE: YES`
