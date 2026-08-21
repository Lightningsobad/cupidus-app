# Phase P1 – About Core Sections And Page Entry Point

## 1. Objective

Turn the empty `/about` route into a rendering page: the shared content data
module, the first four sections (mission, principles, stats, "Why a pet?"), and
the page's own `<title>`. After this phase the header "About" nav item and the
footer "Press kit" link land on real content instead of an empty shell.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-about-core-sections.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `web/src/data/about-content.ts`
  - `web/src/components/about/AboutMission.astro`
  - `web/src/components/about/PrincipleGrid.astro`
  - `web/src/components/about/StatCounters.astro`
  - `web/src/components/about/WhyPetCallout.astro`
  - `web/src/pages/about.astro`
- Impacted Runtime Service/App:
  - Name: `web`
  - Runtime Registry Id: `web-frontend`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: frontend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (`npm run build`)
  - Port Contract: per-project loopback host binding (`DEVSTACK_PORT_WEB`)
- Shared Interfaces Consumed:
  - `../../STORY-001/architecture/contract-summary.md` — `SiteLayout` `page`
    prop, `data-vi`/`data-en` bilingual spans, `tokens.css` custom properties
- Risk Surfaces:
  - VI/EN copy fidelity (AC-11)
  - Shell immutability (contract-summary §6)
  - Per-page title (AC-9)
  - Build/type integrity on pinned Node
  - About page visual fidelity (AC-10) — partial; the full-page gate runs after P2
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §6.2.1–§6.2.4 and
    §6.8 for every value; `cupid-app-design-system/Cupid Web.dc.html:512-543`,
    `:800-805` for the literal strings
  - consumer contract: none produced
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-1..AC-5, AC-9, AC-11
  - architecture: `../architecture/solution.md` sections 1, 4
  - UX constraints, if truly required: `../ux/uiux-spec.md` §6.2.1–§6.2.4, §6.6,
    §6.8, §6.9 — required, these carry the exact style values and copy
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: page scaffold + the four content-block sections above the
    timeline
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md` §6.2.1–§6.2.4, §6.6, §6.8, §6.9
- `../../STORY-001/architecture/contract-summary.md`

## 3. Tasks

- Create `web/src/data/about-content.ts` following the existing
  `web/src/data/home-content.ts` convention (exported interfaces + exported const
  arrays, bilingual fields named `tvi`/`ten`/`dvi`/`den`). Populate `principles`
  (4), `stats` (3), `timeline` (5), `team` (3), and `palette` (8) in this phase —
  P2 consumes the last three without re-opening this file.
  - `stats` entries carry the big number as a single unlocalized `value` field,
    not as a `tvi`/`ten` pair (uiux-spec §6.2.3 flag).
  - `palette` entries carry `hex` and an unlocalized `name`.
- Rewrite `web/src/pages/about.astro`: keep `<SiteLayout page="about" …>`, add
  `title="Giới thiệu & Bộ nhận diện thương hiệu — Cupid"`, and slot a single
  container `<div>` with `max-width:1200px; margin:0 auto; padding:70px 32px 90px`.
  Do not add a second `<main>` — the shell already renders one.
- Build `AboutMission.astro` (§6.2.1), `PrincipleGrid.astro` (§6.2.2),
  `StatCounters.astro` (§6.2.3), `WhyPetCallout.astro` (§6.2.4) and mount them in
  that order. Copy the inline `style="..."` values verbatim from the spec.
- Every localized string ships both a `data-vi` and a `data-en` span. The three
  stat numbers ship as plain unwrapped text and stay identical in EN.

## 4. Acceptance Criteria

- `/about` renders the eyebrow, H1 and subcopy (AC-2), exactly 4 principle cards
  (AC-3), exactly 3 stat cards (AC-4), and the callout (AC-5), each matching the
  spec's cited values.
- The built `web/dist/about/index.html` `<title>` is the story-specific VI string
  above and is not the `'Cupid'` default (AC-9).
- Every localized string on these four sections has both `data-vi` and `data-en`;
  `48.000+`, `31.500`, `2,1 triệu` have neither (AC-11).
- No file under `web/src/layouts/`, `web/src/components/shell/`,
  `web/src/styles/`, or `web/src/scripts/` is modified.
- No hover-lift is added to the principle or stat cards.

## 5. Planned Outputs

- Code directories or files: the six paths in `1B. Write Scope`.
- Notes or evidence: `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: static web (`web-frontend`), Astro build output
- Required levels (omit N/A levels):
  - frontend build/type-check: `npm run check` and `npm run build` from `web/`
  - visual inspection: rendered `/about` at dark×vi, dark×en, light×vi, light×en
    and at 375/768/1024/1440px, limited to the four sections this phase ships
- Required checks:
  - Node version used for the two commands is >=22.12.0 (registry
    `web-frontend.engines`); a run on ambient v20.20.2 is not valid evidence.
  - `<title>` assertion on `web/dist/about/index.html`.
  - Bilingual-span assertion, including the three unwrapped stat numbers.
  - `git -C <worktree> diff --stat <BaseHead>` shows no shell file changed.
- Frontend discoverability / navigation integration: reach `/about` through the
  header "About" nav item and the footer "Press kit" link, and by direct URL —
  all three must render the new body and the "About" pill must show its active
  state (AC-1).
- Minimum gates by risk surface: see `../architecture/solution.md` section 4.
- Evidence format: append a dated block to `coding-plan/test-results.md` with the
  exact commands, the Node version, exit codes, and the four theme×language
  observations.
- Requirement frontend visual audit: YES — this phase's sections feed AC-10; the
  full-page fidelity verdict is issued at the requirement UI-lane review gate
  with `design_source` and `ui_surface` configured, not here.
- Verification strategy:
  - Build/type-check/lint command when required: `npm run check`, `npm run build`
  - Required assertion evidence: title string, span presence/absence counts,
    card counts (4 principles, 3 stats), shell diff empty

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-21
