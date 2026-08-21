# Visual Fidelity Report — REQ-006 / STORY-007 Support FAQ Page

VISUAL_FIDELITY: PASS

- Screen: `support` (route `/support/`)
- Design-Screen: `support` — the `isSupport` section of
  `cupid-app-design-system/Cupid Web.dc.html`, lines 614-637 (markup) and
  814-821 (FAQ seed data), as resolved in `ux/uiux-spec.md` §1 and §6.8
- Lane: `frontend` (browser render owned by the Reviewer, per reviewer rule 12e2)
- Captured by: Iris-QC (pass 2 full-story-review), 2026-08-21

## Evidence standard applied

This story is governed by the user-confirmed standard in
`data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/design-fidelity-tooling-fix.md`
("User decision (2026-08-21, second decision on this doc)"):

- **Implementation side — REQUIRED and produced here.** A real
  `render-running-app.js` capture of the built app at 375/768/1280.
- **Design-reference side.** `render-design-canvas.js` can only drive this
  canvas to its default `startPage: "home"` state, so a
  `design-reference-support-<bp>.png` is not producible in this repository
  (Fix 2 is structurally blocked — the renderer is gitignored, generated
  bundle output from a separate source repo). For every non-`home` screen the
  design-reference side is satisfied by `ux/uiux-spec.md` plus the cited
  design-source line range. Recorded once as DEF-3 in the review report; not a
  defect to re-open.

## How the implementation render was produced

```
node .ai-team-bundle/runtime/tools/render-running-app.js \
  --project=<reviewer scratch root> \
  --out=<story>/visual-fidelity --label=support --route=/support/ \
  --breakpoints=375,768,1280 --full-page
-> {"ok":true,"screenshots":[...375.png, ...768.png, ...1280.png]}
```

Two deviations from the plain invocation, both recorded so the run is
reproducible:

1. **`--project` points at a reviewer-local scratch root, not the worktree.**
   The STORY-007 branch is based on `2e72902d`, which predates the merge of
   Fix 1, so the worktree's own
   `data/devops/system/design-fidelity-config.json` still has no `app_render`
   block and the renderer exits `4 APP_RENDER_NOT_CONFIGURED` against it. The
   scratch root supplies an `app_render` block identical in shape to the one
   DevOps merged to `main`, without writing to the repository. `design_source`
   was NOT self-provisioned — it is already configured and locked in the
   worktree (`entry: "Cupid Web.dc.html"`, `ui_surface: true`).
2. **Port 22003, not the pinned 21021.** `devstack port lease --slot
   story-007-review2 --role web` returned 22003. The pinned `DEVSTACK_PORT_WEB`
   (21021) was already held by another agent's server serving a *different*
   worktree — probed before use: it returned `<title>Cupid</title>` with **0**
   `<details>` elements, i.e. the pre-STORY-007 empty Support page. Reusing it
   would have produced a confident PASS against the wrong code. The lease was
   released after the run and 22003 confirmed free.

`start_cmd` ran `npm run build` before `npm run preview`, so the capture is of
the story branch's freshly built `dist/`, not stale output. No hand-rolled
Playwright script was used; no `playwright test` was run; the dev server was
auto-started and torn down by the tool.

## Per-breakpoint verdict

| Breakpoint | File | Verdict | Observations against `uiux-spec.md` §6.1-6.3, §6.8 |
|---|---|---|---|
| 375 | `implemented-support-375.png` | **PASS** | Mint `SUPPORT` eyebrow; `<h1>` held at 50px and wrapped to two lines with **no** invented mobile downscale (§6.1 explicitly forbids one); single-column FAQ stack, 6 cards, `--surf` fill, 20px radius, 10px gaps; question text wraps *within* its flex item with the pink `expand_more` chevron pinned top-right — the icon never drops below the question (§6.6); contact card `flex-wrap`s to title/subtext stacked above the `hi@cupid.app` pill (§6.3); no horizontal overflow. |
| 768 | `implemented-support-768.png` | **PASS** | 860px section not yet reached, so the 32px side padding governs; heading on one line at 50px; six evenly spaced cards; contact card back to the `space-between` row with the pill right-aligned; spacing above the contact card reads as the specified 34px. |
| 1280 | `implemented-support-1280.png` | **PASS** | Section centred at its 860px max-width with 70/32/90 padding; Nunito 900 / -.03em heading; six `--surf` cards with `--c09` hairline borders and pink chevrons right-aligned via `space-between`; gradient contact card (pink→violet, 26px radius) with the light `--ink90`/`--bg` 999px pill; header nav shows `Hỗ trợ` in the pink `aria-current` pill. |

## Design-source equivalence (design-reference side)

Independently re-derived by the reviewer, not taken from the implementer's
claim: every inline `style` string in `web/src/pages/support.astro` is
byte-identical to `Cupid Web.dc.html:615-635` — the `860px` / `70px 32px 90px`
section, the Roboto Mono 11px `.14em` `--acc-mint` eyebrow, the Nunito
900/50px/-.03em heading, the `gap:10px` column, the
`--surf`/`--c09`/20px/`20px 24px` details, the `space-between` 16.5px summary,
the 20px `--acc-pink` icon, the 14px/1.65 `--c64` answer, the 34px-margin
gradient card, the 19px title, the 14px `--c62` subtext, and the
`--ink90`/`--bg` 999px pill. All six FAQ strings match `:814-821`.

The only additions over the source are `aria-hidden="true"` on the decorative
icon and two `class` hooks carrying `:focus-visible` rings — both explicitly
required by `uiux-spec.md` §6.5/§6.6. No `details[open]` icon rotation or other
invented open-state treatment was added, which §6.2 forbids.

## States

- FAQ closed (all six): the three captures above.
- FAQ entry 3 open with the other five closed:
  `implemented-support-{375,768,1024,1440}-dark-vi-entry3-open.png`.
- `mailto:` pill hover: `implemented-support-mailto-pill-hover.png`.
- Focus rings: `implemented-support-focus-summary.png`,
  `implemented-support-focus-mailto.png`.
- Light theme and EN language: `implemented-support-*-light-*.png`,
  `implemented-support-*-*-en.png`.

(The `*-{dark,light}-{vi,en}` matrix and the state captures are the
implementer's, from `coding-plan/test-results.md` §13.2. The three
`implemented-support-{375,768,1280}.png` files are this review's own
independent bundle-renderer capture and are the evidence rule 12e2 reads.)

## Known deviation, not a story defect

At 375px the shared header clips its right edge: only logo, mobile `<select>`
and the theme button are visible — the VI/EN toggle and the `Tải app` CTA are
cut off. Visible in `implemented-support-375.png`. This is shell chrome owned
by STORY-001; STORY-007 modified no shell file (diff contains one tracked
source file). Carried as DEF-1 in the review report for requirement-level
routing, not fixed here.
