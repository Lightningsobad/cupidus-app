# Phase P1 – Legal Page Body, Localized Title, And Footer Entry Point

## 1. Objective

Fill the existing `/legal` route with the design source's long-form Privacy &
Terms body, give it a locale-reactive per-page `<title>`, and prove it is
reachable from both footer "Legal" links — without touching any shell file.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-legal-page-body-and-entry-point.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `web/src/pages/legal.astro`
- Impacted Runtime Service/App:
  - Name: `web`
  - Runtime Registry Id: `web-frontend`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: frontend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (`npm run build`),
    preceded by `checkCommand` (`npm run check`)
  - Startup Command Source: runtime registry `prodCommand` (`npm run preview`),
    used only to render the built output for visual inspection
  - Readiness Check: N/A
  - Port Contract: per-project loopback host binding (`DEVSTACK_PORT_WEB`) —
    never Astro's default 4321
- Shared Interfaces Consumed:
  - `../../STORY-001/architecture/contract-summary.md` — `SiteLayout` slot
    envelope (§1), `legal` route key (§2), `data-vi`/`data-en` mechanism (§3),
    token read-only rule (§4), consumer prohibitions (§6)
- Risk Surfaces:
  - Verbatim bilingual legal copy
  - Rendered visual fidelity
  - Shell immutability
  - Per-page localized `<title>` (AC-5)
  - Entry-point reachability (AC-1)
  - Heading and landmark semantics
- Source Of Truth:
  - authoritative artifact or convention: `cupid-app-design-system/Cupid Web.dc.html`
    lines 639-653 (markup/styles) and 823-829 (the five-item `legal` data array)
  - consumer contract: none produced by this phase
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` — AC-1..AC-5, UI-Fidelity-AC
  - architecture: `../architecture/solution.md` — §1 Key Discovery, §4 risk table,
    §4 Frontend Lane guardrails, §6 accepted title option
  - UX constraints, if truly required: `../ux/uiux-spec.md` §6.2 (exact values and
    the verbatim VI/EN copy for all five sections), §6.5 (title strings), §6.6
    (semantics), §6.7 (no-card rule), §6.8 (measurable visual anchors)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one static page body plus its title behavior
  - Source/Test File Count: 1
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md` §6.2, §6.5, §6.6, §6.7, §6.8
- `../../STORY-001/architecture/contract-summary.md`

## 3. Tasks

1. Replace the self-closing `<SiteLayout page="legal" />` in
   `web/src/pages/legal.astro` with an open/close pair carrying
   `title="Quyền riêng tư & Điều khoản — Cupid"`. Do not add a `title` prop to
   the layout — `SiteLayout.astro:11-17,25` already declares and renders it.
2. Inside the slot, add the page wrapper as `<section
   style="max-width:820px;margin:0 auto;padding:70px 32px 90px">`. Do **not**
   wrap it in a `<main>`: `SiteLayout.astro:37` already renders
   `<main><slot /></main>`, and a second one is an a11y defect.
3. Build the header block from `Cupid Web.dc.html:641-643`: the literal,
   unlocalized eyebrow `Legal` (Roboto Mono 11px, uppercase,
   `letter-spacing:.14em`, `var(--c5)`); an `<h1>` (Nunito 900 / 48px /
   `letter-spacing:-.03em` / `margin:10px 0 0` / `var(--ink)`) holding the
   VI+EN spans; and the updated-date line (Roboto Mono 11.5px, `var(--c45)`,
   `margin:12px 0 0`) holding the two literal strings — not a computed date.
4. Build the sections container (`display:flex; flex-direction:column; gap:26px;
   margin-top:34px`) and the five section items in source order, each with
   `border-top:1px solid var(--c1); padding-top:22px`, an `<h2>` title (Nunito
   800 / 19px / `var(--ink)` / `margin-bottom:9px`) and a body block (14.5px /
   `line-height:1.7` / `var(--c64)`). Copy all ten title strings and ten body
   strings character-for-character from `../ux/uiux-spec.md` §6.2; every one of
   them needs both a `data-vi` and a `data-en` span.
5. Add one `<script is:inline>` in the page that sets `document.title` from
   `document.body.dataset.lang` (VI: `Quyền riêng tư & Điều khoản — Cupid`, EN:
   `Privacy & Terms — Cupid`) on parse and re-applies it from a
   `MutationObserver` watching `data-lang` on `<body>`. Use `is:inline` so it is
   not deferred like Astro's default bundled script. Do not import from, call
   into, or modify the shell boot script.
6. Run the test scope below and record evidence in `../coding-plan/test-results.md`.

## 4. Acceptance Criteria

- `web/src/pages/legal.astro` is the only changed file in the story diff.
- All five sections render, in source order, with both locales' title and body
  text present and matching the UX §6.2 strings exactly.
- The eyebrow renders as the literal `Legal` in both locales (it has no
  `data-vi`/`data-en` pair in the source and must not gain one).
- The rendered DOM contains exactly one `<main>`, exactly one `<h1>`, and exactly
  five `<h2>` elements.
- `document.title` is the VI title on load with `data-lang="vi"` and switches to
  the EN title when the language toggle is used, without a page reload.
- Both footer "Legal" column links land on the populated `/legal` page; the
  header nav still contains exactly 7 items.
- No card, `--surf` surface, border-radius container, accent color, accordion,
  table of contents, or media query is introduced anywhere on the page.

## 5. Planned Outputs

- Code directories or files: `web/src/pages/legal.astro`
- Notes or evidence: `../coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: `web-frontend` static Astro route `/legal`
- Required levels:
  - frontend build/type-check: `npm run check` then `npm run build`, both run
    from `web/` on Node >= 22.12.0
  - visual inspection: the built output served with `npm run preview` on
    `DEVSTACK_PORT_WEB`, inspected at 375 / 768 / 1024 / 1440 px in all four
    `data-theme` × `data-lang` combinations
- Required checks:
  - `git -C <worktree> diff --name-only <BaseHead>` lists only
    `web/src/pages/legal.astro` plus this story's `data/` artifacts
  - all ten VI/EN strings for the five section titles and five bodies present and
    non-empty in their respective locale
  - measured layout values match `../ux/uiux-spec.md` §6.8: `max-width:820px`,
    `padding:70px 32px 90px`, `margin-top:34px`, `gap:26px`, `padding-top:22px`,
    title `margin-bottom:9px`, H1 `margin:10px 0 0`, updated-date `margin:12px 0 0`
  - no horizontal scroll and no content clipping at 375 px
  - body text (`--c64`) remains legible over full paragraphs in both themes
- Frontend discoverability / navigation integration: from the rendered home page,
  follow footer "Quyền riêng tư"/"Privacy" and "Điều khoản"/"Terms" and confirm
  both reach the populated `/legal` page; confirm no 8th header nav item was added.
- Minimum gates by risk surface: the `Verification Gate` column of
  `../architecture/solution.md` §4 is authoritative for all six rows.
- Required regression or contract coverage: confirm the reused header, footer,
  theme toggle, and language toggle still behave identically on this route.
- Evidence format: `../coding-plan/test-results.md` — command, exit status, the
  per-locale section-string checklist, and the per-width/per-combination visual
  observation list.
- Requirement frontend visual audit: the requirement-level rendered audit
  (`Mode: requirement-visual-audit`) runs later at REQ-006 scope and is NOT this
  phase's gate; this phase owns only the story-scoped visual inspection above.
- Verification strategy:
  - Targeted tests/regression/contract checks: as listed under Required checks
  - Build/type-check command when required: `npm run check` && `npm run build`
  - Required assertion evidence: build/check exit codes plus the two checklists

## 7. Status

- Status: COMPLETE
- Last updated: 2026-08-21
- Evidence: `../coding-plan/test-results.md` — `npm run check` exit 0,
  `npm run build` exit 0, 195 assertions / 0 failures (diff scope, ten VI/EN
  section strings, measured layout anchors, `document.title` on load and on
  toggle, 16 theme x lang x width renders, four footer entry points, 7-item
  header nav, shell diff clean).
