# Requirement Master: REQ-006 Web frontend implementation from design system & production deploy
Status: IN_PROGRESS

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: REQUESTED (direct user instruction, see Business Scope)

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: REQUIRED
- Pending User Setup:
  - VPS Caddy site block for `cupidus.app, www.cupidus.app` (`try_files` +
    `file_server`) must be appended by hand to `/etc/caddy/Caddyfile` on the
    VPS before the first production deploy — same manual/SSH operational step
    REQ-005 §1 performed for `api.cupidus.app` (`configuration-guide.md:82-98`).
  - New GitHub Actions secret `VPS_WEB_DEPLOY_PATH` must be provisioned
    (currently a placeholder only, not set) — `deploy-web.yml` reads it to
    resolve the deploy target directory (`configuration-guide.md:110`).
  - UNVERIFIED RISK, confirm before first real deploy: REQ-005's
    `VPS_SSH_PRIVATE_KEY` is server-side restricted to commands prefixed
    `cd /var/www/backend && `, but `vps-deploy-web.sh` prefixes
    `cd ${VPS_WEB_DEPLOY_PATH} && ` instead, which that forced-command
    wrapper may refuse. Widen the wrapper or provision a separate
    `VPS_WEB_SSH_PRIVATE_KEY` (`configuration-guide.md:115-131`).
- Last Updated: 2026-08-22 (via REQ-006 integration review finding INT-4)

## Business Scope

There is no web frontend app in this project's runnable foundation today
(bootstrap recorded "Frontend app: not_applicable — No web frontend in scope
for REQ-001"). The user now wants a new web frontend project built from the
existing web design in `cupid-app-design-system/` (design-comp/spec files:
`Cupid Web.dc.html`, `Cupid App.dc.html`, `Cupid Screens.dc.html`, `Cupid
Share Cards.dc.html`, logo/icon/sprite assets, plus `android-frame.jsx` /
`ios-frame.jsx` device-frame helpers and `image-slot.js` / `support.js`
support scripts). Read that design source and produce the corresponding
pages for a new frontend project, then deploy it on the same VPS
(`root@84.247.140.178`) at the apex domain `cupidus.app`.

Hard acceptance requirement from the user: the deployed/generated code must
validate as visually identical ("giống 100%") to the design source — this is
a strict pixel/visual-fidelity requirement, not an approximate reskin.

## Technical Constraints

- Design source of truth: `cupid-app-design-system/Cupid Web.dc.html` plus
  the other `.dc.html` design-comp files in that directory (read-only
  design reference; do not treat it as application source code to run).
- Design-Source: UPDATED 2026-08-21T10:18:35Z (applied) — the design-fidelity lock currently points at
  REQ-001's mobile canvas (`Cupid App.dc.html`); it must be re-detected and
  re-locked to this requirement's web canvas (`Cupid Web.dc.html`, confirmed
  present as a sibling file in `cupid-app-design-system/`).
- Target domain: apex `cupidus.app`, on the same VPS as REQ-005
  (`root@84.247.140.178`). This requirement depends on REQ-005 for the VPS
  deploy pattern / CI-CD pipeline and, if the frontend calls the backend
  directly, the `api.cupidus.app` endpoint being live.
- Because this story carries a rendered visual-fidelity acceptance
  requirement, it cannot use the Scrum Master lightweight (Tier 0) review
  gate — it needs the full UI-lane review gate with `design_source` and
  `ui_surface` configured, plus the requirement-level `frontend-dev`
  `Mode: requirement-visual-audit` before this requirement can be marked
  DONE.
- Where the new frontend's CI/CD deploy needs credentials (VPS deploy key,
  registry, etc.), reuse the GitHub Actions pipeline pattern established by
  REQ-005 rather than inventing a second deploy mechanism; create placeholder
  GitHub Actions secrets for anything new and report the exact list back to
  the user, per REQ-005's Technical Constraints.

## Dependencies

- Depends on REQ-005 (production domain + GitHub Actions CI/CD
  standardization) for the VPS deploy pipeline pattern and, if applicable,
  a live `api.cupidus.app` backend endpoint.

## Open Questions

- OQ-REQ006-1 — Frontend framework/stack is not yet chosen by the user (e.g.
  Next.js, Vite/React, plain static site) — this is Tech Lead-owned technical
  solutioning, assigned to STORY-001 (shared-foundation) since every other
  story depends on its output. UNRESOLVED, not a Scrum Master decision.
- OQ-REQ006-2 — RESOLVED (2026-08-21, Product Owner): whether the frontend
  consumes the backend API directly, or is a marketing/static site with no
  API dependency. Resolved by direct inspection of `Cupid Web.dc.html`: the
  design source contains zero `fetch`/API/backend references anywhere —
  every action (download buttons, pairing-code entry, newsletter signup,
  support contact) is a static link, `mailto:`, or presentational-only
  control. This is a static/informational marketing site with no live
  `api.cupidus.app` dependency in v1.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | Frontend App Foundation & Home Landing Page | standard | DONE | data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/story_master.md |
| STORY-002 | Pet Universe Showcase Page | standard | DONE | data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-002/story_master.md |
| STORY-003 | Zodiac Compatibility Preview Page | standard | DONE | data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-003/story_master.md |
| STORY-004 | Pairing Invite Landing Page | standard | DONE | data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/story_master.md |
| STORY-005 | Cupid Journal Blog Page | standard | DONE | data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-005/story_master.md |
| STORY-006 | About & Press Kit Page | standard | DONE | data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-006/story_master.md |
| STORY-007 | Support FAQ Page | standard | DONE | data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-007/story_master.md |
| STORY-008 | Privacy & Terms Page | standard | DONE | data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/story_master.md |

Design-Source: UPDATED 2026-08-22T02:17:06Z (applied) — repo ships TWO design surfaces in one bundle (Cupid App.dc.html = mobile, Cupid Web.dc.html = web); REQ-006 is the web lane and the single-entry config could only name the mobile one.
