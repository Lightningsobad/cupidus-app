# Story Brief: STORY-005 Cupid Journal Blog Page

## Identity

- Parent requirement: REQ-006 Web frontend implementation from design system & production deploy
- Story master: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-005/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-005/requirements/requirements.md`

## Brief

- Actor: visitor interested in relationship-focused editorial content
  (content-marketing audience, not necessarily an app-shopper).
- Capability: a "Blog" page reachable from the shared nav, showing topic
  filter pills, a featured article panel, an article grid, and a newsletter
  signup block.
- Business value: content marketing / SEO surface that builds trust and
  brings in visitors who may later download the app.
- Key business rules or guardrails: content (topics, featured article,
  article list) is static seed content from the design source, not a live
  CMS in v1; newsletter signup input/button is presentational only — no
  backend wiring exists in the design source.
- Key edge or failure case: none — content is static and always fully
  populated; no empty-state needed for v1.
- Existing system entry / discoverability seed: reachable via the "Blog"
  item in the shared header nav established in STORY-001; direct URL also
  acceptable for individual/shared article links in a future iteration
  (out of scope here — the design source has no per-article detail view,
  only the listing page).
- Complexity: standard — new screen.
- Why this complexity: introduces a new screen with several content
  sub-components; no new architecture beyond STORY-001.
- Implementation lane seed: frontend.
- Depends on: STORY-001 (shared chrome, nav route, framework).

## Direct Anchors

- Requirement AC / BR anchors: `requirements/requirements.md` Coverage Map
  row "Blog / Journal page + newsletter signup"; design source section
  `isBlog` in `cupid-app-design-system/Cupid Web.dc.html`.
- Open Question anchors: None directly (inherits OQ-REQ006-2 resolution: no
  backend dependency — newsletter form and articles are static/
  presentational in v1).
- Related story dependencies: STORY-001.

## Scope Seed

### In Scope

- Topic filter pills (presentational; design source does not wire them to
  actual filtering logic — no `onClick` filter handler exists).
- Featured article panel.
- Article card grid (title, excerpt, author, read time).
- Newsletter signup block (presentational form, no submit wiring).

### Out of Scope

- Individual article detail/reader pages (not in the design source — only a
  listing page exists).
- Real topic filtering logic or newsletter backend submission.
- Backend/API/CMS integration.
