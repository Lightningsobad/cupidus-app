# Visual Fidelity — REQ-006 / STORY-006 About & Press Kit Page

VISUAL_FIDELITY: PASS

Captured by: Reviewer (Iris-QC-9), 2026-08-21
Lane: `frontend` (non-mobile → reviewer owns render + compare, rule 12e2)
Design-Screen: `about` (the `isAbout` page-state block of `Cupid Web.dc.html:511-611`)

## Standard applied

Per `../../design-fidelity-tooling-fix.md` (Scrum-Master/user decision,
2026-08-21, second decision on that doc):

- Implementation side — REQUIRED real `render-running-app.js` capture at
  375/768/1280 against the built app. Done, below.
- Design-reference side — `render-design-canvas.js` can render only the
  canvas's default `home` state; for every other screen the reference is the
  story's `uiux-spec.md`. No `design-reference-about-*.png` exists and none is
  producible in this repository. Recorded once as DEF-3 in `review-report.md`.

## Implementation capture

Command (bundle renderer only; no hand-rolled Playwright, no live-runtime
driving):

```
node .ai-team-bundle/runtime/tools/render-running-app.js \
  --project=<control-checkout> \
  --out=<story>/visual-fidelity --label=about --route=/about \
  --breakpoints=375,768,1280 --full-page
```

Server: `astro preview` on the reserved `DEVSTACK_PORT_WEB` port 21021, serving
`web/dist` built from THIS worktree (`npm run build`, 8 pages, exit 0). The
served `/about/` payload was verified to be this story's build before capture
(31368 bytes; contains `Về Cupid`, `Chặng đường`, `Minh Khôi`, `48.000+`,
`press-kit`, and `<title>Giới thiệu & Bộ nhận diện thương hiệu — Cupid`).

| File | Viewport |
|---|---|
| `implemented-about-375.png` | 375 × 5215 |
| `implemented-about-768.png` | 768 × 2909 |
| `implemented-about-1280.png` | 1280 × 2627 |

## Per-breakpoint verdict against `ux/uiux-spec.md` §6.2 / §6.6 / §6.8

| Breakpoint | Verdict | What was checked in the image |
|---|---|---|
| 375 | PASS | Every grid collapses to one column (principles, stats, team, press-kit swatches); press-kit header wraps with "Tải bộ kit" below the headline and not orphaned (§6.6); palette stays a 4×2 grid; all 7 sections present in source order |
| 768 | PASS | Principles 2-up (240px `minmax` floor respected), stats 3-up, team 3-up, press-kit swatches 3-up, callout still two-column; mobile `<select>` nav; no column below its floor (§6.8) |
| 1280 | PASS | Container centred at `max-width:1200px` with `70px 32px 90px` padding; mission column visibly constrained to `max-width:660px`; principles 4-up; header nav pill "Về chúng mình" rendered active |

Section-level check (identical at all three): eyebrow `VỀ CUPID` Roboto Mono
uppercase tracked in `--acc-pink`; H1 Nunito 900 tight-tracked; 4 principle
cards on `--surf` with thin border and no hover-lift; 3 stat cards with the
literal `48.000+` / `31.500` / `2,1 triệu` at Nunito 900 40px; mint eyebrow on
the "Tại sao là pet?" callout; timeline as 5 year-prefixed rows with top
borders, years in `--acc-pink` mono; 3 team cards with the three source
gradients (pink→lilac, lilac→mint, butter→pink) as circular decorative avatars;
press-kit panel with lilac `PRESS KIT` eyebrow, literal `#171129` dark lockup
(with brand-glow tile) and literal `#FFF6FB` light lockup rendered
side-by-side under the site's dark theme as §6.5/§6.7 require, and the 8-swatch
palette in source order Pink / Lilac / Mint / Butter / Peach / Nebula /
Surface / Cotton.

No visible deviation from the spec's documented layout, spacing, typography, or
colour-token intent was found at any breakpoint.

## Not captured

- `design-reference-about-*.png` — structurally impossible in this repository;
  see `../../design-fidelity-tooling-fix.md` "Fix 2 — BLOCKED". Permanent
  DEFERRED finding (DEF-3), not a defect of this story.
- 1024 / 1440 from `uiux-spec.md` §6.8 — the configured breakpoint set is
  375/768/1280. 1280 exercises the same desktop grid state as 1024/1440 (all
  grids are fluid `auto-fit`/`minmax`, no fixed breakpoint overrides exist).
