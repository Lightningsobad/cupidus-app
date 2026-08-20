# REQ-004 Parallel Continue — Scrum Master Checkpoint

Workflow: `.claude/skills/scrum-master/workflows/parallel-continue.md`
Requirement: REQ-004_notifications_dnd_banner_copy_reconciliation
Status: PENDING -> requirement breakdown dispatched (control-plane planning,
no parallel run reserved).

## Selection

`master_requirements_list.md`: REQ-001/002/003 all `DONE`. No requirement was
`IN_PROGRESS`/`PATCH_REQUIRED`/`REWORK_REQUIRED`. `parallel-scheduler.json`
had no active/paused/blocked runs and a cleared `supervisor` block. Selected
the only remaining `PENDING` row: REQ-004.

## Scope Summary (from req_master.md — do not re-read, this is the full gist)

Two locked-design copy tokens both collide with the same ADR-002 guard test
(`reminder_copy_guard_test.dart:18-22`, bans literal "Do Not Disturb" and
"synced alarm"):
1. `notifs` screen DND banner sentence (original E-2 finding).
2. `permissions` screen `Synced Alarm` row body copy (folded in 2026-08-18
   from STORY-047 AC2; app currently ships the ADR-002-canonical
   `Nhắc nhở đồng bộ`/`Synced Reminder` phrasing at
   `permissions_screen.dart:80-81`, unchanged/reverted).

This is a genuine product ruling (alternate copy vs. documented ADR-002
amendment) that Product Owner/UI-UX must make — not a Scrum Master call.

## Dispatch

Target: Andy-PO, Mode: requirement-breakdown, Flow: parallel-requirement
(control-plane planning exception — no `Parallel-Execution: YES`, no `RunId`,
no worktree, no parallel run file, per `.agent-contract/handoff-schema.md`).

## Next Step

Await Andy-PO's breakdown result. Reconcile `req_master.md` `## User Stories`
and `master_requirements_list.md` from the result, then re-enter the
scheduler loop in the same invocation per `parallel-continue/scheduler-loop.md`.
