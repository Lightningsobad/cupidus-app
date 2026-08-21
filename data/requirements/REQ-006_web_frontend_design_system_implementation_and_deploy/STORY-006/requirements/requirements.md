# Story Requirements: STORY-006 About & Press Kit Page

Parent requirement: REQ-006 Web frontend implementation from design system &
production deploy (`req_master.md`).

## Context Summary

- Actor: a visitor, press contact, or partner who wants to understand the
  company and, for press/partner visitors, get brand assets.
- Capability: an "About" page reachable from the shared nav (and footer
  "Press kit" link) built in STORY-001, showing the mission statement,
  product-principles grid, usage-stat counters, a "Why a pet?" callout, a
  company timeline, team member cards, and a press-kit section (dark/light
  brand lockups, colour palette, "Download kit" CTA).
- Business outcome: builds trust/credibility for visitors and gives press or
  partners self-serve access to brand assets.
- Source of truth: `cupid-app-design-system/Cupid Web.dc.html`, `isAbout`
  page-state block (line ~511 onward), including the nested `showPressKit`
  conditional block. Read-only design reference, not application source
  code.
- Confirmed by requirement-level `OQ-REQ006-2` resolution: zero
  `fetch`/API/backend calls anywhere in the design source — this is a
  static/informational build; every action on this page (download kit link)
  is a presentational/static control.
- Depends on STORY-001 (DONE, `MERGE_COMPLETE`) only, for the shared
  header/nav/footer chrome, framework decision, and theme/language toggle
  behavior already established there. This story reuses that foundation
  unmodified and does not re-litigate the framework choice.

## Scope Decision

### In Scope

- About page content, matching the `isAbout` page-state block of
  `Cupid Web.dc.html` exactly:
  - Eyebrow label + H1 mission headline + mission subcopy paragraph.
  - Product-principles grid: 4 cards (Couple-first; Dual-confirmation; Sulk,
    sweetly; No ads), each with title + description, VI/EN.
  - Usage-stat counters: 3 stat cards (48.000+ couples on Cupid; 31.500 pets
    hatched; 2,1 triệu / 2.1 million keepsake cards minted), VI/EN labels.
  - "Why a pet?" callout block: eyebrow label, headline, body copy, VI/EN.
  - Company timeline ("The road so far" / "Chặng đường"): 5 chronological
    entries (2024 whiteboard; 2025 first build; 2025 dual-confirmation; 2026
    Vietnam launch; 2026 next), each with year, title, description, VI/EN.
  - Team section ("The team" / "Đội ngũ"): 3 member cards (Minh Khôi /
    Product; Linh Đàm / Design; Thu Hà / Engineering), each with avatar
    (gradient placeholder per design), name, role label VI/EN.
  - Press-kit section: eyebrow label, "Brand assets" headline, "Download
    kit" CTA; dark lockup swatch, light lockup swatch, and an 8-swatch
    colour palette grid (hex value + name) reading from the design source's
    `palette` data.
- Press-kit section ships always-visible in v1 (`showPressKit` defaults
  `true` in the design source; no admin/config surface exists to toggle it
  in this project, so no toggle is built).
- "Download kit" CTA is a static presentational link to a downloadable
  asset (mechanism — e.g. a static zip file served from the built site —
  is a Tech Lead/DevOps implementation decision, not a Product Owner scope
  item).
- Route reachable from the existing "About" nav item and the existing
  footer "Press kit" link, both already wired to this route by STORY-001
  (per the design source, both controls navigate to the same `about` page
  state); direct URL entry must also work.
- A page-specific `<title>` tag for this page (carried-forward deferred
  finding `DEF-2` from the STORY-001 review gate: every new page needs its
  own proper `<title>`, not a shared/generic one).
- Copy must match the design source's literal VI and EN strings for every
  section on this page; no paraphrasing.

### Out of Scope

- A real press-kit asset-bundling/download backend service — v1 ships a
  static downloadable file only; any bundling/generation service is
  explicitly out of scope.
- Any admin or config control to hide/show the press-kit section — it is
  always visible in v1, matching the design source's default.
- Any backend/API integration — the design source has none (`OQ-REQ006-2`,
  RESOLVED at requirement level).
- Shared header/nav/footer chrome, framework/build tooling, and
  theme/language toggle behavior — already built by STORY-001; this story
  only adds the About page content and route.
- Any new design screens or copy not present in the `isAbout` block of
  `Cupid Web.dc.html`.

## Acceptance Criteria

- **AC-1 (Route reachability)**: the About page is reachable at its own
  route from the existing "About" nav item and the existing footer
  "Press kit" link (both established in STORY-001), and via direct URL
  entry; navigating there does not 404.
- **AC-2 (Mission section)**: the page renders the eyebrow label, H1
  mission headline, and mission subcopy paragraph matching the design
  source's `isAbout` block, VI and EN.
- **AC-3 (Product principles grid)**: exactly 4 principle cards render
  (Couple-first; Dual-confirmation; Sulk, sweetly; No ads), each with title
  and description text matching the design source's `principles` data, VI
  and EN.
- **AC-4 (Usage stat counters)**: exactly 3 stat cards render with the
  literal values and labels from the design source (48.000+ couples on
  Cupid; 31.500 pets hatched; 2,1 triệu / 2.1 million keepsake cards
  minted), VI and EN.
- **AC-5 ("Why a pet?" callout)**: the callout block renders eyebrow label,
  headline, and body copy matching the design source, VI and EN.
- **AC-6 (Company timeline)**: exactly 5 timeline entries render in
  chronological order (2024, 2025, 2025, 2026, 2026) with the literal year,
  title, and description text from the design source, VI and EN.
- **AC-7 (Team section)**: exactly 3 team member cards render (Minh Khôi /
  Product, Linh Đàm / Design, Thu Hà / Engineering) with the design
  source's avatar gradient, name, and role label, VI and EN.
- **AC-8 (Press kit section, always visible)**: the press-kit section
  always renders (no admin toggle exists), containing: dark lockup swatch,
  light lockup swatch, an 8-entry colour-palette grid (hex + name reading
  from the design source's `palette` data), and a "Download kit" CTA that
  is a static presentational link to a downloadable asset (delivery
  mechanism is a Tech Lead/DevOps decision).
- **AC-9 (Per-page title tag)**: the page sets its own descriptive HTML
  `<title>` (not a shared/generic title reused from another page),
  resolving the carried-forward `DEF-2` finding from the STORY-001 review.
- **UI-Fidelity-AC-10 (About page visual fidelity)**: the deployed About
  page — mission section, principles grid, stat counters, "Why a pet?"
  callout, timeline, team section, and press-kit section — is visually
  identical ("giống 100%") to the `isAbout` page-state block of
  `cupid-app-design-system/Cupid Web.dc.html`, per the requirement's hard
  pixel/visual-fidelity acceptance requirement. This story requires the
  full UI-lane review gate with `design_source` and `ui_surface`
  configured (not the Tier 0 lightweight gate), per `req_master.md`
  Technical Constraints.
- **AC-11 (Copy fidelity)**: all About-page copy matches the design
  source's literal VI and EN strings; no paraphrasing.

## Open Question Impact

### Scope Items BLOCKED in this story

- None. Both requirement-level open questions are resolved before this
  story's scope begins.

### Scope Items NOT BLOCKED in this story

- `OQ-REQ006-1` (frontend framework/stack) — RESOLVED by the STORY-001
  Tech Lead (Astro static site). This story reuses that decision; nothing
  here is blocked by it.
- `OQ-REQ006-2` (backend API dependency) — RESOLVED at requirement level:
  no live `api.cupidus.app` dependency in v1, including the "Download kit"
  CTA, which is a static asset link, not a backend-bundling call. Nothing
  in this story is blocked by it.

## Direct Anchors

- Requirement-level: `req_master.md` Business Scope, Technical Constraints
  (visual-fidelity + REQ-005 CI/CD reuse), Open Questions (`OQ-REQ006-1`
  RESOLVED, `OQ-REQ006-2` RESOLVED).
- Requirement-level `requirements/requirements.md`: Coverage Map row
  "About page (mission, stats, timeline, team) + press kit", Story Index
  row for STORY-006.
- Story-level: `story_brief.md` Scope Seed, Direct Anchors.
- Design source: `cupid-app-design-system/Cupid Web.dc.html`, `isAbout`
  block (~line 511) and nested `showPressKit` block (~line 582); data
  arrays `principles` (~line 800) and `palette` (~line 807).
- Depends on: STORY-001 (shared chrome, nav route, framework — DONE,
  `MERGE_COMPLETE`).
- Carried-forward finding: STORY-001 review gate `DEF-2` (per-page
  `<title>` tag), addressed here as `AC-9`.
