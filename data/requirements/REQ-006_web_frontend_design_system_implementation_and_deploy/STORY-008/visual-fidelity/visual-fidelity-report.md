# Visual Fidelity Report — REQ-006 / STORY-008 Legal (Privacy & Terms)

VISUAL_FIDELITY: PASS

- Screen: `legal` (`isLegal` block, `Cupid Web.dc.html:639-653`)
- Design-Screen: NOT_RESOLVABLE — `render-design-canvas.js --list-screens`
  returns `{"screens":[],...}` for this canvas; see
  `../../design-fidelity-tooling-fix.md`. Per the user-confirmed standard in
  that document, the design-reference side for every non-`home` REQ-006 screen
  is satisfied by `ux/uiux-spec.md` §6.2 / §6.8, not a screen-specific canvas
  render.
- Rendered by: Reviewer (frontend lane owns render+compare), bundle tool
  `.ai-team-bundle/runtime/tools/render-running-app.js` against the built
  STORY-008 worktree app. No hand-rolled Playwright, no live-runtime driving.

## Implementation Renders (real captures, this review run)

| File | Breakpoint | Mode | State |
|------|-----------|------|-------|
| `implemented-legal-375.png` | 375 | viewport | VI / dark |
| `implemented-legal-768.png` | 768 | viewport | VI / dark |
| `implemented-legal-1280.png` | 1280 | viewport | VI / dark |
| `implemented-legal-fullpage-375.png` | 375 | full page | VI / dark |
| `implemented-legal-fullpage-768.png` | 768 | full page | VI / dark |
| `implemented-legal-fullpage-1280.png` | 1280 | full page | VI / dark |
| `implemented-legal-en-light-1280.png` | 1280 | full page | EN / light (forced via `fake_state` localStorage, AC-4) |

Serving note: the repo-reserved `DEVSTACK_PORT_WEB` (21021) was held by a
parallel peer worktree's preview server (STORY-006). That peer server was left
untouched; this review leased its own port via
`devstack port lease --slot story-review-008 --role web` → 22003, served the
STORY-008 build there, and pointed the same bundle renderer at it. Served
`/legal` was confirmed to be this story's build (19,705 bytes, 5 `<h2>`)
before any capture was taken.

## Per-Breakpoint Verdict Against `uiux-spec.md` §6.2 / §6.8

| Anchor (uiux-spec) | 375 | 768 | 1280 | Observed |
|--------------------|-----|-----|------|----------|
| 820px max-width column, centered, `32px` side padding | PASS | PASS | PASS | at 1280 the column measures ~800px centered on the 1280 axis; at 768 and 375 it correctly collapses to `100vw - 64px` with the 32px gutters held, exactly as §6.6 requires (no breakpoint added) |
| No horizontal scroll / no clipping at 375 | PASS | — | — | full-page 375 capture shows the whole column inside the viewport, text wrapping, nothing cut |
| Single column, no grid, no cards, no `--surf` panel, no radius | PASS | PASS | PASS | content body carries no surface, no shadow, no rounded container at any width |
| Only separator is a 1px top border per section | PASS | PASS | PASS | five thin rules, one above each section title; no other divider or chrome |
| Eyebrow "Legal", Roboto Mono, uppercase, wide tracking, `--c5` | PASS | PASS | PASS | renders as `LEGAL` (unlocalized in both VI and EN captures), muted against the H1 |
| H1 Nunito 900 48px, tight tracking, `--ink` | PASS | PASS | PASS | heaviest element on the page; wraps to 3 lines at 375, 1 line at 768/1280 |
| Updated-date line, Roboto Mono 11.5px, `--c45` | PASS | PASS | PASS | `Cập nhật 29.07.2026` / `Updated 29 Jul 2026`, dimmer than the H1, sits directly under it |
| 5 sections, source order, `gap:26px`, `padding-top:22px` | PASS | PASS | PASS | all five present in the documented order, evenly spaced, at every breakpoint |
| Section title Nunito 800 19px `--ink`; body 14.5px `line-height:1.7` `--c64` | PASS | PASS | PASS | title clearly heavier/darker than body; body lines comfortably leaded |
| No accordion / collapse / TOC / jump links | PASS | PASS | PASS | all five sections fully expanded, no interactive affordance |
| No brand accent colors in the content body | PASS | PASS | PASS | body uses only the neutral ink/opacity tokens; pink appears only in shared header/footer chrome |
| Theme + locale parity (AC-4), no page-local toggle | — | — | PASS | EN/light capture renders all five sections in English on the light token set, correct ink/contrast; achieved purely through the shell's `cupid-web-lang`/`cupid-web-theme` keys |
| Header stays 7 items, Legal is footer-only | PASS | PASS | PASS | header shows 7 nav items in both locales; footer shows the `PHÁP LÝ`/`LEGAL` column with both links |

## Deltas

None visible. No layout, spacing, sizing, color, typography, or state
discrepancy was observed against the documented design anchor at any
breakpoint or in either locale/theme state.

One intentional, governing-input-approved difference from the raw prototype
markup: section titles are `<h2 style="margin:0 0 9px">` where
`Cupid Web.dc.html:647` uses an unsemantic `<div style="margin-bottom:9px">`.
`uiux-spec.md` §6.6 mandates this for screen-reader navigation, and the
explicit `margin:0 0 9px` cancels the UA heading top-margin so rendered
geometry is unchanged. This is a required accessibility improvement, not a
fidelity deviation.

## Known, Permanently Deferred Gap

No `design-reference-legal-<bp>.png` exists and none can be produced in this
repository. `render-design-canvas.js` can only drive this canvas to its default
`startPage: "home"`, and the fix for that is out-of-repo bundle work
(`design-fidelity-tooling-fix.md`, Fix 2 = BLOCKED, user decision 2026-08-21:
proceed with best-available evidence). Recorded once here as a deferred
finding; not a defect in this story and not grounds to withhold approval.
