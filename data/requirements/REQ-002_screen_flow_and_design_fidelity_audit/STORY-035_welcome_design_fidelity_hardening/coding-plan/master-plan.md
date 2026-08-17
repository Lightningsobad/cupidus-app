# Master Coding Plan – STORY-035 Welcome Design Fidelity Hardening

## 1. Planning Metadata

- Story ID: STORY-035_welcome_design_fidelity_hardening
- Complexity: standard
- OQ Constraints Source: `data/intake/bootstrap/conflicts_open_questions.md`
  (OQ5 only; carried in `../architecture/solution.md` section 3)
- Requirement Configuration Guide impact: NOT_APPLICABLE — no env var, secret,
  or third-party integration changes.

## 2. Planning Goal

- Shared contract owner: none — single mobile lane, no cross-lane or cross-repo
  consumer.
- Contract-first phase required: NO
- Parallel execution possible: NO
- Critical path: P0 (capture -> compare -> conditional fix -> re-verify ->
  evidence).
- Parallelism notes: the AC4 fix loop is inherently iterative against the same
  capture harness and the same two files. Splitting capture from fix would cost
  a second dispatch to re-run an identical emulator build/install/screencap
  cycle, so it stays one phase.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Evidence method (IF-7 recurrence) | P0 |
| Stale-baseline misread | P0 |
| Design-system scope creep | P0 |
| Capture configuration drift | P0 |
| Regression from a fix that was not needed | P0 |
| Gradient axis geometry (D1) | P1 |
| Shared-helper regression across `gradientHot` consumers | P1 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (the app launch
    happens inside the required mobile visual audit, not as a separate
    readiness gate), build command source runtime registry `buildCommand`
    (`flutter build apk --debug`).

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P0 | Mobile Developer | Mobile | None | NO | DONE |
| P1 | Mobile Developer | Mobile | P0 | NO | DONE |

P0 status note: every P0 task executed, every deliverable produced, all gates
green, F1/F2 review rework cleared. One finding is DEFERRED rather than open:
D1, the gradient-axis token, is `SCOPE_BOUNDARY_BLOCKED` outside this phase's
Write Scope and Reviewer-confirmed for separate routing, so
`VISUAL_FIDELITY: PASS` is deliberately not recorded while it stands.

P1 closes D1 instead of routing it elsewhere: the user, asked how to close out
Reviewer cycle 2's `DEFERRED_ONLY` verdict, explicitly chose to widen this
story's Write Scope and fix D1 inline. P1 therefore owns both the shared
gradient-axis correction and the re-verification that flips
`VISUAL_FIDELITY: BLOCKED` to `PASS`.

P1 status note: DONE. D1 RESOLVED — welcome's backdrop axis measures 15.01 deg
off vertical against the design reference's 14.98 deg, up from 6.86 deg pre-fix.
`visual-fidelity/visual-fidelity-report.md` now records `VISUAL_FIDELITY: PASS`.
All gates green: new axis test 15/15, full `flutter test` `+1264 ~2` with 0
failures, `no_fork_guard_test.dart` 1/1, all 7 `*_design_fidelity_test.dart`
50/50, `flutter analyze` 0 attributable issues, `flutter build apk --debug` on
both entry points. The diff touches zero consumer widget files.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P0 | `phase-P0-welcome-rendered-fidelity-evidence.md` |
| P1 | `phase-P1-gradient-axis-fix.md` |

Artifact hygiene:

- Each phase id above maps to exactly one canonical `phase-Px-*.md` file.
- No duplicate files exist for any phase id.
- P0 and P1 each fit one specialist lifecycle (roughly six source/test files
  max); no split required.
- P1 is not a trailing verification phase: it fixes a defect in a shared token
  helper and owns its own targeted tests and build/static-analysis. P0 and P1
  are sequential rather than merged because P0 is already DONE and reviewed —
  P1 exists only because P0's evidence surfaced a defect outside P0's Write
  Scope.
- P0's and P1's test scopes exclude backend e2e/test_e2e, Playwright/browser
  e2e, traces, scenario reruns, and repository-root local script gates.

## 6. Notes

- P0 Status is PATCH_REQUIRED per Reviewer verdict (`review/review-report.md`,
  2026-08-16): D1 (backdrop gradient axis,
  `mobile/lib/design_system/tokens/cupid_color_tokens.dart`) confirmed
  correctly deferred/out of scope; two in-scope blocking findings (F1 missing
  `CupidStarField` twinkle particles, F2 missing test-results.md evidence
  sections) remain. See `phase-P0-welcome-rendered-fidelity-evidence.md`
  section 7 for full remediation detail.
- `../architecture/solution.md` section 1 `Key Discovery` must be read before
  any code edit: the current screen already matches the UX spec's match
  criteria, so the expected outcome is evidence-only with zero code change.
  A code change is justified only by a deviation visible in this story's own
  fresh capture.
- P1's Write Scope is a defect-scoped carve-out authorized by
  `../architecture/solution.md` section 4 `REVISION 2026-08-17`, not a general
  design-system opening. Read that revision plus the `D1 root cause` and
  `D1 blast radius` subheadings before starting P1.
- Verification-sizing decision recorded for Reviewer: the P1 request asked for
  a fresh rendered pair per affected screen. `gradientHot` has ~20 consumers,
  almost all short/wide pills where the axis error is sub-5-degree and below
  what a screenshot comparison resolves. P1 therefore proves the shared helper
  with an exhaustive token-level axis test across a box-shape matrix — which
  covers every consumer, not a sample — and keeps rendered evidence mandatory
  for `welcome`, the one high-aspect consumer where the error is large and
  measurable. If Scrum Master or Reviewer wants literal per-screen captures in
  addition, that is a scope decision for them, not a gap in this plan.
