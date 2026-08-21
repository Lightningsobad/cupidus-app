# Requirement Master: REQ-005 Production domain & CI/CD standardization for backend API
Status: DONE
Stories-Merged: YES — STORY-001 (`993968b`, merged `b17b8e6`) and STORY-002
both merged into `codex/REQ-005_production_domain_and_cicd_standardization-integration`.
STORY-002 landed first (mid-requirement, per the original waiver below);
STORY-001 merged after resolving an additive add/add conflict in
`deployment/configuration-guide.md` (both stories' independent sections kept,
resolved by Scrum Master directly in the integration worktree). Both stories
are `DONE`.

Requirement-integration review (full, both stories together):
`integration-review/review-report.md`, `Outcome: DEFERRED_ONLY`
(2026-08-21). Live integration build + runtime re-verified first-hand by the
reviewer: GitHub Actions run
https://github.com/hoak57uet/cupidus/actions/runs/32457256470 green
end-to-end, `https://api.cupidus.app/` returns `HTTP/2 200` through
Cloudflare edge -> origin Caddy -> backend Express. Both Business Scope
outcomes MET. Non-blocking deferred follow-ups carried forward: STORY-001
D1-D5, STORY-002 F5-F7/N1-N3, requirement-level R1-R3 (this reconciliation
closes R1). F5 (AC7 simulation bind-mount risk) must be fixed before Task 9
(AC7 rollback proof) is ever dispatched.

Original waiver note (historical): STORY-002's coding plan required an early
landing of its GitHub Actions workflow onto `main` (Task 8) to trigger and
verify the real production deploy/rollback (AC6/AC7) before its story review —
this could not wait for STORY-001.

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: DEPLOYED — STORY-002's CI/CD pipeline (`.github/workflows/deploy-backend.yml`) landed on `main` (f87a084) and pushed to `origin/main` per direct user authorization. The `push` trigger never fired (repo-wide `total_count: 0`, undiagnosed CI-registration oddity); per a follow-up explicit user authorization, Scrum Master manually dispatched the workflow (`workflow_dispatch`) instead. Run https://github.com/hoak57uet/cupidus/actions/runs/32457256470 succeeded end-to-end (build-and-push, health gate, post-cutover row-count check all green); `https://api.cupidus.app/` now returns HTTP 200 from the live backend, served through STORY-001's Cloudflare edge + host-Caddy routing. STORY-001 and STORY-002 both DONE. Task 9 (AC7 rollback proof) still requires fixing F5 first; Task 10 (AC6 full re-verification) still outstanding — both deferred, non-blocking follow-ups.

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: DELIVERED — 301-line combined guide covering both stories (GitHub Actions secrets/CI-CD for STORY-002, api.cupidus.app hostname/TLS/Cloudflare edge for STORY-001), verified well-formed and internally consistent by the requirement-integration review.
- Pending User Setup: NONE
- Last Updated: 2026-08-21

## Business Scope

The user owns domain `cupidus.app`, already registered and live on
Cloudflare, with Cloudflare CLI (`cloudflare-cli` / `wrangler`, whichever the
account uses) already installed on the local machine. GitHub CLI (`gh`) is
also installed locally.

Two outcomes are required:

1. Create/point subdomain `api.cupidus.app` at this project's backend API,
   deployed on the existing VPS `root@84.247.140.178` (SSH public key for
   this machine and for GitHub Actions is already present on that VPS).
2. The backend has been deployed to that VPS before, by an undocumented path
   the user does not remember. Investigate the current deployment mechanism
   on the VPS (systemd unit, PM2, docker compose, manual script, cron, etc.)
   and standardize it onto a GitHub Actions CI/CD pipeline: push/merge to the
   production branch triggers an automated build + deploy to the VPS behind
   `api.cupidus.app`.

This is a direct user instruction to deploy to a production VPS target
(`production VPS` per `workflows/deploy.md`), not an inferred deployment.

## Technical Constraints

- VPS: `ssh root@84.247.140.178`. SSH keys for this machine and for GitHub
  Actions are already authorized on the VPS — do not generate or rotate SSH
  keys unless the existing ones are confirmed broken.
- DNS: Cloudflare-managed zone for `cupidus.app`, Cloudflare CLI available
  locally for DNS record changes. Prefer scripting the DNS record creation
  through the Cloudflare CLI/API rather than manual dashboard steps, so the
  step is repeatable and auditable.
- CI/CD: GitHub Actions is the target standard. Any prior undocumented
  deploy path on the VPS must be identified first (read-only investigation),
  then replaced or wrapped by the Actions workflow — do not leave two
  competing deploy paths live.
- Secrets: GitHub CLI (`gh`) is installed locally. Where the pipeline needs a
  credential (VPS deploy key material if a dedicated deploy key is created,
  Cloudflare API token, registry credentials, etc.), create a placeholder
  GitHub Actions secret (`gh secret set <NAME> --body <placeholder>`) rather
  than sourcing or guessing a real value, and report the exact list of
  required secret names back to the user so they can populate/rotate the
  real values themselves. Never invent or reuse a real credential value found
  on the VPS without explicit user confirmation.
- This is the foundational/dependency requirement for REQ-006 (web frontend
  deploy to the `cupidus.app` apex) and REQ-007 (mobile app pointed at
  `api.cupidus.app` in production builds). Those requirements assume
  `api.cupidus.app` is live and the GitHub Actions deploy pipeline pattern
  exists before they can complete their own deploy/build-pointing work.

## Open Questions

- Exact current deploy mechanism on the VPS is unknown to the user; DevOps
  must investigate on the VPS directly (read-only) before proposing the
  standardized pipeline, rather than assuming a mechanism.
- Whether a dedicated least-privilege deploy SSH key should be minted for
  GitHub Actions (recommended) vs. reusing the already-authorized personal
  key is a DevOps security judgment call; record the decision and rationale
  when made.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | Point api.cupidus.app at the production backend API | standard | DONE | `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-001/story_master.md` |
| STORY-002 | Standardize VPS backend deploys onto GitHub Actions CI/CD | complex | DONE | `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-002/story_master.md` |
