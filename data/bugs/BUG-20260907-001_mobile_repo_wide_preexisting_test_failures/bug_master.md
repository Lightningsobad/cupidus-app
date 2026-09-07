# Bug Master: BUG-20260907-001 Mobile Repo-Wide Pre-Existing Test Failures (13 tests)

Status: PENDING
Severity: non-blocking to REQ-016 stories (pre-existing, confirmed identical at
each surfacing story's own BaseHead, out of each surfacing story's write
scope); blocking to the repo-wide full-suite `flutter test` build-evidence
gate whenever a mobile-dev run's session executes it
Source: Alex-Mobile-Dev (mobile-dev), REQ-016/STORY-003 `Mode:
mobile-implementation` run, reported as `BLOCKER: PREEXISTING_TEST_FAILURE`
Created: 2026-09-07
Linked Requirement: N/A (pre-existing defects unrelated to REQ-016; first
surfaced during REQ-016_solo_stage1_relationship_assistant delivery)
Linked Story: surfaced by REQ-016/STORY-003_private_journal (Phase P1); may
also surface independently on REQ-016/STORY-001_activity_card_hub or any
other branch that runs the full mobile test suite

## Report

Observed behavior:
`flutter test` (full suite) exits 1 with 13 failures across 6 unrelated
feature areas. All 13 reproduce identically on a detached checkout of
`BaseHead` (`28a3f22a5559a03014ab0a5c1b559c0693ee56b1`), so none is caused by
the surfacing story. Full per-suite commands, counts, and BaseHead re-run
proof are in
`data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-003_private_journal/coding-plan/test-results.md`
sections 4, 5A, 5B (git diff --stat proof the failing tests and the
production files they exercise are byte-for-byte unchanged since BaseHead).

Failure anchors (13 tests, 6 domains):
1. `test/design_system/shared_backdrop_occlusion_guard_test.dart` (AC2) —
   flags `lib/features/reminders/presentation/screens/reminder_schedule_screen.dart:79`
   `Scaffold(backgroundColor: palette.colorBackground)`
2. `test/design_system/shared_backdrop_occlusion_test.dart` — "chat shows the
   shared sky wash despite its persistent bottom chrome" — `pumpAndSettle`
   timed out
3-6. `test/features/auth/` (4 tests, incl. `data/auth_repository_test.dart`)
   — `[core/no-app] No Firebase App '[DEFAULT]' has been created` via
   `auth_repository.dart:230`/`:173`; welcome-screen twinkle/backdrop opacity
   `0.7411` vs expected `1.0 ± 0.02`
7. `test/features/love_contracts/presentation/love_contract_screen_test.dart`
   — semantics label expected in English, screen renders Vietnamese ("Luôn
   nói thật với nhau")
8. `test/features/love_contracts/presentation/love_contract_bloc_test.dart` —
   expected 1 clause, got 2
9. `test/features/love_contracts/presentation/screens/love_contract_particle_dots_test.dart`
   — opacity `0.2549` vs expected `1.0 ± 0.02`
10-11. `test/features/zodiac/presentation/zodiac_red_flag_screen_golden_test.dart`
   — golden pixel drift 212px (0.06%) and 158px (0.04%)
12. `test/features/gallery/gallery_cubit_test.dart` ("AppShell gallery
   destination") — finder found 0 widgets with text "Gallery"
13. `test/features/in_app_notifications/presentation/dialogs_theme_test.dart`
   ("AlarmRequestDialog adopts active theme colors") — finder found 0 widgets
   with text "Hẹn Giờ Báo Thức Đôi"

Expected behavior:
`flutter test` (full suite) exits 0. Each domain above needs its own,
separate root-cause fix (Firebase test-harness init, l10n string drift,
golden baseline refresh, shell label/theme lookup, backdrop occlusion
guard) — this is not one bug, but is tracked as one intake row until
triaged/split by a bug-fixer.

Reproduction steps or command:
```
cd mobile && flutter test --no-pub --reporter compact
```
or the exact bounded per-directory command list in test-results.md section 4.

Proof this is pre-existing, not introduced by the surfacing story:
- Detached checkout of REQ-016/STORY-003 BaseHead
  `28a3f22a5559a03014ab0a5c1b559c0693ee56b1`; all 13 failures reproduce there
  with identical assertion text, pixel counts, and opacity values.
- `git diff --stat` from that BaseHead against every failing test path and
  the production files it exercises (`lib/features/{reminders,chat,auth,
  love_contracts,zodiac,gallery,in_app_notifications}`, `lib/app`) returns
  empty — byte-for-byte unchanged.
- The failing suites span 6 feature areas with no relationship to
  REQ-016's mobile-only ActivityCards/Journal scope.

Why not fixed inline by the reporting agent:
Each failure needs a different root-cause investigation (Firebase test-double
wiring, ARB/localisation string audit, golden baseline decision, shell label
lookup, occlusion guard exemption or backdrop fix) — none of the touched
files are in the surfacing story's declared write scope, and mixing 6
unrelated fixes into a story branch would blow story scope.

## Artifacts

- [ ] Diagnosis (Bug Fixer)
- [ ] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: bug-fixer, when queued via `fix bugs` (not required to unblock
  REQ-016 story delivery — see Resolution below)
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md` (not created; needs bug-fixer triage — likely
  splits into multiple bugs, one per domain)
- Fix Evidence: `fix-evidence.md` (not created)
- Review Report: `review/review-report.md` (not created)
- Checkpoint: tracked in
  `data/requirements/REQ-016_solo_stage1_relationship_assistant/scrum-master-checkpoint.md`
- Origin: REQ-016/STORY-003_private_journal mobile-dev run
  (`data/runtime/parallel-runs/RUN-REQ-016_solo_stage1_relationship_assistant-STORY-003_private_journal-mobile-dev.json`,
  status `BLOCKED`)

## Resolution (not yet started — non-blocking to REQ-016 delivery)

- REQ-016 story branches (STORY-001, STORY-003, and any sibling that hits the
  same full-suite gate) may cite this bug id as the tracked, pre-existing,
  out-of-scope justification for a non-zero full `flutter test` exit, and
  should verify regression via SCOPED/targeted test commands instead of the
  combined full-suite run (per the repo's known build-evidence-gate session
  lock: a red combined-test run can lock a session's Stop gate even when the
  red tests are proven pre-existing and out of scope). Do not re-run the full
  combined suite from inside a story worktree once this bug is on record for
  that story's evidence file.
- No `bug-fixer` dispatch is required to unblock REQ-016 delivery. Queue this
  bug through `fix bugs` when repo-wide test health work is prioritized.

## Blockers

- N/A
