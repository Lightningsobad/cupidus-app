# Phase P1 – Invite Page Body And Entry Point

## 1. Objective

Fill the body of the existing `/share` route with the six sections of the design
source's `isShare` state, set the page's own `<title>`, and prove the page is
reachable from the shared header's "Invite" nav item — without touching any
STORY-001 shell file.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-invite-page-body-and-entry-point.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `web/src/pages/share.astro`
  - `web/src/components/share/InviteHero.astro`
  - `web/src/components/share/PairingSequence.astro`
  - `web/src/components/share/InviteSteps.astro`
  - `web/src/components/share/KeepsakeCards.astro`
  - `web/src/data/share-content.ts`
- Impacted Runtime Service/App:
  - Name: `web-frontend`
  - Runtime Registry Id: `web-frontend`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: frontend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand` (`npm run build`)
  - Startup Command Source: runtime registry `devCommand` (`npm run dev`)
  - Readiness Check: N/A for this phase
  - Port Contract: per-project loopback host binding (`DEVSTACK_PORT_WEB`)
- Shared Interfaces Consumed:
  - `SiteLayout.astro` props `page: PageKey` and `title?: string`
  - `MochiSprite.astro` prop `size`
  - `tokens.css` custom properties, `global.css` `[data-icon]` and
    `@keyframes floaty`
- Risk Surfaces:
  - Shell freeze
  - Non-functional code cells and CTA
  - Bilingual copy completeness
  - Per-page title
  - Visual fidelity to `isShare`
  - Token-only styling
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §6.2 (every measurement, color,
    and string, each citing its `Cupid Web.dc.html` line range)
  - consumer contract: none published by this phase
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-1..AC-10, UI-Fidelity-AC-9
  - architecture: `../architecture/solution.md` §1 Key Discovery, §4
  - UX constraints: `../ux/uiux-spec.md` §6.2, §6.5, §6.6, §6.8
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one page body — six design-source sections that all compose
    into the same route file.
  - Source/Test File Count: 6
  - Split Required: NO
  - Split Rationale: fits one specialist lifecycle, and any split would put the
    same `share.astro` composition in two phases.

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md` §6.2, §6.5, §6.6, §6.8
- `cupid-app-design-system/Cupid Web.dc.html:387-451`
- `web/src/components/home/HowItWorks.astro` and `web/src/components/home/Hero.astro`
  as the STORY-001 pattern reference (content module, inline styles, scoped
  hover/focus block)

## 3. Tasks

- Create `web/src/data/share-content.ts` holding the repeated content sets: the
  six hero code-cell letters `["C","U","P","1","D","7"]`, the three explainer
  steps (icon, icon color token, VI/EN title, VI/EN body), and the three
  keepsake cards (tag label, tag color token, background gradient, big value,
  VI/EN sub-copy). Mirror `home-content.ts`'s shape and naming.
- Build `InviteHero.astro`: eyebrow, 54px H1, subcopy, the six static code
  cells, and the "Open Cupid" CTA, per uiux-spec §6.2.1-§6.2.3. Cells are
  `<div>` elements with static text; the CTA is `<a href="#">`.
- Build `PairingSequence.astro`: both 250x500 device frames plus the connector,
  per uiux-spec §6.2.4. Left mockup ships exactly three filled cells (`C`,`U`,`P`)
  and three empty ones; right mockup uses `<MochiSprite size={150} />` and the
  mint label. Nothing inside either frame is focusable.
- Build `InviteSteps.astro` from this page's own three-step copy set. Do not
  import `steps` from `home-content.ts`.
- Build `KeepsakeCards.astro`: panel heading, description, and the three
  `aspect-ratio:1` sample cards with per-card gradients and literal tag labels.
- Compose all four sections in `web/src/pages/share.astro` inside the existing
  `<SiteLayout page="share">`, and add `title="Cupid — Ghép đôi"`.
- Add one `<style is:global>` block (pattern: `Hero.astro:69-77`) carrying the
  CTA `:hover` brightness/filter lift with `!important` where it must beat an
  inline declaration, plus a `:focus-visible` outline using `var(--acc-pink)`.
  Add no other rule and no rule targeting a code cell or mockup chrome.
- Produce the design reference for the review gate by running
  `render-design-canvas.js` with `--location` pointed at this worktree's
  `cupid-app-design-system`, `--entry="Cupid Web.dc.html"`, `--screen=share`,
  `--platform=all`. The tool ships in the control checkout at
  `.ai-team-bundle/runtime/tools/render-design-canvas.js` and is not present in
  the story worktree; invoke it by absolute path and write the output inside the
  worktree. If it cannot run, stop and report
  `DESIGN_REFERENCE_RENDER_UNAVAILABLE` with the verbatim error.

## 4. Acceptance Criteria

- All ten story ACs hold on the built page.
- `git diff --name-only <BaseHead>` touches only the six files in Write Scope
  plus this story's `data/` artifacts.
- `dist/share/index.html` contains no `<input`, adds no `tabindex`, and its
  `<title>` is `Cupid — Ghép đôi`, distinct from `dist/index.html`'s.
- `data-vi` and `data-en` occurrence counts are equal in `dist/share/index.html`.
- No new custom property is defined anywhere in the diff.

## 5. Planned Outputs

- Code: the six files in Write Scope.
- Notes or evidence: `coding-plan/test-results.md` with build, check, copy
  parity, interactivity, and title evidence; the rendered
  `design-reference-share-*.png` for the reviewer.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: `web-frontend` (Astro static build, `/share`)
- Required levels:
  - frontend build/type-check: `npm run check` and `npm run build` in `web/`,
    under Node >= 22.12.0
  - visual inspection: `/share` at 375, 768, 1024, 1440 px in all four
    theme x language combinations (dark/light x vi/en)
- Required checks:
  - Shell freeze: changed-file list contains nothing under `web/src/layouts/`,
    `web/src/components/shell/`, `web/src/styles/`, `web/src/scripts/`.
  - Interactivity: no `<input>`, no added `tabindex`; keyboard tabbing through
    `/share` reaches the "Open Cupid" CTA with a visible focus ring and stops
    at no code cell or mockup element.
  - Copy parity: equal `data-vi` / `data-en` counts; switching to EN leaves no
    blank region.
  - Title: `<title>` value and distinctness from Home.
  - Fidelity spot-checks: H1 is 54px (not Home's 66px); left mockup label uses
    the neutral token and right uses `--acc-mint`; left code row shows 3 filled
    + 3 empty cells.
  - Reflow: at 375 px the two mockups stack and the connector badge stays
    centered between them rather than orphaning to one side.
- Frontend discoverability / navigation integration: from `/`, activating the
  header's "Invite" item (desktop pill nav) and selecting `Invite` in the mobile
  `<select>` both land on `/share` with the nav item shown active; direct URL
  load of `/share` renders the same page.
- Minimum gates by risk surface: see `../architecture/solution.md` §4
  `Risk Surfaces And Source Of Truth`.
- Required runtime signals: browser console clean of errors and warnings on
  `/share` in both languages.
- Evidence format: commands with exit codes, grep/count outputs, and screenshots
  recorded in `coding-plan/test-results.md`.
- Requirement frontend visual audit: YES — `/share` against
  `design-reference-share-*.png` for UI-Fidelity-AC-9.

## 7. Status

- Status: BLOCKED
- Last updated: 2026-08-21
- Implementation: COMPLETE. All six Write Scope files are written; Tasks 1-7 of
  §3 are done. `npm run check` and `npm run build` both pass under Node
  v22.17.1, and every §6 required check (shell freeze, interactivity, copy
  parity, title, fidelity spot-checks, reflow, console cleanliness, entry-point
  reachability) passes. Evidence: `test-results.md` §1-§6.
- Blocked on: Task 8 only — `DESIGN_REFERENCE_RENDER_UNAVAILABLE`.
  `render-design-canvas.js --screen=share` cannot target `Cupid Web.dc.html`:
  that entry is a full-viewport web prototype with no `[data-screen-btn]`,
  `[data-tog]`, or `[data-plat]` device frames (`--list-screens` returns empty
  for all three), so the tool exits
  `DESIGN_CANVAS_SCREEN_MISSING: 'share' is not a screen on this canvas`.
  Playwright was provisioned successfully first, so this is not an install
  defect. Resolving it needs tool support for non-device web canvases (or an
  agreed alternative UI-Fidelity-AC-9 anchor), which is outside this phase's
  six-file Write Scope. Full detail and verbatim output: `test-results.md` §7.
