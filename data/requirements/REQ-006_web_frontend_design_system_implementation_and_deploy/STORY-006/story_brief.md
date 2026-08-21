# Story Brief: STORY-006 About & Press Kit Page

## Identity

- Parent requirement: REQ-006 Web frontend implementation from design system & production deploy
- Story master: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-006/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-006/requirements/requirements.md`

## Brief

- Actor: visitor, press contact, or partner wanting to understand the
  company and get brand assets.
- Capability: an "About" page reachable from the shared nav, showing the
  mission statement, product principles grid, usage stat counters, company
  timeline, team member cards, and a press-kit section (brand lockups,
  palette swatches, download-kit CTA).
- Business value: builds trust/credibility for visitors and gives press or
  partners self-serve access to brand assets.
- Key business rules or guardrails: press-kit visibility is controlled by
  the design source's `showPressKit` prop, defaulting to visible/true — ship
  it always-visible in v1 (no admin/config surface exists to toggle it);
  "Download kit" is a presentational link (no backend asset bundling
  service exists — Tech Lead/DevOps determines the actual asset delivery
  mechanism, e.g. a static zip).
- Key edge or failure case: none — content is static and always fully
  populated.
- Existing system entry / discoverability seed: reachable via the "About"
  item in the shared header nav established in STORY-001 (footer also links
  "Press kit" to the same page/anchor); direct URL also acceptable.
- Complexity: standard — new screen.
- Why this complexity: introduces a new screen with multiple content
  sub-sections; no new architecture beyond STORY-001.
- Implementation lane seed: frontend.
- Depends on: STORY-001 (shared chrome, nav route, framework).

## Direct Anchors

- Requirement AC / BR anchors: `requirements/requirements.md` Coverage Map
  row "About page + press kit"; design source section `isAbout` (incl.
  nested `showPressKit`) in `cupid-app-design-system/Cupid Web.dc.html`.
- Open Question anchors: None directly (inherits OQ-REQ006-2 resolution: no
  backend dependency).
- Related story dependencies: STORY-001.

## Scope Seed

### In Scope

- Mission statement + product principles grid.
- Usage stat counters (couples/pets/cards).
- Company timeline (2024–2026 milestones).
- Team member cards.
- Press kit section: dark/light brand lockups, colour palette, "Download
  kit" CTA (static asset link).

### Out of Scope

- A real press-kit asset-bundling/download backend service beyond a static
  downloadable file (Tech Lead determines exact delivery mechanism).
- Any admin control to hide/show the press-kit section (always visible in
  v1, matching the design source default).
- Backend/API integration.
