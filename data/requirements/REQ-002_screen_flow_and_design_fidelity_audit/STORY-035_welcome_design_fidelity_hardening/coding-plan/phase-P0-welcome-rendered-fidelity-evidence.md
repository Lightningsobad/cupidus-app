# Phase P0 – Welcome Rendered Fidelity Evidence And Conditional Fix

## 1. Objective

Produce this story's own matched rendered evidence pair for the `welcome`
screen, compare it region-by-region against the UX match criteria, fix inside
the welcome screen widget only if the fresh pair shows a real deviation,
re-verify after any fix, and record `VISUAL_FIDELITY: PASS`.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-welcome-rendered-fidelity-evidence.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/auth/presentation/screens/welcome_screen.dart` (edit
    only if the fresh capture shows a deviation)
  - `mobile/test/features/auth/presentation/screens/welcome_screen_test.dart`
    (edit only alongside a source change)
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-035_welcome_design_fidelity_hardening/visual-fidelity/`
  - `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-035_welcome_design_fidelity_hardening/coding-plan/test-results.md`
- Prohibited paths (see `../architecture/solution.md` section 4, WriteScope
  Boundary Decision): `mobile/lib/design_system/**`, `mobile/assets/**`,
  `mobile/pubspec.yaml`, any other screen, and every STORY-004 / STORY-033 /
  BUG-20260816-001 artifact.
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
  - Evidence method (IF-7 recurrence)
  - Stale-baseline misread
  - Design-system scope creep
  - Capture configuration drift
  - Regression from a fix that was not needed
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` `## Match criteria`
  - render input (never the comparison basis):
    `cupid-app-design-system/project/Cupid Screens.dc.html`, `isWelcome` block
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC1-5
  - architecture: `../architecture/solution.md` sections 1, 3, 4
  - OQ constraints: OQ5 — dark + `vi` only, both sides
  - UX constraints: `../ux/uiux-spec.md` `## Match criteria` and
    `## What "match exactly" means for AC3/AC5`
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one screen's rendered-evidence capture plus its conditional
    in-place fix — a single behavior cluster.
  - Source/Test File Count: up to 6 (2 source/test, 3 evidence, 1 test-results)
  - Split Required: NO
  - Split Rationale: capture and fix share the same emulator harness and the
    same two source files; a split would re-run an identical
    build/install/screencap cycle in a second dispatch.

## 2. Required Reads

- `../architecture/solution.md` sections 1 (`Key Discovery`), 3, 4
- `../ux/uiux-spec.md`
- `../requirements/requirements.md`

## 3. Tasks

1. Read `../architecture/solution.md` section 1 `Key Discovery` first. The
   current screen already matches the UX match criteria; the UX spec's
   deviation list comes from a pre-BUG-20260816-001 capture and is a hypothesis
   to disprove, not a work list.
2. Render the design reference into this story's `visual-fidelity/`:
   `node .ai-team-bundle/runtime/tools/render-design-canvas.js --screen=welcome
   --platform=android --theme=dark --lang=vi --out=<this story's
   visual-fidelity dir>`. Record the exact invocation.
3. Capture the implemented screen from the running app on a booted emulator,
   using the path already proven for this screen:
   `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=welcome`,
   then `adb -s <serial> install -r build/app/outputs/flutter-apk/app-debug.apk`,
   `am force-stop`, `am start -W -n
   com.snapsofts.cupid/com.snapsofts.cupid_mobile.MainActivity`, then
   `adb -s <serial> exec-out screencap -p > implemented-welcome-<serial>.png`.
   `PREVIEW_BRIGHTNESS` already defaults to `dark`; do not add a locale/theme
   override. Record the exact serial and invocation.
4. Compare the two fresh PNGs region-by-region against `../ux/uiux-spec.md`
   `## Match criteria`: hero left-alignment, accent-rule presence,
   tagline/sub-copy wrap width and opacity, per-row CTA fill vs. outline, pill
   radius, bottom-pinned vs. centered CTA block, footnote contrast, backdrop
   gradient. Ignore font anti-aliasing, the device status bar, and the
   reference image's device bezel.
5. If and only if a deviation is visible in the fresh pair, fix it inside
   `welcome_screen.dart` using existing tokens, then re-run steps 2-4 and keep
   the post-fix `implemented-*.png` as the delivered artifact. Do not swap
   `gradientBrandBackdrop` for `gradientHot` or any reversal of it, and do not
   introduce a screen-local literal hex.
6. If a deviation's only correct fix lies under `mobile/lib/design_system/` or
   `mobile/assets/`, stop and report `SCOPE_BOUNDARY_BLOCKED` with the exact
   token/asset and the exact rendered difference. Do not widen Write Scope.
7. Write `visual-fidelity/visual-fidelity-report.md`: both verbatim commands,
   both artifact filenames, the region-by-region findings sourced only from
   this story's fresh pair, whether any code change was needed, and
   `VISUAL_FIDELITY: PASS`.
8. Record all gate results in `coding-plan/test-results.md`.

## 4. Acceptance Criteria

- Both `design-reference-welcome-android.png` and
  `implemented-welcome-<device>.png` physically exist in this story's own
  `visual-fidelity/` directory (AC2).
- Every finding in the report cites this story's fresh pair; no finding is
  sourced from STORY-033's or STORY-004's artifacts (AC1).
- The report records the verbatim generating command for each side, both fixed
  to android / dark / `vi` (AC1, AC3).
- Hero alignment, spacing, token usage, typography, and per-provider CTA
  fill/outline/radius all match with no visible deviation (AC3, AC5).
- Any deviation found is corrected in `welcome_screen.dart` and re-verified by
  re-rendering both sides; zero code change is a valid outcome when no
  deviation is found (AC4).
- `git -C <Worktree> diff e28a6c2 --stat` lists no path outside the declared
  Write Scope.

## 5. Planned Outputs

- Code: `mobile/lib/features/auth/presentation/screens/welcome_screen.dart`
  (conditional), its widget test (conditional)
- Evidence: `visual-fidelity/design-reference-welcome-android.png`,
  `visual-fidelity/implemented-welcome-<device>.png`,
  `visual-fidelity/visual-fidelity-report.md` with `VISUAL_FIDELITY: PASS`
- Notes: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `welcome` screen, dark theme + `vi`
  locale, Android
- Required levels:
  - unit: `flutter test test/features/auth/presentation/screens/welcome_screen_test.dart`
  - mobile build/type-check/static-analysis: `flutter build apk --debug` and
    `flutter analyze lib test --no-fatal-infos --no-fatal-warnings`
  - visual inspection: region-by-region comparison of this story's fresh
    rendered pair
- Required checks: when `welcome_screen.dart` changes, also run the full
  `flutter test` (registry `testCommand`) so
  `test/design_system/no_fork_guard_test.dart` and the screen's design-fidelity
  tests confirm no token fork and no cross-screen regression.
- Mobile discoverability / navigation integration: not applicable — `welcome`
  is an existing, already-reachable surface; no entry point is added or changed.
- Minimum gates by risk surface:
  - Evidence method / Capture configuration drift: both PNGs present, both
    verbatim commands recorded.
  - Stale-baseline misread: report cites only the fresh pair.
  - Design-system scope creep: diff stat clean against the Write Scope;
    `no_fork_guard_test.dart` green.
  - Regression from an unnecessary fix: full `flutter test` green plus a
    post-fix re-capture, required only when source changed.
- Evidence format: `coding-plan/test-results.md` with exact commands, exit
  codes, and pass/fail counts; `visual-fidelity/visual-fidelity-report.md` for
  the rendered comparison.
- Requirement mobile visual audit: REQUIRED — this is the story's primary
  deliverable, not a smoke check.
- Verification strategy:
  - Targeted tests: welcome screen widget test always; full `flutter test` when
    source changed.
  - Build/static-analysis: `flutter build apk --debug`, `flutter analyze`.
  - Required assertion evidence: exit codes plus the rendered pair.

## 7. Status

- Status: DONE — every P0 task executed, every deliverable produced, all
  gates green, F1/F2 review rework cleared. One finding is DEFERRED rather than
  open work: D1, the gradient-axis token, is `SCOPE_BOUNDARY_BLOCKED` outside
  this phase's Write Scope and Reviewer-confirmed for separate routing.
  `VISUAL_FIDELITY: PASS` is deliberately not recorded while D1 stands.
- Reviewer verdict (`review/review-report.md`, Iris-QC, 2026-08-16):
  `Outcome: PATCH_REQUIRED`. D1 (backdrop gradient axis) confirmed correctly
  DEFERRED — do not touch `design_system/**`, route separately. Two blocking
  findings, both owned by mobile-dev, both fixable inside this phase's Write
  Scope:
  - F1: the design's three `twinkle` `CupidStarField` particles are absent
    from the implemented render (occluded by the opaque
    `gradientBrandBackdrop` `DecoratedBox`). Fix: add
    `const Positioned.fill(child: CupidStarField())` as the LAST child of a
    `Stack` wrapping the welcome body, per `review-report.md` F1 Action
    steps 1-4 (mirror `vow_screen.dart:270-272`).
  - F2: `coding-plan/test-results.md` is missing `## Entry Point
    Reachability` and `## Story Runtime Startup Smoke` sections (or an
    explicit `story_master.md` `Runtime-Smoke: WAIVED` line). Reviewer
    independently verified reachability at `splash_screen.dart:113`; add
    that citation plus a real-entrypoint startup smoke per `review-report.md`
    F2 Action.
- Last updated: 2026-08-16 (mobile-dev — F1 and F2 rework applied, gates re-run
  green, ready for Iris-QC re-review)
- Lane: mobile-dev (Alex-Mobile-Dev)

### Review rework outcome

- **F1 — CLEARED.** The welcome body is now
  `Stack(fit: StackFit.expand, ...)` with
  `const Positioned.fill(child: CupidStarField())` as the last child, mirroring
  `vow_screen.dart:270-272`. `StackFit.expand` is required, not incidental: the
  default loose fit lets the body shrink-wrap, and the
  `CrossAxisAlignment.stretch` from deviation 4.1 would then size the hero to its
  widest child, silently reintroducing the centring defect this phase removed.
  A new widget test guards presence, last-child ordering, the stack fit and the
  `IgnorePointer`. Re-captured and re-measured: all three particles land within
  0.8 logical px of the reference (`visual-fidelity-report.md` 4.4 and 5.4), and
  every pre-existing hero/CTA/footnote landmark is unchanged.
- **F2 — CLEARED, no waiver.** `test-results.md` now carries
  `## Entry Point Reachability` (`Reachable: YES`, `splash_screen.dart:113`) and
  `## Story Runtime Startup Smoke`, the latter run against the real
  `lib/main.dart` entry point rather than the `main_preview.dart` capture
  harness: `Status: ok`, `LaunchState: COLD`, welcome screen reached through the
  session gate, no runtime error entries in the log.
- **D1 — unchanged and still out of scope.** Nothing under
  `mobile/lib/design_system/**` was touched.

### What completed

- Rendered-output-to-rendered-output method replaced STORY-004's source-read
  comparison (defect IF-7). Both fresh PNGs exist in this story's own
  `visual-fidelity/`, each with its verbatim generating command recorded.
- Three real deviations were fixed inside Write Scope and re-verified by
  re-rendering both sides:
  1. hero block rendered horizontally centred (+42 logical px) — fixed with
     `CrossAxisAlignment.stretch` on the outer Column;
  2. footnote gap 10 logical px short — fixed to `_ctaGap + _footnoteMargin`,
     matching the design's flex `gap:10px` plus `margin-top:6px`;
  3. twinkle star particles absent (review finding F1) — fixed with a
     `Positioned.fill(child: CupidStarField())` last child over the backdrop.
- Regression guards added to `welcome_screen_test.dart`, including a painted-x
  assertion that the pre-existing widget-tree assertion could not make.
- All gates green: `flutter analyze` exit 0 (0 issues in the changed files),
  scoped widget test exit 0 (9/9), full `flutter test` exit 0 (1249 passed,
  2 skipped, 0 failed), `test/design_system/no_fork_guard_test.dart` exit 0,
  `flutter build apk --debug` exit 0 for both the preview target and the real
  `lib/main.dart` entry point.
- `git diff e28a6c2 --stat` lists no path outside the declared Write Scope.

### Why the phase is BLOCKED

One deviation is real and reproducible but cannot be fixed here. The
backdrop gradient axis renders at **6.86 deg** off vertical against the design
reference's **14.98 deg** (CSS `linear-gradient(165deg, ...)` expects 15.00).
Colour stops and on-axis corners match exactly; the error concentrates in the
two off-axis corners.

Cause: `_gradient165Begin` / `_gradient165End` in
`mobile/lib/design_system/tokens/cupid_color_tokens.dart` (lines 28-38) use
`sin`/`cos(165deg)` directly as `Alignment` components. Flutter normalises
`Alignment` to the box aspect ratio; CSS does not. On 412x915 the painted angle
collapses to 6.88 deg.

That file is prohibited by this story's Write Scope, and the same defect pattern
affects `_gradient95Begin` / `_gradient95End` behind `gradientHot`, so the fix is
cross-screen by construction. Per task 6, reported rather than widened. The
handoff's explicit prohibition on substituting a reversed `gradientHot`, and on
introducing a screen-local literal hex, was observed.

`VISUAL_FIDELITY: PASS` is therefore not recorded. Re-verify this phase once a
design-system-scoped fix lands.

### Outputs

- `visual-fidelity/design-reference-welcome-android.png` (406x900)
- `visual-fidelity/implemented-welcome-emulator-5560.png` (1080x2400)
- `visual-fidelity/visual-fidelity-report.md`
- `coding-plan/test-results.md`
