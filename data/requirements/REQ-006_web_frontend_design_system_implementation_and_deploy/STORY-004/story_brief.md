# Story Brief: STORY-004 Pairing Invite Landing Page

## Identity

- Parent requirement: REQ-006 Web frontend implementation from design system & production deploy
- Story master: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-004/requirements/requirements.md`

## Brief

- Actor: a person who received an invite/pairing code from their partner and
  lands on the web page (e.g. from a shared link) before opening the app.
- Capability: an "Invite" page reachable from the shared nav, explaining the
  pairing-code flow (code cell display, "Open Cupid" deep-link-style CTA,
  three-step explainer: get a code / both confirm / pick a pet), an
  illustrated before/after phone-mockup pairing sequence, and the keepsake
  card concept/preview.
- Business value: converts an invite recipient into a download, and
  explains the dual-confirmation pairing model that differentiates the
  product.
- Key business rules or guardrails: this page does NOT perform real
  pairing-code redemption — the design source has no backend wiring for it;
  it is a static explainer/landing page whose "Open Cupid" CTA is a
  presentational link only.
- Key edge or failure case: none — no real input validation exists in the
  design source (the code cells are illustrative, not a functional input
  form).
- Existing system entry / discoverability seed: reachable via the "Invite"
  item in the shared header nav established in STORY-001, and this is also
  the most likely direct-URL entry point of any page in this requirement
  (shared invite links point straight here) — both nav discovery and direct
  URL are acceptable.
- Complexity: standard — new screen.
- Why this complexity: introduces a new screen with phone-mockup visual
  components; no new architecture beyond STORY-001.
- Implementation lane seed: frontend.
- Depends on: STORY-001 (shared chrome, nav route, framework).

## Direct Anchors

- Requirement AC / BR anchors: `requirements/requirements.md` Coverage Map
  row "Invite / pairing landing page"; design source section `isShare` in
  `cupid-app-design-system/Cupid Web.dc.html`.
- Open Question anchors: None directly (inherits OQ-REQ006-2 resolution: no
  backend dependency — pairing-code entry is presentational only in v1).
- Related story dependencies: STORY-001.

## Scope Seed

### In Scope

- Pairing-code cell display (illustrative, non-functional) and "Open Cupid"
  CTA link.
- Three-step explainer (get a code / both confirm / pick a pet).
- Before/after phone-mockup pairing illustration.
- Keepsake-card concept section with sample card previews.

### Out of Scope

- Real pairing-code input, validation, or redemption against any backend
  (not in the design source).
- Backend/API integration.
