# STORY-002 P2 — Cutover Evidence

## Open Implementation Decisions (recorded before workflow authoring)

### OID-2 — SSH mechanism

`WebSearch`/`WebFetch` are unavailable in this run (`ToolSearch` is disabled
for this session, subagents included — confirmed by direct attempt, not
assumed). Per the phase file's own fallback rule ("If that cannot be
established, use the runner's OpenSSH client driven by
`.github/workflows/scripts/vps-deploy.sh`, which has no supply-chain
surface"), **decision: OpenSSH client via `.github/workflows/scripts/vps-deploy.sh`**,
not a third-party SSH marketplace action. No SHA-pinning question arises for
the credential path because no third-party action sits in it. `actions/checkout`,
`docker/setup-buildx-action`, `docker/login-action`, and `docker/build-push-action`
are used only in `build-and-push` (GHCR push authenticated with the
Actions-issued `GITHUB_TOKEN`, not a long-lived VPS credential) — outside the
SSH credential path OID-2 scopes, at official Docker-org/GitHub-org major-version
tags consistent with common practice; revisit for SHA-pinning once
`WebSearch`/`WebFetch` are available in a future run.

### OID-1 — Deploy key: dedicated vs. reuse

Per `STORY-002/devops/vps-inspection.md`: `authorized_keys` on the VPS holds
exactly two entries, both `ssh-ed25519` with the identical comment
`alantravala@d0hcf65j0l` — i.e., both read as the operator's personal/dev-machine
key (likely a duplicate), not an Actions-labeled or CI-scoped key. No
existing key was demonstrated broken (AC5's bar for reuse is "an
Actions-specific key already exists and works" — none does).

**Decision: mint a dedicated least-privilege deploy key for GitHub Actions.**
Rationale: a personal key in CI means every workflow contributor inherits the
operator's shell access, and revocation would force a human key rotation
(architecture I-4 / OID-1 criteria). The new key must be constrained in
`authorized_keys` with `command=`, `no-port-forwarding`, `no-agent-forwarding`,
`no-pty` so a leaked CI secret buys a scoped deploy command, not a root shell.

**Execution status: NOT YET PERFORMED.** Minting the key pair and appending
the constrained entry to `/root/.ssh/authorized_keys` requires live root SSH
access to the production VPS (`root@84.247.140.178`) and is scoped to the
live-cutover phase below, which is paused pending explicit user confirmation
per the escalation sent to Scrum Master/team-lead (see "Status" section).

### OID-3 — GHCR package visibility

**Decision: keep the package private, provision `GHCR_PULL_TOKEN`.**
Rationale: per the phase's own criterion, the image contains built
application code (compiled `backend/dist` plus `node_modules`), which is not
acceptable to publish openly by default absent an explicit user decision to
the contrary; the safer default is a private package with a read-scoped pull
token on the VPS.

## Task 4 — workflow authored

- `.github/workflows/deploy-backend.yml`: two jobs, `build-and-push`
  (`push` to `main` + `workflow_dispatch`, `packages: write`, builds
  `backend/Dockerfile`, tags by full commit SHA plus a `latest` convenience
  pointer, runs `docker compose -f backend/docker-compose.prod.yml config` as
  a pre-deploy validation step) and `deploy-and-verify` (SSH via
  `vps-deploy.sh`, `concurrency: group: deploy-backend-production,
  cancel-in-progress: false` to serialize per-environment so no interleaved
  pull/up).
- `.github/workflows/scripts/vps-deploy.sh`: pins the host key from
  `VPS_SSH_KNOWN_HOSTS` (`StrictHostKeyChecking=yes`), records the prior
  running image reference, writes a pre-deploy `pg_dumpall` and asserts
  non-zero size before promoting, pulls then `up`s the replacement, polls
  `GET http://127.0.0.1:<port>/` with bounded retries, restores the prior
  image reference and exits non-zero on gate failure. `workflow_dispatch`
  input `simulate_health_gate_failure` (used only for the task 9 AC7 proof)
  temporarily renames `service-account.json` on the VPS for the duration of
  that one deploy and restores it unconditionally via a shell trap, whether
  the gate passes, fails, or the job is cancelled.
- Local validation (no VPS/network access, no secret material):
  - `python3 -c "yaml.safe_load(...)"` on `deploy-backend.yml`: parses clean.
  - `docker compose -f backend/docker-compose.prod.yml config` (run from
    inside the worktree with placeholder env values): exits 0; resolved
    volume names are `backend_postgres_data` / `backend_redis_data` and
    resolved project network is `backend_default` — matches P1's
    `vps-inspection.md` baseline verbatim.

## Task 5 — GitHub Actions secrets (placeholders only)

**Done.** Ran `gh secret set <NAME> --repo hoak57uet/cupidus --body
PLACEHOLDER_SET_REAL_VALUE` for all 7 required names (confirmed target repo
first with `gh auth status` / `gh repo view hoak57uet/cupidus` — private repo,
matches the `origin` remote given in the handoff). `gh secret list --repo
hoak57uet/cupidus` confirms all 7 present:
`GHCR_PULL_TOKEN`, `VPS_DEPLOY_PATH`, `VPS_SSH_HOST`, `VPS_SSH_KNOWN_HOSTS`,
`VPS_SSH_PORT`, `VPS_SSH_PRIVATE_KEY`, `VPS_SSH_USER` — all created
2026-08-21T02:57Z. No real value was read, echoed, or set for any of them.

**AC4 reporting obligation — exact required secret name list for the user to
populate with real values:**
`VPS_SSH_HOST`, `VPS_SSH_USER`, `VPS_SSH_PORT`, `VPS_SSH_PRIVATE_KEY`,
`VPS_SSH_KNOWN_HOSTS`, `VPS_DEPLOY_PATH`, `GHCR_PULL_TOKEN`.

## Authorization

User explicitly authorized live production actions via a direct
`AskUserQuestion` prompt relayed by Scrum Master/team-lead: *"Yes, proceed
with both"* (STORY-002 live cutover/rollback proof and STORY-001's
Caddy+Cloudflare DNS change together). Recorded in
`data/runtime/parallel-runs/RUN-...-devops.json` as `user_authorization`.
Resumed tasks 2/7/8/9/10 on that basis.

## Task 2 — OID-1 execution (dedicated deploy key minted and installed)

Executed against the live VPS. Evidence recorded here is **metadata only** —
the private key bytes were never printed, echoed, or committed to any file
in this repository.

- Generated a fresh `ed25519` keypair in scratch space (never inside the
  repo/worktree): comment `github-actions-deploy-cupidus-backend`,
  fingerprint `SHA256:96TPSSd2Vguqnnb8xS7xfmHorj2H0SUH0JhshptDlKo`.
- Installed a command-restriction wrapper on the VPS at
  `/root/.ssh/deploy-wrapper.sh` (mode 700, owner root:root) that only
  `eval`s `SSH_ORIGINAL_COMMAND` when it is prefixed with
  `cd /var/www/backend && `; anything else prints
  `deploy-wrapper: command not permitted for this key` and exits 1.
- Appended a constrained `authorized_keys` entry for the new public key:
  `command="/root/.ssh/deploy-wrapper.sh",no-port-forwarding,no-agent-forwarding,no-pty ssh-ed25519 AAAA...DRnS github-actions-deploy-cupidus-backend`.
  The two pre-existing personal keys in `authorized_keys` were left
  untouched (file re-confirmed at exactly 2 original lines + this 1 new
  line, mode 600).
- **Bug found and fixed during install**: a first attempt built the
  `command=` line via nested shell variable interpolation inside the SSH
  command string, which stripped the required quotes around the `command=`
  value. An unquoted `command=` option in OpenSSH's `authorized_keys` grammar
  causes sshd to silently reject/skip that entire key line — this produced
  total `Permission denied (publickey,password)` for the new key on every
  command, allowed or not (confirmed via `ssh -vvv`; ruled out a key
  mismatch by comparing `ssh-keygen -lf` fingerprints of the local pubkey
  and the VPS's authorized_keys line, which matched exactly). Fixed by
  writing the correctly-quoted line to a local file and transferring it via
  `scp` + append, avoiding nested-shell-quoting entirely.
- **Verification (post-fix):**
  - `ssh -i <key> root@84.247.140.178 "cd /var/www/backend && pwd"` →
    `/var/www/backend`, exit 0 (allowed command succeeds).
  - `ssh -i <key> root@84.247.140.178 "whoami"` →
    `deploy-wrapper: command not permitted for this key`, exit 1 (everything
    outside the allowed prefix is rejected).
- The real private key was stored as the `VPS_SSH_PRIVATE_KEY` GitHub
  Actions secret via `gh secret set VPS_SSH_PRIVATE_KEY --repo
  hoak57uet/cupidus < id_deploy` (stdin redirect, never echoed to any tool
  output), then the local private-key file was securely deleted
  (`shred -u`) immediately after. Only the public key, comment, and
  fingerprint above are retained anywhere in this repo.

## Task 5 (continued) — remaining secrets set to real values

Set to real, non-secret operational values (safe to record here verbatim):
`VPS_SSH_HOST=84.247.140.178`, `VPS_SSH_USER=root`, `VPS_SSH_PORT=22`,
`VPS_DEPLOY_PATH=/var/www/backend`, `VPS_SSH_KNOWN_HOSTS=` the VPS's real
`ssh-ed25519` host key obtained via a read-only
`ssh-keyscan -t ed25519 -p 22 84.247.140.178` (host public key, not secret).
`VPS_SSH_PRIVATE_KEY` set per Task 2 above (real value, never recorded here).

`GHCR_PULL_TOKEN` is the **one remaining placeholder** — see "Blocker"
section below; it could not be provisioned with a real value.

## Task 7 — `docker-compose.prod.yml` delivered to the VPS

Copied via `scp` to a staged filename (`docker-compose.prod.yml.new`), then
renamed into place with a single `mv` on the VPS (atomic swap, no
partial-file window). Verified with `stat` (not `ls`, to satisfy this
session's read-tooling guard) that:
- `docker-compose.prod.yml` now exists at
  `/var/www/backend/docker-compose.prod.yml` (mtime = time of this
  delivery).
- `docker-compose.yml`, `.env`, `service-account.json` mtimes are
  **unchanged** from before this session (original `Mar 6` timestamps) —
  confirms none of the pre-existing VPS files were touched.
- `docker compose -f docker-compose.prod.yml config --quiet` run **on the
  VPS itself** (real `.env`, real working directory, placeholder
  `BACKEND_IMAGE` value only) exits 0 — `COMPOSE_VALID_ON_VPS`.

## Blocker — Tasks 8/9 cannot run a legitimate green-run observation yet

**Typed blocker: `SECRETS_UNPROVISIONED` (single secret: `GHCR_PULL_TOKEN`).**

The OID-3 decision above (private GHCR package + `GHCR_PULL_TOKEN`) requires
a real GitHub Personal Access Token scoped `read:packages` so the VPS can
`docker login ghcr.io` and pull the private image. I cannot mint this
programmatically:
- `gh auth status` shows my authenticated token's scopes as `gist,
  read:org, repo, workflow` — no `packages` scope.
- `gh auth refresh -s read:packages` (or minting a new fine-grained PAT)
  requires an interactive OAuth device-flow / browser action on
  github.com that only a human can complete; there is no non-interactive
  path to a real value for this one secret.

**Why I did not run Task 8/9 anyway:** merging to `main` right now would
trigger a real production deploy whose `deploy-and-verify` job is certain
to fail at the image-pull step (private package, placeholder pull token) —
that is not a legitimate "observe the first green run" per Task 8, it is a
predictable red run against production. Task 9's negative-rollback proof
specifically depends on the *prior* deploy having been a real, verified
green baseline to roll back to, so it cannot be meaningfully attempted
before Task 8 succeeds.

**Recommended resolution (needs exactly one human/browser action, not
mine to perform):** I verified `backend/Dockerfile` only copies the built
`/dist` output (plus `package*.json`/`node_modules`) into the final image
stage — `.env` and `service-account.json` are never baked into the pushed
image. Given that, flipping OID-3 to a **public** GHCR package is a
low-risk pivot that permanently removes the need for any pull-side
credential (public packages pull with no auth). This requires one of:
(a) the user/team-lead sets the `cupidus-backend` GHCR package visibility
to public in the GitHub UI after the first image push, or (b) the
user/team-lead creates a real `read:packages`-scoped PAT and it gets set
as `GHCR_PULL_TOKEN` via `gh secret set` (I can perform the `gh secret
set` step non-interactively once a real token value is provided through a
secret-safe channel — I should not receive the raw token value pasted into
chat/transcript).

Tasks 8, 9, 10 remain **not started** pending this one decision/action.

## Scrum Master follow-up — backend host port fix (before cutover resumes)

Scrum Master relayed a finding from Alan-Techlead-3's STORY-001
architecture revision: the original `backend/docker-compose.prod.yml`
published `"3000:3000"` (all interfaces), which both conflicts with the
shared VPS's routing for the unrelated live `vocabik` site and is an
unnecessary plaintext-internet exposure of the backend port.

Performed a **read-only** `ss -ltnp` inspection over SSH (no Docker/VPS
state change — same read-only category P1 already used, not a write/deploy
action) to pick a real free port rather than guessing:

```
127.0.0.1:2019   caddy
0.0.0.0:22       sshd
127.0.0.1:5037   adb
0.0.0.0:8000     docker-proxy
0.0.0.0:20128    docker-proxy
127.0.0.1:3000   docker-proxy   <- vocabik (Caddy: vocabik.com -> localhost:3000)
127.0.0.1:3001   docker-proxy   <- vocabik (Caddy: api.vocabik.com -> localhost:3001)
*:443, *:80      caddy
*:8080           node /opt/andro...
127.0.0.1:18789/18791/18792  openclaw-gateway
```

`3000`/`3001` are already loopback-bound by `vocabik`'s own containers —
`cupid-backend` cannot reuse either, even loopback-only. **Chosen port:
`3010`** (free at inspection time, 2026-08-21).

Fixed `backend/docker-compose.prod.yml`: `ports: - "127.0.0.1:3010:3000"`
(loopback-only, not `0.0.0.0`). Updated `vps-deploy.sh`'s `BACKEND_PORT`
default to `3010` to match the health gate target. Re-ran
`docker compose -f docker-compose.prod.yml config` — exits 0.

**Reporting to Scrum Master per the follow-up instruction: the chosen
backend host port is `3010` (loopback-only, `127.0.0.1:3010`), so
STORY-001's Caddy site block for `api.cupidus.app` should
`reverse_proxy 127.0.0.1:3010`.**

## Blocker resolution — `GHCR_PULL_TOKEN` provisioned

The user set a real `GHCR_PULL_TOKEN` value (classic PAT, `read:packages`
scope) via `gh secret set GHCR_PULL_TOKEN --repo hoak57uet/cupidus` in their
own terminal (a human/browser action outside this session, as recommended in
the "Blocker" section above). The `SECRETS_UNPROVISIONED` blocker is now
**RESOLVED**.

Re-verified in this continuation session:
- `gh secret list --repo hoak57uet/cupidus` — all 7 required secrets present:
  `GHCR_PULL_TOKEN` (updated 2026-08-21T03:51:22Z, after the original
  placeholder timestamp of 02:57Z — confirms a real value was set),
  `VPS_DEPLOY_PATH`, `VPS_SSH_HOST`, `VPS_SSH_KNOWN_HOSTS`, `VPS_SSH_PORT`,
  `VPS_SSH_PRIVATE_KEY`, `VPS_SSH_USER`.
- `docker compose -f backend/docker-compose.prod.yml config` (worktree,
  placeholder env values, no VPS access) — exits 0, unchanged from Task 4/7
  validation. Tasks 1-7 remain valid; no worktree file changes were needed.

## Requirement-integration review rework — F1-F4 (2026-08-21)

Reviewer Iris-QC's integration review of the previously merged diff
(`Outcome: PATCH_REQUIRED`) found F1/F2 blocking and F3/F4 as AC6
safety-net gaps. Fixed all four directly on this story branch.

### F1 (BLOCKING) — forced-command prefix violations

Every `ssh_exec` call had to send the exact literal, unquoted prefix
`cd /var/www/backend && ` to match `/root/.ssh/deploy-wrapper.sh`'s
prefix check (see Task 2 above — the wrapper only `eval`s
`SSH_ORIGINAL_COMMAND` when it starts with that exact string; anything
else, including a quoted `cd '...' && ` prefix, is rejected outright).
Re-audited **every** `ssh_exec`/`ssh_exec_stdin` call in
`vps-deploy.sh` line by line, not just the ones the review named:

- `PRIOR_IMAGE` (`docker inspect`): had no `cd` prefix at all — added
  `cd ${VPS_DEPLOY_PATH} && ` (review-named).
- Pre-deploy dump, dump-size check, pull, both AC7 `mv` commands,
  promote, rollback, and post-cutover row-count check: all sent
  `cd '${VPS_DEPLOY_PATH}' && ` (single-quoted) — switched every one to
  unquoted `cd ${VPS_DEPLOY_PATH} && ` (review-named).
- **Also found during this re-audit, not named in the review**: the
  health-gate `curl` poll had **no `cd` prefix at all**, identical bug
  class to `PRIOR_IMAGE`. Left unfixed, this would have made the health
  gate reject every single poll attempt post-fix (wrapper rejects the
  bare `curl ...` command), forcing every deploy to hit the 20-retry
  timeout and roll back even when the app came up healthy. Fixed with
  the same `cd ${VPS_DEPLOY_PATH} && ` prefix.

**Verification status: NOT live-re-verified against the real VPS in
this session** (no SSH key material or live VPS access available to
this dispatch). The fix follows the wrapper contract documented and
already field-verified in Task 2 above (`cd /var/www/backend && pwd`
succeeded; bare `whoami` was rejected) — an unquoted `cd
${VPS_DEPLOY_PATH} && ...` command expands to byte-for-byte the same
allowed prefix. Per the stop rule in this dispatch's handoff, recording
this as a pending live re-verification rather than blocking; Scrum
Master should route one live-verification step (e.g. `workflow_dispatch`
or a push observed end-to-end) before treating deploy-and-verify as
proven green.

### F2 (BLOCKING) — GHCR_PULL_TOKEN never consumed

Added a `docker login ghcr.io` step to `vps-deploy.sh`, run over SSH
immediately before `docker compose pull`, authenticated with
`GHCR_PULL_TOKEN` piped on stdin (`--password-stdin`) via a new
`ssh_exec_stdin` helper so the token never appears in the command string
or script output. Username comes from a new non-secret workflow env var
`GHCR_PULL_USER` (`${{ github.repository_owner }}` in
`deploy-backend.yml`) — no new required secret. Chose "add VPS login"
over "flip GHCR package public" because OID-3 already decided private is
the correct default; full rationale recorded in
`data/requirements/REQ-005_production_domain_and_cicd_standardization/deployment/configuration-guide.md`.
Local validation only (no VPS/network access): reviewed the resulting
`ssh_exec_stdin` command string by hand against the same wrapper-prefix
rule as F1 — matches. Live re-verification pending, same caveat as F1.

### F3 (MEDIUM, AC6 safety net) — dump/check ran against the wrong compose file

The pre-deploy dump (`docker compose up -d postgres`,
`docker compose exec ... pg_dumpall`) and the post-cutover row-count
check (`docker compose exec ... psql`) were bare `docker compose`
invocations, which resolve to the legacy compose file that publishes
`5432`/`6379` on all interfaces (`vps-inspection.md:18`), transiently
exposing production Postgres to the internet during backup. Added
`-f docker-compose.prod.yml` to all three invocations.

### F4 (MEDIUM, AC6 safety net) — POSTGRES_USER expanded in the wrong shell

`${POSTGRES_USER:-postgres}` (and `${POSTGRES_DB:-cupid}`) expanded in
the VPS login shell, not inside the container and not from
`/var/www/backend/.env` where the real values live
(`vps-inspection.md:21`) — a non-default value would silently fall back
to `postgres`/`cupid` and fail without surfacing an error, leaving AC6's
~48M-row safety net untested. Fixed both the pre-deploy dump and the
post-cutover row-count check to expand `$POSTGRES_USER`/`$POSTGRES_DB`
inside the container via `docker compose ... exec -T postgres sh -c
'... "$POSTGRES_USER" ...'` (double-quoted inside a single-quoted `sh -c`
argument, so the outer `eval` on the VPS passes the string through
literally and only the container's own shell expands it). The review
named only the dump call; applied the identical fix to the post-cutover
check too since it has the exact same bug (bare `${POSTGRES_USER:-postgres}`
expanding in the wrong shell) and would otherwise still silently degrade
AC6 verification after the dump-side fix.

Not addressed in this dispatch, per the handoff's explicit scope: F5
(bind-mount corruption risk, only reachable via Task 9's
`workflow_dispatch`-only AC7 simulation), F6 (legacy
`backend/.github/workflows/deploy.yml` inert-path documentation), F7
(evidence-doc cross-file inconsistencies).

## Status

- Status: MERGE-READY CHECKPOINT — Tasks 1-7 complete and re-confirmed valid
  (OIDs decided, workflow/script authored and validated, all 7 secrets now
  set to real values including `GHCR_PULL_TOKEN`, dedicated constrained
  deploy key minted and verified working, host-port conflict fixed,
  `docker-compose.prod.yml` delivered to the VPS and validated in place).
  Tasks 8 (ordered cutover — merge to `main` to trigger the real deploy), 9
  (AC7 negative rollback proof), 10 (AC6 re-verification) remain **not
  started**. Task 8 requires an actual push to `main`, which is
  Scrum-Master-owned git-control-plane work, not devops-performed even
  though this run's MergeTarget is normally the REQ integration branch.
- Last updated: 2026-08-21
