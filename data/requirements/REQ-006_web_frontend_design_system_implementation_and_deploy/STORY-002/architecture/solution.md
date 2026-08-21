# STORY-002_pet_universe_showcase_page-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-21

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: strict visual fidelity to `Cupid Web.dc.html:213-283`
  (UI-Fidelity-AC); verbatim bilingual copy (BR-2/BR-3); zero shell mutation;
  static-only (no API, OQ-REQ006-2 RESOLVED).
- Architectural invariants / non-goals: this story adds **one page body plus its
  page-local components and one data module**. It does not touch `SiteLayout`,
  `SiteHeader`, `SiteFooter`, `tokens.css`, `global.css`, or the theme/lang boot
  script — any of those silently re-renders the other seven routes and
  invalidates their fidelity evidence.
- Proposed technical direction: replace the `web/src/pages/pets.astro` stub body
  with three page-local Astro components under `web/src/components/pets/`,
  driven by the already-merged `pets` array and a new `stages` array. Set the
  per-page `<title>` through `SiteLayout`'s existing `title` prop.
- Why this fits the current system: `web/src/components/home/` is the existing
  per-page component-folder convention, and `PetCast.astro` already establishes
  the "map the design source's own data array + `spriteFor` record" pattern this
  page repeats at a larger card scale.

### Key Discovery

Two assumptions in the upstream artifacts are already false in merged code, and
acting on them would produce duplicated or unnecessary work:

1. **The pet data does not need authoring.** `web/src/data/home-content.ts:45-52`
   already exports all six pets with exactly the `bg`, `color`, `tvi`/`ten`, and
   `dvi`/`den` values that `ux/uiux-spec.md` §6.2.2 tabulates — including the
   intentional Bo `.12` / Xoài `.1` pink-tint difference. STORY-001 deliberately
   carried `dvi`/`den` through even though Home's teaser card never renders them
   (see the comment above that array). STORY-002 **imports** this array; it must
   not re-author, re-copy, or fork it. A second copy of BR-2 copy is a drift
   source, not a safety measure.
2. **`SiteLayout` already accepts a `title` prop** (`web/src/layouts/SiteLayout.astro:11-17`,
   `title?: string` defaulting to `'Cupid'`, plus an optional `description`).
   DEF-2 / AC-6 therefore needs **no shell change** — only a prop at the call
   site. All eight routes currently pass nothing, so every page renders the
   default title; STORY-002 is simply the first page to pass one. The contract
   this story publishes is the naming convention, not new plumbing.

A third fact constrains the convention: `<title>` is a plain string in the
static HTML, while VI/EN switching is CSS-only over paired `data-vi`/`data-en`
spans. A bilingual document title is therefore **not expressible** without
adding JS to the shell boot script, which the STORY-001 contract forbids. The
title convention is single-language by construction — see section 4.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (per-page `<title>`
  convention and shared page-content data-module rule, both consumed by
  STORY-003…STORY-008).

## 3. Scope And Assumptions

- In Scope: `web/src/pages/pets.astro` body, `web/src/components/pets/*`,
  `web/src/data/pets-content.ts`.
- Out Of Scope: every shell file, every other route, all six sprite components
  (reused as-is), `tokens.css`/`global.css`, any network or persistence code.
- Assumptions affecting design: the six sprite components accept a `size` prop
  (`BoSprite.astro:5-7`, default `120`), so the 130×130 sprite box in
  `uiux-spec.md` §6.2.2 is `size={130}` — not a wrapper rescale.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `web/` (Astro static site), frontend lane only.
- New or changed boundaries: none. One new page-local component folder
  (`components/pets/`) and one new data module inside the existing `web/src/data/`
  boundary.
- Shared patterns reused: `SiteLayout` slot contract; `spriteFor` record keyed on
  the design source's own `dc` key (`components/home/PetCast.astro:14-21`);
  verbatim inline `style="…"` attributes; paired `data-vi`/`data-en` spans.

### Affected Modules

- Frontend: `web/src/pages`, `web/src/components/pets`, `web/src/data`.

### Contracts And Integrations

- Error / empty-state contract: none exists and none may be added. Content is
  statically complete (6 pets, 4 stages); there is no loading, empty, or error
  branch to write.
- Data-module placement decision: `stages` goes in a **new**
  `web/src/data/pets-content.ts`; `pets` is imported from the existing
  `home-content.ts`. Renaming `home-content.ts` to a neutral `site-content.ts`
  would be the tidier name but edits Home's four components and re-renders Home,
  invalidating STORY-001's fidelity evidence for a cosmetic gain. The module name
  is knowingly a misnomer after this story — recorded here so a later story can
  rename it once, deliberately, with Home re-verification budgeted.
- Per-page title convention (AC-6 / DEF-2, published to STORY-003…008):
  `title="<EN page label> — Cupid"`, em dash, EN label only, matching the
  header nav's EN label for that route. This page passes `title="Pets — Cupid"`.
  Single-language is a platform constraint, not a shortcut (section 1). The
  optional `description` prop is available but is **not** required by AC-6 and is
  not in this story's scope.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Pets page visual fidelity | `cupid-app-design-system/Cupid Web.dc.html:213-283`; `ux/uiux-spec.md` §6.2, §6.8 | Copy inline styles verbatim; no hover-lift on pet/stage cards (§6.7 anti-pattern); preserve the two-level `--surf` → `--c05` surface nesting | Rendered `/pets` compared against the `isPets` block at 375/768/1024/1440px, dark + light, evidence in `coding-plan/test-results.md` | Design-fidelity lock still points at `Cupid App.dc.html` (req_master Technical Constraints) — stop and report `DESIGN_SOURCE_LOCK_MISMATCH` |
| Verbatim copy integrity (BR-2/BR-3) | `Cupid Web.dc.html:741-747` (pets), `:756-760` (stages) | Import `pets` from `web/src/data/home-content.ts`; transcribe `stages` character-for-character including quotes and diacritics | Rendered VI and EN strings diffed against the two source arrays; no paraphrase, no normalized punctuation | Named line ranges not readable in the design source |
| Bilingual span completeness | STORY-001 `contract-summary.md` §3 | Every user-visible string ships both `data-vi` and `data-en`; the "Pet Universe" eyebrow is intentionally unpaired per §6.2.1 and must stay a literal | Toggle to EN on the rendered page: zero blank/collapsed strings; every VI string has an EN counterpart | Dev server cannot bind the port from `.env.devstack` |
| Shell immutability | STORY-001 `contract-summary.md` §6 | Page body only; sprite components consumed unmodified | `git -C <worktree> diff --name-only <BaseHead>` lists no `layouts/`, `components/shell/`, `styles/`, or `scripts/` path | n/a |
| Per-page document title (AC-6) | `web/src/layouts/SiteLayout.astro:11-17` | Pass `title="Pets — Cupid"` at the call site; no shell edit | Rendered `<title>` is `Pets — Cupid`, not the `Cupid` default | n/a |
| Responsive reflow (AC-7) | `ux/uiux-spec.md` §6.6, §6.8 | Fluid `auto-fit`/`minmax` only (330px pet floor, 180px stage floor); no new media query | 375/768/1024/1440px: no horizontal overflow, no overlap, no cell below its floor | n/a |
| Theme-independent pet tints (AC-5) | `ux/uiux-spec.md` §6.8 | Keep the six `rgba()` literals verbatim — they do not flip with theme, unlike the `--c*` tokens layered beneath them | Both themes rendered; every card tint legible and distinct against `--bg`/`--surf` | n/a |

### Lane Handoff

#### Frontend Lane

- Responsibilities: the whole story — page body, three page-local components, the
  `stages` data module, and the `title` prop at the call site.
- Authoritative inputs: `ux/uiux-spec.md` §6.2 (copy/style tables), §6.6-§6.8;
  `Cupid Web.dc.html:213-283`, `:741-747`, `:756-760`;
  `../STORY-001/architecture/contract-summary.md`.
- Guardrails:
  - Do not modify any file under `web/src/layouts/`, `web/src/components/shell/`,
    `web/src/styles/`, or `web/src/scripts/`.
  - Do not re-author, duplicate, or edit the `pets` array in `home-content.ts`;
    import it.
  - Do not reuse or retrofit Home's compact `PetCast` teaser card, and do not
    merge the Growth Stage cell with Home's `HowItWorks` step card — the UX spec
    names both as separate shapes at different scales.
  - Do not add hover-lift, `tabindex`, button semantics, `fetch`, `localStorage`,
    a new token, or a second styling system.
  - Pet sprite `alt`/label must carry the pet name; stage numerals stay
    decorative.
