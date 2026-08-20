# Requirement Breakdown: REQ-005 Production domain & CI/CD standardization for backend API

## Source Artifacts

- Requirement master: `data/requirements/REQ-005_production_domain_and_cicd_standardization/req_master.md`
- Additional input files: `data/intake/bootstrap/conflicts_open_questions.md`
- Existing related requirement artifacts: none (REQ-005 is the foundational
  dependency for REQ-006 and REQ-007; those requirements are not read here)

## Context Summary

- Request summary: Point subdomain `api.cupidus.app` (Cloudflare-managed zone
  the user owns) at this project's backend API on the existing VPS
  `root@84.247.140.178`, and replace whatever undocumented mechanism currently
  deploys the backend to that VPS with a GitHub Actions CI/CD pipeline
  triggered by push/merge to the production branch.
- Primary actors: API consumers of the backend (mobile app, web frontend,
  external integrators) for the domain outcome; the engineering/operations
  team for the deploy-pipeline outcome.
- Problem to solve: the backend API has no stable production hostname today,
  and the VPS deploy path is undocumented tribal knowledge with no repeatable,
  auditable trigger.
- Business outcome: a stable, TLS-reachable `api.cupidus.app` backed by a
  single, documented, automated deploy path.
- Success signal: `https://api.cupidus.app` resolves to the running backend
  API; a push/merge to the production branch produces an automated build +
  deploy to the VPS with no other live deploy path remaining.
- Notes on current project context: this is a direct user instruction to
  deploy to a production VPS target, not an inferred deployment (see
  req_master.md Business Scope). `backend/nginx/default.conf` currently sets
  `server_name api-cupid.tikup.me` and `backend/docker-compose.yml` uses fixed
  prod-style host ports — a different, older domain than `api.cupidus.app`.
  The central OQ registry records this VPS target as user-confirmed
  real/owned but explicitly not yet adopted as a live confirmed
  staging/production environment prior to this direct instruction. See Open
  Question Triage below.

## Scope Decision

### In Scope

- Creating/pointing the `api.cupidus.app` DNS record at the VPS through the
  Cloudflare CLI/API (scripted, not manual dashboard steps).
- Whatever VPS-side routing/TLS change is needed for `api.cupidus.app` to
  reach the running backend API (e.g. reverse proxy vhost, certificate).
- Read-only investigation of the VPS's current deploy mechanism (systemd,
  PM2, docker compose, manual script, cron, etc.) before designing the
  replacement.
- A GitHub Actions workflow that builds and deploys the backend to the VPS on
  push/merge to the production branch.
- Decommissioning the prior deploy mechanism once the Actions pipeline is
  live, so exactly one deploy path remains.
- Placeholder GitHub Actions secrets for anything the pipeline needs
  (`gh secret set <NAME> --body <placeholder>`), with the exact required
  secret name list reported back to the user.

### Out of Scope

- REQ-006 (web frontend deploy to the `cupidus.app` apex) and REQ-007 (mobile
  app pointed at `api.cupidus.app` in production builds) — those requirements
  consume this one's outputs but are not read or planned here.
- Rotating or generating new SSH keys, unless the existing authorized keys are
  confirmed broken during investigation.
- Sourcing, guessing, or reusing any real credential value discovered on the
  VPS without explicit user confirmation.
- Any application/business-logic change to the backend itself.

### Business Rules And Guardrails

- SSH access to the VPS (`root@84.247.140.178`) for this machine and for
  GitHub Actions is already authorized — do not generate or rotate SSH keys
  unless the existing ones are confirmed broken.
- Prefer scripting the DNS record creation through the Cloudflare CLI/API over
  manual dashboard steps, so it is repeatable and auditable.
- The current undocumented deploy path must be identified first (read-only
  investigation) before it is replaced or wrapped by the Actions workflow; do
  not leave two competing deploy paths live afterward.
- Any credential the pipeline needs must be created as a placeholder GitHub
  Actions secret rather than sourced/guessed from the VPS; the exact list of
  required secret names must be reported back to the user so they can
  populate/rotate the real values themselves.
- Whether to mint a dedicated least-privilege deploy SSH key for GitHub
  Actions versus reusing the already-authorized personal key is a DevOps
  security judgment call to be made and recorded (with rationale) during
  STORY-002 implementation.

## Open Question Triage

| OQ ID | Status | Scope Items BLOCKED | Scope Items NOT BLOCKED | Decision |
|-------|--------|---------------------|--------------------------|----------|
| Nginx VPS-target ambiguity (central registry, "Decisions Still Needed From The User") | UNRESOLVED (about legacy domain `api-cupid.tikup.me`) | Nothing at story-creation time | STORY-001 and STORY-002 creation; both stories proceed | This OQ concerns a different, older domain (`api-cupid.tikup.me`) than the one named in this requirement (`api.cupidus.app`). REQ-005's Business Scope is itself a direct user instruction naming `root@84.247.140.178` as the target VPS, which satisfies the VPS-target confirmation this OQ was raised for, for the purposes of this requirement. STORY-001 must inspect (not blindly overwrite) the existing `backend/nginx/default.conf` `server_name api-cupid.tikup.me` vhost when adding `api.cupidus.app` routing. STORY-002's read-only investigation phase must inventory this legacy config as part of "current deploy mechanism." Not a blocker to creating either story. |
| `api-cupid.tikup.me` VPS target identity (central registry, "Resolved Foundation Decisions") | RESOLVED (2026-07-29) | — | All scope | Real/owned VPS target, consistent with `root@84.247.140.178` in req_master.md. Confirms the VPS itself is a legitimate deploy target for this requirement's direct-instruction scope. |
| req_master.md "Exact current deploy mechanism unknown" | UNRESOLVED (no formal OQ id; local to REQ-005) | Nothing at story-creation time | STORY-001 and STORY-002 creation | Not a creation blocker — it is the first implementation phase of STORY-002 (read-only investigation), not a precondition for defining the story. |
| req_master.md "dedicated deploy SSH key vs. reuse" | UNRESOLVED (no formal OQ id; local to REQ-005) | Nothing at story-creation time | STORY-001 and STORY-002 creation | DevOps security judgment call to be made and recorded during STORY-002 implementation; does not block story definition. |

### OQs reviewed but not applicable to this requirement

- OQ4 (offline storage strategy): mobile client-side scope, not applicable.
- OQ5 (light theme & EN locale): design-system scope, not applicable.
- R8 (Socket.IO auth gap): backend chat-gateway security scope, not applicable.
- D1/Critical-Alerts copy conflict: notifications copy scope, not applicable.
- `backend/` separate-git-repo folding: already resolved during bootstrap, not
  applicable.

## Seed To Story Mapping

No `## Story Seeds` table is present in `req_master.md`; this requirement
carries no discovery seed table to reconcile. The story set below is derived
directly from the two outcomes stated in req_master.md's Business Scope.

### Distinct user outcomes in this requirement

1. The backend API is reachable at a stable, TLS-secured production hostname
   (`api.cupidus.app`) instead of a raw VPS IP.
2. A push/merge to the production branch produces an automated, auditable
   build + deploy to the VPS, with no other deploy path left running.

## Coverage Map

| Requirement / Need | Planned Story ID(s) | Notes |
|--------------------|----------------------|-------|
| Point `api.cupidus.app` at the backend API on the VPS | STORY-001 | DNS via Cloudflare CLI/API + VPS-side routing/TLS |
| Investigate current VPS deploy mechanism and standardize onto GitHub Actions CI/CD | STORY-002 | Read-only investigation phase, then build + cutover |

## Recommended Story Sequence

| Story ID | Title | Complexity | Depends On | Why This Order | Observable After This Story |
|----------|-------|------------|------------|-----------------|-------------------------------|
| STORY-001 | Point api.cupidus.app at the production backend API | standard | None | Matches Business Scope outcome ordering; independently deliverable since the backend already runs on the VPS via the existing (undocumented) mechanism | `https://api.cupidus.app` resolves and serves live responses from the backend API over HTTPS |
| STORY-002 | Standardize VPS backend deploys onto GitHub Actions CI/CD | complex | None | Independently deliverable: the pipeline builds/deploys to the VPS the app already runs on, regardless of which hostname currently points at it | A push/merge to the production branch triggers an automated build + deploy to the VPS, and the prior undocumented deploy path no longer exists |

Neither story requires the other's delivered behavior: STORY-001 makes the
existing (already-running) backend reachable by domain name; STORY-002
replaces how that backend gets onto the VPS in the first place. Both are
independently observable and independently valuable, so no dependency edge is
recorded between them.

## Story Index

| Story ID | Title | Brief File | Primary Scope | Key AC/OQ Anchors |
|----------|-------|------------|-----------------|----------------------|
| STORY-001 | Point api.cupidus.app at the production backend API | `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-001/story_brief.md` | Cloudflare DNS + VPS routing/TLS | Business Scope outcome 1; Nginx VPS-target ambiguity OQ |
| STORY-002 | Standardize VPS backend deploys onto GitHub Actions CI/CD | `data/requirements/REQ-005_production_domain_and_cicd_standardization/STORY-002/story_brief.md` | GitHub Actions workflow + VPS deploy cutover | Business Scope outcome 2; deploy-mechanism-unknown OQ; deploy-key-choice OQ |

INTEGRATION_VERIFICATION_REQUIRED: NO

Both stories are isolated with no structural cross-story runtime interaction
that per-story testing plus Reviewer gate cannot already cover: STORY-001's
own review verifies domain reachability directly, and STORY-002's own review
verifies the pipeline triggers a working deploy. Neither requires asserting
behavior that spans both story boundaries.
