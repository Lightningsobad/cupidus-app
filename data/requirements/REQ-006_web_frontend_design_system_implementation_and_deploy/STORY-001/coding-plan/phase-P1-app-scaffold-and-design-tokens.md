# Phase P1 – App Scaffold And Design Token Foundation

## 1. Objective

A runnable Astro static workspace at `web/` whose CSS foundation is a verbatim
port of the design source's token blocks and global rules, so every later phase
styles against identical custom properties.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-app-scaffold-and-design-tokens.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `web/package.json`
  - `web/astro.config.mjs`
  - `web/tsconfig.json`
  - `web/.gitignore`
  - `web/src/styles/tokens.css`
  - `web/src/styles/global.css`
- Impacted Runtime Service/App:
  - Name: `web-frontend`
  - Runtime Registry Id: `web-frontend` (created by P6; name it as planned here)
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: frontend
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `devCommand`
  - Readiness Check: N/A
  - Port Contract: per-project loopback host binding, claimed by P6
- Shared Interfaces Produced:
  - `web/src/styles/tokens.css` (`../architecture/contract-summary.md` §4)
  - `web/src/styles/global.css` bilingual + breakpoint rules (§3)
- Risk Surfaces:
  - Design token parity
  - Nav breakpoint hard swap
- Source Of Truth:
  - authoritative artifact: `cupid-app-design-system/Cupid Web.dc.html` lines
    16–27
  - consumer contract: `../architecture/contract-summary.md` §3, §4
- Primary Inputs Summary:
  - requirements: AC-1
  - architecture: `../architecture/solution.md` §1, §4
  - OQ constraints: OQ-REQ006-1 resolved — Astro static, no CSS framework
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO (P6 owns it)
- Phase Sizing:
  - Behavior Slice: workspace scaffold + CSS foundation
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md`
- `../architecture/solution.md` §1, §3, §4
- `../architecture/contract-summary.md` §3, §4
- `cupid-app-design-system/Cupid Web.dc.html` lines 16–27 only

## 3. Tasks

- Scaffold a minimal Astro project in `web/` with `output: 'static'`. Take
  dependency versions from the lockfile the scaffold generates; do not hand-pin
  versions from memory.
- Install no CSS framework, UI kit, or client framework integration. The
  dependency list should contain Astro and its TypeScript tooling only.
- Copy `Cupid Web.dc.html` line 16 into `tokens.css` as the `body{...}` rule
  (dark base, including `margin:0`) and line 17 as
  `body[data-theme="light"]{...}`. Copy the declarations byte-for-byte: same
  property names, same values, same order. Do not add, rename, reformat values,
  or introduce a `:root` indirection.
- Copy `Cupid Web.dc.html` lines 18–27 into `global.css`: the `a` rules, the
  `[data-icon]` font rule, the three bilingual visibility rules, the `floaty`
  and `twinkle` keyframes, the `summary::-webkit-details-marker` rule, and both
  nav media queries (`max-width:1024px`, `min-width:1025px`).
- Verify the port by counting declarations: every custom property present in
  the source's dark block must exist in `tokens.css`, and the light block must
  override exactly the same property names the source overrides.

## 4. Acceptance Criteria

- `web/` builds to static HTML with no client framework in the dependency tree.
- `tokens.css` selectors are exactly `body` and `body[data-theme="light"]` — a
  page with no JavaScript renders the dark theme correctly.
- Every custom property in `Cupid Web.dc.html:16` exists in `tokens.css` with an
  identical value; no property was added, renamed, or reordered.
- `global.css` contains both nav media queries with the exact 1024px/1025px
  boundaries and the three `[data-vi]`/`[data-en]` rules unchanged.

## 5. Planned Outputs

- Code directories or files: the six paths in `## 1B Write Scope`.
- Contracts or schemas: `tokens.css` and `global.css` as published by
  `../architecture/contract-summary.md` §3–§4.
- Notes or evidence: token-parity diff recorded in `test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: web (static build)
- Required levels:
  - frontend build/type-check: `cd web && npm run build` and `npx astro check`
  - visual inspection: none yet — nothing is rendered in this phase
- Required checks:
  - token-parity diff: list every custom property in `Cupid Web.dc.html:16` and
    confirm a matching name+value in `tokens.css`; repeat for line 17 against
    the light block
  - grep `tokens.css` for `:root` and for any property name absent from the
    source — both must return nothing
- Minimum gates by risk surface:
  - Design token parity: the diff above shows zero missing, added, or altered
    properties
  - Nav breakpoint hard swap: `global.css` contains `@media (max-width:1024px)`
    and `@media (min-width:1025px)` verbatim
- Evidence format: command output plus the token-parity diff, appended to
  `coding-plan/test-results.md`
- Verification strategy:
  - Build/type-check command: `cd web && npm run build && npx astro check`
  - Required assertion evidence: build exit code 0 and the token-parity diff

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-21
