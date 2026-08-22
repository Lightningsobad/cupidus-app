# Visual Fidelity Report — REQ-006 / STORY-002 Pet Universe Showcase Page

VISUAL_FIDELITY: PASS

- Screen: `pets` (`design_sources[id=cupid-web].screen_prop = startPage`)
- Route: `/pets/` (implemented at `web/src/pages/pets.astro`)
- Reviewed at: 2026-08-22 (BLK-VF-1 re-verification pass, run
  `RUN-REQ-006_web_frontend_design_system_implementation_and_deploy-STORY-002-reviewer3`)
- Supersedes the earlier 2026-08-22 `VISUAL_FIDELITY: FAIL` on this same file,
  which was caused by the `support.js` renderer defect now fixed. That FAIL body
  is retained below as historical record under "Superseded 2026-08-22 FAIL".

## Verdict (2026-08-22 re-verification)

`VISUAL_FIDELITY: PASS`. The rendered design reference and the rendered
implementation now agree at 1280 and 768 on the pet-card sprite slot, the text
column origin, and the resulting description line wrapping. This closes the sole
open blocking finding `BLK-VF-1`.

Scope of this pass: `BLK-VF-1` only. No other AC row, finding, or evidence
section was re-verified; they stand as recorded in the prior cycle.

### What changed

The renderer defect was fixed, not the implementation.
`cupid-app-design-system/support.js`'s `hostPositionStyle()` copies `dc-import`
host styles through a `HOST_STYLE_PROPS` allowlist that omitted the flex
properties, so `Cupid Web.dc.html:222`'s `flex:0 0 130px` was silently stripped
and the sprite collapsed to its natural size under sibling flex pressure. The
fix adds `flex`, `flex-shrink`, `flex-basis`, and `flex-grow` to that allowlist.

- Fix on `main`: `9aa0aed`
- Mirrored into this worktree: `5907aea` (`support.js`, +5/−1)
- Design references re-rendered with the patched renderer: `d64feab`
  (`design-reference-pets-1280.png`, `design-reference-pets-768.png`)
- `Cupid Web.dc.html` and `web/src/components/pets/PetRoster.astro` are
  **unchanged** since `BaseHead` `67efb8e` — verified with
  `git diff --stat 67efb8e HEAD -- "cupid-app-design-system/Cupid Web.dc.html" web/src/components/pets/PetRoster.astro`
  (empty). Both were already correct.

### Measured re-verification

Same derivation the prior FAIL used (both renders put the first card's left edge
at `x=40`; the source declares `padding:28px` and `gap:22px`, so the sprite slot
starts at `x=68` and the text column's left edge yields the slot width).

| Measurement, 1280 | Design reference (before fix) | Design reference (after fix) | Implementation | Source declares |
|---|---|---|---|---|
| Text column left edge | `x=166` | **`x=222`** | `x=222` | — |
| Derived sprite slot width | 76px | **132px** | 132px | 130px (+1px border each side) |
| Bo sprite ink run | `x=79..135` (57px) | **`x=87..184` (98px)** | `x=87..183` (97px) | — |
| Bo description lines | 2 | **3** | 3 | — |

| Measurement, 768 | Design reference (after fix) | Implementation |
|---|---|---|
| Text column left edge | `x=214` | `x=214` |
| Bo sprite ink run | `x=79..176` (98px) | `x=79..175` (97px) |

Design-reference and implementation sprite ink runs agree within 1px at both
1280 and 768, and the text column origin is pixel-identical at both. All six
sprites (Bo, Bun, Kem, Mochi, Sua, Xoài) render at the same box in both images.

Measurement method: per-pixel bounding box of the sprite's warm body pixels
(`r − b > 40 and r > 140`, restricted to contiguous rows ≥40px wide so ambient
sparkle decorations are excluded), plus first column with ≥3 pixels above
luminance 110 for the text column edge. Run with Python/PIL 11.3.0 against the
committed PNGs.

Residual non-blocking differences inside the card, inspected at 3x zoom: the
ambient decorative sparkles are at different positions/sizes between the two
renders, and the sprite sits ~4px higher in the implementation capture. The
sparkles are randomised/animated ambience, and the vertical delta follows from
the implementation capture being a full-page screenshot versus a fixed-height
canvas artboard. Neither is a layout defect and neither is blocking.

### Breakpoint note (pre-existing, not new)

`design-reference-pets-375.png` was not re-rendered at `d64feab` and remains the
375x600 viewport-height artboard that stops inside the hero, so the 375
design-vs-design comparison for the roster still cannot be performed. This is
the same pre-existing canvas-capture limitation already recorded in the prior
cycle, not a new defect and not part of `BLK-VF-1`. It is carried forward as a
residual risk rather than re-opened.

---

## Superseded 2026-08-22 FAIL (historical record)

The rendered design reference and the rendered implementation did not match at
1280 or 768. The measured cause was on the **design-reference render side**: the
canvas renderer collapsed the pet-card sprite slot from the source-declared
`130px` to `~76px`. The implementation reproduced the design source markup
character-for-character on exactly that property.

This was recorded as FAIL because the required rendered-vs-rendered
comparison genuinely did not match — not as an assertion that
`web/src/components/pets/PetRoster.astro` was wrong. See BLK-VF-1 in
`review/review-report.md`. Changing the implementation to match that render
would have moved it **away** from the design source and would have broken
UI-Fidelity-AC and BR-2.

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

## Verdict (superseded)

`VISUAL_FIDELITY: FAIL` — the required rendered design-vs-implementation
comparison does not match at 1280 or 768, and the 375 comparison cannot be
performed. The divergence is measured to originate in the design-reference
renderer, not in this story's code, so it is escalated as BLK-VF-1 rather than
handed back to the frontend lane as a patch.

**Superseded 2026-08-22 by the re-verification at the top of this file:** the
renderer defect was fixed in `support.js` (`9aa0aed` / `5907aea`), the design
references were re-rendered (`d64feab`), and the comparison now matches at 1280
and 768. Current verdict is `VISUAL_FIDELITY: PASS`.
