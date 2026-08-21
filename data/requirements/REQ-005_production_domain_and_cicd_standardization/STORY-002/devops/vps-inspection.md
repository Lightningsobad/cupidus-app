# STORY-002 — AC1 VPS-side read-only inspection

Inspected: `root@84.247.140.178`, read-only (`ls`/`find`, `cat` of
non-credential files, `docker ps`/`ps -a`, `docker compose ls/config`,
`docker volume ls/inspect`, `systemctl status`, `git log`/`remote -v` with a
one-off `-c safe.directory=` flag — no persisted `git config` write, no
`crontab` write). No Docker state change, no key generation/rotation
occurred.

## Investigation Findings (VPS side)

| Artifact | State on VPS | Consequence |
|----------|---------------|-------------|
| Deploy mechanism | Docker Compose. Project name `backend`, working dir `/var/www/backend`, config file `/var/www/backend/docker-compose.yml`. `docker compose ls -a` shows project `backend` as `exited(3)`. | Confirms assumption A-1 (Compose, not systemd/PM2/manual). Continue per Task 4 — no architecture-revision stop triggered. |
| `cupid-backend` container | `Exited (137) 2 months ago` (SIGKILL exit code, consistent with an OOM-kill). | **The cupid backend is not currently running and has not served traffic for ~2 months.** |
| `cupid-postgres` / `cupid-redis` containers | Both `Exited (0) 7 weeks ago`. | Dependencies are also stopped; nothing cupid-branded is live on this VPS today. |
| `cupid-nginx` container | Does not exist in `docker ps -a` at all — never created/started, despite being declared in the deployed compose file. | The nginx service in `/var/www/backend/docker-compose.yml` has apparently never run on this host. |
| `/var/www/backend/docker-compose.yml` (deployed file) | Fixed host ports (`5432:5432`, `6379:6379`, `3000:3000`, `80:80`), `container_name` set per service, **no** `profiles: ["legacy"]`, `postgres`/`redis` are plain compose services in `backend`'s `depends_on`. | Structurally matches repo's `backend/docker-compose.yml.devstack-backup.*` (pre-devstack), **not** HEAD's profile-legacy version — confirms Key Discovery 1: the VPS runs an older, pre-devstack compose shape. |
| Named volumes | `backend_postgres_data`, `backend_redis_data` (`docker volume inspect`: `com.docker.compose.project=backend`, `com.docker.compose.version=1.29.2`, created `2026-03-06T08:12:41+01:00`). `du -sh`: postgres volume 48M with real `PG_VERSION`/`base`/`global`/`pg_wal` etc. on disk (file names only inspected, no contents); redis volume 8.0K. | AC6 baseline: these are the volumes any cutover must reuse verbatim (`postgres_data`/`redis_data` under compose project `backend`). Real, non-trivial Postgres data exists even though the DB is currently stopped. |
| `postgres`/`redis` runtime nature | Compose services (not host packages, not managed/external). | Confirms checklist item; no external DB/cache to account for. |
| `.env` | Present at `/var/www/backend/.env` (65 bytes). Key names only: `POSTGRES_USER`, `POSTGRES_PASSWORD`. No values read. | `POSTGRES_DB`/`REDIS_*` are not present in `.env` — they come from the compose file's own defaults/hardcoded service names, matching the deployed compose. |
| `service-account.json` | Present at `/var/www/backend/service-account.json` (2418 bytes). Top-level key names only: `type, project_id, private_key_id, private_key, client_email, client_id, auth_uri, token_uri, auth_provider_x509_cert_url, client_x509_cert_url, universe_domain`. `type` field value (non-secret constant) confirmed as `service_account`. No other value read. | Standard Firebase Admin SDK service-account shape confirmed; ready to be bind-mounted at runtime per the architecture's Image Contract. |
| Deployed git commit (`/var/www/backend`, origin `https://github.com/hoak57uet/cupid-backend`) | `b5e6d776d27aebb616749ebb8ded8c44e9f6c5b7`, committed `2026-03-06 10:43:06 +0700` — same date as the volume creation timestamp. | The checkout has not been redeployed/updated in ~5.5 months, consistent with the container having run for a while then being OOM-killed and never restarted. |
| `authorized_keys` (`/root/.ssh/authorized_keys`) | 2 entries, both `ssh-ed25519`, both with the identical comment `alantravala@d0hcf65j0l` (key material not read, only algorithm + comment). | **OID-1 evidence for AC5**: no dedicated, GitHub-Actions-labeled key exists today. Both present keys read as personal/dev-machine keys (identical comment, likely a duplicate), not CI-scoped. This favors minting a dedicated least-privilege deploy key over reusing either of these — final call belongs to P2 per the phase boundary, this is evidence only, no key was generated or rotated here. |
| PM2 (`pm2 list`) | One unrelated process only: `android-web-panel` (namespace `default`). Nothing cupid-related. | Confirms A-1 negatively too: PM2 is present on the host but not managing the cupid backend. |
| `crontab -l` (root) | Empty — no crontab. | No cron-based deploy/restart mechanism for cupid. |

## Legacy `api-cupid.tikup.me` vhost/compose inventory (AC1, required)

- **No TLS termination or routing for `api-cupid.tikup.me` exists anywhere on
  this VPS today.** The only host-level reverse proxy is Caddy
  (`systemctl status caddy`: active, running since 2026-06-08; config
  `/etc/caddy/Caddyfile`, loaded via `ExecStart=/usr/bin/caddy run --config
  /etc/caddy/Caddyfile`). `ss -ltnp` confirms Caddy (pid 570281) is the sole
  listener on `:80` and `:443`.
- The live Caddyfile declares exactly two site blocks, both for an unrelated
  project: `vocabik.com, www.vocabik.com { reverse_proxy localhost:3000 }`
  and `api.vocabik.com { reverse_proxy localhost:3001 }`. No `cupid` or
  `tikup.me` entry exists in it.
- The repo's `backend/nginx/default.conf` (`server_name api-cupid.tikup.me;
  listen 80;`, proxy to `backend:3000`) describes a container (`cupid-nginx`)
  that — per the finding above — was **never actually started** on this VPS
  (absent even from `docker ps -a`). So the legacy vhost has never been live
  from this compose file either; the repo config and the live VPS state have
  simply never matched.
- **This VPS is shared, multi-tenant infrastructure**: besides the (stopped)
  cupid stack, it runs an unrelated, currently-live production app,
  `vocabik` (`docker compose ls`: project `prod`,
  `/opt/vocabik/infra/prod/docker-compose.prod.yml`, `running(5)`, served by
  the same Caddy instance), plus unrelated containers (`ws-scrcpy`,
  `redroid`, `test-redroid3`, `9router`). None of these are touched by this
  phase; noted only because they explain why host port 80/443 is already
  claimed.

## AC6 pre-cutover baseline

- Compose project name to reuse verbatim: `backend`.
- Volumes to reuse verbatim: `backend_postgres_data`, `backend_redis_data`
  (top-level volume names `postgres_data`/`redis_data` under project
  `backend`).
- Bind-mount source paths in the deployed compose: none for `postgres`/
  `redis` beyond the named volumes above; `nginx`'s `./nginx/default.conf`
  bind mount (service never started, see above).
- **Exact row count could not be captured**: `postgres` is currently
  `Exited`, and starting it to run `SELECT count(*)` would be a Docker state
  change, which this read-only P1 phase must not perform. As a non-invasive
  proxy, the volume's on-disk size (`du -sh`: 48M) and a real Postgres data
  directory (`PG_VERSION`, `base`, `global`, `pg_wal`, …, file names only)
  were confirmed present. **Recommendation for P2**: capture
  `SELECT count(*)` from a key table (e.g. `users`) immediately after
  `docker compose up -d postgres` and before promoting/health-gating the new
  backend image — starting postgres happens naturally as part of the actual
  cutover, so this is the first point a live row count can be taken without
  violating this phase's read-only boundary.

## Critical finding requiring P2/tech-lead awareness (not a P1 stop condition)

Neither of P1's two literal Stop-And-Ask triggers fired (Compose *is* the
mechanism; the project/volume names *were* captured read-only), so this
phase continued rather than escalating. Two things found go beyond what P1's
checklist anticipated and materially change the risk framing for P2, and are
recorded here rather than acted on:

1. **Nothing cupid-branded is currently live on this VPS.** AC7's premise
   ("the previous working deployment remains serving traffic until a deploy
   fully succeeds") assumes a currently-serving deployment; here there is
   none — `cupid-backend` has been down for ~2 months. P2's health-gate logic
   should still be built exactly as designed (rollback-on-failure), but the
   "outage risk" for this specific cutover is about restoring service and
   protecting the still-present 48M of Postgres data, not about interrupting
   live traffic.
2. **A containerized `nginx` bound to host port `80:80` cannot start on this
   VPS**: host-level Caddy already owns `:80`/`:443` for the unrelated
   `vocabik` production site, and must not be disrupted. Given the health
   gate contractually bypasses nginx already (`127.0.0.1:<backend port>`,
   contract-summary.md section 4), `backend/docker-compose.prod.yml`
   authored in this phase **omits the nginx service entirely** — see the
   rationale comment at the top of that file. This does not touch or
   regress `api-cupid.tikup.me` (already unreachable, see inventory above)
   and does not decide `api.cupidus.app` routing (STORY-001's scope); it
   only avoids shipping a compose service that is structurally guaranteed to
   fail to start on this shared host. Flagging for STORY-001/P2 tech-lead
   awareness: the eventual `api.cupidus.app` reverse-proxy on this VPS will
   most likely need to be a Caddy site block (matching the existing
   `vocabik` pattern), not a container publishing port 80.

## OID-1 input summary (decision left to P2)

- No existing Actions-specific authorized key found; both present
  `authorized_keys` entries are identical-comment personal/dev keys, not
  CI-labeled. No key was generated, rotated, or otherwise changed here.
