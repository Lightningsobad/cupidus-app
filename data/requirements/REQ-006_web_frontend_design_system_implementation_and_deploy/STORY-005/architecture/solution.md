# 005_cupid-journal-blog-page-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-21

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: rendered visual fidelity against the `isBlog` block of
  `cupid-app-design-system/Cupid Web.dc.html` (UI-Fidelity-AC-7); literal VI/EN
  copy fidelity (AC-8); strictly presentational interaction surfaces (AC-3,
  AC-6); zero modification of the STORY-001 shell.
- Architectural invariants / non-goals: no `fetch`/API/form-submit anywhere on
  this page; no new route, nav item, `localStorage` key, design token, or
  styling system; no article-detail template; no filter logic; no CMS or
  pagination.
- Proposed technical direction: replace the body of the existing
  `web/src/pages/blog.astro` stub with the page content, driven by one typed
  seed-data module for the 4 topics and 6 posts, plus one page-local
  `ArticleCard.astro` component for the repeated grid card. The featured panel,
  intro, pill row, and newsletter block are authored inline in the page because
  each renders exactly once. Bilingual text uses the shell's existing
  `data-vi`/`data-en` span mechanism; `<title>` uses the layout's existing
  `title` prop.

### Key Discovery

Two assumptions carried in from upstream artifacts are already resolved in the
worktree, and both change downstream work:

1. `SiteLayout.astro:11-17` already declares `title?: string` and
   `description?: string` and renders `<title>{title}</title>` with a `'Cupid'`
   default. AC-9 (DEF-2 carry-forward) therefore needs **no** title-templating
   mechanism, no new layout prop, and no shell edit — it is one attribute on the
   existing `<SiteLayout>` tag. Any plan that introduces a title helper here is
   over-built and violates the shell-immutability contract.
2. The UX spec's open item (§7.1) about the design-fidelity lock is closed:
   `data/devops/system/design-fidelity-config.json` shows
   `design_source.entry: "Cupid Web.dc.html"`, `locked: true`, `ui_surface:
   true`. The AC-7 full UI-lane gate is configured; what remains is producing
   the rendered reference via `render-design-canvas.js --screen=blog`, which is
   review/DevOps tooling work, not an implementation dependency.

`web/src/pages/blog.astro` currently exists as a self-closing
`<SiteLayout page="blog" />` stub, so the route and the header nav item already
resolve — this story fills the body of a live entry point rather than creating
one.

## 3. Scope And Assumptions

- In Scope: the `/blog` page body inside `web/`, its seed-data module, and one
  page-local card component.
- Out Of Scope: `SiteLayout`/`SiteHeader`/`SiteFooter`/`tokens.css`/
  `global.css`, any other route, any backend surface.
- Assumptions affecting design: the six sprite components from STORY-001 are
  available; `SuaSprite.astro` supplies the featured panel's illustration, so
  this story authors no new SVG.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `web/` (Astro static site, runtime registry id
  `web-frontend`).
- New or changed boundaries: none. This story is a leaf consumer of the
  STORY-001 shell contract.
- Shared patterns reused or introduced: reuses verbatim inline `style="..."`
  attributes, scoped `<style>` blocks for hover states only, `data-vi`/`data-en`
  bilingual spans, and design tokens read via `var(--…)`. Introduces two
  page-local patterns (gradient-bordered two-cell featured panel, article card
  with author footer row) that are deliberately **not** promoted to shared
  components in this story.

### Affected Modules

- Frontend: `web/src/pages`, `web/src/components/blog`, `web/src/data`.

### Contracts And Integrations

- Error, retry, timeout, idempotency, and empty-state contract: none exist by
  design. Content is compile-time static, so there is no loading, error, or
  empty state to render — adding one would be invented scope.
- External or trust-boundary implications: the page must issue zero network
  calls of its own. Only the shell's existing Google Fonts links are permitted.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Rendered visual fidelity | `Cupid Web.dc.html` `isBlog` block (`:453-509`), seed data (`:780-792`); measurable values in `../ux/uiux-spec.md` §6.2, §6.7 | Copy layout, spacing, radius, color, and typography values verbatim from the cited line ranges; never re-derive or round them | Full UI-lane review gate with `design_source` + `ui_surface` (already configured) plus requirement-level `frontend-dev` `Mode: requirement-visual-audit`; visual inspection at 375/768/1024/1440px | Rendered reference missing: report `DESIGN_REFERENCE_UNAVAILABLE` to Scrum Master and name `render-design-canvas.js --screen=blog`; do not self-approve fidelity |
| Bilingual copy fidelity | `../ux/uiux-spec.md` §6.2 literal VI/EN strings; STORY-001 `contract-summary.md` §3 | Every user-visible string ships both a `data-vi` and a `data-en` span; strings pasted verbatim, no paraphrase, no typography normalization | Toggle language in both directions and confirm no blank/missing string on the whole page; `npm run check` | Language toggle unreachable: report the shell defect rather than adding a page-local toggle |
| Shell immutability | STORY-001 `architecture/contract-summary.md` §6 | Write only inside this story's three files; a needed shell change is a finding, not an edit | Story diff against `BaseHead` contains no shell, token, or `global.css` file | If a shell change looks unavoidable, stop and report to Tech Lead — it silently invalidates seven sibling pages' fidelity evidence |
| False interactive promise | AC-3, AC-6; `../ux/uiux-spec.md` §6.3 | Topic pills and cards render as non-interactive elements outside the Tab order with hover styling only; newsletter uses real `<input type="email">` + `<button>` but performs no submit/navigation | Tab through the page: only the newsletter input and button receive focus, with visible rings; clicking a pill, a card, or Subscribe causes no navigation, reload, or request | Cannot verify without a browser: record as a review-gate item rather than claiming AC-3/AC-6 pass |
| Per-page title (AC-9) | `web/src/layouts/SiteLayout.astro:11-17` | Pass a descriptive `title` to the existing prop; add no layout code | Built `/blog` HTML contains a Blog-specific `<title>`, not the `'Cupid'` default | None — fully verifiable from build output |
| Node engine floor | Runtime registry `web-frontend.engines` | `astro@6.0.5` requires Node >=22.12.0 while the machine default is v20.20.2; select the pinned Node before any `npm` command | `npm run check` and `npm run build` both succeed from `web/` | Wrong Node in the shell: report `NODE_ENGINE_MISMATCH` with the observed `node -v`; do not downgrade or unpin Astro |

### Lane Handoff

#### Frontend Lane

- Responsibilities: the whole story — page body, seed data, card component,
  title prop, build/type-check evidence.
- Authoritative inputs: `../ux/uiux-spec.md` §6.2-§6.7 (measurable values and
  literal copy), `Cupid Web.dc.html:453-509` and `:780-792` (exact gradient
  stops and tint percentages when the spec cites the source instead of inlining
  them), STORY-001 `contract-summary.md`.
- Guardrails: do not edit any shell, token, or global-style file; do not add a
  route, nav item, `localStorage` key, or design token; do not add `fetch`,
  form submission, `<a href="#">` placeholders, or `tabindex` on pills/cards; do
  not build the featured panel from the `posts` array; do not merge the article
  card with STORY-001's feature card; do not add pagination, load-more, or a
  filter-result count.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| One `ArticleCard.astro` + typed seed module; everything single-use authored inline in `blog.astro` | Six near-identical cards justify one component; the intro, pill row, featured panel, and newsletter each render once | ACCEPTED | Keeps the story to three files and one specialist lifecycle |
| Extract a component per page section (pills, featured, newsletter) | Mirrors the UX spec's §6.5 component list | Rejected | Each would have exactly one call site; §6.5 describes visual patterns, not a required file layout, and the split adds indirection between the design source and the rendered markup that fidelity review must then trace through |
