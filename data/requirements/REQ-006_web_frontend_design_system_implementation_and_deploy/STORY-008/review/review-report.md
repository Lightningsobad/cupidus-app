# Review Report — REQ-006 / STORY-008 Privacy & Terms Page

Outcome: PATCH_REQUIRED

- Review type: `full-story-review` (UI lane, parallel story review)
- Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/review/scope-gate.md`
- Reviewer date: 2026-08-21
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-008`
- Diff: `bc499987466ae3cbacf8f7b9157a6b9a3aab857c..8ce3e2f0fed6d00a6abd1b542605201482f437de`
- Changed source files: `web/src/pages/legal.astro` (only)
- Blocking findings: 3
- Deferred findings: 1

## Outcome Rationale

The code is correct and the content is a character-exact port of the design
source. Every functional acceptance criterion passes independent verification.
The story is returned for rework solely on missing critical-gate evidence: the
mandatory rendered visual-fidelity check (rule 12e2) could not be produced
because the project's renderer configuration is incomplete, and two required
evidence sections are absent from `test-results.md` in the form the DONE gate
reads.

None of the three blocking findings requires a change to `legal.astro`.

## Acceptance Criteria

| AC | Verdict | Independent verification |
|----|---------|--------------------------|
| AC-1 route & discoverability | PASS | `site-nav.ts:61-68` — footer "Pháp lý"/"Legal" column holds two `NavItem`s both resolving `hrefFor('legal')` → `/legal`; `SiteFooter.astro:20` renders them as real `<a href>` anchors in both locales. Built `dist/index.html` carries 2 `href="/legal"`. Header markup on `/legal` holds `/ /pets /zodiac /share /blog /about /support` and no `/legal` — 7 nav items, footer-only route, as the design source and UX §5.1 require |
| AC-2 header content | PASS | Diff matches `Cupid Web.dc.html:641-643` character for character: literal unlocalized `Legal` eyebrow (no `data-vi`/`data-en` pair — asserted present in built HTML), H1 VI/EN spans, literal updated-date strings |
| AC-3 five sections verbatim | PASS | Frontmatter `sections` array compared line-by-line against `Cupid Web.dc.html:823-829`: all 5 items, source order, all 20 strings (10 titles + 10 bodies, VI+EN) identical including punctuation and the `Don't` apostrophe. Built page carries 34 `data-vi` / 34 `data-en` spans — balanced, no single-locale string |
| AC-4 locale & theme parity | PASS | No page-local toggle added; page consumes the shell's `data-vi`/`data-en` mechanism only. Story diff touches no file under `web/src/layouts/`, `web/src/components/`, or `web/src/styles/`, so the STORY-001 shell contract §6 is intact |
| AC-5 per-page localized `<title>` | PASS | `SiteLayout.astro:11-17,25` already exposes `title?`; page passes the VI title (present in built `<title>`) and an `is:inline` script reads `document.body.dataset.lang` and re-applies via `MutationObserver` on `data-lang` — both confirmed emitted in the built document, no shell coupling |
| UI-Fidelity-AC (visual parity) | **UNVERIFIED** | See BLOCK-1. Static markup is provably a verbatim port, but rule 12e2 requires a rendered image comparison and explicitly refuses source-inspection as a substitute |

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Status |
|--------------|---------------|--------|
| Verbatim bilingual legal copy | 20-string VI/EN checklist vs design source | PASS (re-verified by Reviewer against `Cupid Web.dc.html:823-829`) |
| Heading / landmark semantics | 1 `<main>`, 1 `<h1>`, 5 `<h2>` | PASS (Reviewer counted in built `dist/legal/index.html`: 1 / 1 / 5) |
| Frontend build / type-check | `npm run check` + `npm run build` | PASS (evidence §1, both exit 0; `dist/legal/index.html` present) |
| Shell immutability | story diff lists no shell file | PASS |
| Frontend discoverability / navigation | rule 12e1 `## Entry Point Reachability` marker | **FAIL** — BLOCK-2 (path itself verified in code) |
| Rendered visual fidelity | rule 12e2 rendered screenshot + design-reference comparison | **FAIL** — BLOCK-1 |
| Runtime / configuration | rule 12g `## Story Runtime Startup Smoke` or `Runtime-Smoke: WAIVED` | **FAIL** — BLOCK-3 |

## Blocking Findings

### BLOCK-1 — Rendered visual-fidelity evidence is absent and currently unproducible (owner: DevOps + UI/UX Designer)

`data/devops/system/design-fidelity-config.json` records `ui_surface: true` and a
`design_source` that is configured **and** `"locked": true`
(`type: claude-design`, `location: cupid-app-design-system`,
`entry: Cupid Web.dc.html`). Reviewer rule 12e2 therefore applies with no
exemption: the frontend lane requires a per-story rendered comparison, owned by
the Reviewer.

I attempted the render rather than assuming it would fail:

```
node .ai-team-bundle/runtime/tools/render-running-app.js \
  --out=<scratch>/vf-probe --label=legal --route=/legal
exit 4
APP_RENDER_NOT_CONFIGURED: data/devops/system/design-fidelity-config.json has no
app_render.base_url. Configure app_render.{start_cmd,ready_url,base_url} so the
running app can be auto-served and rendered.
```

The config file has only `design_source` and `ui_surface` keys — no `app_render`
block at all. Rule 12e2 names this exact case: *"if `app_render`/`auth.storage_state`
is unconfigured the renderer returns `APP_RENDER_NOT_CONFIGURED` — route a config
fix, do not pass the story."*

The reference side is also unresolved. `render-design-canvas.js --list-screens`
against the configured entry returns `{"entry":"Cupid Web.dc.html","screens":[],
"toggles":[],"platforms":[]}` — the canvas exposes no named screen ids, so no
`Design-Screen: <id>` can be resolved as configured, and the UX spec §6.8 records
the reference render as never produced ("not yet rendered as image files",
inheriting the STORY-001 blocker). No `visual-fidelity/` directory exists for
STORY-008, nor for any of the eight REQ-006 stories.

Two things worth recording so the fix is not over-scoped:

1. This is a **project-configuration gap, not a defect in `legal.astro`.** The
   implementation is a character-exact port of `Cupid Web.dc.html:639-653`
   (inline style strings identical), with exactly one deliberate, documented
   deviation: the section title is an `<h2 style="margin:0 0 9px">` instead of the
   source's unsemantic `<div style="margin-bottom:9px">`, required by UX §6.6 for
   screen-reader navigation and geometrically equivalent (the `margin-top:0`
   cancels the UA heading margin; Reviewer confirms this is the correct fix, not a
   fidelity deviation).
2. The gap is **requirement-wide**, so it should be fixed once at REQ-006 level
   rather than eight times.

Required to clear:
- DevOps: add `app_render.{start_cmd, ready_url, base_url}` to
  `data/devops/system/design-fidelity-config.json` for the `web` app, using the
  reserved `DEVSTACK_PORT_WEB` from `.env.devstack` (never Astro's default 4321).
- UI/UX Designer: resolve how this Claude Design bundle yields a comparable
  reference for the `isLegal` state given `screens: []`, record the resolved
  `Design-Screen` (or the documented reason none exists), and produce
  `visual-fidelity/design-reference-legal-<bp>.png`.
- Reviewer (re-review): render `--route=/legal`, compare, and write
  `visual-fidelity/visual-fidelity-report.md` with a `VISUAL_FIDELITY:` verdict.

Do **not** self-provision `design_source`; it is locked and already correct.

### BLOCK-2 — `## Entry Point Reachability` evidence section missing (owner: Frontend Developer)

Rule 12e1 requires `coding-plan/test-results.md` to carry a
`## Entry Point Reachability` section with `Reachable: YES` and the concrete path.
`test-results.md` §7 is headed *"Entry-Point Reachability From The Rendered Site
(AC-1)"* and contains a complete four-row table (both footer links, both locales,
all landing on the populated `/legal`), but no `Reachable: YES` line and not the
gate's heading. The DONE gate reads this literally and will reject the story.

The reachability itself is **not** in doubt — I verified it independently in code
(`site-nav.ts:61-68`, `SiteFooter.astro:20`, built `dist/index.html`) rather than
trusting the evidence line. This is a form fix only.

Required to clear: add a `## Entry Point Reachability` section recording
`Reachable: YES` and the concrete path (footer "Pháp lý"/"Legal" column →
"Quyền riêng tư"/"Privacy" and "Điều khoản"/"Terms" → `/legal`).

### BLOCK-3 — Story runtime startup smoke neither recorded nor waived (owner: Frontend Developer, or Scrum Master waiver)

Rule 12g makes registry-backed runtime startup smoke a mandatory story-level gate
for every non-trivial `frontend`-lane story unless `story_master.md` records
`Runtime-Smoke: WAIVED — <reason>`. `story_master.md` carries no such line, and
`test-results.md` has no `## Story Runtime Startup Smoke` section — §9 states
"Startup smoke: NOT_APPLICABLE for `web-frontend` per the phase file", sourced from
the phase file's `Startup Smoke: NOT_APPLICABLE`. `NOT_APPLICABLE` is not a pass.

As with BLOCK-2 the substance exists: the build was actually served and loaded
(`npm run preview -- --port 21021 --host 127.0.0.1`, 16 successful page loads in
Chromium, evidence §5/§6). It simply is not recorded under the heading the gate
reads.

Required to clear: either add a `## Story Runtime Startup Smoke` section citing
the `npm run preview` command, the `DEVSTACK_PORT_WEB` binding, and the successful
load of `/legal`; or have Scrum Master record `Runtime-Smoke: WAIVED — <reason>` in
`story_master.md`.

## Deferred Findings

### DEF-1 — Footer "Press kit" link targets `/about` (pre-existing, STORY-001)

`site-nav.ts:57` maps the "Press kit" footer entry to `key: 'about'`, so it lands
on the About page rather than a press-kit surface. This is a faithful port of the
design source's own routing and predates this story; STORY-008 did not make it
worse. Out of scope here — raise at REQ-006 integration review if a real press-kit
route is ever wanted.

## Traceability

- Requirements: `STORY-008/requirements/requirements.md` — AC-1..AC-5, UI-Fidelity-AC, `## Open Question Impact` (OQ-REQ006-1 and OQ-REQ006-2 both RESOLVED, no scope blocked; implementation includes no blocked scope and omits no unblocked AC)
- UX: `STORY-008/ux/uiux-spec.md` §5.1 (footer-only discoverability, no 8th nav item), §6.6 (single `<main>` from shell, `<h2>` section headings), §6.7 (no card/`--surf`/radius/accordion/TOC), §6.8 (measurable anchors; records the reference-render blocker underlying BLOCK-1)
- Architecture: `STORY-008/architecture/solution.md` §1 Key Discovery (existing `title` prop, existing `<main>`) — both honoured; §4 risk table, all six declared gates addressed
- Shell contract: `STORY-001/architecture/contract-summary.md` §6 consumer prohibitions — satisfied; story diff contains no shell file
- Evidence: `STORY-008/coding-plan/test-results.md` §1-§10; `phase-P1-legal-page-body-and-entry-point.md` §4, §6, §7
- Configuration guide: `data/requirements/REQ-006_.../deployment/configuration-guide.md` — phase file records `Update Required: NO`; this story adds no env var, secret, external integration, or manual setup step, so no guide change is required (rule 12a satisfied)

## State Recommendation

- Uncheck `Implementation (Development)` in `STORY-008/story_master.md`
- Leave `Review (Reviewer)` unchecked
- Story status: `IN_PROGRESS`
- Route BLOCK-1 to DevOps (`app_render` config) and UI/UX Designer (design
  reference), preferably once at REQ-006 scope since all eight stories share the
  gap; route BLOCK-2 and BLOCK-3 to Frontend Developer as evidence-form fixes in
  `test-results.md`
- Do not merge `codex/REQ-006_..._-STORY-008` into the integration branch until
  the re-review records `CLEAN` or `DEFERRED_ONLY`
