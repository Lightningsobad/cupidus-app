# Story Brief: STORY-008 Privacy & Terms Page

## Identity

- Parent requirement: REQ-006 Web frontend implementation from design system & production deploy
- Story master: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/requirements/requirements.md`

## Brief

- Actor: visitor or compliance reviewer wanting to read the privacy policy
  and terms of service.
- Capability: a "Legal" page reachable from the shared nav, showing the
  "Updated <date>" line and the privacy/terms sections listed in the design
  source.
- Business value: legal/compliance transparency required for any public
  consumer app.
- Key business rules or guardrails: legal copy is exactly the content
  supplied in the design source (`legal` list) — this story reproduces that
  copy verbatim; it is not the source of legal-content authorship. If actual
  legal review of the copy content itself is needed, that is a business
  decision outside this delivery story's scope (flag to the user only if
  asked; do not silently rewrite legal text).
- Key edge or failure case: none — content is static and always fully
  populated.
- Existing system entry / discoverability seed: reachable via the "Legal"
  item (footer "Privacy"/"Terms" links and any header reference) in the
  shared nav established in STORY-001; direct URL also acceptable.
- Complexity: standard — new screen.
- Why this complexity: introduces a new screen; no new architecture beyond
  STORY-001.
- Implementation lane seed: frontend.
- Depends on: STORY-001 (shared chrome, nav route, framework).

## Direct Anchors

- Requirement AC / BR anchors: `requirements/requirements.md` Coverage Map
  row "Privacy & Terms page"; design source section `isLegal` in
  `cupid-app-design-system/Cupid Web.dc.html`.
- Open Question anchors: None directly (inherits OQ-REQ006-2 resolution: no
  backend dependency).
- Related story dependencies: STORY-001.

## Scope Seed

### In Scope

- "Updated <date>" line.
- All legal sections (title + body) exactly as provided in the design
  source, in both VI and EN.

### Out of Scope

- Authoring or legally reviewing the policy content itself (reproduce the
  design source's copy verbatim; do not paraphrase or add sections).
- Backend/API integration.
