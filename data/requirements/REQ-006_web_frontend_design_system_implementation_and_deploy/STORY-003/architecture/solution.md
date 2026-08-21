# 003_zodiac-compatibility-preview-page-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-21

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: strict rendered visual fidelity to
  `cupid-app-design-system/Cupid Web.dc.html:285-384`; zero shell mutation while
  7 sibling page stories build in parallel worktrees; static-only content
  (OQ-REQ006-2 RESOLVED).
- Architectural invariants / non-goals:
  - The STORY-001 shell (`SiteLayout`, `SiteHeader`, `SiteFooter`,
    `tokens.css`, `global.css`, `theme-lang-boot.ts`, `site-nav.ts`) is
    read-only in this story. This page contributes a `<main>` slot body only.
  - No new build tooling, no dependency added to `web/package.json`, no test
    framework introduced. `web/` currently has none, and every sibling story is
    editing this same workspace concurrently.
  - No `fetch`, no `localStorage` key, no interactive control on this page.
- Proposed technical direction: one static data module
  (`web/src/data/zodiac.ts`) holding all sample content, one ported art
  component (`web/src/components/sprites/ZodiacIcon.astro`), four section
  components under `web/src/components/zodiac/`, and the route body in the
  already-existing `web/src/pages/zodiac.astro`.
- Why this fits the current system or new area: mirrors STORY-001's own
  established split (`data/` for verbatim design arrays, `components/sprites/`
  for ported `dc-import` art, `components/<page>/` for page sections) so the
  page reads as native to the workspace rather than as a second convention.

### Key Discovery

Three facts the story artifacts do not carry, found by reading the source:

1. **The zodiac icons are not in `Cupid Web.dc.html`.** Every icon is
   `<dc-import name="Zodiac Icon" sign="...">`; the artwork lives in a separate
   design file, `cupid-app-design-system/Zodiac Icon.dc.html`. It is a single
   `<svg viewBox="0 0 100 100">` with a `<circle cx=50 cy=50 r=48 fill={disc}>`
   plus **12 mutually exclusive `sc-if` glyph branches**, each a
   `<g stroke={ink} stroke-width="6" stroke-linecap="round"
   stroke-linejoin="round" fill="none">`. `ink`/`disc` come from the sign's
   **element**, not from the sign: `fire #FF9576 / rgba(255,149,118,.16)`,
   `earth #5FD3BC / rgba(95,211,188,.16)`, `air #B78CF5 /
   rgba(183,140,245,.18)`, `water #FF7FB6 / rgba(255,127,182,.16)`. The
   component's `color` and `flat` props are never used by the web page — do not
   port them.
2. **`SiteLayout` already accepts `title` (optional, default `'Cupid'`) and
   renders `<title>{title}</title>`** (`web/src/layouts/SiteLayout.astro:13,17,25`).
   AC-9 therefore needs **no shell change** — it is an unused prop, not a
   missing one. Every one of the 8 existing route files currently omits it,
   which is exactly what DEF-2 reported.
3. **A bilingual `<title>` cannot use the site's language mechanism.** The whole
   site switches language with CSS (`body[data-lang]` showing/hiding
   `data-vi`/`data-en` spans); CSS cannot render inside `<title>`, and
   `SiteHeader`'s `setLang` (`SiteHeader.astro:139-146`) sets
   `body.dataset.lang` without dispatching an event. So a language-aware title
   requires JS, and the only conflict-free place for it is the page body.

## 3. Scope And Assumptions

- In Scope: `web/src/data/zodiac.ts`, `web/src/components/sprites/ZodiacIcon.astro`,
  `web/src/components/zodiac/*`, and the body of `web/src/pages/zodiac.astro`.
- Out Of Scope: every shell file, `web/package.json`, `web/astro.config.*`, the
  other 7 route bodies, and the requirement-level visual audit run itself.
- Assumptions affecting design:
  - Node >= 22.12.0 is required by `astro@6.0.5`; the machine default is
    v20.20.2 (runtime registry `web-frontend.engines.note`). An implementer who
    runs bare `npm run build` on ambient node gets an engine failure that looks
    like a code failure.
  - `cupid-app-design-system/` is design reference, never application source —
    nothing under it is imported, bundled, or copied wholesale.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `web` (runtime registry id `web-frontend`).
- New or changed boundaries: none. This story adds leaves under an existing
  boundary; the shell/page contract is unchanged and unextended.
- Shared patterns reused or introduced:
  - Reused: `SiteLayout` slot contract, `data-vi`/`data-en` span pairs, token
    reads, verbatim inline `style="…"` attributes with hover rules hoisted into
    the owning component's scoped `<style>`.
  - Introduced (page-local, deliberately not shell-lifted yet): the
    **`data-title-*` title-sync pattern** in section "Per-page title" below.

### Affected Modules

- Frontend: `web/src/data`, `web/src/components/sprites`,
  `web/src/components/zodiac`, `web/src/pages`.

### Per-page title (AC-9)

`zodiac.astro` defines one const pair and uses it twice, so the two strings
cannot drift:

- Server-rendered baseline: pass `title={TITLE.vi}` to `SiteLayout`. `<body>` is
  server-rendered `data-lang="vi"`, so the served HTML is already correct and
  **AC-9 passes with JavaScript disabled**.
- Language sync: the page's own root element carries `data-title-vi` /
  `data-title-en`; a page-local `is:inline` script sets `document.title` from
  `document.body.dataset.lang` on load and re-runs from a `MutationObserver`
  watching `attributeFilter: ['data-lang']` on `document.body`.
- Copy: `Hoàng đạo — Cupid` / `Zodiac — Cupid` — the `zodiac` nav item's own
  verbatim `vi`/`en` labels (`web/src/data/site-nav.ts:32`) plus the header
  wordmark, so no unsourced marketing copy is invented (UX §6.3).
- Why not in the shell, where it belongs long-term: `setLang` is the correct
  single home for this, but 7 sibling page stories are editing `web/` in
  parallel worktrees right now, and a shell edit here both guarantees a merge
  conflict and silently re-renders the other 7 pages, invalidating their
  fidelity evidence (STORY-001 contract §6). Recorded as a requirement-level
  follow-up: lift `data-title-*` into `SiteLayout` + `setLang` once, in a
  shell-owning story, after REQ-006's page stories have merged.

### Contracts And Integrations

- Error, retry, timeout, idempotency, and empty-state contract: none exist.
  Every value is a compile-time constant, so there is no loading, empty, or
  error state to design — and correspondingly no place to hide one.
- Compatibility or versioning posture: additive only; no existing export,
  route, prop, or token changes signature.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Zodiac glyph fidelity | `cupid-app-design-system/Zodiac Icon.dc.html` (12 `sc-if` branches, `SIGNS`/`EL` maps at `:104-125`) | Port all 12 branches into one component keyed by `sign`; derive `ink`/`disc` from the sign's element via the `EL` map, never per-sign | `npm run check` + rendered inspection that each of the 12 grid cards shows a distinct glyph whose stroke colour matches its element group | Report `DESIGN_SOURCE_UNREADABLE` with the exact line range; do not invent glyph paths |
| Fixed-count sections (AC-4/5/6) | requirements AC-4/5/6; UX §6.2.3/6.2.4/6.2.5 | Type the arrays in `zodiac.ts` as fixed-length `as const` tuples (12 / 4 / 6) so a drifted count is a **type error**, not a visual defect | `npm run check` passes AND `web/dist/zodiac/index.html` yields exactly 12 sign cards, 4 element cards, 6 leaderboard rows | Report `BUILD_GATE_UNAVAILABLE` with the failing command and its stderr |
| Bilingual span completeness | STORY-001 contract §3 | Every user-visible string ships **both** `data-vi` and `data-en` spans; VI/EN copied verbatim from the design source (BR-2) | `web/dist/zodiac/index.html` contains equal counts of `data-vi` and `data-en` spans, and the page has no bare text node outside a span pair | Same as above |
| Shell immutability under parallel merge | STORY-001 `architecture/contract-summary.md` §6 | Shell files are excluded from every phase `Write Scope`; a needed shell change is escalated to Tech Lead, not made locally | `git -C <Worktree> diff --name-only <BaseHead>` lists no file under `web/src/{layouts,components/shell,styles,scripts,data/site-nav.ts}` and no `web/package.json` | Report `SHELL_CHANGE_REQUIRED` naming the file and the reason; stop |
| Per-page `<title>` (AC-9, DEF-2) | requirements AC-9; UX §6.3 | Static VI title via the existing `SiteLayout` `title` prop (works with JS off) + page-local `data-title-*` sync script | `web/dist/zodiac/index.html` `<title>` is `Hoàng đạo — Cupid`, not `Cupid` | Same as build gate above |
| Rendered visual fidelity (AC-10) | `Cupid Web.dc.html:285-384`; req_master "giống 100%" bar | Copy layout/spacing/typography values verbatim per UX §6.7; introduce no token and no colour the token set lacks | Requirement-level `frontend-dev` `Mode: requirement-visual-audit`, run **once for REQ-006**, not per story | `render-design-canvas.js` is **not present in this worktree** and no `design-reference-zodiac-*.png` exists (UX §7 item 1). Report `DESIGN_REFERENCE_MISSING` at the requirement gate — it does not block this story's implementation |

### Frontend Lane

- Responsibilities: all seven source files listed in section 3, across P1 and P2.
- Authoritative inputs: `ux/uiux-spec.md` §6.2 (every measurement, colour, and
  VI/EN string, already extracted verbatim), `Cupid Web.dc.html:285-384`,
  `Zodiac Icon.dc.html`, STORY-001 `architecture/contract-summary.md`.
- Guardrails:
  - Do not modify any shell file, `web/package.json`, or `web/astro.config.*`.
  - Do not add a `<progress>`, `<meter>`, `<button>`, `<a>`, `<input>`, or any
    `tabindex` inside the five sections — this page has zero interactive
    controls of its own (UX §6.5), and adding a focusable wrapper is a
    regression, not a courtesy.
  - Do not add or rename a design token. A needed colour that the token set
    lacks is a finding to report (contract §4).
  - Do not normalise copy: the date-range separator is `" – "` (space, en-dash,
    space) and the pair separator is `×` (U+00D7), not `x`.
  - Element-card icons have no visible label; give those a meaningful `alt`.
    All other sign icons sit beside visible text and must be `aria-hidden`.
  - The ring's conic-gradient stop and the number in its inner disc must both
    derive from the same `zodiac.ts` value — never two hardcoded `92`s.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Page-local `data-title-*` + `MutationObserver`, static VI title via existing `SiteLayout` prop | Satisfies AC-9 with JS off and UX §6.3 with JS on, touching only files this story owns | ACCEPTED | Pattern is deliberately shaped so it lifts into `setLang` unchanged later |
| Extend `SiteLayout`/`setLang` to own bilingual titles now | The correct single home for the behaviour | REJECTED | 7 sibling stories are editing `web/` in parallel worktrees; the edit conflicts on merge and re-renders 7 pages whose fidelity evidence was already captured |
