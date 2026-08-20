# STORY-060 — Test Results

Toolchain: Flutter SDK at `~/flutter` (`flutter analyze` / `flutter test`),
run from `mobile/`.

## P1 — Shell particle paint order + `contract` AC2 conformance test

Files changed:

- `mobile/lib/design_system/theme/cupid_app_background.dart` — `_CupidSkyStars`
  moved from the middle of the `Stack.children` to last, after `widget.child`;
  class dartdoc corrected to state that the wash paints behind the child and the
  particles above it.
- `mobile/test/design_system/cupid_app_background_test.dart` — added
  `paints the twinkle stars above the child, not behind it`.
- `mobile/test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart`
  (new) — `AC2: the contract screen paints the three ambient particle dots above
  its own card`.

### Which star the AC2 probe uses

P1 Step 3 allows switching to another `CupidSkyPalette.stars` entry when the
first star's control assertion does not hold. It does not hold here, so the
AC2 test probes **star index 1** (`rightFactor 0.16`, `topFactor 0.09`,
`size 4`, `#FFD9EA`, `period 4600ms`, `delay 800ms`), pumped to its own twinkle
peak at `delay + period / 2` = **3100ms**.

Reason, from a 121-pixel horizontal scan at each star's centre row on the
390x844 frame (probe run, since removed):

| Star | Centre | Centre pixel | Control at `+40px` |
| --- | --- | --- | --- |
| 0 (`#FFFFFF`) | `(34.2, 121.2)` | `ffffffff` (the dot) | `fff7eefb` — the card's own near-white `display` title text |
| 1 (`#FFD9EA`) | `(325.6, 78.0)` | `ff9e82a3` at 1700ms, near-white at its 3100ms peak | `ff402f60` — the card header gradient, uniform for 60px in both directions |
| 2 (`#CEB4FF`) | `(360.2, 221.9)` | `ffbbaada` (the dot) | `ffb4a6ce` — a near-white clause-row element |

Stars 0 and 2 sit over near-white card content, so their controls cannot
separate "the card is painted here" from "the dot is". Star 1 sits over the
card's flat header gradient, so its control is unambiguous. The probe
coordinate was not nudged; the star was switched, per P1 Step 3.

The control assertion was tightened from "not near-white" to "all three
channels below 0.5", which is the same claim stated against the actual header
gradient value.

### Pre-fix failure check

Both new tests were run against the original `Stack` order to confirm they are
real regression pins rather than tautologies:

```
00:00 +6 -2: Some tests failed.

Failing tests:
  test/design_system/cupid_app_background_test.dart: paints the twinkle stars above the child, not behind it
    Expected: a value greater than <0.5>
      Actual: <0.0>
  test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart: AC2: the contract screen paints the three ambient particle dots above its own card
    Expected: a value greater than <0.7>
      Actual: <0.2549019607843137>
```

The fix was then restored and the verification below was run.

### Analyze

```
$ cd mobile && flutter analyze lib/design_system/theme/cupid_app_background.dart test/design_system/cupid_app_background_test.dart test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart
Analyzing 3 items...
No issues found! (ran in 1.8s)
```

### Test

```
$ cd mobile && flutter test test/design_system/cupid_app_background_test.dart test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart test/design_system/shared_backdrop_occlusion_test.dart
00:00 +0: test/design_system/cupid_app_background_test.dart: renders its child
00:00 +1: .../love_contract_particle_dots_test.dart: AC2: the contract screen paints the three ambient particle dots above its own card
00:00 +8: test/design_system/shared_backdrop_occlusion_test.dart: AC2: otp shows the shared sky wash, not a solid fill
00:00 +9: test/design_system/shared_backdrop_occlusion_test.dart: AC3: contract shows the shared sky wash, not a solid fill
00:00 +10: test/design_system/shared_backdrop_occlusion_test.dart: AC4: profile setup shows the shared sky wash, not a solid fill
00:00 +11: test/design_system/shared_backdrop_occlusion_test.dart: AC5: permissions shows the shared sky wash, not a solid fill
00:00 +12: test/design_system/shared_backdrop_occlusion_test.dart: AC6: joincode shows the shared sky wash, not a solid fill
00:01 +13: test/design_system/shared_backdrop_occlusion_test.dart: AC7: vow shows the shared sky wash, not a solid fill
00:01 +14: All tests passed!
```

**P1: 14 passed, 0 failed.**

Regression guard result: `shared_backdrop_occlusion_test.dart` is unchanged and
all 6 of its screen probes still pass, including `AC3: contract`. Its `(120, 10)`
wash probe is far from all three star centres, so the reorder did not move it.

The three pre-existing `cupid_app_background_test.dart` star tests were left
untouched and all pass, including `never intercepts a tap landing on a star` —
that `IgnorePointer` guarantee is only meaningful now that the star layer sits
above the tap target.

## P2 — Retire the per-screen `CupidStarField` duplicate

Files changed:

- `mobile/lib/features/auth/presentation/screens/welcome_screen.dart` — removed
  the `Positioned.fill(child: CupidStarField())` child and its now-false comment
  from the backdrop `Stack`.
- `mobile/lib/features/vow/presentation/screens/vow_screen.dart` — same removal.
- `mobile/lib/design_system/design_system.dart` — removed the
  `decorations/cupid_star_field.dart` export.
- `mobile/lib/design_system/decorations/cupid_star_field.dart` — deleted
  (`git rm`); it had no remaining reference.
- `mobile/test/features/auth/presentation/screens/welcome_screen_test.dart` and
  `mobile/test/features/vow/presentation/screens/vow_screen_test.dart` — the
  star tests re-pointed from the deleted per-screen widget onto the shared shell
  layer, as pixel probes.

No file outside P2's Write Scope was touched. `love_contracts` production code,
`cupid_sky_palette.dart`, and `main_preview.dart` were not modified by either
phase.

### Which star the re-pointed probes use

Both re-pointed probes use **star index 1** at its 3100ms peak, for the same
reason P1's AC2 probe does. Measured controls at `+40px`:

| Screen | Star 0 control | Star 1 control | Chosen |
| --- | --- | --- | --- |
| welcome (800x600) | `f7eefb` — the screen's own near-white logo block | brand backdrop gradient, flat | 1 |
| vow (390x844) | near-white header copy | flat backdrop | 1 |

The welcome case is the reason all four probes assert
`closeTo(star.color.<channel>, 0.02)` against the token rather than a
"near-white" threshold. At star 0 the surrounding pixels read `f7eefb`
(r `0.968` / g `0.933` / b `0.984`), so a `> 0.9` threshold assertion would have
**passed even with the pre-fix ordering** — a false pass, found and removed
before the test was accepted.

### Pre-fix failure check

The paint order was reversed a second time and both re-pointed suites run. Both
star tests failed on their `onStar` assertion: the probe pixel read the screen's
own backdrop instead of the star token colour. The fix was then restored.

### Layout note — welcome probe surface

The welcome probe pins the suite's existing `Size(800, 600)` frame rather than a
phone frame. At 390pt, welcome's CTA `Row` (`welcome_screen.dart:413`) reports
`RenderFlex overflowed by 33 pixels`. That is a pre-existing characteristic of
that screen, unrelated to and untouched by this story; the probe simply does not
adopt a frame that triggers it. vow and contract both probe at `Size(390, 844)`.

### Analyze

```
$ cd mobile && flutter analyze lib/design_system lib/features/auth/presentation/screens/welcome_screen.dart lib/features/vow/presentation/screens/vow_screen.dart test/features/auth/presentation/screens/welcome_screen_test.dart test/features/vow/presentation/screens/vow_screen_test.dart
Analyzing 5 items...
No issues found! (ran in 1.6s)
```

One issue was found and fixed on the way here: `unnecessary_import` for
`package:flutter/gestures.dart` in both re-pointed test files, superseded by
`package:flutter/rendering.dart`.

### Test

```
$ cd mobile && flutter test test/features/auth/presentation/screens/welcome_screen_test.dart test/features/vow/presentation/screens/vow_screen_test.dart test/design_system/cupid_app_background_test.dart test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart
00:01 +25: All tests passed!
```

**P2: 25 passed, 0 failed.**

### Full-suite regression run

P1 moves a layer above every route in the app, so the scoped runs above are not
sufficient evidence on their own.

```
$ cd mobile && flutter test
01:18 +1319 ~2: All tests passed!
```

**1319 passed, 2 skipped, 0 failed.** STORY-057 recorded 1314 passed / 2
skipped; the `+5` delta is exactly this story's added and re-pointed tests. No
pre-existing test regressed.

## Entry Point Reachability

Reachable: YES

This story adds no new capability, screen, route, or user-facing surface. The
`contract` screen it affects is a pre-existing entry point, reached unchanged by
this story:

| Surface | Entry point | Added by this story? |
| --- | --- | --- |
| `contract` (Love Contract) | Existing in-app route to the Love Contract screen, reachable from the shipped `lib/main.dart` navigation as before this story | No — pre-existing |
| `contract` preview capture | `lib/main_preview.dart` with `--dart-define=PREVIEW=contract`, the STORY-049 fixture, used as-is | No — pre-existing, unmodified |

The fix is entirely at the shared shell (`CupidAppBackground`), which was
already mounted at `MaterialApp.builder` for every route. No navigation, route
table, deep link, or menu entry was added, removed, or re-pointed, so there is
no new path a user must be able to reach. `mobile/lib/features/love_contracts/`
has zero production diff.

## Story Runtime Startup Smoke

The first attempt was blocked: nothing listened on the devstack-pinned API port
and a stale pre-shared-infra process held the framework default `:3000`. DevOps
killed the stale process and restarted the service correctly.

Re-verified here:

```
$ curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:21020/api-docs-json
200
$ lsof -nP -iTCP:21020 -sTCP:LISTEN
node    99586 alantravala   16u  IPv6 …  TCP *:21020 (LISTEN)
```

Then, scoped to the impacted app only:

```
$ cd mobile && flutter build apk --debug
✓ Built build/app/outputs/flutter-apk/app-debug.apk
```

Installed and launched on the already-running `emulator-5560` (no device was
created, booted, wiped, or resized). After 30 s the process was still alive
(`PID=27929`), the activity was resumed, and `adb logcat -d -b crash` was empty.

Scoped suites were re-run once more at this point, all five files together:

```
$ cd mobile && flutter test test/design_system/cupid_app_background_test.dart test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart test/features/auth/presentation/screens/welcome_screen_test.dart test/features/vow/presentation/screens/vow_screen_test.dart test/design_system/shared_backdrop_occlusion_test.dart
00:02 +31: All tests passed!
```

**31 passed, 0 failed.**

Toolchain note for future lanes: `~/flutter/bin` is not on the default `PATH` of
the shell this session's tooling starts, so a bare `flutter …` invocation exits
`127 command not found`. Every command above was run with that directory
prepended to `PATH` for the duration of the command.
