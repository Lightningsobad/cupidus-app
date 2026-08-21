# Phase P4 – Pet Sprite Components

## 1. Objective

Six inline-SVG Astro components — Bo, Bun, Kem, Mochi, Sua, Xoài — ported from
their design-source sprite files, usable by the Home pet-cast teaser and by
STORY-002's Pets page.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-pet-sprite-components.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: YES (runs alongside P2 and P3; needs only P1's tokens)
- Write Scope:
  - `web/src/components/sprites/BoSprite.astro`
  - `web/src/components/sprites/BunSprite.astro`
  - `web/src/components/sprites/KemSprite.astro`
  - `web/src/components/sprites/MochiSprite.astro`
  - `web/src/components/sprites/SuaSprite.astro`
  - `web/src/components/sprites/XoaiSprite.astro`
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
  - the six sprite components (`../architecture/contract-summary.md` §4)
- Shared Interfaces Consumed:
  - `web/src/styles/tokens.css` (P1)
- Risk Surfaces:
  - Inline-style fidelity
- Source Of Truth:
  - authoritative artifact: `cupid-app-design-system/{Bo,Bun,Kem,Mochi,Sua,
    Xoai} Sprite.dc.html`, default `<sc-if>` state only
  - consumer contract: `../architecture/contract-summary.md` §4
- Primary Inputs Summary:
  - requirements: UI-Fidelity-AC-6 (pet-cast section)
  - architecture: `../architecture/solution.md` §3 Assumptions (default sprite
    state only), §4 Frontend Lane guardrails
  - OQ constraints: none open
  - upstream phase outputs: P1 `tokens.css`
  - UX constraints: `../ux/uiux-spec.md` §6.2 item 3 (sprite sizes: 120px in the
    pet-cast grid, 170px and 130px in the hero mockup)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one SVG-port pattern applied to six pet variants
  - Source/Test File Count: 6
  - Split Required: NO
  - Split Rationale: six variants of one behavior cluster belong in one phase.

## 2. Required Reads

- `../architecture/solution.md` §3, §4 Frontend Lane
- `../architecture/contract-summary.md` §4
- `../ux/uiux-spec.md` §6.2 item 3 (sizes and trait labels)
- each sprite's `.dc.html` file, default state only

## 3. Tasks

- For each sprite, port only the markup inside the default/happy `<sc-if>`
  branch. The other states drive the mobile app's mood system and are out of
  scope for this site.
- Copy the `<svg>` subtree verbatim: same `viewBox`, same path data, same
  `fill`/`stroke` values, same inline `style` attributes, same `transform-origin`
  and `animation` declarations.
- Copy each sprite file's `@keyframes` from its `<helmet><style>` block into the
  component's scoped `<style>` block.
- Namespace every SVG `id` and every `url(#...)` reference per sprite (the
  sprite files reuse generic ids such as `boFurA`; six sprites on one page with
  colliding ids means the wrong gradient silently paints). Update the matching
  `url(#...)` references in the same file.
- Accept a size through props or a wrapper style so callers can render at 170px,
  130px, and 120px without editing the component.
- Give each component a meaningful accessible name using the pet's name — the
  pet identity is content, not decoration, per `../ux/uiux-spec.md` §6.6.
- Do not import or copy any file from `cupid-app-design-system/` into `web/`.

## 4. Acceptance Criteria

- Each of the six components renders its pet identically to the design source's
  default state at 120px, 130px, and 170px.
- All six render together on one page with no gradient, filter, or clip-path
  bleeding between them.
- Each sprite's idle animation runs, matching the source's keyframe timing.
- Each component exposes the pet's name as an accessible name.

## 5. Planned Outputs

- Code directories or files: the six components in `## 1B Write Scope`.
- Contracts or schemas: sprite component set published in
  `../architecture/contract-summary.md` §4.
- Notes or evidence: per-sprite render captures in `test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: web (static build, browser render)
- Required levels:
  - frontend build/type-check: `cd web && npm run build` and `npx astro check`
  - visual inspection: per-sprite capture pair (design source vs component) at
    120px, plus one capture of all six on a single page
- Required checks:
  - id-collision check: grep the six components for duplicate SVG `id` values
    across files — must return none
  - each `url(#...)` reference resolves to an id defined in the same file
- Minimum gates by risk surface:
  - Inline-style fidelity: each per-sprite capture pair matches, and the
    all-six capture shows no cross-sprite bleed
- Evidence format: capture pairs and grep output in
  `coding-plan/test-results.md`
- Verification strategy:
  - Build/type-check command: `cd web && npm run build && npx astro check`
  - Required assertion evidence: six capture pairs, the combined capture, and
    the id-collision grep result

## 7. Status

- Status: DONE
- Last updated: 2026-08-21
- Evidence: `coding-plan/test-results.md` → "Phase P4 — Pet Sprite Components".
  `npm run build` exit 0 (8 pages); `npx astro check` 22 files / 0 errors /
  0 warnings / 0 hints; 106/106 markup-equivalence assertions; 17/17 runtime
  DOM assertions; 6 SVG ids and 14 keyframe names, 0 collisions; 6/6 `url(#…)`
  refs resolve in-file and in the live DOM. All under node v22.17.1.
- Deviation 1 (Test Scope §6, capture pairs): the required "per-sprite capture
  pair" and "all-six capture" could not be produced — `render-design-canvas.js`
  and `render-running-app.js` do not exist in this repo, and the `.dc.html`
  sources are design-comp DSL exports, not runnable HTML, so there is no design
  side to screenshot. Per explicit handoff instruction this was substituted
  with a markup/attribute equivalence check that asserts each component's SVG
  subtree is byte-identical to its source default-state subtree once the id is
  un-namespaced. Substitution recorded in test-results.md Gate 3. Tracked at
  Scrum Master level (checkpoint BLOCKER 2); does not block P4.
- Deviation 2 (§3, "scoped `<style>` block"): keyframes were placed in
  `<style is:global>` instead. Every `animation:` declaration in these sprites
  is inside an inline `style` attribute, which Astro's scoped-style transform
  never rewrites, so a scoped keyframe name would be unreachable. `is:global`
  also matches the source, which keeps them in a document-level
  `<helmet><style>`. Safe because all 14 keyframe names are globally unique.
  Verified live: `getAnimations()` returns a `CSSAnimation` at the exact source
  duration for all six sprites.
- Deviation 3 (§3, "copy each sprite file's `@keyframes`"): only the keyframes
  the default state actually references were ported. Each source also declares
  a `*Zzz` keyframe used solely by its `isSleep` branch, which P4 does not
  port; shipping them would be dead CSS on every page. Ported declarations are
  byte-identical to the source.
- Note for P5: rendering the same sprite twice on one page (Home hero uses Bo
  at 170px, pet-cast grid uses Bo at 120px) duplicates that sprite's gradient
  id. Harmless — the duplicated definitions are identical. Demonstrated with
  three Bo instances at 120/130/170px, all painting correctly.
