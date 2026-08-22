# Visual Fidelity — REQ-006 / STORY-001 Home landing page

VISUAL_FIDELITY: PASS

Rendered and compared by Reviewer (non-mobile UI lane owns the render per
reviewer skill 12e2). No hand-rolled Playwright/Puppeteer script; no
`playwright test`.

## Resolved design screen

Design-Screen: `(canvas default state — isHome)`

`render-design-canvas.js --list-screens` on `Cupid Web.dc.html` returns
`{"screens":[],"toggles":[],"platforms":[]}`. This bundle is a **web** canvas,
not a device canvas: it exposes no `[data-screen-btn]` control, no `[data-tog]`
toggle and no `[data-plat]` device frame. Page state is instead selected by the
runtime's `startPage` enum driving `<sc-if>` blocks, and the entry's default
state is `isHome` (`Cupid Web.dc.html:79`,
`<sc-if value="{{ isHome }}" hint-placeholder-val="{{ true }}">` — the only
block whose placeholder value is `true`; `isPets`/`isZodiac`/`isShare`/`isBlog`/
`isAbout`/`isSupport`/`isLegal` at :213/:285/:387/:453/:511/:614/:639 are all
`false`). So the default render IS the Home screen, and the reference below
depicts the screen this story is about — confirmed by reading the images, not
by the filename.

## Tooling

| Image set | Command |
|---|---|
| Reference (desktop canvas) | `render-design-canvas.js --location=<worktree>/cupid-app-design-system --entry="Cupid Web.dc.html" --label=home --platform=all --max-edge=0` → falls back to full-page (`design-reference-home-canvas.png`, 2800x4608 @dsf2) because the canvas has no device frame |
| Reference (per breakpoint) | `visual-capture.js --mode=design --location="<worktree>/cupid-app-design-system/Cupid Web.dc.html" --label=home --breakpoints=375,768,1400 --full-page` |
| Implementation | `visual-capture.js --mode=url --url=http://127.0.0.1:21021/ --label=home --breakpoints=375,768,1400 --full-page` |

`render-running-app.js` could not be used: `data/devops/system/design-fidelity-config.json`
has no `app_render` block, so it exits `4 APP_RENDER_NOT_CONFIGURED`. Per the
handoff's stated fallback the dev server was started from the runtime command
registry contract instead (`runtimes.web-frontend`: `npm run dev -- --port
"$DEVSTACK_PORT_WEB" --host 127.0.0.1`, reserved port **21021**, Node pinned to
v22.17.1 for the `>=22.12.0` engine), rendered with `visual-capture.js` (the
other sanctioned bundle renderer), and torn down after. See DEF-1 in the review
report — `app_render` should be configured so this story's successors get the
one-command path.

## Files

- `design-reference-home-375.png` / `implemented-home-375.png`
- `design-reference-home-768.png` / `implemented-home-768.png`
- `design-reference-home-1400.png` / `implemented-home-1400.png`
- `design-reference-home-canvas.png` (full-page desktop canvas, dsf 2)

## Per-breakpoint verdict

### 1400 (the design's own declared canvas width) — PASS

Full-page height **2304 px in both** images. Every section lands at the same
Y offset: header 0–60, hero badge/headline/subcopy/store badges/stat row,
4-up feature grid, `Sáu bé, sáu tính cách` 6-up pet cast, `Ba bước…`
gradient panel with the 3-of-4 track gap, footer with 3 link columns and the
`© 2026 Cupid Labs` line. Typography, weights, letter-spacing, pill/radius
geometry, token colours, the active `Trang chủ` pink pill, the VI/EN toggle
state and the `Tải app` gradient CTA all read as the same screen.

Two non-deltas, both explained:

1. **Sprites**: the *reference* paints six empty bordered boxes in the pet
   cast and one in the phone mock; the *implementation* paints the actual
   pets. This is a reference-side artifact — those slots are
   `<dc-import name="… Sprite">` custom elements (`:128`, `:164`, `:169`,
   `:174`, `:179`, `:184`, `:189`) that the design bundle does not hydrate
   when served standalone. The containers occupy identical space in both
   (page height is byte-for-byte equal at 2304), so layout fidelity is proven;
   sprite *content* fidelity was verified separately by P4 Gate 3/4/5 markup
   equivalence and by the six rendered pets being correct, named and ordered
   Bo/Bun/Kem/Mochi/Sua/Xoài with the right accent colour per card.
2. **Astro dev toolbar**: the implementation capture carries the four-icon
   dev overlay pinned bottom-centre. It is injected by `astro dev` only and is
   absent from `astro build` output (P6 build log: 8 static pages). Capture
   artifact of rendering the dev server, not shipped UI.

### 768 — PASS (body identical; header delta is an AC-mandated correction)

Body: identical. Feature grid 2 tracks, pet cast 3 tracks, how-it-works 2
tracks, footer 2-then-1 column reflow — same in both, same order, same copy.

Header: the reference paints the **desktop** nav wrapped onto 3 rows; the
implementation paints the collapsed `<select>` on one row. Page height 3645
(reference) vs 3569 (implementation) — the whole 76 px delta is those extra
header rows.

This is a defect in the reference, not the implementation. The design source
declares the swap itself at `Cupid Web.dc.html:26-27`:

```css
@media (max-width:1024px){[data-nav]{display:none}[data-navm]{display:flex}}
@media (min-width:1025px){[data-navm]{display:none}}
```

but `[data-nav]` carries inline `display:flex` (:52) and `[data-navm]` inline
`display:none` (:59), and an inline declaration outranks a non-`!important`
rule — so the prototype's own mobile nav is unreachable and it always renders
the desktop nav. `SiteHeader.astro:59-65` restores the swap at the identical
1024/1025 boundaries with `!important` and no new breakpoint. AC-2 requires
"mobile nav collapsing to a select control at the design breakpoint", so the
implementation is what the design intended and the AC mandates.

### 375 — PASS (same header delta, same authority)

Body: identical — single-column feature grid, single-column pet cast with all
six pets in order, stacked steps, stacked footer columns, same copy.

Header: reference 6176 px tall vs implementation 5936 px; the 240 px is again
the wrapped desktop nav (7 items over 3 rows) versus the collapsed select.
Same `:26-27` authority as the 768 row. At 375 the implementation keeps logo +
select + theme toggle + VI/EN + `Tải app` on one row without overflow.

## Summary

| Breakpoint | Verdict | Residual delta |
|---|---|---|
| 375 | PASS | header: reference shows the prototype's dead-media-query desktop nav; implementation collapses to `<select>` per AC-2 + design `:26-27` |
| 768 | PASS | same as 375 (76 px height delta, header only) |
| 1400 | PASS | none in layout (2304 px both); reference-side unhydrated sprite placeholders + dev-toolbar capture artifact only |

No implementation-caused visual deviation was found at any breakpoint.
