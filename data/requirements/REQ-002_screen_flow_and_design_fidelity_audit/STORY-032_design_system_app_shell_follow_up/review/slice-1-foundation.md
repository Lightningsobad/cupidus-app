# STORY-032 Review — Slice 1 of 4: `phase1-foundation`

Review type: `scoped-slice` (Tier-3). Slice verdict only; the story-level
`Outcome:` belongs to the Final Synthesis pass.

Slice AC scope: AC1 only — shared app-shell background layer.
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-002_screen_flow_and_design_fidelity_audit-STORY-032`
BaseHead: `079d4801831037e2540a813f66efe5e4258eaae4`

## Slice Verdict

**PASS with one coverage note.** No blocking finding. Nothing here should hold
the story; N-1 below is a traceability item the Final Synthesis pass must
resolve against slice 2/4 evidence, not new rework.

## Files In Scope (diffed against BaseHead)

| File | Change | Verdict |
| --- | --- | --- |
| `mobile/lib/design_system/tokens/cupid_sky_palette.dart` | new, +183 | PASS |
| `mobile/lib/design_system/theme/cupid_app_background.dart` | new, +214 | PASS |
| `mobile/lib/design_system/design_system.dart` | +2 barrel exports | PASS |
| `mobile/lib/design_system/theme/cupid_theme.dart` | +3 -1 | PASS |
| `mobile/lib/app/cupid_app.dart` | +3 -2 | PASS |
| `mobile/test/design_system/cupid_app_background_test.dart` | new, +161 | PASS |
| `mobile/test/widget_test.dart` | +5 -1 | PASS |
| `mobile/test/app/feature_flags_test.dart` | +5 -1 | PASS |

## AC1 Traceability

AC1: any screen that should inherit the shared background shows
`CupidColorTokens.skyGradient`'s purple/magenta radial wash and star particles,
not a flat `colorBackground` fill.

| AC1 sub-claim | Evidence | Verdict |
| --- | --- | --- |
| Wash values are `skyGradient`, not an invented approximation | All 6 layers (3 dark + 3 light) in `cupid_sky_palette.dart:92-146` transcribe `cupid_color_tokens.dart:66-70` / `:130-134` exactly — radii, centers, RGBA and end stops all match the CSS string value-for-value | PASS |
| CSS semantics preserved | `radial-gradient(120% 70% at ...)` is explicit-size syntax: the pair is the ellipse's X/Y *radius*, X as a fraction of width and Y of height. `CupidSkyPainter.paint` (`cupid_app_background.dart:98-125`) applies exactly that, and scales about the layer center to turn the radius-X circle into the X/Y ellipse | PASS |
| Fades to the layer's own RGB at zero alpha | `:117-119` uses `layer.color.withAlpha(0)`, explicitly not `Colors.transparent` — this is the correct call; fading through transparent *black* would leave a dark halo | PASS |
| Star particles rendered | 3 particles from `CupidSkyPalette.stars` (`:149-174`), each with its own period/delay/placement, phase derived from a shared monotonic ticker (`:202-212`) | PASS |
| Reaches every screen via a shared layer, no per-screen fork | `cupid_app.dart:43-44` mounts `CupidAppBackground` through `MaterialApp.builder`, which wraps the Navigator — above every route, so pre-pairing (`login`/`register`/`OTP`/`forgot-password`, each its own `Scaffold`) and post-pairing (`app_shell.dart` tabs) are both covered by construction. This is In-Scope item 1's explicit requirement | PASS |
| Screens do not occlude it | `cupid_theme.dart:45` sets `scaffoldBackgroundColor: Colors.transparent`. Verified no other consumer depends on that token being opaque: repo-wide it now has exactly two references, the theme assignment and the doc comment in `cupid_app_background.dart:17` | PASS |
| Star layer is decorative only | `ExcludeSemantics` + `IgnorePointer` + `RepaintBoundary` (`:143-145`); the tap-through test at `cupid_app_background_test.dart:101-133` proves a tap landing on a star still reaches the screen below | PASS |
| Reduce-motion honored | `didChangeDependencies` (`:42-54`) stops the ticker and resets elapsed on `MediaQuery.disableAnimations`, holding the stars at rest; asserted at `cupid_app_background_test.dart:73-86` including `transientCallbackCount == 0` | PASS |

## Test Evidence

`coding-plan/test-results.md` "Phase 1" records no command of its own
("Verified in its own dispatch"), deferring to the full-suite runs under
Phase 2/3. I reran the slice scope directly to confirm the claim rather than
accept the deferral:

`flutter test test/design_system/cupid_app_background_test.dart test/widget_test.dart test/app/feature_flags_test.dart`
— `+11: All tests passed!` Worktree clean afterwards (`git status --porcelain`
empty).

Quality note: `cupid_app_background_test.dart:135-160` is a real rasterized
pixel assertion via `RenderRepaintBoundary.toImage`, not a widget-tree shape
check — it proves the wash actually paints over the flat `0xFF171129` fill.
That is the right kind of evidence for this AC.

## Findings

**N-1 (non-blocking, traceability — for Final Synthesis).** No automated test
asserts the composition-root wiring. `CupidAppBackground` is exercised only in
the synthetic host of `cupid_app_background_test.dart`; nothing asserts that
booting `CupidApp` mounts it through `MaterialApp.builder`. The wiring is one
line (`cupid_app.dart:43-44`) and is correct as written, but "the shared layer
is not an unconsumed abstraction" is precisely the failure AC4 exists to catch.
Final Synthesis should confirm the slice 2/4 rendered `visual-fidelity/`
evidence genuinely shows the wash on the two named screens; if it does, AC1 is
covered end to end and no code change is needed. A single
`expect(find.byType(CupidAppBackground), findsOneWidget)` in `widget_test.dart`
would close the gap permanently at near-zero cost — worth recording as a
follow-up, not as rework.

**N-2 (observation, no action).** The root ticker runs continuously by design
(the source's twinkle animation has no end), so no tree containing `CupidApp`
ever settles and `pumpAndSettle` hangs on it. Both affected tests were switched
to explicit `pump` calls with an inline comment stating why. Under AC5 this
counts as called out rather than silently changed — the callouts live in
`story_master.md`'s Phase 1 bullet and in the test files themselves, though not
in the "One intentional test update" section of `test-results.md`, which names
only the Phase 3 anti-ghosting edit. Any future test booting `CupidApp` inherits
this constraint.

**N-3 (observation, no action).** `CupidSkyPainter.shouldRepaint` compares
`layers` by list identity and `CupidSkyLayer` defines no `==`. That is correct
for the only two callers (the `darkLayers`/`lightLayers` const statics, distinct
identities, so a brightness flip repaints) but would silently skip a repaint if
someone later passed an equal-but-newly-built list. Not reachable today.

## Out Of Slice

Not read, not reviewed, not judged here: all Phase 2 screen files, Phase 3
`cupid_primary_button.dart` / `cupid_header.dart` / `adaptive_widgets_test.dart`,
and the `visual-fidelity/` AC4 evidence. AC2, AC3, AC4 and AC5 belong to slices
2-4.

SLICE_VERDICT: PASS
