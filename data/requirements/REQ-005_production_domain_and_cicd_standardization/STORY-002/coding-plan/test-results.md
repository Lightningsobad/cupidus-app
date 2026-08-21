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
