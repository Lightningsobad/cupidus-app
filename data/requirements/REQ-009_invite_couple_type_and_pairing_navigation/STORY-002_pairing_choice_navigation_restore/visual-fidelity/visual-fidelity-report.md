# STORY-002 Visual Fidelity — Pairing Choice (AC6)

Lane: mobile-dev · Screen: `pairingchoice` · Platform: android · Theme: dark · Lang: vi
Date: 2026-08-24
Scope of this pass: **both halves.** The implemented-side device capture was
supplied by DevOps on 2026-08-24, clearing the prior `DEVICE_CAPTURE_BLOCKED`
state, so this pass is a real design-vs-device comparison.

## Status

| Half | Status | Artifact |
| --- | --- | --- |
| Design reference render | PRESENT | `design-reference-pairingchoice-android.png` (406×900) |
| Implemented app capture | PRESENT | `implemented-pairingchoice-android.png` (1080×2400) |
| Side-by-side comparison | DONE | see `## Comparison — design render vs. device capture` |

`design-fidelity-config.json` has `ui_surface: true` and a locked
`design_source` (`id: cupid-app`, `surface: mobile`), so the design-side render
is mandatory. That half now exists.

## Design reference render

```
node .ai-team-bundle/runtime/tools/render-design-canvas.js \
  --location="<worktree>/cupid-app-design-system" \
  --entry="Cupid App.dc.html" \
  --screen=pairingchoice --platform=android --theme=dark --lang=vi \
  --out="<story>/visual-fidelity"
DESIGN_CANVAS: OK .../design-reference-pairingchoice-android.png 406x900
```

Two invocation details are load-bearing and differ from `ux/ux-spec.md:172`:

1. `--surface=mobile` (or `--entry=`) is required — the project declares two
   design sources (`cupid-app`, `cupid-web`), so the tool refuses to guess
   (`DESIGN_CANVAS_SURFACE_REQUIRED`).
2. `--location=<worktree>/cupid-app-design-system` is required. `--entry` is
   resolved by **basename** against the project root's design directory
   (`render-design-canvas.js:181-204`), and the project root is
   `CLAUDE_PROJECT_DIR || process.cwd()` (`:94`). Without `--location`, the tool
   renders the CONTROL checkout's design source, which does not carry this
   story's P1 restore — it enumerated 37 screens with no `pairingchoice`. With
   `--location` it enumerates 38 including `pairingchoice`, confirming the P1
   `data-screen-btn="pairingchoice"` edit makes the node reachable.

The inverse (running with cwd = worktree) fails with `VISUAL_RUNTIME_MISSING`:
Playwright is provisioned under the control checkout's `.ai-team-bundle/`, which
is gitignored and therefore absent in the worktree.

This supersedes the prior pass's `DESIGN_RENDER_TOOL_UNRESOLVED` finding — that
finding was correct about the worktree (`find` inside it returns 0 results) but
the tool does exist in the control checkout at
`.ai-team-bundle/runtime/tools/render-design-canvas.js`.

## Implemented app capture

`implemented-pairingchoice-android.png` (1080×2400), captured by DevOps on
2026-08-24: `main_preview.dart` built with `PREVIEW=pairingchoice`, installed
and launched on `emulator-5554`, screencapped. Raw evidence in
`coding-plan/test-results.md` `## Story Runtime Startup Smoke (B5, DevOps device
pass)`.

The two halves are not the same geometry: the design reference is a 406×900
device *mockup* whose content sits inside a drawn bezel (~13px sides, ~45px
top, ~32px bottom → content box ≈380×823, ratio 0.462), while the capture is a
raw full-bleed 1080×2400 framebuffer (ratio 0.450). Positions below are
therefore normalised to each side's content box, not compared in raw pixels.

## Comparison — design render vs. device capture

| Aspect | Design render (norm.) | Device capture (norm.) | Δ | Verdict |
| --- | --- | --- | --- | --- |
| Vertical order | title → primary CTA → secondary link | same | — | match |
| Title baseline (top %) | 19.8% | 20.6% | 0.8pp | match |
| Primary CTA centre (top %) | 28.4% | 28.8% | 0.4pp | match |
| Secondary link (top %) | 34.4% | 35.1% | 0.7pp | match |
| Title→CTA gap | 8.6pp | 8.2pp | 0.4pp | match |
| CTA→link gap | 6.0pp | 6.3pp | 0.3pp | match |
| CTA horizontal inset | ~6.1% / 5.8% (L/R) | ~6.9% / 7.0% (L/R) | ≤1.2pp | match |
| Title string (vi) | `Ghép đôi để mở khoá Cupid` | identical, one line, centered | — | match |
| Primary CTA label (vi) | `Ghép đôi với người ấy` | identical, centered in pill | — | match |
| Secondary label (vi) | `Tôi đã có mã` | identical | — | match |
| Title typography | bold rounded sans, white, single line | same face/weight/colour, single line | — | match |
| Secondary typography | pink text link, no border/fill | same | — | match |
| Primary CTA fill | pink→purple horizontal gradient, fully rounded pill | same gradient direction, endpoints and pill radius | — | match |
| Primary CTA glow | soft pink outer glow under the pill | present, same spread | — | match |
| Background | radial purple → near-black, warmer magenta bias upper-right | same ramp and bias | — | match |
| Decorative dots | 2 (upper-right ~82% x, left ~10% x) + 1 at CTA top-right | 3 dots in the same three positions (~83.5%, ~8.7%, CTA top-right) | ≤1.5pp | match |
| Chrome | no AppBar, no tab bar | no AppBar, no tab bar, no back affordance | — | match |
| Lower two-thirds | empty background below the link | empty background below the link | — | match |
| Screen-index FAB | suppressed by config `hide_selectors` | absent (prototype-only affordance) | — | correctly excluded |

State fidelity: the capture is the default/idle state of the screen with both
controls enabled and no error, loading, or selected state — the same state the
design canvas renders. No alternate state is specified for this screen, so
there is no unrendered state to compare.

No layout, spacing, colour, typography, or state deviation was found between
the design reference and the device capture. Every positional delta is ≤1.5
percentage points of the content box, which is inside the tolerance implied by
comparing a 380px-wide mockup against a 1080px framebuffer.

## Cross-check — render vs. Flutter source

Retained from the prior pass as a source-level cross-check of the pixel
comparison above. Implemented side read-only from
`mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
(not modified by this story).

| Aspect | Design render | Flutter screen | Verdict |
| --- | --- | --- | --- |
| Vertical order | title → primary CTA → secondary link | same three children, same order (`:86-110`) | match |
| Title (vi) | `Ghép đôi để mở khoá Cupid`, centered, wraps to one line at 406px | same string, `TextAlign.center` (`:88`) | match |
| Title position | starts ~23% down the frame | `EdgeInsets.fromLTRB(28, 150, 28, 0)`, top-aligned, no `Center` (`:82`) | match |
| Primary CTA | pink→purple gradient pill, full content width | `CupidPrimaryButton` (`:98`) | match |
| Primary CTA label (vi) | `Ghép đôi với người ấy` | same string (`:100`) | match |
| Secondary CTA | plain pink text link, not a bordered button | `TextButton` (`:105`) | match |
| Secondary label (vi) | `Tôi đã có mã` | same string (`:108`) | match |
| Chrome | no AppBar, no tab bar (`NO_CHROME` + `NO_TABS`) | bare `Scaffold`, no AppBar/CupidHeader/tabs; asserted in `pairing_choice_screen_test.dart` | match |
| Background | dark radial purple→near-black | theme token surface | match |
| Screen-index FAB | suppressed by config `hide_selectors` | n/a (prototype-only affordance) | correctly excluded |
| Title size | `24px` canvas (`Cupid Screens.dc.html:123`) | `fontSize: 24` (`:92`) — fixed 2026-08-24, B3 | match |
| Title (en) | `Pair up to unlock Cupid` (`:123`) | same string (`:89`) | match |
| Secondary CTA (en) | `I already have a code` (`:125`) | same string (`:108`) | match |
| Primary CTA (en) | `Pair up with them` (`:124`) | `Pair with your partner` (`:101`) | deviation (deferred, OQ5) |

Correction to the prior pass: `coding-plan/test-results.md` recorded the EN
deviation on the row labelled "Secondary CTA (en)". Read against the canvas, the
mismatched string `Pair up with them` is the **primary** CTA
(`Cupid Screens.dc.html:124`, `onClick="{{ goInvite }}"`). The secondary
(`:125`, `goJoinCode`) actually matches. Same one deviation, attributed to the
correct control.

## Residual deviations (updated 2026-08-24, Scrum Master disposition)

1. Title `fontSize: 27` vs canvas `24px` — **RESOLVED**. Fixed to `fontSize: 24`
   in `pairing_choice_screen.dart:92` (reviewer finding B3, mobile-dev rework
   pass, `+172` regression tests re-run green, `flutter analyze` clean on the
   touched file). See `coding-plan/test-results.md` `## B3 — Title-size
   fidelity fix`.
2. EN **primary** CTA wording (`Pair up with them` vs `Pair with your partner`)
   — deferred, not a defect. `en` is not a user-enabled locale (OQ5 fixes the
   app to dark + `vi` only).

No remaining un-dispositioned deviation in the design-render-vs-source
comparison.

The one open item, the EN primary CTA wording, is not observable in the device
capture: the capture is `vi`, and `en` is not a user-enabled locale (OQ5 fixes
the app to dark + `vi` only). It therefore has no bearing on the AC6 pixel
verdict and remains deferred at the source level.

## AC6 device capture — closed (2026-08-24)

The prior pass recorded `DEVICE_CAPTURE_BLOCKED` for the implemented half.
That gap is now **closed**, not accepted: DevOps remediated `emulator-5554`
storage (93% used / 425 MB free -> 8% used / 9.0 GB free; AVD userdata
wipe/recreate, `coding-plan/test-results.md` `## Device Environment — Emulator
Storage (B2)`) and then completed the install-and-screenshot capture in the B5
DevOps device pass. Both halves of AC6 exist, and the comparison above is a
real design-vs-device pass rather than the render-vs-source stand-in.

VISUAL_FIDELITY: PASS

— design reference and device capture compared on layout,
spacing, colour, typography, and state; all aspects match with positional
deltas ≤1.5pp of the content box, and no un-dispositioned deviation remains.
