# Visual Fidelity — REQ-006 / STORY-002 Pet Universe showcase page

VISUAL_FIDELITY: BLOCKED — DESIGN_SCREEN_NOT_FORCEABLE

No `VISUAL_FIDELITY: PASS` is claimed. The implementation side was rendered;
the design side could not be, so no comparison happened and none is asserted.

Rendered by Reviewer (non-mobile UI lane owns the render, reviewer skill 12e2).
Only the bundle renderers were used — no hand-rolled Playwright/Puppeteer
script, no `playwright test`.

## Resolved design screen

Design-Screen: `isPets` (canvas state, `Cupid Web.dc.html:213-283`)

Not recorded by the story before this review — `Design-Screen` appears nowhere
in `STORY-002/`. It is resolved here from the requirement's own design anchor
(`requirements/requirements.md` §Identity and §Traceability both cite the
`isPets` conditional block).

## Implementation images — captured

| File | Command |
|---|---|
| `implemented-pets-375.png`, `implemented-pets-768.png`, `implemented-pets-1400.png` | `visual-capture.js --mode=url --url=http://127.0.0.1:21021/pets --label=pets --breakpoints=375,768,1400 --full-page` |

Served from the production build (`npm run build` → `astro preview --port 21021
--host 127.0.0.1`, Node v22.17.1), not the dev server, so no Astro dev-toolbar
overlay appears in the capture.

## Design reference images — NOT captured (blocker)

`design-reference-pets-*.png` does not exist. Neither sanctioned bundle renderer
can select this canvas's Pets state:

1. `render-design-canvas.js --location=<bundle> --entry="Cupid Web.dc.html"
   --list-screens` returns `{"entry":"Cupid Web.dc.html","screens":[],
   "toggles":[],"platforms":[]}`. `--screen` clicks `[data-screen-btn]`,
   `--theme`/`--lang` click `[data-tog]`, `--platform` selects `[data-plat]`.
   This canvas has none of those controls, so all four flags are inert.
2. The Pets screen is instead the `isPets` branch of one `<sc-if>` tree,
   selected by the `startPage` component prop — declared as an enum with
   options `home|pets|zodiac|share|blog|about|support|legal` and default
   `home` at `Cupid Web.dc.html:679`, consumed at `:709`
   (`this.state.page || this.props.startPage || "home"`). Neither renderer can
   set a canvas prop.
3. `visual-capture.js` state levers are `--storage-state`, `--fake-state`
   (cookies / localStorage / sessionStorage / `page.route` mocks) and
   `--wait-selector`. The canvas reads localStorage for `cupid-web-theme` only;
   it never reads `page`/`startPage` from storage, a cookie, or the URL.
4. Tested empirically rather than assumed: the bundle was served over loopback
   and captured at
   `http://127.0.0.1:21055/Cupid%20Web.dc.html?startPage=pets`. The resulting
   image was read and shows the **Home** screen (`Trang chủ` pill active, "Nuôi
   tình yêu như nuôi một bé pet" hero, feature grid, `Sáu bé, sáu tính cách`
   teaser, `Ba bước…` panel). The query param is ignored.

Reaching the state would require clicking the canvas's own `Pet` nav pill,
which is a hand-rolled browser script and is prohibited by 12e2.

Per 12e2 the Reviewer must not self-provision or edit `design_source`
configuration to work around this, and did not. Resolving how a non-default
canvas screen becomes a design reference is a ui-ux-designer / Scrum Master
decision, and it affects every remaining page story in REQ-006 (Zodiac, Invite,
Blog, About, Support, Legal are all non-default `isX` states of this same
canvas).

## What the implementation images do establish

Read at full size, not merely counted:

| Breakpoint | Observation |
|---|---|
| 1400 | Hero eyebrow `PET UNIVERSE`, H1 `Bé nào là bé của hai bạn?`, subcopy with the em dash. Six pet cards in design order Bo, Bun, Kem, Mochi, Sua, Xoài across 3 columns, each with sprite, name, trait tag in its own accent, and description. Four-stage panel `01 Trứng / 02 Bé con / 03 Trưởng thành / 04 Linh thú` in one row inside the raised `var(--surf)` panel. Header `Pet` pill carries the active pink fill. No placeholder, no error frame, no blank span. |
| 768 | Captured; single file, not separately analysed below. |
| 375 | Mobile `<select>` is the visible nav control with `Pet` selected. Single-column roster, stages stacked, footer stacked. Card text intact, nothing clipped. |

### 375 gutter measurement (checked, not eyeballed)

A 1:1 crop of the Bo card row was inspected. The card's rounded **right** corner
is visible with roughly 13 px of background between it and the viewport edge,
against 32 px on the left. This is the arithmetic consequence of the design's
own `minmax(330px,1fr)` (`:220`) inside the section's `311 px` content box
(`375 − 2×32`): the track floors at 330 px and overhangs its container by 19 px.
Nothing is clipped and the document does not scroll horizontally, so AC-7's
literal text holds; the asymmetric gutter is recorded as a deferred fidelity
note, not a defect, because reproducing `minmax(330px,1fr)` verbatim is what
UI-Fidelity-AC and BR-2 require.

## Compensating evidence (does NOT substitute for the rendered comparison)

`Cupid Web.dc.html:213-283` was read and compared declaration-by-declaration
against the five implementation files. Every inline style string and every VI/EN
literal is reproduced exactly: section `max-width:1200px;margin:0 auto;
padding:70px 32px 90px`; hero `max-width:640px` with the eyebrow left unwrapped
as in the source; roster grid `repeat(auto-fit,minmax(330px,1fr));gap:20px;
margin-top:40px`; card `border:1px solid var(--c11);border-radius:30px;
padding:28px;display:flex;gap:22px;align-items:center` with per-pet `bg`/`color`
from `:741-747` including Bo `.12` and Xoài `.1` kept distinct; sprite box
`flex:0 0 130px`; name Nunito 900 26px; trait Roboto Mono 10px `.1em` uppercase
`margin:4px 0 10px`; description 13.5px/1.6 `var(--c66)`; stages panel
`margin-top:40px;background:var(--surf);border-radius:30px;padding:34px` with
header Nunito 800 22px, inner grid `minmax(180px,1fr);gap:16px;margin-top:22px`,
cell `var(--c05)` radius 20 padding 18, numeral Roboto Mono 10px
`var(--acc-pink)`, title Nunito 800 16px `margin:6px 0 6px`, description
12.5px/1.55 `var(--c58)`. The two-level surface nesting is retained.

This is strong evidence of a faithful port, but 12e2 requires rendered images on
both sides, and "verified by source inspection" is exactly the substitution the
rule refuses. It is recorded as context for the next pass, not as a pass.
