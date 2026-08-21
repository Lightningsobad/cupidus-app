# REQ-005 Requirement Integration Review — FULL (STORY-001 + STORY-002)

Outcome: DEFERRED_ONLY

- Reviewer: Iris-QC
- Mode: `requirement-integration-review` (full requirement, both stories as shipped)
- Scope gate: `integration-review/scope-gate.md`
- Branch: `codex/REQ-005_production_domain_and_cicd_standardization-integration`
- Diff reviewed: `8ae3d376065781bd20ee20078f88afb86406dcba..HEAD` — 16 files, +2409 / -7
- Date: 2026-08-21
- Supersedes: the STORY-002-only integration review (`Outcome: DEFERRED_ONLY`)
  that previously occupied this path. Its F1-F4 verdicts and F5/F6/F7/N1-N3
  findings are carried forward below by reference, not re-litigated.

## What this diff actually contains

STORY-002 landed on `main` **before** this branch's fork point (merge `bf6427b`,
then `8ae3d37`), so its implementation is not in `8ae3d37..HEAD`. Every path in
this diff is STORY-001 or requirement-level. STORY-002 is therefore reviewed
here as already-merged base state plus its own prior review, and the
requirement-level question — do the two stories hold together as shipped — is
answered against the combined tree, not against the diff alone.

## Integration Build & Runtime

- Build: PASS — GitHub Actions `Deploy Backend` run
  [32457256470](https://github.com/hoak57uet/cupidus/actions/runs/32457256470)
  on `main` @ `f87a084`, both jobs green: `build-and-push` = success (includes
  `docker compose -f backend/docker-compose.prod.yml config` validation and the
  GHCR image build/push), `deploy-and-verify` = success. Verified first-hand
  via `gh run view 32457256470`, not taken from evidence prose.
- Runtime/Smoke: PASS — `curl -sS -m 25 -D - -o /dev/null https://api.cupidus.app/`
  executed by this reviewer at 2026-08-21T07:43:15Z returned `HTTP/2 200` with
  `via: 1.1 Caddy`, `x-powered-by: Express`, `server: cloudflare`,
  `cf-ray: a2e80175c9092104-HKG` — the full Cloudflare edge -> origin Caddy ->
  backend Express chain, live. Co-tenant regression gate in the same pass:
  `https://vocabik.com` = `200` (unchanged). `dig +short api.cupidus.app A` =
  `172.67.141.59`, `104.21.62.250` (Cloudflare anycast).

This is the requirement's real end-to-end proof: the CI/CD pipeline built and
deployed the backend, and the hostname serves it over HTTPS. The two stories
are verified together by a single observation rather than separately.

## Cross-story contract: the backend port

The one value both stories share is the backend's published host port. It is
consistent at every layer:

| Layer | Value | Source |
|---|---|---|
| Cloudflare edge -> origin | `api.cupidus.app` -> VPS `:443` | `configuration-guide.md` §5 |
| Host Caddy site block | `reverse_proxy 127.0.0.1:3010` | `deployment/caddy/api.cupidus.app.caddy:11` |
| Compose publish | `"127.0.0.1:3010:3000"` | `backend/docker-compose.prod.yml:72` |
| Pipeline health gate | `BACKEND_PORT="${BACKEND_PORT:-3010}"` | `.github/workflows/scripts/vps-deploy.sh:109`, used at `:112` |
| Combined guide | `3010`, "Not `3000`" | `configuration-guide.md` §"Backend host port" and §2 |

`3000` is correctly and consistently avoided across both stories (held by the
unrelated live `vocabik` tenant on this shared host), and the binding is
loopback-only at every layer — the backend is never published on `0.0.0.0`.
Shared-infrastructure safety (rule 12h): PASS. `postgres`/`redis` publish no
host port at all.

## Configuration guide (rule 12a)

`data/requirements/REQ-005_production_domain_and_cicd_standardization/deployment/configuration-guide.md`
— read in full (301 lines). Well-formed, both story sections present, complete,
correctly formatted, not duplicated and not truncated:

- STORY-002 section, lines 3-103: GitHub Actions secrets table (7 secrets),
  container registry dependency + F2 rationale, VPS runtime file layout,
  backend host port, deploy trigger and rollback behavior, OID-1/2/3 decisions.
- STORY-001 section, lines 105-301: §1 TLS terminator (with the in-repo Caddy
  block and a re-apply-after-drift runbook), §2 backend port cross-story
  contract, §3 certificate lifecycle + renewal-failure runbook, §4 zone SSL
  mode, §5 DNS record sequence, §6 legacy hostname disposition, §7 open
  blocker, §8 secret handling.

Git confirms the merge was purely additive to this file (+197 / -0 across
`8ae3d37..HEAD`), so no STORY-002 content was overwritten. Heading levels are
consistent (`##` for both story sections, `###` for STORY-001 subsections) and
the two sections cross-reference each other correctly on the port contract
rather than contradicting.

Residual staleness in this file is heading-level only and already tracked as
STORY-001 D5 — see Deferred below.

## Business Scope outcomes

| Outcome | Verdict | Proof |
|---|---|---|
| (a) `api.cupidus.app` serves the backend over HTTPS | MET | Live `HTTP/2 200` above, publicly trusted Let's Encrypt origin cert, DNS proxied through Cloudflare, all four mutations made through `scripts/cloudflare/*.sh` with no dashboard step |
| (b) VPS backend deploys standardized onto GitHub Actions CI/CD | MET | `.github/workflows/deploy-backend.yml` triggers on `push` to `main` scoped to `backend/**` + the workflow and deploy script, plus `workflow_dispatch`; `concurrency: deploy-backend-production, cancel-in-progress: false`; `deploy-and-verify` gated on `needs: build-and-push`; one real green end-to-end run observed (32457256470) |

Both requirement-level Technical Constraints hold: no SSH key was rotated
(a dedicated least-privilege key was minted, OID-1), DNS was scripted rather
than clicked, and no real credential discovered on the VPS was reused —
`git diff -G'PRIVATE KEY|ghp_|github_pat_|BEGIN CERTIFICATE|...' 8ae3d37..HEAD`
returns no file, confirming no secret-shaped material entered this diff.

## Touched risk surfaces and critical gates

| Surface | Critical gate | Result |
|---|---|---|
| Runtime/configuration | Integration build + live runtime smoke | PASS (above) |
| Operational command (`vps-deploy.sh`) | Forced-command prefix + fail-safe behavior | PASS — verified line-by-line in the prior STORY-002 review (F1-F4 fixed, stub-`ssh` dry-run); confirmed unchanged by this diff |
| External integration (Cloudflare, GHCR) | Scripted, idempotent, fail-closed | PASS — 3 Cloudflare scripts enumerate-then-refuse on conflict; GHCR login on stdin only |
| Security/auth (SSH, TLS, secrets) | No secret material; pinned host key; publicly trusted cert | PASS |
| Shared multi-tenant VPS | Co-tenant non-regression | PASS — `vocabik.com` `200` re-verified this pass |
| UI | 12e1/12e2/12g1/12g2 | NOT APPLICABLE — both stories record `UX-Spec: WAIVED`, no operator-facing UI surface |

Story-level runtime smoke (rule 12g) is present and passing for STORY-001 at
`STORY-001/coding-plan/test-results.md:487-515` (`## Story Runtime Startup
Smoke`, `Result: PASS`), correctly scoped to the impacted Caddy edge surface.

## Deferred findings (all non-blocking, carried forward)

Re-checked against the shipped tree — each is still accurately described as
deferred, with two status corrections noted.

**From STORY-001** (`STORY-001/review/review-report.md`):

- D1 — `CLOUDFLARE_TOKEN_MISSING_SSL_PERMISSION`. Still accurate. The token
  lacks the "SSL and Certificates" group, so the exact zone SSL-mode *name*
  cannot be read or written. Costs a recorded value, not a security property:
  the live `200` with a genuine Let's Encrypt origin cert proves the path works.
  Parent item for D2/D4/D5.
- D2 — `scripts/cloudflare/set-zone-ssl-full-strict.sh` retained while the
  chosen target is Flexible. Still accurate; file still tracked, and
  `configuration-guide.md` §5 step 4 marks it struck-through
  "Superseded, do not run", which removes the operator hazard.
- D3 — `www.vocabik.com` ACME failure on the shared host. Pre-existing
  co-tenant issue since 2026-06, out of scope, not worsened.
- D4 — `STORY-001/coding-plan/test-results.md` header status line stale
  relative to its own §12. Still accurate, intra-document only.
- D5 — `configuration-guide.md` §7 still titled "Open blocker". Confirmed still
  present at line 261; the body correctly describes item 1 as resolved and
  item 2 as narrowed/non-blocking, so the heading is the only stale element.

**From STORY-002** (prior integration review, superseded above):

- F5 — the AC7 simulation path can permanently break production
  (`vps-deploy.sh:92-99`, Compose short-syntax bind-mount auto-creates a
  directory). Still accurate and still MEDIUM. Unreachable from the `push`
  trigger (opt-in `workflow_dispatch` input defaulting to `false`). **Must be
  fixed before Task 9 is ever dispatched.**
- F6 — `backend/.github/workflows/deploy.yml` still tracked, still undocumented.
  **Status correction:** its precondition has now been met. The guide (line
  86-88) promises the legacy trigger is disabled "only after one green Actions
  run is verified serving traffic" — that run now exists (32457256470) and the
  site is serving. The cleanup is therefore due rather than waiting. Still
  non-blocking: the file is inert because it sits at `backend/.github/workflows/`
  rather than the repo root, so GitHub never schedules it — there is no
  double-deploy risk. Carry into REQ-006/REQ-007 or a follow-up.
- F7 — evidence inconsistencies (`GHCR_PULL_TOKEN` placeholder-vs-real
  contradiction between `test-results.md` and `cutover-evidence.md`; the
  configuration guide's line 5-7 "all values below are placeholders" header vs.
  the 6-of-7 really-populated state). Still accurate. AC4's *intent* is
  satisfied; the guide misdescribes the state.
- N1 — `ssh_exec_stdin` is a byte-identical copy of `ssh_exec` with a
  misleading comment. Redundant abstraction, not a defect.
- N2 — no `docker logout` after the GHCR pull; the token persists in the VPS
  user's `~/.docker/config.json` on a host shared with the `vocabik` tenant.
- N3 — duplicate `cutover-evidence.md` (`STORY-002/cutover-evidence.md`, a
  13-line pointer) committed only to satisfy a mismatched parallel-run
  `OutputPath`. Confirmed still present. Scrum Master should fix the handoff's
  `OutputPath`/`WriteScope` and remove the pointer.
- Task 9 (AC7 negative rollback proof) and Task 10 (AC6 re-verification) remain
  not done, as accepted. **Status correction: Task 8 is now satisfied** — the
  first green run has been observed and the deployed backend is serving
  traffic, which was the prior review's named pre-DONE condition.

**New at requirement level (this review):**

- R1 — requirement/story state files are stale relative to the shipped reality,
  Scrum-Master-owned. In this branch, `req_master.md` still lists both stories
  `Status: PENDING` in its User Stories table (STORY-001's own
  `story_master.md` reads `Status: DONE`), records
  `Configuration Documentation / Status: NOT_REQUIRED` with an empty
  `Last Updated` despite a 301-line delivered guide, and records
  `Development Environment: NOT_DEPLOYED` / `Production: REQUESTED` although
  production is live. `STORY-002/story_master.md` still reads `Status: PENDING`
  with `[ ] Implementation` and `[ ] Review` unchecked (this is F7's third
  bullet, still unreconciled). None of this affects delivered behavior, and
  rule 17 puts it on Scrum Master, but it must be reconciled before `DONE`.
- R2 — this branch does not contain `main`. STORY-002 was landed to `main` as
  `f87a084` (and `origin/main` sits there; local `main` is at `9cb8c80`), and
  neither commit is an ancestor of this branch's HEAD. The branch content is
  still a strict superset of the code that was deployed, so this is a merge
  mechanic, not a content gap. Informational for the land step.
- R3 — the green run was `workflow_dispatch`, not `push`. The `push`-to-`main`
  trigger is wired correctly and runs the identical two-job graph, but has not
  itself fired live. Landing *this* branch will not exercise it either: the
  diff touches none of the trigger paths (`backend/**`,
  `.github/workflows/deploy-backend.yml`,
  `.github/workflows/scripts/vps-deploy.sh`) — verified with
  `git diff --name-only`. That is the correct and safe outcome here (nothing
  runtime-affecting changed), but it means the push trigger's first live proof
  moves to the next backend change.

## Traceability

- Merged stories: STORY-001 (`review/review-report.md`, `Outcome:
  DEFERRED_ONLY`), STORY-002 (prior integration review, `Outcome:
  DEFERRED_ONLY`, merged as `bf6427b`).
- Requirement: `req_master.md` Business Scope outcomes 1 and 2, Technical
  Constraints (VPS/DNS/CI-CD/secrets), `requirements/requirements.md:145`
  `INTEGRATION_VERIFICATION_REQUIRED: NO`.
- Configuration guide: verified in full, rule 12a PASS.
- Cross-story contract: backend port `3010`, verified across four layers.
- Integration build + runtime: verified first-hand this pass (see above).
- Downstream: REQ-006 (apex `cupidus.app`) and REQ-007 (mobile pointed at
  `api.cupidus.app`) are unblocked — the host is live and the Actions deploy
  pattern exists for them to copy.

## State recommendation

- Requirement status: `DONE` — eligible, after the R1 reconciliation below.
- Before marking `DONE`, Scrum Master should: reconcile
  `STORY-002/story_master.md` to `DONE` with both boxes checked, update the
  `req_master.md` User Stories table to `DONE`/`DONE`, set
  `Configuration Documentation / Status` to reflect the delivered guide with a
  `Last Updated` date, and update `Deployment Status` to record production as
  deployed.
- Before Task 9 is ever dispatched: fix F5.
- Carry D1-D5, F5-F7, N1-N3, and R1-R3 forward as non-blocking follow-ups.

REVIEW_COMPLETE: YES
