# P2 — Consolidate the duplicate star implementation

Lane: mobile-dev
Depends on: P1 (must be complete and green first)

Why this phase exists: P1 makes the shell star layer paint above every route,
so the two per-screen `CupidStarField` mounts become a **second** twinkle layer
at identical coordinates with an independent phase. Composited, at-rest opacity
reads `≈0.44` instead of `0.25`, with a mismatched scale halo — a new fidelity
deviation on `welcome` and `vow` caused by this story. See
`../architecture/solution.md` DEC-2.

## Write Scope

- `mobile/lib/features/auth/presentation/screens/welcome_screen.dart`
- `mobile/lib/features/vow/presentation/screens/vow_screen.dart`
- `mobile/lib/design_system/decorations/cupid_star_field.dart` (delete)
- `mobile/lib/design_system/design_system.dart`
- `mobile/test/features/auth/presentation/screens/welcome_screen_test.dart`
- `mobile/test/features/vow/presentation/screens/vow_screen_test.dart`

`welcome_screen.dart` and `vow_screen.dart` are in scope **only** to delete the
redundant workaround. Do not change their layout, gradients, spacing, copy, or
any other rendering.

## Step 1 — remove the two call sites

- `welcome_screen.dart:176`: delete the `const Positioned.fill(child:
  CupidStarField())` entry from its `Stack.children`.
- `vow_screen.dart:273-275`: delete the same entry and the two-line comment
  above it ("Last, not first: …"). That comment's invariant now lives on
  `CupidAppBackground`'s dartdoc, where P1 put it.

In both files, drop the `CupidStarField` import if it was imported directly
rather than through the `design_system.dart` barrel; if the barrel import is
still used for other symbols, leave the import line alone.

Check whether the enclosing `Stack` still has more than one child after the
removal. If a `Stack` is left with a single child, leave the `Stack` in place —
collapsing it is a layout change and is out of scope.

## Step 2 — delete the widget and its export

- Delete `mobile/lib/design_system/decorations/cupid_star_field.dart` entirely
  (`CupidStarField` and the private `_TwinkleStar`/`_TwinkleStarState`).
- Remove `export 'decorations/cupid_star_field.dart';` from
  `mobile/lib/design_system/design_system.dart:10`.
- If `lib/design_system/decorations/` is then empty, leave the empty directory
  alone; git will not track it.

Before deleting, re-grep for `CupidStarField` across `mobile/` to confirm the
only remaining references are the two test files handled in Step 3. If anything
else references it, **stop and report** rather than widening scope.

## Step 3 — re-point the two tests at the shell layer

Both tests assert an AC from an earlier story ("the shared twinkle star field
paints over the screen"). The AC is still true after this story — it is now
delivered by the shell instead of by the screen — so re-point the assertions;
do not delete the tests.

`welcome_screen_test.dart:116-152` and `vow_screen_test.dart:144-165`:

- Wrap the existing `_harness()` output so `CupidAppBackground` is mounted
  through the host `MaterialApp`'s `builder`, matching the production
  composition root (`cupid_app.dart:58-59`). If `_harness()` already builds a
  `MaterialApp`, add the `builder`; if it builds a bare widget, wrap it. Keep
  every other harness parameter identical so the other tests in each file keep
  passing unchanged.
- Replace `expect(find.byType(CupidStarField), findsOneWidget)` with a
  behavioural assertion equivalent to P1's: pump to the first
  `CupidSkyPalette.stars` entry's 1700ms peak and probe that the star's centre
  pixel reads near-white over the screen's own backdrop. Reuse the same probe
  helper shape as P1's tests.
- Keep the `pointer-events:none` intent. `find.byType(IgnorePointer)` scoped
  under `CupidStarField` no longer resolves; assert instead that a tap landing
  on the star's centre still reaches the widget underneath — the same technique
  as `cupid_app_background_test.dart:101-130` ("never intercepts a tap landing
  on a star"). On `vow` that underlying target is the hold affordance
  (`Key('vow_hold_target')`); on `welcome` use whichever CTA the existing test
  file already has a finder for.
- Delete the now-false comment at `welcome_screen_test.dart:124-127` ("welcome
  paints a full-bleed opaque gradient that occludes it, so the screen has to
  carry its own copy"). Do not replace it with a paragraph — the assertions
  say it.

`welcome_screen_test.dart` and `vow_screen_test.dart` currently avoid
`pumpAndSettle` because `_TwinkleStar`'s bare `..repeat()` never settles. The
shell layer parks its ticker under `MediaQuery.disableAnimations`, so other
tests in these files may now settle — but do not convert them; that is an
unrelated cleanup.

## Verification

```
cd mobile && flutter analyze lib/design_system lib/features/auth/presentation/screens/welcome_screen.dart lib/features/vow/presentation/screens/vow_screen.dart test/features/auth/presentation/screens/welcome_screen_test.dart test/features/vow/presentation/screens/vow_screen_test.dart
cd mobile && flutter test test/features/auth/presentation/screens/welcome_screen_test.dart test/features/vow/presentation/screens/vow_screen_test.dart test/design_system/cupid_app_background_test.dart test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart
```

Analyzing the whole `lib/design_system` directory (not just the touched files)
is deliberate: it is what catches a dangling barrel export or a stale import
after the deletion.

## Completion

Append the analyze/test output to `coding-plan/test-results.md`, then capture
the visual-fidelity evidence AC2 owes, per `master-plan.md` — a fresh
`contract` implemented-state PNG diffed against the existing byte-locked design
reference. Do not re-render the design reference.
