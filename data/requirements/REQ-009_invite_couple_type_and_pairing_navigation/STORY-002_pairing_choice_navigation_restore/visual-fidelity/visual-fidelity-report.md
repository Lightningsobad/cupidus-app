# STORY-002 Visual Fidelity — Pairing Choice (AC6)

Lane: mobile-dev · Screen: `pairingchoice` · Platform: android · Theme: dark · Lang: vi
Date: 2026-08-24
Scope of this pass: **design-reference half only.** The implemented-side capture
stays `DEVICE_CAPTURE_BLOCKED` from the prior pass and was not retried.

## Status

| Half | Status | Artifact |
| --- | --- | --- |
| Design reference render | PRESENT | `design-reference-pairingchoice-android.png` (406×900) |
| Implemented app capture | `DEVICE_CAPTURE_BLOCKED` | none |
| Pixel/side-by-side diff | NOT POSSIBLE | requires both halves |

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

## Comparison — render vs. Flutter source

Implemented side read-only from
`mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`
(not modified by this story). This is a render-vs-source comparison, not a
pixel diff, because the implemented capture is still blocked.

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
| Title size | `24px` canvas (`Cupid Screens.dc.html:123`) | `fontSize: 27` (`:92`) | deviation |
| Title (en) | `Pair up to unlock Cupid` (`:123`) | same string (`:89`) | match |
| Secondary CTA (en) | `I already have a code` (`:125`) | same string (`:108`) | match |
| Primary CTA (en) | `Pair up with them` (`:124`) | `Pair with your partner` (`:101`) | deviation |

Correction to the prior pass: `coding-plan/test-results.md` recorded the EN
deviation on the row labelled "Secondary CTA (en)". Read against the canvas, the
mismatched string `Pair up with them` is the **primary** CTA
(`Cupid Screens.dc.html:124`, `onClick="{{ goInvite }}"`). The secondary
(`:125`, `goJoinCode`) actually matches. Same one deviation, attributed to the
correct control.

## Residual deviations

Both live in `mobile/lib/`, which this story is forbidden to touch, and neither
affects the only user-enabled configuration (dark + `vi`, per OQ5):

1. Title `fontSize: 27` vs canvas `24px`. Pre-existing.
2. EN **primary** CTA wording (`Pair up with them` vs `Pair with your partner`).
   `en` is not user-enabled.

Carried to the review gate as findings, not fixed here.

## Remaining gap

AC6 still has no implemented-side capture. `DEVICE_CAPTURE_BLOCKED` reason from
the prior pass is unchanged: `adb install` failed with
`java.io.IOException: Requested internal only, but not enough space`
(`emulator-5554`, `adb shell df /data` → 429848 KB free, 93% used). Freeing that
space means uninstalling apps or wiping a shared emulator, which is outside the
mobile-dev lane (no emulator provisioning or repair). A reviewer needing a pixel
diff must free emulator storage first.
