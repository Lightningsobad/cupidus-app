# Bug Master: BUG-20260814-002 `waiting` Screen Used As Login-Resume Target

Status: REPORTED
Severity: unknown
Source: Tech Lead pre-disclosure (P1-F3), surfaced during REQ-002 STORY-002 audit
Created: 2026-08-14
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: STORY-002 (candidate; resume-logic owner not yet confirmed)

## Report

Observed behavior:
Login-resume logic can resolve/target the `waiting` screen as a resume
destination.

Expected behavior:
Per Tech Lead finding P1-F3 (pre-disclosed during REQ-002 planning), `waiting`
is not a valid login-resume target.

Reproduction steps or command:
Not run by Scrum Master (intake only). Candidate: exercise the login-resume /
onboarding-progress resolution path (e.g. `OnboardingProgressResolver` or
equivalent) with app state that would currently resolve to `waiting`.

Failure anchors:
- Stack trace: N/A
- Failing test: none identified yet
- Route/endpoint/component/job: login-resume / onboarding-progress resolution
  logic; `waiting` screen
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
