# Scrum Master Checkpoint

Scope:
- Bug: BUG-20260817-001_chat_fab_occludes_send_button
- Status: REVIEW_REQUIRED
- Workflow: fix-bugs (Branch C -> Reviewer: Bugfix Review dispatched)

Canonical artifact paths:
- Registry: `data/bugs/master_bugs_list.md`
- Bug master: `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/bug_master.md`
- Diagnosis: `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/diagnosis.md`
- Fix evidence: `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/fix-evidence.md`
- Review report (not yet written): `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/review/review-report.md`

Bug Fixer outcome (`BUG_FIX_COMPLETE: YES`, Justin-BugFixer, attempt 1):
- Not reproducible on HEAD (`main`, `a11959d`). The occluding FAB
  (`mobile/lib/core/navigation/app_shell.dart`) was already deleted by commit
  `3d74a75` (STORY-061, 2026-08-20), which replaced STORY-016 DEC-4's
  provisional 3-tab+FAB shell with the design's 5-tab shell — 3 days after
  this bug was filed (2026-08-17). No STORY-016 DEC-4 re-litigation occurred.
- No production source changed (`app_shell.dart` and `chat_composer.dart`
  diffs both empty).
- Only changed file: `mobile/test/core/navigation/app_shell_test.dart` — new
  regression test asserting the send button is hit-testable (not just "no
  FAB exists"), verified by a mutation check (re-added the old FAB, test
  failed with the expected "pointer never reached it" message, then reverted).
- Gates recorded: Pre-Fix Reproduction Gate (`diagnosis.md`,
  `Result: NOT_REPRODUCIBLE_ON_HEAD`, rendered on-device capture same
  modality as report), Original Failure Recheck Gate (`fix-evidence.md`,
  `Same modality as original: YES`, `Result: PASS`, real `adb` tap proof),
  Build Gate (`Result: PASS`, `flutter build apk --debug`), Runtime Startup
  Gate (`Result: PASS`, `Shutdown: PASS`, runtime id `mobile-app`).
- Evidence captures: `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/evidence/recheck-chat-shell-{empty-draft,enabled-send,after-send-tap}.png`

Two items outside Bug Fixer's scope, noted for later routing (not this bug):
1. Pre-existing unrelated `validate-runtime-registry.sh` PostToolUse gate
   fires on every Write in this repo: `web-frontend` `dependsOn` is empty
   with no `dependsOnRationale` field (the rationale exists in `notes` but
   not the field the gate reads). Not caused by this bugfix; devops-owned.
2. Working-tree files present at session start, not from this bugfix:
   `backend/.env.example`, `docs/production-readiness-checklist.md`,
   `mobile/ios/Runner.xcodeproj/project.pbxproj`,
   `mobile/ios/Runner/Base.lproj/Main.storyboard`.

Query keys for Reviewer (`bugfix-review`):
- `diagnosis.md` §Pre-Fix Reproduction Gate, §Root Cause, §Fix Scope
- `fix-evidence.md` §Changed Files, §Regression Coverage (mutation check),
  §Regression Test Gate, §Build Gate, §Runtime Startup Gate, §Original
  Failure Recheck Gate, §Residual Notes For Reviewer
- Changed file: `mobile/test/core/navigation/app_shell_test.dart`
- Confirm: no re-litigation of STORY-016 DEC-4 (already superseded by
  STORY-061/commit `3d74a75` before this bug was picked up)

Active Bug Fixer Agent Id: Justin-BugFixer@session-e28bc612
Bug Fixer Status: COMPLETE

Active Reviewer Agent Id: Iris-QC@session-e28bc612
Reviewer Status: RUNNING

Next step: dispatch `Iris-QC`, `Mode: bugfix-review`, `Scope: BUG-20260817-001`.
On return, validate `review/review-report.md` has one literal `Outcome:` line
and follow fix-bugs.md "After Reviewer Returns".
