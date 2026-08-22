# Visual Fidelity Report — REQ-006 / STORY-002 Pet Universe Showcase Page

VISUAL_FIDELITY: FAIL

- Screen: `pets` (`design_sources[id=cupid-web].screen_prop = startPage`)
- Route: `/pets/` (implemented at `web/src/pages/pets.astro`)
- Reviewed at: 2026-08-22 (re-review under the third user decision in
  `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/design-fidelity-tooling-fix.md`)
- Supersedes the 2026-08-21 pass, which recorded `VISUAL_FIDELITY: PASS` under
  the now-abolished `SPEC-CITED` / best-available-evidence standard.

## Why this is FAIL and what it does NOT mean

The rendered design reference and the rendered implementation do not match at
1280 or 768. The measured cause is on the **design-reference render side**: the
canvas renderer collapses the pet-card sprite slot from the source-declared
`130px` to `~76px`. The implementation reproduces the design source markup
character-for-character on exactly that property.

This is therefore recorded as FAIL because the required rendered-vs-rendered
comparison genuinely does not match — not as an assertion that
`web/src/components/pets/PetRoster.astro` is wrong. See BLK-VF-1 in
`review/review-report.md`. Changing the implementation to match this render
would move it **away** from the design source and would break UI-Fidelity-AC
and BR-2.

## Evidence

Design reference — real `render-design-canvas.js` captures (exit 0):

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=web --screen=pets --out=<story>/visual-fidelity/design-reference
```

| File | Pixel size |
|---|---|
| `design-reference/design-reference-pets-375.png` | 375x600 |
| `design-reference/design-reference-pets-768.png` | 768x1229 |
| `design-reference/design-reference-pets-1280.png` | 1280x2048 |

Implementation — real `render-running-app.js` capture (exit 0), full page:

| File | Pixel size |
|---|---|
| `implemented/implemented-pets-375.png` | 375x3191 |
| `implemented/implemented-pets-768.png` | 768x1884 |
| `implemented/implemented-pets-1280.png` | 1280x2048 |

Build re-run by Reviewer in this worktree: `npm run build` PASS, 8 static pages,
Node v22.17.1.

Server identity was verified before capture (see DEF-5 in the prior review): the
reserved port 21021 was held by the **STORY-003** worktree's preview server, so
this story's build was served on a private port 21023 and confirmed with
`lsof -a -p <pid> -d cwd` = `story-...-STORY-002/web`, `GET /pets/` → 200,
`<title>Pets — Cupid</title>`. The flat `implemented-pets-*.png` files at the
root of this directory are the superseded 2026-08-21 captures.

## Measured comparison, 1280px

Both renders agree that the first pet card's left edge is at `x=40`. The source
declares the card `padding:28px` and the flex `gap:22px`
(`cupid-app-design-system/Cupid Web.dc.html:221-222`), so the sprite slot starts
at `x=68` in both, and the text column's left edge gives the slot width directly.

| Measurement | Design reference | Implementation | Source declares |
|---|---|---|---|
| Card left edge | `x=40` | `x=40` | — |
| Sprite ink run | `x=79..135` (57px) | `x=87..183` (97px) | — |
| Text column left edge | `x=166` | `x=221` | — |
| Derived sprite slot width (`text_left − 22 − 68`) | **76px** | **131px** | **130px** |
| Text column width | 228px | 169px | — |
| Bo description line count | 2 | 3 | — |

The implementation lands on the source-declared 130px (131 measured, 1px
border). The design reference lands on 76px, which the source markup does not
declare anywhere.

Consequence at 1280: the narrower text column rewraps every pet description
(Bo, Kem, Mochi, Sua, Xoài) from 2 lines to 3. At 768 the same cascade rewraps
them from 3 lines to 4. The card boxes, grid columns, gaps, radii, background
tints, type sizes, and colour tokens are otherwise identical between the two
renders.

## Root cause of the render-side divergence

`Cupid Web.dc.html:222` declares the slot as:

```html
<dc-import name="Bo Sprite" hint-size="130px,130px" style="width:130px;height:130px;flex:0 0 130px"></dc-import>
```

`PetRoster.astro:30` reproduces it as:

```html
<div style="width:130px;height:130px;flex:0 0 130px"><Sprite size={130} /></div>
```

The two are equivalent, and a browser rendering the source markup directly would
produce a 130px flex item, because a flex item is blockified and `flex-basis`
applies. The canvas render does not: it resolves `<dc-import>` and loses the
element's declared inline size, so the slot falls back to the sprite's natural
size (~76px).

Calibration against `home`, which STORY-001 certified CLEAN with a real canvas
render, is consistent with this single mechanism rather than with an
implementation defect. On home the sprite sits in
`<div style="height:130px;display:grid;place-items:center">` with the import at
`120px` (`Cupid Web.dc.html:169` and siblings). A slot that collapses to its
natural size is still centred by `place-items:center`, so the home layout is
unaffected and the two home renders agree. The pets cards put the same slot in a
flex row, where a collapsed slot shifts everything after it — which is why this
surfaces on `pets` and never surfaced on `home`.

## Breakpoint coverage

| Breakpoint | Design reference | Comparable? |
|---|---|---|
| 1280 | full page (1280x2048) | yes — divergence measured above |
| 768 | 768x1229, truncated | partial — roster visible; same divergence, descriptions 3→4 lines |
| 375 | 375x600, viewport height only | **no** — covers header + hero only; the roster and stage grid are not in frame |

Two further design-reference render limitations, recorded so they are not
mistaken for implementation defects:

- The 375 and 768 canvas captures are not full-page, so there is no
  design-reference image of the roster or the stage explainer at 375.
- At 375 the canvas's own header overflows horizontally (nav links stacked and
  running off-canvas). The implementation uses STORY-001's mobile `<select>`
  chrome there. This is shell behaviour owned by STORY-001; this story's diff
  touches no shell file.

## Aspects that DO match

Verified against the rendered pair at 1280 and 768, and against
`ux/uiux-spec.md` §6.2/§6.7/§6.8:

- Section max-width, page padding, and the `auto-fit minmax(330px,1fr)` roster
  grid: 3 columns at 1280, 2 at 768, 1 at 375, with the same 20px gap.
- All six pets present, in design order, with the correct sprite, name, trait
  tag, and description text in both renders.
- Per-pet card background tints, 30px radius, and 1px `var(--c11)` border.
- Hero eyebrow, H1, and supporting paragraph: identical position, size, and
  line breaks in both renders.
- Growth-stage block: heading, 4 stages in order `01..04`, `minmax(180px,1fr)`
  reflow (4 columns at 1280, 3+1 at 768, 1 at 375), identical copy.
- Footer and header chrome at 1280: identical, including the active `Pet` pill.

## Verdict

`VISUAL_FIDELITY: FAIL` — the required rendered design-vs-implementation
comparison does not match at 1280 or 768, and the 375 comparison cannot be
performed. The divergence is measured to originate in the design-reference
renderer, not in this story's code, so it is escalated as BLK-VF-1 rather than
handed back to the frontend lane as a patch.
