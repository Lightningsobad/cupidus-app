# Requirement Master: REQ-006 Web frontend implementation from design system & production deploy
Status: PENDING

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

- Frontend framework/stack is not yet chosen by the user (e.g. Next.js,
  Vite/React, plain static site) — this is Tech Lead-owned technical
  solutioning once Product Owner has broken this requirement into stories,
  not a Scrum Master decision.
- Whether the frontend consumes the backend API directly (needs
  `api.cupidus.app` live first) or is a marketing/static site with no API
  dependency is unclear from the request and should be resolved during story
  breakdown.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
