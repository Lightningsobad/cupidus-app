# Scope Gate: BUG-20260814-004 Triage-Pending — Guard-Red / Registry Mismatch / Splash Compile Error

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: bugfix-review
Bug id: BUG-20260814-004_triage_pending_guard_registry_splash_family
Reviewer: Iris-QC
Date: 2026-08-15

Review report path:
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/data/bugs/BUG-20260814-004_triage_pending_guard_registry_splash_family/review/review-report.md`

Work location: REQ-002 integration worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Diff basis: uncommitted worktree diff — 1 modified file (`+2 -2`) plus 2
untracked bug-record files. No committed BaseHead range for this patch.

## Evidence Files In Scope

| File | Read mode |
| --- | --- |
| `data/bugs/BUG-20260814-004_.../bug_master.md` (control checkout) | full (small) |
| `<worktree>/data/bugs/BUG-20260814-004_.../diagnosis.md` | full (small) |
| `<worktree>/data/bugs/BUG-20260814-004_.../fix-evidence.md` | full (small) |
| `data/bugs/BUG-20260814-004_.../scrum-master-checkpoint.md` (control checkout) | targeted |
| `git -C <worktree> diff` + `status --porcelain --untracked-files=all` | full patch |

## Source/Test Files In Scope (max 12; 5 planned)

| # | File | Read mode | Purpose |
| --- | --- | --- | --- |
| 1 | `mobile/lib/features/onboarding/presentation/screens/permissions_screen.dart` | ranged `:70-95` | anchor (a) patch site |
| 2 | `mobile/lib/features/reminders/presentation/reminder_strings.dart` | ranged `:15-25`, `:140-150` | verify the canonical-copy-reuse claim |
| 3 | `mobile/test/features/reminders/reminder_copy_guard_test.dart` | targeted — forbidden tokens, scanned scope, comment/literal handling | guard contract for the independent re-run |
| 4 | `mobile/lib/main_preview.dart` | ranged `:185-250` | independently disprove anchor (b) |
| 5 | `mobile/lib/features/home/presentation/home_screen.dart` | `git grep` only, no full read | independently disprove anchor (c) |

Out of scope: story artifacts, the whole `flutter test` suite, other REQ-002
bugs (BUG-20260814-001/002/003, BUG-20260815-002), and BUG-20260815-001
records (different bug, already DONE at `b4d785f`).

## Focused Query Keys For Phase 2

- `synced alarm` / `Synced Alarm` / `báo thức` / `do not disturb` — residual
  occurrences anywhere under `mobile/lib` (independent guard re-run)
- `Nhắc nhở đồng bộ`, `Synced Reminder` — canonical string in
  `reminder_strings.dart:19,145`
- `_notImplementedCanvasIds`, `permissions` — `main_preview.dart:192,244`
- `resolvePairingStatus` — which widget actually declares it
- `splash_design_fidelity_test` — file existence anywhere under `mobile/`
- `## Pre-Fix Reproduction Gate`, `## Original Failure Recheck Gate`,
  `## Build Gate`, `## Runtime Startup Gate`, `## Regression Evidence`

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Source of truth |
| --- | --- | --- |
| User-facing copy / ADR-002 banned-token contract | `reminder_copy_guard_test.dart` green + independent token sweep of `mobile/lib` | fix-evidence `## Original Failure Recheck Gate` |
| Triage correctness (3 anchors, 2 claimed non-reproducing) | independent re-verification of both negative claims before accepting closure with no follow-up bug | `diagnosis.md` `## Anchor (b) Evidence`, Pre-Fix Reproduction Gate anchor (c) |
| Mobile build | `flutter build apk --debug` + scoped `flutter analyze` | fix-evidence `## Build Gate` |
| App lifecycle / runtime startup | emulator install + resumed-activity readiness + shutdown | fix-evidence `## Runtime Startup Gate` |
| Mobile rendering (onboarding card copy) | scoped regression over onboarding/navigation/reminders/splash/no-fork suites | fix-evidence `## Regression Evidence` |

Not applicable: persistence/schema/migration, external integration, async job,
security/auth, deep link/push, operational commands, deployment configuration
(copy-only change, no setup/config surface). Rules 12e2/12e3 rendered visual
fidelity are not triggered — this is a bugfix review, not a UI-bearing story
review, and no layout, token, or widget structure is touched.

## Special Verification Duty For This Review

A negative reproduction claim closes an anchor without a fix, so it must not be
accepted on trust. Phase 2 must independently establish, from the branch itself:
(b) `permissions` is genuinely absent from `_notImplementedCanvasIds` AND has a
real registered preview entry; (c) `splash_design_fidelity_test.dart` genuinely
does not exist under `mobile/` AND `resolvePairingStatus` is declared by
`HomeScreen`, not `SplashScreen`. If either check contradicts the diagnosis, the
outcome is `PATCH_REQUIRED`.

## Gate Decision

Phase 2 may proceed. All three governing bugfix artifacts exist, the patch is
1 file / 2 lines, and every declared gate has a recorded command plus result.
