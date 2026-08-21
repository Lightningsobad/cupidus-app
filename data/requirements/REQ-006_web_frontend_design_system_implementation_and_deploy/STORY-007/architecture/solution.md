# 007_support-faq-page-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-21

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: strict rendered visual fidelity to `Cupid Web.dc.html`
  (`isSupport`, lines 614-637 + `faq` data 814-821); zero new runtime
  dependencies (REQ-006 is a static site, OQ-REQ006-2 RESOLVED); the STORY-001
  shell contract must stay byte-unchanged.
- Architectural invariants / non-goals:
  - This story writes exactly one page body. No shell, token, nav, or footer
    change. No API, form handler, CMS, or i18n library.
  - FAQ disclosure is native `<details>`/`<summary>`. No accordion library, no
    JS-managed open state, no invented `details[open]` icon treatment.
  - The contact control is a plain `<a href="mailto:hi@cupid.app">`.
- Proposed technical direction: replace the stub body of the already-existing
  route `web/src/pages/support.astro` with the eyebrow/heading header block, a
  6-entry `<details>` FAQ stack, and the "Still need a human?" contact block,
  all using verbatim inline styles and paired `data-vi`/`data-en` spans. Supply
  AC-7's per-page title through the `title` prop `SiteLayout` already accepts.
- Why this fits the current system or new area: STORY-001 already created the
  route file, the layout, the token set, and the bilingual CSS mechanism. The
  smallest correct change is a body swap plus two layout props.

### Key Discovery

Two findings changed the shape of this story versus the UX spec's assumptions:

1. **AC-7 needs no new mechanism and no shell change.**
   `web/src/layouts/SiteLayout.astro:11-17,25` already declares
   `interface Props { page: PageKey; title?: string; description?: string }`
   with `title = 'Cupid'` as the default and renders `<title>{title}</title>`.
   The DEF-2 defect is that pages fall through to the default, not that the hook
   is missing. Passing `title` from `support.astro` closes AC-7 in one line.

2. **The per-page `<title>` cannot be localized with this site's bilingual
   mechanism, so it must not try.** The STORY-001 contract (§3) states the only
   supported bilingual mechanism is paired `data-vi`/`data-en` spans toggled by
   CSS from `body[data-lang]`. CSS cannot style or toggle `<head>` text, and the
   language toggle lives in `SiteHeader` with no page-observable event — a
   `document.title` swap would mean editing the shell boot script, which the
   contract (§6) forbids because it silently re-renders the other seven pages.
   Decision: one static bilingual title string, VI first (site default lang is
   `vi`), no JS. See section 6.

## 3. Scope And Assumptions

- In Scope: the body of `web/src/pages/support.astro` plus its `title` and
  `description` props.
- Out Of Scope: `SiteLayout`/`SiteHeader`/`SiteFooter`/`tokens.css`/
  `global.css`, the theme+lang boot script, every other route file, and any
  support backend.
- Assumptions affecting design:
  - STORY-001 is merged into this worktree's base; `support.astro`,
    `SiteLayout.astro`, and the token set are present and are read-only inputs.
  - The design-source fidelity lock is repointed to `Cupid Web.dc.html` before
    the UI review gate runs (`req_master.md` Technical Constraints,
    Design-Source line) — that is a requirement-level DevOps action, not this
    story's work, but it gates AC-6 evidence.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `web` Astro workspace, runtime registry id
  `web-frontend`.
- New or changed boundaries: none. This is a leaf page inside an existing
  boundary.
- Shared patterns reused or introduced: reused unchanged — `SiteLayout` slot
  contract, `data-vi`/`data-en` span pairs, `var(--*)` design tokens, verbatim
  inline `style="..."` with one scoped `:hover` rule per element.

### Affected Modules

- Frontend: `web/src/pages` (one file).

### Contracts And Integrations

- Error, retry, timeout, idempotency, and empty-state contract: none apply —
  the page is fully static with no fetch, no form submit, and no empty state.
  The six FAQ entries are literals in the markup, so "no results" is
  unreachable by construction.
- External or trust-boundary implications: the only outbound affordance is a
  `mailto:` URI handled by the visitor's own mail client. No third-party script,
  no analytics, no cross-origin request is added.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Rendered visual fidelity (AC-6) | `cupid-app-design-system/Cupid Web.dc.html` lines 614-637 and 814-821 | Copy inline styles and copy verbatim; never retype a numeric value or a token name from the UX prose when the source line is available | Frontend visual audit of the rendered `/support` page against the source `isSupport` section at 375/768/1024/1440px, in dark and light theme, in VI and EN, plus one FAQ entry open | Design-source fidelity lock still points at `Cupid App.dc.html`; report and stop rather than audit against the wrong canvas |
| Bilingual completeness (AC-5) | STORY-001 `architecture/contract-summary.md` §3 | Every user-visible string ships both a `data-vi` and a `data-en` span; a lone `data-vi` renders blank in EN with no build error | Rendered-page check in both languages: eyebrow, `<h1>`, 6 questions, 6 answers, contact title, contact subtext all show text; `mailto` pill label `hi@cupid.app` is intentionally unlocalized | None |
| Independent FAQ disclosure state (AC-3, BR-3) | UX spec §6.2 | Six sibling native `<details>` elements, no `name` attribute (that would make them mutually exclusive), no JS | Open entry 3, confirm entries 1,2,4,5,6 stay closed; toggle via Enter/Space from the keyboard | None |
| Shell immutability (STORY-001 contract §6) | STORY-001 `architecture/contract-summary.md` §6 | Restrict writes to `web/src/pages/support.astro` | Story diff against `BaseHead` touches no file under `web/src/layouts/`, `web/src/components/`, or `web/src/styles/` | None |
| Per-page document title (AC-7) | `web/src/layouts/SiteLayout.astro:11-17,25` | Pass `title` explicitly; do not change the layout default | Built `web/dist/support/index.html` contains the story's title string and not the bare default `Cupid` | None |
| Entry-point reachability (AC-1) | STORY-001 `architecture/contract-summary.md` §2 route key `support` | Fill the existing `/support` route body; do not add a nav item | From the rendered home page, the header "Support"/"Hỗ trợ" nav item and the footer Company-column "Support" link both resolve to `/support` and that page shows the FAQ content, not an empty shell | None |

### Lane Handoff

#### Frontend Lane

- Responsibilities: the whole story. One phase, `P1`.
- Authoritative inputs: `../ux/uiux-spec.md` §6.1-6.3 and §6.6-6.8 for anchors
  and measurements; `Cupid Web.dc.html:614-637,814-821` for the literal markup,
  style values, and all VI/EN copy; STORY-001 `contract-summary.md` for the
  layout import shape and route key.
- Guardrails:
  - Do not modify any file outside `web/src/pages/support.astro`.
  - Do not paraphrase, re-translate, or retypeset any VI/EN string; copy it
    character-for-character from the design source, including punctuation.
  - Do not add `role="button"` or `aria-expanded` to `<summary>`; native
    `<details>` already exposes correct semantics. Do add
    `aria-hidden="true"` to the `expand_more` icon.
  - Do not add a `details[open]` icon rotation, color change, or size change —
    the source defines none.
  - Do not reduce the 50px `<h1>` on mobile; the source has no such media rule.
  - Do not use the `name` attribute on the `<details>` elements.

## 5. Non-Functional Impact

- Accessibility closes one gap the raw prototype leaves open: `<summary>` and
  the `mailto:` anchor need a visible focus ring, added as scoped rules in this
  page's own `<style>` block (STORY-001 flagged the same gap sitewide).
- The global `a:hover{color:#FFA9CD}` rule from `Cupid Web.dc.html:18` competes
  with the mailto pill's own `color: var(--bg)`. Inline style wins over a
  stylesheet rule of any specificity, so the pill keeps its solid look — this
  must be confirmed visually rather than assumed, because it is the one place a
  sitewide rule can silently break fidelity.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Static bilingual `<title>`: `Hỗ trợ & FAQ · Support & FAQ — Cupid`, passed as the `title` prop | AC-7 asks for a distinct descriptive title; the shell already accepts one | ACCEPTED | Pattern for the page set: `<VI page name> · <EN page name> — Cupid`. Satisfies AC-7 in both language states at once with zero JS and zero shell change. Also pass `description` for the same reason it exists |
| JS `document.title` swap driven by `body[data-lang]` | The UX spec §6.7 suggests localizing the title per active language | REJECTED | The lang toggle is owned by the shell boot script and exposes no page-observable event, so this needs a shell edit that STORY-001 contract §6 forbids — it would silently re-render and invalidate the fidelity evidence of the other seven pages |
