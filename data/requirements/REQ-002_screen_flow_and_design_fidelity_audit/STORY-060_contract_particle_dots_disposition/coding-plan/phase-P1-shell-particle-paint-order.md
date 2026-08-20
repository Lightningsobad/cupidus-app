# P1 — Shell particle paint order + `contract` AC2 conformance test

Lane: mobile-dev
Depends on: nothing
Blocks: P2

Read `../architecture/solution.md` first. The one decision already made for
you: **this is a Stack reorder, not a new widget.** `_CupidSkyStars` already
renders the exact three dots with the exact canvas geometry and twinkle
semantics; it is just painted underneath the Navigator.

## Write Scope

- `mobile/lib/design_system/theme/cupid_app_background.dart`
- `mobile/test/design_system/cupid_app_background_test.dart`
- `mobile/test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart` (new)

Nothing else. In particular: no file under
`mobile/lib/features/love_contracts/`, no
`mobile/lib/design_system/tokens/cupid_sky_palette.dart`, no
`mobile/lib/main_preview.dart`.

## Step 1 — `cupid_app_background.dart`: reorder the Stack

In `_CupidAppBackgroundState.build` (currently lines 70-81), move
`_CupidSkyStars(elapsed: _elapsed)` from the middle of the `Stack.children` to
**last**, after `widget.child`. Final order: `CustomPaint` (sky wash) →
`widget.child` → `_CupidSkyStars`.

Nothing else in the method changes: keep the `ColoredBox`, keep
`fit: StackFit.expand`, keep the same `_elapsed` notifier.

Also correct the class dartdoc (lines 10-18), which currently claims the
particles are part of the wash painted "behind [child]". State instead that the
sky wash paints behind the child and the twinkle particles paint above it,
because the design source authors them as `position:absolute` siblings of the
screen body, which CSS paints above in-flow screen content. One or two lines —
do not write an essay, and do not restate the story id.

## Step 2 — `cupid_app_background_test.dart`: pin the paint order

Add one test that fails on the pre-fix ordering. Structure it as a pixel probe,
not a widget-tree-shape assertion, so a future refactor that preserves the
behaviour does not break it:

- Mount `CupidAppBackground` with a child that is a full-bleed opaque
  `ColoredBox` in a color that appears in neither the flat fill nor any
  `CupidSkyLayer` (reuse the sentinel idea from
  `test/design_system/shared_backdrop_occlusion_test.dart:44` — pure green
  works).
- Leave animations **enabled** and pump to the first star's peak: the first
  `CupidSkyPalette.stars` entry has `period: 3400ms` and `delay: Duration.zero`,
  so its peak (`twinkleMaxOpacity 1.0`, `twinkleMaxScale 1.15`) is at 1700ms.
  Pump a first frame, then `tester.pump(const Duration(milliseconds: 1700))`.
  Do not call `pumpAndSettle` — the ticker never settles with animations on.
- Rasterize through a `RepaintBoundary` and probe the pixel at that star's
  centre, derived from the token rather than hardcoded:
  `star.leftFactor! * surfaceWidth + star.size / 2`,
  `star.topFactor * surfaceHeight + star.size / 2`. Copy the `toImage` /
  `runAsync` / `getUint8` mechanics from `shared_backdrop_occlusion_test.dart`
  (`_probePixel`, lines 78-97) — do not invent a second rasterization helper.
- Assert the probed pixel reads as the white star, not the sentinel: its green
  channel alone cannot separate white from green, so assert on **red** and
  **blue** being high (the sentinel `0xFF00FF00` has both at zero).
- Add a control probe at the same `y`, offset ~40 logical px horizontally, and
  assert it still reads the sentinel. Without this control the test would pass
  even if the child stopped painting.

Leave the three existing tests (`holds the stars at rest…`, `twinkles the
stars…`, `never intercepts a tap landing on a star`) untouched. Confirm the tap
test at line 101 still passes after the reorder — the star layer now sits above
the tap target, and it must still not swallow the tap; that is exactly the
`IgnorePointer` guarantee this test exists to protect, and it becomes
meaningful only after this phase.

## Step 3 — new `love_contract_particle_dots_test.dart`: the AC2 pin

Path:
`mobile/test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart`

This is AC2's named-screen conformance criterion. It must prove the `contract`
screen renders the dots **on top of its own opaque card**, which is the exact
STORY-056 DEF-1 deviation.

- Host: mirror `_host` in `shared_backdrop_occlusion_test.dart:48-76` — a
  `MaterialApp` with `buildCupidTheme(platform: CupidPlatform.material,
  brightness: Brightness.dark)`, `locale: const Locale('vi')`,
  `AppL10n.localizationsDelegates`, and `CupidAppBackground` mounted through
  `builder`. **Do not** copy its `disableAnimations: true` MediaQuery; this test
  needs the ticker running.
- Screen: `LoveContractScreen(repository: …, entry:
  LoveContractEntry.onboardingStep)`. Reuse the `_ScriptedAdapter` /
  `_loveContractRepository` pattern from
  `shared_backdrop_occlusion_test.dart:155-191` so the screen reaches
  `LoveContractReady` (requester, unsigned — the state AC2's reference PNG
  shows). The in-chain entry is deliberate: it renders without `CupidHeader`, so
  the probe pixel is card surface rather than app-bar chrome.
- Surface: set a phone-like frame so the source's percentage positions land
  where the design reference puts them — `tester.view.physicalSize = const
  Size(390, 844)` with `tester.view.devicePixelRatio = 1.0`, and reset both with
  `addTearDown(tester.view.reset)`.
- Pump to the first star's 1700ms peak as in Step 2.
- Probe the first star's centre (derived from `CupidSkyPalette.stars.first`, as
  in Step 2). At this frame size that centre is `≈(34, 121)`, inside the
  `colorSurface` contract card, which `_LoveContractReadyBody`
  (`love_contract_screen.dart:308-325`) lays out at `CupidSpacing.md` from the
  body's top edge and full width minus `CupidSpacing.md` on each side.
- Assert: the probe pixel is near-white (all three channels high). Control: a
  pixel ~40 logical px to the right, same `y`, is **not** near-white — proving
  the card is genuinely painted there and the dot sits above it rather than on
  bare backdrop.
- If the control assertion fails because the chosen dot does not land over the
  card at that frame size, switch to another `CupidSkyPalette.stars` entry whose
  control does hold (adjusting the pump duration to that star's own
  `period`/`delay`) rather than nudging the probe coordinate until it passes.
  Record which star you used in `test-results.md`.
- Name the test so the screen id is explicit, e.g.
  `'AC2: the contract screen paints the three ambient particle dots above its own card'`.

## Verification

```
cd mobile && flutter analyze lib/design_system/theme/cupid_app_background.dart test/design_system/cupid_app_background_test.dart test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart
cd mobile && flutter test test/design_system/cupid_app_background_test.dart test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart test/design_system/shared_backdrop_occlusion_test.dart
```

`shared_backdrop_occlusion_test.dart` is included as a regression guard: it
probes the sky wash at `(120, 10)` on six screens including `contract`, and the
reorder must not change what that pixel reads. `(120, 10)` is far from all
three star centres, so it should be unaffected — if it moves, stop and report.

## Completion

Record the analyze/test output in `coding-plan/test-results.md`. Do not capture
visual evidence yet; do that after P2, per `master-plan.md`.
