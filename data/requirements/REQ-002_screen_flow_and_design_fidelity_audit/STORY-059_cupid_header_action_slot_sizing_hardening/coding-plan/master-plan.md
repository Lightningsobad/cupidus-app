# STORY-059 — Master Coding Plan

Story: STORY-059_cupid_header_action_slot_sizing_hardening
Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Complexity: standard | Story-Class: standard
Architecture source: `../architecture/solution.md`
Author: tech-lead | Date: 2026-08-19

## Scope Summary

Two coordinated edits in one lane (mobile-dev):

1. Remove the design-unsupported `CupidAddAction` from `CupidHeader.actions` on
   the Dream Jar list screen (root-causes the 60x56 clamp).
2. Harden `CupidHeader`'s Material toolbar band to 60 behind an explicit
   `hasOversizedAction` opt-in, and make `preferredSize` track it.

Component contract decided in `../architecture/solution.md` §1: **explicit
opt-in constructor parameter**, not marker/type inspection. Reason: the real
call site wraps the FAB in `Semantics`, which defeats a `is CupidAddAction`
test while the unwrapped AC2 test would still pass.

## Phase Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| P1 | mobile-dev | mobile | NONE | No | `mobile/lib/design_system/adaptive/cupid_header.dart`, `mobile/lib/features/dream_jar/presentation/screens/dream_jar_list_screen.dart`, `mobile/test/design_system/adaptive_widgets_test.dart`, `mobile/test/features/dream_jar/presentation/dream_jar_list_screen_test.dart` | `../architecture/solution.md` §1-§5, `../requirements/requirements.md` AC1-AC4, `../ux/uiux-spec.md` "Secondary, complementary fix" | `hasOversizedAction` opt-in contract on `CupidHeader`; conditional 60pt Material band tracked by `preferredSize`; Dream Jar header actions emptied; AC2 pin flipped to `Size(60, 60)`; new AC1 + AC4 regression tests | `cd mobile && flutter analyze` + `flutter test test/design_system/adaptive_widgets_test.dart test/features/dream_jar/ test/features/account/presentation/screens/profile_edit_screen_test.dart` | DONE |

Single phase rationale: four files, one behavior cluster, one specialist
lifecycle. The design-system contract and its only two consumers must land in
the same commit — splitting them would leave `main` with either a clamped FAB or
an unconsumed parameter. No trailing verification phase: P1's own test scope is
the verification.

P1 status note (2026-08-19): `DONE`. `flutter analyze` clean, named test scope
115/115 (`coding-plan/test-results.md`), visual fidelity `PASS` with both
AC1-bearing states captured on `emulator-5560`
(`../visual-fidelity/visual-fidelity-report.md`). Touched files are the four in
the phase write scope plus `mobile/lib/main_preview.dart`, added under an
explicit Scrum Master write-scope extension to make those two states renderable
(`PREVIEW_JARLIST_FIXTURE=empty|ready`); the first pass had stopped at
`MOBILE_VISUAL_AUDIT_SCREEN_UNREACHABLE` rather than take that file
unilaterally. The visual-fidelity report also records 11 pre-existing,
out-of-scope `jarlist` design deviations no open story owns, and recommends a
new RWB item for them.

## Phase Files

- `phase-P1-cupid-header-oversized-action-contract.md`

## AC Coverage Map

| AC | Phase | Evidence |
| --- | --- | --- |
| AC1 (Dream Jar header carries no `CupidAddAction`) | P1 | new test in `dream_jar_list_screen_test.dart` |
| AC2 (pin flips to explicit correct `Size`) | P1 | `adaptive_widgets_test.dart` asserts `const Size(60, 60)` |
| AC3 (`CupidAddAction` intrinsic 60x60 unchanged elsewhere) | P1 | `cupid_add_action.dart` untouched; existing tests at `adaptive_widgets_test.dart:554-612` pass unmodified |
| AC4 (other `CupidHeader.actions` consumers unchanged) | P1 | `hasOversizedAction` defaults `false`; new default-band test; `profile_edit_screen_test.dart` passes unmodified |

## Cross-Phase Invariants

- Do not modify `mobile/lib/design_system/adaptive/cupid_add_action.dart`.
- Do not modify `gallery_empty_view.dart` or `expense_history_screen.dart`.
- Do not change `kToolbarHeight` or any global theme `toolbarHeight`.
- The band value is exactly `60`. See `../architecture/solution.md` §2 for why a
  larger value creates a new deviation.
- No e2e, Playwright, emulator, or device-farm gate in any test scope.
