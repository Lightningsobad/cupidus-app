# Phase P2 – Timeline, Team, And Press Kit

## 1. Objective

Complete the About page with the company timeline, the team section, and the
always-visible press-kit section, and give the "Download kit" CTA a real
downloadable target so the source's `href="#"` placeholder never ships.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-timeline-team-press-kit.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `web/src/components/about/CompanyTimeline.astro`
  - `web/src/components/about/TeamSection.astro`
  - `web/src/components/about/PressKit.astro`
  - `web/src/pages/about.astro`
  - `web/public/press-kit/` (asset bundle: `cupid-lockup-dark.svg`,
    `cupid-lockup-light.svg`, `palette.txt`, `README.txt`,
    `cupid-press-kit.zip`)
- Impacted Runtime Service/App:
  - Name: `web`
  - Runtime Registry Id: `web-frontend`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: frontend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (`npm run build`)
  - Port Contract: per-project loopback host binding (`DEVSTACK_PORT_WEB`)
- Shared Interfaces Consumed:
  - `web/src/data/about-content.ts` (`timeline`, `team`, `palette`) — produced by P1
  - `../../STORY-001/architecture/contract-summary.md` — `data-vi`/`data-en`
    spans, `tokens.css` custom properties
- Risk Surfaces:
  - About page visual fidelity (AC-10)
  - VI/EN copy fidelity (AC-11)
  - Shell immutability (contract-summary §6)
  - Press-kit download target (AC-8)
  - Build/type integrity on pinned Node
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §6.2.5–§6.2.7 and
    §6.8; `cupid-app-design-system/Cupid Web.dc.html:544-610`, `:807-812`
  - consumer contract: none produced
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-6, AC-7, AC-8, AC-10, AC-11
  - architecture: `../architecture/solution.md` sections 1, 4, 6
  - upstream phase outputs: `web/src/data/about-content.ts` from P1
  - UX constraints, if truly required: `../ux/uiux-spec.md` §6.2.5–§6.2.7, §6.5,
    §6.6, §6.8 — required, these carry the exact style values and copy
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: the three remaining page sections plus the download payload
  - Source/Test File Count: 4 source files + 1 asset bundle
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md` §6.2.5–§6.2.7, §6.5, §6.6, §6.8
- `web/src/data/about-content.ts` (P1 output)

## 3. Tasks

- `CompanyTimeline.astro` (§6.2.5): H2 plus exactly 5 entries from
  `about-content.ts`, rendered as a semantic `<ol>`/`<li>` (uiux-spec §6.6 —
  ordered chronological content), styled to match the source's flex rows. Entry 4's
  number **is** localized (`48.000` VI / `48,000` EN) — the opposite of the stat
  counters in P1. Do not normalize the two into false consistency.
- `TeamSection.astro` (§6.2.6): H2 plus exactly 3 centered cards. Avatars are
  72×72 gradient placeholders — decorative, so `aria-hidden="true"` or empty
  `alt`. Names are plain unlocalized text; role labels are localized.
- `PressKit.astro` (§6.2.7): always rendered, no toggle. Add `id="press-kit"` to
  its root section. Header row + "Download kit" pill link, then the three-item
  swatch row: dark lockup, light lockup (no border — deliberate), and the 8-swatch
  palette grid from `about-content.ts`.
  - The on-page lockups are inline markup (gradient tile + Material Symbols
    `favorite` glyph + wordmark) and are fixed-color: do NOT wire them to
    `data-theme`, and do NOT build them from the downloadable SVGs.
  - Only the headline and the CTA label are localized. `Press kit`,
    `Dark lockup`, `Light lockup`, `Palette`, and the 8 swatch names are plain
    unwrapped text in both languages.
  - CTA: `href="/press-kit/cupid-press-kit.zip"` with the `download` attribute
    and a visible focus ring. `href="#"` must not survive.
- Create `web/public/press-kit/`: two brand-lockup SVGs (a heart mark on the
  brand gradient, dark and light variants), `palette.txt` listing the 8 hex/name
  pairs, a short `README.txt` with usage terms, and `cupid-press-kit.zip`
  containing those four files. These are download payload only — they are not
  fidelity-gated and must contain nothing beyond brand marks and the palette.
- Mount the three sections into `web/src/pages/about.astro` after the P1 sections.

## 4. Acceptance Criteria

- Exactly 5 timeline entries in chronological order with the literal year, title,
  and description (AC-6), inside a semantic ordered list.
- Exactly 3 team cards with the spec's gradients, names, and role labels (AC-7).
- The press-kit section always renders with dark lockup, light lockup, an 8-entry
  palette grid, and a "Download kit" CTA whose href resolves to a real asset in
  the build output (AC-8).
- `web/dist/press-kit/cupid-press-kit.zip` exists after `npm run build`.
- Every localized string in these sections has both `data-vi` and `data-en`; the
  flagged literals have neither (AC-11).
- No file under `web/src/layouts/`, `web/src/components/shell/`,
  `web/src/styles/`, or `web/src/scripts/` is modified — including
  `SiteFooter.astro`, whose "Press kit" link stays pointed at `/about`.

## 5. Planned Outputs

- Code directories or files: the paths in `1B. Write Scope`.
- Notes or evidence: `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: static web (`web-frontend`), Astro build output
- Required levels (omit N/A levels):
  - frontend build/type-check: `npm run check` and `npm run build` from `web/`
  - visual inspection: full `/about` page at dark×vi, dark×en, light×vi, light×en
    and at 375/768/1024/1440px
- Required checks:
  - Node version used for the two commands is >=22.12.0; a run on ambient
    v20.20.2 is not valid evidence.
  - `web/dist/press-kit/cupid-press-kit.zip` exists and the built href matches it.
  - Entry counts: 5 timeline `<li>`, 3 team cards, 8 palette swatches.
  - The two localization-format facts hold simultaneously: stat numbers
    unlocalized, timeline entry 4's separator localized.
  - No grid column drops below its `minmax` floor (240px principles, 200px
    stat/team/swatch) at any of the four widths; the press-kit header row wraps
    without orphaning the CTA.
  - `git -C <worktree> diff --stat <BaseHead>` shows no shell file changed.
- Frontend discoverability / navigation integration: the footer "Press kit" link
  reaches this page and the press-kit section is present on it (AC-1, AC-8).
- Minimum gates by risk surface: see `../architecture/solution.md` section 4.
- Evidence format: append a dated block to `coding-plan/test-results.md` with the
  exact commands, the Node version, exit codes, the counts above, and the four
  theme×language observations.
- Requirement frontend visual audit: YES — AC-10 is decided at the requirement
  UI-lane review gate with `design_source` and `ui_surface` configured. Record the
  interim anchor used (uiux-spec §6.2's line-cited values) if no rendered
  `design-reference-*.png` exists yet.
- Verification strategy:
  - Build/type-check/lint command when required: `npm run check`, `npm run build`
  - Required assertion evidence: zip presence, href value, element counts, span
    presence/absence, shell diff empty

## 7. Status

- Status: COMPLETE
- Last updated: 2026-08-21
- Evidence: `coding-plan/test-results.md` § "Phase P2"
