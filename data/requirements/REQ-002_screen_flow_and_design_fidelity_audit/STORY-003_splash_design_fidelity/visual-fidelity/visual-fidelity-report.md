# Visual Fidelity Report: STORY-003 Splash

Story: STORY-003 Design Fidelity — Splash
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Lane: mobile
Configuration audited: dark theme + `vi` locale (the enabled combination)

Design-Screen: splash
VISUAL_FIDELITY: PASS

Rendered evidence (all three images live beside this report):

| File | What it is |
|---|---|
| `design-reference-splash-android.png` | 406x900, rendered from the locked canvas by `.ai-team-bundle/runtime/tools/render-design-canvas.js --screen=splash --platform=android` (frame `[data-plat="md"]`, 412x915 logical, animations frozen) |
| `implemented-splash-emulator-5554.png` | 405x900, live `adb exec-out screencap` of the built app, settled state (~1.75 s after mount) |
| `implemented-splash-popin-emulator-5554.png` | 405x900, live `adb exec-out screencap` of the built app, first painted state (mid `popIn`) |

## Design Source Of Record

`cupid-app-design-system/project/Cupid Screens.dc.html`, the
`<sc-if value="{{ isSplash }}">` block at lines 1409-1423, plus the shared
keyframes it references at lines 31 (`bob`), 40 (`popIn`), 41 (`breathe`) and
the `--safe-bot` platform tokens at lines 24-25.

Verbatim design declarations used as the comparison baseline:

- Container — `min-height:100%; display:flex; flex-direction:column;
  align-items:center; justify-content:center; gap:26px;
  background:linear-gradient(168deg,#7B4FBE,#C2508F 55%,#4E8A87);
  position:relative; overflow:hidden`
- Glow orb — `position:absolute; top:22%; left:14%; width:150px; height:150px;
  border-radius:50%; background:radial-gradient(circle,rgba(255,255,255,.28),
  transparent 70%); animation:breathe 6s ease-in-out infinite`
- Wordmark — `font-family:Nunito; font-weight:900; font-size:58px;
  letter-spacing:-.03em; color:#fff; animation:popIn .7s ease-out`
- Dots — row, `gap:8px`; each `width:9px; height:9px; border-radius:50%;
  background:rgba(255,255,255,.9); animation:bob 1.1s ease-in-out infinite`
  with per-dot delays `0s / .18s / .36s`
- Bottom block — `position:absolute; bottom:calc(var(--safe-bot) + 26px);
  flex-direction:column; align-items:center; gap:12px`, always rendered
  - status line `font-size:11.5px; color:rgba(255,255,255,.6)`
  - pill `padding:8px 16px; border-radius:999px;
    background:rgba(255,255,255,.16); border:1px solid rgba(255,255,255,.24);
    font-size:12px; font-weight:700; color:#fff`

Note on story wording: the story's In Scope line calls the background a
"nebula background (twinkling stars)". The locked design source declares no
star field — it declares the 168deg gradient plus one breathing radial glow
orb. The design source was treated as authoritative and no invented star
layer was added (adding one would also violate the story's Out of Scope rule
against elements "not already present in the locked design source").

## Rendered Comparison (12e2/12e3)

### How the two renders were produced

Design reference — `render-design-canvas.js --screen=splash --platform=android`
against the locked bundle declared in `data/devops/system/design-fidelity-config.json`
(`claude-design`, `cupid-app-design-system/project`, entry `Cupid App.dc.html`,
`locked: true`). Canvas id resolved from `--list-screens`: **`splash`**. Frame
`[data-plat="md"]` is 412x915 logical, downscaled to 406x900.

Implemented — Android emulator `emulator-5554`, display forced to
`540x1200 @ 210 dpi` so the logical viewport is **411.4x914.3**, within 1 px of
the design frame's 412x915. Capture is a live `adb exec-out screencap` (PNG,
never a video frame), downscaled to 405x900. Both renders therefore sit at the
same scale and are directly comparable pixel-for-pixel.

The APK under capture was built and installed inside the same device lease:

```
flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=splash
sha256 f380b1660cff5fece713e4daa76d4cca99478b1ad8f908281427cded1f9ec0a2
```

`lib/main_preview.dart` pins `Locale('vi')`, `brightness: dark`,
`MediaQuery.withNoTextScaling` and hides the debug banner, so the capture is the
audited configuration and nothing else.

### Two captured states

`SplashScreen` holds a 2 s `_minDwell`, then `_tryNavigate` runs. In the
unauthenticated preview session `SessionGateCubit` emits
`SessionGateUnauthenticated` immediately, so the dwell expiring **is** the
navigation — no splash frame exists strictly after the dwell. The two states
captured are therefore the entry state and the settled state at the dwell
boundary:

| State | File | Capture time after mount |
|---|---|---|
| First painted (entry animations in flight) | `implemented-splash-popin-emulator-5554.png` | ~0.3 s |
| Settled (all entry animations complete, dwell about to fire) | `implemented-splash-emulator-5554.png` | ~1.75 s |
| Post-dwell | not capturable | navigation replaces the route at 2.0 s |

The next screencap after the settled frame (1.2 s later) is already the Welcome
screen, which confirms the dwell boundary directly.

### Element geometry, design vs implemented

Measured by per-row brightness banding on both PNGs, expressed as a fraction of
the shared 900 px height / image width. Positive Δ = lower or wider than design.

| Element | Design | Implemented (settled) | Δ |
|---|---|---|---|
| Wordmark band (y) | 0.4633–0.5222 | 0.4556–0.5133 | −8 px |
| Wordmark width | 148 px | 147 px | −1 px |
| Wordmark centre x | 0.5012 | 0.4988 | −1 px |
| Dots row (y) | 0.5611–0.5700 | 0.5478–0.5589 | −11 px |
| Dots row width | 42 px | 43 px | +1 px |
| Status line (y) | 0.8689–0.8778 | 0.8822–0.8933 | +12 px |
| Status line width | 182 px | 190 px | +8 px |
| Pill outer box (y) | 0.8956–0.9289 | 0.9089–0.9433 | +13 px |
| Pill width x height | 122 x 31 px | 125 x 32 px | +3 / +1 px |
| Pill label width | 114.4 logical | 114.8 logical | +0.4 px |

Glow orb centroid, normalised to each render's own gradient area: design
`(0.3277 W, 0.3081 H)`, implemented `(0.3218 W, 0.3019 H)` — 2.4 px and 5.6 px
apart. The implemented centroid matches the code exactly: `left: 0.14 * W` and
`top: 0.22 * H` on a 150x150 box gives `(0.3218, 0.3019)` for this viewport.

Two residuals are explained rather than corrected:

- **Centre block sits 8 px higher.** The design canvas draws an opaque 48 px
  status bar and a 31 px home-indicator bar as part of its frame, so its
  centred block is pushed down by `(48 − 31) / 2 = 8.5 px`. The implementation
  centres over the full screen because `SafeArea` was deliberately removed from
  the centring frame (deviation 18 below). Measured Δ is 8 px — the chrome
  model, not a layout error.
- **Bottom block sits 13 px lower.** The design mock's fixed 31 px
  home-indicator bar is taller than the emulator's real ~26 dp gesture inset.
  The pill's bottom edge measures 25.8 logical px above the device inset, which
  is the `safeBottom + 26` the design's `bottom: calc(var(--safe-bot) + 26px)`
  asks for (deviation 8 below).

### Gradient ramp

Sampled down the right edge, which is free of both chrome mocks:

| Height | Design | Implemented | Max channel Δ |
|---|---|---|---|
| 6% | (135, 79, 181) | (133, 79, 184) | 3 |
| 15% | (147, 79, 174) | (145, 79, 176) | 2 |
| 30% | (166, 79, 161) | (164, 80, 163) | 2 |
| 45% | (185, 79, 148) | (184, 80, 150) | 2 |
| 60% | (171, 91, 141) | (175, 89, 142) | 4 |
| 75% | (133, 110, 138) | (136, 109, 139) | 3 |
| 90% | (94, 129, 136) | (97, 129, 136) | 3 |

The `168deg #7B4FBE → #C2508F 55% → #4E8A87` ramp reproduces within 4/255 across
the full run. At 98.5% the design shows its opaque home-indicator bar while the
device shows gradient under a transparent gesture bar; that row is chrome, not a
colour deviation.

### Copy, and what the two states prove

Both renders carry the same Vietnamese strings — wordmark `Cupid`, status line
`Đang mở khoá kỷ niệm của hai bạn…`, pill `Chạm để tiếp tục` — at matching
widths, and no `CircularProgressIndicator` appears in either.

Between the pop-in and settled captures only the wordmark changes (band
`421.6..472.4` logical, width 144.2 → `416.5..469.3`, width 149.3, i.e. smaller
and lower mid-`popIn`, then settled). The status line and pill bands are
byte-identical across both states, which is the direct evidence for deviation 13
— the bottom treatment is always rendered and does not appear only after the
dwell.

### Verdict

`VISUAL_FIDELITY: PASS`. Every declared element is present, correctly
positioned within ≤1.5% of screen height, correctly sized within ≤3 px, and the
gradient reproduces within 4/255. The only differences are the two chrome-model
residuals explained above and animation phase, which the design render freezes
and the device render cannot.

## Deviations Found And Fixed

All fixes are in
`mobile/lib/features/auth/presentation/screens/splash_screen.dart` unless
noted otherwise.

| # | Element | Was (before this story) | Design source | Fix |
|---|---------|-------------------------|---------------|-----|
| 1 | Background gradient | `CupidColorTokens.gradientDream` — `linear-gradient(120deg, #FF9CC4, #C79BF0 52%, #8FE6D3)`, a pastel pink/lilac/mint ramp | `linear-gradient(168deg, #7B4FBE, #C2508F 55%, #4E8A87)` | New `SplashPalette.background` token with the exact stops, stop positions and 168deg axis |
| 2 | Breathing glow orb | Absent entirely | 150px white radial fade at top 22% / left 14%, `breathe 6s ease-in-out infinite` (scale 1→1.09, opacity .5→.85) | Added `_BreathingGlow`, positioned via `LayoutBuilder` percentages inside the `Stack` |
| 3 | Container clipping | No clip; a scaled absolute child would overflow the screen | `overflow:hidden` | Wrapped the content in `ClipRect` |
| 4 | Wordmark color | `colorText` (`#F7EEFB` dark / `#3E2645` light) — theme-varying, so the light theme would render near-black text on the fixed dark gradient | `#fff`, fixed | `SplashPalette.foreground` |
| 5 | Wordmark letter-spacing | Unset | `-.03em` | `letterSpacing: -1.74` (`-.03em` at 58px) |
| 6 | Wordmark entrance | No animation | `popIn .7s ease-out` (scale .94→1, translateY 8→0, opacity 0→1) | `_Wordmark` drives all three via a 700ms `Curves.easeOut` controller |
| 7 | Wordmark→dots gap | `CupidSpacing.lg` = 24 | 26 | `SizedBox(height: 26)` |
| 8 | Status line + tap affordance placement | In the centered column, `CupidSpacing.xl` (32) and `CupidSpacing.xxl` (48) below the dots | Absolutely bottom-anchored at `calc(--safe-bot + 26px)`, `gap:12px` | `Positioned(bottom: MediaQuery.paddingOf(context).bottom + 26)` with a 12px internal gap |
| 9 | Status line color | `colorTextMuted` (`#B4A6CE`) | `rgba(255,255,255,.6)` | `SplashPalette.caption` |
| 10 | Status line size | `cupidType.body` = 17 | 11.5 | `caption.copyWith(fontSize: 11.5)` |
| 11 | Tap affordance shape | Bare `Text` with no container | Translucent pill: `padding 8/16`, `radius 999`, fill `rgba(255,255,255,.16)`, `1px` border `rgba(255,255,255,.24)` | `DecoratedBox` + `Padding` using `SplashPalette.pillFill` / `pillBorder` |
| 12 | Tap affordance typography | `cupidType.caption` (13, w400) in `colorTextMuted` | 12px, weight 700, `#fff` | `caption.copyWith(fontSize: 12, fontWeight: w700, color: foreground)` |
| 13 | Tap affordance visibility | Hidden until the 2s minimum dwell elapsed | Always rendered | Bottom block now renders from the first frame |
| 14 | Dot diameter | 8 | 9 | `SizedBox(width: 9, height: 9)` |
| 15 | Dot color | `colorText` (opaque, theme-varying) | `rgba(255,255,255,.9)` | `SplashPalette.dot` |
| 16 | Dot spacing | `EdgeInsets.symmetric(horizontal: CupidSpacing.xs)` — 8 between dots but also 4 of dead padding on each outer edge | `gap:8px`, no outer padding | Explicit `SizedBox(width: 8)` separators only |
| 17 | Dot animation | 900ms cycle, `index * 0.2` stagger, -6px amplitude, linear triangle wave | 1100ms, `.18s`/`.36s` stagger, -7px, `ease-in-out` per keyframe segment | 1100ms controller; phase offsets `.18/1.1` and `.36/1.1`; `-7 * Curves.easeInOut` applied per half-segment |
| 18 | Vertical centering frame | `SafeArea` wrapped the whole column, so the centered group was centered inside the safe area | Container is `min-height:100%` with no safe-area padding; only the bottom block uses `--safe-bot` | `SafeArea` removed; group centered on the full screen, safe inset applied only to the bottom block |

### Animation curve mapping

CSS `ease-in-out` is `cubic-bezier(.42,0,.58,1)`, which is exactly Flutter's
`Curves.easeInOut`, and CSS applies the timing function independently between
each keyframe pair. `breathe` is therefore driven by a 3000ms controller with
`repeat(reverse: true)` plus `curve`/`reverseCurve` of `Curves.easeInOut`
(half of the 6s cycle, mirrored), and `bob` maps its phase through
`Curves.easeInOut` on each half of the cycle rather than as a linear triangle.

## Explicitly Not Changed (out of scope)

- Session-resolution routing, the 2s minimum dwell timer, the
  `SessionGateCubit` wiring and every navigation destination — STORY-001
  scope. `_tryNavigate`, `_onTapToContinue` and the dwell timer are byte-for-byte
  unchanged, and the tap handler remains gated on `_minDwellElapsed` exactly as
  before. Only the *rendering* of the affordance changed (item 13).
- The screen-wide `GestureDetector` hit area. The design source scopes its
  `onClick` to the bottom block; narrowing the Flutter hit area is an
  interaction change, not a visual one, so it was left alone.
- Light theme / `en` locale user-facing QA (OQ5, out of scope per
  story_master.md). The new values are theme-invariant by design, which
  incidentally *fixes* a latent light-theme bug (item 4) rather than
  introducing one.

## Write-Scope Deviation (requires Scrum Master acknowledgement)

Two files outside the declared `WriteScope` were touched, both mandatory to
land deviations 1, 4, 9, 11, 12 and 15:

- **Added** `mobile/lib/design_system/tokens/splash_palette.dart`
- **Edited** `mobile/lib/design_system/design_system.dart` (one added
  `export` line for the barrel)

Reason: `test/design_system/no_fork_guard_test.dart` fails the build if
`lib/features/**` contains a `Color(0x` or `Colors.` literal (D3/ADR-004), and
none of the splash design-source colors — the 168deg gradient, `#fff`, or the
four white alpha values — exist in `CupidColorTokens`. The splash gradient is
not `gradientDream` or `gradientHot`. The only compliant place for these
values is the design system.

This follows the established repo precedent for exactly this situation:
`tokens/pet_hero_gradient.dart` and `tokens/bun_sprite_palette.dart` are both
additive, non-shared, single-consumer token files created for the same reason,
and `pet_hero_gradient.dart` documents that rationale in its own dartdoc.
`SplashPalette` is consumed only by `splash_screen.dart` and changes no
existing token, so no other screen's rendering is affected.

## Verification

Run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-003/mobile`.

| Command | Result |
|---------|--------|
| `flutter gen-l10n` | required first — `lib/l10n/generated/` is not committed |
| `flutter analyze` | 0 errors. 94 pre-existing `info`/`warning` issues remain (`prefer_initializing_formals`, generated-openapi `unused_import`, one `deprecated_member_use`); none are on a line added or changed by this story. `flutter analyze` exits 1 whenever any issue of any severity exists, so the exit code is not a regression signal here. |
| `flutter test` (full suite) | **927/927 passed**, exit 0 |
| `flutter test test/features/auth/presentation/screens/splash_design_fidelity_test.dart` | 7/7 passed |
| `flutter test test/features/auth/presentation/splash_screen_test.dart` | 4/4 passed — the pre-existing routing suite is untouched and still green, confirming no STORY-001 behavior drift |
| `flutter test test/design_system/no_fork_guard_test.dart` | passed — no color literal leaked into `lib/features` |

### New test

`mobile/test/features/auth/presentation/screens/splash_design_fidelity_test.dart`
pins the design source values in dark theme + `Locale('vi')`:

1. background gradient is `SplashPalette.background`, not `gradientDream`
2. glow orb exists, is 150x150, and sits at top 22% / left 14%
3. wordmark is Nunito 900 / 58px / `-1.74` letter-spacing in design white
4. exactly three 9px dots, 8px apart, and no `CircularProgressIndicator`
   (AC 3: no ad hoc spinner)
5. status line (11.5px) and pill label (12px, w700) render on the first
   frame, before the dwell elapses
6. pill fill, 1px border, 999 radius and 8/16 padding
7. bottom block bottom edge sits exactly 26px above the safe-area inset

### Re-verification for the rendered-evidence patch

The patch that closed F-1 added images and report text only; no Dart file
changed. Re-run in the story worktree to confirm no regression:

| Command | Result |
|---------|--------|
| `flutter gen-l10n` | ok |
| `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=splash` | ✓ Built `build/app/outputs/flutter-apk/app-debug.apk` |
| `flutter test test/features/auth/presentation/screens/splash_design_fidelity_test.dart test/features/auth/presentation/splash_screen_test.dart test/design_system/no_fork_guard_test.dart` | **12/12 passed**, exit 0 |

### Device capture provenance

Emulator `emulator-5554`, acquired through
`.ai-team-bundle/runtime/tools/capture-mobile-screen.sh --lease-exec` so the
install and the screencaps ran inside one exclusive device lease. This matters:
the emulator is shared across the parallel wave and the `com.snapsofts.cupid`
package is replaced by whichever story installed last, so install and capture
cannot be split across leases. The display override
(`wm size 540x1200` / `wm density 210`) is reset by the script's `EXIT` trap.

No toolchain, signing, store or release configuration work was performed — out
of scope per the handoff.

## Acceptance Criteria Status

- **AC 1** (layout/spacing/color/typography match in dark + `vi`) — MET.
  18 deviations corrected; each design value is pinned by an assertion.
- **AC 2** (deviations corrected in the app, not merely documented) — MET.
  Every row in the table is a code change, verified by a passing test.
- **AC 3** (loading hold uses the design source's own treatment, no ad hoc
  spinner) — MET. The bobbing dots and the status line/pill are the design
  source's own treatment; the test asserts no `CircularProgressIndicator`.
- **AC 4** (no new entry point) — MET. Splash is still reached through the
  unchanged launch sequence; routing code was not touched.
