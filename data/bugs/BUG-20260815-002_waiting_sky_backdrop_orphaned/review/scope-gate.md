# Scope Gate: BUG-20260815-002 Waiting Screen `_SkyBackdrop` Orphaned

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: `bugfix-review`
Bug id: BUG-20260815-002_waiting_sky_backdrop_orphaned
Reviewer: Iris-QC
Review report path: `data/bugs/BUG-20260815-002_waiting_sky_backdrop_orphaned/review/review-report.md`
Work location: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Diff baseline: uncommitted working tree vs branch HEAD (`git diff`), per handoff.

## Governing Inputs (already read)

- `data/bugs/BUG-20260815-002_waiting_sky_backdrop_orphaned/bug_master.md` (control checkout)
- `diagnosis.md` (integration worktree) — `## Pre-Fix Reproduction Gate`, `## Root Cause`,
  `## Delete-and-Retarget vs. Restore — Evidence`, `## Coverage Mapping`, `## Not In Scope`
- `fix-evidence.md` (integration worktree) — `## Original Failure Recheck Gate`,
  `## Build Gate`, `## Runtime Startup Gate`, `## Regression Evidence`

## Source/Test Files In Scope

| File | Why |
| --- | --- |
| `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart` | Only changed production file (218 deletions) |
| `mobile/test/features/pairing/presentation/screens/waiting_screen_design_fidelity_test.dart` | Only changed test file (retargeted assertions) |
| `mobile/lib/design_system/tokens/cupid_sky_palette.dart` | Read-only: verify value-for-value equivalence claim |
| `mobile/lib/design_system/decorations/cupid_app_background.dart` | Read-only: verify twinkle curve, theme selection, reduce-motion claim |
| `mobile/lib/app/cupid_app.dart` (`:58-59`) | Read-only: verify successor really mounts above every route |
| Deleted `_SkyBackdrop` subtree via `git show HEAD:<waiting_screen.dart>` | Source of truth for what the successor must preserve |

## Evidence Files In Scope

- `diagnosis.md` reproduction gate + equivalence tables
- `fix-evidence.md` recheck / build / runtime-startup / regression sections
- `data/bugs/master_bugs_list.md` — verify the `BUG-20260814-003` scope-attribution claim
- `mobile/test/design_system/cupid_app_background_test.dart` — verify the claimed new owners of retired assertions exist

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | How verified |
| --- | --- | --- |
| Mobile UI rendering (dead-code removal) | Proof the deleted code was truly unreferenced | Independent `git grep` in the patched tree + analyzer delta |
| Mobile regression suite (stale test retarget) | Same-modality test recheck; non-vacuous assertions | Independent rerun of the changed suite + read of the new finder chain |
| Design-system contract (visual intent preservation) | Value-for-value equivalence of successor vs deleted painter | Independent read of both value sets, not the diagnosis tables |
| Static analysis | 0 warnings after patch, no new `unused_element` | Independent `flutter analyze` |
| App lifecycle / runtime startup | App boots on device without crash | `fix-evidence.md` Runtime Startup Gate (registry-backed) |
| Build | `flutter build apk --debug` | `fix-evidence.md` Build Gate |

Not applicable: design-fidelity rendered-screenshot gate (12e2/12e3) — this is a
bugfix review, not a UI-bearing story review, and the patch removes only
unreferenced code plus test scaffolding; no rendered output changes.

## Query Keys For Phase 2

- `_SkyBackdrop`, `_CssEllipse`, `_TwinkleStar`, `_skyPurpleWash`, `_skyMagentaWash`, `_skyTealWash`
- `waiting_sky_backdrop`
- `CupidSkyPalette.darkLayers`, `lightLayers`, `stars`, `twinkleMin/MaxOpacity`, `twinkleMin/MaxScale`
- `CupidSkyPainter`, `CupidAppBackground`, `disableAnimations`
- `scaffoldBackgroundColor`
- `BUG-20260814-003`, `waiting_screen_design_fidelity_test.dart:238`

## Decision

Phase 2 may proceed. Handoff is within `bugfix-review` budget: 2 changed files,
4 read-only reference files, no governing artifact over ~20 KB requiring a full
read.
