# Scrum Master Checkpoint

Scope:
- Bug: BUG-20260817-001_chat_fab_occludes_send_button
- Status: REPORTED
- Workflow: add-bug (intake only — no diagnosis, no bug-fixer dispatch)

Canonical artifact paths:
- Registry: `data/bugs/master_bugs_list.md`
- Bug master: `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/bug_master.md`
- Diagnosis (not yet written): `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/diagnosis.md`
- Fix evidence (not yet written): `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/fix-evidence.md`
- Review report (not yet written): `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/review/review-report.md`

Failure anchors:
- Component: `mobile/lib/core/navigation/app_shell.dart:199-206`
  (`FloatingActionButton`, `endFloat`) occludes
  `mobile/lib/features/chat/presentation/widgets/chat_composer.dart`'s send
  button (100% overlap, measured off `implemented-chat-composer-draft-emulator-5560.png`).
- No stack trace (interaction/visual occlusion, not a crash).
- No existing failing test — no current widget test pumps the shell-wrapped
  chat screen together (chat tests are unshelled).

Expected-behavior source: inferred — send button must be reachable in
production; design reference has no FAB on this screen at all, so this is an
IA/layout decision, not a pixel-match target.

Suspected impacted app: `mobile` (Flutter). No backend/devops involvement
expected.

Runtime registry path: `data/devops/system/runtime-command-registry.json`

Query keys for future `bug-fixer` handoff:
- `app_shell.dart` FAB placement (`endFloat`, lines 199-206)
- `chat_composer.dart` send-button geometry
- STORY-016 DEC-4 (existing accepted 3-tab shell + FAB chrome decision —
  the fix must not silently re-litigate DEC-4 itself, only resolve the
  send-button overlap)
- Full measurement/finding write-up: STORY-040's own
  `visual-fidelity/visual-fidelity-report.md`, finding `N2`

Active Bug Fixer Agent Id: N/A
Bug Fixer Status: NOT_STARTED

Next step: `@scrum-master fix bugs` will pick this up per the standard
bug-queue pipeline. Do not dispatch `bug-fixer` from this checkpoint.
