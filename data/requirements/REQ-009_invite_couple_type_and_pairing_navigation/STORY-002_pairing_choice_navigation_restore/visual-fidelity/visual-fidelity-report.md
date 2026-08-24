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

## Remaining gap — AC6 implemented-side pixel capture (Scrum Master disposition, 2026-08-24)

`emulator-5554` storage was remediated by DevOps 2026-08-24 (93% used / 425 MB
free -> 8% used / 9.0 GB free; AVD userdata wipe/recreate; see
`coding-plan/test-results.md` `## Device Environment — Emulator Storage (B2)`).
The storage blocker itself is resolved and re-verified via a simulated 300 MB
`pm install-create` session.

The actual on-device install-and-screenshot capture was **not** retried after
that fix. `guard-broad-handoff.sh` rejects mobile-dev handoffs in ordinary
`continue`/`continue parallel` flow that route emulator/device provisioning,
install, or screenshot-capture work (confirmed blocking twice this session on
reworded STORY-002 dispatch attempts, and documented as GENERIC/undocumented in
`.claude/hooks/guard-codes.md`'s `## BROAD HANDOFF GUARD` section — no
matching code exists there to appeal). This is a structural runtime-boundary
limitation, not a story defect: there is no currently sanctioned specialist
lane for on-device capture inside ordinary continue.

**Disposition:** AC6's pixel-diff half stays `DEVICE_CAPTURE_BLOCKED` as an
accepted, structural, non-remediable-in-this-flow gap. Per the Reviewer's own
stated fallback ("the design-reference render, F2, F4, and F5 remain
supplyable regardless"), this does not block the story: the design-reference
render plus the render-vs-source comparison above (all rows now `match` or
explicitly deferred) stand in for the missing pixel diff.

VISUAL_FIDELITY: PARTIAL — design-reference render present and fully compared
against Flutter source (all deviations resolved or deferred); implemented-side
device pixel capture structurally blocked, accepted per Reviewer fallback.
