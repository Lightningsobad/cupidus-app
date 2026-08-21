# Story Brief: STORY-001 Frontend App Foundation & Home Landing Page

## Identity

- Parent requirement: REQ-006 Web frontend implementation from design system & production deploy
- Story master: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/requirements/requirements.md`

## Brief

- Actor: prospective couple visiting `cupidus.app` for the first time.
- Capability: a live, deployed web app at `cupidus.app` with the shared
  header/nav/footer chrome (theme toggle, VI/EN language toggle, "Get the
  app" CTA) and a fully-built Home landing page (hero, feature highlights,
  App Store/Google Play download links, usage stats).
- Business value: this is the primary marketing entry point that drives app
  downloads and establishes the visual chrome every later page reuses.
- Key business rules or guardrails: framework/stack choice is Tech
  Lead-owned (OQ-REQ006-1, resolved in this story); site must be a
  static/informational build with no backend API calls (design source has
  none); theme and language toggles must both be fully working, not gated to
  a subset, since they are visible design chrome elements; deploy pipeline
  should reuse the REQ-005 GitHub Actions/VPS pattern rather than inventing
  a new one.
- Key edge or failure case: theme/language preference persistence across
  navigation (design source persists theme via `localStorage`); mobile
  viewport nav collapses to a select control per the design breakpoint.
- Existing system entry / discoverability seed: direct URL entry
  (`https://cupidus.app`) is the expected and business-appropriate entry
  point — this is a brand-new public marketing site with no existing product
  surface to link from.
- Complexity: standard — new screens, new UX/architecture decisions
  (framework choice), single lane cannot bypass UX/architecture.
- Why this complexity: introduces the app's framework, shared chrome, and
  first screen; not security- or performance-sensitive.
- Implementation lane seed: frontend (framework choice + deploy wiring may
  also touch devops for the CI/CD pipeline extension; Tech Lead confirms
  exact lane split during architecture).
- Depends on: None (shared-foundation story; every other REQ-006 story
  depends on this one).

## Direct Anchors

- Requirement AC / BR anchors: `req_master.md` Business Scope, Technical
  Constraints (visual-fidelity + REQ-005 CI/CD reuse), Coverage Map row
  "Global chrome... / Home page" in `requirements/requirements.md`.
- Open Question anchors: OQ-REQ006-1 (frontend framework/stack, UNRESOLVED,
  resolved here by Tech Lead); OQ-REQ006-2 (backend API dependency,
  RESOLVED — no API dependency).
- Related story dependencies: STORY-002 through STORY-008 all depend on this
  story's shared chrome and framework decision.

## Scope Seed

### In Scope

- Framework/stack selection and app scaffold (Tech Lead decision).
- Shared header: logo, primary nav (desktop), mobile nav select, theme
  toggle (dark/light), language toggle (VI/EN), "Get the app" CTA.
- Shared footer: brand block, link columns, copyright line.
- Home page: hero section (headline, subcopy, download badges, stat
  counters), features grid section.
- CI/CD wiring to deploy to `cupidus.app` on the REQ-005 VPS, reusing the
  REQ-005 GitHub Actions pattern (placeholder secrets reported to the user
  per REQ-005's Technical Constraints if new ones are needed).
- Client-side theme persistence (`localStorage`) and language state.

### Out of Scope

- All 7 other pages (Pets, Zodiac, Invite, Blog, About, Support, Legal) —
  each is its own story; only the nav routes/links to them need to exist
  and not 404 within this story's own scope (they render nothing until
  their own story ships, which is acceptable since this story does not
  claim those pages work).
- Any backend/API integration.
- Restricting theme/language toggle combinations.
