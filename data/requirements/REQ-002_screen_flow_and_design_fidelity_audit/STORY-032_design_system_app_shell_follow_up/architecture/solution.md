# Architecture: STORY-032 Design System — App-Shell Background, Button & Header Follow-Up

Scope: mobile lane only, Flutter `mobile/lib/design_system/` + one composition-root
wiring in `mobile/lib/app/cupid_app.dart`. No backend, no devops, no new routes.
Dark theme + `vi` only (OQ5 out of scope).

Inputs: `../story_master.md`, `../ux/ux-spec.md`.

## 1. Decisions

### ADR-032a — The shared background mounts at `MaterialApp.builder`, not `AppShell`

Confirmed against the code: `MaterialApp.builder` is currently unset
(`mobile/lib/app/cupid_app.dart:25-45`), and a repo-wide search for
`builder:` in `mobile/lib/core/navigation/` returns only `BlocBuilder` and
`MaterialPageRoute` builders. Nothing depends on `builder` being unset, so
adding one is safe. This closes UX spec open item 2.

`builder` wraps the whole `Navigator` output, so a single insertion reaches
pre-pairing screens (`PairGateShell`), post-pairing tabs (`AppShell`), and
routes pushed outside `AppShell.build` (`MeScreen`, `GhostSettingsScreen`).
Wrapping `AppShell`'s `Scaffold` instead would miss all three of the last
group, so the composition root is the only correct layer.

### ADR-032b — New design-source values live in a palette file, not in `CupidColorTokens`

The 3 star-particle colors (`#FFFFFF`, `#FFD9EA`, `#CEB4FF`) have no existing
token (`colorText` is `#F7EEFB`, `colorAccentLilac` is `#D9C2FF` — neither
matches). They are declared inline in the design source's frame block, not as
`:root` custom properties, so they are not theme-axis tokens.

Decision: add `mobile/lib/design_system/tokens/cupid_sky_palette.dart`
following the existing `SplashPalette` / `PetHeroGradient` precedent
(`mobile/lib/design_system/tokens/splash_palette.dart`). Do **not** add fields
to `CupidColorTokens` — that would force `copyWith`/`lerp`/both constructors to
change and widen the blast radius for values that are not theme tokens.

`skyGradient` itself stays a `String` on `CupidColorTokens` and is **not**
parsed at runtime. The palette carries the same three layers as structured
Dart values, in both a `dark` and a `light` set (the token string differs per
theme). `CupidColorTokens.skyGradient` remains the documented design-source
record; the palette is its renderable transcription. Do not delete or reword
the token.

Raw `Color(0x...)` literals are legal here: `test/design_system/no_fork_guard_test.dart`
guards only `lib/features`, `lib/app`, and `lib/core`. This is the reason the
background widget and its palette must live under `lib/design_system/` and the
`cupid_app.dart` change must contain no color literal and no `Colors.` reference.

### ADR-032c — `CupidPrimaryButton` keeps `ElevatedButton`; the gradient goes on a wrapper

`test/design_system/adaptive_widgets_test.dart:99` and `:122` do
`tester.widget(find.byType(ElevatedButton))` and read `button.style!.shape!` to
assert the iOS-pill vs Material-20dp radius fork. The UX spec floated an
`Ink`/`InkWell` restructure; that would break both assertions and force a
rewrite of a contract test this story is required (AC5) to keep passing.

Decision: keep `ElevatedButton` in the tree. Wrap it in a `DecoratedBox`
carrying `gradient` + `boxShadow`, and set the button's own
`backgroundColor`/`shadowColor` to transparent so the wrapper shows through.
Material ink still renders on the button's own `Material`, so ripple is
preserved. Both existing radius assertions keep passing unmodified, and the
existing `find.byType(SizedBox).first` height assertions (`>= 44` iOS,
`>= 48` Material) are satisfied by the new fixed height of 54.

### ADR-032d — Header blur uses `AppBar.flexibleSpace`, keeping `AppBar` in the tree

`adaptive_widgets_test.dart:84` asserts `find.byType(AppBar), findsOneWidget`.
Material blur is therefore applied as
`AppBar(backgroundColor: transparent, flexibleSpace: ClipRect(BackdropFilter(...)))`
rather than by replacing `AppBar`. iOS uses `ClipRect(BackdropFilter(...))`
around the existing `Container`, with the opaque `color:` removed.

`ClipRect` is mandatory on both: an unclipped `BackdropFilter` blurs the entire
screen, not just the header band.

### ADR-032e — The `Scaffold` background override is removed from all 21 sites, not 4

The UX spec named 4 files. The code has 21 `Scaffold(backgroundColor:
colors.colorBackground)` sites. Once `scaffoldBackgroundColor` flips to
transparent, every remaining override is an explicit opt-out that occludes the
new shared layer — leaving 17 of them would make AC1 ("any screen that should
inherit the shared background") false across most of the app and would leave
the abstraction exactly as unconsumed as AC4 exists to prevent.

Verified safe: no test in `mobile/test/` reads `Scaffold.backgroundColor`, and
there are no golden tests in the repo (`matchesGoldenFile`: 0 matches). Every
`backgroundColor`-adjacent test assertion is a `BoxDecoration.color` check on
an inner card, unaffected by this change.

This is deliberately scoped as a mechanical one-line deletion per file. It is
not a re-audit of those screens, which the story's Out of Scope section
excludes and this plan does not perform.

### ADR-032f — Gradient rendering is a `CustomPainter` with an explicit ellipse transform

`RadialGradient.createShader(rect)` produces a circle (radius derived from
`rect.shortestSide`), so it cannot express the source's independently sized
ellipses. A stacked `DecoratedBox` approach would need `Transform.scale` per
layer and still fights the paint order.

Decision: one `CustomPainter` drawing all 3 layers with `ui.Gradient.radial`
plus a per-layer `Matrix4` that scales about the layer center. Exact math is in
the coding plan; getting it wrong is the specific fidelity failure this story
exists to fix, so it is specified there rather than left to implementer choice.

### ADR-032g — Reduce-motion path is required

The star twinkle runs for the entire app lifetime at the composition root.
`CupidAppBackground` must render the stars at their rest state and start no
`AnimationController` when `MediaQuery.disableAnimations` is true. This is ~3
lines and is the accessibility contract for perpetual decorative motion.

It does **not** fix the test hazard in section 3 — `flutter_test` defaults
`disableAnimations` to false — so the two test edits there are still required.

## 2. Touched files

New:
- `mobile/lib/design_system/tokens/cupid_sky_palette.dart`
- `mobile/lib/design_system/theme/cupid_app_background.dart`
- `mobile/test/design_system/cupid_app_background_test.dart`

Modified (design system):
- `mobile/lib/design_system/design_system.dart` (2 exports)
- `mobile/lib/design_system/theme/cupid_theme.dart` (line 43)
- `mobile/lib/design_system/adaptive/cupid_primary_button.dart`
- `mobile/lib/design_system/adaptive/cupid_header.dart`

Modified (composition root):
- `mobile/lib/app/cupid_app.dart` (add `builder:`)

Modified (tests, intentional per AC5):
- `mobile/test/design_system/adaptive_widgets_test.dart` (add assertions)
- `mobile/test/widget_test.dart:68` (`pumpAndSettle` → bounded `pump`)
- `mobile/test/app/feature_flags_test.dart:78` (same)

Modified (one-line deletion each, 21 files): listed in the coding plan, Phase 2.

## 3. Known regression risks

1. **`pumpAndSettle` deadlock (highest risk).** `mobile/test/widget_test.dart:68`
   and `mobile/test/app/feature_flags_test.dart:78` are the only two tests that
   pump the full `CupidApp`, and both call `await tester.pumpAndSettle()`
   immediately after. A perpetual `AnimationController` at the composition root
   makes `pumpAndSettle` throw "timed out". Both must move to a bounded
   `await tester.pump()` + `await tester.pump(Duration(seconds: 1))`. Called out
   explicitly per AC5.

2. **Transparent-black fringe.** Fading a gradient stop to `Colors.transparent`
   fades through transparent *black* and produces a visible dark halo. Each
   layer's end stop must be the same RGB at zero alpha.

3. **CSS radii vs diameters.** In `radial-gradient(120% 70% at ...)` the two
   values are the ellipse's horizontal and vertical **radii**, not its size.
   Halving them is a silent 2x fidelity error.

4. **Now-unused locals.** Deleting `backgroundColor: colors.colorBackground`
   may orphan `final CupidColorTokens colors = context.cupidColors;` in files
   where it had no other use, failing `flutter analyze`. Must be checked per
   file, not assumed.

5. **Welcome screen.** `welcome_screen.dart` paints its own `LinearGradient`
   and has no `Scaffold` override, so it is untouched by Phase 2 — but the
   theme default flip means it must be visually confirmed to still cover its
   frame. Build-time check only, not an acceptance criterion.

6. **Splash screen.** Out of scope. It fully occludes the new layer with its
   own `SplashPalette` gradient. Do not touch or re-verify.

## 4. STORY-033 overlap

`STORY-033_app_shell_design_system_deltas` does not exist in this worktree at
`BaseHead` 940773a, so it cannot be read or coordinated against here.

Per `../story_master.md` it overlaps on `skyGradient` and `CupidHeader`
back-arrow ink, and separately owns two deltas this story must **not** take:
the `caption` sub-13px text-style regression, and the shared CTA gradient axis
change (120deg -> 95deg).

Boundary to hold: this story consumes `colors.gradientHot` **by reference** and
never edits its angle. STORY-033 changes the token; this story changes the
consumer. That keeps the CTA axis conflict-free on merge. The `CupidHeader`
back-glyph ink change (`colorText` -> `colorAccentPink`) and the `skyGradient`
adoption are genuine same-line overlaps and will need a merge reconciliation if
STORY-033 lands first — flag to Scrum Master, not resolvable from this branch.
