# Review Report — REQ-006 / STORY-005 Cupid Journal Blog Page

Outcome: PATCH_REQUIRED

- Review type: `full-story-review` (Flow: parallel-story)
- Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-005/review/scope-gate.md`
- Reviewer: Iris-QC
- Date: 2026-08-21
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-005`
- Branch: `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-005`
- Diff reviewed: `15af9b1d99e10cfdcaf7f6b1862d898c35906ee9..c2615c15b3fe3a98bb2e90ef51e8bdfbfb81ca5e`

## Rationale

The code is right. The evidence is not complete.

The implementation is a faithful, near-verbatim port of the design source's
`isBlog` block and every functional acceptance criterion verifies. What is
missing is three gate artifacts that the DONE gate reads independently and that
the story cannot be closed without: the `## Entry Point Reachability` section,
the `## Story Runtime Startup Smoke` section, and the design-reference half of
the rendered visual-fidelity pair. Two are a section the implementer can write
from evidence already gathered. The third is a real tooling gap that this story
is simply the first to hit.

## Code scope reviewed

| File | Verdict |
|---|---|
| `web/src/pages/blog.astro` | PASS |
| `web/src/components/blog/ArticleCard.astro` | PASS |
| `web/src/data/blog-content.ts` | PASS |

Compared line-by-line against `cupid-app-design-system/Cupid Web.dc.html:453-509`
(the `isBlog` block). The port is structurally and textually verbatim, including
inline style strings, the `color-mix` tint per card, the escaped inner quotes in
`"mình cần nói chuyện"`, and the `· 8 phút đọc` featured-panel meta row.

## Acceptance criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 reachable via nav, active treatment, no console errors | PASS | independently verified in code: `web/src/data/site-nav.ts:34` (`{ key: 'blog', href: '/blog' }`), `web/src/components/shell/SiteHeader.astro:22-29` desktop `<a href="/blog">` with `aria-current="page"` when active, `:31-35` mobile `<select>` option, `:158-160` its change handler; footer link at `site-nav.ts:49`. Behavioural confirmation in `test-results.md` §5.1/§5.9. See F-1 for the missing evidence section. |
| AC-2 intro eyebrow / H1 / paragraph, literal VI+EN | PASS | `blog.astro` vs design `:456-458` — character-identical |
| AC-3 exactly 4 presentational topic pills, no Tab stop | PASS | `topics.map` → `<div class="cupid-topic-pill">`; no `<button>`, `<a>`, `href`, `tabindex`, or ARIA role anywhere in the pill markup; `test-results.md` §5.3/§5.5 |
| AC-4 hardcoded featured panel, not derived from `posts` | PASS | authored inline in `blog.astro` from design `:466-481`; `SuaSprite size={180}`; no `posts` reference in that subtree |
| AC-5 exactly 6 cards, `auto-fit` grid holds its `minmax` floor | PASS | `posts.map` (6 entries) into `repeat(auto-fit,minmax(min(300px,100%),1fr))`, verbatim from `:483`; `test-results.md` §5.2 measures 1/2/3/3 tracks at 375/768/1024/1440 with 0 overflow |
| AC-6 newsletter renders; Subscribe is inert | PASS | `<input type="email" placeholder="email@cupid.app">` + `<button type="button">` with no listener and no `<form>`; `test-results.md` §5.6 (URL unchanged, no reload, 0 network requests) |
| UI-Fidelity-AC-7 layout/spacing/radii/colors/typography | **FAIL** | see F-3 — no rendered design reference exists to compare against; the §5.8 computed-style spot-check is supporting evidence, not the rendered check 12e2 requires |
| AC-8 VI↔EN leaves no blank or missing string | PASS | 38/38 balanced `data-vi`/`data-en` pairs inside `<main>`; `test-results.md` §4/§5.4 |
| AC-9 Blog-specific `<title>` | PASS | `blog.astro` `title="Cupid Journal — Cupid"` → `SiteLayout.astro:17,25`, overriding the `'Cupid'` default |
| diff touches only the 3 phase files | PASS | `git diff --stat` = 3 web files + 2 story artifacts; no shell, token, or global-style file |

## Touched risk surfaces and critical gates

| Risk surface | Critical gate | Result |
|---|---|---|
| Frontend build / typed contract | `npm run check` + `npm run build` exit 0 | PASS — reproduced independently by Reviewer under Node v22.17.1: 8 pages, exit 0 |
| Frontend discoverability / navigation integration | `## Entry Point Reachability` + code verification (12e1) | **FAIL — F-1** (code side verified; evidence section absent) |
| Rendered visual fidelity (design_source configured, `ui_surface: true`) | rendered pair + `VISUAL_FIDELITY` verdict (12e2) | **FAIL — F-3** |
| Runtime / operational | `## Story Runtime Startup Smoke` (12g) | **FAIL — F-2** |
| False interactive promise | zero interactive semantics on pills/cards; inert Subscribe | PASS |
| Bilingual copy fidelity | balanced pairs, verbatim strings | PASS |
| Shell immutability (STORY-001 contract) | no shell/token/global-style file in diff | PASS |

STORY-001 contract compliance: `SiteLayout page="blog"` with the `title` prop
(contract §1), route key `blog` (§2), `data-vi`/`data-en` span pairs (§3), token
variables and `SuaSprite` reuse (§4). No shell file modified (§6). PASS.

Configuration guide: phase metadata records `Requirement Configuration Guide —
Update Required: NO`, and the diff adds no env var, external integration, or
manual setup step. No guide update required for the story itself. (F-3's
`app_render` gap is a requirement-level devops config item, not this story's
deliverable.)

## Blocking findings

### F-1 — `## Entry Point Reachability` section missing (owner: `frontend-dev`)

`coding-plan/test-results.md` carries the reachability evidence as `### 5.1
Entry-Point Reachability (AC-1)`, but reviewer rule 12e1 and the DONE gate read a
top-level `## Entry Point Reachability` section containing a literal
`Reachable: YES` line plus the concrete path. Neither the heading nor the
`Reachable:` line exists in the file.

This is a formatting/evidence gap only. I verified the entry point in the code
myself and it is real and discoverable (`site-nav.ts:34`,
`SiteHeader.astro:22-29` and `:31-35`, footer at `site-nav.ts:49`) — it is not
direct-URL-only. But 12e1 is explicitly non-waivable and the DONE gate enforces
it independently; the same gap was patched for REQ-005/STORY-001 in commit
`d9ff554`.

Action: add to `coding-plan/test-results.md`

```
## Entry Point Reachability
Reachable: YES
Path: header nav "Blog" (`SiteHeader.astro:22-29`, desktop) and header
      `<select data-navm>` option "Blog" (`SiteHeader.astro:31-35`, ≤1024px)
      → `/blog`; also footer Product column (`site-nav.ts:49`)
```

### F-2 — `## Story Runtime Startup Smoke` section missing (owner: `frontend-dev` or `scrum-master`)

Rule 12g makes a registry-backed runtime startup smoke mandatory for every
non-trivial story in the `frontend` lane. `story_master.md` is `Complexity:
standard`, `Implementation Lane: frontend`, and records no `Runtime-Smoke:
WAIVED — <reason>` line. `test-results.md` has no `## Story Runtime Startup
Smoke` section.

The phase file's `Startup Smoke: NOT_APPLICABLE` (`phase-P1` §1B) is *phase*
metadata about the impacted service; it is not the story-master waiver the gate
reads, and it does not satisfy 12g.

The underlying signal exists and I reproduced it: `npx astro preview --port
22003 --host 127.0.0.1` served `/blog` with `HTTP 200` and a clean console.
Only the recorded section is missing.

Action: either add the `## Story Runtime Startup Smoke` section to
`test-results.md` with the registry command, readiness probe, and result, or
record `Runtime-Smoke: WAIVED — <reason>` in `story_master.md`. Do not leave
both absent.

### F-3 — rendered design-fidelity check cannot complete (owner: `ui-ux-designer` + `devops`)

Full detail and measured tool output:
`STORY-005/visual-fidelity/visual-fidelity-report.md` (`VISUAL_FIDELITY: FAIL`).

A design source IS configured (`data/devops/system/design-fidelity-config.json`:
`type: claude-design`, `entry: Cupid Web.dc.html`, `locked: true`,
`ui_surface: true`), so rule 12e2's rendered check is mandatory and no prose
waiver applies. I own the render for this (non-mobile) UI lane and I performed
the half that is possible:

- Implementation captured at 375/768/1400 →
  `visual-fidelity/implemented-blog-{375,768,1400}.png`. I read the 1400 image:
  it shows the real Blog screen of the built app, correctly painted, not a
  blank/error/wrong screen.
- Design reference: **not obtainable with the sanctioned renderers.**
  `render-design-canvas.js --list-screens` returns
  `{"screens":[],"toggles":[],"platforms":[]}`, and `--screen=blog` dies
  `DESIGN_CANVAS_SCREEN_MISSING: 'blog' is not a screen on this canvas.
  Available: (none)`. On this canvas the Blog view is a non-default component
  prop state (`Cupid Web.dc.html:679` `startPage` enum, default `"home"`;
  `:709`; `:453` `<sc-if value="{{ isBlog }}">`), reachable only by clicking a
  header `<button>` (`:52-57`) that carries no `[data-screen-btn]`. The canvas
  exposes no URL, query, hash, or localStorage hook for `startPage`, so
  `visual-capture.js --mode=design` always renders Home.

STORY-001 never hit this because Home *is* the canvas default. STORY-005 is the
first REQ-006 story whose design screen is a non-default state, and the rendered
gate stops working there. Every remaining UI story in this requirement
(`pets`, `zodiac`, `share`, `about`, `support`, `legal`) will hit the identical
wall, so this is worth fixing once at the requirement level rather than
per story.

No `Design-Screen: <id>` is recorded for this story anywhere in
`story_master.md`, `ux/uiux-spec.md`, `architecture/solution.md`, or
`coding-plan/` — per 12e2 that omission is itself a finding.

I did not improvise around this: no hand-rolled browser script, no authored
wrapper HTML, and no edit to `design-fidelity-config.json`.

Action:
1. `ui-ux-designer` — produce `design-reference-blog-{375,768,1400}.png` for the
   canvas `startPage: "blog"` state and record the resolved `Design-Screen: <id>`
   in the story. This needs a forceable path to the non-default canvas state;
   decide it once for all seven remaining REQ-006 screens.
2. `devops` — add `app_render.{start_cmd,ready_url,base_url}` to
   `data/devops/system/design-fidelity-config.json`. Measured this run:
   `APP_RENDER_NOT_CONFIGURED … exit=4`. This is STORY-001's DEF-1, still
   unactioned.
3. Reviewer re-runs the compare afterwards.

## Deferred findings

- **DEF-1 — `cursor:pointer` on non-interactive topic pills and article cards.**
  `blog.astro` topic pill and `ArticleCard.astro` both paint a pointer cursor on
  elements with deliberately zero interactive semantics (the phase's own
  "False interactive promise" risk surface). It is a verbatim port of design
  `:462`/`:485`, so the implementation is faithful and this is not a story
  defect. Worth raising with PO/UX when these pills gain real filter behaviour.
- **DEF-2 — card title promoted from `<div>` to `<h3>`.** Documented deviation
  (`test-results.md` §7), taken to satisfy uiux-spec §6.6 heading levels, with
  `margin:0` keeping the card's `gap:12px` rhythm identical to the source.
  Correct call; recorded so the markup delta vs the design source is traceable.
- **DEF-3 — `!important` on ported `style-hover` and focus-ring rules.** Forced
  by the design source's inline `border`/`color`/`outline:none` shorthands
  outranking non-`!important` rules. Same pattern STORY-001 established in
  `SiteHeader.astro:59-65`. Consistent, but it accumulates: if a later story
  needs to override these, note the specificity floor.

## Handoff notes for Scrum Master

- **Declared `WriteScope` was narrower than the review this handoff asked for.**
  It listed only `review/review-report.md`, but `full-story-review` requires
  `review/scope-gate.md` (skill rule 5) and the UI lane requires
  `visual-fidelity/` artifacts (12e2). I wrote all three under the story
  directory inside the worktree. Future story-review handoffs should declare
  `review/` and `visual-fidelity/` in `WriteScope`.
- **The handoff prescribed `npm run build` + `npm run preview` for the visual
  check.** Skill 12e2 restricts the reviewer to the bundle renderers
  (`render-running-app.js` / `visual-capture.js`). I used `visual-capture.js`,
  falling back to a hand-started `astro preview` for the server only because
  `render-running-app.js` returns `APP_RENDER_NOT_CONFIGURED` (F-3, item 2) —
  matching the precedent STORY-001 set.
- **A background `astro preview` process may still be listening on 127.0.0.1:22003**
  (harness task `bz6f3apu5`, devstack lease role `preview`). I could not stop it:
  `pkill` is blocked by `bash-safety-guard.sh` and `devstack port release` takes
  a project, not a role/slot, so releasing would have disturbed other parallel
  workers' leases. Please stop that task and release the lease.
- Untracked artifacts I added under the worktree: `STORY-005/review/scope-gate.md`,
  `STORY-005/review/review-report.md`, `STORY-005/visual-fidelity/` (3 PNGs +
  report).

## State recommendation

- `Implementation (Development)`: **uncheck**
- `Review (Reviewer)`: leave unchecked
- Story status: **IN_PROGRESS**
- Route F-1 and F-2 to `frontend-dev` (F-2 may instead be closed by
  `scrum-master` recording the waiver in `story_master.md`).
- Route F-3 to `ui-ux-designer` (design reference + `Design-Screen`) and
  `devops` (`app_render` config). Consider handling F-3 as a requirement-level
  fix, since the six remaining REQ-006 UI screens are all non-default canvas
  states and will hit the same wall.
- Blocking findings: 3. Deferred findings: 3.
