# Phase P1 – Support FAQ Page Body And Entry Point

## 1. Objective

Fill the existing `/support` route with the design source's `isSupport` section
— eyebrow, `<h1>`, six independent `<details>` FAQ entries, and the "Still need
a human?" `mailto:` contact block — in both languages and both themes, and give
the page its own document title. On completion the header/footer "Support" links
lead to a fully rendered page instead of an empty shell.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-support-faq-page.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `web/src/pages/support.astro`
- Impacted Runtime Service/App:
  - Name: `web`
  - Runtime Registry Id: `web-frontend`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: frontend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (`npm run build`)
  - Startup Command Source: runtime registry `devCommand` (`npm run dev`) — used
    only to render the page for the visual audit, not as a startup smoke gate
  - Readiness Check: N/A
  - Port Contract: per-project loopback host binding (`DEVSTACK_PORT_WEB`)
- Shared Interfaces Consumed:
  - `SiteLayout` slot + props contract, route key `support`, `data-vi`/`data-en`
    span mechanism, `tokens.css` custom properties — all per
    `../../STORY-001/architecture/contract-summary.md`
- Risk Surfaces:
  - Rendered visual fidelity (AC-6)
  - Bilingual completeness (AC-5)
  - Independent FAQ disclosure state (AC-3, BR-3)
  - Shell immutability (STORY-001 contract §6)
  - Per-page document title (AC-7)
  - Entry-point reachability (AC-1)
- Source Of Truth:
  - authoritative artifact or convention: `cupid-app-design-system/Cupid Web.dc.html`
    lines 614-637 (markup and inline styles) and 814-821 (the six VI/EN
    question+answer pairs). Copy from these lines; do not retype values or copy
    from prose.
  - consumer contract: none — this page has no downstream consumer.
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-1..AC-7, BR-1..BR-3
  - architecture: `../architecture/solution.md` sections 1, 4, 5, 6
  - OQ constraints: none blocked; both requirement OQs are RESOLVED
  - upstream phase outputs: none
  - UX constraints, if truly required: `../ux/uiux-spec.md` §6.1-6.3 (exact
    measurements and token names per element), §6.6 (focus rings, responsive
    checkpoints, mailto hover caveat), §6.7 (title intent), §6.8 (fidelity scope)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one static page body — header block, FAQ disclosure list,
    contact block, document title. One behavior cluster, one route.
  - Source/Test File Count: 1
  - Split Required: NO
  - Split Rationale: splitting by visual section would separate phases that
    write the same file, which the planning rules forbid.

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md` sections 6.1-6.3 and 6.6-6.8
- `../../STORY-001/architecture/contract-summary.md`
- `cupid-app-design-system/Cupid Web.dc.html` lines 614-637 and 814-821 (ranged
  read only — the file is large; do not full-read it)

## 3. Tasks

- Replace the stub body of `web/src/pages/support.astro`, keeping the existing
  `SiteLayout` import and `page="support"` prop untouched.
- Pass `title="Hỗ trợ & FAQ · Support & FAQ — Cupid"` and a matching
  `description` to `SiteLayout` (AC-7). Do not change the layout's default.
- Build the section container, eyebrow, and `<h1>` per UX §6.1, with paired
  `data-vi`/`data-en` spans on the heading. Keep the `<h1>` at 50px at every
  width.
- Build the FAQ list per UX §6.2: a flex column, `gap: 10px`, containing six
  sibling `<details>` elements with no `name` attribute. Each has a `<summary>`
  row (question span left, `aria-hidden="true"` `expand_more` icon right) and
  an answer body. Suppress the native marker with `list-style: none` plus the
  WebKit `summary::-webkit-details-marker{display:none}` rule from the source.
- Copy all six question and answer strings verbatim from
  `Cupid Web.dc.html:814-821`, each as a `data-vi`/`data-en` span pair.
- Build the contact block per UX §6.3, ending in
  `<a href="mailto:hi@cupid.app">hi@cupid.app</a>` styled as the solid pill. The
  pill's visible label is not localized.
- Add scoped `:focus-visible` rules for `<summary>` and the `mailto:` anchor in
  this page's own `<style>` block, plus any `:hover` rule the source defines
  inline for these elements.
- Record evidence in `coding-plan/test-results.md`.

## 4. Acceptance Criteria

- AC-1: the header "Support"/"Hỗ trợ" nav item and the footer Company-column
  "Support" link both resolve to `/support`, and that page renders the FAQ
  content rather than an empty shell.
- AC-2: exactly six FAQ entries render, with the heading "Câu hỏi thường gặp" /
  "Frequently asked".
- AC-3 / BR-3: opening one entry leaves the other five in their prior state; no
  JS manages open state.
- AC-4 / BR-2: the contact block renders below the FAQ list with a visible
  `hi@cupid.app` link whose `href` is exactly `mailto:hi@cupid.app`.
- AC-5: every string above renders correctly under both `body[data-lang="vi"]`
  and `body[data-lang="en"]`, with no blank element in either state.
- AC-6: the rendered page matches the source `isSupport` section on layout,
  spacing, typography, and color tokens in both themes.
- AC-7: the built page's `<title>` is the story's own title, not the default.
- No file outside `web/src/pages/support.astro` is modified.

## 5. Planned Outputs

- Code directories or files: `web/src/pages/support.astro`
- Notes or evidence: `coding-plan/test-results.md`, plus visual audit
  screenshots referenced from it

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: `web-frontend` static Astro page, route `/support`
- Required levels (omit N/A levels):
  - frontend build/type-check: `npm run check` then `npm run build`, run from
    `web/` with the Node >=22.12.0 toolchain
  - visual inspection: rendered `/support` at 375, 768, 1024, 1440px, in dark
    and light theme, in VI and EN, with at least one FAQ entry open
- Required checks:
  - Rendered-DOM check: exactly six `<details>` elements, none carrying a `name`
    attribute.
  - Bilingual pairing check: every user-visible string element carries both a
    `data-vi` and a `data-en` span; no element renders blank in either language.
  - `href` check: the contact anchor's `href` is exactly `mailto:hi@cupid.app`.
  - Title check: built `web/dist/support/index.html` contains the story's
    `<title>` and not the bare default `Cupid`.
  - Shell-immutability check: `git -C <worktree> diff --name-only <BaseHead>`
    lists no path under `web/src/layouts/`, `web/src/components/`, or
    `web/src/styles/`.
  - Disclosure independence: open entry 3, confirm entries 1, 2, 4, 5, 6 remain
    closed; toggle a `<summary>` with Enter and with Space from the keyboard.
  - Focus visibility: `<summary>` and the `mailto:` anchor show a visible focus
    ring under keyboard navigation.
  - Mailto pill hover: the pill's label stays `var(--bg)`-colored and does not
    pick up the sitewide `a:hover{color:#FFA9CD}` pink.
  - Overflow check: no horizontal overflow and no icon-wrapping-below-question
    at any of the four widths.
- Frontend discoverability / navigation integration: this phase is the story's
  entry-point phase. The route and the header/footer links already exist from
  STORY-001; the phase is complete only when navigating from another page's
  header nav item and from the footer "Support" link both land on the rendered
  FAQ page. Direct-URL-only verification is not sufficient evidence.
- Minimum gates by risk surface:
  - Rendered visual fidelity (AC-6): the visual audit below
  - Bilingual completeness (AC-5): the bilingual pairing check
  - Independent FAQ disclosure state (AC-3, BR-3): the disclosure independence
    check
  - Shell immutability: the shell-immutability check
  - Per-page document title (AC-7): the title check
  - Entry-point reachability (AC-1): the discoverability check above
- Required runtime signals (omit N/A signals):
  - Browser console clean on `/support` — no errors, no 404 for the Material
    Symbols icon font
- Evidence format: `coding-plan/test-results.md` with the exact commands run,
  their pass/fail result, the per-check outcomes above, and the screenshot paths
- Requirement frontend visual audit: YES — compare the rendered `/support`
  page against `Cupid Web.dc.html`'s `isSupport` section per
  `../ux/uiux-spec.md` §6.8. Screenshot-based comparison only; do not author
  browser e2e specs. If the requirement's design-source fidelity lock still
  points at `Cupid App.dc.html`, stop and report instead of auditing against the
  wrong canvas.
- Verification strategy:
  - Targeted tests/regression/contract checks: the required checks above. The
    `web/` workspace has no unit-test framework and this phase does not
    introduce one.
  - Build/type-check/lint command when required: `npm run check` and
    `npm run build` from `web/`
  - Required assertion evidence: command output plus the visual audit
    screenshots, both recorded in `coding-plan/test-results.md`

## 7. Status

- Status: COMPLETE
- Last updated: 2026-08-21
- Evidence: `coding-plan/test-results.md`; screenshots in `visual-fidelity/`
- Gates: `npm run check` 0 errors / `npm run build` 8 pages (Node v25.2.1);
  6 `<details>` none named; 37/37 `data-vi`/`data-en` pairs; all 24 FAQ strings
  verbatim; `href="mailto:hi@cupid.app"`; per-page `<title>` set; diff vs
  BaseHead is `web/src/pages/support.astro` only; disclosure independence,
  focus rings, mailto hover, overflow and all three entry points verified
- Deferred: design-side canvas render for AC-6 — the DC preview runtime and the
  sanctioned `render-design-canvas.js`/`visual-capture.js` are absent from this
  worktree; see `coding-plan/test-results.md` §13.3
