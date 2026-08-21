# REQ-005 Requirement Integration Review — STORY-002

Outcome: DEFERRED_ONLY

- Reviewer: Iris-QC
- Mode: requirement-integration-review (re-review of the F1-F4 patch)
- Scope: STORY-002 (Standardize VPS backend deploys onto GitHub Actions CI/CD)
- Branch: `codex/REQ-005_production_domain_and_cicd_standardization-integration`
- Re-review diff baseline: `f0f043f..bf6427b` (5 files, +168 / -13)
- Superseded review: `Outcome: PATCH_REQUIRED` at diff `4523068..f0f043f`, same
  reviewer role, 2026-08-21. Its F1-F7 analysis is preserved below with a
  per-finding re-review verdict; the parts of `4523068..f0f043f` it already
  cleared were not re-litigated.
- Patch commits reviewed: `e143527` (F1-F4 fix in `vps-deploy.sh` /
  `deploy-backend.yml`), `d29c7ed` (release-gate pointer file), merged as
  `bf6427b`
- Date: 2026-08-21

## Verdict

All four findings the prior review required before merge (F1, F2, F3, F4) are
genuinely fixed in the code, not merely claimed in commit prose. I verified
this by executing `vps-deploy.sh` against a stub `ssh` that prints the exact
generated remote command string and applies the same prefix test the VPS
forced-command wrapper applies — the "verify against the real generated
strings, not a hand-typed representative" step the prior report demanded.
Every one of the nine remote command strings the script emits is accepted by
that prefix test, the GHCR token appears only on stdin, and
`$POSTGRES_USER`/`$POSTGRES_DB` reach the container's own shell unexpanded.

The patch also fixed a defect the prior review missed (the health-gate `curl`
had no `cd` prefix either), which would have caused every deploy to time out
and roll back even on a healthy app.

Outcome is `DEFERRED_ONLY` rather than `CLEAN` because F5, F6, and F7 remain
open exactly as originally scoped — none of them blocks the merge, and the
patch deliberately left them alone per its handoff. Three new low-severity
observations (N1-N3) are also non-blocking.

## Re-review verdicts on F1-F4

### F1 — forced-command prefix violations — FIXED (verified)

All eleven remote call sites in `.github/workflows/scripts/vps-deploy.sh` now
interpolate `VPS_DEPLOY_PATH` **unquoted** at the prefix position
(`:55`, `:65`, `:67`, `:79`, `:83`, `:92`, `:94`, `:99`, `:112`, `:122`,
`:134`). `git grep` over `.github/` and `backend/.github/` confirms there is no
other `ssh` call site in the repository.

Verification method (local dry-run, `VPS_DEPLOY_PATH=/var/www/backend`, stub
`ssh` echoing `${!#}` and applying `case "$CMD" in "cd /var/www/backend && "*)`):
all nine command strings the default (non-simulation) path emits were ACCEPT.
Representative generated strings, verbatim:

```
cd /var/www/backend && docker inspect --format '{{.Config.Image}}' cupid-backend 2>/dev/null || echo NONE
cd /var/www/backend && docker compose -f docker-compose.prod.yml up -d postgres && sleep 5 && mkdir -p backups && docker compose -f docker-compose.prod.yml exec -T postgres sh -c 'pg_dumpall -U "$POSTGRES_USER"' > backups/pre-deploy-$(date +%Y%m%dT%H%M%SZ).sql && ls -la backups/ | tail -5
cd /var/www/backend && docker login ghcr.io -u 'owner' --password-stdin
cd /var/www/backend && curl -sf -o /dev/null -w '%{http_code}' http://127.0.0.1:3010/ | grep -q '^200$'
```

The `PRIOR_IMAGE` call named in the prior report now carries the prefix, and
the `|| echo NONE` fallback keeps its original semantics: `&&`/`||` are
left-associative at equal precedence, so a failed `cd` or a failed
`docker inspect` both yield `NONE`.

The two AC7 `mv` calls (`:92`, `:94`) and the rollback call (`:122`) were not
exercised by the dry-run (they are behind `SIMULATE_HEALTH_GATE_FAILURE` and
the failure branch), but their interpolation form is character-identical to the
nine proven strings.

Beyond the review's list, the patch found and fixed the health-gate `curl`
poll (`:112`), which had no `cd` prefix at all. Left unfixed, the wrapper would
have rejected all 20 polls and forced a rollback on every otherwise-healthy
deploy. This is credible evidence the re-audit was line-by-line rather than
finding-by-finding.

Residual risk (named, not blocking — see Residual risks below): correctness
depends on the `VPS_DEPLOY_PATH` GitHub secret being exactly `/var/www/backend`
with no trailing slash or whitespace.

### F2 — `GHCR_PULL_TOKEN` never consumed — FIXED (verified)

`.github/workflows/deploy-backend.yml:86-88` now passes `GHCR_PULL_TOKEN`
(from `secrets.GHCR_PULL_TOKEN`) and `GHCR_PULL_USER` (from
`github.repository_owner`, a non-secret) into the `deploy-and-verify` step's
`env:` block. `vps-deploy.sh:12-13` hard-requires both via `:?missing`, so an
unprovisioned secret fails loudly on the runner before any VPS contact.

`vps-deploy.sh:79` runs `docker login ghcr.io ... --password-stdin` over SSH,
placed after the pre-deploy dump and **before** the
`docker compose -f docker-compose.prod.yml pull` at `:83`. Credentials persist
in the VPS user's `~/.docker/config.json`, so the login in one SSH session
authenticates the pull in the next.

Token-exposure check, confirmed by the dry-run: the emitted command string is
`cd /var/www/backend && docker login ghcr.io -u 'owner' --password-stdin` —
the token is absent from it, and therefore absent from Actions logs and from
remote `ps` output. The captured remote stdin was
`REMOTE_STDIN>>>SECRET_TOKEN_VALUE<<<`, proving the herestring at `:79` does
reach the remote command's stdin. See N1 for a caveat about the helper that
carries it.

### F3 — dump/check ran against the legacy compose file — FIXED (verified)

`-f docker-compose.prod.yml` is now pinned on all three previously-bare
invocations: `up -d postgres` and `exec -T postgres pg_dumpall` inside
`DUMP_CMD` (`:65`), and `exec -T postgres psql` in the post-cutover check
(`:134`). Confirmed present in the generated strings above.

Cross-checked against `backend/docker-compose.prod.yml`: it does declare a
`postgres` service (`:31-40`), so `-f docker-compose.prod.yml up -d postgres`
resolves rather than failing with "no such service", and neither `postgres`
nor `redis` declares a `ports:` mapping there. The transient
`0.0.0.0:5432` exposure window during backup is closed.

### F4 — `POSTGRES_USER` expanded in the VPS login shell — FIXED (verified)

Both call sites now use `sh -c` inside the container. The dry-run confirms the
strings that leave the runner contain `sh -c 'pg_dumpall -U "$POSTGRES_USER"'`
and `sh -c 'psql -U "$POSTGRES_USER" -d "$POSTGRES_DB" -c "SELECT count(*) FROM users;"'`
— the `$` survives the runner's double-quoted assembly, and the VPS-side `eval`
passes it through untouched because it sits inside single quotes. Only the
container's `sh` expands it.

The values are guaranteed to exist in that container's environment:
`backend/docker-compose.prod.yml:35-38` sets `POSTGRES_USER`,
`POSTGRES_PASSWORD`, and `POSTGRES_DB` on the `postgres` service via Compose
substitution from the VPS-owned `.env`. Dropping the shell-side
`:-postgres` / `:-cupid` defaults therefore does not introduce an
empty-argument failure mode; the Compose-side defaults still apply.

The patch applied the fix to the post-cutover check as well, which the prior
report had listed under F3 rather than F4 — correct, both call sites had the
bug.

## Findings that remain open (non-blocking, unchanged by this patch)

Confirmed unchanged: `git diff f0f043f..HEAD` touches neither
`backend/docker-compose.prod.yml`, nor `STORY-002/story_master.md`, nor
`STORY-002/coding-plan/`, nor `backend/.github/workflows/deploy.yml`. The three
findings below therefore stand exactly as originally written, and were not
re-litigated.

### F5 — the AC7 simulation path can permanently break production (MEDIUM — do not run Task 9 until fixed)

`vps-deploy.sh:92` runs `mv service-account.json service-account.json.ac7-hidden`,
then `:99` runs `docker compose up -d`. Compose short-syntax bind mounts
auto-create a missing host source **as a directory**, so `up -d` creates
`./service-account.json/`. The restore at `:94` then moves the key *into* that
directory as `service-account.json/service-account.json` rather than restoring
it — leaving the backend permanently bind-mounting a directory over its
Firebase key. The "restores it unconditionally via a shell trap" claim in
`devops/cutover-evidence.md:70-72` does not hold under this Docker behavior.
The mount is still short-syntax at `backend/docker-compose.prod.yml:63`.

Secondary: `trap 'restore_service_account' EXIT` at `:96` *replaces* the
`cleanup` trap, so if `:99` fails the SSH private key and known-hosts files are
never removed (low severity on an ephemeral runner).

Fix: use long-syntax `type: bind` with `create_host_path: false` for that
mount, make the restore fail loudly if the target is a directory, and chain the
traps instead of replacing them.

Why this does not block the merge: the path is opt-in behind a
`workflow_dispatch` input defaulting to `false` and is unreachable from the
`push` trigger. It must be fixed before Task 9 is ever dispatched.

### F6 — AC3's legacy deploy path is untouched and undocumented (LOW)

`backend/.github/workflows/deploy.yml` is still tracked, still declares
`on: push: branches: [main]` under the same workflow `name: Deploy Backend`,
still uses unpinned `appleboy/scp-action@master` / `appleboy/ssh-action@master`
(re-confirmed by `git grep` over `backend/.github/`), and runs a destructive
`docker-compose down && docker-compose up -d --build`. It is inert **only**
because it sits at `backend/.github/workflows/` rather than the repo root, so
GitHub will not schedule it — there is no double-deploy risk on the first push.
But no artifact mentions the file, while `deployment/configuration-guide.md:70-72`
promises the legacy trigger will be "disabled (not deleted) ... with a dated
note left beside it". Record its inert status explicitly and handle it under
AC3 after the first green run.

### F7 — evidence inconsistencies (LOW)

- `coding-plan/test-results.md:101-103` still states `GHCR_PULL_TOKEN`
  "remains a placeholder"; `devops/cutover-evidence.md:257-270` states it was
  resolved with a real value at 03:51Z. Same story, contradictory claims.
  Unchanged by this patch.
- `deployment/configuration-guide.md:5-7` still states "All values below are
  placeholders ... The user populates the real values", while
  `devops/cutover-evidence.md:149-156` records 6 of 7 set to real values by the
  agent under explicit user authorization. AC4's *intent* (never source or
  guess a real credential discovered on the VPS) is satisfied — the deploy key
  was freshly minted, the known-hosts value is a public host key — but the
  guide misdescribes the actual state. The patch appended an accurate F2
  rationale block at `:26-44` without correcting the stale header at `:5-7`.
- `STORY-002/story_master.md` still shows `Status: PENDING` with
  `- [ ] Implementation (Development)` unchecked. Scrum-Master-owned; must be
  reconciled before DONE.

## New observations from this patch (all non-blocking)

### N1 — `ssh_exec_stdin` is a byte-identical copy of `ssh_exec` (LOW)

`vps-deploy.sh:49-51` is character-for-character the same body as `:42-44`.
The comment at `:46-48` describes a stdin-forwarding behavior the helper does
not itself implement. The F2 fix works anyway — `ssh` forwards the local stdin
to the remote command by default when a command is given and neither `-n` nor
`-f` is used, which the dry-run confirmed — so this is a redundant abstraction
with a misleading comment, not a defect.

Related, informational: because plain `ssh_exec` also inherits the script's
stdin, the 20-iteration health-gate loop would drain a piped stdin if one ever
existed. GitHub Actions `run:` steps get stdin from `/dev/null`, so this is
inert today.

Suggested: delete `ssh_exec_stdin`, call `ssh_exec` with the herestring, and
move the "token travels on stdin" rationale to the `docker login` line.

### N2 — no `docker logout` after the pull (LOW-MEDIUM, follow-up)

`vps-deploy.sh:79` logs in but nothing logs out. The GHCR pull token persists
base64-encoded in the VPS user's `~/.docker/config.json` indefinitely, on a
host that also serves the unrelated live `vocabik` tenant. Marginal added
exposure (a host compromise already yields the root deploy key), but a
`docker logout ghcr.io` after `:83`, or in the cleanup path, would bound it.

### N3 — duplicate `cutover-evidence.md` committed to satisfy a mismatched release gate (LOW, Scrum-Master-owned)

Commit `d29c7ed` adds
`data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-002/cutover-evidence.md`,
a 13-line pointer whose own body states it exists only to satisfy the parallel
run's declared `OutputPath`, which did not match this worktree's real artifact
layout. The canonical evidence remains at `STORY-002/devops/cutover-evidence.md`.
The file is honest about itself, but leaves two files named `cutover-evidence.md`
in the requirement tree. Scrum Master should correct the handoff's
`OutputPath`/`WriteScope` and remove the pointer rather than keep it.

## Verified clean (carried forward from the superseded review, re-confirmed against the current diff)

- **No secret material in the push.** No hardcoded credential in the workflow,
  the deploy script, or the compose file. The patch introduces none: the only
  new secret reference is `${{ secrets.GHCR_PULL_TOKEN }}` in the workflow
  `env:` block, and the dry-run confirms its value never enters a command
  string.
- `StrictHostKeyChecking=yes` with `UserKnownHostsFile` pinned from
  `VPS_SSH_KNOWN_HOSTS`, `BatchMode=yes`; the private key is written under
  `RUNNER_TEMP` with `umask 077` + `chmod 600` and removed in an EXIT trap
  (except the F5 window). Unchanged by the patch.
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
  VPS-shape compose, so there is **no** Postgres major-version and no
  database-name mismatch against the existing 48M data directory. File
  untouched by the patch.
- Backend published loopback-only at `127.0.0.1:3010:3000`; `BACKEND_PORT`
  defaults to `3010` in the script, matching. No nginx service (host Caddy owns
  80/443). Does not disturb the unrelated live `vocabik` tenant.
- `backend/Dockerfile` no longer bakes `service-account.json` into the image,
  verified by a from-scratch build with no key in context
  (`test-results.md:3-10`).
- `vps-deploy.sh` remains fail-safe on every newly-introduced failure mode: a
  missing `GHCR_PULL_TOKEN`/`GHCR_PULL_USER` aborts on the runner before VPS
  contact (`:12-13`), a failed `docker login` aborts under `set -euo pipefail`
  before the pull, and a wrapper rejection aborts on the first remote call
  before the dump, the pull, and the `up -d`.

## Residual risks (accepted / deferred)

- **F1's fix is correct-by-construction but not live-verified.** The devops
  rework explicitly records this (`devops/cutover-evidence.md`, "Verification
  status: NOT live-re-verified against the real VPS in this session"), and the
  prior report's requirement to "re-verify against the real generated strings"
  is satisfied here by the stub-`ssh` dry-run above — but nothing in this
  dispatch can reach the real VPS, and the deploy only triggers on push to
  `main`, so pre-merge live verification is unsatisfiable by design. The one
  input the dry-run cannot check is the `VPS_DEPLOY_PATH` secret's exact value:
  a trailing slash or stray whitespace makes the wrapper reject all nine calls.
  That failure is fail-safe (first remote call, before any VPS state change)
  and loud. Task 8's "observe the first green run" is the verification step.
- Tasks 8 (merge-to-main / real deploy), 9 (AC7 negative rollback proof) and
  10 (AC6 re-verification) are not done. Accepted per the handoff; they depend
  on this landing. Task 9 additionally requires F5 fixed first.
- `GHCR_PULL_USER` is derived from `github.repository_owner`, which assumes the
  provisioned `GHCR_PULL_TOKEN` belongs to that account. If it does not,
  `docker login` fails visibly at deploy time; the fix is re-provisioning the
  secret, not editing the workflow. Documented at
  `deployment/configuration-guide.md:38-44`.
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

## Merge disposition

This branch is approved to merge. Nothing that remains open is a merge blocker:
F5 is unreachable from the `push` trigger, F6 is inert, F7 and N3 are
documentation/state reconciliation, N1 and N2 are hygiene follow-ups.

Before Scrum Master marks STORY-002 `DONE`:

1. Reconcile `STORY-002/story_master.md` (`Status: PENDING`, unchecked
   implementation box) — F7, Scrum-Master-owned.
2. Observe the first real deploy run as Task 8 and record whether the
   forced-command prefix and the GHCR login behaved as analyzed here.

Before Task 9 is ever dispatched: fix F5.

REVIEW_COMPLETE: YES
