# Story Requirements: STORY-005 Cupid Journal Blog Page

Parent requirement: REQ-006 Web frontend implementation from design system &
production deploy (`req_master.md`).

## Context Summary

- Actor: a visitor interested in relationship-focused editorial content
  (content-marketing audience, not necessarily an app-shopper yet).
- Capability: a "Blog" page, reachable from the shared header nav
  established in STORY-001, showing topic filter pills, a featured-article
  panel, an article card grid, and a newsletter signup block.
- Business outcome: a content-marketing / SEO surface that builds trust and
  brings visitors back to the app-download surfaces built in STORY-001.
- Source of truth: `cupid-app-design-system/Cupid Web.dc.html`, the
  `isBlog` page-state block (page section ~lines 453-509): heading + intro
  copy, 4 topic pills (`topics` seed data), 1 featured-article panel
  (hardcoded content, not looped), a 6-item article grid (`posts` seed
  data), and a newsletter signup block (email input + Subscribe button).
- Confirmed by direct inspection of the design source (Product Owner,
  requirement-level `OQ-REQ006-2` resolution): zero `fetch`/API/backend
  calls anywhere in the file — this is a static/informational build. The
  `isBlog` block specifically has no `onClick` filter handler on the topic
  pills and no form-submit wiring on the newsletter input/button.
- Depends on STORY-001 (Frontend App Foundation, shared-foundation,
  DONE/MERGE_COMPLETE) for the framework choice, shared header/nav/footer
  chrome, and the "Blog" nav route (already wired to not-404 by STORY-001;
  this story fills in that route's page content).

## Scope Decision

### In Scope

- Blog page reachable via the "Blog" nav item in the shared header nav
  (route already exists from STORY-001; this story builds the page content
  behind it).
- Page intro: "Cupid Journal" eyebrow label, H1 headline, intro paragraph —
  literal VI/EN copy from the design source.
- Topic filter pills: 4 pills (Yêu xa/Long distance, Giải quyết xung
  đột/Conflict, Ngôn ngữ tình yêu/Love languages, Hoàng đạo/Zodiac) rendered
  as presentational/static pills — no filtering logic, since the design
  source wires no click handler to them.
- Featured article panel: single hardcoded featured article (illustration
  panel + category tag, title, excerpt, author, read time) exactly as
  authored in the design source — not sourced from the `posts` array.
- Article card grid: 6 article cards from the design source's `posts` seed
  data (category tag, title, excerpt, author avatar/name, read time), laid
  out as a responsive auto-fit grid per the design source.
- Newsletter signup block: heading, subcopy, email input (placeholder
  `email@cupid.app`), and "Subscribe" button — presentational only, no
  submit handler/backend wiring, matching the design source.
- Per-page `<title>` tag for the Blog page (carried-forward deferred
  finding DEF-2 from STORY-001 review: every new page needs a proper
  per-page `<title>`, not just the shared shell default).
- Literal VI/EN copy fidelity for all Blog-page text content (headline,
  intro, topic pill labels, featured article, all 6 article cards,
  newsletter block) — no paraphrasing.

### Out of Scope

- Individual article detail/reader pages — the design source has no
  per-article route or content, only this single listing page.
- Real topic-filter logic (filtering the grid by pill selection) — no
  handler exists in the design source for this.
- Newsletter signup backend/API wiring or validation beyond native HTML
  input behavior — presentational only, per `OQ-REQ006-2` resolution.
- Any CMS integration, pagination, or dynamic article loading — v1 content
  is static seed content baked into the page.
- Shared header/nav/footer chrome and theme/language toggle behavior —
  already built and DONE in STORY-001; this story only supplies the Blog
  page's own body content.

## Acceptance Criteria

- **AC-1 (Page reachable)**: the Blog page is reachable by clicking "Blog"
  in the shared header nav and renders without error.
- **AC-2 (Page intro)**: the page renders the "Cupid Journal" eyebrow
  label, H1 headline, and intro paragraph with literal VI/EN copy matching
  the design source.
- **AC-3 (Topic pills, presentational)**: the page renders exactly 4 topic
  filter pills with the design source's literal VI/EN labels; pills are
  static/presentational and do not wire any filtering behavior.
- **AC-4 (Featured article panel)**: the page renders one featured-article
  panel with the design source's hardcoded illustration area, category tag,
  title, excerpt, author, and read time — not generated from the article
  grid data.
- **AC-5 (Article grid)**: the page renders 6 article cards from the design
  source's seed data, each with category tag, title, excerpt, author
  avatar/name, and read time, in a responsive auto-fit grid layout.
- **AC-6 (Newsletter block, presentational)**: the page renders the
  newsletter heading, subcopy, email input (with the design source's
  placeholder text), and "Subscribe" button; the input/button do not submit
  to any backend or API.
- **UI-Fidelity-AC-7 (Visual fidelity)**: the deployed Blog page — intro,
  topic pills, featured panel, article grid, and newsletter block — is
  visually identical ("giống 100%") to the `isBlog` page state of
  `cupid-app-design-system/Cupid Web.dc.html`, per the requirement's hard
  pixel/visual-fidelity acceptance requirement. This story requires the
  full UI-lane review gate with `design_source` and `ui_surface` configured
  (not the Tier 0 lightweight gate), per `req_master.md` Technical
  Constraints.
- **AC-8 (Copy fidelity)**: all Blog-page copy (headline, intro, topic
  pills, featured article, all 6 article cards, newsletter block) matches
  the design source's literal VI and EN strings for both locales.
- **AC-9 (Per-page title tag — DEF-2 carry-forward)**: the Blog page sets
  its own descriptive `<title>` tag (not the shared-shell default title),
  closing the deferred finding DEF-2 recorded in the STORY-001 review for
  this page.

## Open Question Impact

### Scope Items BLOCKED in this story

- None. Both requirement-level open questions are resolved before this
  story starts.

### Scope Items NOT BLOCKED in this story

- `OQ-REQ006-1` (frontend framework/stack) — RESOLVED by STORY-001's Tech
  Lead architecture pass (Astro static site), already DONE/MERGE_COMPLETE.
  This story implements against that established framework/foundation and
  does not re-litigate the choice.
- `OQ-REQ006-2` (backend API dependency) — RESOLVED at requirement level:
  no live `api.cupidus.app` dependency in v1. This story's topic pills and
  newsletter block are presentational-only per that resolution; nothing in
  this story is blocked by it.

## Direct Anchors

- Requirement-level: `req_master.md` Business Scope, Technical Constraints
  (visual-fidelity + REQ-005 CI/CD reuse), Open Questions (`OQ-REQ006-1`
  RESOLVED via STORY-001, `OQ-REQ006-2` RESOLVED).
- Requirement-level `requirements/requirements.md`: Coverage Map row "Blog /
  Journal page + newsletter signup", Story Index row for STORY-005.
- Story-level: `story_brief.md` Scope Seed, Direct Anchors (design source
  section `isBlog` in `cupid-app-design-system/Cupid Web.dc.html`).
- Dependency: STORY-001 (Frontend App Foundation & Home Landing Page) —
  shared chrome, nav route, and framework decision this story reuses;
  DONE/MERGE_COMPLETE.
- Carried-forward finding: STORY-001 review DEF-2 (per-page `<title>` tag),
  addressed here as AC-9.
