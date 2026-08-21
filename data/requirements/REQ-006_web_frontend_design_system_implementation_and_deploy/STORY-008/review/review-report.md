# Review Report — REQ-006 / STORY-008 Privacy & Terms Page

Outcome: DEFERRED_ONLY

- Review type: `full-story-review` (UI lane, parallel story review, fresh re-review)
- Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-008/review/scope-gate.md`
- Reviewer date: 2026-08-21
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-008`
- Diff baseline: `git -C <Worktree> diff 2e72902de51910c18ca1c6e8ca31faeedc14d823`
- Changed source files: `web/src/pages/legal.astro` (+65/-1) — the only non-artifact file in the story diff
- Blocking findings: 0
- Deferred findings: 2

## Outcome Rationale

All five functional acceptance criteria pass independent verification, and the
visual-fidelity criterion now passes on real rendered evidence produced during
this review. The three blocking findings from the prior pass are all closed:

| Prior finding | Status now | Evidence |
|---------------|-----------|----------|
| BLOCK-1 rendered visual-fidelity evidence absent/unproducible | **CLOSED** | `app_render` is configured on `main`; this review produced 7 real renders and wrote `visual-fidelity/visual-fidelity-report.md` with `VISUAL_FIDELITY: PASS` |
| BLOCK-2 `## Entry Point Reachability` section missing | **CLOSED** | `test-results.md:251-287` now carries the exact heading with `Reachable: YES` and the concrete path; reachability re-verified independently in code |
| BLOCK-3 runtime startup smoke neither recorded nor waived | **CLOSED** | `test-results.md:289-347` now carries `## Story Runtime Startup Smoke`, `Executed: YES — result PASS`, registry-sourced command, 8 assertions, clean shutdown |

The remaining two findings are deferred: one is a structurally unfixable
tooling gap already adjudicated by the user, the other is pre-existing
STORY-001 scope this story did not worsen. Neither blocks closure.

## Acceptance Criteria

| AC | Verdict | Independent verification |
|----|---------|--------------------------|
| AC-1 route & discoverability | PASS | `site-nav.ts:24-26` `hrefFor('legal')` → `/legal`; `:62-66` the `Pháp lý`/`Legal` footer column holds two `NavItem`s both pointing there; `SiteFooter.astro:20` renders them as real `<a href>` anchors in both locales. Built `dist/index.html` carries exactly 2 `href="/legal"`. `navItems` (`:29-37`) has 7 entries and no `legal` — footer-only, per design source and UX §5.1. Discoverable, not URL-only; both footer links visible in the captured renders |
| AC-2 header content | PASS | Diff is character-identical to `Cupid Web.dc.html:641-643` — unlocalized `Legal` eyebrow, VI/EN H1 spans, literal updated-date strings. Confirmed visible in both the VI/dark and EN/light renders |
| AC-3 five sections verbatim | PASS | Frontmatter `sections` array compared line-by-line against `Cupid Web.dc.html:823-829`: 5 items, source order, all 20 strings (10 titles + 10 bodies, VI+EN) identical including punctuation and the `Don't` apostrophe. Built page has 5 `<h2>`; all ten EN strings read off the EN render |
| AC-4 locale & theme parity | PASS | No page-local toggle; page uses only the shell `data-vi`/`data-en` mechanism. Story diff touches nothing under `web/src/layouts/`, `components/`, `styles/`, `scripts/`. Verified by rendering the EN + light state through the shell's own `cupid-web-lang`/`cupid-web-theme` localStorage keys — page paints fully in EN on the light token set |
| AC-5 per-page localized `<title>` | PASS | `SiteLayout.astro:11-17,25` already exposed `title?`; the page passes the VI title (built `<title>Quyền riêng tư &amp; Điều khoản — Cupid</title>`) and an `is:inline` script re-applies the localized title via `MutationObserver` on `body[data-lang]`. No shell change |
| UI-Fidelity-AC (visual parity) | PASS | `visual-fidelity/visual-fidelity-report.md`, `VISUAL_FIDELITY: PASS`. Real renders at 375/768/1280 (viewport + full page) plus an EN/light state, compared against `uiux-spec.md` §6.2/§6.8 per the governing standard in `design-fidelity-tooling-fix.md`. No visible delta on layout, spacing, sizing, color, typography, or state. See DEF-1 for the reference-side gap |

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Status |
|--------------|---------------|--------|
| Verbatim bilingual legal copy | 20-string VI/EN check vs `Cupid Web.dc.html:823-829` | PASS (re-verified by Reviewer against the design source) |
| Rendered visual fidelity | rule 12e2 rendered comparison, as amended by `design-fidelity-tooling-fix.md` | PASS (Reviewer-owned render, this run) |
| Frontend discoverability / navigation | rule 12e1 `## Entry Point Reachability` + independent code check | PASS |
| Runtime / configuration | rule 12g `## Story Runtime Startup Smoke` | PASS |
| Frontend build / type-check | `npm run check` + `npm run build` | PASS — Reviewer re-ran both in the worktree on Node v22.17.1: check `0 errors, 0 warnings, 0 hints` (27 files); build `8 page(s) built`, `/legal/index.html` emitted |
| Heading / landmark semantics | 1 `<main>`, 1 `<h1>`, 5 `<h2>` | PASS (counted in built `dist/legal/index.html`) |
| Shell immutability | story diff lists no shell file | PASS |
| Setup/configuration impact (rule 12a) | configuration-guide currency | NOT REQUIRED — no env var, secret, external integration, or manual setup step added; phase file records `Update Required: NO` |

## Deferred Findings

### DEF-1 — No screen-specific design-reference render exists for `legal` (structural, out-of-repo)

`render-design-canvas.js` can only drive this Claude Design canvas to its
default `startPage: "home"`; the canvas selects its page through a React prop,
not the `[data-screen-btn]` DOM contract the tool implements, so
`--list-screens` returns `{"screens":[]}` and no `Design-Screen: <id>` is
resolvable. The fix belongs in the separate bundle source repo
(`.ai-team-bundle/` is generated, gitignored output here), and DevOps correctly
declined to patch the generated copy.

Adjudicated by the user on 2026-08-21
(`data/requirements/REQ-006_.../design-fidelity-tooling-fix.md`): proceed with
best-available evidence — a real implementation-side render compared against
the story's `uiux-spec.md` satisfies the visual-fidelity axis, and the missing
canvas render is recorded once per story as deferred, never as a blocker.
Recorded here for that purpose. Not actionable inside this repository.

### DEF-2 — Footer "Press kit" link targets `/about` (pre-existing, STORY-001)

`site-nav.ts:57` maps the "Press kit" footer entry to `key: 'about'`, so it
lands on the About page rather than a press-kit surface. This faithfully ports
the design source's own routing and predates this story; STORY-008 did not make
it worse. Raise at REQ-006 integration review if a real press-kit route is ever
wanted. Carried forward unchanged from the prior review pass.

## Traceability

- Requirements: `STORY-008/requirements/requirements.md` — AC-1..AC-5, UI-Fidelity-AC, `## Open Question Impact` (OQ-REQ006-1 and OQ-REQ006-2 both RESOLVED, nothing blocked; implementation includes no blocked scope and omits no unblocked AC)
- UX: `STORY-008/ux/uiux-spec.md` §5.1 (footer-only discoverability), §6.2 (page anatomy, verbatim copy), §6.6 (`<main>`, `<h2>` section headings, no breakpoint), §6.7 (no card/`--surf`/accordion/TOC), §6.8 (measurable visual anchor used as the design-reference side)
- Architecture: `STORY-008/architecture/solution.md` — existing `title` prop and existing `<main>` reused as designed
- Design source: `cupid-app-design-system/Cupid Web.dc.html:639-653` (markup) and `:823-829` (copy), compared directly
- Evidence: `STORY-008/coding-plan/test-results.md` §1, §7, §10, `## Entry Point Reachability`, `## Story Runtime Startup Smoke`
- Visual: `STORY-008/visual-fidelity/visual-fidelity-report.md` + 7 rendered PNGs
- Governing standard for the visual axis: `data/requirements/REQ-006_.../design-fidelity-tooling-fix.md` (user decision, 2026-08-21)

## Reviewer Environment Note

Two environment facts other REQ-006 reviews will hit:

1. The worktree's `data/devops/system/design-fidelity-config.json` predates the
   `app_render` fix and still returns `APP_RENDER_NOT_CONFIGURED`. The fix is on
   `main` (commit `1df5e6d`) but has not reached this story branch. The render
   was performed with the sanctioned bundle renderer pointed at a project root
   carrying the `main` `app_render` values; no repo config was edited.
2. Reserved `DEVSTACK_PORT_WEB` 21021 was held by a parallel peer worktree's
   preview server (STORY-006). That server was left running and untouched; this
   review took its own port via `devstack port lease --slot story-review-008
   --role web` → 22003. Scrum Master may want to fold the `app_render` config
   into the integration branch so later story reviews do not each rediscover
   point 1.

## State Recommendation

- Keep `Implementation (Development)` checked
- Check `Review (Reviewer)`
- Story status: `DONE`
- Story branch `codex/REQ-006_..._-STORY-008` is merge-eligible into
  `codex/REQ-006_..._-integration`
- Carry DEF-1 and DEF-2 into the REQ-006 integration review
