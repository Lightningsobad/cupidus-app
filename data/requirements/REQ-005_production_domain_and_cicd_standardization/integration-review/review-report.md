# REQ-005 Requirement Integration Review — STORY-002

Outcome: PATCH_REQUIRED

- Reviewer: Iris-QC
- Mode: requirement-integration-review
- Scope: STORY-002 (Standardize VPS backend deploys onto GitHub Actions CI/CD)
- Branch: `codex/REQ-005_production_domain_and_cicd_standardization-integration`
- Diff baseline: `4523068..HEAD` (16 files, +1938 / -6)
- Date: 2026-08-21

## Verdict

The security posture of the pipeline is sound and the first-ever push carries
no secret material. However two independent defects in the diff each guarantee
that the first production deploy fails at the VPS step. Both are small,
localized fixes inside the two new files. Because the entire stated purpose of
landing now is Task 8's "observe the first green run", this is
`PATCH_REQUIRED`, not `DEFERRED_ONLY` — the gaps are code defects in the diff,
not the intentionally deferred Tasks 9/10 evidence.

## Blocking findings

### F1 — Every SSH command in `vps-deploy.sh` violates the forced-command restriction this same story installed on the deploy key

`STORY-002/devops/cutover-evidence.md` (Task 2) and
`STORY-002/coding-plan/test-results.md` lines 105-113 record that the new
deploy key is pinned to `command="/root/.ssh/deploy-wrapper.sh"`, and that the
wrapper only `eval`s `SSH_ORIGINAL_COMMAND` when it is prefixed with
`cd /var/www/backend && `, rejecting everything else with
`deploy-wrapper: command not permitted for this key`, exit 1.

- `.github/workflows/scripts/vps-deploy.sh:40` sends
  `docker inspect --format '{{.Config.Image}}' cupid-backend 2>/dev/null || echo NONE`
  with **no `cd` prefix at all**. This is the same rejected class as the
  verified `whoami` probe. The `|| echo NONE` fallback lives inside the remote
  string, so it never runs — the wrapper rejects before `eval`. Under
  `set -euo pipefail`, `PRIOR_IMAGE=$(ssh_exec ...)` propagates the non-zero
  status and the script aborts on its very first remote call.
- Every other remote call (`:44-46`, `:55`, `:64`, `:66`, `:71`, `:94`, `:102`)
  is built from `cd '${VPS_DEPLOY_PATH}' && ...`, i.e. it sends
  `cd '/var/www/backend' && ...` with the path **single-quoted**. The only form
  ever verified against the wrapper is the unquoted
  `cd /var/www/backend && pwd`. A literal prefix match fails on the quotes.

Impact: `deploy-and-verify` is a guaranteed red run. It is fail-safe (the abort
happens before the dump, the pull, and the `up -d`, so no VPS state changes),
but Task 8 cannot produce the green run that this landing exists to obtain.

Fix: prefix the `PRIOR_IMAGE` command with `cd /var/www/backend && `, drop the
single quotes around `${VPS_DEPLOY_PATH}` (or normalize in the wrapper), and
re-run the allow/reject probe from cutover-evidence Task 2 against the *actual*
generated command strings — not a hand-typed representative — before merging.

### F2 — `GHCR_PULL_TOKEN` is documented and provisioned but never consumed; the VPS never authenticates to GHCR

OID-3 (`cutover-evidence.md:44-51`) and
`REQ-005/deployment/configuration-guide.md:26-28` both state the package stays
private and "the VPS authenticates the pull with `GHCR_PULL_TOKEN`". Full reads
of `.github/workflows/deploy-backend.yml` and
`.github/workflows/scripts/vps-deploy.sh` show:

- no `docker login ghcr.io` anywhere on the VPS side;
- no `GHCR_PULL_TOKEN` in the `deploy-and-verify` job's `env:` block
  (`deploy-backend.yml:80-88`);
- a bare, unauthenticated `docker compose -f docker-compose.prod.yml pull` at
  `vps-deploy.sh:55`.

Impact: the private-package pull is denied — the same guaranteed red first run.
The `SECRETS_UNPROVISIONED` blocker was closed on the grounds that the secret
now holds a real value, but the code that consumes it was never written. This
is precisely the failure mode the devops run declined to cause earlier
(`cutover-evidence.md:192-199`).

Fix: either add a `docker login ghcr.io` on the VPS fed from the secret via
stdin (prefixed to satisfy F1), or flip the package to public and update OID-3
plus the configuration guide.

## Non-blocking findings

### F3 — Pre-deploy dump runs against the wrong compose file and transiently exposes production Postgres to the internet (MEDIUM)

`vps-deploy.sh:44` uses bare `docker compose up -d postgres` and
`docker compose exec -T postgres` with no `-f docker-compose.prod.yml`. In
`/var/www/backend` that resolves to the legacy `docker-compose.yml`, which per
`devops/vps-inspection.md:18` publishes fixed host ports `5432:5432` and
`6379:6379` on **all interfaces**. The backup step therefore starts production
Postgres publicly reachable on `84.247.140.178:5432`, and if the run aborts at
the dump-size check (`:47-50`) it stays that way. Same issue at `:102`.

Fix: use `-f docker-compose.prod.yml` (which publishes no dependency host port)
for both the dump and the row-count check.

### F4 — Pre-deploy `pg_dumpall` uses a host-shell `POSTGRES_USER` that is never set (MEDIUM)

`vps-deploy.sh:44` and `:102` embed `\${POSTGRES_USER:-postgres}`, which
expands in the VPS *login shell* — not inside the container, and not from
`/var/www/backend/.env` (Compose reads that file; the ssh shell does not). Per
`vps-inspection.md:21` the real `POSTGRES_USER` exists only in that `.env`. If
it is not literally `postgres`, `pg_dumpall -U postgres` fails on a missing
role. The `&&` chain plus `set -e` keeps this fail-safe (the deploy aborts
rather than promoting without a backup), but the AC6 safety net over 48M of
real data is untested and the deploy hard-stops.

Fix: expand inside the container, e.g.
`docker compose -f docker-compose.prod.yml exec -T postgres sh -c 'pg_dumpall -U "$POSTGRES_USER"'`.

### F5 — The AC7 simulation path can permanently break production (MEDIUM — do not run Task 9 until fixed)

`vps-deploy.sh:64` runs `mv service-account.json service-account.json.ac7-hidden`,
then `:71` runs `docker compose up -d`. Compose short-syntax bind mounts
auto-create a missing host source **as a directory**, so `up -d` creates
`./service-account.json/`. The restore at `:66`
(`mv service-account.json.ac7-hidden service-account.json`) then moves the key
*into* that directory as `service-account.json/service-account.json` rather
than restoring it — leaving the backend permanently bind-mounting a directory
over its Firebase key. The "restores it unconditionally via a shell trap" claim
in `cutover-evidence.md:70-72` does not hold under this Docker behavior.

Secondary: `trap 'restore_service_account' EXIT` at `:68` *replaces* the
`cleanup` trap, so if `:71` fails the SSH private key and known-hosts files are
never removed (low severity on an ephemeral runner).

Fix: use long-syntax `type: bind` with `create_host_path: false` for that
mount, make the restore fail loudly if the target is a directory, and chain the
traps instead of replacing them.

### F6 — AC3's legacy deploy path is untouched and undocumented (LOW)

`backend/.github/workflows/deploy.yml` is still tracked, still declares
`on: push: branches: [main]` under the same workflow `name: Deploy Backend`,
uses unpinned `appleboy/scp-action@master` / `appleboy/ssh-action@master`, and
runs a destructive `docker-compose down && docker-compose up -d --build`. It is
inert **only** because it sits at `backend/.github/workflows/` rather than the
repo root, so GitHub will not schedule it — there is no double-deploy risk on
the first push. But no artifact mentions the file at all, while
`configuration-guide.md:70-72` promises the legacy trigger will be "disabled
(not deleted) ... with a dated note left beside it". Record its inert status
explicitly and handle it under AC3 after the first green run.

### F7 — Evidence inconsistencies (LOW)

- `coding-plan/test-results.md:101-103` still states `GHCR_PULL_TOKEN`
  "remains a placeholder"; `devops/cutover-evidence.md:257-270` states it was
  resolved with a real value at 03:51Z. Same story, contradictory claims.
- `deployment/configuration-guide.md:5-7` states "All values below are
  placeholders ... The user populates the real values";
  `cutover-evidence.md:149-156` records 6 of 7 set to real values by the agent
  under explicit user authorization. AC4's *intent* (never source or guess a
  real credential discovered on the VPS) is satisfied — the deploy key was
  freshly minted, the known-hosts value is a public host key — but the guide
  now misdescribes the actual state.
- `STORY-002/story_master.md` still shows `Status: PENDING` with
  `- [ ] Implementation (Development)` unchecked even though the
  implementation is merged into the integration branch. Scrum-Master-owned;
  must be reconciled before DONE.

## Verified clean

- **No secret material in the push.** No hardcoded credential in the workflow,
  the deploy script, or the compose file. `git ls-files` over
  `*service-account*`, `*.pem`, `*.key`, `*.p12`, `*.jks`, `*credentials*`,
  `.env`, `*/.env`, `*id_rsa*`, `*id_ed25519*` returns nothing — the
  first-ever push carries no credential-shaped tracked file.
- `StrictHostKeyChecking=yes` with `UserKnownHostsFile` pinned from
  `VPS_SSH_KNOWN_HOSTS`, `BatchMode=yes`; the private key is written under
  `RUNNER_TEMP` with `umask 077` + `chmod 600` and removed in an EXIT trap
  (except the F5 window).
- No third-party action in the SSH credential path (OID-2). The GHCR push is
  authenticated with the Actions-issued `GITHUB_TOKEN` under a job-scoped
  `packages: write`, with workflow default `contents: read`.
- `concurrency: group: deploy-backend-production, cancel-in-progress: false`
  prevents interleaved and double deploys.
- `deploy-and-verify` is gated on `needs: build-and-push`, so a build failure
  never reaches the VPS.
- `backend/docker-compose.prod.yml` pins `name: backend` with volumes
  `postgres_data`/`redis_data` → `backend_postgres_data`/`backend_redis_data`,
  matching the VPS baseline in `vps-inspection.md:19,57-60` verbatim.
  `postgres:16` and the `POSTGRES_DB` default `cupid` match the legacy
  VPS-shape compose (`backend/docker-compose.yml.devstack-backup.1787195883:11,15`),
  so there is **no** Postgres major-version and no database-name mismatch
  against the existing 48M data directory.
- Backend published loopback-only at `127.0.0.1:3010:3000`, backed by real
  read-only `ss -ltnp` evidence; no nginx service (host Caddy owns 80/443).
  Does not disturb the unrelated live `vocabik` tenant on the shared VPS.
- `backend/Dockerfile` no longer bakes `service-account.json` into the image,
  verified by a from-scratch build with no key in context
  (`test-results.md:3-10`). No other tracked compose file depends on that
  `COPY`; the local dev compose (`backend/docker-compose.yml`) builds the same
  image but its dependency services are devstack-retired behind
  `profiles: ["legacy"]`, so removing the `COPY` regresses no live local path.

## Residual risks (accepted / deferred)

- Tasks 8 (merge-to-main / real deploy), 9 (AC7 negative rollback proof) and
  10 (AC6 re-verification) are not done. Accepted per the handoff; they depend
  on this landing.
- Rollback restores only the prior **image** reference. The pre-deploy
  `pg_dumpall` is never automatically restored and no manual restore runbook is
  documented. Because `vps-inspection.md:15,84-91` shows nothing cupid-branded
  is currently running, `PRIOR_IMAGE` will resolve to `NONE` (or a stale local
  image) on the first run — AC7's premise of "the previous working deployment
  remains serving traffic" has no live baseline to protect here. State this in
  the configuration guide before Task 9.
- `actions/checkout` and the `docker/*` actions use major-version tags rather
  than SHA pins. Explicitly deferred by OID-2 pending `WebSearch`/`WebFetch`
  availability; they sit outside the SSH credential path.
- `Stories-Merged: WAIVED` on `req_master.md` is a documented Scrum-Master-owned
  waiver of the other land gate and was not re-litigated here. STORY-001 is out
  of scope for this review.

## Required before re-review

1. Fix F1 (forced-command prefix on all remote calls) and re-verify against the
   real generated strings.
2. Fix F2 (GHCR pull authentication, or a public-package pivot with OID-3 and
   the configuration guide updated).
3. Fix F3 and F4 (dump against the prod compose file; resolve `POSTGRES_USER`
   inside the container) — these guard the AC6 data-safety net over live data.

F5 must be fixed before Task 9 is ever dispatched, but does not block the merge
to `main` (the simulation path is opt-in `workflow_dispatch` input, default
`false`, and is not reachable from a `push` trigger). F6 and F7 are
documentation/state reconciliation and may be handled alongside Task 8.

REVIEW_COMPLETE: YES
