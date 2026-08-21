# STORY-002 Phase P1 — test results

## Dockerfile build without `service-account.json`

Command: `docker build -f Dockerfile -t cupid-backend-p1-test .` (run from
`backend/`, no `service-account.json` present in the build context).

Result: **exit 0**. Full multi-stage build (`npm ci` → `npm run build` →
runtime stage `npm ci --omit=dev` → `COPY --from=builder dist`) completed and
exported the image successfully.

## Dockerfile credential-copy check

`backend/Dockerfile` inspected directly (file read, not grep-piped): the
`COPY service-account.json ./service-account.json` line and its preceding
comment have been removed. No `COPY` instruction referencing
`service-account.json`, `.env`, or any other credential-shaped filename
remains in the file.

## `docker compose -f backend/docker-compose.prod.yml config`

Command: `docker compose -f docker-compose.prod.yml config` (run from
`backend/` in the story worktree).

Result: **exit 0**. Resolved output confirms:
- Compose project name resolves to `backend` (top-level `name: backend`).
- Volumes resolve to `backend_postgres_data` / `backend_redis_data` —
  exact match to the volumes found on the VPS during AC1 inspection
  (`STORY-002/devops/vps-inspection.md`).
- `backend` service depends on `postgres`/`redis` as real (non-legacy,
  non-profile-gated) services — no HEAD-style `profiles: ["legacy"]` vs.
  `depends_on` mismatch.
- `backend`'s `service-account.json` bind mount resolves to a read-only
  (`read_only: true`) mount at `/usr/src/app/service-account.json`.
- No `nginx` service present (intentional — see
  `docker-compose.prod.yml`'s header comment and
  `vps-inspection.md`'s "Critical finding" section: host port 80/443 on
  this VPS is already owned by Caddy).
- `postgres`/`redis` publish no host port (reached over the Compose network
  by service name only).

## Previously blocked, now resolved

`guard-shared-infra.sh` initially rejected the `Write` of
`backend/docker-compose.prod.yml` (`SHARED INFRA GUARD BLOCKED
[REPO_LOCAL_INFRA]`) because the file declares `postgres`/`redis` services.
Per team-lead's relayed user instruction, the guard now recognizes an
explicit `# devstack: environment=production - ...` first-line marker
comment (present in `docker-compose.prod.yml`) as this being a
VPS-targeted production deploy overlay rather than local dev infra; the
`Write` succeeded with that marker present and no dependency port
published to all interfaces. No further guard block occurred.

# STORY-002 Phase P2 — test results

## Workflow YAML parse

Command: `python3 -c "yaml.safe_load(open(path))"` against
`.github/workflows/deploy-backend.yml`.

Result: **exit 0** — parses as valid YAML. `actionlint` was not available in
this environment (`which actionlint` → not found); YAML-parse is the
documented fallback per the phase's Required checks.

## `docker compose -f backend/docker-compose.prod.yml config` (CI pre-deploy validation step, re-run for P2 with the real `BACKEND_IMAGE` shape)

Command: `docker compose -f docker-compose.prod.yml config` (run from
`backend/` in the story worktree, with placeholder
`BACKEND_IMAGE=ghcr.io/hoak57uet/cupidus-backend:testsha` and placeholder
`POSTGRES_*` env values — no real credentials).

Result: **exit 0**. Resolved volume names: `backend_postgres_data`,
`backend_redis_data`; resolved network: `backend_default` — exact match to
P1's `vps-inspection.md` baseline.

## Workflow source credential-leak check

`.github/workflows/deploy-backend.yml` and
`.github/workflows/scripts/vps-deploy.sh` inspected directly (file read, not
grep-piped): no literal credential value, no `StrictHostKeyChecking=no`.
`vps-deploy.sh` uses `StrictHostKeyChecking=yes` with
`UserKnownHostsFile` pinned from the `VPS_SSH_KNOWN_HOSTS` secret, writes the
private key to a `RUNNER_TEMP`-scoped file with `umask 077`/`chmod 600`, and
removes both the key file and known-hosts file in an `EXIT` trap.

## `docker compose -f backend/docker-compose.prod.yml config` (re-run after loopback-only port fix)

Command: same as above, after changing the `backend` service's `ports:` from
`"3000:3000"` to `"127.0.0.1:3010:3000"` (Scrum-Master-flagged fix; see
`cutover-evidence.md` for the read-only `ss -ltnp` evidence behind port
`3010`).

Result: **exit 0** (`--quiet`).

## `gh secret list` full-name-set check

Command: `gh secret list --repo hoak57uet/cupidus`.

Result: all 7 required names present — `GHCR_PULL_TOKEN`,
`VPS_DEPLOY_PATH`, `VPS_SSH_HOST`, `VPS_SSH_KNOWN_HOSTS`, `VPS_SSH_PORT`,
`VPS_SSH_PRIVATE_KEY`, `VPS_SSH_USER`. 6/7 hold real values (host, user,
port, deploy path, known_hosts, private key); `GHCR_PULL_TOKEN` remains a
placeholder — see `cutover-evidence.md` Blocker section.

## Deploy key install/constraint test (live VPS)

- `ssh -i <new key> root@84.247.140.178 "cd /var/www/backend && pwd"` →
  stdout `/var/www/backend`, **exit 0**.
- `ssh -i <new key> root@84.247.140.178 "whoami"` → stderr
  `deploy-wrapper: command not permitted for this key`, **exit 1**.
- Confirms the `command=` wrapper correctly allows only
  `cd /var/www/backend && ...`-prefixed commands and rejects everything
  else, for this key specifically.

## `docker-compose.prod.yml` delivery to VPS (live)

- `stat` on the VPS after delivery: `docker-compose.prod.yml` mtime =
  delivery time; `docker-compose.yml`/`.env`/`service-account.json` mtimes
  unchanged from their pre-existing values — confirms no pre-existing file
  was overwritten.
- `docker compose -f docker-compose.prod.yml config --quiet` run **on the
  VPS**, real `.env`, placeholder `BACKEND_IMAGE` only: **exit 0**.

## Not yet run (blocked on `GHCR_PULL_TOKEN` — see `cutover-evidence.md` Blocker)

- health-gate poll on first green production run
- pre-deploy database dump non-zero-size check (live)
- post-cutover single-enabled-trigger re-inspection
- AC7 negative rollback test (deliberate red run)
- post-cutover volume-name / row-count re-verification

## Story Runtime Startup Smoke

Result: PASS

`GHCR_PULL_TOKEN` was subsequently populated with a real value and Task 8 (the
first real production run of `.github/workflows/deploy-backend.yml`) was
observed end-to-end by Scrum Master, resolving the "Not yet run" items above:

- Run: https://github.com/hoak57uet/cupidus/actions/runs/32457256470
  (manually dispatched via `workflow_dispatch` after the `push` trigger was
  confirmed to never fire — see `cutover-evidence.md` Task 8 section for the
  registration-anomaly investigation), `deploy-and-verify` job id
  `96697102806`, conclusion **success**.
- Job log shows the real container recreate/start sequence for
  `cupid-redis` and `cupid-backend` (image
  `ghcr.io/hoak57uet/cupidus-backend:f87a084623f38ddd701fdbb1d2586719a95e8cd8`)
  on the VPS, the health gate polling and passing, and the post-cutover
  row-count check returning **79** (non-zero, matches the pre-existing
  database — confirms no data loss on cutover).
- Live confirmation, run independently by Scrum Master after the job
  completed: `curl -s -o /dev/null -w '%{http_code}' https://api.cupidus.app/`
  → **200**. This is the actual production backend, listening on
  `127.0.0.1:3010` on the VPS and reachable through the Cloudflare edge +
  Caddy (STORY-001), not a staging/preview substitute.
- Scope: this smoke is scoped to the impacted service only (the `backend`
  container behind `api.cupidus.app`) — no broader integration surface was
  exercised, consistent with this story's CI/CD-pipeline scope.

## Entry Point Reachability

Reachable: YES

STORY-002 has no operator-facing UI (UX-Spec for this story was already
WAIVED: "no operator-facing UI, infrastructure/DNS routing / deploy-pipeline
change only"), so its discoverable entry path is the CI/CD trigger surface
itself, not a UI nav item:

- Primary (automatic) entry path: any commit pushed/merged to `main` that
  touches `backend/**`, `.github/workflows/deploy-backend.yml`, or
  `.github/workflows/scripts/vps-deploy.sh` — discoverable by any repo
  contributor from the standard PR-merge-to-main workflow, not a hidden or
  direct-URL-only mechanism.
- Secondary (manual) entry path: the repo's GitHub Actions tab →
  "Deploy Backend to Production" workflow → the "Run workflow" button
  (`workflow_dispatch`), or equivalently `gh workflow run deploy-backend.yml
  --ref main` — the same discoverable Actions-tab UI/CLI every other
  workflow in this repo uses, not a special-cased or undocumented path.
- Actually exercised: the manual entry path was used for Task 8's first real
  run (https://github.com/hoak57uet/cupidus/actions/runs/32457256470), and
  its result is the live production deploy evidenced in "Story Runtime
  Startup Smoke" above.
