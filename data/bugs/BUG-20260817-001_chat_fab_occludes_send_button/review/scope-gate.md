# Scope Gate: BUG-20260817-001 Chat FAB Occludes Send Button

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: bugfix-review
Reviewer: Iris-QC
Date: 2026-08-23
Bug: `BUG-20260817-001_chat_fab_occludes_send_button`
Review report path: `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/review/review-report.md`

## Governing Artifacts (already read, do not re-read)

- `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/bug_master.md`
- `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/diagnosis.md`
- `data/bugs/BUG-20260817-001_chat_fab_occludes_send_button/fix-evidence.md`

## Source/Test Files In Scope (Phase 2)

1. `mobile/test/core/navigation/app_shell_test.dart` — the only changed file;
   read the new regression test `chat tab: the composer send button is
   hit-testable, not occluded by shell chrome (BUG-20260817-001)` and the
   pre-existing `no account FAB remains on any shell destination` guard.
2. `mobile/lib/core/navigation/app_shell.dart` — read-only confirmation that
   no `FloatingActionButton` / `floatingActionButton:` /
   `floatingActionButtonLocation` remains, and that the file is unmodified.
3. `mobile/lib/features/chat/presentation/widgets/chat_composer.dart` — read-only
   confirmation the send button widget the test targets exists and is unmodified.

Changed-file count: 1 (budget: 12). Within `bugfix-review` budget.

## Evidence Files In Scope

- `evidence/recheck-chat-shell-empty-draft.png`
- `evidence/recheck-chat-shell-enabled-send.png`
- `evidence/recheck-chat-shell-after-send-tap.png`
- Historical pre-fix capture referenced by the diagnosis:
  `data/requirements/REQ-002_screen_flow_and_design_fidelity_audit/STORY-040_chat_typing_ghost_design_fidelity_hardening/visual-fidelity/implemented-chat-emulator-5560.png`
- Git history for commit `3d74a75` (read-only `git show --stat` / path-scoped
  `git log`) to confirm the incidental-fix and DEC-4 supersession claims.

## Touched Risk Surfaces And Critical Gates

| Risk surface | Touched? | Critical gate | Where verified |
|---|---|---|---|
| Mobile navigation/shell chrome | Read-only (asserted unmodified) | `git diff` empty on `app_shell.dart` | Independent git check |
| Mobile interaction (chat primary action) | Behaviour unchanged; newly guarded | Same-modality on-device recheck | `## Original Failure Recheck Gate` + 3 captures |
| Test/regression coverage | Yes (sole change) | Test suite pass + mutation check proving the guard catches the original defect | `## Regression Test Gate`, `## Mutation check` |
| Mobile build | Indirect | `flutter build apk --debug` | `## Build Gate` |
| App lifecycle / runtime startup | Indirect | Registry readiness probe + shutdown | `## Runtime Startup Gate` |
| Product scope creep | Must be none | No production source change | Independent git diff check |

Not applicable: persistence/schema, migration, external integration, async job,
security/auth, permissions/device API, deep link/push, operational command,
configuration guide (no setup/config surface touched — test-only change).

## Focused Query Keys For Phase 2

- `BUG-20260817-001` (test name anchor in `app_shell_test.dart`)
- `hitTest` / `HitTestResult` / `RenderBox` (the asserted property)
- `_SendButton` / `sendButton` (composer target the test locates)
- `FloatingActionButton`, `floatingActionButton`, `floatingActionButtonLocation`
  (occluder absence in `app_shell.dart`)
- `wrapInShell` (shelled render tree used by the recheck harness)
- `3d74a75` (incidental-fix commit; confirm it removed the FAB)

## Special Verification Directives From Handoff

- Reproduction gate result is `NOT_REPRODUCIBLE_ON_HEAD`. Verify that conclusion
  against the cited historical capture and current source state rather than
  rejecting it for not matching a literal `REPRODUCED`/`NOT_REPRODUCED` token.
- Verify the mutation check genuinely proves the new guard would have caught the
  original defect (guard must fail with the FAB re-added, and the mutation must
  be fully reverted).
- Verify no STORY-016 DEC-4 re-litigation: confirm DEC-4 supersession is treated
  as inherited fact from STORY-061, not a decision made by this bugfix.

## Explicitly Out Of Scope

- STORY-016 / STORY-040 / STORY-061 story masters, requirement rereads, and any
  other implementation directory.
- Editing `bug_master.md`, implementation code, test files, or workflow
  checklists.

## Phase 2 Decision

Phase 2 may proceed. The handoff is within `bugfix-review` budget, all three
governing bug artifacts exist, `BUG_FIX_COMPLETE: YES` is recorded, and both the
`## Pre-Fix Reproduction Gate` and `## Original Failure Recheck Gate` sections
are present. No `BLOCKED` / `PATCH_REQUIRED` scope-stage stop is warranted.
