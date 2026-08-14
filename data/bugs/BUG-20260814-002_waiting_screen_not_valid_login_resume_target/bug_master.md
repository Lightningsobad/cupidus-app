# Bug Master: BUG-20260814-002 `waiting` Screen Used As Login-Resume Target

Status: IN_PROGRESS
Severity: blocking (confirmed and elevated by REQ-002 requirement integration
review finding I-4; 2 RED tests are part of the `flutter test` suite that
must be fixed before DEFERRED_ONLY/CLEAN is possible per SKILL 12c)
Source: Tech Lead pre-disclosure (P1-F3), surfaced during REQ-002 STORY-002
audit; independently confirmed by Iris-QC's requirement integration review
(finding I-4)
Created: 2026-08-14
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: STORY-002 (candidate; resume-logic owner not yet confirmed)

## Report

Observed behavior:
Login-resume logic can resolve/target the `waiting` screen as a resume
destination. Confirmed at requirement integration review (I-4): the
integrated boot never reaches `home_screen_ready_signal` — 2 independent
tests (`widget_test.dart`, `app/feature_flags_test.dart`) find 0 widgets even
with a seeded signed-in + paired session. `git log -S` on the key proves no
REQ-002 commit touched it, so the routing logic itself is the cause, not a
stale/renamed key. This key is also the runtime registry's declared
`inAppFirstScreenSignal`.

Expected behavior:
Per Tech Lead finding P1-F3 (pre-disclosed during REQ-002 planning), `waiting`
is not a valid login-resume target. With a seeded signed-in + paired session,
boot must reach `home_screen_ready_signal` (the registry's
`inAppFirstScreenSignal`), and both `widget_test.dart` and
`app/feature_flags_test.dart` must find that widget.

Reproduction steps or command:
Not run by Scrum Master (intake only). Candidate: exercise the login-resume /
onboarding-progress resolution path (e.g. `OnboardingProgressResolver` or
equivalent) with app state that would currently resolve to `waiting`; run
`widget_test.dart` and `app/feature_flags_test.dart` with a seeded
signed-in + paired session.

Failure anchors:
- Stack trace: N/A
- Failing test:
  - `widget_test.dart` (0 widgets found for `home_screen_ready_signal`)
  - `app/feature_flags_test.dart` (same)
- Route/endpoint/component/job: login-resume / onboarding-progress resolution
  logic; `waiting` screen; `home_screen_ready_signal` /
  `inAppFirstScreenSignal` (registry-declared)
- Environment: mobile (Flutter)

## Artifacts

- [ ] Diagnosis (Bug Fixer)
- [ ] Fix Evidence (Bug Fixer)
- [ ] Review (Reviewer)

## Routing Notes

- Current owner: scrum-master
- Next role: queued for fix-bugs
- Bug Registry: `data/bugs/master_bugs_list.md`
- Diagnosis: `diagnosis.md`
- Fix Evidence: `fix-evidence.md`
- Review Report: `review/review-report.md`
- Checkpoint: `scrum-master-checkpoint.md`
- Origin checkpoint: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/scrum-master-checkpoint.md` § Cross-Story / Infra Findings (P1-F3)

## Blockers

- N/A
