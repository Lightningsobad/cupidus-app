# Phase P1 – Pets Page Body And Entry-Point Wiring

## 1. Objective

`/pets` renders the full Pet Universe showcase — hero, six-card pet roster,
four-stage growth explainer — visually identical to `Cupid Web.dc.html:213-283`,
with the "Pets" nav item active and a distinct document title, inside the
unmodified STORY-001 shell.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-pets-page-body-and-entry-point.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `web/src/pages/pets.astro` (replace stub body)
  - `web/src/components/pets/PetsHero.astro` (new)
  - `web/src/components/pets/PetRoster.astro` (new)
  - `web/src/components/pets/GrowthStages.astro` (new)
  - `web/src/data/pets-content.ts` (new)
- Impacted Runtime Service/App:
  - Name: `web`
  - Runtime Registry Id: `web-frontend`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: frontend
  - Startup Smoke: OPTIONAL (dev server is needed only to render the page for
    visual inspection; it is not a gate for this phase)
  - Build Command Source: runtime registry `buildCommand` (`npm run build`)
  - Startup Command Source: runtime registry `devCommand` (`npm run dev`)
  - Readiness Check: `GET http://127.0.0.1:${DEVSTACK_PORT_WEB}/pets` → 200
  - Port Contract: per-project loopback host binding, port from `.env.devstack`
- Shared Interfaces Produced:
  - `../architecture/contract-summary.md` §2 (per-page `<title>` convention)
  - `web/src/data/pets-content.ts` → `stages`
- Shared Interfaces Consumed:
  - `../../STORY-001/architecture/contract-summary.md` (SiteLayout envelope,
    route keys, `data-vi`/`data-en` mechanism, token rules, shell prohibitions)
  - `web/src/data/home-content.ts` → `pets`
  - `web/src/components/sprites/{Bo,Bun,Kem,Mochi,Sua,Xoai}Sprite.astro`
- Risk Surfaces:
  - Pets page visual fidelity
  - Verbatim copy integrity (BR-2/BR-3)
  - Bilingual span completeness
  - Shell immutability
  - Per-page document title (AC-6)
  - Responsive reflow (AC-7)
  - Theme-independent pet tints (AC-5)
- Source Of Truth:
  - authoritative artifact or convention: `cupid-app-design-system/Cupid Web.dc.html`
    `:213-283` (markup/styles), `:741-747` (pets), `:756-760` (stages);
    `../ux/uiux-spec.md` §6.2 tables restate the same values measured out
  - consumer contract: `../architecture/contract-summary.md`
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-1…AC-7, UI-Fidelity-AC,
    BR-1…BR-3
  - architecture: `../architecture/solution.md` §1 Key Discovery, §4
  - UX constraints: `../ux/uiux-spec.md` §6.2 (copy/style tables), §6.6-§6.8
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one page body plus the components only that page mounts
  - Source/Test File Count: 5
  - Split Required: NO
  - Split Rationale: within the roughly-six-file specialist lifecycle cap; the
    three components share one fidelity gate against one design-source block and
    are verified in a single rendered pass

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md` and `../architecture/contract-summary.md`
- `../../STORY-001/architecture/contract-summary.md`
- `../ux/uiux-spec.md` §6.2, §6.6, §6.7, §6.8
- `cupid-app-design-system/Cupid Web.dc.html` lines 213-283, 741-747, 756-760
  (ranged reads only — this is a large file)

## 3. Tasks

1. Create `web/src/data/pets-content.ts` exporting a typed `stages` array of the
   four growth stages (`n`, `tvi`, `ten`, `dvi`, `den`), transcribed
   character-for-character from `Cupid Web.dc.html:756-760`. Mirror the type
   style already used in `home-content.ts`. Do **not** re-declare `pets` here.
2. Create `PetsHero.astro`: single column, `max-width:640px`, section padding
   `70px 32px 90px`. Eyebrow renders the literal string `Pet Universe`
   **unwrapped** (no `data-vi`/`data-en` — intentional, per uiux §6.2.1). H1 and
   subcopy each ship both spans with the exact VI/EN strings from uiux §6.2.1.
3. Create `PetRoster.astro`: import `pets` from `../../data/home-content`, reuse
   the `spriteFor` record pattern from `components/home/PetCast.astro:14-21`
   keyed on `p.dc`, and render `<Sprite size={130} />`. Grid
   `repeat(auto-fit,minmax(330px,1fr))`, `gap:20px`, `margin-top:40px`. Card:
   `background:{p.bg}; border:1px solid var(--c11); border-radius:30px;
   padding:28px; display:flex; gap:22px; align-items:center`, sprite box
   `flex:0 0 130px`. Text block: name (Nunito 900 26px `var(--ink)`), trait tag
   (Roboto Mono 10px, `letter-spacing:.1em`, uppercase, `margin:4px 0 10px`,
   `color:{p.color}`, both spans), description (13.5px/1.6 `var(--c66)`, both
   spans). Give each sprite an accessible name carrying the pet name. No hover
   rule, no `tabindex`, no button semantics.
4. Create `GrowthStages.astro`: outer panel `margin-top:40px;
   background:var(--surf); border:1px solid var(--c09); border-radius:30px;
   padding:34px`; header "Bốn giai đoạn lớn lên" / "Four stages of growth"
   (Nunito 800 22px). Inner grid `margin-top:22px;
   repeat(auto-fit,minmax(180px,1fr)); gap:16px`; cell
   `background:var(--c05); border:1px solid var(--c09); border-radius:20px;
   padding:18px` with numeral (Roboto Mono 10px `var(--acc-pink)`), title
   (Nunito 800 16px, `margin:6px 0 6px`), description (12.5px/1.55
   `var(--c58)`). Keep the two-level surface nesting; do not flatten it.
5. Rewrite `web/src/pages/pets.astro` to
   `<SiteLayout page="pets" title="Pets — Cupid">` wrapping the three components
   in design order, with section content constrained to
   `max-width:1200px;margin:0 auto`. This is the entry-point wiring: `page="pets"`
   is what drives the header pill's active treatment, `aria-current="page"`, and
   the mobile `<select>` selection.
6. Verify no file under `web/src/layouts/`, `web/src/components/shell/`,
   `web/src/styles/`, or `web/src/scripts/` was touched, and that
   `home-content.ts` is unchanged.

## 4. Acceptance Criteria

- AC-1: on `/pets`, the header "Pets" pill and the mobile `<select>` both show
  the active treatment with `aria-current="page"`; all four existing entry
  affordances still navigate to a page that now has real content.
- AC-2/AC-3/AC-4: hero copy, all six pet cards in design order (Bo, Bun, Kem,
  Mochi, Sua, Xoài) with sprite + name + trait + description, and all four stages
  in order render with copy matching the design source verbatim in VI and EN.
  No omission, no reorder, no placeholder.
- AC-5: dark↔light and VI↔EN both produce a complete, correct page; no blank
  string in either language; pet tints stay legible in both themes.
- AC-6: rendered `<title>` is `Pets — Cupid`.
- AC-7: at 375/768/1024/1440px there is no horizontal overflow, no overlap, and
  no pet card below 330px or stage cell below 180px.
- UI-Fidelity-AC: rendered `/pets` matches the `isPets` block of
  `Cupid Web.dc.html` at matching viewports in layout, spacing, color,
  typography, and imagery.
- `npm run check` and `npm run build` both pass in `web/`.
- `git diff --name-only <BaseHead>` contains no shell path and no
  `home-content.ts`.

## 5. Planned Outputs

- Code: the five files in `Write Scope`.
- Contracts: `../architecture/contract-summary.md` realized at its first call
  site (`title="Pets — Cupid"`, `stages` module).
- Notes or evidence: `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Astro static web, route `/pets`
- Required levels:
  - frontend build/type-check: `npm run check` then `npm run build` in `web/`
    (registry `web-frontend`; Node >=22.12.0 — do not rely on ambient node)
  - visual inspection: rendered `/pets` at 375, 768, 1024, 1440px, in dark and
    light, in VI and EN
- Required checks:
  - Copy diff: every rendered VI/EN string against `Cupid Web.dc.html:741-747`
    and `:756-760` and uiux §6.2 tables — exact, including diacritics and
    punctuation
  - Six pet cards present, in design order, none with placeholder content
  - Four stages present, in order
  - Bo (`.12`) and Xoài (`.1`) pink tints remain distinct — not "corrected" to
    the same value
  - No hover-lift on pet or stage cards
  - Shell files and `home-content.ts` unmodified in the diff
- Frontend discoverability / navigation integration: from `/`, click the header
  "Pets" pill, the footer "Pets" link, and Home's "Meet them all" CTA; each
  lands on the populated page with the nav item marked active. Repeat the header
  path below 1024px through the mobile `<select>`.
- Minimum gates by risk surface:
  - Pets page visual fidelity → four-viewport × two-theme rendered comparison
  - Verbatim copy integrity → copy diff above
  - Bilingual span completeness → EN toggle with zero blank strings
  - Shell immutability → diff path check
  - Per-page document title → rendered `<title>` assertion
  - Responsive reflow → four-viewport overflow check
  - Theme-independent pet tints → both-theme render
- Required regression coverage: Home (`/`) still renders its pet-cast teaser
  cards unchanged, since `pets` is now shared — one rendered check, not a full
  Home re-audit.
- Required runtime signals: browser console clean on `/pets` (no errors, no 404
  for sprite or font assets).
- Evidence format: `coding-plan/test-results.md` — command output for
  `npm run check` / `npm run build`, plus per-viewport and per-theme observations
  with the design-source line range each one was compared against.
- Requirement frontend visual audit: YES — this story feeds the requirement-level
  `frontend-dev` `Mode: requirement-visual-audit` and the full UI-lane review
  gate; the phase-level inspection above does not replace either.
- Verification strategy:
  - Targeted checks: the copy diff, the discoverability walk, and the
    four-viewport reflow check
  - Build/type-check command: `npm run check && npm run build` in `web/`
  - Required assertion evidence: rendered `<title>`, span-pair completeness,
    and the diff path check, all recorded in `test-results.md`

## 7. Status

- Status: COMPLETE
- Last updated: 2026-08-21
- Evidence: `coding-plan/test-results.md`
- Gates: `npm run check` PASS, `npm run build` PASS, 67 structural/copy-diff
  assertions PASS, 16 rendered viewport×theme×language passes PASS, diff path
  check PASS (no shell path, no `home-content.ts`)
