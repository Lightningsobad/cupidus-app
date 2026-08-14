# Scrum Master Checkpoint: BUG-20260814-004

Bug id: BUG-20260814-004_triage_pending_guard_registry_splash_family
Status: REPORTED

## Artifact Paths
- Bug master: `data/bugs/BUG-20260814-004_triage_pending_guard_registry_splash_family/bug_master.md`
- Diagnosis: `data/bugs/BUG-20260814-004_triage_pending_guard_registry_splash_family/diagnosis.md`
- Fix evidence: `data/bugs/BUG-20260814-004_triage_pending_guard_registry_splash_family/fix-evidence.md`
- Review: `data/bugs/BUG-20260814-004_triage_pending_guard_registry_splash_family/review/review-report.md`

## Failure Anchors
- (a) `no_fork_guard_test.dart`, `reminder_copy_guard_test.dart` — banned
  string "Synced Alarm" in `permissions_screen.dart:80-81`
- (b) `main_preview.dart` `_notImplementedCanvasIds` may still list
  `permissions`
- (c) `splash_design_fidelity_test.dart` compile error — `SplashScreen`
  missing `resolvePairingStatus` named param

## Expected Behavior Source
REQ-002 STORY-002 round-3 audit findings; NOT yet triaged into one vs three
root causes — bug-fixer must confirm via query-first diagnosis before
deciding whether this is one fix or three.

Suspected impacted runtime/service/app: mobile-app (Flutter)
Runtime registry: `data/devops/system/runtime-command-registry.json`

Query keys for future bug-fixer handoff: "Synced Alarm", "_notImplementedCanvasIds", "resolvePairingStatus"

Active Bug Fixer Agent Id: N/A
Bug Fixer Status: NOT_STARTED

Note: distinct from `BUG-20260801-007` (DONE) — that fixed a different
"Synced Alarm" occurrence in REQ-001 STORY-016 ARB copy, not this REQ-002
STORY-007 `permissions_screen.dart` occurrence.
