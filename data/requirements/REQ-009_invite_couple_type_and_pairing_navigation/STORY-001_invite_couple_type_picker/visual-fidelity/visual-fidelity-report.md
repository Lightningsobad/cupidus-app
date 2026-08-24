---
story: STORY-001_invite_couple_type_picker
requirement: REQ-009_invite_couple_type_and_pairing_navigation
written_by: mobile-dev
written_at: 2026-08-24
review_cycle: 5
---

# Visual Fidelity Report — Invite Couple-Type Picker

VISUAL_FIDELITY: PASS

No open defects. The one defect this report ever raised, **D1 — the two grid
columns are not equal width**, was fixed in `dbaaf7b` and is now re-measured as
**PASS** against a fresh device capture (left 180.9dp, right 180.6dp, against an
ideal 180.7dp equal split). Its full history and the confirming measurements are
in `## Confirmed defects` below. Every other row in this report re-verified as
matching.

Scope: the couple-type section added by this story (heading, supporting
subtext, 2x2 card grid). `_InviteCodeCard`, the back chrome, and the Continue
CTA are pre-existing and out of scope; they appear here only as positional
anchors.

## Cycle-5 correction notice

Cycle 4 (below) moved this report PASS → FAIL on D1. That defect has since been
fixed in `dbaaf7b` (the 10dp gutter moved from a per-cell `Padding` inset to a
`SizedBox` sibling between the two `Expanded` cells) and DevOps recaptured the
device screenshot in `6514b78`, overwriting
`visual-fidelity/implemented-invite-couple-type-android.png` in place. This
cycle re-measured the new capture with the same pixel-scan methodology that
produced the original D1 finding and confirms the columns are now equal. The
verdict moves FAIL → PASS. Nothing else in the report changed except the two
`x`-coordinate citations for the selected cell's border, which shifted with the
corrected column geometry.

## Cycle-4 correction notice

Cycles 1-3 of this report asserted `VISUAL_FIDELITY: PASS` with the
implemented side marked `DEVICE_CAPTURE_BLOCKED` — no implemented-side
screenshot existed, so the "comparison" was design-markup vs Dart source, not
design pixels vs rendered pixels. Cycle-3 review raised that as finding B1: the
verdict was **unverified**, not necessarily wrong.

DevOps has since captured the real device screenshot, and this cycle re-ran the
comparison against it. The cycle-3 deltas it was meant to confirm (subtext
line, 38x38 / radius-13 icon tile, left alignment, 14h/16v padding) all
**confirm as matching in pixels**. The screenshot additionally surfaced D1, a
column-width asymmetry that source inspection could not see, because the
constant it depends on (`_coupleGridGutter = 10`) is correct and only its
*placement* is wrong. That is precisely the class of defect a device capture
exists to catch, and it is why the verdict moved PASS → FAIL at that cycle.
(Superseded by the cycle-5 notice above: D1 is fixed and now measures PASS.)

## Design-Screen

| Field | Value |
| --- | --- |
| Design-Screen | `invite` |
| Render entry | `cupid-app-design-system/Cupid App.dc.html` (registered `cupid-app` source, `screens_from: "dom"`, `locked: true`, `surface: "mobile"`) |
| Authoritative markup | `cupid-app-design-system/Cupid Screens.dc.html:168-203` (`<sc-if value="{{ isInvite }}">`); the couple-type block is `:179-200` |
| Axes | android / dark / vi |
| Design capture | `visual-fidelity/design-reference-invite-couple-type-android.png` (406x900, device frame; 389px of screen content ≈ 390 CSS px, so reference px ≈ dp 1:1) |
| Render command | `node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=mobile --entry="Cupid App.dc.html" --location=<worktree>/cupid-app-design-system --screen=invite --platform=android --theme=dark --lang=vi --out=<story>/visual-fidelity` |

`Cupid Screens.dc.html` is the screen library, not a render entry: standalone
it enumerates `screens: []` / `screens_from: "none"` and `--theme=dark` fails
with `DESIGN_CANVAS_TOGGLE_MISSING`. `Cupid App.dc.html` is the composing
shell that owns the `screen`/`platform`/`theme`/`lang` toggles. No
`design-fidelity-config.json` change was needed for this render, and none is
outstanding.

## Implemented-side capture

| Field | Value |
| --- | --- |
| Capture | `visual-fidelity/implemented-invite-couple-type-android.png` (1080x2400) |
| Source | `main_preview.dart` with `PREVIEW=invite`, built/installed/launched and screencapped on `emulator-5554` by DevOps. Recaptured post-D1-fix in `6514b78`, overwriting the cycle-4 file in place |
| Raw evidence | `coding-plan/test-results.md` → `## Story Runtime Startup Smoke` and `## Post-fix device recapture (D1)` |
| State captured | card 2 (`SAME_CITY`) selected, cards 1/3/4 unselected — exercises both cell states in one frame |
| Device pixel ratio | **2.625**, so 1080x2400px = 411.4 x 914.3dp |

The dpr is derived from the capture itself, not assumed: the selected cell's
pink border measures exactly 4px (`x 553..556`, RGB `(255,127,182)`) against a
declared `1.5` logical width, and 1080 / 2.625 = 411.4dp is the standard
411dp-wide Android width class. Two independent metrics land on the same
ratio (icon tile 100px / 38 = 2.63; border 4px / 1.5 = 2.67), so every dp
figure below carries roughly ±0.4dp of measurement noise. Deltas smaller than
that are not claimed as findings.

Measurements were taken by pixel-scanning the PNG (column/row occupancy runs
over the exact token fills `colorSurface` `(36,27,66)` and `colorSurfaceAlt`
`(46,36,86)`), not by eye. Where the top row's left cell abuts the selected
cell, its glow bleeds over the boundary; the bottom row (two unselected cells,
no glow) is used for all edge measurements.

## Confirmed defects

### D1 — grid columns are unequal width (FIXED — re-measured PASS)

Status: **PASS**. Raised at cycle 4, fixed in `dbaaf7b`, re-measured at cycle 5
against the `6514b78` recapture. No longer blocking.

Re-measured on the current capture:

| | Design | Implemented (post-fix) | Delta |
| --- | --- | --- | --- |
| Left column | 169px of 389 | `x 52..526` = 475px = **180.9dp** | +0.2dp vs equal split |
| Right column | 169px of 389 | `x 553..1026` = 474px = **180.6dp** | -0.1dp vs equal split |
| Gutter | 11px | `x 527..552` = 26px = 9.9dp | MATCH (10) |
| Side margins | 20 / 20 | 52px = 19.8dp / 53px = 20.2dp | MATCH (20) |

The design declares `grid-template-columns:1fr 1fr; gap:10px`
(`Cupid Screens.dc.html:182`) and renders exactly equal tracks (169 / 169). On
a 411.4dp screen the equivalent equal split is (411.4 − 40 − 10) / 2 =
**180.7dp per column**. The build now renders 180.9 / 180.6 — a 1px difference
between the two tracks, i.e. 0.4dp, which is the quantisation floor at dpr
2.625 and inside the ±0.4dp measurement noise this report declares. The tracks
are equal to the limit of what the capture can resolve.

Three independent checks agree, which is why the 1px residual is read as
rounding and not as a surviving asymmetry:

- **Corner-arc rows.** At `y=1470` and `y=1780` — inside the cards' rounded
  corners, where both cells are inset by the identical arc geometry — the two
  fill runs measure **447px and 447px, exactly equal**. Equal widths at the
  same arc offset can only come from equal card widths.
- **Crisp selected border.** The top-right cell (`SAME_CITY`, selected) is
  bounded by 4px of exact `(255,127,182)` rather than by an anti-aliased fill
  edge, so its extent is unambiguous: `x 553..1026` at every scanned row
  (`y=1150/1200/1230/1260`), width 474px. The bottom-right unselected cell
  measures the same 553..1026, so the right column is 474px in both rows.
- **Sum closure.** 52 + 475 + 26 + 474 + 53 = 1080, the full capture width,
  with the horizontal gutter (26px) equal to the independently measured
  vertical gutter (26px).

A widget-level regression guard now holds the invariant independently of any
future capture: `test/features/pairing/presentation/invite_screen_test.dart` →
`D1: the two grid columns are equal width, split by one gutter`, which passes.

One measurement caveat, recorded so a future cycle does not re-derive it: a
strict exact-equality scan for `colorSurface` `(36,27,66)` truncates the left
cell at `x 510`, because `x 511..526` renders one unit brighter at
`(37,27,67)`. That band is inside the card — it is bounded by the gutter's
distinctly darker `(29,18,48)` at `x 527` — and taking 510 as the edge would
report a spurious 42px gutter, contradicting both the 10dp design gap and the
26px vertical gutter. All figures above use a ±2 tolerance on the fill token.

Historical root cause,
`mobile/lib/features/pairing/presentation/screens/invite_screen.dart` (cycle-4
state, lines 632-638):

```dart
Expanded(
  child: Padding(
    padding: EdgeInsets.only(
      left: index == 0 ? 0 : _coupleGridGutter,
    ),
```

Both `Expanded` slots were equal — (411.4 − 40) / 2 = 185.7dp each — but the
gutter was applied as an inset *inside* the second slot, so it was subtracted
from the right cell alone rather than taken from between the two tracks. That
predicted 185.7 / 175.7 and the capture measured 185.9 / 175.6, confirming the
mechanism. `_coupleGridGutter = 10` was always the correct value and the
vertical gutter using the same constant was always correct, which is why three
rounds of source review passed it: only the horizontal *placement* was wrong.

The fix (`dbaaf7b`) dropped the `Padding` and put the gutter between the
`Expanded`s as a `SizedBox(width: _coupleGridGutter)` sibling. The measurements
above confirm both tracks now resolve to the intended 180.7dp.

## Per-state comparison

Design values cited as `Cupid Screens.dc.html:<line>`. Implemented values are
measured from `implemented-invite-couple-type-android.png` where the metric is
observable in pixels, and read from
`mobile/lib/features/pairing/presentation/screens/invite_screen.dart` where it
is not (marked *source* in the Implemented column).

### Section frame (state-independent)

| Aspect | Design | Implemented | Verdict |
| --- | --- | --- | --- |
| Heading | `:180` "Tụi mình thuộc kiểu nào?", `w700` | rendered heavy, left-aligned at the 20dp margin | MATCH (size: accepted deviation, below) |
| Heading → subtext gap | `:180` `margin-bottom:4px` | `_coupleHeadingSubtextGap = 4` (*source*; sub-glyph-leading, not separable in pixels) | MATCH |
| Supporting subtext | `:181` "Cupid sẽ bật/tắt tính năng phù hợp cho kiểu của bạn.", `color:var(--tx2)` | rendered muted, one line, left-aligned | MATCH (size: accepted deviation, below) |
| Subtext → grid gap | `:181` `margin-bottom:12px` | `_coupleSubtextGridGap = 12` (*source*) | MATCH |
| Grid shape | `:182` `grid-template-columns:1fr 1fr`, 4 items | 2x2, catalog order 1,2 / 3,4; tracks 475px / 474px = 180.9 / 180.6dp | MATCH (pixel-confirmed post-fix — see D1) |
| Grid gutter, horizontal | `:182` `gap:10px` | `x 527..552` = 26px = 9.9dp between cells, taken from between the tracks | MATCH (pixel-confirmed) |
| Grid gutter, vertical | `:182` `gap:10px` | row 1 ends y1419, row 2 starts y1446 → 26px = 9.9dp | MATCH |
| Row heights equal | 2 equal rows | 375px / 376px = 142.9 / 143.2dp | MATCH |
| Cell padding | `:185`/`:192` `padding:16px 14px` | fill edge → tile: 41px horizontal, 46px vertical; less the 3.9px border = 37.1px / 42.1px = **14.1dp / 16.0dp** | MATCH (pixel-confirmed) |
| Cell corner radius | `:185`/`:192` `var(--r-card)` | corner inset probe → ≈63px ≈ 24dp | MATCH (both resolve from the same card-radius role) |
| Border width | `:185`/`:192` `1.5px` | selected border spans `x 553..556` = 4px = 1.5dp | MATCH (pixel-confirmed) |
| Content alignment | `:185`-`:196` plain block `div`s — no `text-align`, no flex centering | tile, label and subtext all flush to the same left inset in all 4 cells | MATCH (pixel-confirmed) |
| Content order | tile → label → hint | tile → label → subtext | MATCH |
| Icon tile box | `:186`/`:193` `width:38px;height:38px;border-radius:13px` | 100x100px = **38.1 x 38.1dp**; corner inset 26px at +1px and 7px at +13px, both consistent with r=34px = **13.0dp** | MATCH (pixel-confirmed) |
| Glyph size | `:186`/`:193` `font-size:21px` | `_coupleIconSize = 21` (*source*; glyph ink extent is font-dependent and not a reliable pixel metric) | MATCH |
| Tile → label gap | `:187`/`:194` `margin-top:10px` | tile bottom → label ink 39px = 14.9dp, i.e. 10dp box gap + ~4.9dp of caption leading | MATCH (consistent; leading is not separable in pixels) |
| Label → subtext gap | `:188`/`:195` `margin-top:3px` | label ink → subtext ink 26px = 9.9dp, i.e. 3dp box gap + two leadings | MATCH (consistent, same caveat) |

### Selected state

Read from card 2 (`SAME_CITY`) in the capture.

| Aspect | Design (`:185`-`:188`) | Implemented | Verdict |
| --- | --- | --- | --- |
| Cell fill | `linear-gradient(140deg, rgba(255,127,182,.22), rgba(183,140,245,.22))` | pink-to-purple wash, warm at the top-left corner, cool at the bottom-right | MATCH |
| Cell border | `1.5px solid var(--pink)` | 4px of exactly `(255,127,182)` = `colorAccentPink` at full opacity | MATCH (pixel-confirmed) |
| Cell shadow | `box-shadow:var(--glow)` | glow present and measurable — it tints the neighbouring cell's edge, which is why edge metrics use the bottom row | MATCH |
| Tile fill | `background:var(--grad-hot)` | tile renders as the hot gradient, not the flat `surf2` of the other three | MATCH |
| Glyph color | `color:#fff` | white glyph on the gradient tile | MATCH |
| Label color/weight | default text color, `font-weight:800` | full-brightness label, visibly heavier than the muted unselected labels | MATCH on color; weight is an accepted deviation, below |
| Subtext color | `color:var(--tx2)` | muted | MATCH |

### Unselected state

Read from cards 1, 3 and 4 in the capture.

| Aspect | Design (`:192`-`:195`) | Implemented | Verdict |
| --- | --- | --- | --- |
| Cell fill | `background:var(--surf)` | exactly `(36,27,66)` = `colorSurface`, uniform across all three | MATCH (pixel-confirmed) |
| Cell border | `1.5px solid transparent` | no border edge distinguishable from the fill | MATCH in effect (sizing-only border painted in `colorSurface`; no transparent token exists and the no-fork guard bans raw color constants) |
| Cell shadow | none declared | soft dark halo present around each unselected cell | MINOR — the design declares no shadow on the unselected cell; the build keeps the platform card elevation, matching `_MoodCell` and the code card above. Pre-existing, not introduced by this pass |
| Tile fill | `background:var(--surf2)` | exactly `(46,36,86)` = `colorSurfaceAlt` | MATCH (pixel-confirmed) |
| Glyph color | `color:var(--tx2)` | muted glyph | MATCH |
| Label color/weight | default text color, `font-weight:600` | muted label. Color: the design leaves the unselected label at full text color and the build mutes it — a deliberate, spec'd (`§6.8`) reinforcement of the selection signal, consistent with `_MoodCell` | MATCH on weight, deliberate deviation on color |
| Subtext color | `color:var(--tx2)` | muted | MATCH |

### Grid-level states

| State | Verdict | Evidence |
| --- | --- | --- |
| 0 selected (default) | PASS | `AC2:` widget case — no card carries `selected == true`, Continue's `onPressed` is null. Not in the capture, which shows the 1-selected state |
| Exactly 1 selected, each of 4 | PASS | `AC3:` widget case — the selected set has length 1 after each tap, and the identity swaps. The capture shows one such state (card 2 selected, other three plainly unselected) |
| Pre-filled on return | PASS | `AC5:` widget case — a persisted `LIVING_TOGETHER` renders selected on first paint |
| Selection is visually unambiguous | PASS (now pixel-confirmed) | In the capture, card 2 differs from its three siblings on four simultaneous channels: gradient cell fill, pink border, glow, and the tile flip from `colorSurfaceAlt` to the hot gradient with a white glyph. Unmistakable at a glance |

## Accepted deviations

Each was raised by the cycle-2 review and is recorded here and in
`ux/ux-spec.md` §6.7/§6.8 rather than left unstated. None of these is D1; D1 was
a defect, not a deviation, and it has been fixed rather than accepted.

| # | Aspect | Design | Implemented | Basis |
| --- | --- | --- | --- | --- |
| R7 | Heading size | `:180` 16px | `type.body` = 17px | Token-driven typography; 1px |
| R4 | Label / subtext sizes | `:187` 14.5px, `:188` 11.5px | both `type.caption` = 13px | `CupidTypographyTokens.caption` deliberately collapses the source's five small-text sizes into one role; transcribing literals would fork the type scale for one section |
| R5 | Selected label weight | `:187` `w800` | `w700` | Matches ux-spec §6.8 and every other selected-card label in the app |
| R8 | Section vertical rhythm | `:169` `gap:20px` | `CupidSpacing.lg` = 24px | No 20px step on the scale; the gap is shared with the out-of-scope `_InviteCodeCard` rhythm |
| — | Unselected cell shadow | none | `platform.elevationShadow` | Pre-existing card language on this screen; not introduced by this pass |
| — | Unselected label color | full text color | `colorTextMuted` | Spec'd selection-signal reinforcement (§6.8), consistent with `_MoodCell` |
| — | Cell height | 114px of 389 (1-line hints) | 143dp of 411 (2-line subtexts) | Consequence of the PO catalog copy being longer than the canvas placeholder copy — see the non-defect below. The cells are uniform and grow together; only the absolute height differs |

## Non-defects confirmed, not reopened

Carried from the cycle-2 review, which agreed with each. All three are visible
in the capture and are called out here so they are not re-raised as pixel
deltas:

- Card 3/4 glyphs render `auto_awesome` / `all_inclusive`, intentionally
  substituting the canvas's `potted_plant` / `diamond` per ux-spec §6.7's
  glyph table.
- Card copy follows the PO catalog, which supersedes the canvas's placeholder
  labels/hints — the capture reads "Mới hẹn hò" / "Gắn bó lâu dài" where the
  canvas reads "Mới yêu" / "Yêu lâu rồi", and the catalog subtexts are longer.
- The CTA reads "Tiếp tục" and does not navigate; the canvas's
  "Tiếp tục → Fingerprint Vow" edge is pre-REQ-009 and STORY-002 owns the
  destination.

## Out-of-scope observations from the capture

Recorded because the device capture is the first time they were observable,
not raised as findings against this story:

- The capture has no "Ghép đôi" app-bar title where the canvas shows one; only
  the back arrow is present. The back chrome is out of this story's scope, and
  the capture came from the `main_preview.dart` harness, which may not mount
  the app's normal navigation shell — so this is not evidence of a defect in
  the product screen. Worth a look from whoever owns the invite chrome.
- `_InviteCodeCard` shows two lines ("Mã 6 ký tự", "Hết hạn sau 23h 59p")
  where the canvas shows one ("Hết hạn sau 15 phút"). Pre-existing widget,
  data-driven expiry, out of scope.

## Verdict

VISUAL_FIDELITY: PASS

Blocking: **none**. D1, the only defect this report raised, is fixed
(`dbaaf7b`) and re-measured against the fresh device capture (`6514b78`): the
2x2 grid's columns now measure 180.9dp / 180.6dp against an ideal 180.7dp equal
split, with the 10dp gutter taken from between the two tracks. The residual is
1px — the dpr-2.625 quantisation floor — and is corroborated by exactly equal
447px/447px corner-arc runs and by the crisp 4px accent-pink border bounding
the right column at `x 553..1026` in both rows.

Everything else re-verified clean against the real device capture. Every metric
delta the cycle-2 and cycle-3 reviews confirmed against the design markup is
fixed in the build, and this cycle confirms them in rendered pixels rather than
in source: the 38.1 x 38.1dp / radius-13 icon tile, the 14.1dp / 16.0dp cell
padding, the 1.5dp border, left alignment across all four cells, the 9.9dp
gutter on both axes, the 19.8/20.2dp side margins, and the exact
`colorSurface` / `colorSurfaceAlt` / `colorAccentPink` token values. The
remaining differences are the seven enumerated, justified deviations — four
token-scale, two pre-existing screen-language choices, one copy-driven height —
all stated identically in the build, `ux/ux-spec.md`, and this report.

`DEVICE_CAPTURE_BLOCKED` no longer applies to this story.
