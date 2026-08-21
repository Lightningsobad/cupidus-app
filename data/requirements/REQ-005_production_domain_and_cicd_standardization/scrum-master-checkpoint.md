# Scrum Master Checkpoint: REQ-005

Flow: parallel-requirement (continue parallel wave)
Requirement: REQ-005_production_domain_and_cicd_standardization
Status: IN_PROGRESS — user explicitly authorized live production VPS actions
for both stories (AskUserQuestion: "Yes, proceed with both"); resuming both

## State As Of This Checkpoint

- Integration worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-005_production_domain_and_cicd_standardization`,
  branch `codex/REQ-005_production_domain_and_cicd_standardization-integration`.
  No paused merge (`MERGE_HEAD` absent, worktree clean).

- STORY-001 (`Point api.cupidus.app at the production backend API`, standard,
  single-lane devops):
  - Requirements DONE, UX WAIVED, Architecture DONE — **but now under
    revision**, see below.
  - USER ANSWERED (this checkpoint revision) both prior blockers:
    1. Git remote: user confirmed `https://github.com/hoak57uet/cupidus` is
       the one repo for the whole project (backend+frontend+mobile). Added
       via `git remote add origin https://github.com/hoak57uet/cupidus`
       (control checkout; worktrees share `.git/config`). `SECRET_REQUIRED`
       is superseded, not by adding a GH Actions secret but by a *scope
       change*: the user wants Cloudflare DNS/Origin-CA setup done **once,
       directly via the Cloudflare CLI already installed on this local
       machine** — NOT via a `CLOUDFLARE_API_TOKEN` GitHub Actions secret.
       GitHub Actions secrets are for frontend/backend CI/CD only.
    2. `ORIGIN_CERT_PROVISION_FAILED`: user chose "Retry with tool access" —
       next DevOps dispatch for this story must have WebSearch/WebFetch/
       ToolSearch available.
  - **NEW architectural blocker superseding both of the above for now**:
    STORY-002's P1 VPS inspection
    (`STORY-002/devops/vps-inspection.md`, "Critical finding" section)
    discovered the VPS's real reverse proxy for ports 80/443 is **Caddy**
    (already serving an unrelated live site, `vocabik`), not nginx — the
    `cupid-nginx` container this story's approved architecture extends has
    never actually run on this VPS and structurally cannot bind 80/443
    without conflicting with Caddy. This invalidates the
    nginx/`docker-compose.yml` 443-publish TLS-termination approach in the
    already-approved `architecture/solution.md`.
  - **`Alan-Techlead-3` architecture revision returned `ARCHITECTURE_COMPLETE:
    YES`** (run `RUN-...-STORY-001-tech-lead-revision`, now `COMPLETED` and
    released). Revised approach: Caddy site-block
    (`api.cupidus.app { reverse_proxy 127.0.0.1:<port> }` on the VPS,
    matching the existing `vocabik` Caddyfile pattern) replaces the
    nginx/443-publish TLS-termination design entirely. Origin CA is
    **eliminated** — Caddy issues/renews its own cert via Cloudflare DNS-01
    once DNS is DNS-only (grey cloud) during issuance. Ordered Cloudflare-CLI
    DNS sequence: (1) create `api` A/AAAA record DNS-only, (2) Caddy
    obtains cert + confirms `https://api.cupidus.app` serves the backend,
    (3) flip the record to proxied (orange cloud) once confirmed working,
    then set the zone/record to Full (strict) SSL mode. P1 coding-plan
    (`STORY-001/coding-plan/phase-P1-api-hostname-tls-edge.md`) rewritten
    to match; P1 status reset to `NOT_STARTED`, `Blockers: NONE`.
  - **Cross-story finding from this revision**: STORY-002's already-shipped
    `backend/docker-compose.prod.yml` publishes the backend on `"3000:3000"`
    (all interfaces) — this conflicts with the shared VPS's existing Caddy
    route for the unrelated `vocabik` site and is also an unneeded
    plaintext-internet exposure. Must become `127.0.0.1:<port>:3000` with
    `<port>` verified free live via `ss -ltnp` (not guessed/reused as 3000).
    STORY-001's Caddy site block must `reverse_proxy` to that exact same
    port once STORY-002 picks it — folded into STORY-002's next dispatch
    (see below); STORY-001's next DevOps dispatch must read the chosen port
    back from this checkpoint/STORY-002 evidence before writing its
    Caddyfile, not invent its own.
  - `Frank-Devops-3`'s prior repo-side prep (nginx additive block,
    `.gitignore`, old compose 443-publish edits, DNS script) is now
    obsolete under the revised architecture. `RUN-...-STORY-001-devops`
    marked `SUPERSEDED` (not resumed); `Frank-Devops-3` left idle/unreleased
    (release guard fails closed on non-standard status — acceptable, it is
    parked with durable `waiting_reason`/`next_resume_action`, not tracked
    in any active/blocked scheduler list). **Next STORY-001 DevOps dispatch
    must first revert this obsolete uncommitted prep** in the STORY-001
    worktree before writing the new Caddy-based implementation, per the
    revised coding plan.
  - `Frank-Devops-5` completed Task 0 cleanup + VPS-side Caddy work: reverted
    obsolete `Frank-Devops-3` prep, installed the `api.cupidus.app` Caddy
    site block (`reverse_proxy 127.0.0.1:3010`), reloaded Caddy, verified no
    regression on the co-tenant `vocabik` site. Wrote
    `deployment/caddy/api.cupidus.app.caddy` (in-repo source of truth,
    flagged as outside declared `write_scope` — additive/low-risk, accepted).
    **BLOCKED on `CLOUDFLARE_CREDENTIAL_UNAVAILABLE`**: no
    `CLOUDFLARE_API_TOKEN`/`CLOUDFLARE_ZONE_ID` found in env, shell rc files,
    Keychain, or `.env` files; only `cloudflared` (Tunnel client) is
    installed locally, which cannot do `dns_records`/zone-settings API
    calls. DNS record creation, proxy flip, and zone SSL mode change remain
    undone. Run `BLOCKED`, removed from `active_runs`. **Awaiting user
    decision on Cloudflare credential source** (see "Next Step").

- STORY-002 (`Standardize VPS backend deploys onto GitHub Actions CI/CD`,
  complex, single-lane devops):
  - Requirements DONE, UX WAIVED, Architecture DONE (solution + coding-plan
    both complete and gate-verified).
  - Coding plan: P1 (`phase-P1-vps-inspection-and-deploy-artifacts.md`,
    read-only VPS inspection + Dockerfile/compose fix, no secrets/remote
    needed) then P2 (`phase-P2-actions-pipeline-cutover-and-rollback-proof.md`,
    depends on P1, owns the GitHub Actions workflow + secrets + cutover).
  - P1 implementation returned `DEVOPS_COMPLETE: NO`, run status `BLOCKED`
    (`RUN-REQ-005_production_domain_and_cicd_standardization-STORY-002-devops`,
    `Frank-Devops-4`). BaseHead used:
    `548029eb809c6da6029cac5e513e783a9b86abc4`.
  - VPS inspection (`STORY-002/devops/vps-inspection.md`) completed clean:
    Dockerfile build without `service-account.json` PASS, credential-copy
    line removed, AC6 baseline captured (compose project `backend`, volumes
    `backend_postgres_data`/`backend_redis_data`, 48M real Postgres data on
    disk). Also produced the Caddy/nginx architectural finding now driving
    STORY-001's revision above.
  - Outstanding blocker: `guard-shared-infra.sh [REPO_LOCAL_INFRA]` rejected
    the `Write` of `backend/docker-compose.prod.yml` because it declares
    `postgres`/`redis` services — this file is a VPS-targeted **production**
    deploy overlay (must declare the VPS's own already-existing containers/
    volumes to reuse them verbatim; never runs on the local dev machine), not
    local-dev infra the guard's `devstack`-migration remedy applies to.
    `guard-codes.md`'s `REPO_LOCAL_INFRA` section documents no VPS-production
    carve-out.
  - USER ANSWERED: guard-shared-infra.sh has been updated to judge by an
    explicit `# devstack: environment=production - ...` first-line marker
    comment rather than filename/service-name pattern alone; real
    postgres/redis services are fine as long as no dependency port is
    published to all interfaces (loopback-only, e.g. `127.0.0.1:5432:5432`),
    deployed via `ssh <host> 'docker compose -f ... up -d'`.
  - P1 RESULT: `DEVOPS_COMPLETE: YES`. `docker compose -f
    backend/docker-compose.prod.yml config` exit 0; volumes match VPS AC6
    baseline; no nginx service (Caddy owns 80/443); no dependency port
    published. `Frank-Devops-4` released. `git-story-boundary.sh
    refresh-base` sealed the worktree (new BaseHead
    `2b84c0e0cdd179fdea186c846448ec1626703999`).
  - P2 dispatched: fresh `Frank-Devops-4` (Actions pipeline, secrets
    (`VPS_SSH_*`, `GHCR_PULL_TOKEN`), ordered cutover, AC7 negative rollback
    proof) per `phase-P2-actions-pipeline-cutover-and-rollback-proof.md`.
    **RESULT: `DEVOPS_COMPLETE: NO`, blocker `CUTOVER_INCOMPLETE`.**
    Workflow, deploy script, OID-1/2/3 decisions, configuration-guide, and
    placeholder GitHub secrets are done and locally validated (tasks 1, 3-6
    complete). Tasks 2, 7, 8, 9, 10 (mint+install a real VPS deploy key,
    deliver the compose file to the VPS, ordered cutover merge-to-main that
    self-triggers a real production deploy, negative rollback test against
    real ~48M-row Postgres data, AC6 re-verification) require live root SSH
    execution against the real production VPS and a merge to `main`.
    `Frank-Devops-4` correctly declined to treat a peer/worker escalation as
    user authorization for production actions and paused; escalated via
    SendMessage. **User explicitly authorized proceeding (AskUserQuestion:
    "Yes, proceed with both").** While parked, `Frank-Devops-4` already
    applied the port fix (read-only `ss -ltnp` check, no state change):
    `backend/docker-compose.prod.yml` backend port changed
    `"3000:3000"` -> `"127.0.0.1:3010:3000"` (ports 3000/3001 were already
    loopback-bound by the unrelated live `vocabik` app); `vps-deploy.sh`
    `BACKEND_PORT` default updated to `3010`; `docker compose config`
    re-validated exit 0. **CONFIRMED PORT FOR STORY-001: 3010** — its Caddy
    site block for `api.cupidus.app` must `reverse_proxy 127.0.0.1:3010`.
    Run resumed `ACTIVE`, back in `active_runs`. Resuming via `SendMessage`
    to complete tasks 2/7/8/9/10 (deploy key, compose delivery, ordered
    cutover merge to `main`, AC7 negative rollback proof, AC6
    re-verification).
  - Tasks 2/7 completed with full evidence (deploy key minted/installed/
    verified on VPS; `docker-compose.prod.yml` delivered + validated in
    place). Blocked again on `SECRETS_UNPROVISIONED` (`GHCR_PULL_TOKEN`
    placeholder — no agent can mint `packages` scope). **User confirmed
    2026-08-21: `GHCR_PULL_TOKEN` now set via `gh secret set` (real classic
    PAT, `read:packages` scope). All 7/7 secrets real.** Run kept `BLOCKED`
    (not resumed yet) — see "Next Step" for the deliberate devops-cap
    sequencing reason.
  - **Session recovery**: `Frank-Devops-4` was no longer reachable (not in
    `ListAgents`) when the resume `SendMessage` was sent; that continuation
    never actually executed. Its uncommitted Tasks 1-7 work (workflow +
    script, cutover-evidence.md, configuration-guide.md, docker-compose fix,
    test-results.md) was intact in the worktree and sealed via
    `git-story-boundary.sh commit` -> commit `a853b8f`, then
    `refresh-base` -> new BaseHead `a853b8ff5fa58755983e2f5e761602c4fd5439ab`.
    Fresh `Frank-Devops-6` spawned (`Session-Recovery: YES`, same `RunId`)
    to re-verify 7/7 secrets + `docker compose config`, update the evidence
    file, commit, and STOP before Task 8 — same merge-to-main
    Scrum-Master-ownership instruction as before. Run `ACTIVE`, back in
    `active_runs`. Awaiting result.

## Next Step

1. STORY-001: `BLOCKED` on `CLOUDFLARE_CREDENTIAL_UNAVAILABLE`. VPS-side
   Caddy work is done and verified; only Cloudflare-cloud-API DNS work
   remains (create `api` A/AAAA record DNS-only, confirm cert, flip to
   proxied, set zone SSL mode Full-strict). **Waiting on user decision**:
   asked via `AskUserQuestion` how to supply Cloudflare DNS-API access
   (provide a scoped API token for the agent to use locally / do the
   3-step DNS sequence manually via the dashboard themselves / other). Do
   not resume `Frank-Devops-5` until the user answers. `RunId`
   `RUN-...-STORY-001-devops`, BaseHead
   `e34385af8c9579b3ee33fdf4f3c6bb8b47665097`.
2. STORY-002: `Frank-Devops-4` was unreachable; work sealed to commit
   `a853b8f` (BaseHead refreshed) and fresh `Frank-Devops-6` spawned
   `ACTIVE` (RunId `RUN-...-STORY-002-devops`, `Session-Recovery: YES`) for
   pre-merge re-verification only (GHCR_PULL_TOKEN now real; confirm 7/7
   secrets + `docker compose config` still exit 0), then commit and STOP
   before Task 8. No result yet — waiting on SubagentStop/mailbox
   notification. When it reports: **Scrum Master performs the
   merge-to-main git action itself** (git-control-plane ownership), then
   spawns/resumes a devops agent for Task 9 (AC7 negative rollback proof)
   and Task 10 (AC6 re-verification). No same-VPS collision risk with
   STORY-001 since STORY-001's remaining work is Cloudflare-cloud-side
   only. On `DEVOPS_COMPLETE: YES` this is the story's last phase — route
   to Reviewer (not Scrum Master Tier 0).
3. Refresh this checkpoint after every specialist result; re-run dispatch
   discipline (fill capacity) before waiting again.
4. While either run stays non-terminal, a plain Stop is guard-blocked by
   `guard-open-parallel-runs-on-stop.sh [OPEN_RUNS]`; reconcile
   (list-releasable-agents, run-state re-read) and emit `WAVE_STOPPED` JSON
   rather than inventing a `TaskOutput` id or polling with shell loops
   (explicitly blocked by `bash-safety-guard.sh`).

## Do Not Re-read

- REQ-006 / REQ-007 req_master.md (separate requirements, not in scope)
- data/intake/bootstrap/* (bootstrap already DONE)
- data/retro-audit/rework-backlog.md (confirmed fully resolved this pass)
- STORY-001/STORY-002 requirements.md bodies, STORY-002 architecture/solution.md
  full body, both coding-plan/master-plan.md bodies (already consumed/
  summarized above; query-first only if needed)
- STORY-001/coding-plan/test-results.md full body (summarized above)
- STORY-002/devops/vps-inspection.md full body (summarized above; already
  quoted verbatim into the Alan-Techlead-3 handoff)
- STORY-002/coding-plan/test-results.md full body (summarized above)
