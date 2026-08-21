# Review Report — REQ-006 / STORY-007 Support FAQ Page

Outcome: BLOCKED

- Review type: `full-story-review`
- Scope gate: `review/scope-gate.md`
- Story: STORY-007 (standard, lane `frontend`)
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-007`
- Diff reviewed: `205c3835..a0807a8` — one tracked source file,
  `web/src/pages/support.astro` (+48/-2)
- Reviewer: Iris-QC, 2026-08-21

## Rationale

The implementation itself is correct and, on every criterion I could verify
independently, it passes. It is blocked on one non-waivable gate that **no
delivery lane can currently satisfy with the sanctioned tooling**, so this is an
upstream tooling/config decision rather than story rework. Sending this back to
frontend-dev as `PATCH_REQUIRED` would ask them to run a command that does not
exist.

## Acceptance criteria

| AC | Verdict | Evidence (independently verified) |
|---|---|---|
| AC-1 nav entry point | PASS | `web/src/data/site-nav.ts:36` puts `support` in `navItems`; `SiteHeader.astro:21-35` renders it in both the desktop `<nav data-nav>` and the mobile `<select data-navm>` on every page via `SiteLayout.astro:36`; `site-nav.ts:58` repeats it in the footer Company column. Discoverable, not direct-URL-only. Evidence §12 + 3 screenshots. |
| AC-2 heading + 6 entries | PASS | `support.astro` maps a 6-element `faq` array to six `<details>`; evidence §2 (6 `<details>`, 6 `<summary>`); confirmed in rendered PNGs. |
| AC-3 / BR-3 independent disclosure | PASS | Zero `name` attributes on the six `<details>` (verified in the diff), so each is an independent native disclosure; the page ships no script of its own. Evidence §7 shows `010010` for two simultaneously open entries, and `implemented-support-*-entry3-open.png` shows entry 3 open with the other five closed. |
| AC-4 / BR-2 contact block | PASS | `href="mailto:hi@cupid.app"` verbatim in the diff; single `mailto:` anchor; no form/handler/fetch. Evidence §4. |
| AC-5 bilingual | PASS | 37/37 `data-vi`/`data-en` pairs, 0 blank spans across 16 width×theme×lang runs; all 24 FAQ strings verbatim vs `Cupid Web.dc.html:814-821`. Evidence §3; confirmed in the 375-light-EN and 1440-dark-VI renders. |
| AC-6 visual fidelity | **UNVERIFIABLE — blocking** | Implementation side is strong (see below); the design-side rendered reference cannot be produced. See BLK-1. |
| AC-7 per-page `<title>` | PASS | `support.astro` passes `title="Hỗ trợ & FAQ · Support & FAQ — Cupid"` to `SiteLayout`; `SiteLayout.astro:17,25` keeps its `'Cupid'` default unchanged. Evidence §5. |
| Shell immutability (STORY-001 contract §6) | PASS | `git diff --name-only 205c3835` lists only `web/src/pages/support.astro`. Nothing under `layouts/`, `components/`, `styles/`. |

On AC-6 I re-derived the implementer's §13.1 claim myself rather than trusting
it: every inline `style` string in the delivered page is byte-identical to
`Cupid Web.dc.html:615-635` (the 860px/70-32-90 section, mint eyebrow, Nunito
900/50px/-.03em heading, `gap:10px` column, `--surf`/`--c09`/20px details,
`space-between` 16.5px summary, 20px `--acc-pink` icon, 14px/1.65 `--c64`
answer, 34px-margin gradient card, 19px title, 14px `--c62` subtext,
`--ink90`/`--bg` 999px pill). The only additions are `aria-hidden="true"` on the
decorative icon and two `class` hooks carrying `:focus-visible` rings — both
sanctioned by UX §6.6. No invented `details[open]` treatment was added, which
§6.2 explicitly forbids.

## Blocking finding

### BLK-1 — AC-6 design-side rendered reference is not producible with sanctioned tooling

Reviewer skill 12e2 makes the rendered design-fidelity comparison mandatory and
non-waivable when a design source is configured, and for non-mobile UI lanes it
assigns the render to the Reviewer. A design source **is** configured
(`data/devops/system/design-fidelity-config.json`: `entry: "Cupid Web.dc.html"`,
`locked: true`, `ui_surface: true`). I attempted the render and it is not
reachable. Measured, not assumed:

1. `render-design-canvas.js --location=<worktree>/cupid-app-design-system
   --entry="Cupid Web.dc.html" --list-screens` returns
   `{"screens":[],"toggles":[],"platforms":[]}`. The tool selects state only via
   `[data-screen-btn="<id>"]` (`render-design-canvas.js:349-358`) and
   `[data-tog]` (`:270-281`); this web canvas exposes neither.
2. The Support state is a **prop**, not a control: `startPage` is a `data-props`
   enum (`Cupid Web.dc.html:679`, options include `"support"`) consumed by
   `Component.renderVals()` at `:709,721` to flip `isSupport`. Its `<sc-if>`
   placeholder is `false` (`:614`), so a standalone render always paints
   `isHome`. Neither `render-design-canvas.js` nor `visual-capture.js` exposes a
   prop/`--start-page` flag — `visual-capture.js` has no state selector at all
   (`:9-39`).
3. `render-running-app.js` is unusable regardless: the config still has no
   `app_render` block, so it exits `4 APP_RENDER_NOT_CONFIGURED`. This is
   STORY-001's DEF-1, raised at that story's review and never fixed.

The only ways to manufacture a reference would be to accept the Home render
under a Support filename (a wrong-screen PASS, which 12e2 names as the exact
failure mode that "certifies nothing") or to edit the locked design source. I
did neither. 12e2's own instruction for the `APP_RENDER_NOT_CONFIGURED` case is
"route a config fix, do not pass the story", and 12c reserves `BLOCKED` for a
gate prevented by a dependency or upstream decision — which is this.

This is **not specific to STORY-007**. STORY-001 passed only because the canvas
default state happens to be its screen. Every remaining REQ-006 page story
(002-008) hits the same wall, so this wants one decision at requirement level
rather than seven story-level rework loops.

Resolution requires one of, decided by Scrum Master (with DevOps / bundle
tooling):

- **(a)** add an `app_render` block to `data/devops/system/design-fidelity-config.json`
  **and** a sanctioned prop/state selector to `render-design-canvas.js`
  (e.g. `--prop=startPage=support`) so the `isSupport` reference can be rendered;
  then the per-story `visual-fidelity/design-reference-support-<bp>.png` +
  `visual-fidelity-report.md` with `VISUAL_FIDELITY: PASS` become producible for
  this and every sibling story; or
- **(b)** an explicit, recorded requirement-level decision that for this web
  canvas AC-6 is evidenced by byte-level markup equivalence against the source
  section plus the implementation-side rendered matrix (what this story already
  has), with the design-side render deferred to the requirement integration
  gate. This is a user/Scrum-Master call, not a Reviewer waiver — 12e2 gives me
  no prose escape.

Note for whoever picks this up: `phase-P1:199-201` and `test-results.md §13.3`
state the bundle renderers are "absent from this worktree or anywhere under
`$HOME`". That is incorrect — both exist at
`/Users/alantravala/workspace/snapsofts/cupid-apps/.ai-team-bundle/runtime/tools/`
(they are gitignored, hence absent from the *worktree*). The real obstacle is the
capability gap described above, not a missing install; the note should be
corrected so option (a) is not dismissed as impossible.

## Required before DONE (independent of BLK-1)

These are cheap evidence-shape gaps that the DONE gate enforces literally. They
are not code defects, but the story cannot close with them open.

- **ACT-1 (frontend-dev)** — `coding-plan/test-results.md` has no
  `## Entry Point Reachability` section with a `Reachable: YES` line. The
  substance is present and correct as `## 12. Entry-point reachability (AC-1)`;
  it needs the literal heading plus `Reachable: YES` and the concrete path
  (`header nav "Hỗ trợ"/"Support" → /support`). Reviewer skill 12e1 requires that
  exact section; the same omission had to be patched retroactively in
  REQ-005/STORY-001.
- **ACT-2 (Scrum Master / Tech Lead)** — reviewer skill 12g requires story-level
  runtime startup smoke for a `frontend` lane story unless `story_master.md`
  records `Runtime-Smoke: WAIVED — <reason>`. `story_master.md` has no such line;
  the `NOT_APPLICABLE` decision lives only in `phase-P1:29`. Either mirror the
  waiver into `story_master.md` with its reason (static Astro build, no
  long-running service), or record `## Story Runtime Startup Smoke` in
  `test-results.md` — the §11 `astro preview` run on 127.0.0.1:22003 with 0
  console errors and 0 failed requests already is that evidence, just not under
  the heading the gate reads.

## Deferred findings

- **DEF-1 (shell / STORY-001, pre-existing — do not fix in this story)** — at
  375px the header row overflows and the VI/EN toggle and `Tải app` CTA are cut
  off at the right edge. Visible in `implemented-support-375-light-en.png` and
  `entry-point-mobile-select-375.png`: only logo + nav `<select>` + theme button
  fit. `SiteLayout.astro:34`'s wrapper carries `overflow-x:hidden`, so the
  clipped content produces **no** `scrollWidth > clientWidth` — which is why
  `test-results.md §10` reports 0 overflow occurrences in good faith and why
  STORY-001's own report claims all five controls fit on one row at 375. They do
  not. This is STORY-007-visible but STORY-001-caused (the story touched no
  shell file), so it is deferred here; it affects every page and should be routed
  as a shell fix or a queued bug at requirement level.
- **DEF-2 (config, carried from STORY-001 DEF-1)** — `app_render` is still
  missing from `data/devops/system/design-fidelity-config.json`. Folded into
  BLK-1 option (a).

## Traceability

- Requirements: `requirements/requirements.md` AC-1..AC-7, BR-1..BR-3. OQ
  discipline is clean — both requirement OQs are RESOLVED, the story records an
  empty BLOCKED list and a populated NOT-BLOCKED list, and nothing in the
  implementation is gated on an open question.
- UX: `ux/uiux-spec.md` §6.6 (focus rings — implemented as
  `.cupid-faq-summary:focus-visible` / `.cupid-support-mail:focus-visible`,
  `2px var(--acc-pink)` offset `2px`, matching the sitewide pattern), §6.8
  (fidelity scope, states, and the 375/768/1024/1440 checkpoints — all four
  captured in both themes and both languages).
- Architecture / plan: `coding-plan/phase-P1-support-faq-page.md` §4 AC and §6
  Test Scope. Every required check in §6 has a corresponding evidence section,
  and the phase Write Scope (`web/src/pages/support.astro`) was respected
  exactly. `package-lock.json` drift from `npm install` was reverted and the diff
  re-verified — good discipline, correctly recorded.
- Configuration guide: `phase-P1:60-62` records `Update Required: NO`. Correct —
  the story adds no env var, no external integration, and no manual setup step.
- Test evidence: `coding-plan/test-results.md` §1-§15, plus 26 PNGs under
  `visual-fidelity/`. I did not rerun the build or the DOM checks; the recorded
  evidence is specific, internally consistent, and matches what I read in the
  diff and the screenshots.

## Risk surfaces and gates

| Risk surface | Critical gate | Result |
|---|---|---|
| Frontend interaction (native disclosure) | disclosure independence, no JS state | PASS (§7, diff) |
| Frontend discoverability / navigation | entry-point reachability | PASS in code and evidence; **evidence heading missing (ACT-1)** |
| Typed contract / build | `npm run check` (0/0/0), `npm run build` (8 pages) | PASS (§1) |
| Rendered visual fidelity (12e2) | rendered design-reference comparison | **BLOCKED (BLK-1)** |
| Shared shell contract | diff containment | PASS (§6) |
| Runtime / configuration | story runtime startup smoke or recorded waiver | **Not recorded where the gate reads it (ACT-2)** |
| Browser runtime signals | console errors / failed requests | PASS — 0 and 0 across 16 runs (§11) |

## State recommendation

- Story status: `BLOCKED`
- Leave `Implementation (Development)` checked — the code is not at fault.
- Leave `Review (Reviewer)` unchecked.
- Do not merge the story branch into the requirement integration branch until
  BLK-1 is decided; the branch itself is clean and merge-ready on every other
  axis.
- Escalate BLK-1 at requirement level, not story level: it applies identically to
  STORY-002 through STORY-008.
