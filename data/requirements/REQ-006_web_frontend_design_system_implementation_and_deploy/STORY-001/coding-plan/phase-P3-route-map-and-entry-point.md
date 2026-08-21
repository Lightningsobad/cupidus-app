# Phase P3 – Route Map And Entry Point

## 1. Objective

All eight REQ-006 routes exist as real, pre-rendered pages mounted in the shell,
reachable through the header nav and footer, with none returning 404. This is
the entry-point phase: it is what makes the capability discoverable rather than
merely built.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-route-map-and-entry-point.md`
- Owner: Frontend Developer
- Lane: Frontend

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `web/src/pages/index.astro`
  - `web/src/pages/pets.astro`
  - `web/src/pages/zodiac.astro`
  - `web/src/pages/share.astro`
  - `web/src/pages/blog.astro`
  - `web/src/pages/about.astro`
  - `web/src/pages/support.astro`
  - `web/src/pages/legal.astro`
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
  - the eight route files STORY-002…STORY-008 fill in
    (`../architecture/contract-summary.md` §2, §5)
- Shared Interfaces Consumed:
  - `SiteLayout` and its `page` prop union (P2)
- Risk Surfaces:
  - Route reachability
  - Theme/lang boot before first paint
  - Language persistence across document loads
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §6.3 Route Map
  - consumer contract: `../architecture/contract-summary.md` §2, §5
- Primary Inputs Summary:
  - requirements: AC-5
  - architecture: `../architecture/solution.md` §4 Risk Surfaces
  - OQ constraints: none open
  - upstream phase outputs: P2 shell
  - UX constraints: `../ux/uiux-spec.md` §6.3 only
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one route pattern applied to eight route keys
  - Source/Test File Count: 8 files, of which 7 are the same few-line stub —
    one behavior cluster, one specialist lifecycle
  - Split Required: NO
  - Split Rationale: splitting would repeat one pattern across sibling phases,
    which the planning rules forbid.

## 2. Required Reads

- `../requirements/requirements.md` (AC-5)
- `../architecture/contract-summary.md` §2, §5
- `../ux/uiux-spec.md` §6.3

## 3. Tasks

- Create one page per route key using the exact key→path mapping in
  `../architecture/contract-summary.md` §2. Each page renders `<SiteLayout
  page="<key>">` and, for the seven non-Home routes, an empty `<main>` body.
- `index.astro` is the `/` route with `page="home"`; its body stays empty in
  this phase and is filled by P5.
- Leave the seven non-Home bodies genuinely empty. Do not add a placeholder
  heading, "coming soon" copy, a skeleton, or a redirect — those are content the
  design source does not have, and each owning story replaces the body wholesale.
- Confirm the header's active-pill styling and the mobile `<select>`'s selected
  option follow the `page` prop on every route.
- Confirm `/legal` is reachable from the footer only. Do not add it to the
  header nav.

## 4. Acceptance Criteria

- The build emits eight HTML files at `/`, `/pets`, `/zodiac`, `/share`,
  `/blog`, `/about`, `/support`, `/legal`.
- Every header nav item, the logo, the "Get the app" CTA, and every footer link
  resolves to one of those eight routes; none 404s.
- On each route the correct nav item is visually active and carries
  `aria-current="page"`.
- Theme and language chosen on one route are still active after navigating to
  another route.
- Passing an unknown `page` value fails `astro check`.

## 5. Planned Outputs

- Code directories or files: the eight page files in `## 1B Write Scope`.
- Contracts or schemas: route map published in
  `../architecture/contract-summary.md` §2, now implemented.
- Notes or evidence: link-resolution results and the cross-route persistence
  check in `test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: web (static build, browser render)
- Required levels:
  - frontend build/type-check: `cd web && npm run build` and `npx astro check`
  - visual inspection: active-nav state captured on two routes (one header
    route, plus `/legal` reached from the footer)
- Required checks:
  - build output contains exactly the eight expected HTML files
  - link-resolution: enumerate every `href` in the built header and footer and
    confirm each maps to an emitted file
  - cross-route persistence: set light + EN on `/`, navigate to `/pets` and
    `/legal`, confirm both survive
  - negative type check: a page passing an invalid `page` value fails
    `astro check`
- Frontend discoverability / navigation integration: this phase IS the
  discoverability wiring — the header's seven items plus the footer's `legal`
  links are the full navigation surface, matching the design source exactly.
  No route is direct-URL-only.
- Minimum gates by risk surface:
  - Route reachability: eight files emitted, zero unresolved links
  - Theme/lang boot, Language persistence: cross-route check passes
- Evidence format: build file listing, link-resolution table, and check results
  in `coding-plan/test-results.md`
- Verification strategy:
  - Build/type-check command: `cd web && npm run build && npx astro check`
  - Required assertion evidence: the eight-file listing and the
    link-resolution table

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-21
