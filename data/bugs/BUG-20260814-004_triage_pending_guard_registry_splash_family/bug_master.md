# Bug Master: BUG-20260814-004 Triage-Pending: Guard-Red / Registry Mismatch / Splash Compile Error

Status: REPORTED
Severity: blocking (anchor (a) reconfirmed by REQ-002 requirement integration
review finding I-2 as the same `"Synced Alarm"` banned-string guard-red still
present in `permissions_screen.dart`; part of the RED `flutter test` suite
that must be fixed before DEFERRED_ONLY/CLEAN is possible per SKILL 12c.
Anchors (b) and (c) severity remains unknown pending bug-fixer triage.)
Source: REQ-002 STORY-002 round-3 audit — possible shared root-cause family,
NOT yet triaged into one bug vs three separate bugs. Anchor (a) independently
reconfirmed by Iris-QC's REQ-002 requirement integration review, finding I-2.
Created: 2026-08-14
Linked Requirement: REQ-002_screen_flow_and_design_fidelity_audit
Linked Story: STORY-007, STORY-009, STORY-001/STORY-002 (mixed; see anchors)

## Report

Observed behavior:
Three separate pre-existing failures, suspected but NOT confirmed to share a
root cause. Bug-fixer must determine during diagnosis whether this is one bug
or three; do not assume commonality without investigation.

(a) STORY-007 guard-red: `no_fork_guard_test.dart` and
`reminder_copy_guard_test.dart` fail on the banned string `"Synced Alarm"`
found in `permissions_screen.dart:80-81`.

(b) STORY-009 registry-vs-code mismatch: `main_preview.dart`'s
`_notImplementedCanvasIds` may still list `permissions` even though it is
implemented.

(c) `splash_design_fidelity_test.dart` fails to compile: `SplashScreen` is
missing a `resolvePairingStatus` named parameter expected by the test;
pre-existing, likely STORY-001/002 scope.

Expected behavior:
(a) Guard tests pass (no banned copy string present).
(b) Registry accurately reflects implemented canvases.
(c) `splash_design_fidelity_test.dart` compiles and the `SplashScreen` widget
exposes whatever contract the test expects.

Reproduction steps or command:
Not run by Scrum Master (intake only). Candidate: run each named test file in
`mobile/` individually.

Failure anchors:
- Stack trace: N/A
- Failing test:
  - `no_fork_guard_test.dart`
  - `reminder_copy_guard_test.dart`
  - `splash_design_fidelity_test.dart` (compile error)
- Route/endpoint/component/job:
  - `permissions_screen.dart:80-81` (banned string)
  - `main_preview.dart` `_notImplementedCanvasIds` (registry)
  - `SplashScreen` widget / `resolvePairingStatus` named param
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
- Origin checkpoint: `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/scrum-master-checkpoint.md` § Cross-Story / Infra Findings
- Note: this is distinct from `BUG-20260801-007` (DONE), which fixed a
  different `"Synced Alarm"` occurrence in REQ-001 STORY-016 ARB copy. This
  finding (a) is a separate REQ-002 STORY-007 occurrence in
  `permissions_screen.dart`.
- Priority: anchor (a) is blocking REQ-002 DONE (SKILL 12c test-gate
  reasoning) per Iris-QC's requirement integration review
  (`Outcome: PATCH_REQUIRED`, finding I-2: "Same family as
  BUG-20260814-004" anchor (a)). Fix directly in the REQ-002 integration
  worktree
  (`/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-002_screen_flow_and_design_fidelity_audit`,
  branch `codex/REQ-002_screen_flow_and_design_fidelity_audit-integration`),
  not a fresh story worktree.

## Blockers

- N/A
