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
    file, commit, and STOP before Task 8.
  - **`Frank-Devops-6` COMPLETED** (correctly reported `DEVOPS_COMPLETE: NO`
    at the deliberate mid-story checkpoint; refused to misreport YES).
    Updated `cutover-evidence.md`, committed as `681cbf6` on the story
    branch (new BaseHead). Run auto-finalized `COMPLETION_INVALID` by the
    release hook (spurious — hook expected `YES`); run file's
    `completion_marker`/`completion_error` manually corrected by Scrum
    Master with a `completion_marker_correction` note. Run terminal
    (`status: COMPLETED`), released via `TaskStop`.
  - **Scrum Master performed Task 8's git-control-plane half itself**:
    `git-story-boundary.sh merge --req REQ-005_production_domain_and_cicd_standardization
    --story STORY-002` (sanctioned two-step land model, not a raw merge —
    `RAW_STORY_MERGE` blocks direct `git merge` of a story/integration
    branch). Produced integration-branch merge commit `fb4367a` (16 files,
    1938 insertions/6 deletions: workflow, deploy script, Dockerfile fix,
    `docker-compose.prod.yml`, configuration-guide, 11 STORY-002 artifacts).
    Integration worktree/branch:
    `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-005_production_domain_and_cicd_standardization`,
    `codex/REQ-005_production_domain_and_cicd_standardization-integration`,
    current HEAD `fb4367a` (parent on integration side: `4523068`).
    Caught+corrected a false `sync-status` side effect that auto-marked
    STORY-002 `DONE` in `req_master.md` (reverted to `IN_PROGRESS`, commit
    `6157cc8` — no Reviewer approval yet, Tasks 9/10 outstanding).
  - `git-story-boundary.sh land-integration` (the actual merge into `main`,
    still pending the real `git push`) hit two gates in order:
    `LAND_STORIES_UNMERGED` — resolved via a documented
    `Stories-Merged: WAIVED — ...` line added to `req_master.md` (commit
    `227ec8b`; STORY-001 is still legitimately in progress on unrelated
    Cloudflare scope, not a real merge problem). `LAND_REVIEW_MISSING` —
    **not self-waived** (this gate protects the real, first-ever production
    push/deploy trigger; needs genuine Reviewer judgment). Dispatched
    `Iris-QC-3` (`Mode: requirement-integration-review`, RunId
    `RUN-...-STORY-002-reviewer`) against the integration worktree, diff
    `4523068..HEAD`, to write
    `data/requirements/REQ-005_production_domain_and_cicd_standardization/integration-review/review-report.md`.
  - **`Iris-QC-3` COMPLETED, `Outcome: PATCH_REQUIRED`** (227-line report,
    correctly written the whole time inside the integration worktree at the
    declared `OutputPath` — an earlier Scrum Master check at the *control
    checkout* path incorrectly concluded the file was missing; both that
    misdiagnosis and an earlier "reviewer looks stuck" misdiagnosis (transcript
    mtime check) are now corrected — the reviewer completed a full, careful
    review on schedule). Scrum Master committed the report inside the
    integration worktree: commit `f0f043f` on
    `codex/REQ-005_production_domain_and_cicd_standardization-integration`.
    Run file's spurious `completion_error` ("Missing completion marker...")
    manually corrected/annotated (same pattern as the earlier `Frank-Devops-6`
    false-marker case); run terminal, released via `TaskStop`.
    Findings: **F1 (BLOCKING)** — every `ssh_exec` call in
    `backend/.github/workflows/scripts/vps-deploy.sh` violates the
    forced-command restriction on the deploy key; the `PRIOR_IMAGE` line
    (~line 40) has no `cd` prefix at all (guaranteed rejected), and lines
    ~44-46,55,64,66,71,94,102 send a single-quoted `cd '...' &&` prefix that
    was never verified against the real wrapper. **F2 (BLOCKING)** —
    `GHCR_PULL_TOKEN` is documented/provisioned (OID-3) but no code ever
    consumes it: no VPS-side `docker login ghcr.io`, `vps-deploy.sh:55` pulls
    unauthenticated. **F3 (MEDIUM)** — pre-deploy Postgres dump
    (`vps-deploy.sh:44,102`) omits `-f docker-compose.prod.yml`, resolving to
    the legacy compose file that publishes 5432/6379 on all interfaces.
    **F4 (MEDIUM)** — `pg_dumpall -U ${POSTGRES_USER:-postgres}` expands in the
    VPS login shell, not inside the container/`.env`; untested AC6 safety net
    if the real value isn't literally `postgres`. **F5 (blocks Task 9 only,
    not merge)** — Compose short-syntax bind mount auto-creates a missing
    `service-account.json` as a directory during the AC7 simulation path,
    corrupting the real key; opt-in `workflow_dispatch`, not reachable from
    `push`. **F6/F7 (LOW)** — inert legacy `backend/.github/workflows/deploy.yml`
    undocumented as inert; evidence-doc inconsistencies across
    `test-results.md`/`configuration-guide.md`; `STORY-002/story_master.md`
    still shows `Status: PENDING` with all artifact boxes unchecked despite
    merged implementation (Scrum-Master-owned reconciliation, still pending).
    No secret material in the diff; SSH hardening, GHCR push auth, concurrency
    gating, compose parity with the real VPS baseline, and the loopback-only
    backend port all verified clean. **Dispatched `Frank-Devops-6`** (fresh
    spawn, `RunId RUN-...-STORY-002-devops-patch1`, `Mode:
    devops-implementation`, same story worktree/branch, `BaseHead 681cbf6`) to
    fix F1-F4 only (F5 deferred to a dedicated pre-Task-9 dispatch; F6/F7
    deferred to Task 8 evidence work).
  - **`Frank-Devops-6` COMPLETED, `DEVOPS_COMPLETE: YES`** (verified directly:
    real commit `e143527` on the story branch fixes F1 unquoted-cd-prefix on
    every ssh_exec including an unnamed health-gate curl call, F2 VPS-side
    `docker login` via stdin, F3 `-f docker-compose.prod.yml` pinned on dump +
    post-cutover check, F4 `POSTGRES_USER`/`POSTGRES_DB` expanded inside the
    container). Run's auto-`COMPLETION_INVALID`/spurious `completion_error`
    manually corrected (same false-marker pattern as before).
    `git-story-boundary.sh refresh-base` sealed an additional pointer-file
    commit `d29c7ed`; `git-story-boundary.sh merge` folded both into the
    integration branch as merge commit `bf6427b` (first parent on the
    integration side: `f0f043f`, the original review-report commit). Caught
    +reverted another uncommitted `sync-status` side effect that would have
    flipped STORY-002 to `DONE` in `req_master.md` (working tree already
    matched the last real commit `227ec8b`/`IN_PROGRESS` after the revert, so
    no new commit was needed there). Checkpoint committed `25643e3`.
    Both `Frank-Devops-6` and the prior `Iris-QC-3` released via `TaskStop`.
  - **Dispatched fresh `Iris-QC-3`** (`RunId
    RUN-...-STORY-002-reviewer2`, same `Mode: requirement-integration-review`,
    `BaseHead f0f043f` — an ancestor of current integration HEAD `bf6427b`,
    per the "never HEAD itself" rule) to re-review only the new
    `f0f043f..HEAD` diff against F1-F4, with F5/F6/F7 explicitly out of scope
    unless the new diff touches them. Run `ACTIVE`. **Awaiting result.**

## Next Step

1. STORY-001: `BLOCKED` on `CLOUDFLARE_CREDENTIAL_UNAVAILABLE`. VPS-side
   Caddy work is done and verified; only Cloudflare-cloud-API DNS work
   remains (create `api` A/AAAA record DNS-only, confirm cert, flip to
   proxied, set zone SSL mode Full-strict). **User answered (AskUserQuestion):
   "I'll provide a scoped API token."** Scrum Master sent the user exact
   instructions in chat (scoped token: Zone:DNS Edit + Zone:Zone Read for
   `cupidus.app`, configured via the local Cloudflare CLI, never pasted in
   chat). Waiting on the user to confirm it's configured locally before
   resuming `Frank-Devops-5`. `RunId` `RUN-...-STORY-001-devops`, BaseHead
   `e34385af8c9579b3ee33fdf4f3c6bb8b47665097`.
2. STORY-002: DONE as far as integration landing goes.
   - `Iris-QC-3` re-review returned `Outcome: DEFERRED_ONLY` ("approved to
     merge"); F1-F4 confirmed genuinely fixed via stub-SSH dry-run against
     commit `e143527`. Report committed by Scrum Master directly in the
     integration worktree (it was written but left uncommitted by the
     reviewer) as `8ae3d37`.
   - `land-integration` run and succeeded: integration branch merged into
     `main` at `f87a084` (`Stories-Merged: WAIVED` acknowledged by the gate,
     STORY-001 still pending is expected/intentional per req_master.md).
   - `git push origin main` executed and succeeded — **first-ever push** to
     `hoak57uet/cupidus` (`* [new branch] main -> main`). This is the Task 8
     trigger for the real `deploy-backend.yml` production deploy. User's
     standing authorization ("Yes, push all 776 commits now") is now
     CONSUMED.
   - `req_master.md` Deployment Status updated to `DEPLOY_TRIGGERED` with the
     push SHA and outstanding Task 8/9/10 evidence note.
   - `STORY-002/story_master.md` updated: `Status: IN_PROGRESS`,
     Implementation box checked with landing SHAs, Review box still unchecked
     pending story-level Reviewer gate.
   - **Not yet done / next steps for STORY-002**: (a) observe the first real
     `deploy-backend.yml` run on GitHub Actions as Task 8 evidence; (b) fix F5
     (bind-mount issue, blocks Task 9) before dispatching devops for Task 9
     (AC7 negative rollback proof); (c) Task 10 (AC6 re-verification); (d)
     once genuine end-to-end evidence exists, route the *story itself*
     (separate from the integration review just completed) through the full
     story-scoped Reviewer gate before marking STORY-002 `DONE` (complex
     stories are excluded from Tier 0 lightweight validation).
   - **Deferred hygiene cleanup (non-blocking, Scrum-Master-owned, not yet
     done)**: finding N3 — duplicate pointer file
     `STORY-002/cutover-evidence.md` (real evidence is at
     `STORY-002/devops/cutover-evidence.md`) was auto-created by
     `refresh-base` and is now merged onto `main`. A `git rm` of it was
     blocked by `bash-safety-guard.sh [GENERIC]` requiring explicit user
     confirmation before a destructive removal on `main` — ask the user
     before removing, or leave it as a documented pointer. N1 (redundant
     `ssh_exec_stdin` helper) and N2 (no `docker logout` after GHCR pull) are
     LOW/LOW-MEDIUM follow-ups, not scheduled yet.
3. Refresh this checkpoint after every specialist result; re-run dispatch
   discipline (fill capacity) before waiting again.
4. Scheduler confirmed QUIESCENT this pass: `active_runs: []`,
   `paused_runs: []`, `blocked_runs: [RUN-...-STORY-001-devops]` (genuinely
   blocked on the user, not a live run). `prune-parallel-runs.sh --apply`
   already run. Releasable agents `Frank-Devops-6`/`Iris-QC-3` already
   `TaskStop`-released this pass.

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
