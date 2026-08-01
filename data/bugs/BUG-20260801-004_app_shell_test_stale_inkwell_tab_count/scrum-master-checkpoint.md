# Scrum Master Checkpoint — BUG-20260801-004_app_shell_test_stale_inkwell_tab_count

Status: PENDING — not yet dispatched. Blocked behind BUG-20260801-002's
Reviewer gate and BUG-20260801-003's fix by the global `bug-fixer` role cap
of 1 (`data/runtime/parallel-scheduler.json` `role_caps.bug-fixer: 1`).
Linked Requirement: REQ-001_cupid_flutter_mobile_app.

## Scope
- Fix must land on `codex/REQ-001_cupid_flutter_mobile_app-integration`, in
  the existing worktree at
  `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`
  (not `main`).

## Next valid step
- Dispatch to Justin-BugFixer once BUG-20260801-003 is DONE (bug-fixer cap
  allows only 1 active globally).
- Use the same `BUGFIX_CONTRACT`-compliant handoff pattern (canonical bug
  artifact paths, Build Gate, Runtime Startup Gate,
  `subagent_type: "Justin-BugFixer"`).

## Do Not Re-read
- Do not re-derive the failure anchor; fully captured in `bug_master.md`
  (both failures independently reproduced by Scrum Master).
