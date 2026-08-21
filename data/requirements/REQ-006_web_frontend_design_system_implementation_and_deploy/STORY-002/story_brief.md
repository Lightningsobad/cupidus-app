# Story Brief: STORY-002 Pet Universe Showcase Page

## Identity

- Parent requirement: REQ-006 Web frontend implementation from design system & production deploy
- Story master: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-002/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-002/requirements/requirements.md`

## Brief

- Actor: visitor evaluating the app who wants to know what the pet
  characters are like before downloading.
- Capability: a "Pets" page reachable from the shared nav, showing all 6
  pet characters (Bo, Bun, Kem, Mochi, Sua, Xoài) with their trait/tagline
  and description, plus the four-stage growth-mechanic explainer.
- Business value: helps visitors emotionally connect with the core "raise a
  pet together" mechanic, supporting download conversion.
- Key business rules or guardrails: content is presentational only (no
  backend); pet names, traits, and copy must match the design source
  verbatim in both VI and EN.
- Key edge or failure case: none beyond standard responsive layout —
  content is static and always fully populated.
- Existing system entry / discoverability seed: reachable via the "Pets"
  item in the shared header nav / mobile nav select established in
  STORY-001; direct URL also acceptable for a public marketing page.
- Complexity: standard — new screen.
- Why this complexity: introduces a new screen; no new architecture beyond
  what STORY-001 established.
- Implementation lane seed: frontend.
- Depends on: STORY-001 (shared chrome, nav route, framework).

## Direct Anchors

- Requirement AC / BR anchors: `requirements/requirements.md` Coverage Map
  row "Pet Universe showcase page"; design source section `isPets` in
  `cupid-app-design-system/Cupid Web.dc.html`.
- Open Question anchors: None directly (inherits OQ-REQ006-2 resolution:
  no backend dependency).
- Related story dependencies: STORY-001.

## Scope Seed

### In Scope

- All 6 pet cards (sprite, name, trait tag, description) in both locales.
- Four-stage growth explainer section.

### Out of Scope

- Any pet-selection or account-linked functionality (not in the design
  source; this is a showcase page only).
- Backend/API integration.
