# Bug Master: BUG-20260924-001 `test/design_system/` Repo-Wide Pre-Existing Reds (3 files, confirmed at STORY-007 P3 BaseHead)

Status: PENDING
Severity: non-blocking to REQ-016 stories (pre-existing, confirmed identical at
the surfacing story's own BaseHead, out of that story's write scope); blocking
to the full-repo combined `flutter test` build-evidence gate whenever a
mobile-dev run's session executes it unscoped
Source: Alex-Mobile-Dev (mobile-dev), REQ-016/STORY-007 `Mode:
mobile-implementation` run (phase P3), reported via
`coding-plan/test-results.md` "Hồi quy toàn bộ app — 3 test đỏ có sẵn, không
thuộc P3"
Created: 2026-09-24
Linked Requirement: REQ-016_solo_stage1_relationship_assistant
Linked Story: surfaced by REQ-016/STORY-007_thank_you_and_next_plan (Phase P3);
root cause spans two pre-existing families already tracked elsewhere, not a
new/unrelated defect and not caused by P3's own scope — see Root-Cause Family
below

## Report

Observed behavior:
Full-repo `flutter test --reporter failures-only` exits 1 with 3 failures, all
in `test/design_system/`, none of them naming a file P3 touched:

- `no_fork_guard_test.dart` — 9 raw `Colors.`/`Platform.is` violations across
  `context_notebook`, `compatibility_lookup`, `activity_card_detail_screen`,
  `quick_capture_sheet`, `your_view_portrait`, `frame_chip_strip`,
  `gift_ideas`, `service_locator`.
- `shared_backdrop_occlusion_guard_test.dart` — 3 screens with solid
  background fills: `chapter_closure`, `activity_card_detail_screen`,
  `reminders`.
- `shared_backdrop_occlusion_test.dart` — a chat-related test's
  `pumpAndSettle` timed out.

Expected behavior:
These 3 suites should be green, or at minimum should not regress further as
new screens/components are added, independent of REQ-016/STORY-007 P3's own
scope.

Reproduction steps or command:
```
cd mobile && flutter test --reporter failures-only
```

Proof this is pre-existing, not introduced by the surfacing story:
- `git diff --name-only 5fa0e972bf21ab1e38bd05d5a381e21d90fa97c5` (STORY-007
  P3's own BaseHead) for this phase's diff lists only
  `thank_you_block.dart`, `preset_content_gate.dart`, two test files, this
  story's own visual-fidelity PNG, and 3 new files (asset pack,
  `thanks_section.dart`, `thanks_section_test.dart`) — none of the 3 failing
  suites, and none of the screens/files they name.
- `test/core` (320 tests) ran fully green in the same session.
- Scoped runs limited to P3's own touched directories
  (`test/features/invite_composer`, `test/features/activity_cards/thank_you`)
  are fully green (`+123`, `+82 ~1`).

Why not fixed inline by the reporting agent:
The named files (`context_notebook`, `compatibility_lookup`,
`activity_card_detail_screen`, `quick_capture_sheet`, `your_view_portrait`,
`frame_chip_strip`, `gift_ideas`, `service_locator`, `chapter_closure`,
`reminders`, chat) are outside STORY-007/P3's declared WriteScope
(`activity_cards/thank_you/`, `invite_composer/domain/preset_content_gate.dart`
only), and the root causes belong to other, already-tracked domains.

## Root-Cause Family

- `no_fork_guard_test.dart` (9 violations): same guard/root-cause family as
  `BUG-20260815-001_no_fork_guard_raw_color_violations` (DONE) and
  `BUG-20260825-002_no_fork_guard_pet_preview_card_color_literal` (PENDING) —
  ADR-004 no-fork/raw-color guard drift as new screens are added across
  sibling stories/branches. The specific file/violation set here (8 different
  components, 9 violations) does not overlap either prior bug's named files
  (`ghost_settings_screen.dart`, `notification_settings_screen.dart`,
  `reminder_schedule_screen.dart`, `reminder_weekday_chips.dart`,
  `pet_preview_card.dart`), so it is recorded as its own confirmation snapshot
  rather than folded silently into a closed/narrower bug.
- `shared_backdrop_occlusion_guard_test.dart` /
  `shared_backdrop_occlusion_test.dart`: same "design_system backdrop
  occlusion" domain already tracked at a much earlier baseline by
  `BUG-20260907-001_mobile_repo_wide_preexisting_test_failures` (PENDING,
  confirmed at REQ-016/STORY-003 BaseHead `28a3f22a`). Re-confirmed here at a
  much later BaseHead (`5fa0e972`), so the drift is still present after many
  intervening merges; recorded as a fresh dated snapshot per this repo's
  established convention (see `BUG-20260923-001`/`BUG-20260923-002`, both
  separately dated snapshots of already-known families).

## Artifacts

- [ ] Diagnosis (Bug Fixer)
- [ ] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: bug-fixer, when queued via `fix bugs` (not required to unblock
  REQ-016 story delivery — see Resolution below)
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md` (not created; needs bug-fixer triage, likely
  split by family — no-fork guard literals vs. backdrop occlusion)
- Fix Evidence: `fix-evidence.md` (not created)
- Review Report: `review/review-report.md` (not created)
- Checkpoint: tracked in
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/scrum-master-checkpoint.md`
- Origin: REQ-016/STORY-007_thank_you_and_next_plan mobile-dev run, phase P3
  (`data/runtime/parallel-runs/RUN-REQ-016_solo_stage1_relationship_assistant-STORY-007_thank_you_and_next_plan-mobile-dev-P3.json`)

## Resolution (not yet started — non-blocking to REQ-016 delivery)

- REQ-016 story branches may cite this bug id as the tracked, pre-existing,
  out-of-scope justification for these 3 known-red suites, and should verify
  their own regression via SCOPED/targeted test commands instead of the
  combined full-repo run (same known build-evidence-gate session-lock pattern
  as `BUG-20260923-001`/`BUG-20260923-002`).
- No `bug-fixer` dispatch is required to unblock REQ-016 delivery. Queue this
  bug through `fix bugs` when repo-wide test health work is prioritized.

## Blockers

- N/A
