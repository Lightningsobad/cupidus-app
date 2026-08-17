# Phase P1 – Gradient Axis Fix (D1) And Cross-Screen Re-Verification

## 1. Objective

Correct the CSS-angle-to-Flutter-`Alignment` conversion defect behind
`gradientBrandBackdrop` and `gradientHot`, prove the corrected geometry holds
for every consumer's box shape, re-capture welcome's rendered evidence, and
flip `visual-fidelity/visual-fidelity-report.md` from
`VISUAL_FIDELITY: BLOCKED` to `VISUAL_FIDELITY: PASS`.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-gradient-axis-fix.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0 (DONE)
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/design_system/tokens/cupid_color_tokens.dart` — restricted to
    `_gradient165Begin` / `_gradient165End` / `_gradient95Begin` /
    `_gradient95End`, their doc comments, and the `gradientBrandBackdrop` /
    `gradientHot` construction needed to consume the corrected axis
  - one new sibling file under `mobile/lib/design_system/tokens/` **only if**
    the accepted mechanism needs a `Gradient` subclass that cannot live in the
    token file
  - `mobile/test/design_system/` — new gradient-axis test
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-035_welcome_design_fidelity_hardening/visual-fidelity/`
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-035_welcome_design_fidelity_hardening/coding-plan/test-results.md`
- Prohibited paths: `mobile/assets/**`, `mobile/pubspec.yaml`, every other
  token/field in `cupid_color_tokens.dart` (`gradientDream` and `_gradient120*`
  explicitly included in the prohibition), every other design-system file, all
  ~20 `gradientHot` consumer widget files, and all STORY-004 / STORY-033 /
  BUG-20260816-001 artifacts. Authority for the carve-out and its limits:
  `../architecture/solution.md` section 4 `REVISION 2026-08-17`.
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
    (`flutter build apk --debug`)
  - Readiness Check: N/A
  - Port Contract: N/A
- Risk Surfaces:
  - Gradient axis geometry (D1)
  - Shared-helper regression across `gradientHot` consumers
  - Evidence method (IF-7 recurrence)
  - Capture configuration drift
- Source Of Truth:
  - root cause and required invariants: `../architecture/solution.md` section 4
    (`D1 root cause and the invariant the fix must satisfy`)
  - accepted mechanism and the rejected alternative:
    `../architecture/solution.md` section 6
  - measured defect: `../review/review-report.md`, "Deferred findings" D1
- Primary Inputs Summary:
  - architecture: `../architecture/solution.md` sections 4 and 6
  - review findings: `../review/review-report.md` D1
  - upstream phase outputs: P0's `visual-fidelity/` pair and
    `visual-fidelity-report.md` (the pre-fix baseline to re-measure against)
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one shared math defect in one helper family, plus its test
    and the single rendered surface that can measure it.
  - Source/Test File Count: up to 6 (1-2 source, 1 test, 2 evidence PNGs +
    report, 1 test-results)
  - Split Required: NO
  - Split Rationale: both token pairs share one defect class and one helper;
    fixing them separately would write the same file twice, which is a reason
    to merge, not split.

## 2. Required Reads

- `../architecture/solution.md` sections 4 and 6
- `../review/review-report.md` "Deferred findings" D1
- `visual-fidelity/visual-fidelity-report.md` (P0's recorded measurement)

## 3. Tasks

1. Read `../architecture/solution.md` section 4 `D1 root cause and the
   invariant the fix must satisfy` and section 6. Both invariants are binding:
   the rendered gradient line must sit at the declared CSS angle **and** its
   length must match the CSS gradient-line definition
   `|W·sin θ| + |H·cos θ|`. An axis-only fix that moves
   `gradientBrandBackdrop`'s 58% stop is not acceptable.
2. Implement the accepted mechanism from section 6 (per-rect CSS-correct
   endpoint computation in a `LinearGradient` subclass). If a different
   mechanism satisfies both invariants and keeps `CupidColorTokens`'s
   `LinearGradient`-typed fields, `copyWith`, and `lerp` compiling unchanged,
   it may be substituted — record the substitution and its reasoning in
   `test-results.md`.
3. Apply the correction to **both** axis pairs: `_gradient165Begin` /
   `_gradient165End` (165deg, `gradientBrandBackdrop`) and `_gradient95Begin` /
   `_gradient95End` (95deg, `gradientHot`). Do not change any colors or stop
   values. Do not touch `gradientDream` / `_gradient120*`.
4. Add a gradient-axis test under `mobile/test/design_system/`. It must, for
   each of the two tokens, resolve the gradient against a matrix of box shapes
   spanning every consumer's aspect class and assert the resulting geometric
   angle matches the declared CSS angle within a stated tolerance, and that the
   gradient-line extent matches the CSS formula. The matrix must include at
   minimum:
   - `412 x 915` — welcome's full-screen backdrop (`gradientBrandBackdrop`'s
     only consumer, and the case that produced the 6.86-vs-15.00 deg defect)
   - a square box — the degenerate case where the old and new math agree, which
     proves the test would have caught the original defect rather than passing
     vacuously
   - a wide short pill, e.g. `380 x 52` — the aspect class that ~20
     `gradientHot` consumers occupy (buttons, chips, toggles, bubbles)
   - a tall narrow box — the opposite extreme, to pin the sign/orientation
5. Verify the direct-shader consumer still behaves: `colors.gradientHot
   .createShader(bounds)` at
   `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart:281`
   bypasses `BoxDecoration`, so confirm the chosen mechanism corrects that path
   too. If it does not, the mechanism is wrong — do not special-case the call
   site (it is outside Write Scope).
6. Re-capture welcome's rendered evidence using P0's recorded procedure
   (`render-design-canvas.js --screen=welcome --platform=android --theme=dark
   --lang=vi`; preview APK via `-t lib/main_preview.dart
   --dart-define=PREVIEW=welcome`, then `adb ... exec-out screencap`). Re-measure
   the backdrop axis on the fresh implemented capture and confirm it now reads
   ~15.0 deg against the reference's 14.98 deg.
7. Run the full gate set in section 6 below.
8. Update `visual-fidelity/visual-fidelity-report.md`: replace the
   `VISUAL_FIDELITY: BLOCKED` verdict with `VISUAL_FIDELITY: PASS`, record the
   before/after measured angles, mark D1 RESOLVED, and update sections 4.3 and
   7 which currently carry the blocked state. Record all gate results in
   `coding-plan/test-results.md`.
9. If the corrected geometry surfaces a *new* visible deviation on any screen,
   stop and report it rather than widening Write Scope into consumer widgets.

## 4. Acceptance Criteria

- Both axis pairs produce the declared CSS angle and CSS gradient-line extent
  on every box shape in the test matrix.
- The new axis test fails against the pre-fix math (confirm by reasoning or a
  scratch run) — a test that passes both before and after proves nothing.
- Gradient colors and stop values are byte-identical to their pre-fix values;
  `gradientDream` and `_gradient120*` are untouched.
- `CupidColorTokens`'s public shape is unchanged: field types, `copyWith`, and
  `lerp` compile with no consumer edits, and `git diff` touches zero consumer
  widget files.
- Welcome's fresh implemented capture measures ~15.0 deg on the backdrop axis
  against the reference's 14.98 deg.
- `visual-fidelity/visual-fidelity-report.md` records `VISUAL_FIDELITY: PASS`
  with D1 marked RESOLVED and the before/after angles cited.
- `git -C <Worktree> diff e28a6c2 --stat` lists no path outside the declared
  Write Scope.

## 5. Planned Outputs

- Code: `mobile/lib/design_system/tokens/cupid_color_tokens.dart`, optionally
  one new sibling helper file in the same directory
- Tests: new gradient-axis test under `mobile/test/design_system/`
- Evidence: refreshed `visual-fidelity/implemented-welcome-<device>.png` and
  `visual-fidelity/design-reference-welcome-android.png`, plus
  `visual-fidelity/visual-fidelity-report.md` at `VISUAL_FIDELITY: PASS`
- Notes: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, shared color tokens, dark theme + `vi`
  locale, Android
- Required levels:
  - unit: the new gradient-axis test (box-shape matrix, both tokens, angle and
    extent assertions)
  - integration: full `flutter test` (registry `testCommand`) — mandatory, not
    optional, because the change is in a token consumed by ~20 widgets
  - mobile build/type-check/static-analysis: `flutter build apk --debug` and
    `flutter analyze lib test --no-fatal-infos --no-fatal-warnings`
  - visual inspection: fresh rendered pair for `welcome`, with the backdrop
    axis re-measured numerically rather than eyeballed
- Required checks:
  - `mobile/test/design_system/no_fork_guard_test.dart` green — proves no
    screen-local literal was introduced as a workaround
  - every existing `*_design_fidelity_test.dart` green — these are the
    regression net for the `gradientHot` consumer surfaces
- Mobile discoverability / navigation integration: not applicable — no entry
  point or navigation change.
- Minimum gates by risk surface:
  - Gradient axis geometry (D1): the box-shape matrix test passes, and welcome's
    fresh capture measures ~15.0 deg.
  - Shared-helper regression across `gradientHot` consumers: full `flutter test`
    green including `no_fork_guard_test.dart` and all design-fidelity tests.
  - Evidence method / Capture configuration drift: both PNGs re-rendered fresh
    with their verbatim commands recorded; android / dark / `vi` on both sides.
- Evidence format: `coding-plan/test-results.md` with exact commands, exit
  codes, and pass/fail counts; `visual-fidelity/visual-fidelity-report.md` for
  the rendered comparison and the before/after angle measurements.
- Requirement mobile visual audit: REQUIRED — welcome only. Per-screen captures
  for the ~20 `gradientHot` consumers are deliberately not required; see
  `master-plan.md` section 6 for the sizing decision and its reasoning.
- Verification strategy:
  - Targeted tests: new gradient-axis test.
  - Regression: full `flutter test`.
  - Build/static-analysis: `flutter build apk --debug`, `flutter analyze`.
  - Required assertion evidence: exit codes, the numeric angle measurements
    before and after, and the refreshed rendered pair.

## 7. Status

- Status: DONE
- Last updated: 2026-08-17

All nine tasks executed. D1 RESOLVED: welcome's backdrop axis measures **15.01
deg** off vertical against the design reference's 14.98 deg, up from **6.86 deg**
pre-fix, and all four corner colours now agree within 1/255.

Mechanism: new `mobile/lib/design_system/tokens/cupid_css_angle_gradient.dart`
(`CupidCssAngleGradient extends LinearGradient`, overriding `createShader`), wired
into the four `gradientBrandBackdrop` / `gradientHot` construction sites in
`cupid_color_tokens.dart`. The CSS direction is derived from the existing
`begin`/`end` pair rather than from a stored angle, so no new field is added and
`==` / `hashCode` / `const` semantics are unchanged. Colours, stops and the four
`Alignment` constants are untouched, as are `gradientDream` / `_gradient120*`.

Task 5: the direct-shader call site needed no special case — the override is on
the instance, so `waiting_screen.dart:281` is corrected automatically (asserted
LTR and RTL).

Task 9: no new visible deviation surfaced from the corrected geometry, so no
Write Scope widening was requested.

Gates (all exit 0): new axis test 15/15; full `flutter test` `+1264 ~2` (was
1249, +15 = the new test), 0 failures; `no_fork_guard_test.dart` 1/1; all 7
`*_design_fidelity_test.dart` 50/50; `flutter analyze` 80 pre-existing infos, 0
attributable; `flutter build apk --debug` on both the real and preview entry
points.

Evidence: `coding-plan/test-results.md` sections 6-8 and
`visual-fidelity/visual-fidelity-report.md` sections 4.3 and 7
(`VISUAL_FIDELITY: PASS`).
