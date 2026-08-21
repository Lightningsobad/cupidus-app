# Phase P5 – Home Page Body

## 1. Objective

The complete Home page body — hero with phone mockup, features grid, pet-cast
teaser, and "How it works" — rendered inside the shell and visually identical to
the design source's `isHome` state. This phase carries UI-Fidelity-AC-6.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-home-page-body.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: P3, P4
- Parallelizable: NO
- Write Scope:
  - `web/src/components/home/Hero.astro`
  - `web/src/components/home/FeatureGrid.astro`
  - `web/src/components/home/PetCast.astro`
  - `web/src/components/home/HowItWorks.astro`
  - `web/src/data/home-content.ts`
  - `web/src/pages/index.astro`
- Impacted Runtime Service/App:
  - Name: `web-frontend`
  - Runtime Registry Id: `web-frontend` (created by P6)
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: frontend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `devCommand`
  - Readiness Check: N/A
  - Port Contract: per-project loopback host binding
- Shared Interfaces Produced:
  - `FeatureGrid` card pattern, reusable by later page stories
    (`../ux/uiux-spec.md` §6.5)
- Shared Interfaces Consumed:
  - `SiteLayout` (P2), the six sprite components (P4), `tokens.css` (P1)
- Risk Surfaces:
  - Inline-style fidelity
  - Hover-state fidelity
- Source Of Truth:
  - authoritative artifact: `cupid-app-design-system/Cupid Web.dc.html` lines
    79–211 (markup) and 734–754 (feature, pet, and step content arrays)
  - consumer contract: `../architecture/contract-summary.md` §3 (bilingual
    spans), §4 (tokens and sprites)
- Primary Inputs Summary:
  - requirements: UI-Fidelity-AC-6, AC-7
  - architecture: `../architecture/solution.md` §4 Fidelity Baseline, §4
    Frontend Lane guardrails
  - OQ constraints: OQ-REQ006-2 resolved — the stat counters are static
    marketing numbers, not live data; no fetch
  - upstream phase outputs: P3 `index.astro` route, P4 sprites
  - UX constraints: `../ux/uiux-spec.md` §6.2 (all four sections), §6.8
    (measurable visual rules)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one page body — four sections of the same `isHome` render
  - Source/Test File Count: 6
  - Split Required: NO
  - Split Rationale: the four sections are one continuous page render sharing
    one content module and one route file; splitting them would separate phases
    that write the same files without adding a behavior boundary.

## 2. Required Reads

- `../requirements/requirements.md` (UI-Fidelity-AC-6, AC-7)
- `../architecture/solution.md` §4 Fidelity Baseline and Frontend Lane
- `../architecture/contract-summary.md` §3, §4
- `../ux/uiux-spec.md` §6.2, §6.8
- `cupid-app-design-system/Cupid Web.dc.html` lines 79–211 and 734–754

## 3. Tasks

- Port all four sections in the source's order: hero (79–140), features grid
  (142–152), pet-cast teaser (154–194), how-it-works (196–210). All four are one
  continuous `isHome` render; shipping only "hero and features grid" would miss
  half the page (see `../ux/uiux-spec.md` §6.2 preamble).
- Copy every `style="..."` attribute verbatim. Do not consolidate repeated
  values into classes, do not round or normalize numbers, and do not substitute
  a shorthand.
- Build the hero phone mockup inline in `Hero.astro` — it is hero-exclusive
  decoration, not a reusable component. Use `BoSprite` from P4 for its pet.
- Move the `features`, `pets`, and `steps` arrays from source lines 734–754 into
  `home-content.ts` with the VI and EN strings copied character-for-character,
  including quotes, em dashes, and the `"sao thế?"` inner quotes. Do not
  paraphrase, re-translate, or normalize punctuation.
- Render every string as the paired `data-vi` / `data-en` spans described in
  `../architecture/contract-summary.md` §3. A string with only one span
  disappears silently in the other language.
- The App Store and Google Play badge labels ("Download on the" / "App Store",
  "Get it on" / "Google Play") are not localized in the source — ship them
  identically in both languages.
- The three stat counters (6 pets, 12 zodiac signs, 0₫ to start) are static
  literals. Do not animate, compute, or fetch them.
- The pet-cast "Xem tất cả" / "Meet them all" CTA links to `/pets`, and the
  header CTA behavior is unchanged from P2. Both must resolve.
- Convert each `style-hover` in this range into one scoped `:hover` rule
  (feature-card lift, pet-card lift, download-badge hover, CTA hover).
- Keep the hero, features, pet-cast, and steps grids as fluid
  `auto-fit`/`minmax` grids exactly as the source writes them. Do not add
  breakpoint overrides — the only named breakpoint in this design is the
  1024/1025 nav swap.

## 4. Acceptance Criteria

- The Home page at the Fidelity Baseline (1440×900, dark, VI) is visually
  identical to the design source's `isHome` state across all four sections.
- The same holds at 1440×900 in light × EN.
- At 375, 768, 1024, 1025, and 1440 no grid column drops below its `minmax`
  floor (420px hero halves, 260px feature cards, 170px pet cards, 230px step
  cells), and the download badges and stat counters stay above the decorative
  phone mockup in source order on narrow viewports.
- Every VI and EN string on the page matches the design source character for
  character.
- Every hover state in this range matches the source.
- No network request originates from the Home page beyond the two Google Fonts
  stylesheets.

## 5. Planned Outputs

- Code directories or files: the six paths in `## 1B Write Scope`.
- Notes or evidence: Home capture pairs at every listed viewport and the
  copy-fidelity diff, in `test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: web (static build, browser render)
- Required levels:
  - frontend build/type-check: `cd web && npm run build` and `npx astro check`
  - visual inspection: per-section capture pair (design vs built app) at the
    Fidelity Baseline; full-page pair at 1440×900 in dark/VI and light/EN;
    single-side app captures at 375, 768, 1024, 1025
- Required checks:
  - copy-fidelity diff: extract every VI and EN string from `home-content.ts`
    and the four components and diff against source lines 734–754 and the
    inline strings in 79–211
  - paired-span check: every user-visible string has both a `data-vi` and a
    `data-en` span
  - network check: the built page issues no `fetch`/XHR; grep the `web/src`
    tree for `fetch(` and confirm none
  - link check: the pet-cast CTA resolves to `/pets`
- Frontend discoverability / navigation integration: Home is `/`, already
  mounted in the shell and linked from the header logo, the header "Home" nav
  item, and the footer Product column by P2/P3. This phase adds page body only.
- Minimum gates by risk surface:
  - Inline-style fidelity: all section capture pairs match at the Fidelity
    Baseline
  - Hover-state fidelity: each hover state captured and matching
- Required runtime signals: browser console clean; no network entries beyond
  the two font stylesheets
- Evidence format: capture pairs, the copy-fidelity diff, and command output in
  `coding-plan/test-results.md`
- Requirement frontend visual audit: this phase's captures are the story-level
  evidence; the requirement-level `frontend-dev` `Mode:
  requirement-visual-audit` runs separately before REQ-006 is marked DONE.
- Verification strategy:
  - Build/type-check command: `cd web && npm run build && npx astro check`
  - Required assertion evidence: the capture pairs and the copy-fidelity diff

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-21
