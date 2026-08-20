# STORY-060 Architecture: Contract Ambient Particle Dots (shared-shell fix)

Scope input: `requirements/requirements.md` AC2 (concrete), `ux/uiux-spec.md`
disposition "SHIP IT".

## TL;DR — the handoff's premise was wrong in the useful direction

The handoff asked me to design a new decorative overlay widget (3 positioned
dots + twinkle animation) and insert it at the shared shell layer.

**That widget already exists, and it is already mounted at the shared shell
layer.** Two of them, in fact. The real defect is a **paint-order** bug, not a
missing element. So the correct implementation is a Stack reorder in one shared
file, plus removal of the two per-screen workarounds that the bug forced
earlier stories to add.

This mirrors the STORY-052/058/059 precedent the handoff cited: the real path
differed from the handoff's guess.

## What already exists (verified in source)

| Concern | Real path |
| --- | --- |
| Shared shell background, mounted once via `MaterialApp.builder` | `mobile/lib/app/cupid_app.dart:58-59` → `CupidAppBackground` |
| Shared shell background widget | `mobile/lib/design_system/theme/cupid_app_background.dart` |
| Shell star layer (private) | `_CupidSkyStars` + `_twinklePhase`, same file, lines 136-214 |
| Star geometry/animation tokens, transcribed from the canvas source | `mobile/lib/design_system/tokens/cupid_sky_palette.dart:149-182` (`CupidSkyPalette.stars`) |
| A **second**, duplicate implementation of the same 3 dots | `mobile/lib/design_system/decorations/cupid_star_field.dart` (`CupidStarField`) |
| Preview/evidence harness, same mount point | `mobile/lib/main_preview.dart:1496-1500` |

`CupidSkyPalette.stars` is already an exact transcription of the canvas source
lines 44-47 the UX disposition cites: `left 8% / top 14% / 6px / #FFFFFF /
3400ms / delay 0`, `right 16% / top 9% / 4px / #FFD9EA / 4600ms / delay 800ms`,
`right 7% / top 26% / 5px / #CEB4FF / 5200ms / delay 1600ms`, with
`twinkleMinOpacity .25` → `twinkleMaxOpacity 1.0` and `twinkleMinScale .85` →
`twinkleMaxScale 1.15`, eased. **No new geometry, color, duration, or token is
needed by this story.** Do not re-derive these values.

## Root cause

`cupid_app_background.dart:72-79` builds:

```dart
Stack(
  fit: StackFit.expand,
  children: <Widget>[
    CustomPaint(painter: CupidSkyPainter(layers: layers)),
    _CupidSkyStars(elapsed: _elapsed),
    widget.child,          // <-- the whole Navigator, painted LAST = on top
  ],
)
```

In a Flutter `Stack` later children paint on top, so the star layer paints
**below** every route. In the canvas source the three dots are
`position:absolute` siblings authored *before* the screen body, and CSS paints
positioned elements **above** in-flow content — i.e. above each screen's own
opaque surfaces. `cupid_star_field.dart:10-13` already documents exactly this
CSS semantics; `cupid_app_background.dart`'s own dartdoc contradicts it by
calling the particles part of the wash "behind [child]".

For the `contract` screen this is fully determinative. `_LoveContractReadyBody`
(`love_contract_screen.dart:308-325`) renders a full-width opaque
`colors.colorSurface` card at `CupidSpacing.md` from the top of the body. On a
390x844 frame that card spans roughly `x 16..374, y 16..250`, and all three dot
centres (`≈(34,121)`, `≈(316,79)`, `≈(354,222)`) land inside it. The dots are
therefore drawn and then painted over — which is precisely the STORY-056 DEF-1
observation: present in the design reference, absent from the implementation
capture, with no `contract`-local markup difference to explain it.

Two earlier stories already hit this bug and worked around it per-screen rather
than fixing it, by mounting the duplicate `CupidStarField` as the last child of
their own backdrop `Stack`:

- `mobile/lib/features/auth/presentation/screens/welcome_screen.dart:176`
- `mobile/lib/features/vow/presentation/screens/vow_screen.dart:273-275`

`vow_screen.dart:273-274` states the reason in a comment: *"Last, not first: the
source's star particles are positioned siblings of the screen body, so CSS
paints them above it."* That is the shell-level invariant, applied at two
call sites instead of at the shell. `welcome_screen_test.dart:124` even asserts
in prose that "CupidAppBackground mounts a star layer above every route" —
which is not what the code does.

## Decision

**DEC-1 — Fix at the shell by paint order, not by adding a widget.**
Move `_CupidSkyStars` to be the **last** child of `CupidAppBackground`'s
`Stack`, above `widget.child`. This is the shared-screen-shell layer AC2
requires: `CupidAppBackground` is mounted exactly once, at the composition root
(`cupid_app.dart:58-59`) and at the evidence harness root
(`main_preview.dart:1496`), so one reorder covers `contract` and every other
screen with no per-screen fan-out. Rejected alternative: a `contract`-local
overlay — AC2 explicitly forbids it, and it would be the third copy of the same
workaround.

**DEC-2 — Keep `_CupidSkyStars`/`CupidSkyPalette` as the single implementation;
delete `CupidStarField`.** After DEC-1 the two per-screen `CupidStarField`
mounts become a second twinkle layer at identical coordinates with an
independent phase. Composited, at-rest opacity reads `1-(1-.25)^2 ≈ 0.44`
instead of `0.25`, with a mismatched scale halo — a new, self-inflicted fidelity
deviation on `welcome` and `vow`. Removing the two call sites leaves
`CupidStarField` with zero references, so the file and its
`design_system.dart:10` barrel export go too. The retained shell layer is
strictly better: it is driven by `CupidSkyPalette` tokens rather than hardcoded
literals, and it honours `MediaQuery.disableAnimations`
(`cupid_app_background.dart:42-54`), which `_TwinkleStar`'s bare `..repeat()`
does not. Rejected alternative: keep both and accept the doubling — it converts
this fidelity story into a fidelity regression on two other screens.

**DEC-3 — No platform split.** Unlike STORY-059's `CupidHeader`, there is no
Material/iOS branch to mirror here. `CupidAppBackground` has no `data-plat`
equivalent, and `cupid_sky_palette.dart:88-89` records the source-level reason:
the particles "are declared once in the source frame block, outside any
`[data-plat]` or theme branch, so they do not vary with platform or theme."
Verified: `_CupidSkyStars` and `CupidSkyPalette.stars` contain no
`CupidPlatform` reference. One code path serves both silhouettes.

**DEC-4 — No change to `main_preview.dart`.** The evidence harness mounts the
same `CupidAppBackground` at the same full-surface root, so the fix reaches the
`contract` capture for free. `main_preview.dart` is explicitly out of write
scope.

## Accepted consequence

With the star layer above the Navigator, the dots also paint over modal routes,
dialogs, and bottom sheets. This matches the source, where the dots are
absolute siblings of the whole frame, and the layer keeps its
`IgnorePointer`/`ExcludeSemantics` wrapper (`cupid_app_background.dart:143-145`)
so nothing under it loses taps or semantics. The dots sit at 9-26% of the
surface height, above the reach of `add_clause_sheet.dart`. Accepted as-is; do
not add a suppression mechanism for it.

## Write scope

Phase P1 (3 files):
- `mobile/lib/design_system/theme/cupid_app_background.dart`
- `mobile/test/design_system/cupid_app_background_test.dart`
- `mobile/test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart` (new, AC2)

Phase P2 (6 files):
- `mobile/lib/features/auth/presentation/screens/welcome_screen.dart`
- `mobile/lib/features/vow/presentation/screens/vow_screen.dart`
- `mobile/lib/design_system/decorations/cupid_star_field.dart` (delete)
- `mobile/lib/design_system/design_system.dart`
- `mobile/test/features/auth/presentation/screens/welcome_screen_test.dart`
- `mobile/test/features/vow/presentation/screens/vow_screen_test.dart`

## Explicitly forbidden

- `mobile/lib/features/expenses/presentation/screens/expense_history_screen.dart`
- `mobile/lib/features/gallery/presentation/widgets/gallery_empty_view.dart`
- `mobile/lib/features/love_contracts/**` production code — the fix is
  shell-level; the `contract` screen gets **no** code change, only a test.
- `mobile/lib/main_preview.dart` (DEC-4)
- `mobile/lib/design_system/tokens/cupid_sky_palette.dart` — the values are
  already correct; touching them is out of scope.
- Any other screen file. The only two screen files in scope
  (`welcome_screen.dart`, `vow_screen.dart`) are touched **solely to delete the
  redundant workaround the shell fix supersedes** (DEC-2), never to add
  rendering.

## AC mapping

- **AC2** (`contract` screen renders the three ambient dots, matching
  `design-reference-contract-myunsigned-android.png`, evidence scoped to screen
  id `contract`): P1 code change + P1's new `contract`-scoped pixel-probe test +
  mobile-dev's fresh `contract` implemented-state capture.
- AC1 and AC3 are already settled by `ux/uiux-spec.md`; no implementation work.
