# STORY-001 Frontend App Foundation & Home Landing Page — solution.md

## 0. Metadata

- Complexity: standard (shared-foundation, Implementation Lane `shared`)
- Date: 2026-08-21

## 1. Decision Summary

- Mode: Greenfield (`research architecture` branch — no web frontend exists in
  the runnable foundation; `backend/` NestJS and `mobile/` are unrelated lanes)
- Architecture Drivers: pixel/visual fidelity to a fixed HTML/CSS design export
  ("giống 100%", UI-Fidelity-AC-6) outranks every other quality here; no API
  (OQ-REQ006-2 RESOLVED); 8 routes, 7 of them owned by later stories; deploy
  must reuse the REQ-005 GitHub Actions → VPS pattern.
- Architectural invariants:
  - The design source's per-element `style="..."` attributes are copied
    **verbatim** into the app. No utility-CSS rewrite, no Tailwind, no CSS-in-JS
    object syntax, no "equivalent" refactor of a style string.
  - Zero client-side framework runtime. The only shipped JS is the design
    source's own theme/language logic.
  - Zero network calls at runtime beyond the two Google Fonts stylesheets the
    design source already loads.
- Non-goals: SSR, any API/data layer, an i18n routing scheme, a component
  library, a CSS framework.
- Proposed technical direction: **Astro, static output** (`output: 'static'`),
  new `web/` workspace, 8 pre-rendered HTML routes, shell as an Astro layout,
  theme/lang as one render-blocking vanilla script. Resolves OQ-REQ006-1.
- Why this fits: `.astro` templates are an HTML superset, so a `style="..."`
  attribute pastes across unchanged and untranslated. That single property is
  the whole decision — it removes the largest fidelity risk (hand-translating
  hundreds of inline style strings) instead of mitigating it. File-based routing
  gives the 8 real routes AC-5 needs, and static output means the deployed
  artifact is a directory of HTML/CSS that the REQ-005 VPS pattern can ship
  without a container runtime.

### Key Discovery

Three findings from reading the design source changed the shape of this plan:

1. **`Cupid Web.dc.html` is not runnable HTML.** It is a design-comp template
   DSL: `{{ expr }}` bindings, `<sc-for list>`, `<sc-if value>`, `<dc-import
   name="Bo Sprite">`, `<x-dc>`/`<helmet>` wrappers, and a `<script
   type="text/x-dc">` `DCLogic` class (line 680). It cannot be copied wholesale
   and cannot be served. But ~95% of its *visual* weight is plain inline
   `style="..."` — portable byte-for-byte. So the port is a **mechanical
   transpile of a small, enumerable DSL surface** around a verbatim style core,
   not a reimplementation. Every phase below is scoped by that split.
2. **AC-4 language persistence is unsatisfiable by copying the source.** The
   prototype is a single-page state machine — `nav(page)` only calls
   `setState` + `scrollTo` (line 705), never a document load — so its in-memory
   `lang` survives "navigation" there. On a real multi-page static site every
   nav is a document load, so AC-4's "language selection persists across
   navigation" **requires** persistence that the source does not have. UX spec
   §6.4 warns against adding persistence beyond the source; that warning is
   correct about *visual* fidelity and wrong about this case. Decision: persist
   language to `localStorage["cupid-web-lang"]`, mirroring the source's own
   `localStorage["cupid-web-theme"]` (line 686/702). Nothing rendered changes,
   so this is not a fidelity deviation — it is the multi-page equivalent of the
   source's SPA behavior. Recorded here so Reviewer does not read it as scope
   creep.
3. **Dark is the no-JS default, light is the only flashable theme.** Dark tokens
   sit on bare `body{...}` (line 16); light overrides on
   `body[data-theme="light"]` (line 17). So a user with no JS, or before the
   boot script runs, gets a correct dark render. Only a user who chose light can
   see a flash — which is exactly why the boot script must be render-blocking
   and the first child of `<body>` (it writes `document.body.dataset`, so it
   cannot live in `<head>`).

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` — the shell/route/token
  contract STORY-002…STORY-008 build their pages against.

## 3. Scope And Assumptions

- In Scope: `web/` Astro workspace, design-token + global CSS port, shell
  (header/footer/backdrop/theme+lang boot), 8 routes, Home page body, 6 pet
  sprite components, `web-frontend` runtime registry entry, GitHub Actions →
  VPS deploy for `cupidus.app`.
- Out Of Scope: body content of the 7 non-Home routes, any API layer, any
  change to `backend/` or `mobile/`.
- Assumptions affecting design:
  - The `accent` prototype prop is fixed at its default `#FF7FB6` (line 711);
    `{{ accent }}` interpolations are replaced by that literal, not by a
    configurable token.
  - Only the default/happy `<sc-if>` state of each sprite file is ported; the
    other sprite states belong to the mobile app, not this site.
  - The design-fidelity lock still points at `Cupid App.dc.html`
    (`data/devops/system/design-fidelity-config.json`). Re-pointing it to the web
    canvas is Product Owner + Scrum Master work in flight and is **not** a
    dependency of any phase below — it only gates the Reviewer visual gate.
    Note for whoever re-points it: the web canvas exposes page states through a
    `startPage` **prop enum** (line 679), not through canvas screen nodes, so the
    mobile `--screen=<id>` capture mechanism does not transfer unchanged.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| OQ-REQ006-1 | RESOLVED here | none after this document | all | Astro static (section 1, section 6) |
| OQ-REQ006-2 | RESOLVED (PO) | any API/data layer | static build only | no fetch, no runtime backend dependency |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: new `web/` workspace, sibling to `backend/` and `mobile/`. It
  shares no code, no build, and no dependency graph with them.
- New boundaries: `web/` ↔ VPS static root (`cupidus.app`); `web/` ↔ read-only
  `cupid-app-design-system/` (input to humans/agents at authoring time only —
  never imported, bundled, or copied into the build).
- Shared patterns reused: REQ-005's `.github/workflows/deploy-backend.yml` +
  `.github/workflows/scripts/vps-deploy.sh` SSH/secret shape; the devstack
  reserved-port contract for the local dev server.

### Affected Modules

- Frontend: `web/` (new). Infrastructure: `.github/workflows/`, `scripts/`,
  `data/devops/system/runtime-command-registry.json`.

### Fidelity Baseline (authoritative for every visual gate in this story)

The design source declares its own canvas: `$preview {width:1440, height:900}`,
`theme` default `dark`, `lang` default `vi`, `accent` default `#FF7FB6`
(line 679). Those are the baseline capture conditions — a capture taken under
any other conditions is not evidence for UI-Fidelity-AC-6.

- Primary pair: **1440×900, `data-theme="dark"`, `data-lang="vi"`**, one capture
  from the design source and one from the built app, per section.
- Shell second pass: 1440×900, light × EN (proves all four AC-4 combinations
  render, per UX §6.4).
- Responsive checkpoints: 375, 768, **1024 and 1025** (the hard nav swap),
  1440.

### Contracts And Integrations

- No runtime error/retry/timeout contract exists — there are no async operations.
  The only failure mode is `localStorage` being unavailable; both reads are
  wrapped in `try/catch` exactly as the source does (line 686), falling back to
  dark/VI.
- External trust boundary: two Google Fonts stylesheets (lines 11–14). Their
  URLs are copied byte-identical. Self-hosting or subsetting the fonts is
  forbidden — different font binaries mean different glyph metrics, which is a
  silent, page-wide fidelity failure.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Design token parity | `Cupid Web.dc.html:16-17` | copy both blocks verbatim into `tokens.css`; keep the selectors `body{}` and `body[data-theme="light"]` unchanged | every custom property in lines 16–17 is present with an identical value; no property added or renamed | `DESIGN_TOKEN_PARITY_UNVERIFIABLE` |
| Inline-style fidelity | per-element `style="..."` in the design source | paste style attributes verbatim; never re-express as classes, utilities, or shorthand | section capture pair at the Fidelity Baseline is visually identical | `VISUAL_BASELINE_UNRENDERABLE` |
| Hover-state fidelity | the **17** `style-hover="..."` attributes in the design source | each becomes one real CSS `:hover` rule in the owning component's scoped `<style>`; no consolidation across elements | 17 `:hover` rules exist and each is exercised in a hover capture | `HOVER_STATE_UNVERIFIED` |
| Nav breakpoint hard swap | `Cupid Web.dc.html:26-27` | copy the two media queries verbatim into `global.css`; no extra breakpoints | 1024 shows the `<select>`, 1025 shows the pill row, nothing in between | `RESPONSIVE_CAPTURE_UNAVAILABLE` |
| Theme/lang boot before first paint | `componentDidMount`, lines 683–691 | render-blocking inline script, first child of `<body>`; server-rendered defaults `data-theme="dark" data-lang="vi"` | with `cupid-web-theme=light` set, a cold load of `/pets` shows no dark frame | `FOUC_CHECK_UNAVAILABLE` |
| Language persistence across document loads | AC-4 (see Key Discovery #2) | persist `cupid-web-lang` alongside `cupid-web-theme` | choose EN on `/`, navigate to `/pets`, EN is still active | `LANG_PERSISTENCE_UNVERIFIED` |
| Web font + icon-font parity | `Cupid Web.dc.html:11-14` | keep both Google Fonts `href` values byte-identical; keep `display=block` on Material Symbols | built `<head>` contains both hrefs unchanged | `FONT_PARITY_UNVERIFIED` |
| Route reachability | UX spec §6.3 | 8 real routes; `legal` reachable from the footer only, exactly as the source does | build emits 8 HTML files; every header and footer link resolves | `ROUTE_MAP_INCOMPLETE` |
| Deploy parity with REQ-005 | `.github/workflows/deploy-backend.yml`, `scripts/vps-deploy.sh` | reuse the same `VPS_SSH_*` secret names and SSH script shape; ship a static directory instead of a container image | workflow triggers on `web/**`, uploads the build, and passes an HTTP gate on `cupidus.app` | `VPS_SECRETS_MISSING` |

### Lane Handoff

#### Frontend Lane

- Responsibilities: P1–P5 (scaffold, tokens, shell, routes, sprites, Home body).
- Authoritative inputs: `cupid-app-design-system/Cupid Web.dc.html` (read-only,
  by the exact line ranges each phase names), `../ux/uiux-spec.md` §6.1–§6.8,
  `../requirements/requirements.md`.
- Guardrails:
  - Do not install Tailwind, a CSS framework, a UI kit, React, Vue, or Svelte.
  - Do not "clean up", consolidate, minify, or re-order a copied `style="..."`
    attribute, and do not convert one into a class.
  - Do not add a `legal` item to the header nav, and do not add any nav item,
    section, breakpoint, ARIA-invisible wrapper, or element the source lacks.
  - Do not import, bundle, or copy any file from `cupid-app-design-system/` into
    `web/`; it is a reading source, not a dependency.
  - Do not persist anything to `localStorage` beyond `cupid-web-theme` and
    `cupid-web-lang`.

#### DevOps Lane

- Responsibilities: P6 (runtime registry entry, local env scripts, CI/CD to
  `cupidus.app`, configuration guide).
- Authoritative inputs: `.github/workflows/deploy-backend.yml`,
  `.github/workflows/scripts/vps-deploy.sh`,
  `data/devops/system/runtime-command-registry.json`,
  `.claude/skills/devops/references/shared-local-infrastructure.md`.
- Guardrails:
  - The local dev-server port comes from `devstack port claim --role web` and is
    read from `.env.devstack`. Never hardcode Astro's default 4321, never scan.
  - Do not invent a second deploy mechanism; reuse the REQ-005 secret names, and
    report any genuinely new secret to the user by exact name.
  - Do not add a container/runtime to serve `web/` unless the existing VPS web
    server cannot serve a static root — state the finding first.
- Requirement configuration guide update (DevOps lane only): REQUIRED

## 5. Non-Functional Impact

- The site must render correctly with JavaScript disabled except for the two
  toggles: all content is server-rendered HTML, and the dark/VI default comes
  from CSS and server-rendered attributes, not from the boot script.
- `color-mix(in oklab, ...)` appears in the feature-card tints (line 735–738).
  It is copied verbatim; confirm at implementation that the target browser
  baseline supports it, and if not, record the finding rather than substituting
  a hand-computed color (a substitution changes rendered pixels).

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Astro, static output | HTML-superset templates keep `style="..."` verbatim; file-based routing gives 8 real routes; zero runtime JS by default; static build output suits the REQ-005 VPS pattern | ACCEPTED | Pin versions from the lockfile the scaffold generates; do not assert versions from memory |
| Next.js static export / Vite + React | The obvious default for a new frontend | REJECTED | JSX forces every `style="a:b;c:d"` into a `style={{a:'b'}}` object and every `style-hover` into a state/class construct. That is hundreds of hand-translations, each a silent pixel risk, against the story's single hardest acceptance criterion. |

## 7. Research Status

External research was requested for the framework choice. `ToolSearch` returned
`Error: No such tool available: ToolSearch. ToolSearch is disabled for this
session, in subagents as well as here.`; direct `WebSearch` returned `Error: No
such tool available: WebSearch. WebSearch is disabled for this session, in
subagents as well as here.`; direct `WebFetch` returned `Error: No such tool
available: WebFetch. WebFetch is disabled for this session, in subagents as well
as here.` Blocker: `RESEARCH_TOOLS_UNAVAILABLE` (only the user can restore a
session-level tool).

Consequence for this document: the decision above is argued entirely from
evidence inside this repository (the design source's own markup shape and the
existing REQ-005 workflow), not from any version-specific or comparative claim
about third-party tooling. No version numbers, feature-support claims, or
release facts are asserted anywhere in this solution or its phases — P1 pins
versions from the lockfile the scaffold itself generates.
