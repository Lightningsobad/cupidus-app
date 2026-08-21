# Phase P1 – Zodiac data module, sign icon, and sign-directory sections

## 1. Objective

Establish the single static data source for the whole Zodiac page, port the
12-branch `Zodiac Icon` art component from the design system, and build the two
sections that are pure consumers of both: the 12-sign grid (AC-4) and the
4-element grouping (AC-5).

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-zodiac-data-icon-and-sign-directory.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `web/src/data/zodiac.ts`
  - `web/src/components/sprites/ZodiacIcon.astro`
  - `web/src/components/zodiac/TwelveSignsGrid.astro`
  - `web/src/components/zodiac/FourElementsGrid.astro`
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
  - `web/src/data/zodiac.ts` — all static page content for STORY-003
  - `web/src/components/sprites/ZodiacIcon.astro` — `sign` + `size` props
- Shared Interfaces Consumed:
  - STORY-001 `architecture/contract-summary.md` §3 (bilingual spans) and §4
    (design tokens, `components/sprites/` convention)
- Risk Surfaces:
  - Zodiac glyph fidelity
  - Fixed-count sections (AC-4/5/6)
  - Bilingual span completeness
  - Shell immutability under parallel merge
- Source Of Truth:
  - authoritative artifact or convention:
    `cupid-app-design-system/Zodiac Icon.dc.html` for glyph geometry and the
    `SIGNS`/`EL` maps; `Cupid Web.dc.html:322-350, 763-776` for the sections and
    the `zodiac` array; `../ux/uiux-spec.md` §6.2.3 and §6.2.4 for every
    measurement and both language strings, already extracted verbatim.
  - consumer contract: P2 imports both files; do not rename an export after P2
    starts.
- Primary Inputs Summary:
  - requirements: AC-4, AC-5, AC-7, AC-8, BR-1, BR-2
  - architecture: `../architecture/solution.md` §1 Key Discovery item 1,
    §4 Risk Surfaces, §4 Frontend Lane guardrails
  - upstream phase outputs: none
  - UX constraints: `../ux/uiux-spec.md` §6.2.3, §6.2.4, §6.5, §6.7
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO

- Phase Sizing:
  - Behavior Slice: static content model + the sign-icon art + its two direct
    directory-style consumers
  - Source/Test File Count: 4
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md` §6.2.3, §6.2.4, §6.5, §6.7
- `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-001/architecture/contract-summary.md`

## 3. Tasks

1. Create `web/src/data/zodiac.ts` holding every static value the page renders,
   typed with `as const` fixed-length tuples so a drifted count fails
   `astro check` rather than silently rendering the wrong number of cards:
   - `SIGNS`: exactly 12 entries in source order, each `{ key, element, vi, en,
     dates }`. Keys and VI/EN names come from `Zodiac Icon.dc.html:104-118`;
     date ranges from `../ux/uiux-spec.md` §6.2.3 (aries `21.3 – 19.4` through
     pisces `19.2 – 20.3`). The separator is `" – "` — space, EN DASH (U+2013),
     space. Do not normalise it to a hyphen.
   - `ELEMENTS`: exactly 4 entries `{ element, vi, en, labelColor, signs }`
     with `signs` as a 3-key tuple — fire/`var(--acc-peach)`/aries,leo,
     sagittarius; earth/`var(--acc-butter)`/taurus,virgo,capricorn;
     air/`var(--acc-lilac)`/gemini,libra,aquarius;
     water/`var(--acc-mint)`/cancer,scorpio,pisces.
   - Also add, for P2 to consume: `DAILY_READ` (the two sign keys, the `92`
     score as a **number**, the three metric rows, and the VI/EN nudge copy) and
     `IN_SYNC_PAIRS` (exactly 6 entries, VI/EN pair label + number). Values are
     in `../ux/uiux-spec.md` §6.2.2 and §6.2.5.
2. Create `web/src/components/sprites/ZodiacIcon.astro`, following the existing
   `BoSprite.astro` porting convention (frontmatter comment naming the source
   file and line range, `interface Props`, defaulted size):
   - Props: `sign: ZodiacKey` and `size?: number` (default 54). Do **not** port
     the design component's `color` or `flat` props — the web page never passes
     them.
   - Render one `<svg viewBox="0 0 100 100">` containing
     `<circle cx="50" cy="50" r="48" fill={disc} />` followed by exactly one of
     the 12 glyph groups, selected by `sign`.
   - `ink` and `disc` are derived from the sign's **element**, not from the
     sign: fire `#FF9576` / `rgba(255,149,118,.16)`, earth `#5FD3BC` /
     `rgba(95,211,188,.16)`, air `#B78CF5` / `rgba(183,140,245,.18)`, water
     `#FF7FB6` / `rgba(255,127,182,.16)` (`Zodiac Icon.dc.html:120-125`).
   - Every glyph group keeps `stroke={ink} stroke-width="6"
     stroke-linecap="round" stroke-linejoin="round" fill="none"`. Copy all 12
     `sc-if` branch bodies verbatim from `Zodiac Icon.dc.html:14-~100`; do not
     redraw, simplify, or merge paths.
   - Accessibility is decided by the caller: accept an optional `label?: string`
     and render `role="img"` + `aria-label` when it is given, otherwise
     `aria-hidden="true"` and no accessible name.
   - Namespace any SVG `id` as `cupid-zodiac-*` if one is needed, per the
     `BoSprite.astro` precedent (12 instances of this component appear on one
     page, so a bare id would collide).
3. Create `web/src/components/zodiac/TwelveSignsGrid.astro` (AC-4): H2 +
   `auto-fit`/`minmax(150px,1fr)` grid mapping over all 12 `SIGNS` entries.
   Card anatomy, spacing, and typography exactly per `../ux/uiux-spec.md`
   §6.2.3. The hover `border-color:rgba(255,201,126,.4)` becomes one scoped
   `:hover` rule in this component's own `<style>` block. Icons here sit beside
   a visible name, so pass no `label` (they render `aria-hidden`).
4. Create `web/src/components/zodiac/FourElementsGrid.astro` (AC-5): H2 +
   `auto-fit`/`minmax(min(230px,100%),1fr)` grid over all 4 `ELEMENTS` entries,
   each with its label row and three 46x46 icons and **no** name/date text.
   These icons have no visible text fallback, so each one must receive a
   `label` (the sign's name) — this is the one accessibility gap the raw design
   source does not close (`../ux/uiux-spec.md` §6.5).
5. Give every user-visible string in both components a `data-vi` **and** a
   `data-en` span. A string with only one of the two silently renders blank in
   the other language, with no build error.

## 4. Acceptance Criteria

- `web/src/data/zodiac.ts` exports 12 signs, 4 elements, 6 pairs, and the daily
  read, all as fixed-length `as const` tuples; changing a count breaks
  `npm run check`.
- `ZodiacIcon.astro` renders a visually distinct glyph for each of the 12 sign
  keys, with stroke and disc colours matching the sign's element group.
- `TwelveSignsGrid.astro` renders exactly 12 cards with icon, VI+EN name, and
  date range; `FourElementsGrid.astro` renders exactly 4 cards with 3 labelled
  icons each.
- No file outside this phase's Write Scope is modified.
- `npm run check` and `npm run build` both pass from `web/`.

## 5. Planned Outputs

- Code directories or files: the four files in Write Scope
- Notes or evidence: `../coding-plan/test-results.md` entry for P1

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: web (`web/`, Astro static build)
- Required levels:
  - frontend build/type-check: `npm run check` then `npm run build`, run from
    `web/` on Node >= 22.12.0
  - visual inspection: confirm the 12 glyphs are distinct and element-coloured
- Required checks:
  - `npm run check` exits 0 (`astro build` alone does **not** type-check)
  - `npm run build` exits 0
  - No new entry in `web/package.json` dependencies or devDependencies
- Minimum gates by risk surface:
  - Zodiac glyph fidelity: all 12 branches present, each keyed to its own sign
  - Fixed-count sections: type-level tuple lengths 12 and 4
  - Bilingual span completeness: both components emit paired `data-vi` /
    `data-en` spans for every visible string
  - Shell immutability: `git -C <Worktree> diff --name-only <BaseHead>` lists
    only this phase's four files
- Evidence format: exact commands, exit codes, and the `git diff --name-only`
  output pasted into `../coding-plan/test-results.md`
- Verification strategy:
  - Build/type-check command when required: `npm run check` and `npm run build`
  - Required assertion evidence: the file list from `git diff --name-only`
- Requirement frontend visual audit: deferred to the requirement-level
  `frontend-dev` `Mode: requirement-visual-audit` gate (AC-10); not run here

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-21
