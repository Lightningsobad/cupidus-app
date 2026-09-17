# Review Scope Gate: STORY-012 Trạng thái theo pha, widget, và bộ đếm "của cải đang lớn"

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

## Identity

- Review type: `compact-story-review` requested by handoff; gate decision is
  RE-SCOPE to `scoped-slice` passes + `final-synthesis`
- Review report path:
  `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget/data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/review/review-report.md`
- Scope gate path:
  `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-016_solo_stage1_relationship_assistant-STORY-012_phase_status_and_widget/data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/review/scope-gate.md`

## Scope Decision

- Scope status: `STOP`
- Why this review is within budget or why it must stop: it is NOT within budget.
  `git diff --name-only b58afbe0..759c6cbc` returns 76 changed files, of which
  ~55 are source/test/config implementation files, across 12,108 insertions,
  8 phases (P1-P8) and two native platforms (Kotlin + Swift + `project.pbxproj`).
  `compact-story-review` allows at most 8 touched source/test/config files and
  1 large governing artifact over ~20 KB (reviewer SKILL.md rule 1c); even
  `full-story-review` (12 files, 2 large artifacts) is exceeded ~4.5x. The one
  governing evidence artifact, `coding-plan/test-results.md`, is 71 KB on its
  own. `story_master.md:4` records `Complexity: complex`, and the handoff named
  no exact files or query keys. Per rule 1c the gate stops here rather than
  widening; per rule 1b a whole-story sweep without exact files/query keys is
  rejected by default.
- Current story or bug status: `story_master.md:3` `Status: TODO`;
  `Implementation (Development)` checked, `Review (Reviewer)` unchecked.

## Governing Inputs

- Primary artifacts: `story_master.md` (7.4 KB, read in full — small),
  `data/devops/system/design-fidelity-config.json` (read in full — decides
  whether rule 12e2/12e3 applies at all)
- Existing review findings: `N/A` — `review/` did not exist before this pass in
  either the worktree or the control checkout; this is the story's first review.
- Test evidence: `coding-plan/test-results.md` — headings-only grep plus one
  ranged read of lines 330-414 (`### Visual fidelity` and the two decisions the
  implementer escalated). Not full-read: 71 KB, rule 2c.
- Extra artifacts required beyond the default minimum: none. No requirements,
  UX, architecture, or phase file was opened, because Phase 2 is not approved.

## Source/Test Files In Scope

- None for this pass — Phase 2 not approved. One exception was read because the
  handoff named it explicitly and it is a single small file:
  `mobile/test/features/reminders/reminder_copy_guard_test.dart` (the narrowed
  cross-requirement guard), plus a `find` over
  `mobile/lib/features/reminders/**.dart` to prove the guard is non-vacuous.
- Per-slice inventory proposed for the re-scope (all paths relative to the
  Worktree root):
  - S1 `phase-P1` content packages + invariant gate (8 files):
    `mobile/assets/data/req016/phase_content.v1.json`,
    `mobile/assets/data/req016/nudges.v1.json`,
    `mobile/assets/data/req016/drip.v1.json`,
    `mobile/lib/features/phase_status/domain/phase_content.dart`,
    `mobile/lib/features/phase_status/domain/phase_content_gate.dart`,
    `mobile/lib/features/phase_status/data/phase_content_repository.dart`,
    `mobile/test/features/phase_status/phase_content_gate_test.dart`,
    `mobile/test/features/phase_status/phase_content_repository_test.dart`
  - S2 `phase-P2` + `phase-P7` resolver, phase line, countdown (8 files):
    `mobile/lib/features/phase_status/domain/solo_phase.dart`,
    `mobile/lib/features/phase_status/domain/solo_phase_resolver.dart`,
    `mobile/lib/features/phase_status/data/phase_status_prefs.dart`,
    `mobile/lib/features/phase_status/presentation/phase_status_cubit.dart`,
    `mobile/lib/features/phase_status/presentation/phase_status_line.dart`,
    `mobile/test/features/phase_status/solo_phase_resolver_test.dart`,
    `mobile/test/features/phase_status/phase_status_line_test.dart`,
    `mobile/test/features/phase_status/phase_status_prefs_test.dart`
  - S3 `phase-P4` Android widget bridge + provider (7 files):
    `mobile/android/app/src/main/AndroidManifest.xml`,
    `mobile/android/app/src/main/kotlin/com/snapsofts/cupid/CupidPhaseWidgetProvider.kt`,
    `mobile/android/app/src/main/res/layout/cupid_phase_widget.xml`,
    `mobile/android/app/src/main/res/xml/cupid_phase_widget_info.xml`,
    `mobile/lib/features/phase_status/data/home_widget_bridge.dart`,
    `mobile/test/features/phase_status/home_widget_bridge_test.dart`,
    `mobile/test/features/phase_status/native_copy_scan_test.dart`
  - S4 `phase-P5` iOS WidgetKit extension (6 files):
    `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.swift`,
    `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.entitlements`,
    `mobile/ios/CupidPhaseWidget/Info.plist`,
    `mobile/ios/Runner/Runner.entitlements`,
    `mobile/ios/Runner/AppDelegate.swift`,
    `mobile/ios/Runner.xcodeproj/project.pbxproj`
  - S5 `phase-P6` evening check-in + cross-requirement guard narrowing
    (10 files — needs the `full-story-review` file budget, not compact):
    `mobile/lib/features/phase_status/data/local_notification_scheduler.dart`,
    `mobile/lib/features/phase_status/domain/evening_check_in_scheduler.dart`,
    `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart`,
    `mobile/lib/features/account/presentation/screens/notification_settings_screen.dart`,
    `mobile/pubspec.yaml`, `mobile/pubspec.lock`,
    `mobile/test/features/phase_status/evening_check_in_scheduler_test.dart`,
    `mobile/test/features/phase_status/evening_check_in_sheet_test.dart`,
    `mobile/test/features/account/presentation/screens/notification_settings_screen_test.dart`,
    `mobile/test/features/reminders/reminder_copy_guard_test.dart`
  - S6a `phase-P3` counter, milestone J12, drip cadence (7 files):
    `mobile/lib/features/phase_status/domain/wealth_counter.dart`,
    `mobile/lib/features/phase_status/domain/milestone_resolver.dart`,
    `mobile/lib/features/phase_status/domain/drip_cadence_policy.dart`,
    `mobile/test/features/phase_status/wealth_counter_test.dart`,
    `mobile/test/features/phase_status/milestone_resolver_test.dart`,
    `mobile/test/features/phase_status/drip_cadence_policy_test.dart`,
    `mobile/lib/l10n/arb/app_vi.arb`
  - S6b `phase-P8` quiet surfaces + hub/card integration (8 files):
    `mobile/lib/features/phase_status/presentation/wealth_counter_line.dart`,
    `mobile/lib/features/phase_status/presentation/gift_progress_block.dart`,
    `mobile/lib/features/activity_cards/presentation/screens/activity_card_hub_view.dart`,
    `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart`,
    `mobile/lib/features/activity_cards/presentation/widgets/activity_card_tile.dart`,
    `mobile/test/features/phase_status/wealth_counter_line_test.dart`,
    `mobile/test/features/phase_status/gift_progress_block_test.dart`,
    `mobile/test/features/phase_status/quiet_surfaces_capture_test.dart`
  - S7 `final-synthesis` from S1-S6b slice reports, plus
    `mobile/lib/l10n/arb/app_en.arb` and
    `data/requirements/REQ-016_solo_stage1_relationship_assistant/deployment/configuration-guide.md`

## Evidence Files In Scope

- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/story_master.md`
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/coding-plan/test-results.md`
  (query-first only; 71 KB)
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-012_phase_status_and_widget/visual-fidelity/`
  (directory listing: 6 `implemented-*.png`, zero `design-reference-*.png`,
  no `visual-fidelity-report.md`)
- `data/devops/system/design-fidelity-config.json`

## Risk Surfaces And Critical Gates

- Touched risk surfaces: mobile interaction; mobile navigation/discoverability;
  app lifecycle (foreground refresh); permissions/device API (notification
  permission, home-screen widget); local storage/offline
  (`SharedPreferences`, App Group shared container); deep link/push (local
  notification tap route to the journal); external integration (WidgetKit /
  AppWidgetProvider host processes); runtime/configuration (`project.pbxproj`
  target, entitlements, `AndroidManifest`); typed/generated contract
  (the `phase_content`/`nudges`/`drip` v1 asset schemas);
  package-dependencies (`pubspec.yaml`/`pubspec.lock`).
- Source-of-truth artifacts or contracts: `story_master.md` AC-1..AC-8 and the
  R-1(f)/R-1b out-of-scope bans; `requirements/requirements.md` AC-37..AC-39 /
  BR-15..BR-17 (R-15 preset-content rules); `architecture/contract-summary.md`
  (`PhaseWidgetPublisher` port); REQ-002/STORY-021 AC4 as narrowed by the
  2026-09-17 user decision.
- Critical gates to verify: per-slice unit/widget tests (present);
  mobile build/static-analysis evidence; mobile-lane design-fidelity comparison
  (rule 12e2/12e3); entry-point reachability (rule 12e1);
  story runtime startup smoke (rule 12g).
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` — requirement has no
  frontend participation; lane is `mobile`.
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `REQUIRED when requirement had mobile participation`
  — REQ-016 is mobile, so the requirement-level
  `integration-review/mobile-visual-audit.md` remains due at requirement
  closure. It is separate from, and does not substitute for, the per-story
  check below.
- Missing gate evidence or blocker: three gaps confirmed at gate cost, all
  independent of the scope blocker. See findings G-1, G-2, G-3 in
  `review-report.md`.

## Query Keys

- AC ids from `story_master.md`: AC-1 (SB-83 prepare-not-guess, R-1b),
  AC-2 (SB-84 four widget phases), AC-3 (SB-86 countdown),
  AC-4 (SB-85 23h nudge, no repeat when skipped), AC-5 (wealth counter),
  AC-6 (no streak/chain/leaderboard, R-1(f)), AC-7 (notifications off),
  AC-8 (no absence-shaming on return).
- AC ids from `requirements/requirements.md`: AC-9..AC-13 (Group C, widget),
  AC-14/AC-15 (Group D, countdown), AC-33 (Group I, no other-party behaviour
  indicator), AC-37..AC-39 + BR-15..BR-17 (R-15 preset content).
  NOTE: `test-results.md:378-385` records that
  `phase-P7-phase-line-and-countdown.md` §4 cited AC-9..AC-11 and AC-33 for
  the countdown, which the implementer corrected to AC-14/AC-15 — the slice
  reviewer must use the corrected ids, not the phase file's original text.
- Invariants: `R-1(f)`, `R-1b`, `R-15a`, `R-15b`, `R-15c`, `BR-2`, `BR-4`,
  `BR-9`, `BR-14`, `WIDGET-STALE`.
- Symbols: `PhaseWidgetPublisher`, `pushWidgetPayload`, `civilDaysUntil`,
  `PhaseStatusCubit`, `PhaseStatusState`, `_anchorIndex`,
  `_remindersForbiddenImport`.
- Commands: `flutter test test/features/phase_status`,
  `flutter test test/features/reminders/reminder_copy_guard_test.dart`.

## Phase 2 Approval

- Phase 2 may proceed: `NO`
- If `NO`, final review outcome should be: `BLOCKED`
- If `NO`, exact blocker or re-scope instruction:
  `BLOCKER: REVIEW_SCOPE_TOO_BROAD`. Re-dispatch as the seven
  `Reviewer: scoped-slice` passes inventoried above (S5 needs the
  `full-story-review` file budget) followed by one `Reviewer: final-synthesis`
  pass. Close findings G-1, G-2 and G-3 in the mobile-dev / DevOps lane in
  parallel, so no slice pass is spent rediscovering them.
