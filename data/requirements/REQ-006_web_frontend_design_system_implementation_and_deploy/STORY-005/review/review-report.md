# Review Report — REQ-006 / STORY-005 Cupid Journal Blog Page

Outcome: DEFERRED_ONLY

- Review type: `full-story-review` (Flow: parallel-story, Parallel-Execution: YES)
- Scope gate: `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/STORY-005/review/scope-gate.md`
- Reviewer: Iris-QC — fresh re-review, supersedes the Iris-QC-4 `PATCH_REQUIRED` pass
- Date: 2026-08-21
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-005`
- Branch: `codex/REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-005`
- Diff reviewed: `git -C <Worktree> diff 2e72902de51910c18ca1c6e8ca31faeedc14d823` (HEAD `fbe9d4f`)

## Rationale

All three prior blocking findings are closed, re-verified against current
worktree state rather than assumed:

- **F-1** — `coding-plan/test-results.md` now carries a top-level
  `## Entry Point Reachability` with `Reachable: YES` and five concrete paths.
  I re-verified the entry point in code independently: `site-nav.ts:34`
  (`{ key: 'blog', href: '/blog' }`), `SiteHeader.astro:22-29` (desktop
  `<a href="/blog">` with `aria-current="page"` when active), `:31-35` (mobile
  `<select data-navm>` option), and `site-nav.ts:49` (footer Product column).
  Real and discoverable, not direct-URL-only. **Closed.**
- **F-2** — `## Story Runtime Startup Smoke` now present with
  `Runtime-Smoke: PERFORMED`, registry id `web-frontend` (confirmed present in
  `data/devops/system/runtime-command-registry.json`), a devstack-leased port,
  `GET /blog` → HTTP 200 on the first attempt, clean shutdown and released
  lease. **Closed.**
- **F-3** — the rendered check now completes under the standard the user
  confirmed in `../design-fidelity-tooling-fix.md`. I produced a real
  `render-running-app.js` capture of this story's built app at 375/768/1280
  (exit 0) and compared it against `ux/uiux-spec.md` §6.2-§6.7, whose values are
  line-cited to `Cupid Web.dc.html:453-509` / `:780-792` — which I also read
  directly. `VISUAL_FIDELITY: PASS`. **Closed**, with the permanently
  unobtainable screen-specific canvas render recorded once as DEF-A.

The code itself is a character-for-character port of the design source's
`isBlog` block. The only markup departures are the four accessibility closures
`uiux-spec.md` §6.3/§6.6 explicitly asked for, none of which changes the
default-state rendering.

## Code scope reviewed

| File | Verdict |
|---|---|
| `web/src/pages/blog.astro` | PASS — verbatim vs design `:454-508` |
| `web/src/components/blog/ArticleCard.astro` | PASS — verbatim vs design `:485-494` |
| `web/src/data/blog-content.ts` | PASS — `topics`/`posts` character-identical to design `:780-792`, including each card's own `color-mix` percentage and the escaped inner quotes in `"mình cần nói chuyện"` |

Read-only entry-point verification (not story-changed): `web/src/data/site-nav.ts`,
`web/src/components/shell/SiteHeader.astro`.

Diff contains exactly these 3 `web/` files plus story artifacts. No shell, token,
or global-style file touched — STORY-001 shell contract intact.

## Acceptance criteria

| AC | Verdict | Evidence |
|---|---|---|
| AC-1 page reachable via nav | PASS | independently verified in code (see F-1 above); `test-results.md` `## Entry Point Reachability` records 5 activated paths; 1280 render shows the active "Blog" pill |
| AC-2 intro eyebrow / H1 / paragraph, literal VI+EN | PASS | `blog.astro:11-13` vs design `:456-458`, character-identical; visible in all 3 renders |
| AC-3 exactly 4 presentational topic pills | PASS | `topics.map` → `<div class="cupid-topic-pill">`; no `<button>`/`<a>`/`href`/`tabindex`/ARIA role; `test-results.md` §5.3 (4, source order), §5.5 (0 tabbable) |
| AC-4 hardcoded featured panel, not from `posts` | PASS | authored inline `blog.astro:21-36` from design `:466-481`; `SuaSprite size={180}`; no `posts` reference in that subtree |
| AC-5 6 cards, `auto-fit` grid holds its `minmax` floor | PASS | `posts.map` (6) into `repeat(auto-fit,minmax(min(300px,100%),1fr))`; renders show 1/2/3 columns at 375/768/1280 with no overflow; `test-results.md` §5.2 |
| AC-6 newsletter renders; Subscribe inert | PASS | `<input type="email" placeholder="email@cupid.app">` + `<button type="button">`, no listener, no `<form>`; `test-results.md` §5.6 (URL unchanged, no reload, 0 network requests) |
| UI-Fidelity-AC-7 visual fidelity | **PASS** | `visual-fidelity/visual-fidelity-report.md` — `VISUAL_FIDELITY: PASS`, real `render-running-app.js` capture at 375/768/1280, per-breakpoint PASS, element-by-element table vs uiux-spec §6.2-§6.7 |
| AC-8 copy fidelity VI↔EN | PASS | `blog-content.ts` byte-identical to design `:780-792`; `test-results.md` §4 (38/38 balanced pairs in `<main>`), §5.4 (no blank/unpaired string in either locale) |
| AC-9 Blog-specific `<title>` | PASS | `blog.astro:8` `title="Cupid Journal — Cupid"`, overriding the `'Cupid'` shell default (closes STORY-001 DEF-2) |

## Touched risk surfaces and critical gates

| Risk surface | Critical gate | Result |
|---|---|---|
| Frontend build / typed contract | `npm run check` + `npm run build` exit 0 | PASS — `test-results.md` §1/§1.1; independently reproduced this pass, since `render-running-app.js`'s auto-start ran `npm run build && npm run preview` in this worktree and the app served `/blog` |
| Frontend discoverability / navigation (12e1) | `## Entry Point Reachability` + independent code verification | PASS |
| Rendered visual fidelity (12e2) | rendered capture + `VISUAL_FIDELITY` verdict | PASS (DEF-A on the reference half) |
| Runtime / operational (12g) | `## Story Runtime Startup Smoke`, registry-backed | PASS |
| False interactive promise | zero interactive semantics on pills/cards; inert Subscribe | PASS |
| Bilingual copy fidelity | balanced pairs, verbatim strings | PASS |
| Shell immutability (STORY-001 contract) | no shell/token/global-style file in diff | PASS |

Configuration guide: phase metadata records `Requirement Configuration Guide —
Update Required: NO`; the diff adds no env var, external integration, or manual
setup step. No guide update required for this story. The `app_render` items in
DEF-B/DEF-C are requirement-level devops config, not this story's deliverable.

OQ discipline: `requirements.md` `## Open Question Impact` triages both
requirement-level OQs as RESOLVED with nothing blocked, and the implementation
neither adds blocked scope nor omits unblocked ACs. PASS.

## Blocking findings

None.

## Deferred findings

- **DEF-A — no screen-specific `design-reference-blog-*.png` (permanent, do not
  re-open).** On this canvas the Blog view is a non-default component prop state
  (`Cupid Web.dc.html:679` `startPage` enum default `"home"`; `:709`; `:453`
  `<sc-if value="{{ isBlog }}">`), reachable only via header buttons carrying no
  `[data-screen-btn]`. `render-design-canvas.js` cannot drive it, and the fix
  belongs to a separate bundle source repo. Confirmed and closed as
  structurally blocked in `../design-fidelity-tooling-fix.md` ("Fix 2 —
  BLOCKED"). Per the user decision on that doc this is recorded once and is not
  grounds for `PATCH_REQUIRED`/`BLOCKED`. Consequently no `Design-Screen: <id>`
  is recorded for this story — moot while no per-screen canvas render exists.
- **DEF-B — `app_render` is missing from this story worktree's
  `design-fidelity-config.json` (owner: `scrum-master`).** Fix 1 landed on
  `codex/REQ-006_..._-integration` (`5a075f2`) and on `main`, but this story's
  `BaseHead` (`2e72902`) predates it, so
  `render-running-app.js --project=<worktree>` still exits
  `4 APP_RENDER_NOT_CONFIGURED`. I worked around it with a scratch project root
  holding a verbatim copy of the integration branch's `app_render` block (see
  the visual-fidelity report). Not a story defect — it resolves the moment the
  story branch takes the integration branch's config. Every remaining REQ-006
  story branch cut before `5a075f2` has the same gap.
- **DEF-C — `app_render.base_url` is a single fixed port shared by all parallel
  worktrees; this can silently certify the wrong story (owner: `devops` +
  `scrum-master`).** Measured this run: port `21021` was bound by the
  **STORY-002** worktree's preview (PID 8740, cwd
  `.../story-REQ-006_..._-STORY-002/web`, `GET /blog` → 200).
  `render-running-app.js` reuses an already-running server at `ready_url`
  instead of starting one, so an unmodified run from any REQ-006 story worktree
  would have captured STORY-002's build and produced a confident PASS for the
  wrong code — and the resulting screenshot would look entirely plausible,
  because every REQ-006 page shares the same shell. I avoided it with a devstack
  lease (`22004`, released). This is the highest-value item in this report: it
  is a false-PASS mechanism, not a cosmetic config gap. Suggested fix: make
  `app_render`'s port worktree-scoped (read a devstack lease) or have the
  orchestrator verify the served build's provenance before reusing a server.
- **DEF-D — `uiux-spec.md` §6.2.4's tint summary is inaccurate.** It says "14%
  for lilac/mint/pink/peach, 16% for butter", but the design source uses 15% for
  lilac (cards 1, 6) and 15% for peach (card 5). The implementation follows the
  source, which the same spec bullet defers to ("see source `:786-791` for exact
  values"), so the code is right and the spec prose is the wrong copy. Worth
  correcting so a later reader does not "fix" the code toward the summary.
- **DEF-E — `cursor:pointer` on non-interactive topic pills and article cards.**
  Verbatim port of design `:462`/`:485` and explicitly acknowledged as an
  intentional design-source behavior in `uiux-spec.md` §6.3/§6.8. Not a story
  defect. Revisit with PO/UX when these pills gain real filter behavior.
- **DEF-F — card title promoted from `<div>` to `<h3 style="margin:0">`.**
  Documented deviation (`test-results.md` §7), taken to satisfy `uiux-spec.md`
  §6.6's no-skipped-heading-levels rule, with `margin:0` keeping the card's
  `gap:12px` rhythm identical to the source. Correct call; recorded so the
  markup delta stays traceable.
- **DEF-G — `!important` on ported `style-hover` and focus-ring rules.** Forced
  by the design source's inline `border`/`color`/`outline:none` shorthands
  outranking non-`!important` rules; same pattern STORY-001 established in
  `SiteHeader.astro:59-65`. Consistent, but it sets a specificity floor a later
  override will have to clear.
- **DEF-H — `main`'s `design-fidelity-config.json` still points at the mobile
  canvas (owner: `scrum-master`).** `main` has `entry: "Cupid App.dc.html"`,
  `project_dir: "cupid-app-design-system/project"`, while
  `codex/REQ-006_..._-integration` has `entry: "Cupid Web.dc.html"`,
  `project_dir: "cupid-app-design-system"` (`b116ffc`, set from an explicit user
  decision). These will collide when the REQ-006 integration branch lands on
  `main`, and `design_source` is `locked: true` on both sides. Worth deciding
  the intended end state before the merge rather than during it.

## Handoff notes for Scrum Master

- **Declared `WriteScope` is narrower than this review requires.** It names only
  `.../STORY-005/review`, but reviewer skill 12e2 makes this (non-mobile) UI
  lane's reviewer the owner of the render, whose artifacts land in
  `.../STORY-005/visual-fidelity/`. Both directories were written inside the
  declared `Worktree`. The prior pass reported the same mismatch; future
  UI story-review handoffs should declare `review/` and `visual-fidelity/`.
- Artifacts changed by this pass: `review/scope-gate.md`,
  `review/review-report.md`, `visual-fidelity/visual-fidelity-report.md`,
  `visual-fidelity/implemented-blog-{375,768}.png` (re-captured), new
  `visual-fidelity/implemented-blog-1280.png`, new
  `visual-fidelity/dev-server.log` (renderer's own server output).
  `visual-fidelity/implemented-blog-1400.png` is the prior pass's capture at a
  breakpoint `app_render.breakpoints` does not declare — superseded; delete or
  keep as history, your call.
- Devstack lease `slot=story-005-review2 role=preview` (port `22004`) was used
  for the render and the server was torn down by the orchestrator; no listener
  remains on `22004`. The STORY-002 preview on `21021` was left untouched.
- `story_master.md` still records `Status: PENDING` with
  `Implementation (Development)` unchecked from the prior `PATCH_REQUIRED`
  cycle; both need the state update below.

## State recommendation

- `Implementation (Development)`: **check**
- `Review (Reviewer)`: **check**
- Story status: **DONE**
- Blocking findings: 0. Deferred findings: 8.
- DEF-C should be routed as a requirement-level `devops` item before the
  remaining REQ-006 story reviews run their renders; DEF-B and DEF-H are
  Scrum Master git/config decisions.
