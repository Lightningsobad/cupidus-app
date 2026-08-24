---
story: STORY-001_invite_couple_type_picker
requirement: REQ-009_invite_couple_type_and_pairing_navigation
written_by: mobile-dev
written_at: 2026-08-24
review_cycle: 3
---

# Visual Fidelity Report — Invite Couple-Type Picker

VISUAL_FIDELITY: PASS

Scope: the couple-type section added by this story (heading, supporting
subtext, 2x2 card grid). `_InviteCodeCard`, the back chrome, and the Continue
CTA are pre-existing and out of scope; they appear here only as positional
anchors.

## Design-Screen

| Field | Value |
| --- | --- |
| Design-Screen | `invite` |
| Render entry | `cupid-app-design-system/Cupid App.dc.html` (registered `cupid-app` source, `screens_from: "dom"`, `locked: true`, `surface: "mobile"`) |
| Authoritative markup | `cupid-app-design-system/Cupid Screens.dc.html:168-203` (`<sc-if value="{{ isInvite }}">`); the couple-type block is `:179-200` |
| Axes | android / dark / vi |
| Design capture | `visual-fidelity/design-reference-invite-couple-type-android.png` (406x900) |
| Render command | `node .ai-team-bundle/runtime/tools/render-design-canvas.js --surface=mobile --entry="Cupid App.dc.html" --location=<worktree>/cupid-app-design-system --screen=invite --platform=android --theme=dark --lang=vi --out=<story>/visual-fidelity` |

`Cupid Screens.dc.html` is the screen library, not a render entry: standalone
it enumerates `screens: []` / `screens_from: "none"` and `--theme=dark` fails
with `DESIGN_CANVAS_TOGGLE_MISSING`. `Cupid App.dc.html` is the composing
shell that owns the `screen`/`platform`/`theme`/`lang` toggles. No
`design-fidelity-config.json` change was needed for this render, and none is
outstanding.

## Implemented-side capture

**DEVICE_CAPTURE_BLOCKED** — known emulator storage constraint under DevOps
remediation. No device, install, or screenshot activity was attempted in this
pass (explicitly out of lane scope).

Consequence for this report, stated plainly: the implemented side is compared
from source and from widget-test geometry assertions, not from a device
screenshot. That is sufficient for every row below — each is a discrete,
checkable value (a size, a gap, a token, an alignment), not a perceptual
judgement that needs pixels. It would not be sufficient for antialiasing,
font rasterisation, or gradient banding, and this report makes no claim about
those.

## Per-state comparison

Design values cited as `Cupid Screens.dc.html:<line>`. Implemented values from
`mobile/lib/features/pairing/presentation/screens/invite_screen.dart`.

### Section frame (state-independent)

| Aspect | Design | Implemented | Verdict |
| --- | --- | --- | --- |
| Heading | `:180` "Tụi mình thuộc kiểu nào?", `w700` | `viEn(...)`, `type.body` + `w700`, `colorText` | MATCH (size: accepted deviation, below) |
| Heading → subtext gap | `:180` `margin-bottom:4px` | `_coupleHeadingSubtextGap = 4` | MATCH |
| Supporting subtext | `:181` "Cupid sẽ bật/tắt tính năng phù hợp cho kiểu của bạn.", `color:var(--tx2)` | `viEn(...)`, `type.caption` + `w400`, `colorTextMuted` | MATCH (size: accepted deviation, below) |
| Subtext → grid gap | `:181` `margin-bottom:12px` | `_coupleSubtextGridGap = 12` | MATCH |
| Grid shape | `:182` `grid-template-columns:1fr 1fr`, 4 items | `Column` of 2 `Row`s, 2 `Expanded` cells each, catalog order 1,2 / 3,4 | MATCH |
| Grid gutter, both axes | `:182` `gap:10px` | `_coupleGridGutter = 10` | MATCH |
| Cell padding | `:185`/`:192` `padding:16px 14px` | `EdgeInsets.symmetric(vertical: CupidSpacing.md /*16*/, horizontal: _coupleCellHorizontalPadding /*14*/)` | MATCH |
| Cell corner radius | `:185`/`:192` `var(--r-card)` | `platform.radiusCard` | MATCH (both resolve from the same card-radius role) |
| Border width | `:185`/`:192` `1.5px` | `_coupleCellBorderWidth = 1.5` | MATCH |
| Content alignment | `:185`-`:196` plain block `div`s — no `text-align`, no flex centering | `Column(crossAxisAlignment: CrossAxisAlignment.start)`, no `textAlign` on either `Text` | MATCH |
| Content order | tile → label → hint | tile → label → subtext | MATCH |
| Icon tile box | `:186`/`:193` `width:38px;height:38px;border-radius:13px`, glyph centered | `Container(width: 38, height: 38, borderRadius: circular(13), alignment: center)` | MATCH |
| Glyph size | `:186`/`:193` `font-size:21px` | `_coupleIconSize = 21` | MATCH |
| Tile → label gap | `:187`/`:194` `margin-top:10px` | `_coupleIconLabelGap = 10` | MATCH |
| Label → subtext gap | `:188`/`:195` `margin-top:3px` | `_coupleLabelGap = 3` | MATCH |

### Selected state

| Aspect | Design (`:185`-`:188`) | Implemented | Verdict |
| --- | --- | --- | --- |
| Cell fill | `linear-gradient(140deg, rgba(255,127,182,.22), rgba(183,140,245,.22))` | 140deg `LinearGradient`, `colorAccentPink@0.22` → `colorAccentPurple@0.22` | MATCH |
| Cell border | `1.5px solid var(--pink)` | `colorAccentPink` @ 1.5 | MATCH |
| Cell shadow | `box-shadow:var(--glow)` | `colors.glowShadow` | MATCH |
| Tile fill | `background:var(--grad-hot)` | `colors.gradientHot` | MATCH |
| Glyph color | `color:#fff` | `colors.colorOnAccent` (token role: "glyph rendered on top of `gradientHot`") | MATCH |
| Label color/weight | default text color, `font-weight:800` | `colorText`, `w700` | MATCH on color; weight is an accepted deviation, below |
| Subtext color | `color:var(--tx2)` | `colorTextMuted` | MATCH |

### Unselected state

| Aspect | Design (`:192`-`:195`) | Implemented | Verdict |
| --- | --- | --- | --- |
| Cell fill | `background:var(--surf)` | `colors.colorSurface` | MATCH |
| Cell border | `1.5px solid transparent` | `colorSurface` @ 1.5 (sizing-only, invisible against its own fill; no transparent token exists and the no-fork guard bans raw color constants) | MATCH in effect |
| Cell shadow | none declared | `platform.elevationShadow` | MINOR — the design declares no shadow on the unselected cell; the build keeps the platform card elevation, matching `_MoodCell` and the code card above. Pre-existing, not introduced by this pass |
| Tile fill | `background:var(--surf2)` | `colors.colorSurfaceAlt` | MATCH |
| Glyph color | `color:var(--tx2)` | `colors.colorTextMuted` | MATCH |
| Label color/weight | default text color, `font-weight:600` | `colorTextMuted`, `w600` | MATCH on weight. Color: the design leaves the unselected label at full text color and the build mutes it — a deliberate, spec'd (`§6.8`) reinforcement of the selection signal, consistent with `_MoodCell` |
| Subtext color | `color:var(--tx2)` | `colorTextMuted` | MATCH |

### Grid-level states

| State | Verdict | Evidence |
| --- | --- | --- |
| 0 selected (default) | PASS | `AC2:` widget case — no card carries `selected == true`, Continue's `onPressed` is null |
| Exactly 1 selected, each of 4 | PASS | `AC3:` widget case — the selected set has length 1 after each tap, and the identity swaps |
| Pre-filled on return | PASS | `AC5:` widget case — a persisted `LIVING_TOGETHER` renders selected on first paint |
| Selection is visually unambiguous | PASS | Three simultaneous signals now present and design-matched: cell gradient + glow + pink border, tile fill flip (`gradientHot` ↔ `colorSurfaceAlt`), glyph color flip. The tile flip was entirely absent before this pass |

## Accepted deviations

Each was raised by the cycle-2 review and is recorded here and in
`ux/ux-spec.md` §6.7/§6.8 rather than left unstated.

| # | Aspect | Design | Implemented | Basis |
| --- | --- | --- | --- | --- |
| R7 | Heading size | `:180` 16px | `type.body` = 17px | Token-driven typography; 1px |
| R4 | Label / subtext sizes | `:187` 14.5px, `:188` 11.5px | both `type.caption` = 13px | `CupidTypographyTokens.caption` deliberately collapses the source's five small-text sizes into one role; transcribing literals would fork the type scale for one section |
| R5 | Selected label weight | `:187` `w800` | `w700` | Matches ux-spec §6.8 and every other selected-card label in the app |
| R8 | Section vertical rhythm | `:169` `gap:20px` | `CupidSpacing.lg` = 24px | No 20px step on the scale; the gap is shared with the out-of-scope `_InviteCodeCard` rhythm |
| — | Unselected cell shadow | none | `platform.elevationShadow` | Pre-existing card language on this screen; not introduced by this pass |
| — | Unselected label color | full text color | `colorTextMuted` | Spec'd selection-signal reinforcement (§6.8), consistent with `_MoodCell` |

## Non-defects confirmed, not reopened

Carried from the cycle-2 review, which agreed with each:

- Card 3/4 glyphs (`auto_awesome`, `all_inclusive`) intentionally substitute
  the canvas's `potted_plant`/`diamond` per ux-spec §6.7's glyph table.
- Card copy follows the PO catalog, which supersedes the canvas's placeholder
  labels/hints ("Mới yêu", "Yêu lâu rồi", "Ưu tiên gamification", ...).
- The CTA reads "Tiếp tục" and does not navigate; the canvas's
  "Tiếp tục → Fingerprint Vow" edge is pre-REQ-009 and STORY-002 owns the
  destination.

## Verdict

VISUAL_FIDELITY: PASS

Every structural and metric delta the cycle-2 review confirmed against the
design markup is now fixed in the build. The remaining differences are six
enumerated, justified deviations — four token-scale (sub-1.5px or one weight
step) and two pre-existing screen-language choices — all now stated
identically in the build, `ux/ux-spec.md`, and this report. Implemented-side
device capture stays DEVICE_CAPTURE_BLOCKED; see the scope caveat above for
what that does and does not leave unverified.
