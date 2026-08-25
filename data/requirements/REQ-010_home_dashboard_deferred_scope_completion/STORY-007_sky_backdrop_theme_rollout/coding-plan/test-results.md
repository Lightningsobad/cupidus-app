# STORY-007 Test Results — Sky Backdrop Theme Rollout

Lane: mobile-dev · Phase: P1 (backdrop occlusion guard and probes)
Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-010_home_dashboard_deferred_scope_completion-STORY-007`
Branch: `codex/REQ-010_home_dashboard_deferred_scope_completion-STORY-007`
BaseHead: `964fc65e8e474ea4befa1389fffca1c466ea6920`
Date: 2026-08-25

This is a **verification-only** story. The expected production change surface is
`mobile/lib/**` = ZERO files (master-plan.md `## 2A`), and that is what was
delivered. All work landed in `mobile/test/` plus this evidence package.

## Summary

| Gate | Result |
| --- | --- |
| AC1 shared backdrop mounted once, above the Navigator (documentary) | PASS |
| AC2 whole-inventory static occlusion guard (AD-4) | PASS — 38/38 production files scanned, 0 violations |
| AC3 allowlist freshness (AD-3, 3 ratified paths) | PASS |
| AC4 runtime pixel probes, six STORY-046 screens | PASS — 6/6 |
| AC5 four new representative probes (AD-5) | PASS — 4/4 |
| AC6 targeted visual pass, 2 intersections (AD-6) | PASS with 1 DEFERRED observation |
| `flutter analyze` on the two story test files | PASS — `No issues found!` |
| `flutter test` (targeted, both story files) | PASS — `+12: All tests passed!` |
| `flutter test` (full suite) | PASS — `+1392 ~2: All other tests passed!` |
| `flutter build apk --debug` | PASS — `✓ Built .../app-local-debug.apk` |
| `mobile/lib/**` change surface | PASS — ZERO files (empty diff vs BaseHead) |
| Entry point reachability (rule 12e1) | PASS — `Reachable: YES` |
| Story runtime startup smoke | PASS (scoped — no runtime delta) |

## AC1 — The shared backdrop is mounted once, above every route

Documentary evidence only; no code changed.

`mobile/lib/app/cupid_app.dart:58-59` mounts the wash through
`MaterialApp.builder`, which sits **above** the `Navigator`, so it is composited
once for the whole app rather than per route:

```dart
builder: (BuildContext context, Widget? child) =>
    CupidAppBackground(child: child ?? const SizedBox.shrink()),
```

`mobile/lib/design_system/theme/cupid_theme.dart:43-45` is what lets it show
through — the comment already names the exact failure mode this story guards:

```dart
// CupidAppBackground owns the base fill now, one layer above every route;
// an opaque scaffold here would occlude its sky wash.
scaffoldBackgroundColor: Colors.transparent,
```

Because the backdrop is mounted once and the theme default is transparent, the
only way a route can lose the wash is by painting its **own** opaque root fill.
That is the single failure mode AC2–AC5 below are built to detect. It is silent:
nothing throws, nothing logs, the screen simply renders on a flat fill. REQ-002
STORY-046 fixed six such screens by hand; this story replaces that manual sweep
with a standing guard.

## AC2/AC3 — Whole-inventory static occlusion guard (AD-4)

New file: `mobile/test/design_system/shared_backdrop_occlusion_guard_test.dart`

The guard walks every `.dart` file under `mobile/lib/`, finds each `Scaffold(`
construction, and uses a hand-rolled paren/bracket-depth scanner to decide
whether a `backgroundColor:` argument belongs to that `Scaffold` or to a nested
widget. Depth tracking rather than a flat regex is what makes it correct on the
real tree, where `Scaffold(... body: Container(backgroundColor: ...))` is
common and harmless.

Inventory scanned this run:

```
Scaffold-bearing .dart files under lib/: 42
  preview-harness (skipped by the guard): 4
  production (scanned by the guard): 38
Total `backgroundColor:` occurrences under lib/: 14
```

The four skipped files are `lib/preview/**` and `lib/main_preview.dart` — the
design-canvas preview harness, which deliberately paints its own frame fill and
is never a user-reachable route.

### Detector narrowing: `_alphaModulated`

The guard does not flag a `Scaffold.backgroundColor` whose value is
alpha-modulated (`withValues(alpha: …)` / `withAlpha(…)` / `withOpacity(…)`).
This is deliberate and matches master-plan §3A row 2: a translucent scaffold
fill is a **decorative accent layered over** the wash, not an occluder — the
wash still reaches the user. `paired_screen.dart` and `vow_screen.dart` are the
two live examples; both tint over the backdrop rather than replacing it. Without
this narrowing the guard would produce two permanent false positives and would
be routed around rather than trusted.

### AC3 — allowlist freshness

`const Map<String, String> _allowlist` carries the three AD-3 ratified paths,
each with its rationale:

| Path | Why it is allowed to occlude |
| --- | --- |
| `splash` | pre-theme boot frame; the backdrop is not mounted yet |
| `gallery_viewer` | full-bleed media viewer; an opaque fill is the intended presentation |
| `welcome` | full-bleed art treatment ratified in AD-3 |

The freshness test fails if an allowlist entry no longer names a real file or no
longer actually occludes, so the allowlist cannot silently rot into a
rubber stamp.

**Result: PASS** — 2/2 tests, 0 violations across 38 production files.

## AC4/AC5 — Runtime pixel probes

File: `mobile/test/design_system/shared_backdrop_occlusion_test.dart`

### Technique

Each probe renders the screen **twice** into a `RenderRepaintBoundary` and
rasterizes via `tester.runAsync` + `boundary.toImage()`, reading pixel
(120, 10):

1. **Negative control** — force `scaffoldBackgroundColor` to a green sentinel
   `#00FF00`. If the probe pixel does not come back green, the screen is
   painting over the scaffold and the probe is pointed at the wrong pixel.
2. **Production theme** — assert the wash is actually visible.

`_expectSharedBackdropShowsThrough()` asserts all of:

- `occluded.g > 0.5` — the sentinel reaches the probe pixel (control is valid)
- every `Scaffold.backgroundColor` in the tree is `null`
- `washed.g < 0.2` — the green is gone under the real theme
- `washed != _flatFill`, `washed.r > _flatFill.r`, `washed.b > _flatFill.b` —
  the pixel carries the purple/magenta wash, not the flat base colour

The negative control is the load-bearing half. Without it a probe that happens
to sit under an opaque card would pass forever while proving nothing.

### AC4 — the six STORY-046 screens (pre-existing, unweakened)

`otp`, `contract`, `profile setup`, `permissions`, `joincode`, `vow` — 6/6 PASS.
These assertions were not modified, relaxed, or re-thresholded by this story.

### AC5 — four new representative probes (AD-5)

Deliberately capped at four. The static guard covers the whole inventory, so
extra probes buy pump time rather than coverage. These four were chosen because
they are composition shapes the STORY-046 six do not exercise at all:

| Probe | Composition shape under test |
| --- | --- |
| home tab content | a screen painting its **own** decorative hero glow over the shared wash |
| paired pair-gate route | **two nested shell `Scaffold`s** (`PairGateShell` inside `AppShell`) |
| timeline | a long **scrollable** body |
| chat | **persistent bottom chrome** (composer) pinned over the backdrop |

All 4 PASS.

#### Probe-target correction (pair-gate) — not an occluder

The pair-gate probe initially failed its **negative control**:

```
Expected: a value greater than <0.5>
  Actual: <0.10588235294117647>
```

Diagnosis, not threshold-lowering: the probe pixel was `#241B42`
(`colorSurface`), both `Scaffold`s were correctly green, but
`find.byKey(const Key('home_couple_hero'))` matched **0 widgets**. `AppShell`
mounts `const HomeScreen()` with no `resolveProfile` seam, so a profile that
fails to resolve collapses `_CoupleHeroHeader` to `SizedBox.shrink()` and slides
the first entry card up under (120, 10) — a layout production never shows a
paired user.

Per the phase file's "fix the probe target, do not lower the threshold", the fix
was to register `StubAccountRepository(relationshipStartDate: …)` as the
`AccountRepository` so the hero renders as it does in production. The
`occluded.g > 0.5` threshold was left untouched. This was a **defect in the
test harness, not a fourth occluder**, so no escalation and no `mobile/lib/`
edit was warranted.

### Targeted run

```
flutter test test/design_system/shared_backdrop_occlusion_test.dart \
             test/design_system/shared_backdrop_occlusion_guard_test.dart

00:00 +7: ... AC7: vow shows the shared sky wash, not a solid fill
00:00 +8: ... STORY-007 AD-5: ... home tab content shows the shared sky wash under its own hero glow
00:00 +9: ... STORY-007 AD-5: ... the paired pair-gate route shows the shared sky wash through two nested shell Scaffolds
00:01 +10: ... STORY-007 AD-5: ... timeline shows the shared sky wash behind a long scrollable body
00:01 +11: ... STORY-007 AD-5: ... chat shows the shared sky wash despite its persistent bottom chrome
00:01 +12: All tests passed!
```

10 probes + 2 guard tests = 12/12.

The probe file was also re-run standalone after the temporary capture harness
was removed, so the green result is backed by an explicit exit code and not only
by the combined run:

```
flutter test test/design_system/shared_backdrop_occlusion_test.dart
00:01 +10: All tests passed!
TEST_EXIT=0

flutter test test/design_system/shared_backdrop_occlusion_test.dart --no-pub
00:01 +10: All tests passed!

flutter test test/design_system/shared_backdrop_occlusion_guard_test.dart --no-pub
00:00 +2: All tests passed!

flutter test test/design_system/shared_backdrop_occlusion_test.dart \
             test/design_system/shared_backdrop_occlusion_guard_test.dart --no-pub
00:01 +12: All tests passed!
```

Earlier failing runs of this same command during the story are superseded: they
were the pair-gate probe-target defect (diagnosed and fixed above) and one
mid-edit state while the temporary AD-6 capture harness was being removed. Both
are resolved; the command now exits 0.

## AC6 — Targeted visual pass (AD-6)

Scope per the phase file: **exactly two intersections**, dark theme and the `vi`
locale only. `en` is not a user-enabled locale and light theme is not shipped,
so neither is evidence-bearing here.

**The three allowlisted screens (`splash`, `gallery_viewer`, `welcome`) are
outside this pass by construction** — they are ratified as intentionally opaque,
so there is no wash for text or glow to intersect with on those routes.

### Capture method and its honest limit

Captures were produced by in-test rasterization at a 430×932 logical frame
(`physicalSize 1290×2796` @ dpr 3), not from a device. Emulator/simulator
provisioning is explicitly outside the mobile-dev lane for this handoff.

Limit worth stating plainly: `flutter test` renders without real fonts, so
glyphs rasterize as solid boxes filled with the text colour. That makes
**colour-vs-backdrop contrast directly measurable** — which is exactly what
intersection 1 asks — but it does **not** cover glyph-level legibility (stroke
weight, hinting, antialiasing). A device pass would be needed for that and is
not claimed here.

Artifacts (all 430×932, dark + `vi`):

```
data/requirements/REQ-010_home_dashboard_deferred_scope_completion/STORY-007_sky_backdrop_theme_rollout/visual-evidence/
  ad6-home-hero-glow-dark-vi.png
  ad6-pair-gate-shell-dark-vi.png
  ad6-timeline-dark-vi.png
  ad6-chat-dark-vi.png
```

### Intersection 1 — top-third text contrast over the brightest wash

The wash's two bright lobes are purple at alpha .55 (15%, -8%) and magenta at
alpha .32 (95%, 6%), both in the top third. Measured worst-case backdrop pixel
in that region and the resulting WCAG contrast ratios:

```
AD6 brightest top-third backdrop = #7c4e6c  L=0.1082
AD6 tx      #F7EEFB over backdrop ratio = 5.872843396901565
AD6 tx2     #B4A6CE over backdrop ratio = 2.935652544857914
AD6 divider #FFFFFF @ 0.06 over backdrop ratio = 1.1592045596127238
```

| Token | Ratio | Verdict |
| --- | --- | --- |
| `--tx` `#F7EEFB` (primary text) | **5.87:1** | PASS — clears WCAG AA 4.5:1 |
| `--tx2` `#B4A6CE` (secondary text) | **2.94:1** | Below AA 4.5:1, marginally below AA-large 3.0:1 — see DEFERRED |
| thin divider `#FFFFFF` @ .06 | 1.16:1 | Decorative hairline, non-informational; no contrast requirement |

Primary text — the informational load of every one of these screens — passes
against the worst pixel the wash can produce.

**Result: PASS**, with the `--tx2` figure recorded as DEFERRED below.

### Intersection 2 — Home hero-glow double-stack

The Home hero paints its own pink radial glow
(`mobile/lib/features/home/presentation/home_screen.dart:310`) directly over the
shared magenta lobe — the one place in the app where two decorative radial
gradients stack.

Confirmed visually from `ad6-home-hero-glow-dark-vi.png`:

- **No banding** — the glow's falloff blends smoothly into the shared magenta
  layer; no stepped rings at the alpha boundary.
- **No over-brightness / no clipped region** — the combined core does not blow
  out to a flat saturated patch; gradient detail is preserved through the
  overlap.
- **No bleed** — the `ClipRect` at `home_screen.dart:303` holds the glow inside
  the hero block; it does not leak into the card column below, matching the
  design source's `overflow:hidden`.

**Result: PASS.**

## Why `mobile/lib/**` was not modified

Zero production files changed, and that is the correct outcome, not a gap:

- **OQ-1** ratified two of the occluding screens (`splash`, `gallery_viewer`) as
  intentional exceptions.
- **OQ-3** ratified the third (`welcome`).
- The AD-4 whole-inventory scan found **no fourth occluder**, so there was
  nothing left to fix.
- The one probe failure encountered was a harness defect (pair-gate probe
  target, above), not a production occlusion.

The handoff's stop rule — escalate rather than edit `mobile/lib/` or self-expand
the allowlist — was therefore never triggered.

```
git diff --stat 964fc65e8e474ea4befa1389fffca1c466ea6920 -- mobile/lib
(no output — ZERO files)

git diff --stat 964fc65e8e474ea4befa1389fffca1c466ea6920
 .../shared_backdrop_occlusion_test.dart            | 302 +++++++++++++++++++++
 1 file changed, 302 insertions(+)

git status --porcelain
 M mobile/test/design_system/shared_backdrop_occlusion_test.dart
?? data/requirements/.../STORY-007_sky_backdrop_theme_rollout/visual-evidence/
?? mobile/test/design_system/shared_backdrop_occlusion_guard_test.dart
```

The temporary AD-6 capture harness (`dart:io` / `dart:math` imports,
`_capture()`, and the `AD-6 capture` group) was used to produce the PNGs above
and has been **removed before commit** as planned; the probe file now contains
only the 10 permanent probes.

## Gate commands

### analyze — story files

```
flutter analyze test/design_system/shared_backdrop_occlusion_test.dart \
                test/design_system/shared_backdrop_occlusion_guard_test.dart
Analyzing 2 items...
No issues found! (ran in 0.8s)
```

### analyze — project source

```
flutter analyze lib test
75 issues found. (ran in 1.3s)
```

All 75 are severity `info`, all in `lib/` (predominantly
`prefer_initializing_formals`, plus one `use_null_aware_elements` and one
`deprecated_member_use` for `SemanticsService.announce`). Zero errors, zero
warnings, and **none in either file this story touches** — confirmed by the
scoped run above returning `No issues found!`. `lib/` was not modified by this
story, so these are the pre-existing baseline.

Note: bare `flutter analyze` also walks `mobile/build/ios/SourcePackages/`,
vendored FlutterFire checkouts left by an earlier iOS build. Those emit
`uri_does_not_exist` errors for `package:cloud_firestore`. That path is
gitignored (`mobile/.gitignore:33:/build/`), is not project source, and is
unrelated to this story; the analyze gate is therefore recorded against
`lib test`.

### test — full suite

```
flutter test --reporter compact
00:43 +1392 ~2: 2 skipped tests.
00:43 +1392 ~2: All other tests passed!
```

1392 passed, 2 skipped, **0 failed**. Both skips are pre-existing and unrelated
(`ReminderFiringOverlay ... captures the alarmRinging state at the Android
reference viewport (F-1)`, and one boot-signal case).

### build

```
flutter build apk --debug
Running Gradle task 'assembleLocalDebug'...                        39.3s
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

## Story Runtime Startup Smoke

Scope: the mobile app, the only impacted artifact.

Because `mobile/lib/**` is a **ZERO-file change surface** (empty diff vs
BaseHead, above), the shipped runtime is bit-identical to BaseHead. There is no
runtime delta for this story to smoke — the only changes are test-tree files,
which are not compiled into the APK.

The compile-and-package path was still exercised end to end:

```
flutter build apk --debug
✓ Built build/app/outputs/flutter-apk/app-local-debug.apk
```

No device or emulator launch was attempted. Emulator/simulator provisioning is
outside the mobile-dev lane for this handoff, and with zero production delta it
would re-measure the already-recorded REQ-009 STORY-002 DevOps device pass
rather than produce new evidence.

Result: PASS

## Entry Point Reachability

Reachable: YES

(Proven by existing and new tests; no manual navigation used.)

Entry point: `main.dart` → `CupidApp` → `MaterialApp.builder` →
`CupidAppBackground` (`mobile/lib/app/cupid_app.dart:58-59`). Because the
backdrop is installed by `builder`, it is above the `Navigator` and is therefore
on the render path of **every** route — there is no route a real user can reach
that bypasses it.

| Item | Location |
| --- | --- |
| Backdrop mounted once, above the Navigator | `mobile/lib/app/cupid_app.dart:58-59` |
| Theme default that lets it show through | `mobile/lib/design_system/theme/cupid_theme.dart:45` |
| 10 runtime probes mount real screens (`OtpScreen`, `ChatScreen`, `TimelineScreen`, `PairGateShell` inside `AppShell`, …) and assert the wash is present at the probe pixel | `shared_backdrop_occlusion_test.dart` |
| The pair-gate probe reaches its screen through the **real** `AppShell`/`PairGateShell` composition, not by direct construction | `shared_backdrop_occlusion_test.dart`, AD-5 group |
| Whole-inventory static scan proves no production route re-introduces an opaque root fill | `shared_backdrop_occlusion_guard_test.dart` |

These assertions are inside the `+12: All tests passed!` run recorded above.

## Observations (DEFERRED — not fixed in this story)

1. **`--tx2` secondary text at 2.94:1 over the brightest wash pixel.** Below
   WCAG AA 4.5:1 and marginally below AA-large 3.0:1. This is a **pre-existing
   token/backdrop pairing**, unchanged by this story, and it applies only at the
   magenta lobe's peak (top-right corner). None of the four captures place
   secondary text there. Fixing it means re-tuning `--tx2` or the wash alpha —
   a UX token decision, not a P1 code change, and squarely outside a
   verification-only story's zero-lib-change constraint. Routing to UX.

2. **`_DaysCounter` overflows by 14px at 390 logical width.**
   `RenderFlex overflowed by 14 pixels on the right` in
   `mobile/lib/features/home/presentation/home_screen.dart` (~`:500`) when the
   Home hero is rendered at 390dp. Reproduced during AD-6 capture; the capture
   frame was widened to 430×932 to work around it. This is a **pre-existing
   narrow-width layout issue**, unrelated to the backdrop, and touching it would
   require a `mobile/lib/` edit this story is forbidden to make. Worth a
   follow-up story: 390dp is a real device width (iPhone 12/13/14 class).

## Lane status

All STORY-007 deliverables are written and every gate above passed in-session.
The lane is nevertheless held at **BLOCKED**, pending a Scrum Master decision,
by `verify-implementation-build-runtime-gate.sh`.

Blocker: `BUILD_EVIDENCE_GATE_UNCLEARABLE`

The gate replays every build/test command that exited non-zero during the story
and requires each to be re-run to exit 0. Every command shape targeting a
**permanent** test has been re-run green (see the block above). The remaining
cited command is a truncated `flutter test … --plain-name …` run, and the
`--plain-name` runs in this story targeted the **temporary AD-6 capture
harness** (`capture home`, `capture pair gate`, `capture timeline`,
`capture chat`, `worst-case top-third contrast`).

That harness was removed before commit because the handoff required it. The
cited command therefore cannot exit 0 by construction — the test no longer
exists. Re-adding scaffolding solely to satisfy a gate replay would be worse
than the block, so it was not done.

Nothing is masked: the full suite is 1392 passed / 2 skipped / **0 failed**,
both story files are green standalone and combined, analyze is clean on both,
the debug APK builds, and `mobile/lib/**` is an empty diff.

Awaiting Scrum Master: waive the deleted-scaffolding replay entries, or supply
the exact recorded command string for assessment.
