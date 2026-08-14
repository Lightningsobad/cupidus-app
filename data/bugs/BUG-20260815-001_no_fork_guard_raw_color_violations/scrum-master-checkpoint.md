# Scrum Master Checkpoint: BUG-20260815-001

Bug id: BUG-20260815-001_no_fork_guard_raw_color_violations
Status: REVIEW_REQUIRED
Attempt count: 1
Continuation count: 0

## Artifact Paths
- Bug master: `data/bugs/BUG-20260815-001_no_fork_guard_raw_color_violations/bug_master.md`
- Diagnosis: `data/bugs/BUG-20260815-001_no_fork_guard_raw_color_violations/diagnosis.md`
- Fix evidence: `data/bugs/BUG-20260815-001_no_fork_guard_raw_color_violations/fix-evidence.md`
- Review: `data/bugs/BUG-20260815-001_no_fork_guard_raw_color_violations/review/review-report.md`

## Failure Anchors
- `ghost_settings_screen.dart:211,411` (STORY-019)
- `notification_settings_screen.dart:359` (STORY-031)
- `reminder_schedule_screen.dart:448,449,452` (STORY-021)
- `reminder_weekday_chips.dart:71` (STORY-021)

## Expected Behavior Source
REQ-002 requirement integration review (Iris-QC), finding I-1 — ADR-004
no-fork/raw-color guard test RED on the integration branch.

Suspected impacted runtime/service/app: mobile-app (Flutter)
Runtime registry: `data/devops/system/runtime-command-registry.json`

Query keys for future bug-fixer handoff: "no_fork_guard", "raw color",
"Color(0x", "ghost_settings_screen", "notification_settings_screen",
"reminder_schedule_screen", "reminder_weekday_chips"

Active Bug Fixer Agent Id: Justin-BugFixer@session-0463b8e0
Bug Fixer Status: COMPLETE (BUG_FIX_COMPLETE: YES)

## Fix Summary (for Reviewer handoff)
Changed files (6, uncommitted in the integration worktree):
- mobile/lib/design_system/tokens/on_accent_palette.dart (new)
- mobile/lib/design_system/design_system.dart (barrel export)
- mobile/lib/features/chat/presentation/screens/ghost_settings_screen.dart (:211,:411)
- mobile/lib/features/account/presentation/screens/notification_settings_screen.dart (:359)
- mobile/lib/features/reminders/presentation/screens/reminder_schedule_screen.dart (:448,449,452)
- mobile/lib/features/reminders/presentation/widgets/reminder_weekday_chips.dart (:71)

Gates: Pre-Fix Reproduction REPRODUCED (7/7 anchors matched), Original Failure
Recheck PASS (test modality, same as reported — original bug was itself a
guard-test failure), Build PASS (`flutter build apk --debug` + `flutter
analyze` clean on changed files), Runtime Startup PASS + Shutdown PASS
(emulator-5560), scoped Regression +82~1-0.

Correction vs original bug report: only 1/7 anchors is a literal `Color(0x`;
the other 6 are `Colors.*` constants. Same ADR-004 family, anchor set
unchanged.

Two open judgment calls for Reviewer:
1. Added one shared additive token `OnAccentPalette.foreground` (mirrors
   existing SplashPalette/CouplePresencePalette precedent) instead of 3
   per-screen palettes for the 3 pure-white-on-gradient sites.
2. `Color.fromARGB(0, 0, 0, 0)` / `MaterialType.transparency` used for the 4
   "no paint" sites, following existing merged precedent
   (`add_clause_sheet.dart:21`, ~15 existing transparent-ink-host call sites) —
   Reviewer should confirm this is not guard evasion vs. a design-system
   addition.

Full-suite `flutter test` after patch: `+1232 ~2 -8`. `no_fork_guard_test.dart`
now GREEN. Remaining 8 RED tests confirmed pre-existing/unrelated, all already
mapped to other bugs: BUG-20260814-003 (4x caption typography), BUG-20260815-002
(1x waiting_sky_backdrop), BUG-20260814-004 anchor (a) (1x ADR-002 copy guard),
and BUG-20260814-002 (2x home_screen_ready_signal — `feature_flags_test.dart`,
`widget_test.dart`; bug-fixer flagged this family as possibly unmapped, but it
is already covered by BUG-20260814-002's I-4 annotation from this same round).

Work location: this bug must be fixed directly in the REQ-002 integration
worktree (`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`,
branch `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`),
not a fresh story worktree — the violation is only visible once all 3
owning stories are merged together.

Priority: blocking REQ-002 DONE. Iris-QC's requirement integration review
(`Outcome: PATCH_REQUIRED`) states the RED `flutter test` suite is the
primary proof gate under SKILL 12c and cannot be recorded DEFERRED_ONLY —
this bug must reach `Status: DONE` (or be conclusively shown not to affect
the RED test count) before the next integration review can pass.
