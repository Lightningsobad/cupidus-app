# Phase P2 – Global Shell (Layout, Header, Footer, Theme/Language Boot)

## 1. Objective

The shell every REQ-006 page renders inside: layout, nebula backdrop, sticky
header with both toggles and the "Get the app" CTA, footer, and the
render-blocking theme/language boot script. This phase publishes the contract
STORY-002…STORY-008 build against.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-global-shell.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `web/src/layouts/SiteLayout.astro`
  - `web/src/components/shell/NebulaBackdrop.astro`
  - `web/src/components/shell/SiteHeader.astro`
  - `web/src/components/shell/SiteFooter.astro`
  - `web/src/data/site-nav.ts`
  - `web/src/scripts/theme-lang-boot.ts`
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
  - `SiteLayout` + its `page` prop union
    (`../architecture/contract-summary.md` §1)
  - route keys, storage keys, body attributes (§2)
- Shared Interfaces Consumed:
  - `web/src/styles/tokens.css`, `web/src/styles/global.css` (P1)
- Risk Surfaces:
  - Inline-style fidelity
  - Hover-state fidelity
  - Nav breakpoint hard swap
  - Theme/lang boot before first paint
  - Language persistence across document loads
  - Web font + icon-font parity
- Source Of Truth:
  - authoritative artifact: `cupid-app-design-system/Cupid Web.dc.html` lines
    11–14 (fonts), 31–44 (backdrop), 46–77 (header), 655–676 (footer),
    683–732 (theme/lang logic + nav data), 831–848 (footer link data)
  - consumer contract: `../architecture/contract-summary.md` §1–§3
- Primary Inputs Summary:
  - requirements: AC-2, AC-3, AC-4, AC-7
  - architecture: `../architecture/solution.md` §1 Key Discovery #2 and #3, §4
    Fidelity Baseline, §4 Frontend Lane guardrails
  - OQ constraints: none open
  - upstream phase outputs: P1 `tokens.css`, `global.css`
  - UX constraints: `../ux/uiux-spec.md` §6.1 (header/footer geometry, copy,
    accessibility gaps to close), §6.4 (theme/lang states)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one shell — layout + its four fixed regions + boot script
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (AC-2, AC-3, AC-4, AC-7)
- `../architecture/solution.md` §1, §4
- `../architecture/contract-summary.md` §1–§3
- `../ux/uiux-spec.md` §6.1, §6.4 only
- `cupid-app-design-system/Cupid Web.dc.html` at the line ranges named above

## 3. Tasks

- `SiteLayout.astro`: emit `<html lang="vi">`, a `<head>` containing the two
  Google Fonts `<link>` elements copied byte-identical from source lines 11–14
  (both `preconnect` hints included), and `<body data-theme="dark"
  data-lang="vi">`. Import `tokens.css` and `global.css`.
- Make the theme/language boot script the **first child of `<body>`**, inline
  and render-blocking (no `defer`, no `type="module"`, not in `<head>` — it
  writes `document.body.dataset`, which does not exist during `<head>` parsing).
  It reads `cupid-web-theme` and `cupid-web-lang` inside `try/catch` exactly as
  source line 686 does, falling back to `dark`/`vi`.
- Type the `page` prop as the string-literal union of the eight route keys so an
  unknown value is a build error.
- Persist **both** `cupid-web-theme` and `cupid-web-lang` on toggle. The design
  source persists only theme; see `../architecture/solution.md` Key Discovery #2
  for why AC-4 requires the language key on a multi-page site. Do not add a
  third storage key.
- `NebulaBackdrop.astro`: port source lines 32–43 verbatim, keeping
  `aria-hidden="true"`, all ten star radial-gradients, the eight `star` icon
  spans with their exact animation delays, and both blurred blobs.
- `SiteHeader.astro`: port lines 46–77 verbatim. Replace `{{ accent }}` with the
  literal `#FF7FB6`. Convert `<sc-for list="{{ navItems }}">` into an Astro map
  over `site-nav.ts`; the seven items and their VI/EN labels come from source
  line 715–718 unchanged. Keep both the desktop `<nav data-nav>` and the mobile
  `<select data-navm>` — the swap is P1's media queries, not a JS breakpoint.
- Convert every `style-hover="..."` attribute into one real CSS `:hover` rule in
  the component's scoped `<style>` block. One rule per element; do not merge
  rules across elements. The source contains 17 such attributes across the file.
- `SiteFooter.astro`: port lines 655–676 with the link data at 831–848. Four
  columns; "Press kit" links to `/about`; both Legal links point to `/legal`.
  Do not add a header nav item for `legal`.
- Close the accessibility gaps the design source lacks, without changing
  rendered pixels: `aria-label` on the mobile `<select>`, `aria-current="page"`
  on the active nav item, `role="group"` plus accessible names on the VI/EN
  toggle, retain the theme button's localized `title`, and add visible focus
  rings for keyboard users.
- Copy every VI and EN string verbatim from the design source, including the
  theme-toggle titles ("Chuyển sang Hồng mơ mộng" / "Switch to Dreamy Pink" /
  "Chuyển sang nền tối" / "Switch to dark") and the footer tagline.

## 4. Acceptance Criteria

- Header and footer render at the Fidelity Baseline visually identical to the
  design source's header and footer regions.
- With `cupid-web-theme=light` in storage, a cold document load shows no dark
  frame before the light theme applies.
- Toggling theme or language updates `<body>` immediately and both survive a
  full document load.
- Every one of the 17 `style-hover` sites has a corresponding `:hover` rule.
- Both Google Fonts hrefs appear unchanged in the built HTML.
- Every header nav item, both toggles, the CTA, and every footer link are
  Tab-reachable in visual order with a visible focus ring.

## 5. Planned Outputs

- Code directories or files: the six paths in `## 1B Write Scope`.
- Contracts or schemas: the shell contract in
  `../architecture/contract-summary.md` §1–§3, now implemented.
- Notes or evidence: shell capture pairs and the hover-rule count in
  `test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: web (static build, browser render)
- Required levels:
  - frontend build/type-check: `cd web && npm run build` and `npx astro check`
  - visual inspection: shell capture pair (design vs built app) at the Fidelity
    Baseline — 1440×900, dark, VI — plus a light×EN pass at 1440×900
- Required checks:
  - hover-rule count: `:hover` rules across the shell components match the
    `style-hover` sites ported from the source
  - breakpoint check: render at 1024 (mobile `<select>` visible, pill row
    hidden) and 1025 (inverse)
  - FOUC check: seed `localStorage.cupid-web-theme="light"`, cold-load a route,
    confirm no dark first frame
  - persistence check: toggle to EN, reload, confirm EN is still active
  - keyboard pass: Tab through the header and footer, confirm order and rings
- Frontend discoverability / navigation integration: the header nav and footer
  are the site's only navigation surfaces; this phase builds them, and P3 mounts
  them on all 8 routes.
- Minimum gates by risk surface:
  - Inline-style fidelity / Hover-state fidelity: shell capture pair matches
  - Theme/lang boot before first paint: FOUC check passes
  - Language persistence across document loads: persistence check passes
  - Web font + icon-font parity: both hrefs byte-identical in built output
- Required runtime signals: browser console clean on load and on both toggles
- Evidence format: capture pairs plus command output in
  `coding-plan/test-results.md`
- Verification strategy:
  - Build/type-check command: `cd web && npm run build && npx astro check`
  - Required assertion evidence: capture pairs, hover-rule count, FOUC and
    persistence check results

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-21
