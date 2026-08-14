# Visual Fidelity Report: STORY-003 Splash

Story: STORY-003 Design Fidelity — Splash
Requirement: REQ-002 (Scope B, Full Design Fidelity Audit)
Lane: mobile
Configuration audited: dark theme + `vi` locale (the enabled combination)

Design-Screen: splash
VISUAL_FIDELITY: PASS

Rendered evidence (both images live beside this report):

| File | What it is |
|---|---|
| `design-reference-splash-android.png` | 406x900, rendered from the locked canvas by `.ai-team-bundle/runtime/tools/render-design-canvas.js --screen=splash --platform=android` (frame `[data-plat="md"]`, 412x915 logical, animations frozen) |
| `implemented-splash-emulator-5554.png` | 405x900, live `adb exec-out screencap` of the built preview app, settled state |

## What This Round Changed

Round 1 of this story was discarded. It reproduced the design source's
tap-to-continue pill, which ADR-6 had already removed from this screen, and it
left a `_TapToContinue` widget in the file that `build()` no longer referenced.
This round re-derives the screen from the design source with the ADR-6
exclusion applied deliberately, and leaves no unreferenced code behind: every
widget declared in `splash_screen.dart` is reachable from `build()`.

Round 1's rendered evidence was also stale — it photographed the discarded
design. It has been replaced: `implemented-splash-emulator-5554.png` is a new
capture of the current code, and `implemented-splash-popin-emulator-5554.png`
was deleted rather than left contradicting the shipped screen (see "Evidence
Notes" below).

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
  flex-direction:column; align-items:center; gap:12px`
  - status line `font-size:11.5px; color:rgba(255,255,255,.6)`
  - pill `padding:8px 16px; border-radius:999px;
    background:rgba(255,255,255,.16); border:1px solid rgba(255,255,255,.24);
    font-size:12px; font-weight:700; color:#fff`, with a `goWelcome` handler

Note on story wording: the story's In Scope line calls the background a
"nebula background (twinkling stars)". The locked design source declares no
star field on this screen — it declares the 168deg gradient plus one breathing
radial glow orb, and the splash's opaque gradient covers the frame root's own
twinkle layer. The design source was treated as authoritative and no invented
star layer was added; adding one would also violate the story's Out of Scope
rule against elements "not already present in the locked design source".

## The One Deliberate Deviation: The Tap Pill (ADR-6)

The design source's bottom block has two children — the status line and a
`Chạm để tiếp tục` pill whose `onClick` runs `goWelcome`. ADR-6 removed the
tap-to-continue affordance from splash: the screen advances only when the
session resolves and the 2 s minimum dwell has elapsed (AC4), and STORY-001's
own regression test asserts that tapping splash routes nowhere.

The pill is therefore **not reproduced**. Rendering it as a static, dead
control would advertise an interaction the screen no longer offers, which is a
worse fidelity outcome than omitting it: the user would tap a button that does
nothing. The status line it accompanied **is** reproduced, at the design
source's own typography and at the design source's own bottom anchor.

Consequence, called out so it is not read as a layout error: with the pill
gone, the status line becomes the last child of a bottom-anchored column, so it
occupies the position the pill used to. It sits lower than the design render's
status line by design, not by drift. See the geometry table.

## Rendered Comparison

### How the two renders were produced

Design reference — `render-design-canvas.js --screen=splash --platform=android`
against the locked bundle declared in
`data/devops/system/design-fidelity-config.json` (`claude-design`,
`cupid-app-design-system/project`, entry `Cupid App.dc.html`, `locked: true`).
Frame `[data-plat="md"]` is 412x915 logical, downscaled to 406x900.

Implemented — Android emulator `emulator-5554`, display temporarily forced to
`540x1200 @ 210 dpi` so the logical viewport is 411.4x914.3, within 1 px of the
design frame, then reset. Capture is a live `adb exec-out screencap` PNG,
downscaled to 405x900. Both renders sit at the same scale and are directly
comparable.

The APK under capture was built in this worktree from the preview entrypoint,
which pins `Locale('vi')`, dark brightness and `MediaQuery.withNoTextScaling`,
so the capture is the audited configuration and nothing else:

```
flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=splash
```

### Gradient ramp

Sampled down the right edge, which carries no centred content in either render:

| Height | Design | Implemented | Max channel Δ |
|---|---|---|---|
| 6% | (135, 79, 181) | (133, 81, 181) | 2 |
| 15% | (147, 79, 174) | (145, 81, 174) | 2 |
| 30% | (166, 79, 161) | (164, 82, 161) | 3 |
| 45% | (185, 79, 148) | (184, 82, 148) | 3 |
| 60% | (172, 90, 141) | (175, 91, 140) | 3 |
| 75% | (133, 110, 138) | (136, 110, 137) | 3 |
| 90% | (94, 129, 136) | (98, 130, 134) | 4 |

The `168deg #7B4FBE → #C2508F 55% → #4E8A87` ramp reproduces within 4/255
across the full run.

### Element geometry

Both images are 900 px tall (design 406 px wide, implemented 405 px).

| Element | Design | Implemented | Δ |
|---|---|---|---|
| Wordmark band (y) | 418–469 | 411–461 | −8 px |
| Wordmark width | 146 px | 147 px | +1 px |
| Wordmark centre x | 0.5012 W | 0.4988 W | −1 px |
| Dots band (y) | 506–512 | 493–504 | −11 px |
| Dots row width | 42 px | 41 px | −1 px |
| Status line (y) | 782–792 | 838–848 | +56 px (pill removed, see above) |
| Status line width | 182 px | 190 px | +8 px |
| Glow orb centroid | (0.3404 W, 0.3328 H) | (0.3268 W, 0.3017 H) | −5 px, −28 px |
| Tap pill | present | absent | intentional (ADR-6) |

Four residuals are explained rather than corrected:

- **Centre block sits 8 px higher.** The design canvas draws an opaque 48 px
  status bar and a 31 px home-indicator bar as part of its frame, so its
  centred group is pushed down by `(48 − 31) / 2 = 8.5 px`. The implementation
  centres over the full screen, because the design container is
  `min-height:100%` with no safe-area padding and only its bottom block uses
  `--safe-bot`. Measured Δ is 8 px — the chrome model, not a layout error.
- **Glow orb sits 28 px higher.** Same cause, unhalved: the canvas resolves
  `top:22%` inside a content box that starts below its 48 px status bar
  (`0.22 × 821 + 48 + 75 = 303.6`, i.e. `0.337 H`), while the app resolves it
  against the real full-height screen (`0.22 × 900 + 75 = 273`, i.e.
  `0.303 H`). Both measurements land within 1 px of those predictions, which
  confirms the code is placing the orb exactly where the CSS asks.
- **Status line sits 56 px lower.** ~45 px of that is the removed pill and its
  12 px gap no longer pushing the status line up; the remaining ~11 px is the
  real device's ~26 dp gesture inset versus the mock's 6 px `--safe-bot` for
  the `md` frame. The implemented status line's bottom edge measures 52.8
  logical px above the screen bottom, which is exactly the
  `safeBottom + 26` that `bottom: calc(var(--safe-bot) + 26px)` asks for.
- **Dots band is 11 px tall instead of 6 px.** The design render freezes
  animation, so its three dots are coplanar; the device render catches `bob`
  mid-cycle with the three dots at different phases. Row width still matches
  within 1 px.

### Copy

Both renders carry the same Vietnamese strings — wordmark `Cupid` and status
line `Đang mở khoá kỷ niệm của hai bạn…`. No `CircularProgressIndicator` or
other ad hoc spinner appears in the implemented render (AC3). The design
render's `Chạm để tiếp tục` pill has no counterpart, as described above.

### Evidence notes

`implemented-splash-popin-emulator-5554.png` was removed rather than
re-captured. A clean mid-`popIn` frame is not obtainable on this emulator: the
preview app's cold start to first Dart frame is ~18–23 s with several seconds
of jitter, splash is only on screen for the 2 s dwell, and `adb exec-out
screencap` round-trips at ~700 ms on this host — slower than the 700 ms
animation itself. The two frames that could be captured inside the window
differed only in `bob` phase (rows 493–508), with the wordmark already settled.
The `popIn` mapping is instead verified by the curve mapping below and by
`_Wordmark`'s code; no acceptance criterion depends on photographing it.

`data/requirements/.../STORY-003_splash_design_fidelity/story_master.md` still
lists the deleted `implemented-splash-popin-emulator-5554.png` in its Artifacts
section. That file is Scrum Master-owned and outside this handoff's write
scope; the bullet needs updating to the two-image set.

## Deviations Found And Fixed

All fixes are in
`mobile/lib/features/auth/presentation/screens/splash_screen.dart`.

| # | Element | Was | Design source | Fix |
|---|---------|-----|---------------|-----|
| 1 | Background gradient | `CupidColorTokens.gradientDream` — `linear-gradient(120deg, #FF9CC4, #C79BF0 52%, #8FE6D3)`, a pastel pink/lilac/mint ramp | `linear-gradient(168deg, #7B4FBE, #C2508F 55%, #4E8A87)` | `SplashPalette.background`, exact stops, stop positions and 168deg axis |
| 2 | Breathing glow orb | Absent entirely | 150px white radial fade at top 22% / left 14%, `breathe 6s ease-in-out infinite` (scale 1→1.09, opacity .5→.85) | `_BreathingGlow`, positioned via `LayoutBuilder` percentages inside the `Stack` |
| 3 | Wordmark color | `colorText` (`#F7EEFB` dark / `#3E2645` light) — theme-varying, so the light theme rendered near-black text on a fixed dark gradient | `#fff`, fixed | `SplashPalette.foreground` |
| 4 | Wordmark letter-spacing | Unset | `-.03em` | `letterSpacing: -1.74` (`-.03em` at 58px) |
| 5 | Wordmark entrance | No animation | `popIn .7s ease-out` (scale .94→1, translateY 8→0, opacity 0→1) | `_Wordmark` drives all three from a 700 ms `Curves.easeOut` controller |
| 6 | Wordmark→dots gap | `CupidSpacing.lg` = 24 | 26 | `SizedBox(height: 26)` |
| 7 | Status line placement | In the centred column, `CupidSpacing.xl` (32) below the dots | Absolutely bottom-anchored at `calc(--safe-bot + 26px)` | `Positioned(bottom: MediaQuery.paddingOf(context).bottom + 26)`, read above `Scaffold` so the raw frame inset is used |
| 8 | Status line color | `colorTextMuted` (`#B4A6CE`) | `rgba(255,255,255,.6)` | `SplashPalette.caption` |
| 9 | Status line size | `cupidType.body` = 17 | 11.5 | `caption.copyWith(fontSize: 11.5)` |
| 10 | Dot diameter | 8 | 9 | `SizedBox(width: 9, height: 9)` |
| 11 | Dot color | `colorText` (opaque, theme-varying) | `rgba(255,255,255,.9)` | `SplashPalette.dot` |
| 12 | Dot spacing | `EdgeInsets.symmetric(horizontal: CupidSpacing.xs)` — 8 between dots but also 4 of dead padding on each outer edge | `gap:8px`, no outer padding | Explicit `SizedBox(width: 8)` separators only |
| 13 | Dot animation | 900 ms cycle, `index * 0.2` stagger, −6 px amplitude, linear triangle wave | 1100 ms, `.18s`/`.36s` stagger, −7 px, `ease-in-out` per keyframe segment | 1100 ms controller; phase offsets `.18/1.1` and `.36/1.1`; `-7 * Curves.easeInOut` per half-segment |
| 14 | Vertical centring frame | `SafeArea` wrapped the whole column, centring the group inside the safe area | Container is `min-height:100%` with no safe-area padding; only the bottom block uses `--safe-bot` | `SafeArea` removed; group centred on the full screen, safe inset applied only to the bottom block |
| 15 | Dead code | `_TapToContinue` rendered the ADR-6-removed affordance | n/a | Replaced by `_StatusLine`; every widget in the file is now reachable from `build()` |

### Animation curve mapping

CSS `ease-in-out` is `cubic-bezier(.42,0,.58,1)`, which is exactly Flutter's
`Curves.easeInOut`, and CSS applies the timing function independently between
each keyframe pair. `breathe` is therefore driven by a 3000 ms controller with
`repeat(reverse: true)` plus `curve`/`reverseCurve` of `Curves.easeInOut` (half
of the 6 s cycle, mirrored, so the 0/50/100 keyframes and their per-segment
easing both land exactly), and `bob` maps its phase through `Curves.easeInOut`
on each half of the cycle rather than as a linear triangle.

## Explicitly Not Changed (out of scope)

- Session-resolution routing, the 2 s minimum dwell timer, the
  `SessionGateCubit` wiring and every navigation destination — STORY-001 scope.
  `initState`, `dispose` and `_tryNavigate` are byte-for-byte unchanged, and
  the ADR-5 invariant-2 comment on `pushReplacement` is intact.
- Tap and gesture handling. No `GestureDetector`, `InkWell` or `onTap` of any
  kind exists on this screen; the only `IgnorePointer` is inside the decorative
  glow. STORY-001's tap regression test still passes unmodified.
- Light theme / `en` locale user-facing QA (OQ5, out of scope per
  story_master.md). The new values are theme-invariant by construction, which
  incidentally fixes a latent light-theme bug (deviation 3).

## Write-Scope Notes

`mobile/lib/design_system/tokens/splash_palette.dart` and its
`design_system.dart` barrel export already existed on this branch before this
round and were not modified. They remain necessary:
`test/design_system/no_fork_guard_test.dart` fails the build if
`lib/features/**` contains a `Color(0x` or `Colors.` literal (D3/ADR-004), and
none of the splash design-source colors exist in `CupidColorTokens`. This
follows the `tokens/pet_hero_gradient.dart` and `tokens/bun_sprite_palette.dart`
precedent for additive, single-consumer token files.

Two members of that file are now unreferenced by `lib/` because the pill is
gone: `SplashPalette.pillFill` and `SplashPalette.pillBorder`. `pillFill` is
still referenced by this story's negative assertion (no pill is painted);
`pillBorder` is referenced by nothing. Removing it needs a write-scope
extension and is flagged to Scrum Master rather than taken unilaterally.

## Verification

Run from
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-003/mobile`.

| Command | Result |
|---------|--------|
| `flutter analyze lib/features/auth/presentation/screens/splash_screen.dart test/features/auth/presentation/splash_screen_test.dart` | 2 issues, both the pre-existing `prefer_initializing_formals` infos on STORY-001's constructor at `splash_screen.dart:38:8` and `:39:8`. No issue on a line this story added or changed. `flutter analyze` exits 1 whenever any issue of any severity exists, so the exit code is not a regression signal here. |
| `flutter test test/features/auth/presentation/splash_screen_test.dart test/design_system/no_fork_guard_test.dart` | `00:00 +10: All tests passed!` — 9 splash tests plus the color-literal guard |
| `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=splash` | `✓ Built build/app/outputs/flutter-apk/app-debug.apk` |

### Tests added this round

Three tests were appended to
`mobile/test/features/auth/presentation/splash_screen_test.dart`. The six
pre-existing routing/ADR-6 tests in that file are byte-identical — none was
weakened or removed.

1. background gradient is `SplashPalette.background`, the glow orb paints
   `SplashPalette.glow`, and exactly three `SplashPalette.dot` circles render
   (AC1, AC3)
2. the wordmark is Nunito 900 / 58 px / `-1.74` letter-spacing in
   `SplashPalette.foreground` (AC1)
3. the status line is 11.5 px in `SplashPalette.caption` and no
   `SplashPalette.pillFill` box is painted anywhere (AC1, AC3, ADR-6)

### Known failing test outside this write scope

`mobile/test/features/auth/presentation/screens/splash_design_fidelity_test.dart`
does not compile and fails the repository-wide suite:

```
test/features/auth/presentation/screens/splash_design_fidelity_test.dart:81:11:
Error: No named parameter with the name 'resolvePairingStatus'.
```

`git log` attributes the file to `9ab731f`, this story's discarded round-1
commit. It asserts the discarded tap-pill design and calls a `SplashScreen`
parameter that no longer exists. Its still-valid assertions have been re-homed
into `splash_screen_test.dart` above. It is outside this handoff's declared
`WriteScope`, so it was left in place and raised to Scrum Master as a blocker
rather than deleted unilaterally.

Also observed, unrelated to splash:
`mobile/test/features/reminders/reminder_copy_guard_test.dart` fails on two
`"synced alarm"` tokens in
`lib/features/onboarding/presentation/screens/permissions_screen.dart`, last
touched by STORY-009. Untouched by this story's diff.

## Acceptance Criteria Status

- **AC 1** (layout/spacing/color/typography match in dark + `vi`) — MET.
  15 deviations corrected; gradient within 4/255, wordmark and dot geometry
  within 1 px, remaining offsets accounted for by the chrome model and the
  ADR-6 pill removal.
- **AC 2** (deviations corrected in the app, not merely documented) — MET.
  Every row in the table is a code change, each pinned by a passing assertion
  and visible in the new device capture.
- **AC 3** (loading hold uses the design source's own treatment, no ad hoc
  spinner) — MET. The bobbing dots and the status line are the design source's
  own treatment; the tests assert no pill and the capture shows no spinner.
- **AC 4** (no new entry point) — MET. Splash is still reached through the
  unchanged launch sequence; no routing, session-resolution or gesture code was
  touched.
