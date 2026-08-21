# 004_pairing_invite_landing_page-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-21

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: verbatim visual fidelity to `Cupid Web.dc.html:387-451`
  (`isShare`), strict non-functionality of the code cells and CTA (AC-3/AC-4),
  and zero modification of the STORY-001 shell.
- Architectural invariants / non-goals:
  - The `web/` Astro workspace, `SiteLayout`, `SiteHeader`, `SiteFooter`,
    `tokens.css`, `global.css`, and `scripts/theme-lang-boot.ts` are frozen for
    this story. This page composes them; it never edits them.
  - No client-side state, no `fetch`, no `localStorage` key, no form control.
    The whole page is static server-rendered markup plus one scoped `<style>`.
  - No new design token. A needed-but-missing color is a finding, not a token.
- Proposed technical direction: add one page-local content module and four
  page-local section components under `web/src/components/share/`, composed by
  the existing `web/src/pages/share.astro`, which passes a `title` prop to
  `SiteLayout`. Styling follows the STORY-001 convention already proven on Home:
  verbatim inline `style="…"` attributes copied from the design source, with
  `:hover` / `:focus-visible` promoted into one `<style is:global>` block.
- Why this fits: `web/src/components/home/*` established exactly this shape
  (`HowItWorks.astro` + `web/src/data/home-content.ts`). This story mirrors it
  for a second page, adding no new pattern and no new dependency.

### Key Discovery

`SiteLayout.astro:11-17` already declares `title?: string` (default `'Cupid'`)
and `description?: string`, and renders `<title>{title}</title>`. AC-8 / DEF-2 is
therefore closed by passing a prop from `share.astro` — the shell needs no edit,
which is what makes AC-8 compatible with the STORY-001 contract's
"do not modify `SiteLayout.astro`" rule. This is not obvious from the contract
summary, which does not mention the prop.

Second discovery, which constrains AC-8's shape: `<title>` is not a rendered
element, so the requirement-wide bilingual mechanism (`data-vi` / `data-en`
sibling spans toggled by CSS) cannot reach it. A bilingual title would require
either the shell boot script or a page-local `MutationObserver` on
`body[data-lang]`. Both are rejected — the first violates the shell freeze, the
second makes `/share` the only page in the site with a live-updating head and
buys nothing AC-8 asks for. Decision: one static, VI-primary, brand-prefixed
title, `Cupid — Ghép đôi`, matching the `data-lang="vi"` default the shell boots
with. Site-wide bilingual titles are a requirement-level concern; record as a
finding if the product wants them, do not solve them here.

## 3. Scope And Assumptions

- In Scope: the body of the existing `/share` route — one content module, four
  section components, one scoped style block, and the `title` prop.
- Out Of Scope: every shell file, every other route, `tokens.css`, and any
  interactive or networked behavior.
- Assumptions affecting design:
  - `MochiSprite.astro` already renders `role="img" aria-label="Mochi"` and
    accepts `size`, so uiux-spec §6.2.4's alt requirement is met by reuse at
    `size={150}`; no new sprite is authored.
  - `global.css:7` already defines `@keyframes floaty`, and `global.css:3`
    already styles `[data-icon]` as Material Symbols Rounded. The connector
    badge animation and all five Material icons on this page are available
    without touching shared CSS.
  - `web-frontend` requires Node >= 22.12.0 (runtime registry `engines.note`);
    the machine default is v20. Build/check must run under a pinned Node 22.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `web-frontend` (Astro static site, `web/`).
- New or changed boundaries: none. One existing route file gains a body.
- Shared patterns reused: STORY-001's page-body convention — `data/<page>-content.ts`
  for repeated content, one component per design-source section, verbatim inline
  styles, `data-vi`/`data-en` span pairs, `<style is:global>` for hover/focus
  with `!important` where an inline declaration must be overridden
  (`Hero.astro:69-77` is the reference implementation).

### Affected Modules

- Frontend: `web/src/pages`, `web/src/components/share`, `web/src/data`.

### Contracts And Integrations

- Error, retry, timeout, idempotency, and empty-state contract: none exist by
  design. There is no async operation, no data source, and no failure mode on
  this page; the "Paired" mockup is an illustration of a state, not a state.
  Implementations must not add a disclaimer, tooltip, or `disabled` affordance
  to explain the non-functional cells — the mitigation is that they never look
  interactive (uiux-spec §6.9).

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Shell freeze | `STORY-001/architecture/contract-summary.md` §6 | Compose only; pass `page` + `title` props; never edit shell or token files | `git -C <Worktree> diff --name-only <BaseHead>` lists no path under `web/src/layouts/`, `web/src/components/shell/`, `web/src/styles/`, `web/src/scripts/` | SHELL_CONTRACT_VIOLATION |
| Non-functional code cells and CTA | requirements AC-3, AC-4; uiux-spec §6.2.2, §6.2.3, §6.6 | Cells are `<div>`, never `<input>`; CTA is `<a href="#">` with no deep link; no `tabindex` on cells or mockup chrome; no `cursor:text` | Built `dist/share/index.html` contains no `<input`, no `tabindex` outside the shell; keyboard tab order reaches the CTA and nothing else new on the page | AC3_AC4_INTERACTIVITY_UNVERIFIED |
| Bilingual copy completeness | requirements AC-10; contract-summary §3 | Every user-visible string ships both `data-vi` and `data-en` spans, verbatim from source | `data-vi` and `data-en` occurrence counts are equal in `dist/share/index.html`, and both `data-lang` states render fully (no blank region) | COPY_PARITY_UNVERIFIED |
| Per-page title | requirements AC-8; STORY-001 DEF-2 | `share.astro` passes `title="Cupid — Ghép đôi"` | `dist/share/index.html` `<title>` is `Cupid — Ghép đôi` and differs from `dist/index.html`'s | TITLE_GATE_UNVERIFIED |
| Visual fidelity to `isShare` | requirements UI-Fidelity-AC-9; uiux-spec §6.2, §6.8 | Copy inline styles verbatim by cited line range; no normalization of Home's 66px H1 onto this page's 54px H1; preserve the mint-vs-neutral mockup label contrast | Rendered design reference vs. the running page, plus reflow inspection at 375/768/1024/1440 (connector badge must not orphan between stacked mockups) | DESIGN_REFERENCE_RENDER_UNAVAILABLE |
| Token-only styling | contract-summary §4 | Read `var(--*)` only; author no token | Diff shows no change to `web/src/styles/tokens.css`; page introduces no new custom property | TOKEN_DRIFT_UNVERIFIED |

### Lane Handoff

#### Frontend Lane

- Responsibilities: the whole story — content module, four section components,
  route composition, scoped hover/focus style, build + check evidence, and the
  design-reference render for the review gate.
- Authoritative inputs: `../ux/uiux-spec.md` §6.2 (per-section measurements with
  design-source line citations), `../requirements/requirements.md` AC-1..AC-10,
  `cupid-app-design-system/Cupid Web.dc.html:387-451`.
- Guardrails:
  - Do not edit any file outside `web/src/pages/share.astro`,
    `web/src/components/share/`, and `web/src/data/share-content.ts`.
  - Do not reuse Home's `steps` data or `HowItWorks.astro` for this page's
    three-step explainer. Same anatomy, different copy set — merging them is a
    fidelity regression (uiux-spec §6.2.5).
  - Do not give the "Open Cupid" CTA a real store or deep-link `href`.
  - Do not add a `<title>`-updating script, an i18n library, or a second
    styling system.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Static VI-primary `<title>` via the existing `SiteLayout` prop | Closes AC-8/DEF-2 with zero shell change | ACCEPTED | Matches the shell's `data-lang="vi"` boot default |
| Bilingual `<title>` driven by a `body[data-lang]` observer | uiux-spec §6.5 floats a localized title | REJECTED | Requires either the frozen boot script or page-local JS unique to this one route; AC-8 asks for distinct and descriptive, not localized |
