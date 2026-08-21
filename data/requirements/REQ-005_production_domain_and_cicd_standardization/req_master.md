# Requirement Master: REQ-005 Production domain & CI/CD standardization for backend API
Status: IN_PROGRESS
Stories-Merged: WAIVED — STORY-001 is still IN_PROGRESS (blocked on
CLOUDFLARE_CREDENTIAL_UNAVAILABLE, unrelated DNS/edge scope; user is
providing a scoped Cloudflare API token). STORY-002's coding plan requires
an early landing of its GitHub Actions workflow onto `main` (Task 8) to
trigger and verify the real production deploy/rollback (AC6/AC7) before the
story can be reviewed — this cannot wait for STORY-001. Requirement is NOT
DONE; only STORY-002's mid-requirement integration landing is intentionally
ahead of STORY-001. A fresh integration branch will be (re)created via
`ensure-integration`/`start` when STORY-001 is ready to merge.

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: REQUESTED (direct user instruction, see Business Scope)

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

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
| STORY-001 | Point api.cupidus.app at the production backend API | standard | PENDING | `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-001/story_master.md` |
| STORY-002 | Standardize VPS backend deploys onto GitHub Actions CI/CD | complex | IN_PROGRESS | `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-002/story_master.md` |
