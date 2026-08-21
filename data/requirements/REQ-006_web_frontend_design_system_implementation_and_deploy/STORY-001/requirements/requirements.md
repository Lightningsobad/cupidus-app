# Story Requirements: STORY-001 Frontend App Foundation & Home Landing Page

Parent requirement: REQ-006 Web frontend implementation from design system &
production deploy (`req_master.md`).

## Context Summary

- Actor: a prospective couple visiting `cupidus.app` for the first time via
  direct URL entry (brand-new public marketing site; no existing product
  surface links here).
- Capability: a live, deployed web app at `cupidus.app` that establishes the
  app's framework/stack, the shared header/nav/footer chrome (theme toggle,
  VI/EN language toggle, "Get the app" CTA), and a fully-built Home landing
  page (hero, feature highlights, App Store/Google Play download links,
  usage stats).
- Business outcome: this is the primary marketing entry point that drives
  app downloads and establishes the visual chrome every later REQ-006 page
  story (STORY-002 through STORY-008) reuses unmodified.
- Source of truth: `cupid-app-design-system/Cupid Web.dc.html` (`home` page
  state plus the persistent header/nav/footer shell). Read-only design
  reference, not application source code.
- Confirmed by direct inspection of the design source (Product Owner,
  requirement-level `OQ-REQ006-2` resolution): zero `fetch`/API/backend
  calls anywhere in the file — this is a static/informational build.

## Scope Decision

### In Scope

- Framework/stack selection and runnable app scaffold (Tech Lead decision,
  resolves `OQ-REQ006-1` inside this story's architecture pass).
- Shared header: logo, primary nav (desktop), mobile nav collapses to a
  select control per the design breakpoint, dark/light theme toggle, VI/EN
  language toggle, "Get the app" CTA.
- Shared footer: brand block, link columns, copyright line.
- Home page: hero section (headline, subcopy, download badges, stat
  counters), features grid section — matching the `home` page state of
  `Cupid Web.dc.html` exactly.
- Nav routes/links to the other 7 pages (Pets, Zodiac, Invite, Blog, About,
  Support, Legal) must exist and not 404 within this story's scope; those
  pages render nothing until their own story ships (each is out of scope
  here).
- Client-side theme persistence (`localStorage`, per design source) and
  language state; both toggles fully functional across all four
  combinations (dark/light × VI/EN), not gated to a subset, since they are
  always-visible design chrome elements.
- CI/CD wiring to deploy to `cupidus.app` on the REQ-005 VPS
  (`root@84.247.140.178`), reusing the REQ-005 GitHub Actions pattern rather
  than inventing a new deploy mechanism; any new placeholder GitHub Actions
  secrets needed must be reported back to the user by exact name, per
  REQ-005's Technical Constraints.
- Copy must match the design source's literal VI and EN strings for the
  Home page and shared chrome; no paraphrasing.

### Out of Scope

- All 7 other pages' body content (Pets, Zodiac, Invite, Blog, About,
  Support, Legal) — each is its own REQ-006 story (STORY-002 through
  STORY-008); this story only wires the nav routes so they don't 404.
- Any backend/API integration — the design source has none (`OQ-REQ006-2`,
  RESOLVED at requirement level).
- Restricting theme/language toggle combinations to a subset.
- Any new design screens not present in `Cupid Web.dc.html`.

## Acceptance Criteria

- **AC-1 (Framework foundation)**: a runnable frontend app scaffold exists
  using the framework/stack Tech Lead selects during this story's
  architecture pass, resolving `OQ-REQ006-1`.
- **AC-2 (Shared chrome — header)**: every page (including the Home page
  built in this story) renders the sticky header with logo, desktop primary
  nav, mobile nav collapsing to a select control at the design breakpoint,
  dark/light theme toggle, VI/EN language toggle, and "Get the app" CTA.
- **AC-3 (Shared chrome — footer)**: every page renders the footer with
  brand block, link columns, and copyright line.
- **AC-4 (Theme + language persistence)**: theme selection persists across
  navigation via `localStorage`; language selection persists across
  navigation; all four theme × language combinations (dark/light × VI/EN)
  are fully working, none gated or disabled.
- **AC-5 (Nav routing, no dead links)**: nav items for all 8 pages (Home,
  Pets, Zodiac, Invite, Blog, About, Support, Legal) link to a valid route
  that does not 404, even though only Home has built page content in this
  story.
- **UI-Fidelity-AC-6 (Home page visual fidelity)**: the deployed Home page —
  hero section (headline, subcopy, download badges, stat counters) and
  features grid section — is visually identical ("giống 100%") to the
  `home` page state of `cupid-app-design-system/Cupid Web.dc.html`, per the
  requirement's hard pixel/visual-fidelity acceptance requirement. This
  story requires the full UI-lane review gate with `design_source` and
  `ui_surface` configured (not the Tier 0 lightweight gate), per
  `req_master.md` Technical Constraints.
- **AC-7 (Copy fidelity)**: Home page and shared chrome copy matches the
  design source's literal VI and EN strings for both locales.
- **AC-8 (Production deploy)**: the built app deploys to `cupidus.app` on
  the REQ-005 VPS via a GitHub Actions pipeline that reuses the REQ-005
  pattern; any new placeholder secrets required are reported to the user by
  exact name.

## Open Question Impact

### Scope Items BLOCKED in this story

- Framework/stack-dependent implementation work (app scaffold, component
  structure, build tooling) is BLOCKED on `OQ-REQ006-1` (frontend
  framework/stack choice — UNRESOLVED) until Tech Lead resolves it during
  this story's architecture pass. No implementation may proceed against a
  chosen framework until that resolution is recorded.

### Scope Items NOT BLOCKED in this story

- This story-requirements pass itself: business scope, in/out-of-scope
  boundaries, and acceptance criteria above are all framework-agnostic and
  do not depend on which framework Tech Lead selects.
- `OQ-REQ006-2` (backend API dependency) — RESOLVED at requirement level:
  no live `api.cupidus.app` dependency in v1; nothing in this story is
  blocked by it.

## Direct Anchors

- Requirement-level: `req_master.md` Business Scope, Technical Constraints
  (visual-fidelity + REQ-005 CI/CD reuse), Open Questions (`OQ-REQ006-1`,
  `OQ-REQ006-2`).
- Requirement-level `requirements/requirements.md`: Coverage Map row
  "Frontend framework/stack decision..." and "Global chrome..." / "Home /
  landing page...", Open Question Triage row for `OQ-REQ006-1`, Story Index
  row for STORY-001.
- Story-level: `story_brief.md` Scope Seed, Direct Anchors.
- Dependent stories: STORY-002 through STORY-008 all depend on this story's
  shared chrome and framework decision (`requirements/requirements.md`
  Recommended Story Sequence).
