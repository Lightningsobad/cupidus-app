# STORY-008 Privacy & Terms Page — Architecture Solution

## 0. Metadata

- Complexity: standard
- Date: 2026-08-21

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: UI-Fidelity-AC (rendered parity with
  `cupid-app-design-system/Cupid Web.dc.html:639-653`); verbatim bilingual legal
  copy (AC-3); zero change to the STORY-001 shell (contract §6); AC-5 per-page
  `<title>` that follows the language toggle.
- Architectural invariants / non-goals:
  - The story writes exactly one file: `web/src/pages/legal.astro`. Any need to
    change `SiteLayout.astro`, `SiteHeader.astro`, `SiteFooter.astro`,
    `tokens.css`, or `global.css` is a blocker to report, not a change to make —
    those files are shared by seven other in-flight page stories.
  - No new design token, no new route, no new nav/footer item, no `fetch`, no
    i18n library, no second styling system.
  - No card / `--surf` / border-radius chrome and no 8th header nav item. Both
    are deliberate design-source properties, not omissions to "fix".
- Proposed technical direction: fill the existing `/legal` route body with the
  design source's single-column 820px long-form block, using verbatim inline
  `style="..."` attributes and paired `data-vi` / `data-en` spans, wrapped in
  semantic `<h1>`/`<h2>` elements; satisfy AC-5 through the layout's existing
  `title` prop plus one page-local inline script that mirrors `body[data-lang]`
  into `document.title`.
- Why this fits the current system or new area: STORY-001 already created the
  route file, the `<main>` landmark, the token set, and the bilingual CSS
  mechanism. This story is a body-only fill of a pre-existing, contract-defined
  slot.

### Key Discovery

Two implementation assumptions that the story inputs imply are already false in
the merged code, and acting on either would create a defect:

1. **`SiteLayout` already accepts a per-page title.**
   `web/src/layouts/SiteLayout.astro:11-17,25` declares `interface Props { …
   title?: string }` with `const { page, title = 'Cupid', description } =
   Astro.props` rendering `<title>{title}</title>`. AC-5 (DEF-2 carry-forward)
   therefore needs **no shell change at all** — only `<SiteLayout page="legal"
   title="…">`. The only unsolved part of AC-5 is locale reactivity (section 6).
2. **The `<main>` landmark already exists in the shell.**
   `SiteLayout.astro:37` renders `<main><slot /></main>`. The UX spec's §6.6
   requirement for "a real `<main>` landmark" is satisfied by the shell; the page
   body must **not** add its own `<main>`. A nested `<main>` is both an
   accessibility violation and a silent duplication of the shell. The page's
   outermost element is the `<section>` from `Cupid Web.dc.html:640`.

## 3. Scope And Assumptions

- In Scope: the body of `web/src/pages/legal.astro` (page wrapper, header block,
  five-section list), its scoped `<style>` if one is needed, its `title` prop,
  and one page-local inline title-sync script.
- Out Of Scope: every shell file; any other route; any backend, API, or data
  access; authoring or editing the legal copy itself.
- Assumptions affecting design:
  - `body[data-lang]` and `body[data-theme]` are set by the shell boot script
    before first paint, and the language toggle mutates `body[data-lang]` in
    place (contract §2). The title-sync script depends only on that attribute,
    not on any shell-exported function or event.
  - The tokens `--ink`, `--c1`, `--c45`, `--c5`, `--c64` all already exist in
    both the dark and light blocks of `web/src/styles/tokens.css`; no token is
    added.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `web` (runtime registry id `web-frontend`).
- New or changed boundaries: none. The `/legal` route and its footer entry
  points already exist; this story fills a body slot inside an unchanged shell.
- Shared patterns reused or introduced:
  - Reused: `SiteLayout` slot contract, `data-vi`/`data-en` bilingual spans,
    verbatim inline styles, token variables.
  - Introduced (page-local, documented for reuse): the **long-form text block** —
    a title + body pair separated by `border-top:1px solid var(--c1)` with no
    card, no `--surf`, no radius. This is the system's first non-card content
    pattern and is a deliberate contrast to every other REQ-006 page.

### Affected Modules

- Frontend: `web/src/pages` only.

### Contracts And Integrations

- Error, retry, timeout, idempotency, and empty-state contract: none apply — the
  page is fully static with no interactive element, no form, and no async call.
  There is no loading, empty, or error state to design.
- External or trust-boundary implications: the page publishes the product's
  privacy and terms statements. The copy is a verbatim reproduction of the
  design-source placeholder text and is **not** counsel-reviewed; paraphrasing,
  reordering, or dropping a section changes a legal-facing statement, which is
  why AC-3 is enforced as an exact-string gate rather than a content review.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Verbatim bilingual legal copy | UX spec §6.2 content list; `Cupid Web.dc.html:823-829` | Every user-visible string ships BOTH a `data-vi` and a `data-en` span; strings copied character-for-character, no re-translation, no quote/dash normalization | Render `/legal` in `vi` and in `en`; assert all 5 titles and all 5 bodies are present and non-empty in each locale, in source order | `LEGAL_COPY_GATE_BLOCKED` — record which locale/section could not be verified |
| Rendered visual fidelity | `Cupid Web.dc.html:639-653`; UX spec §6.8 measurable rules | Copy inline styles verbatim; keep `max-width:820px`, `padding:70px 32px 90px`, `gap:26px`, `margin-top:34px`, `padding-top:22px`, `margin-bottom:9px`; no card/`--surf`/radius chrome; no added breakpoint | Visual inspection of the built page at 375 / 768 / 1024 / 1440 px against the §6.8 value list, in all 4 theme×lang combinations; no horizontal scroll or clipping at 375 | `VISUAL_FIDELITY_GATE_BLOCKED` — name the width/combination that could not be rendered |
| Shell immutability | `STORY-001/architecture/contract-summary.md` §6 | Page-local changes only; title reactivity solved without touching the shell script | `git -C <worktree> diff --name-only <BaseHead>` lists no file under `web/src/layouts/`, `web/src/components/`, or `web/src/styles/` | `SHELL_DIFF_GATE_BLOCKED` |
| Per-page localized `<title>` (AC-5) | Story requirements AC-5; UX spec §6.5 | `title` prop supplies the static VI value; a page-local `is:inline` script mirrors `body[data-lang]` into `document.title` on load and on mutation | Load `/legal`, assert `document.title` is the VI value; toggle language, assert it becomes the EN value without a reload | `TITLE_GATE_BLOCKED` |
| Entry-point reachability (AC-1) | Story requirements AC-1; UX spec §5.1, §6.3 | Both footer "Legal" column links already target `/legal`; the page fills that target. Header nav stays at 7 items | From the rendered home page, click each footer Legal link and land on the populated `/legal` page; confirm the header nav still has exactly 7 items | `ENTRY_POINT_GATE_BLOCKED` |
| Heading and landmark semantics | UX spec §6.6 | Exactly one `<h1>` (page heading); the 5 section titles are `<h2>`; the page body adds NO `<main>` because the shell already provides one | Inspect the rendered DOM: exactly one `<main>`, exactly one `<h1>`, exactly five `<h2>` inside it | `SEMANTICS_GATE_BLOCKED` |

### Lane Handoff

#### Frontend Lane

- Responsibilities: implement the `/legal` page body, its `title` prop, and the
  title-sync script; run the phase test scope and record evidence.
- Authoritative inputs: `../requirements/requirements.md` (AC-1..AC-5,
  UI-Fidelity-AC), `../ux/uiux-spec.md` §6.2 / §6.5 / §6.6 / §6.7 / §6.8,
  `../../STORY-001/architecture/contract-summary.md`.
- Guardrails:
  - Do not edit any file outside `web/src/pages/legal.astro`.
  - Do not add a `<main>`, an accordion/`<details>`, a table of contents, jump
    links, a card/`--surf` container, a border-radius wrapper, an accent color,
    a responsive breakpoint, or an 8th header nav item.
  - Do not widen the 820px measure to match another page, and do not compute the
    updated-date — "Cập nhật 29.07.2026" / "Updated 29 Jul 2026" are literals.
  - Do not ship a string with only one of the two locale spans.

## 5. Non-Functional Impact

- The statically rendered `<title>` is the Vietnamese value (the site's default
  `data-lang="vi"`), so crawlers and link previews see the VI title; the EN title
  is applied client-side. This is accepted: `<title>` cannot hold bilingual spans
  and a build-time per-locale title would require locale-prefixed routes, which
  the shell contract forbids.
- A returning EN visitor may see the VI title for one frame before the inline
  script runs. Mitigated by `is:inline` (executes during parse, not deferred like
  Astro's default bundled `<script>`), and bounded to the tab label only.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| `title` prop (static VI) + page-local `is:inline` script mirroring `body[data-lang]` into `document.title` via `MutationObserver` | Uses the prop the shell already exposes; satisfies AC-5 and UX §6.5 reactivity with zero shared-file writes | ACCEPTED | ~6 lines, page-local, no shell coupling, no merge-conflict surface against the seven sibling page stories |
| Extend `SiteLayout` with `titleVi`/`titleEn` and move the sync into the shell boot script | Would give every page locale-reactive titles in one place | REJECTED | Edits a file the contract declares immutable for consumers, re-renders the other seven pages and invalidates their fidelity evidence, and makes one file a write hotspot across seven parallel worktrees. If the requirement later wants this for all pages, it is a separate shell story owned by one lane. |
