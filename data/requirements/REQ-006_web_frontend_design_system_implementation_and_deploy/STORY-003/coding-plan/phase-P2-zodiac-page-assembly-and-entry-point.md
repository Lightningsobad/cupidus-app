# Phase P2 – Zodiac page assembly, entry point, and per-page title

## 1. Objective

Build the daily compatibility card and the in-sync leaderboard, then assemble
all five sections into the existing `/zodiac` route body so the page is reachable
through the header/footer nav STORY-001 already wired, and give it its own
`<title>` (AC-9 / DEF-2).

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-zodiac-page-assembly-and-entry-point.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `web/src/components/zodiac/DailyCompatibilityCard.astro`
  - `web/src/components/zodiac/InSyncLeaderboard.astro`
  - `web/src/pages/zodiac.astro`
- Impacted Runtime Service/App:
  - Name: `web`
  - Runtime Registry Id: `web-frontend`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: frontend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (`npm run build`) and
    `checkCommand` (`npm run check`), run from `web/` on Node >= 22.12.0
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - none consumed inside this story
- Shared Interfaces Consumed:
  - P1's `web/src/data/zodiac.ts` (`DAILY_READ`, `IN_SYNC_PAIRS`, `SIGNS`) and
    `web/src/components/sprites/ZodiacIcon.astro`
  - STORY-001 `architecture/contract-summary.md` §1 (`SiteLayout` slot + `page`
    prop) and §3 (bilingual spans)
- Risk Surfaces:
  - Fixed-count sections (AC-4/5/6)
  - Bilingual span completeness
  - Shell immutability under parallel merge
  - Per-page `<title>` (AC-9, DEF-2)
  - Rendered visual fidelity (AC-10)
- Source Of Truth:
  - authoritative artifact or convention: `Cupid Web.dc.html:285-320, 351-383`;
    `../ux/uiux-spec.md` §6.2.1, §6.2.2, §6.2.5, §6.3
  - consumer contract: none downstream in this story
- Primary Inputs Summary:
  - requirements: AC-1, AC-2, AC-3, AC-6, AC-7, AC-8, AC-9, AC-10, BR-1, BR-2
  - architecture: `../architecture/solution.md` §1 Key Discovery items 2 and 3,
    §4 "Per-page title (AC-9)", §4 Risk Surfaces, §4 Frontend Lane guardrails
  - upstream phase outputs: P1's data module and `ZodiacIcon.astro`
  - UX constraints: `../ux/uiux-spec.md` §6.2.1, §6.2.2, §6.2.5, §6.3, §6.5,
    §6.7
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: the two score-visualisation sections plus route assembly,
    entry-point wiring, and page title
  - Source/Test File Count: 3
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md` §6.2.1, §6.2.2, §6.2.5, §6.3, §6.5, §6.7
- P1 outputs: `web/src/data/zodiac.ts`, `web/src/components/sprites/ZodiacIcon.astro`

## 3. Tasks

1. Create `web/src/components/zodiac/DailyCompatibilityCard.astro` (AC-3), a
   two-column `auto-fit`/`minmax(min(300px,100%),1fr)` grid per
   `../ux/uiux-spec.md` §6.2.2:
   - Left cell: `ZodiacIcon` for both `DAILY_READ` sign keys at 86px with their
     VI/EN names below, and the percentage ring between them. The ring is a
     104x104 circle whose `conic-gradient` stop is **computed from
     `DAILY_READ.score`** (`conic-gradient(#FFC97E 0% ${score}%, var(--c1)
     ${score}% 100%)`), with an 82x82 `var(--screen)` inner disc rendering
     `${score}%` as real DOM text. One value, two derived outputs — never two
     hardcoded `92`s (`../architecture/solution.md` §4 Frontend Lane).
   - Right cell: the three metric rows (Communication 88 / Understanding 94 /
     Energy 71) with each row's percentage text colour and bar fill colour taken
     from the data entry, then the "today's nudge" inset panel.
   - Sign icons here sit beside visible names: pass no `label`.
2. Create `web/src/components/zodiac/InSyncLeaderboard.astro` (AC-6): the card
   title plus exactly 6 rows from `IN_SYNC_PAIRS`, each with a `flex:1` pair
   label, a fixed `120px x 6px` track whose fill width is the row's percentage
   and whose gradient is the same `linear-gradient(90deg,#FF7FB6,#B78CF5)` for
   every row, and a right-aligned `38px` Roboto Mono value. Every row carries
   `border-top:1px solid var(--c08)`, including the first. The pair separator is
   `×` (U+00D7), not a lowercase `x`.
3. Replace the body of `web/src/pages/zodiac.astro`, keeping
   `<SiteLayout page="zodiac">` and adding nothing to the shell:
   - Define one `TITLE = { vi: 'Hoàng đạo — Cupid', en: 'Zodiac — Cupid' }`
     const and pass `title={TITLE.vi}` to `SiteLayout`, so the served HTML
     carries the correct title with JavaScript disabled.
   - Inside the slot, render the page container
     (`max-width:1200px;margin:0 auto;padding:70px 32px 90px`) carrying
     `data-title-vi={TITLE.vi}` and `data-title-en={TITLE.en}`, then the hero
     (inline here, it is three elements — do not create a component for it),
     `DailyCompatibilityCard`, `TwelveSignsGrid`, `FourElementsGrid`,
     `InSyncLeaderboard` in that order.
   - Add the page-local `is:inline` title-sync script at the end of the slot: it
     reads `document.body.dataset.lang`, sets `document.title` from the matching
     `data-title-*` attribute, and re-runs from a `MutationObserver` on
     `document.body` with `attributeFilter: ['data-lang']`. `setLang` dispatches
     no event, so the observer is the only hook available
     (`../architecture/solution.md` §1 Key Discovery item 3).
   - The hero H1 is plain text at Nunito 900 52px — it has no gradient span,
     unlike the Home hero. Adding one is a fidelity deviation.
4. Do not add any `<a>`, `<button>`, `<input>`, `<progress>`, `<meter>`, or
   `tabindex` inside the five sections. This page has no interactive controls of
   its own; the only focusable elements on the route stay the shell's.
5. Verify AC-1 against the build output rather than by adding anything: the
   header nav item and footer link for `/zodiac` already exist in
   `web/src/data/site-nav.ts` and are rendered by the shell. Confirm the built
   page is reachable from them and shows the active-pill state.

## 4. Acceptance Criteria

- `web/dist/zodiac/index.html` exists and contains all five sections in source
  order: hero, daily card, 12-sign grid, 4-element grouping, 6-row leaderboard.
- Its `<title>` is `Hoàng đạo — Cupid`, not the shell default `Cupid` (AC-9).
- The ring's `conic-gradient` stop percentage equals the number rendered in its
  inner disc.
- Exactly 6 leaderboard rows, each with the `×` separator and its own bar width.
- The built page's header nav renders the `/zodiac` link with the active state,
  and the mobile `<select>` has a `/zodiac` option (AC-1).
- No shell file, `web/package.json`, or `web/astro.config.*` is modified.
- `npm run check` and `npm run build` both pass from `web/`.

## 5. Planned Outputs

- Code directories or files: the three files in Write Scope
- Notes or evidence: `../coding-plan/test-results.md` entry for P2

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: web (`web/`, Astro static build)
- Required levels:
  - frontend build/type-check: `npm run check` then `npm run build`, run from
    `web/` on Node >= 22.12.0
  - visual inspection: the five sections in order, in both themes and both
    languages, at 375 / 768 / 1024 / 1440 widths
- Required checks (assert against `web/dist/zodiac/index.html`, no new tooling):
  - `<title>` is `Hoàng đạo — Cupid`
  - exactly 12 sign cards, exactly 4 element cards, exactly 6 leaderboard rows
  - equal counts of `data-vi` and `data-en` spans
  - the `conic-gradient` stop percentage matches the inner-disc text
  - no `<a`, `<button`, `<input`, `<progress`, `<meter`, or `tabindex` inside
    the page container element
- Frontend discoverability / navigation integration: the built page is reached
  through the existing header nav pill and mobile `<select>` option for
  `/zodiac`; direct-URL-only access is not sufficient evidence for AC-1.
- Minimum gates by risk surface:
  - Per-page `<title>`: the dist assertion above, plus confirming the title
    still reads correctly with JavaScript disabled
  - Fixed-count sections: the 12 / 4 / 6 dist counts
  - Bilingual span completeness: the paired-span count assertion, plus a manual
    EN toggle showing no blank strings
  - Shell immutability: `git -C <Worktree> diff --name-only <BaseHead>` lists
    only this story's seven files
- Required runtime signals: browser console clean on the rendered page (the
  title-sync script is the only page JS)
- Evidence format: exact commands, exit codes, assertion output, and the
  `git diff --name-only` file list pasted into `../coding-plan/test-results.md`
- Verification strategy:
  - Build/type-check command when required: `npm run check` and `npm run build`
  - Required assertion evidence: the dist assertions listed above
- Requirement frontend visual audit: YES — AC-10 is verified once for REQ-006 at
  the requirement-level `frontend-dev` `Mode: requirement-visual-audit` gate, not
  inside this phase. `render-design-canvas.js` is not present in this worktree
  and no `design-reference-zodiac-*.png` exists yet; if that is still true at the
  gate, report `DESIGN_REFERENCE_MISSING` there. It does not block this phase.

## 7. Status

- Status: COMPLETE
- Last updated: 2026-08-21
- Evidence: `../coding-plan/test-results.md` "Phase P2"
- `npm run check` 0 errors / `npm run build` exit 0, on Node v22.17.1
- All dist assertions pass (title, 12/4/6 counts, 36/36 paired spans, ring
  stop == disc text, no interactive controls in the page container)
- Runtime verified in headless Chromium: nav-pill entry to `/zodiac` (AC-1),
  title sync across the language toggle and with JavaScript disabled (AC-9),
  clean console, 375/768/1024/1440 measured
- AC-10 requirement visual audit deferred to the requirement-level gate;
  `render-design-canvas.js` and `design-reference-zodiac-*.png` still absent
- One open finding for UI/UX Designer: at 375px the daily card's sign-pair row
  (86+104+86+2×22 = 320px) overflows its 233px cell and the right sign icon
  clips. Inherited verbatim from `Cupid Web.dc.html:293` (flex, no wrap); not
  fixed here. See test-results.md "Finding".
