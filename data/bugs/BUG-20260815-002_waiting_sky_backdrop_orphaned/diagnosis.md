# Diagnosis: BUG-20260815-002 Waiting Screen `_SkyBackdrop` Orphaned After STORY-032 Supersede

Bug id: BUG-20260815-002_waiting_sky_backdrop_orphaned
Owner: bug-fixer (Justin-BugFixer)
Work location: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`

## Pre-Fix Reproduction Gate

Modality: static analysis (for the reported analyzer warning) + test execution
(for the reported RED regression tests). Both are the reported failures' native
modalities.

### Anchor 1 — analyzer warning: REPRODUCED

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter analyze lib test
```

Expected result (bug present): exactly one `warning` severity diagnostic, an
unreferenced `_SkyBackdrop` at `waiting_screen.dart:337`.

Actual result (exit 1, `81 issues found`):
```
warning • The declaration '_SkyBackdrop' isn't referenced. Try removing the
declaration of '_SkyBackdrop' • lib/features/pairing/presentation/screens/waiting_screen.dart:337:7 • unused_element
```
All 80 other diagnostics are `info` severity (`prefer_initializing_formals`,
one `deprecated_member_use`), so this is the branch's only warning, exactly as
reported.

Result: REPRODUCED — line and element match the report exactly.

### Anchor 2 — RED regression test(s): REPRODUCED (1 of the 2 reported)

Command:
```
cd /Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/mobile
/Users/alantravala/flutter/bin/flutter test --reporter failures-only \
  test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart \
  test/features/pairing/presentation/waiting_screen_test.dart
```

Actual result: `+10 -2: Some tests failed.` (exit 1). Both failures are in
`waiting_screen_design_fidelity_test.dart`:

| # | Test | Line | Failure | Belongs to |
| --- | --- | --- | --- | --- |
| 1 | `paints the --sky wash and twinkle stars over --bg` | `:134` | `Found 0 widgets with key [<'waiting_sky_backdrop'>]` | **This bug** |
| 2 | `applies the design source typography and muted subtitle` | `:238` | `Expected: <13> Actual: <11.5>` | `BUG-20260814-003` (caption typography token mismatch — that bug's registry row names `waiting_screen_design_fidelity_test.dart:238` verbatim) |

Result: REPRODUCED for failure #1, the failure this bug describes.

Scope correction to the bug report: the report and checkpoint say "2 STORY-013
regression tests RED". Both RED tests do live in the STORY-013 design-fidelity
file, but only one of them is caused by the orphaned `_SkyBackdrop`. The other
is the already-queued caption-typography defect `BUG-20260814-003`, whose
registry row names this exact file and line. Fixing `_SkyBackdrop` cannot and
should not turn `:238` green; that failure stays RED for `BUG-20260814-003` to
own. This bug's scope is therefore 1 RED test + 1 analyzer warning.

Confirmed dead: `git grep -n "_SkyBackdrop" -- mobile` returns only the
declaration itself (`waiting_screen.dart:337`, `:338`) — no call site anywhere
in `lib/` or `test/`.

`git grep -n "waiting_sky_backdrop" -- mobile` returns exactly two hits:
`waiting_screen.dart:348` (the key, inside the dead `_SkyBackdrop` body) and
`waiting_screen_design_fidelity_test.dart:133` (the finder). The key is
therefore only reachable through the orphaned widget.

## Root Cause

STORY-013 painted the design source's root-frame sky **inside the waiting
screen**: `_SkyBackdrop` stacked three `RadialGradient` washes (via a bespoke
`_CssEllipse` `GradientTransform`) plus three `_TwinkleStar` particles, and the
screen's `Scaffold` carried an opaque `colorBackground` fill beneath it.

STORY-032 moved that same paint job up to the composition root:
`cupid_app.dart:58-59` mounts `CupidAppBackground` through `MaterialApp.builder`
so one instance sits above every route, and `cupid_theme.dart:43-45` sets
`scaffoldBackgroundColor: Colors.transparent` with the explicit comment "an
opaque scaffold here would occlude its sky wash".

STORY-032 correctly detached the waiting screen's `_SkyBackdrop` call site and
correctly dropped the screen's opaque `Scaffold` fill (`waiting_screen.dart:119`
is a bare `Scaffold(body: …)` with no `backgroundColor`), but it left behind
both the now-unreachable declaration and the STORY-013 test that asserts against
it. That is the whole defect: dead code plus a stale test, not a rendering
regression.

## Delete-and-Retarget vs. Restore — Evidence

Verdict: **(a) delete and retarget.** `CupidAppBackground` preserves STORY-013's
visual intent exactly; it does not approximate it.

`CupidSkyPalette` (`mobile/lib/design_system/tokens/cupid_sky_palette.dart`) is
a value-for-value transcription of what `_SkyBackdrop` painted:

| Layer | `_SkyBackdrop` (`waiting_screen.dart`) | `CupidSkyPalette.darkLayers` | Match |
| --- | --- | --- | --- |
| purple | `rgba(123,47,190,.55)`, stops `[0, .62]`, ellipse `1.2 x 0.7` at `(.15, -.08)` | same color, `endStop .62`, `radiusXFactor 1.20`, `radiusYFactor 0.70`, center `(.15, -.08)` | exact |
| magenta | `rgba(255,75,140,.32)`, stops `[0, .6]`, ellipse `0.9 x 0.55` at `(.95, .06)` | same color, `endStop .60`, `0.90 x 0.55`, center `(.95, .06)` | exact |
| teal | `rgba(0,201,167,.16)`, stops `[0, .62]`, ellipse `0.8 x 0.5` at `(.5, 1.08)` | same color, `endStop .62`, `0.80 x 0.50`, center `(.50, 1.08)` | exact |

| Star | `_SkyBackdrop` | `CupidSkyPalette.stars` | Match |
| --- | --- | --- | --- |
| 1 | `top 14%`, `left 8%`, ⌀6, `rgb(255,255,255)`, period 3400ms, no delay | `topFactor .14`, `leftFactor .08`, `size 6`, `0xFFFFFFFF`, 3400ms, `Duration.zero` | exact |
| 2 | `top 9%`, `right 16%`, ⌀4, `rgb(255,217,234)`, period 4600ms, phase `0.8/4.6` | `topFactor .09`, `rightFactor .16`, `size 4`, `0xFFD9EA`, 4600ms, delay 800ms | exact |
| 3 | `top 26%`, `right 7%`, ⌀5, `rgb(206,180,255)`, period 5200ms, phase `1.6/5.2` | `topFactor .26`, `rightFactor .07`, `size 5`, `0xCEB4FF`, 5200ms, delay 1600ms | exact |

Twinkle curve also matches: `_TwinkleStarState` ran `opacity 0.25 + 0.75·eased`
and `scale 0.85 + 0.3·eased` through `Curves.easeInOut`; `CupidSkyPalette`
declares `twinkleMinOpacity .25` / `twinkleMaxOpacity 1.0` /
`twinkleMinScale .85` / `twinkleMaxScale 1.15`, applied with `Curves.easeInOut`
in `cupid_app_background.dart:212`.

The successor is additionally a strict improvement on two axes `_SkyBackdrop`
never covered: it selects `lightLayers` under a light theme (`_SkyBackdrop`
hardcoded the dark values only) and it honours `disableAnimations` by holding
the stars at rest.

There is therefore no visual intent left for a restored `_SkyBackdrop` to
carry, and restoring it would double-paint the sky on this one screen.

## Fix Strategy

1. Delete the dead subtree from `waiting_screen.dart`. `_SkyBackdrop` is not
   the only orphan — it was the sole consumer of `_CssEllipse`,
   `_skyPurpleWash`, `_skyMagentaWash`, `_skyTealWash`, `_TwinkleStar` and
   `_TwinkleStarState`, all private to the file. Removing only the element the
   analyzer named would have produced six new `unused_element` warnings on the
   next run, so the whole subtree goes (former lines 244-461). The identically
   named `_TwinkleStar` in
   `mobile/lib/design_system/decorations/cupid_star_field.dart` is a separate,
   live private class and is untouched.
2. Retarget the STORY-013 regression test. Its harness composed
   `MaterialApp(home: WaitingScreen(...))`, which never mounts
   `CupidAppBackground` — so it could not see the successor at all. The harness
   now mirrors `cupid_app.dart:58-59` with
   `builder: (context, child) => CupidAppBackground(child: …)`, and the test
   asserts what is still this screen's responsibility: the sky reaches it, and
   it does not paint over it.

### Coverage Mapping — nothing silently dropped

Every assertion the old test made is either retained or has a named new owner:

| STORY-013 assertion | Where it lives now |
| --- | --- |
| `waiting_sky_backdrop` key present | Replaced by `CupidSkyPainter` present in the waiting screen's composed tree with `layers` identical to `CupidSkyPalette.darkLayers` |
| `Scaffold.backgroundColor == colorBackground` | Replaced by the non-occlusion pair: screen sets no `backgroundColor`, and the effective theme `scaffoldBackgroundColor` has alpha 0. The flat `colorBackground` fill is now painted by `CupidAppBackground` and pinned by `cupid_app_background_test.dart` → "paints the wash over the flat background fill" (asserts `0xFF171129`) |
| 3 wash colors / stops / non-null transform / fade-to-own-hue | `CupidSkyPalette.darkLayers` + `cupid_app_background_test.dart` → "selects the sky layer set from the theme brightness"; the fade-to-own-hue rule is now enforced in `CupidSkyPainter.paint` (`layer.color.withAlpha(0)`) |
| 3 star fill colors | **Retained** in the retargeted test, asserted through `CupidSkyPalette.stars` instead of re-forked RGB literals |
| Star positions at 14%/8%, 9%/16%, 26%/7% | `CupidSkyPalette.stars` factors, exercised at real geometry by `cupid_app_background_test.dart` → "never intercepts a tap landing on a star" |
| Twinkle `0.25 → 0.625` over 850ms | `cupid_app_background_test.dart` → "holds the stars at rest…" and "twinkles the stars when animations are enabled" |

Star geometry and twinkle timing are deliberately not re-asserted here: they are
`CupidSkyPalette` values with a design-system owner, and duplicating the
literals in a feature test would re-create exactly the design-source fork
STORY-032 removed.

## Changed Files

| File | Change |
| --- | --- |
| `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart` | Removed the orphaned `_SkyBackdrop` and its exclusive helpers `_CssEllipse`, `_skyPurpleWash`, `_skyMagentaWash`, `_skyTealWash`, `_TwinkleStar`, `_TwinkleStarState` (218 lines deleted, 0 added). |
| `mobile/test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart` | Harness mounts `CupidAppBackground` via `MaterialApp.builder` as the app does; the sky test is retargeted to the design-system successor. |

2 files, `32 insertions(+), 300 deletions(-)`. No new files, no design-system
changes, no product behavior change.

## Not In Scope

- The second RED test in the same file (`:188`, caption size `13` vs `11.5`) —
  owned by `BUG-20260814-003`, still RED by design after this fix.
- `widget_test.dart` / `feature_flags_test.dart` `home_screen_ready_signal`
  failures — owned by `BUG-20260814-002`.
- `CupidAppBackground`, `CupidSkyPalette`, `CupidSkyPainter` and
  `cupid_app_background_test.dart` are read-only reference here; none were
  modified.
- The `Scaffold`'s `body: Stack(...)` in `waiting_screen.dart:120` is left as
  STORY-032 shaped it; it is not part of the reported defect.
