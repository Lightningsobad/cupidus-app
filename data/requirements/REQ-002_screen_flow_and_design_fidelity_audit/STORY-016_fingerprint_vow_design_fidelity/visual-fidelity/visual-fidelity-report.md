# STORY-016 — Visual Fidelity: Fingerprint Vow

VISUAL_FIDELITY: PASS

## Scope of this comparison

| Field | Value |
| --- | --- |
| Screen | Fingerprint Vow (`VowScreen`, Epic 1, `NO_CHROME` / `NO_TABS`) |
| Design source | `cupid-app-design-system`, entry `Cupid App.dc.html` (locked) |
| Design-Screen id | `vow` |
| Device / form factor | `emulator-5560`, Android phone, 405x900 capture (360dp wide) |
| Theme / locale | dark, `vi` (AC1 scope; light + `en` out of scope per OQ5) |
| Design reference | `design-reference-vow-android.png` (406x900) |
| Implemented capture | `implemented-vow-emulator-5560.png` (405x900) |
| Captured state | idle / `myNotVowed` — both partners still waiting |

## The starting condition this story actually found

The story is written as a re-audit, but there was no Fingerprint Vow screen in
the app to audit. `mobile/lib/features/vow/` did not exist at `BaseHead`
(`4eadb3d`), `vow` was listed in `main_preview.dart`'s `_notImplementedCanvasIds`,
and no route, widget, or test referenced it. Nothing was rendering, so "correct
every deviation" could only be satisfied by transcribing the whole screen from
the locked source.

That was treated as in scope rather than as a blocker, on three grounds: the
story's WriteScope is all of `mobile/lib` and `mobile/test`; the design source
fully specifies every element, state, and animation, so no design decision had
to be invented; and the backing data already exists (`POST /users/vow`,
`CupidProfile.vowTaken`), so the screen is not speculative. AC5 is honoured by
adding **no** app navigation — see "AC5" below.

## What the screen is transcribed from

Every value below is read from `Cupid Screens.dc.html` (the `isVow` block at
`:205-228`, the shared wrapper at `:44-47`) and `Cupid App.dc.html` (theme
variables `:30`, `pulseRing` `:35`, `boom` `:39`, `twinkle` `:42`, the
"Nebula Sky — nền chung mọi screen" note at `:100`).

| Element | Design source | Implemented as |
| --- | --- | --- |
| Root wash | `radial-gradient(circle at 50% 30%, rgba(123,47,190,.5), transparent 62%)` over `var(--bg)` | `RadialGradient(center: Alignment(0,-0.4), radius: 1.01)` from `VowPalette.heroWash` α.5 → α0, over `colorBackground` |
| Screen padding | `var(--safe-top) 24px 40px` | `SafeArea` + `EdgeInsets.fromLTRB(CupidSpacing.lg, 0, CupidSpacing.lg, 40)` |
| Eyebrow | Roboto Mono 10px, `letter-spacing .2em`, `--pink`, uppercase | `labelMono` 10px, `letterSpacing 2.0`, `colorAccentPink`, `.toUpperCase()` |
| Title | Nunito 900, 29px, `line-height 1.15`, `--tx` | `headline` w900 29px, `height 1.15`, `colorText` |
| Subtitle | 13.5px, `line-height 1.55`, `--tx2`, `max-width 270` | 13.5px, `height 1.55`, `colorTextMuted`, `ConstrainedBox(maxWidth: 270)` |
| Hold target | 150px field; `2px solid var(--pink)` ring on `pulseRing 1.9s ease-out infinite`; disc `linear-gradient(135deg, rgba(255,127,182,.24), rgba(183,140,245,.24))` with `1.5px solid rgba(255,127,182,.5)`; 78px `fingerprint` in `--pink` | `SizedBox(150)` → `_PulseRing` (2px `colorAccentPink`) + circular `LinearGradient(topLeft→bottomRight)` of `colorAccentPink`/`colorAccentPurple` at α.24, `Border.all(colorAccentPink α.5, 1.5)`, `CupidIcon(CupidIcons.fingerprint, size: 78)` |
| `pulseRing` keyframe | `scale(.9)/opacity .7` → `scale(1.5)/opacity 0` at 70%, invisible to 100% | `Curves.easeOut` over `t/0.7`, `scale 0.9 + 0.6·eased`, `opacity 0.7·(1-eased)`, `SizedBox.shrink()` for `t ≥ 0.7` |
| Signed disc | 154px, `rgba(121,226,205,.16)`, `2px solid var(--mint)`, 72px `check_circle`, `animation: boom .6s ease-out` | `Container` 154, mint α.16, 2px mint border, `CupidIcons.checkCircle` at 72, `_SignedDisc` playing `boom` over 600ms |
| `boom` keyframe | `scale(.2)/opacity 0` → `scale(1.18)/opacity 1` at 55% → `scale(1)` | Two-segment `TweenSequence` on a 600ms `ease-out` controller |
| Status row | `gap:14px`; 38px avatars `linear-gradient(135deg,#FF4B8C,#7B2FBE)` and `#00C9A7,#7B2FBE`; 14px/700 `#fff` initial; 11px `--tx2` label; `34x1` `var(--line)` connector | `SizedBox(width:14)` gaps, 38px `VowPalette.selfAvatarGradient` / `partnerAvatarGradient`, `VowPalette.avatarInitial` 14px w700, 11px `colorTextMuted`, `SizedBox(34,1)` in `colorLine` |
| Both-signed CTA | 52px pill, `padding 0 26px`, `var(--green)`, `#04231E` ink, 16.5px/700 "Vào Dashboard" | 52px pill, 26px horizontal padding, `colorAccentGreen`, `VowPalette.dashboardCtaInk`, 16.5px w700 |
| Star particles | three `position:absolute` `twinkle` dots, `pointer-events:none` | `CupidStarField` (new shared decoration) — see below |

## Deltas found and fixed after the first capture

The first implementation capture differed from the design reference in one
respect that was **not** an artefact: the design reference showed three small
twinkling dots at `top 14% / left 8%`, `top 9% / right 16%` and
`top 26% / right 7%` that the implementation did not have.

They are not a Vow element. `Cupid Screens.dc.html:44-47` puts them in the
wrapper that every screen renders inside, and `Cupid App.dc.html:100` labels
that wrapper "Nebula Sky — nền chung mọi screen, có sao nhấp nháy". The reason
they still show through the Vow screen's own opaque `var(--bg)` layer is CSS
painting order: they are `position:absolute` siblings of the in-flow screen
body, so they paint *above* it. The `--sky` wash behind them does not show
through, and correctly must not be reproduced here.

Fixed by adding `mobile/lib/design_system/decorations/cupid_star_field.dart` and
placing it as the **last** child of the screen's background `Stack`, which
reproduces the source's painting order. `pointer-events:none` maps to the
`ExcludeSemantics` + `IgnorePointer` pair built into the widget, so it cannot be
made interactive by a caller. Pinned by the widget test "AC1: the shared twinkle
star field paints over the screen".

`waiting_screen.dart` carries its own private `_TwinkleStar`/`_SkyBackdrop`
predating this widget. It was deliberately left untouched: it belongs to
STORY-013's screen and consolidating the two is a design-system change, not a
Vow change. Logged as a deferred item below.

## Intentional deviation: the "holding" state (AC4)

The design source binds a plain `onClick="doVow()"` to the fingerprint field and
specifies **no** holding treatment — there is no third state in the markup to
copy. AC3 nevertheless requires a 1.5s hold, and `architecture/solution.md`
ADR-006a fixes that dwell at 1500ms for the shared hold-to-sign ritual.

Resolved without inventing geometry or colour: during the dwell,
`_HoldDwellPainter` sweeps **the disc's own existing 1.5px border** clockwise
from 12 o'clock, from `rgba(255,127,182,.5)` to full-alpha `--pink`. No new
ring, radius, thickness, or hue is introduced — the only thing that changes is
the alpha of a stroke the design source already draws. This is the minimum
visual that can express progress while staying inside the source's vocabulary,
and it is flagged here so a reviewer sees it as a deliberate choice rather than
an unsourced addition.

Accessibility: the dwell is not the only path. `Semantics(button: true, onTap:)`
wraps the target with the label "Giữ 1,5 giây để ký Fingerprint Vow", so an
assistive-technology activation signs instantly (ADR-006a). Pinned by "AC3: the
hold target exposes an accessible activation".

## Differences visible between the two images that are NOT deviations

- **Device bezel.** `render-design-canvas.js` draws the design inside a phone
  frame; `capture-mobile-screen.sh` returns the raw framebuffer. Renderer
  artefact.
- **Status bar and gesture pill.** Design draws a mock `9:30` bar; the capture
  has the emulator's real one at `2:24`. Not screen content.
- **`pulseRing` phase.** The ring is `1.9s infinite`; the reference happened to
  be captured near `t≈0` (ring at scale ~1, full opacity, hugging the disc) and
  the implementation near `t≈0.4` (expanded to ~scale 1.25 and faded). Both are
  the same keyframe sampled at different instants — see the keyframe row above.
- **Absolute-pixel elements read larger in the capture.** The design frame is
  ~398 CSS px wide; the capture device is 360dp wide. Every size in the source
  is an absolute px value, so a 150px disc is 38% of the design frame and 42% of
  the capture. Measured against each image's own screen width the two agree
  (design 139/386 px, implementation 168/405 px). This is the same capture
  geometry the 24 sibling design-fidelity stories in REQ-002 used.

## States not photographed

The design canvas keeps `myVowed` in local prototype state driven by its own
`doVow()` click handler, so `render-design-canvas.js` cannot produce a design
reference for the signed or both-signed states — there is nothing to compare a
second capture against. Those states are covered instead by transcription (table
above) and by four widget tests: idle affordance, first-partner-signed check
disc with no CTA, both-signed with the CTA firing, and an assertion that the
signed disc uses exactly `#79E2CD` at α.16 with a 2px border.

## AC5 — no new entry point

The screen is registered **only** in `lib/main_preview.dart` (a dev-only
capture harness) with an `idle | signed | both` state seed. No route, no
navigator push, no shell tab, and no change to any other screen. `VowScreen`
reports out through `onVowSigned` / `onEnterDashboard` callbacks and wires
neither itself, following the `PairedScreen.onSignContract` precedent. Choosing
where `vow` sits in the flow stays with Scope A (STORY-001/STORY-002).

## Remaining deltas, deferred with named owners

- **Duplicate twinkle-star implementations.** `waiting_screen.dart` has a
  private `_TwinkleStar` and a full `_SkyBackdrop`; this story adds the shared
  `CupidStarField`. Consolidating them means editing STORY-013's screen and
  should be owned by a design-system story, not by a Vow fidelity story.
- **The `--sky` nebula wash itself.** Only the star particles are reproduced,
  because the Vow root's opaque `var(--bg)` covers the wash. Screens whose root
  is transparent still need the wash; that is STORY-009 items 1 and 3, an
  app-wide background concern.
- **No golden baseline.** `matchesGoldenFile` would create
  `test/features/vow/presentation/screens/goldens/`, a new goldens tree. The
  eight widget tests are the in-scope regression guard; baselining should be
  done by whichever story owns the goldens directory.
- **`no_fork_guard_test.dart` is red at `BaseHead` and still red.** Seven
  pre-existing violations in `ghost_settings_screen.dart:211,411`,
  `notification_settings_screen.dart:360`,
  `reminder_schedule_screen.dart:449,450,453` and
  `reminder_weekday_chips.dart:71`. None is a file this story touches
  (`git status` confirms), and the new `vow` feature code contains no raw colour
  literal or platform branch. Not fixed here — those files are owned by
  STORY-018/019, STORY-031 and STORY-021.

## Verification

All commands run in this session from the story worktree.

- `dart format lib/features/vow lib/design_system/decorations test/features/vow` — formatted.
- `flutter analyze --no-fatal-infos lib/features/vow lib/design_system lib/main_preview.dart test/features/vow` — **No issues found!**
- `flutter test test/features/vow/presentation/screens/vow_screen_test.dart` — **+8: All tests passed!**
- `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=vow --dart-define=PREVIEW_VOW_STATE=idle` — **✓ Built build/app/outputs/flutter-apk/app-debug.apk**
- `flutter test test/design_system/no_fork_guard_test.dart` — fails with the 7
  pre-existing violations listed above, unchanged from `BaseHead`.
- Capture taken from that exact APK, installed and screenshotted inside one
  `capture-mobile-screen.sh --lease-exec` window on `emulator-5560` so a
  concurrently running story could not swap the package underneath it. Earlier
  captures that caught another story's build were discarded and regenerated;
  the image in this folder certifies the code being delivered.

## Files

- `mobile/lib/features/vow/presentation/screens/vow_screen.dart` (new)
- `mobile/lib/features/vow/presentation/vow_strings.dart` (new)
- `mobile/lib/design_system/decorations/cupid_star_field.dart` (new)
- `mobile/lib/design_system/tokens/vow_palette.dart` (new)
- `mobile/lib/design_system/design_system.dart` (barrel exports)
- `mobile/lib/design_system/icons/cupid_icons.dart` (`fingerprint`, `checkCircle`)
- `mobile/lib/main_preview.dart` (preview entry, `vow` removed from `_notImplementedCanvasIds`)
- `mobile/test/features/vow/presentation/screens/vow_screen_test.dart` (new, 8 tests)
