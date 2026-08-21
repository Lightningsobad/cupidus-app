# Visual Fidelity — REQ-006 / STORY-002 Pet Universe showcase page

VISUAL_FIDELITY: PASS

Rendered by Reviewer (non-mobile UI lane owns the render, reviewer skill 12e2),
2026-08-21, re-review pass `...-STORY-002-reviewer2`. Only the bundle renderer
was used (`render-running-app.js` → `visual-capture.js`) — no hand-rolled
Playwright/Puppeteer script, no `playwright test`, no live-runtime driving.

## Standard applied

Per the user decision recorded in
`data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/design-fidelity-tooling-fix.md`
("proceed with best-available evidence", 2026-08-21):

- Implementation side: a real `render-running-app.js` capture of the built app
  at 375/768/1280 — REQUIRED and produced here.
- Design-reference side: `render-design-canvas.js` can only reach the canvas's
  default `home` state, so for this screen the design reference is this story's
  `ux/uiux-spec.md` §6.2 / §6.7 / §6.8 tables (which were transcribed directly
  from `Cupid Web.dc.html:213-283`, `:741-747`, `:756-760`), not a
  screen-specific `design-reference-pets-*.png`.
- The absent screen-specific canvas render is recorded once as a deferred
  finding citing that document; it is not treated as a defect of this story.

Design-Screen: `isPets` (canvas state, `Cupid Web.dc.html:213-283`), resolved
from the requirement's own design anchor (`requirements.md` §Identity and
§Traceability).

## Implementation images — captured

| File | Viewport | Command |
|---|---|---|
| `implemented-pets-375.png` | 375 (full page, 375×3191) | `render-running-app.js --label=pets --route=/pets --breakpoints=375,768,1280 --full-page` |
| `implemented-pets-768.png` | 768 (full page, 768×1884) | same invocation |
| `implemented-pets-1280.png` | 1280 (full page, 1280×2048) | same invocation |

`implemented-pets-1400.png` is a leftover from the previous review pass and is
superseded by the three captures above.

Served from the production build (`npm run build` → `astro preview`, Node
v22.17.1) of THIS story's worktree, not the dev server, so no Astro dev-toolbar
overlay appears.

Capture-provenance note (material — see review report DEF-5): the first attempt
of this pass used the reserved `DEVSTACK_PORT_WEB` 21021 and the renderer
reported `reusing already-running server`. That server belonged to a *different*
parallel story worktree (`...-STORY-006`, verified via
`lsof -a -p <pid> -d cwd`), and the resulting screenshots showed a header and a
footer with no page body — the wrong build. The captures above were redone on a
private port 21231 after confirming `GET /pets` on that port returns the real
body (`Pet Universe` and `Bốn giai đoạn` both present in the served HTML) and
that the listening process's cwd is this story's worktree.

## Comparison against the design reference (uiux-spec)

Read at full size, not merely counted. Each row is checked against the
`uiux-spec.md` value it must reproduce.

| Aspect | uiux-spec reference | Rendered result |
|---|---|---|
| Hero eyebrow | §6.2.1 — literal `Pet Universe`, Roboto Mono 11px, tracked `.14em`, uppercase, `var(--acc-lilac)` | Matches at all three breakpoints; lilac mono caps, untranslated as required |
| Hero H1 | §6.2.1 — Nunito 900 52px, `letter-spacing:-.03em` | `Bé nào là bé của hai bạn?` at the specified weight/scale; wraps to 2 lines at 375 without clipping |
| Hero subcopy | §6.2.1 — 16px/1.65, `var(--c64)`, max-width 640 | Wraps inside a 640px measure at 1280 (line breaks after `bắt đầu —`); full text with the em dash present |
| Roster grid | §6.2.2 — `auto-fit, minmax(330px,1fr)`, gap 20, margin-top 40 | 3 columns at 1280, 2 at 768, 1 at 375 — pure fluid reflow, no column below the 330px floor |
| Card anatomy | §6.2.2 — sprite 130×130 left, text right, `padding:28px`, `gap:22px`, radius 30, 1px border, vertically centred | Matches; sprite box is square and equal across all six cards, text block vertically centred beside it |
| Six pets, order and copy | §6.2.2 table | Bo, Bun, Kem, Mochi, Sua, Xoài in that order, each with name, trait tag and full description in VI. No placeholder, no truncation, no omission |
| Per-pet tints and trait colours | §6.2.2 table | Bo pink, Bun lilac, Kem mint, Mochi butter, Sua peach, Xoài pink — each card tint distinct and each trait tag in the matching accent; Bo `.12` and Xoài `.1` remain visibly distinct |
| Stages panel | §6.2.3 — `var(--surf)` panel, radius 30, padding 34, header Nunito 800 22px | `Bốn giai đoạn lớn lên` panel present with the two-level surface nesting intact (lighter `var(--c05)` cells inside the `var(--surf)` panel), not flattened |
| Stage cells | §6.2.3 — `auto-fit, minmax(180px,1fr)`, gap 16, numeral mono 10px pink | `01 Trứng / 02 Bé con / 03 Trưởng thành / 04 Linh thú` in order: 4-up at 1280, 3+1 at 768, stacked at 375; numerals mono-pink |
| Active nav state | §6.1 / AC-1 | Desktop `Pet` pill carries the pink fill at 1280; mobile `<select>` shows `Pet` selected at 375/768 |
| Anti-pattern check | §6.7 — no hover-lift on these cards | No elevation/shadow treatment on roster or stage cards in the render |
| Responsive floors | §6.8 — no card below 330px, no cell below 180px, no overlap | Holds at all three breakpoints; nothing overlaps, no content is cut vertically |

No visible deviation from the uiux-spec's documented layout, spacing,
typography, or colour-token intent was found at any of the three breakpoints.

## Recorded deltas (not defects of this story)

1. **Right gutter asymmetry at ≤394px.** At 375 the roster track floors at the
   design's own `minmax(330px,1fr)` and overhangs the section content box
   (`375 − 2×32 = 311`), so the right gutter shrinks to roughly 13px against
   32px on the left. Nothing is clipped and the page does not scroll
   horizontally. Reproducing `minmax(330px,1fr)` verbatim is exactly what
   UI-Fidelity-AC and BR-2 require, so this is the design's own value, not an
   implementation deviation.
2. **Shell header at 375 clips the VI/EN toggle and the `Tải app` CTA.** Present
   identically in STORY-001's own `implemented-home-375.png`, on a shell file
   this story does not touch. Pre-existing, not a STORY-002 regression.

## Not captured

`design-reference-pets-*.png` does not exist and cannot be produced in this
repository. `render-design-canvas.js` drives `[data-screen-btn]`/`[data-tog]`/
`[data-plat]`; this canvas selects its page through the `startPage` React prop
(`Cupid Web.dc.html:679`, consumed `:709`), so only the default `home` state is
reachable. The fix belongs in the separate bundle source repo and is out of
scope here — see `design-fidelity-tooling-fix.md` §"Fix 2 — BLOCKED" and the
user decision recorded there.
