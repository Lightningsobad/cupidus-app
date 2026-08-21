# STORY-006_about_and_press_kit_page-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-21

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: rendered visual fidelity against `Cupid Web.dc.html`
  (AC-10) and literal VI/EN copy fidelity (AC-11), inside the STORY-001 Astro
  shell that this story may not modify.
- Architectural invariants / non-goals: no backend call, no new route, no new
  design token, no second styling system, no shell edit, no admin toggle for the
  press-kit section. Page body only.
- Proposed technical direction: fill the existing `web/src/pages/about.astro`
  body with seven section components under `web/src/components/about/`, backed by
  one `web/src/data/about-content.ts` data module that mirrors the existing
  `home-content.ts` `tvi/ten/dvi/den` convention. Ship the "Download kit" target
  as a checked-in static asset bundle under `web/public/press-kit/`.
- Why this fits the current system or new area: it is exactly the consumer shape
  the STORY-001 contract prescribes — one page body, zero shell change — and it
  reuses the section-component granularity already established by
  `web/src/components/home/`.

### Key Discovery

1. **AC-9 needs no shell change, and cannot be fully satisfied.**
   `SiteLayout.astro:11-17` already declares `title?: string` (default `'Cupid'`)
   and `description?: string`, and renders `<title>{title}</title>`. So the
   per-page title is a one-word prop pass, not a shell edit. But the site's only
   bilingual mechanism is CSS visibility over `data-vi`/`data-en` spans
   (contract-summary §3), which cannot operate inside `<head>`; `<html lang="vi">`
   and the `<title>` are single static strings. The EN title from uiux-spec §6.9
   is therefore undeliverable without a shell-level `document.title` script that
   would re-render all eight pages. Ship the VI title (the site default language),
   per the fallback uiux-spec §6.9 pre-authorized, and carry the EN title as a
   deferred finding.
2. **The build must not run on ambient Node.** `runtime-command-registry.json`
   (`web-frontend.engines`) records that astro@6.0.5 requires Node >=22.12.0 while
   this machine's default is v20.20.2. `npm run check` / `npm run build` evidence
   produced on ambient node is a false failure, not a code defect.

## 3. Scope And Assumptions

- In Scope: `web/src/pages/about.astro` body, seven new components under
  `web/src/components/about/`, one new `web/src/data/about-content.ts`, one new
  static asset bundle under `web/public/press-kit/`.
- Out Of Scope: every file named in contract-summary §6 (layout, header, footer,
  tokens, global CSS, boot script), all other routes, any build/CI config change.
- Assumptions affecting design: STORY-001 is merged and `about.astro` exists as a
  body-less `<SiteLayout page="about" />` stub; Astro copies `public/` verbatim
  into `dist/` with no config change.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `web` (runtime registry id `web-frontend`).
- New or changed boundaries: none. This story adds leaves under an existing
  route; no new boundary, no new dependency, no new runtime surface.
- Shared patterns reused or introduced: reuses the `components/<page>/` +
  `data/<page>-content.ts` split that `home/` + `home-content.ts` established.
  Introduces no pattern intended for reuse — uiux-spec §7 explicitly defers
  promoting this page's card variants to shared UX memory.

### Affected Modules

- Frontend: `web/src/pages`, `web/src/components/about`, `web/src/data`,
  `web/public/press-kit`.

### Contracts And Integrations

- Error, retry, timeout, idempotency, and empty-state contract: none apply —
  static content, no async operation, no form (uiux-spec §6.6). The one failure
  mode that exists is a dead "Download kit" href, which is a build-output
  assertion (risk surface *Press-kit download target*), not a runtime state.
- External or trust-boundary implications: the press-kit bundle is published
  content on a public static site. It may contain only brand marks and the
  palette — no internal document, no credential, no unreleased asset.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| About page visual fidelity (AC-10) | `cupid-app-design-system/Cupid Web.dc.html:511-611`; `../ux/uiux-spec.md` §6.2, §6.8 | Copy inline `style="..."` verbatim per section; no invented token, no added hover-lift, no added border on the light lockup | Full UI-lane review gate with `design_source` + `ui_surface` configured (req_master Technical Constraints); rendered check at dark×vi, dark×en, light×vi, light×en and at 375/768/1024/1440px | `DESIGN_REFERENCE_UNRENDERED` — record uiux-spec §6.2's line-cited values as the interim anchor and report; do not self-certify fidelity |
| VI/EN copy fidelity (AC-11) | `Cupid Web.dc.html:511-611`, `:800-812`; uiux-spec §6.2.3 and §6.2.5 traps | Every localized string ships BOTH `data-vi` and `data-en` spans; the flagged literals (stat numbers `48.000+`/`31.500`/`2,1 triệu`, `Press kit`, `Dark lockup`, `Light lockup`, `Palette`, swatch names, team names) ship as plain unwrapped text | Per-string diff of the built HTML against the cited source lines; assert both spans exist for localized strings and are absent for the flagged literals | `COPY_SOURCE_UNREADABLE` — stop; do not paraphrase or re-translate from the spec prose |
| Shell immutability (contract-summary §6) | `.../STORY-001/architecture/contract-summary.md` §6 | Page body only; a needed shell change is reported, never applied | `git -C <worktree> diff --stat <BaseHead>` shows zero changed lines under `web/src/layouts/`, `web/src/components/shell/`, `web/src/styles/`, `web/src/scripts/` | none — this gate is a diff read and always runs |
| Press-kit download target (AC-8) | uiux-spec §6.2.7 CTA note | Anchor points at a real committed asset with `download`; source's `href="#"` placeholder is never shipped | After `npm run build`, assert `web/dist/press-kit/cupid-press-kit.zip` exists and the built `about/index.html` href resolves to it | `BUILD_UNAVAILABLE` (see Node trap below) |
| Per-page title (AC-9) | `SiteLayout.astro:11-17,25`; uiux-spec §6.9 | Pass the story's own `title` prop; never leave the `'Cupid'` default | Built `web/dist/about/index.html` `<title>` equals the VI title string and differs from every other page's | `BUILD_UNAVAILABLE` |
| Build/type integrity on pinned Node | `runtime-command-registry.json` `web-frontend.engines` | Run `npm run check` and `npm run build` on Node >=22.12.0, never ambient v20.20.2 | Both commands exit 0 with the Node version recorded in the evidence line | `NODE_VERSION_UNAVAILABLE` — report the ambient version; do not record a v20 failure as a code defect |

### Lane Handoff

#### Frontend Lane

- Responsibilities: all seven sections, the data module, the page wiring, the
  title prop, and the press-kit asset bundle.
- Authoritative inputs: `../ux/uiux-spec.md` §6.2 and §6.8 (exact values),
  `../requirements/requirements.md` AC-1..AC-11, this file section 4.
- Guardrails:
  - Do not edit any file listed in contract-summary §6, and do not add a header
    nav item or footer link. The `#press-kit` anchor is added on this page's own
    section; wiring the footer link to it is a deferred finding, not this story.
  - Do not wrap the body in a second `<main>` — the shell already renders
    `<main><slot/></main>`.
  - Do not wire the dark/light lockup swatches to `data-theme`; they are
    fixed-color brand documentation (uiux-spec §6.5) and must render both
    literal renderings under either site theme.
  - Do not build the on-page lockup swatches from the downloadable SVGs. The
    on-page swatch is inline markup (gradient tile + Material Symbols `favorite`
    glyph + wordmark) and is fidelity-gated; the SVGs are download payload and
    are not.
  - Do not translate the stat numbers or add a hover-lift the source does not
    specify.

## 5. Non-Functional Impact

- Accessibility raises two hard requirements beyond the prototype: the timeline
  must be a semantic ordered list, and the "Download kit" link must have a
  visible focus ring (uiux-spec §6.6). Neither exists in the source markup, and
  neither may be dropped for fidelity — they add no visual delta at rest.
- The press-kit bundle is committed binary/content in git. Keep it small (brand
  marks + palette + a short README), and keep the unzipped sources next to the
  zip so it stays regenerable without a build step.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Checked-in static bundle at `web/public/press-kit/` | AC-8 needs a real download target and REQ-006 is a static site with no backend (OQ-REQ006-2 RESOLVED) | ACCEPTED | Astro copies `public/` verbatim; zero build/CI change, zero new dependency |
| Generate the zip during `astro build` via an integration | Avoids committing a binary | REJECTED | Adds a dependency and a build step to a pipeline REQ-005 owns, to save a few KB — the bundling service is also explicitly out of scope in `requirements.md` |
