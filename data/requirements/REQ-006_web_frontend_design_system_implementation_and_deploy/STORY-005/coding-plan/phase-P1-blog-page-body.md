# Phase P1 – Blog Page Body, Seed Data, And Article Card

## 1. Objective

Replace the `web/src/pages/blog.astro` stub body with the full Cupid Journal
page — intro, topic pills, featured panel, 6-card article grid, newsletter
block — rendered inside the unmodified STORY-001 shell, with a Blog-specific
`<title>`, satisfying AC-1 through AC-9.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-blog-page-body.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: None (STORY-001 already merged)
- Parallelizable: NO
- Write Scope:
  - `web/src/pages/blog.astro`
  - `web/src/components/blog/ArticleCard.astro`
  - `web/src/data/blog-content.ts`
- Impacted Runtime Service/App:
  - Name: `web`
  - Runtime Registry Id: `web-frontend`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: frontend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (`npm run build`)
  - Readiness Check: N/A for this phase
  - Port Contract: per-project loopback host binding (`DEVSTACK_PORT_WEB`)
- Shared Interfaces Consumed:
  - `../../STORY-001/architecture/contract-summary.md` (§1 `SiteLayout` usage,
    §2 route key `blog`, §3 `data-vi`/`data-en`, §4 tokens and sprites, §6
    prohibitions)
  - `web/src/layouts/SiteLayout.astro` `title` prop (existing, `:11-17`)
  - `web/src/components/sprites/SuaSprite.astro`
- Risk Surfaces:
  - Rendered visual fidelity
  - Bilingual copy fidelity
  - Shell immutability
  - False interactive promise
  - Per-page title (AC-9)
  - Node engine floor
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §6.2-§6.7 for
    every measurable value and every literal VI/EN string;
    `cupid-app-design-system/Cupid Web.dc.html:453-509` and `:780-792` for the
    per-card avatar gradient stops and tint percentages the spec cites rather
    than inlines.
  - consumer contract: none published by this phase.
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-1..AC-9
  - architecture: `../architecture/solution.md` §1 Key Discovery, §4
  - UX constraints, if truly required: `../ux/uiux-spec.md` §6.2 (layout,
    spacing, copy), §6.3 (interaction/a11y treatment), §6.6 (responsive,
    focus, heading levels), §6.7 (visual anchor values)
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one static page body plus its seed data and its one
    repeated card component.
  - Source/Test File Count: 3
  - Split Required: NO
  - Split Rationale: all three files are one behavior cluster written in one
    pass; a split would separate files that must be written together and would
    add a second verification pass over the same rendered page.

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md` §6.2-§6.7
- `../../STORY-001/architecture/contract-summary.md`

## 3. Tasks

- Select a Node >=22.12.0 runtime before any `npm` command in `web/`; the
  machine default is v20.20.2 and `astro@6.0.5` will refuse it.
- Create `web/src/data/blog-content.ts` exporting a typed `topics` array (4
  entries, VI/EN label pairs, source order) and a typed `posts` array (6
  entries: category VI/EN, accent token name, tag tint percentage, title VI/EN,
  excerpt VI/EN, author, read-time minutes, avatar gradient stops), copied
  verbatim from `Cupid Web.dc.html:780-792`.
- Create `web/src/components/blog/ArticleCard.astro` taking one `posts` entry
  and rendering the §6.2.4 anatomy: category tag pill, title, flexing excerpt,
  divider-topped author/read-time footer row, decorative avatar swatch with
  `aria-hidden="true"`, hover border + `translateY(-4px)` lift in a scoped
  `<style>` block.
- Rewrite `web/src/pages/blog.astro`: open `<SiteLayout page="blog" title="…">`
  with a descriptive Blog-specific title (AC-9), then author the page container,
  intro block, topic pill row, featured panel, `posts.map` card grid, and
  newsletter block inline per §6.2.1-§6.2.5.
- Build the featured panel from the design source's hardcoded content, not from
  `posts` (AC-4); mount `SuaSprite.astro` at 180×180 in the illustration cell.
- Render topic pills and article cards as non-interactive elements: no
  `<button>`, `<a>`, `href="#"`, `tabindex`, or ARIA interactive role. Hover
  styling only.
- Render the newsletter as a real `<input type="email">` plus `<button>` with
  visible focus rings; if wrapped in a `<form>`, its submit handler calls
  `preventDefault()` and does nothing else. No `fetch`, no action URL.
- Give every user-visible string both a `data-vi` and a `data-en` span, copied
  verbatim — no paraphrase, no quote or dash normalization.
- Use `<h1>` for the page headline, `<h2>` for the featured title, `<h3>` (or
  non-heading emphasis) for card titles; do not skip levels.
- Record evidence in `coding-plan/test-results.md`.

## 4. Acceptance Criteria

- `/blog` is reachable by clicking "Blog" in the header nav and renders without
  console errors; the nav pill and the mobile `<select>` option show the active
  treatment (AC-1).
- Intro eyebrow, H1, and paragraph render with the literal VI/EN copy (AC-2).
- Exactly 4 presentational topic pills render in source order with no filter
  behavior and no Tab stop (AC-3).
- One hardcoded featured panel renders with illustration cell, category tag,
  title, excerpt, author, and read time, and is not derived from `posts` (AC-4).
- Exactly 6 article cards render from seed data in an `auto-fit` grid that
  never drops below its `minmax` floor at 375/768/1024/1440px (AC-5).
- Newsletter heading, subcopy, `email@cupid.app`-placeholder input, and
  Subscribe button render; activating the button causes no navigation, reload,
  or network request (AC-6).
- Layout, spacing, radii, colors, and typography match the §6.7 anchor values
  (UI-Fidelity-AC-7, confirmed at the review gate).
- Toggling VI↔EN leaves no blank or missing string anywhere on the page (AC-8).
- Built `/blog` HTML contains a Blog-specific `<title>`, not the `'Cupid'`
  default (AC-9).
- The story diff touches only this phase's three files — no shell, token, or
  global-style file.

## 5. Planned Outputs

- Code directories or files: `web/src/pages/blog.astro`,
  `web/src/components/blog/ArticleCard.astro`, `web/src/data/blog-content.ts`
- Notes or evidence: `../coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: static web page `/blog` in the `web/` Astro workspace
- Required levels (omit N/A levels):
  - frontend build/type-check: `npm run check` then `npm run build`, both from
    `web/` under Node >=22.12.0
- Required checks:
  - grep the story diff for `fetch(`, `href="#"`, `tabindex`, `action=`, and
    `localStorage` — all must be absent
  - confirm no file outside the declared Write Scope is modified
  - confirm the built `/blog` output contains the Blog-specific `<title>` and
    both a `data-vi` and a `data-en` span for every user-visible string
  - in the dev server, confirm at 375/768/1024/1440px that the featured panel
    and article grid reflow without dropping below their `minmax` floors, that
    VI↔EN toggling leaves no blank string, that Tab reaches only the newsletter
    input and button, and that Subscribe triggers no navigation or request
    (behavioral checks for AC-3/AC-5/AC-6/AC-8; pixel fidelity itself is the
    requirement visual audit's job, not this phase's)
- Frontend discoverability / navigation integration: reach `/blog` by clicking
  the header nav item (desktop) and selecting it in the mobile `<select>`, not
  by typing the URL; confirm the active-pill treatment and `aria-current="page"`.
- Minimum gates by risk surface: build/type-check clean; VI↔EN toggle shows no
  missing string; Tab order contains only the newsletter input and button;
  Subscribe performs no navigation or request; diff contains no shell file.
- Required runtime signals (omit N/A signals):
  - browser console clean of errors and warnings on `/blog`
- Evidence format: one concise row per required check in
  `../coding-plan/test-results.md` (command output, per-breakpoint and
  per-locale observations)
- Requirement frontend visual audit: YES — REQ-006 requires the full UI-lane
  review gate for this story plus a requirement-level `frontend-dev`
  `Mode: requirement-visual-audit` before the requirement can be DONE. That is
  a story-exit/requirement-exit gate, not a P1 task.
- Verification strategy:
  - Targeted tests/regression/contract checks: no test framework exists in
    `web/`; `astro check` is the type/contract gate, and the `page="blog"`
    prop is validated at build time by the string-literal union.
  - Build/type-check/lint command when required: `npm run check` and
    `npm run build` from `web/`
  - Required assertion evidence: both commands exit 0; per-breakpoint visual
    observations; VI/EN toggle observation; Tab-order observation.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-21
