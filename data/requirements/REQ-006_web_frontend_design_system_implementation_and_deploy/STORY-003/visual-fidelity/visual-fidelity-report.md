# Visual Fidelity Report: STORY-003 Zodiac Compatibility Preview Page

VISUAL_FIDELITY: PASS

Design-Screen: `zodiac` (the `isZodiac` state of `cupid-app-design-system/Cupid Web.dc.html`, lines 285-384 + `zodiac` data array 763-776)
Captured by: Reviewer (non-mobile UI lane owns render+compare per reviewer rule 12e2)
Captured at: 2026-08-21
Route: `/zodiac`
Breakpoints: 375 / 768 / 1280 (full-page)

## Evidence

| File | Breakpoint | Size |
|---|---|---|
| `implemented-zodiac-375.png` | 375 | 375x5157 |
| `implemented-zodiac-768.png` | 768 | 768x2748 |
| `implemented-zodiac-1280.png` | 1280 | 1280x(full page) |

Command (sanctioned bundle renderer, no hand-rolled Playwright):

```
node .ai-team-bundle/runtime/tools/render-running-app.js \
  --project=<isolated render root> --out=<story>/visual-fidelity \
  --label=zodiac --route=/zodiac --full-page
```

Two deviations from the plain invocation, both disclosed rather than waived:

1. `--project` points at an isolated root whose `app_render.base_url` is
   `http://127.0.0.1:21311` and whose `web/` is a symlink to THIS story
   worktree's `web/`. Reason: the `app_render` block (Fix 1 of
   `design-fidelity-tooling-fix.md`) landed on `main` and is not yet on this
   story branch, so the worktree's own
   `data/devops/system/design-fidelity-config.json` still has no `app_render`
   and returns `APP_RENDER_NOT_CONFIGURED`. The isolated root carries the same
   `start_cmd` shape as the merged `main` config, only the port differs.
2. The configured port 21021 was already bound by another agent's preview
   server serving a DIFFERENT build (`<title>Cupid</title>`, not this story's
   `Hoàng đạo — Cupid`). `render-running-app.js` reuses an already-listening
   server, so rendering on 21021 would have captured someone else's tree. Port
   21311 was verified free before use. The server was started by the renderer
   itself from `start_cmd` (`npm run build && npm run preview`) against this
   worktree, so the captured pixels are this story's own build.

## Design-reference side

Per `data/requirements/REQ-006_web_frontend_design_system_implementation_and_deploy/design-fidelity-tooling-fix.md`
(user decision, 2026-08-21, second decision on that doc): `render-design-canvas.js`
can only drive this canvas to its default `startPage: "home"`, so a rendered
`design-reference-zodiac-*.png` is structurally unproducible in this repository.
For every non-`home` screen the design-reference side is satisfied by the
story's `ux/uiux-spec.md`, which carries the literal design-source values
(§6.2.1-§6.2.5 layout/spacing/type/color, §6.5 responsive, §6.7 visual
acceptance criteria) transcribed from `Cupid Web.dc.html:285-384`. Spot-checks
below were also taken against the design source directly.

## Per-breakpoint verdict

| Breakpoint | Verdict | Observed |
|---|---|---|
| 375 | PASS | All five sections render in source order. Hero eyebrow `CHIÊM TINH` / H1 / subcopy present. Daily card collapses to one column (left cell first, metric bars + nudge below) — the `minmax(min(300px,100%),1fr)` collapse uiux-spec §6.5 describes. 12 sign cards single column, 4 element cards single column, 6 leaderboard rows. Leaderboard measured at the pixel level: bar track exactly 120px, value column intact (`82%` legible), only the `flex:1` pair label wraps — exactly the §6.5 rule ("wrap the label text only, never truncate the percentage or shrink the bar"). Mobile nav `<select>` shows `Hoàng đạo` selected. One inherited clipping, see Deviations. |
| 768 | PASS | Daily card stacked, left cell fully visible and centred, three metric bars (88/94/71) with correct accent colors, nudge callout inset. 12-sign grid reflows to 4x3, element grid to 2x2, leaderboard 6 rows with 120px bars. Footer three-column. |
| 1280 | PASS | Two-column daily card (sign pair + 92% ring left, metrics + nudge right) per §6.2.2. 12-sign grid 7+5 auto-fit. 4 element cards in one row with correct label tokens (HỎA peach / THỔ butter / KHÍ lilac / THỦY mint). Leaderboard 6 rows, uniform pink→lilac gradient fill, values 96/93/90/88/85/82. Header nav shows `Hoàng đạo` as the active pill. |

## Element-level spot-checks against the spec

- Ring: butter `#FFC97E` arc to 92% with the remainder in `var(--c1)`; inner
  disc reads `92%`. Single source (`DAILY_READ.score`) drives both, per §6.2.2's
  explicit "not two independently-hardcoded numbers" rule — confirmed in
  `DailyCompatibilityCard.astro:21-22`.
- Metric bars: Giao tiếp 88% pink, Thấu hiểu 94% lilac, Năng lượng 71% mint —
  fill widths visibly proportional and matching their percentage-text colors.
- 12 signs: exactly 12 cards, correct order, VI names and ` – `-separated date
  ranges as rendered (`21.3 – 19.4` … `19.2 – 20.3`).
- 4 elements: exactly 4 cards, 3 unlabelled icons each, correct membership
  (Fire aries/leo/sagittarius, Earth taurus/virgo/capricorn, Air
  gemini/libra/aquarius, Water cancer/scorpio/pisces).
- Leaderboard: exactly 6 rows, `×` (U+00D7) separator, hairline rule above every
  row including the first.
- Typography: H1 Nunito 900 with no gradient span (§6.2.1 explicitly forbids
  adding one), H2s at the smaller 28px page-type scale, Roboto Mono
  uppercase-tracked eyebrow/caption/date/percentage.

## Deviations found

- **V-1 (design-source-inherited, 375px only)** — In the daily compatibility
  card at 375px the right-hand sign icon (`Kim Ngưu`) is clipped by the card's
  right edge and its label sits flush against that edge. Arithmetic: the left
  cell is a `display:flex` row of 86 + 104 + 86 px with two 22px gaps = 320px
  minimum against a 235px inner width (375 − 64 page padding − 76 card padding).
  This is verbatim source behaviour, not a porting error:
  `Cupid Web.dc.html:293` sets `display:flex;align-items:center;justify-content:center;gap:22px`
  with **no** `flex-wrap`, and `:294/:296/:301` fix the 86/104/86 sizes — read
  directly and confirmed. `ux/uiux-spec.md` §6.2.2/§6.5 transcribe those fixed
  sizes and instruct the implementer to reproduce them exactly, and §6.7's
  responsive checkpoints name the card's outer 2-column collapse and the
  leaderboard label wrap but not this inner row. Page-level horizontal scroll
  stays at zero at all four measured widths. Recorded as deferred finding D2 in
  the story review report and routed to UI/UX Designer at the requirement-level
  visual audit; it is a defect in the design source itself, so "fixing" it in
  the implementation would be the fidelity deviation.

## Known permanent gap

No screen-specific `design-reference-zodiac-*.png` exists, and none can be
produced in this repository. Root cause and the user-confirmed standard are
recorded in `design-fidelity-tooling-fix.md` (Fix 2 — BLOCKED, pushed back with
evidence: `render-design-canvas.js` is generated, gitignored, bundle-owned
tooling that must be fixed in the separate bundle source repo). Recorded once
here and once as deferred finding D1 in the story review report; per that
document it is not grounds for `PATCH_REQUIRED` or `BLOCKED` on its own.
