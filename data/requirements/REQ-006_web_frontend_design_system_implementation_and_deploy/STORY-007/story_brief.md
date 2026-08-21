# Story Brief: STORY-007 Support FAQ Page

## Identity

- Parent requirement: REQ-006 Web frontend implementation from design system & production deploy
- Story master: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-007/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-007/requirements/requirements.md`

## Brief

- Actor: visitor or existing user with a question or problem, seeking
  self-service help.
- Capability: a "Support" page reachable from the shared nav, showing an
  expandable FAQ list (native disclosure/accordion behavior) and a "still
  need a human?" contact block linking to `hi@cupid.app`.
- Business value: reduces support load via self-service and gives a clear
  fallback contact channel.
- Key business rules or guardrails: FAQ entries are static seed content
  from the design source; contact is a `mailto:` link only — no ticketing
  or live-chat backend in v1.
- Key edge or failure case: each FAQ entry must independently
  expand/collapse (native `<details>`/`<summary>` behavior in the design
  source) without affecting other entries' state.
- Existing system entry / discoverability seed: reachable via the "Support"
  item in the shared header nav established in STORY-001; direct URL also
  acceptable.
- Complexity: standard — new screen.
- Why this complexity: introduces a new screen; no new architecture beyond
  STORY-001.
- Implementation lane seed: frontend.
- Depends on: STORY-001 (shared chrome, nav route, framework).

## Direct Anchors

- Requirement AC / BR anchors: `requirements/requirements.md` Coverage Map
  row "Support / FAQ page"; design source section `isSupport` in
  `cupid-app-design-system/Cupid Web.dc.html`.
- Open Question anchors: None directly (inherits OQ-REQ006-2 resolution: no
  backend dependency).
- Related story dependencies: STORY-001.

## Scope Seed

### In Scope

- Expandable FAQ list (question/answer pairs, independent expand/collapse).
- "Still need a human?" contact block with `mailto:hi@cupid.app` link.

### Out of Scope

- Live chat, ticketing system, or any support backend.
- Backend/API integration.
