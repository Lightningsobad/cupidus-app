# STORY-060 — Master Coding Plan

Story: `REQ-002_screen_flow_and_design_fidelity_audit/STORY-060_contract_particle_dots_disposition`
Story-Class: standard
Lane: mobile-dev only (no backend, frontend, or devops work)
Architecture: `../architecture/solution.md` (read it before P1)

## Scope Summary

The three ambient twinkle dots the design canvas authors at its shared root
app-shell (`Cupid Screens.dc.html:44-47`) are **already implemented** in this
repo, at the correct shared layer, with the correct geometry and animation
tokens. They are invisible on the `contract` screen because
`CupidAppBackground` paints them **below** the Navigator, while the canvas
source paints them **above** each screen's own opaque surfaces.

This story fixes the paint order at the shell (P1) and removes the two
per-screen copies that the paint-order bug forced earlier stories to add, which
would otherwise double-render after P1 (P2).

No new widget, token, color, duration, or geometry value is introduced. If you
find yourself writing a `Positioned` dot or a `0.14`/`#FFD9EA` literal, stop —
you are on the wrong path; see `architecture/solution.md` DEC-1/DEC-2.

## Phase Overview

**P1 — Shell particle paint order + `contract` AC2 conformance test.**
Move `_CupidSkyStars` above `widget.child` in `CupidAppBackground`'s `Stack`,
correct the widget's dartdoc, pin the paint order in the shell's own test, and
add the `contract`-scoped pixel-probe test AC2 names. 3 files.

**P2 — Consolidate the duplicate star implementation.**
Remove the now-redundant `CupidStarField` mounts from `welcome_screen` and
`vow_screen`, delete the widget and its barrel export, and re-point the two
tests that asserted it at the shell layer. 6 files.

P1 must land before P2: P1 alone leaves `welcome`/`vow` with doubled dots, P2
alone leaves them with none.

## Phase Status

| Phase | Status | Evidence |
| --- | --- | --- |
| P1 | DONE | `flutter analyze` clean (3 files); `flutter test` 14/14 pass incl. pre-fix failure check proving the pins are real (`coding-plan/test-results.md`) |
| P2 | DONE | `flutter analyze` clean (5 items); `flutter test` 25/25 pass incl. pre-fix failure check; full-suite regression 1319 passed/2 skipped/0 failed vs STORY-057's 1314/2 baseline (`coding-plan/test-results.md`) |

Visual-fidelity evidence owed below: captured, `VISUAL_FIDELITY: PASS`
(`../visual-fidelity/visual-fidelity-report.md`).

## Phase Files

- `phase-P1-shell-particle-paint-order.md`
- `phase-P2-consolidate-star-field.md`

## AC Coverage Map

| AC | Phase | Evidence |
| --- | --- | --- |
| AC1 (disposition recorded) | — | already satisfied by `ux/uiux-spec.md`; no code |
| AC2 (`contract` renders the 3 ambient dots, matching the design reference, evidence scoped to screen id `contract`) | P1 | `love_contract_particle_dots_test.dart` + a fresh `contract` implemented-state capture in `visual-fidelity/` |
| AC3 (`NOT_APPLICABLE` branch) | — | does not apply; disposition is SHIP IT |

## Cross-Phase Invariants

- The star layer stays wrapped in `ExcludeSemantics` + `IgnorePointer` +
  `RepaintBoundary` (`pointer-events:none` in the source). Never remove them.
- The star layer keeps honouring `MediaQuery.disableAnimations`
  (`cupid_app_background.dart:42-54`). Widget tests that need
  `pumpAndSettle` rely on it.
- `mobile/lib/design_system/tokens/cupid_sky_palette.dart` is read-only for
  this story.
- The `contract` screen itself receives **no production code change**. Any diff
  under `mobile/lib/features/love_contracts/` means the fix was misscoped.
- No literal colors in `lib/` — the repo runs a forbidden-literal-color guard
  (see `vow_screen.dart:160-163`). P1/P2 add no new color literals at all.

## Visual-Fidelity Evidence Owed (mobile-dev)

AC2 requires evidence scoped to screen id `contract`. The design reference
already exists and is byte-locked (`sha256` `2acd1045…14b3`) — **do not
re-render it**. Capture only a NEW implemented-state PNG of the `contract`
screen after P1+P2 and diff it against that existing reference:

- Existing reference (do not regenerate):
  `../visual-fidelity/design-reference-contract-myunsigned-android.png`
- New capture owed:
  `../visual-fidelity/implemented-contract-requesterunsigned-emulator-5560.png`
  (refresh; the current file predates the fix)
- Report: `../visual-fidelity/visual-fidelity-report.md`, stating explicitly
  whether the three dots now appear at the reference's positions.

The evidence harness (`mobile/lib/main_preview.dart:1496`) mounts the same
`CupidAppBackground`, so the fix reaches the capture with no harness change.
`main_preview.dart` is out of write scope.
