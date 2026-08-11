# Mobile Visual Audit — REQ-001 (first pass)

Result: **FAIL** — the implementation does not match the current design.

Scope of this pass: 10 of the design's 37 screens, Android, dark theme.
Captured from `lib/main_preview.dart` on emulator-5554; references rendered
from the locked `claude-design` source with `render-design-canvas.js`.
Screenshots: `mobile-screenshots/`.

## Read this before filing anything

Two classes of difference in these images are NOT defects. Filing them would
bury the real findings:

- **No bottom tab bar in any implemented capture.** The preview harness renders
  each screen bare; the real app wraps them in `AppShell`, which does supply
  `CupidTabBar`. Harness limitation — fix the harness, do not file bugs.
- **Error banners and empty states** ("Không tải được…", "Chưa có…"). The backend
  was not running. Environment, not design.

And one class needs checking before it counts: several screens document
deliberate scope reductions in their own source (e.g. `InviteScreen`: "no
couple-type picker, no Continue → Fingerprint Vow CTA — both excluded by that
decision, not stubbed"). A screen that is smaller than the design **on purpose**
is not a mismatch. Check the widget's doc comment and the story plan before
turning a delta into a bug.

## Why this audit exists at all

Nothing in this requirement was ever visually checked. 15 of 16 stories carried
no `Implementation Lane`, and every gate keys on that field and bails when it is
absent, so the DONE gate, the story visual gate and the UX handoff gate all
returned immediately. Zero stories carry runtime-smoke evidence; zero carried a
`visual-fidelity/` artifact. The design source was also invisible to detection
(a Claude Design bundle is many `.dc.html` files and no images), so even a
working gate would have exempted itself.

Separately, the design moved after implementation: `Cupid Screens.dc.html` went
from 175 KB to 247 KB (~1141 lines changed). Part of the gap below is drift, not
regression.

## Reviewed in detail

### `alarm` — FAIL (closest match of the ten)

| Design | Implemented |
| --- | --- |
| Dark translucent card with subtle glow | **Bright pink→green gradient fill** |
| Day chips T2–CN in a horizontal row | **Vertical column** |
| Partner confirmation cards (Minh ✓ / Linh) | **Absent**, and not documented as scoped out |
| CTA "Xác nhận giờ này" | **Absent**, and not documented as scoped out |
| Title "Synced Alarm" | "Nhắc nhở đồng bộ" |
| "Luật chơi" info card | present ✓ |

The card-surface and chip-orientation deltas are structural, not cosmetic.

### `home` — FAIL (not implemented)

The screen is still the STORY-001 placeholder: it renders the literal string
"Cupid mobile scaffold is running." above a plain list of six navigation cards.
The design specifies a couple header, a "247 ngày bên nhau" hero counter, a
milestone chip, a seen-alert card, a Vibe Check card, a pet card with XP bar,
and Synced Alarm / Zodiac Red Flag tiles. This was never built to the design.

## Captured, not yet reviewed

Rendered-vs-implemented pairs exist for the eight below. PNG size is a weak
proxy, but a 5–10x gap on a like-for-like capture indicates a screen that is
close to empty against one that is dense — consistent with `home`.

| Screen | Design | Implemented | Ratio |
| --- | --- | --- | --- |
| `alarm` | 180 KB | 178 KB | 1.0x |
| `antighost` | 183 KB | 30 KB | 6.0x |
| `gallery` | 144 KB | 24 KB | 6.0x |
| `home` | 205 KB | 77 KB | 2.7x |
| `invite` | 168 KB | 29 KB | 5.7x |
| `joincode` | 154 KB | 30 KB | 5.0x |
| `paired` | 220 KB | 22 KB | 9.8x |
| `pet` | 165 KB | 24 KB | 6.9x |
| `privacy` | 184 KB | 112 KB | 1.6x |
| `vibe` | 174 KB | 113 KB | 1.5x |
## Recommended next steps

1. Fix the harness to wrap screens in `AppShell`, and re-capture. Otherwise the
   next reviewer re-discovers the false tab-bar finding.
2. Bring up the backend (or add fixtures to the preview registry) so screens
   render populated rather than empty.
3. Review the eight outstanding pairs, checking each delta against the widget's
   documented scope before recording it.
4. Extend `previewScreens` to the 18 screens that still need authored fixtures;
   27 of the design's 37 screens are currently uncapturable.
5. Triage from this table, not from the story list. Design drift after DONE is
   new work, not a story defect; only deltas against the design as it stood at
   implementation time are regressions.

