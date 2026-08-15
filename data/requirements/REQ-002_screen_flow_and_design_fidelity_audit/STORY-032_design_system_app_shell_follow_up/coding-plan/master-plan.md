# Coding Plan: STORY-032 Design System — App-Shell Background, Button & Header Follow-Up

Lane: mobile only (single lane, no parallel split).
Decisions and rationale: `../architecture/solution.md`.
UX source of truth: `../ux/ux-spec.md`.

Phases run in order. Phase 2 depends on Phase 1 (the theme default must be
transparent and the layer must exist before screen overrides are removed).
Phase 3 is independent of Phases 1-2 and may run before or after them.

---

## Phase 1 — Shared app-shell background layer (AC1)

Files (6):
1. `mobile/lib/design_system/tokens/cupid_sky_palette.dart` (new)
2. `mobile/lib/design_system/theme/cupid_app_background.dart` (new)
3. `mobile/lib/design_system/design_system.dart` (add 2 exports)
4. `mobile/lib/design_system/theme/cupid_theme.dart` (line 43)
5. `mobile/lib/app/cupid_app.dart` (add `builder:`)
6. `mobile/test/design_system/cupid_app_background_test.dart` (new)

### 1.1 `cupid_sky_palette.dart`

Follow the `SplashPalette` pattern in
`mobile/lib/design_system/tokens/splash_palette.dart` — an `abstract final
class` of `static const` design-source transcriptions, with a dartdoc naming
the source. Declare a small `@immutable` value type for a gradient layer:

```dart
class CupidSkyLayer {
  const CupidSkyLayer({
    required this.radiusXFactor,   // fraction of surface width
    required this.radiusYFactor,   // fraction of surface height
    required this.centerXFactor,   // fraction of surface width
    required this.centerYFactor,   // fraction of surface height
    required this.color,
    required this.endStop,
  });
  ...
}
```

Dark layers (`CupidColorTokens.dark().skyGradient`, in paint order):

| # | radiusX | radiusY | centerX | centerY | color | endStop |
|---|---|---|---|---|---|---|
| 1 | 1.20 | 0.70 | 0.15 | -0.08 | `Color.fromRGBO(123, 47, 190, 0.55)` | 0.62 |
| 2 | 0.90 | 0.55 | 0.95 | 0.06 | `Color.fromRGBO(255, 75, 140, 0.32)` | 0.60 |
| 3 | 0.80 | 0.50 | 0.50 | 1.08 | `Color.fromRGBO(0, 201, 167, 0.16)` | 0.62 |

Light layers (`CupidColorTokens.light().skyGradient`):

| # | radiusX | radiusY | centerX | centerY | color | endStop |
|---|---|---|---|---|---|---|
| 1 | 1.20 | 0.70 | 0.12 | -0.10 | `Color.fromRGBO(255, 182, 214, 0.72)` | 0.62 |
| 2 | 0.90 | 0.55 | 0.96 | 0.04 | `Color.fromRGBO(206, 180, 255, 0.60)` | 0.60 |
| 3 | 0.80 | 0.50 | 0.50 | 1.08 | `Color.fromRGBO(178, 240, 226, 0.50)` | 0.62 |

**The `120% 70%` pair are the ellipse's horizontal and vertical radii, not its
width and height.** Do not halve them.

Stars (theme-independent — the design source declares them once in the frame
block, outside any `[data-plat]` or theme branch):

| # | left/right | top | size | color | period | delay |
|---|---|---|---|---|---|---|
| 1 | left 0.08 | 0.14 | 6 | `Color(0xFFFFFFFF)` | 3400ms | 0 |
| 2 | right 0.16 | 0.09 | 4 | `Color(0xFFFFD9EA)` | 4600ms | 800ms |
| 3 | right 0.07 | 0.26 | 5 | `Color(0xFFCEB4FF)` | 5200ms | 1600ms |

Twinkle motion, shared by all 3: opacity `0.25 <-> 1.0`, scale `0.85 <-> 1.15`,
`Curves.easeInOut`, symmetric `low -> high -> low` across one period, repeating
forever. Rest state (reduce-motion) is the low end: opacity `0.25`, scale
`0.85`.

### 1.2 `cupid_app_background.dart`

`CupidAppBackground({required Widget child})`, a `StatefulWidget` with
`SingleTickerProviderStateMixin`.

Paint order, back to front — this order is the fix, do not reorder:
1. Solid `context.cupidColors.colorBackground` fill.
2. The 3 radial layers, via one `CustomPaint`.
3. The 3 twinkle stars.
4. `child`.

Layer selection: pick the dark or light palette set from
`Theme.of(context).brightness`.

Gradient painter, per layer, given `Size size`:

```dart
final double rx = layer.radiusXFactor * size.width;
final double ry = layer.radiusYFactor * size.height;
final Offset c = Offset(
  layer.centerXFactor * size.width,
  layer.centerYFactor * size.height,
);

// Scale about c so the circle of radius rx becomes an ellipse rx x ry.
final Matrix4 m = Matrix4.identity()
  ..translate(c.dx, c.dy)
  ..scale(1.0, ry / rx)
  ..translate(-c.dx, -c.dy);

final Paint paint = Paint()
  ..shader = ui.Gradient.radial(
    c,
    rx,
    <Color>[layer.color, layer.color.withAlpha(0)],
    <double>[0.0, layer.endStop],
    TileMode.clamp,
    m.storage,
  );
canvas.drawRect(Offset.zero & size, paint);
```

The end stop must be `layer.color.withAlpha(0)` — the same RGB at zero alpha.
Using `Colors.transparent` fades through transparent black and produces a
visible dark halo.

`shouldRepaint` returns true only when the layer list or size changes; the
stars are a separate subtree so the gradient does not repaint per animation
frame. Wrap the star layer in a `RepaintBoundary`.

Reduce-motion: when `MediaQuery.maybeOf(context)?.disableAnimations ?? false`
is true, render the stars at rest state and do not start the controller.

Stars are decorative: wrap in `ExcludeSemantics` and never intercept hit
testing (`IgnorePointer`).

### 1.3 `design_system.dart`

Add, keeping the file's alphabetical grouping:
- `export 'theme/cupid_app_background.dart';`
- `export 'tokens/cupid_sky_palette.dart';`

### 1.4 `cupid_theme.dart`

Line 43: `scaffoldBackgroundColor: colorTokens.colorBackground` becomes
`scaffoldBackgroundColor: Colors.transparent`. Add a one-line comment naming
`CupidAppBackground` as the layer that now owns the base fill. `Colors.` is
legal in `lib/design_system/` (the no-fork guard covers only `lib/features`,
`lib/app`, `lib/core`).

### 1.5 `cupid_app.dart`

Add to the `MaterialApp`:

```dart
builder: (BuildContext context, Widget? child) =>
    CupidAppBackground(child: child ?? const SizedBox.shrink()),
```

Import via the `design_system.dart` barrel. This file is inside the no-fork
guard: no `Color(0x`, no `Colors.`, no `Platform.is`, no
`defaultTargetPlatform`.

### 1.6 `cupid_app_background_test.dart`

Cover: (a) `CupidAppBackground` renders its child; (b) the dark palette is
selected under `Brightness.dark`; (c) with `disableAnimations` true no ticker
is running (use `tester.binding.transientCallbackCount`, or assert the rest-state
opacity); (d) the widget is not hit-testable, i.e. a button behind/inside the
child still receives taps.

### Phase 1 verification
- `flutter analyze` clean.
- `flutter test test/design_system/`.
- App boots and every screen without a `Scaffold` override shows the wash.

---

## Phase 2 — Adopt the layer app-wide + AC4 re-verification (AC1, AC4)

One mechanical edit repeated across 21 files: delete the
`backgroundColor: colors.colorBackground,` line from the `Scaffold`.

| # | File | Line |
|---|---|---|
| 1 | `mobile/lib/features/auth/presentation/screens/login_screen.dart` | 180 |
| 2 | `mobile/lib/features/auth/presentation/screens/register_screen.dart` | 145 |
| 3 | `mobile/lib/features/auth/presentation/screens/forgot_screen.dart` | 100 |
| 4 | `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart` | 91 |
| 5 | `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` | 177 |
| 6 | `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart` | 99 |
| 7 | `mobile/lib/features/pairing/presentation/screens/paired_screen.dart` | 43 |
| 8 | `mobile/lib/features/account/presentation/screens/me_screen.dart` | 78 |
| 9 | `mobile/lib/features/account/presentation/screens/privacy_screen.dart` | 35 |
| 10 | `mobile/lib/features/account/presentation/screens/profile_edit_screen.dart` | 101 |
| 11 | `mobile/lib/features/account/presentation/screens/notification_settings_screen.dart` | 39 |
| 12 | `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart` | 53 |
| 13 | `mobile/lib/features/dream_jar/presentation/screens/dream_jar_detail_screen.dart` | 48 |
| 14 | `mobile/lib/features/dream_jar/presentation/screens/contribution_history_screen.dart` | 83 |
| 15 | `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart` | 66 |
| 16 | `mobile/lib/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart` | 197 |
| 17 | `mobile/lib/features/expenses/presentation/widgets/pairing_required_gate.dart` | 29 |
| 18 | `mobile/lib/features/anti_ghosting/presentation/screens/anti_ghost_screen.dart` | 66 |
| 19 | `mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart` | 138 |
| 20 | `mobile/lib/features/vibes/presentation/vibe_screen.dart` | 79 |
| 21 | `mobile/lib/features/pet/presentation/pet_screen.dart` | 56 |

Line numbers are at `BaseHead` 940773a; match on the `backgroundColor:
colors.colorBackground,` text, not the number.

Per file, after the deletion, check whether `final CupidColorTokens colors =
context.cupidColors;` (and its import) is now unused and remove it if so.
`flutter analyze` must be clean — do not leave an ignore comment.

Do not touch: `app_shell.dart` and `pair_gate_shell.dart` (already have no
override), `splash_screen.dart` (out of scope, paints its own full-bleed
gradient), `welcome_screen.dart` (no override; see the build-time check below).

### Phase 2 verification
- `flutter analyze` clean, `flutter test` full suite green.
- **AC4 evidence (required):** render Forgot Password and Waiting For Pairing
  in dark theme + `vi` and capture a screenshot of each. Both must visibly show
  the sky wash and the 3 twinkle stars. Forgot Password must additionally show
  the restyled CTA and header once Phase 3 has landed — if Phase 3 runs after
  Phase 2, recapture Forgot Password then.
- Build-time visual check: Welcome screen's own gradient still covers its frame.

---

## Phase 3 — `CupidPrimaryButton` and `CupidHeader` restyle (AC2, AC3, AC5)

Files (3):
1. `mobile/lib/design_system/adaptive/cupid_primary_button.dart`
2. `mobile/lib/design_system/adaptive/cupid_header.dart`
3. `mobile/test/design_system/adaptive_widgets_test.dart`

### 3.1 `cupid_primary_button.dart`

Public API (`label`, `onPressed`) is unchanged.

- Height: hoist `const double _primaryCtaHeight = 54;` next to the existing
  `_materialPrimaryCtaRadius`, with the same style of dartdoc citing the design
  source. Replace `height: platformTokens.tapTarget` with it on both platforms.
- Keep the `radius` fork exactly as-is (iOS `platformTokens.radiusButton`,
  Material `_materialPrimaryCtaRadius`). The UX spec is explicit that the radius
  is not part of this deviation.
- Wrap the `ElevatedButton` in a `DecoratedBox` with
  `BoxDecoration(gradient: colors.gradientHot, borderRadius:
  BorderRadius.circular(radius), boxShadow: colors.glowShadow)`.
- On the `ElevatedButton.styleFrom`: set `backgroundColor` and `shadowColor` to
  transparent, and `elevation: 0` on both platforms (the wrapper's `glowShadow`
  now provides depth; a residual Material elevation shadow would double up).
  Keep `foregroundColor: colors.colorText` and the existing `shape`.
- Label: `type.body.copyWith(fontSize: 16.5, fontWeight: FontWeight.w800,
  color: colors.colorText)`. Do not introduce a raw `#fff`.

Keep `ElevatedButton` and the outer `SizedBox` in the tree — see ADR-032c.
Reference `colors.gradientHot` by name only; do not edit the token (STORY-033
owns its axis).

### 3.2 `cupid_header.dart`

Both variants, per UX spec section 3 (the design source does not fork
opacity/blur by platform):

- `_MaterialHeader` (line 154): `backgroundColor: Colors.transparent`, and
  `flexibleSpace: ClipRect(child: BackdropFilter(filter:
  ImageFilter.blur(sigmaX: 16, sigmaY: 16), child: const SizedBox.expand()))`.
  Keep `AppBar`, `elevation: 0`, and `titleTextStyle` unchanged.
- `_MaterialHeader` back `IconButton` (line 168): `color` changes from
  `colors.colorText` to `colors.colorAccentPink`.
- `_IosHeader` (line 90): remove `color: colors.colorBackground` from the
  `Container` and wrap it in `ClipRect(child: BackdropFilter(filter:
  ImageFilter.blur(sigmaX: 16, sigmaY: 16), child: ...))`. Back chevron color is
  already correct.
- Both: pass `size: 26` to the back `Icon`. No tint or scrim over the blur — the
  source says literally `background: transparent`.

`ClipRect` is required on both; without it `BackdropFilter` blurs the whole
screen. `import 'dart:ui' show ImageFilter;`.

### 3.3 `adaptive_widgets_test.dart` (intentional update, AC5)

Existing assertions stay unmodified and must still pass — that is the point of
ADR-032c/d. **Add**:
- CTA outer `BoxDecoration.gradient == dark.gradientHot` and
  `.boxShadow == dark.glowShadow`.
- CTA `SizedBox` height `== 54` on both platforms.
- CTA label style `fontSize == 16.5`, `fontWeight == FontWeight.w800`.
- Material `AppBar.backgroundColor` is transparent and a `BackdropFilter` is
  present; Material back `IconButton.color == colors.colorAccentPink`.
- iOS header contains a `BackdropFilter` and no opaque `colorBackground` fill.

No existing assertion in the repo asserts the old flat `colorAccentPink` CTA
fill, the old opaque header color, or the old `colorText` back-icon color, so
nothing is being silently replaced — only added.

### Phase 3 verification
- `flutter analyze` clean, `flutter test` full suite green.
- Visual check of the CTA and header in dark theme + `vi`.

---

## Cross-phase required test edits (AC5)

`mobile/test/widget_test.dart:68` and `mobile/test/app/feature_flags_test.dart:78`
are the only two tests that pump the full `CupidApp`, and both call
`await tester.pumpAndSettle()` right after. Phase 1 adds a perpetual animation
at the composition root, which makes `pumpAndSettle` throw "timed out".

Replace each `await tester.pumpAndSettle();` with:

```dart
await tester.pump();
await tester.pump(const Duration(seconds: 1));
```

Both tests only need the `PairGateCubit` future to resolve before asserting on
`home_screen_ready_signal` / `MaterialApp`, so nothing else changes. This is an
intentional update driven by the new shared layer, called out here per AC5's
"intentionally updated rather than silently changed" requirement.

## Explicitly not in this plan

- `caption` text-style sub-13px regression — STORY-033.
- CTA gradient axis 120deg -> 95deg — STORY-033. This story consumes
  `gradientHot` by reference and does not edit it.
- Light theme / `en` locale user-facing QA — OQ5, out of scope. The light
  palette set exists in Phase 1 only so the layer is not wrong if the flag
  flips; it is not verified here.
- Splash screen, and re-verification of already-DONE Scope B screens other than
  Forgot Password and Waiting For Pairing.

## Gates

`flutter analyze` clean and the full `flutter test` suite green after each
phase. AC4 screenshot evidence for Forgot Password and Waiting For Pairing is
required before review.
