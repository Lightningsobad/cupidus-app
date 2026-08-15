# Scope Gate: BUG-20260815-001 ADR-004 No-Fork Guard Red — Raw Color Literals

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: bugfix-review
Bug id: BUG-20260815-001_no_fork_guard_raw_color_violations
Reviewer: Iris-QC
Date: 2026-08-15

Review report path:
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit/data/bugs/BUG-20260815-001_no_fork_guard_raw_color_violations/review/review-report.md`

Work location: integration worktree
`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`
Branch: `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`
Diff basis: uncommitted worktree diff (`git -C <worktree> diff` + one untracked
file). No committed BaseHead range exists for this patch; the 5 modified +
1 new file are the entire patch.

## Evidence Files In Scope

| File | Read mode |
| --- | --- |
| `data/bugs/BUG-20260815-001_.../bug_master.md` (control checkout — absent from this worktree) | full (small) |
| `<worktree>/data/bugs/BUG-20260815-001_.../diagnosis.md` | full (small) |
| `<worktree>/data/bugs/BUG-20260815-001_.../fix-evidence.md` | full (small) |
| `data/bugs/BUG-20260815-001_.../scrum-master-checkpoint.md` (control checkout) | targeted |
| `git -C <worktree> diff -- mobile/` + `git status --porcelain` | full patch |

## Source/Test Files In Scope (max 12; 9 planned)

| # | File | Read mode |
| --- | --- | --- |
| 1 | `mobile/lib/design_system/tokens/on_accent_palette.dart` (new) | full (tiny) |
| 2 | `mobile/lib/design_system/design_system.dart` | diff hunk only |
| 3 | `mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart` | ranged around `:205-220`, `:405-420` |
| 4 | `mobile/lib/features/account/presentation/screens/notification_settings_screen.dart` | ranged around `:350-368` |
| 5 | `mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart` | ranged around `:25-40`, `:440-468` |
| 6 | `mobile/lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart` | ranged around `:60-82` |
| 7 | `mobile/test/design_system/no_fork_guard_test.dart` | targeted — forbidden pattern list, scanned dirs, exemptions |
| 8 | `mobile/lib/features/love_contracts/presentation/widgets/add_clause_sheet.dart` | ranged `:15-25` — claimed `_transparent` precedent |
| 9 | `mobile/lib/design_system/tokens/splash_palette.dart` | ranged — claimed additive-palette precedent |

Out of scope: story artifacts (bug not linked to a single story's ACs), the
whole `flutter test` suite, the 8 unrelated RED tests (BUG-20260814-003,
BUG-20260814-004, BUG-20260815-002), REQ-002 requirement artifacts.

## Focused Query Keys For Phase 2

- `OnAccentPalette` — declaration value + all 4 call sites + barrel export
- `_transparent` — declaration and the 3 `reminder_schedule_screen.dart` uses
- `MaterialType.transparency` — chip site + existing repo call-site count
- `Colors.` / `Color(0x` — residual occurrences inside the 6 changed files
- forbidden pattern list + exempt directory list in `no_fork_guard_test.dart`
- `## Pre-Fix Reproduction Gate`, `## Original Failure Recheck Gate`,
  `## Build Gate`, `## Runtime Startup Gate`, `## Regression Evidence`

## Touched Risk Surfaces And Critical Gates

| Risk surface | Critical gate | Source of truth |
| --- | --- | --- |
| Shared design-system abstraction (new exported token) | sibling call-site consistency + repo-wide guard scan green | `no_fork_guard_test.dart`, barrel export |
| Mobile interaction / rendering (4 screens+widgets) | scoped widget/design-fidelity regression tests | fix-evidence `## Regression Evidence` |
| Mobile build | `flutter build apk --debug` + scoped `flutter analyze` | fix-evidence `## Build Gate` |
| App lifecycle / runtime startup | emulator install + resumed-activity readiness + shutdown | fix-evidence `## Runtime Startup Gate` |
| Original reported failure | same-modality guard-test recheck (original bug WAS a test failure, so test modality is the native modality, not a fallback) | fix-evidence `## Original Failure Recheck Gate` |

Not applicable: persistence/schema/migration, external integration, async job,
security/auth, deep link/push, operational command changes, deployment
configuration guide (no setup/config surface touched — pure in-app color
constant substitution).

Rule 12e2/12e3 rendered visual fidelity: not triggered. This is a
`bugfix-review`, not a UI-bearing story review, and every substitution is
asserted value-identical; Phase 2 verifies that identity claim in code instead.

## Named Judgment Calls To Adjudicate In Phase 2

1. One shared additive token `OnAccentPalette.foreground` for 3 pure-white
   on-gradient sites vs 3 per-screen palettes.
2. `Color.fromARGB(0, 0, 0, 0)` / `Material(type: MaterialType.transparency)`
   for the 4 "no paint" sites — legitimate reuse of an existing merged repo
   idiom, or a substring-level pass around the guard.

## Gate Decision

Phase 2 may proceed. All three governing bugfix artifacts exist, the changed
file set (6) is well inside the review budget, and every declared verification
gate has a recorded command plus result to verify.
