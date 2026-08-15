# UX Spec: STORY-033 App Shell Design System Deltas

Story: STORY-033 (REQ-002)
Design source: `cupid-app-design-system/project/Cupid Screens.dc.html`
(imported by the locked entry `Cupid App.dc.html`; canvas states = `<sc-if>`
blocks keyed by screen id, per `data/devops/system/design-fidelity-config.json`).
Scope: 4 shared `mobile/lib/design_system/` deltas only — see "Non-Goals"
below. No screen-specific content/copy in scope.

This spec transcribes exact values from the design source's CSS custom
properties and canvas markup. Where a value is theme-varied, both Dark and
Light are given (tokens are shared across all 4 platform x theme
combinations even though only Dark is in active QA scope per OQ5).

## Delta 1 — Ambient `skyGradient` Backdrop Widget (AC1)

### What it is
A **screen-level, full-bleed ambient backdrop**, not a component. In the
design source it is painted directly on the outermost per-screen container
(the same container that holds the header, content and tab bar), so it
appears behind every screen render, edge-to-edge, non-interactive, and does
not scroll with content. It has two layers, always both present together:

1. **Aurora wash** — 3 stacked soft radial-gradient blobs.
2. **Sparkle dots** — 3 small twinkling circles layered on top of the wash.

Both layers sit at the very back of the stack (painted first), with the
header, content and tab bar composited above them. The header's own
background is transparent with a blur (frosted-glass), so the aurora wash
reads *through* the header area, softened — the backdrop is not occluded by
an opaque header panel.

### Aurora wash — exact values
Three `radial-gradient` layers, painted together, stacked in this order
(first-listed paints on top):

| Layer | Shape/size | Position | Color (Dark) | Color (Light) | Fade |
|---|---|---|---|---|---|
| 1 (top-left, largest) | 120% width / 70% height ellipse | 15% from left, **-8%** from top (center sits above the viewport) | `rgba(123,47,190,.55)` — purple | `rgba(255,182,214,.72)` — pink | transparent at 62% |
| 2 (top-right) | 90% / 55% ellipse | 95% from left, 6% from top | `rgba(255,75,140,.32)` — hot pink | `rgba(206,180,255,.6)` — lilac | transparent at 60% |
| 3 (bottom-center) | 80% / 50% ellipse | 50% from left, **108%** from top (center sits below the viewport) | `rgba(0,201,167,.16)` — mint, very faint | `rgba(178,240,226,.5)` — mint | transparent at 62% |

This exact 3-layer recipe already exists as the `skyGradient` CSS-gradient
string on `CupidColorTokens` (`mobile/lib/design_system/tokens/cupid_color_tokens.dart:66-70`
for dark, `:130-134` for light) — the token's values already match the
design source verbatim; the only gap is that no widget paints them. Layer
order (compositing) must match the table above (layer 1 on top) so the
purple wash reads as the dominant tone at upper-left, not washed out by the
others.

Net visual read: dim violet-purple glow bleeding in from the top-left
corner, a softer hot-pink glow from the top-right corner, and a very faint
mint glow low and centered at the bottom — over the flat `colorBackground`
base. It must never read as a flat single-color background; if the three
blobs are not independently visible at their stated positions, the delta is
not done.

### Sparkle dots — exact values
Three small solid circles, each independently twinkling, positioned over
the aurora wash (same full-screen container, painted after the wash, before
the header):

| Dot | Size | Position | Color | Opacity (base) | Twinkle cycle | Delay |
|---|---|---|---|---|---|---|
| 1 | 6px diameter | 14% from top, 8% from left | `#FFFFFF` | 0.5 (fixed base, animates via the twinkle keyframe below) | 3.4s | 0s |
| 2 | 4px diameter | 9% from top, 16% from right | `#FFD9EA` (pale pink) | 1.0 base | 4.6s | 0.8s |
| 3 | 5px diameter | 26% from top, 7% from right | `#CEB4FF` (pale lilac) | 1.0 base | 5.2s | 1.6s |

Twinkle behavior (per dot, looping, ease-in-out): opacity cycles
0.25 → 1.0 → 0.25, and scale cycles 0.85 → 1.15 → 0.85, bottoming out at the
start/end of each cycle and peaking at the midpoint. The three dots run on
independent, staggered timers (different durations and start delays) so
they never pulse in sync — this is a deliberate ambient-sparkle effect, not
a single synchronized blink. All three dots are circular, fully opaque
color at peak, and must not intercept touch/gesture input (decorative only,
same as the aurora wash).

These dot values are not theme-varied in the design source (same 3 dots,
same colors/positions, in both Dark and Light) — unlike the aurora wash,
which does change per theme.

### Placement / integration guidance
- The backdrop (wash + dots) is the bottom-most layer of the screen, sized
  to the full screen viewport (not just visible content — it must extend
  under the status bar / header area and under the bottom tab bar / safe
  areas, matching the design source's outermost-container placement).
- It does not scroll with screen content.
- It is decorative and must not block or intercept taps.
- Because it lives at the per-screen container level in the design source
  (not per-widget), it is expected to be composed once per screen (e.g. at
  a shared screen-shell / scaffold level) rather than duplicated inside
  individual feature widgets — the exact Flutter composition point is a
  Tech Lead decision; this spec constrains only the visual output.
- Coordinate with STORY-032 per `story_master.md`'s "Relationship To
  STORY-032" section — that story also introduces this same backdrop;
  sequencing/ownership of the actual widget file is a Tech Lead call, not a
  UX call.

### Cross-screen impact
Every screen that renders through the shared per-screen container in the
design source shows this backdrop — i.e. this is a true app-shell delta.
Landing it should visibly affect every screen currently rendering a flat
`colorBackground` fill instead (that is the visual signature of the
missing-backdrop defect named in STORY-010's round-3 finding).

## Delta 2 — `CupidHeader` Back-Arrow Ink (AC2)

### Root cause located
`CupidHeader` (`mobile/lib/design_system/adaptive/cupid_header.dart`) is
already split by platform, and the two platform variants disagree:
- **iOS** (`_IosHeader`, line 111): chevron already renders in
  `colors.colorAccentPink` — **already correct**, no change needed.
- **Material** (`_MaterialHeader`, line 166-170): the `IconButton`'s `color`
  is `colors.colorText` (primary text ink) — **this is the defect**. The
  design source's back arrow is pink ink on every canvas that shows a
  header with `canBack`, regardless of platform (`Cupid Screens.dc.html`
  line 52: `<span data-icon style="...color:var(--pink)">{{backIcon}}</span>`
  — same header partial serves both platform frames).

### Fix
Material header back-arrow ink → `colors.colorAccentPink`
(`#FF7FB6` dark / `#E8558F` light — same token iOS already uses). No other
property of the Material header (background, title style, spacing) changes.
This is a single-property ink fix, not a header redesign.

### Cross-screen impact
Every screen using `CupidHeader` with `onBack` set, on Android/Material
rendering, gets the corrected pink back-arrow. iOS is unaffected (already
correct).

## Delta 3 — `caption` Text Style Declared Size (AC3)

### Root cause located
`CupidTypographyTokens.caption` (`mobile/lib/design_system/tokens/cupid_typography_tokens.dart:46-50`)
is declared at `fontSize: 13`. The design source's canvas `profile` (the
onboarding profile-setup screen, `Cupid Screens.dc.html` lines 93-119) shows
small supporting text at three distinct sizes, all smaller than 13px:

| Element (canvas `profile`) | Declared size | Role |
|---|---|---|
| Uppercase field labels ("Tên gọi" / "Ngày sinh" / "Ngôn ngữ") | 11px | field eyebrow/label |
| Zodiac auto-derived helper text ("Cung hoàng đạo tính tự động…") | **11.5px** | inline helper / metadata copy |
| Photo-crop hint under the avatar | 12.5px | supporting hint copy |

`type.caption` in the app is consumed broadly (~50 call sites across the
codebase) for exactly this kind of small supporting/metadata text,
including — confirmed directly in
`mobile/lib/features/account/presentation/screens/profile_edit_screen.dart` —
both the zodiac helper text (line 224-225) **and** the uppercase field-label
row (line 271-277), via the same base `type.caption` style with only
color/letter-spacing overrides, no fontSize override. Both currently render
at the wrong 13px.

### Fix
Set `caption`'s declared `fontSize` to **11.5px** — this is the exact
design-source value for the acceptance-critical case named in AC3 (the
zodiac helper text, whose current 13px oversizing is the confirmed cause of
its unwanted 2-line wrap; at 11.5px it must return to the design source's
intended single line).

**Known residual micro-delta (flag, not a blocker):** the uppercase
field-label role in the same canvas is drawn at 11px, 0.5px below the
corrected 11.5px caption value. Both roles route through the same
`type.caption` base today, and this story's scope is the single shared
`caption` token (per story `story_master.md` "In Scope" item 3 and AC3's
"the caption text style's declared size" — singular token, not a
role-split). 0.5px on a short, already-fitting all-caps label is not
expected to cause any wrap regression, so it does not block AC3. If Tech
Lead/dev determine the two roles must diverge into separate tokens, that is
a new token and is out of this story's declared scope (see Non-Goals) —
raise it as a follow-up rather than doing it inside this story.

### Verification requirement (part of AC3, not optional)
Re-check every layout that depended on the old 13px caption for its line
count, not just the named zodiac-helper example — the onboarding
profile-setup zodiac helper text is the one confirmed regression case, but
`caption`'s ~50 call sites should be scanned for any other place a
line-count assumption was silently keyed to the wrong 13px value.

## Delta 4 — Shared CTA Gradient Axis (AC4)

### Root cause located
`CupidColorTokens` derives `gradientHot`'s direction from a 120deg CSS
angle (`_gradient120Begin`/`_gradient120End` Alignment constants,
`cupid_color_tokens.dart` lines 3-8, applied to `gradientHot` at line 81-84
dark / equivalent light block). The design source's own base CSS variable
`--grad-hot` (`Cupid Screens.dc.html` line 23) is also still declared at
120deg — but every actual CTA usage in the canvases hardcodes the corrected
angle inline instead of referencing that stale variable:
`linear-gradient(95deg,var(--pink),var(--purple))`, verified at 4 call
sites (profile-setup "Continue" CTA line 117, contract hold-to-sign button
line 153, invite pairing-code gradient text line 172, invite "Continue"
CTA line 201). 95deg is the design source's real, current intent for this
gradient; the 120deg base variable is dead/stale.

### Fix
Change the angle backing `gradientHot` from 120deg to **95deg**
(colors unchanged: pink → purple, same stops). Do not touch `gradientDream`
(the separate 3-stop `#FF9CC4 → #C79BF0 → #8FE6D3` gradient used for large
display/hero text, e.g. the "247" days-counter treatment) — the design
source keeps that one at 120deg (`Cupid Screens.dc.html` line 248,
`--grad` variable line 23); it is a distinct token from `gradientHot` and
is explicitly out of this delta.

### Cross-screen impact
Every screen consuming `gradientHot` (17 files today, e.g. welcome/splash
screens, chat composer, dream jar hero card, hold-to-sign button, reminder
firing overlay) gets the corrected 95deg axis. `CupidPrimaryButton` does
not currently consume `gradientHot` at all (it uses a flat
`colorAccentPink` fill) — its broader gradient+glow restyle is STORY-032's
scope, not touched here; this delta only corrects the token's angle for
whichever surfaces already reference it.

## Accessibility / Contrast Notes
- The aurora wash and sparkle dots sit behind text/content, at low opacity
  (all wash layers fade to transparent; dots are small, individual points,
  not a field). No foreground text color changes as part of this story —
  existing `contrast_test.dart` coverage (`test/design_system/`) should
  continue to hold since no text-on-background color pairing changes.
- The corrected pink back-arrow ink is the same `colorAccentPink` token
  already used and already contrast-vetted for icon use (per the
  `colorAccentPink` dartdoc in `cupid_color_tokens.dart`: "icons, borders,
  focus rings, gradients and decorative accents" are an approved use of
  this token in the light theme even where it fails AA for text — an icon
  is exactly this use, consistent with iOS's existing back-arrow already
  using this same token).
- The `caption` size correction (13px → 11.5px) does not change color or
  weight, only size — re-verify (design/dev, not a new UX decision) that no
  caption-styled string becomes uncomfortably small at 11.5px on any
  extreme system font-scaling setting already covered by existing
  responsiveness expectations; no new accessibility exception is being
  introduced by this delta.

## Cross-Screen Impact Summary
All four deltas live in the shared `mobile/lib/design_system/` layer (and
the directly-adjacent shared `CupidHeader` widget), so each fix is expected
to visibly change every screen in the current design-fidelity audit wave
that consumes the affected shared piece — not just the screens explicitly
named above. This is intentional per `story_master.md`'s "Cross-Screen
Impact (expected and intended)" section: screens whose own open review
findings are exactly these four items may re-verify against this story's
landed fix rather than re-deriving the same values independently.

## Non-Goals (matches story `story_master.md` "Out of Scope")
- `CupidPrimaryButton`'s overall gradient/glow CTA restyle, and the
  STORY-008/STORY-013 re-verification against it — STORY-032's scope. This
  spec's Delta 4 is the `gradientHot` angle token only.
- Any design-system token or widget not named in Deltas 1-4 above,
  including the field-label vs. helper-text 11px/11.5px micro-delta flagged
  under Delta 3 (informational only, not a new scope item).
- Any screen-specific content, copy, or interaction logic.
- Re-running or re-authoring other stories' visual-fidelity reports.
- Light theme / `en` locale user-facing visual QA (OQ5) — this spec
  provides Light-theme values for Delta 1 for token completeness since
  `skyGradient` is a shared token with both variants, but no dedicated
  Light/`en` visual QA pass is required by this story.

## Test/Verification Pointer (AC5, informational)
This story must not silently change behavior asserted by existing
design-system contract tests referenced in `story_master.md` (no-fork
guard, adaptive-widget, contrast tests, e.g.
`mobile/test/design_system/no_fork_guard_test.dart`). If any such test
needs an intentional update to reflect a shared-treatment change from this
story, dev must call it out explicitly per AC5 rather than editing it
silently — this is a dev/review-time verification step, not a UX decision.
