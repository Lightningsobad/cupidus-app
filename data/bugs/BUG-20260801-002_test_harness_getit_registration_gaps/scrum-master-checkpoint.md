# Scrum Master Checkpoint — BUG-20260801-002_test_harness_getit_registration_gaps

Status: IN_PROGRESS — dispatched to Justin-BugFixer (`Mode: fix-bug`).
Linked Requirement: REQ-001_cupid_flutter_mobile_app — blocks the readiness
gate test (`widget_test.dart`) itself.

## Scope
- Fix must land on `codex/REQ-001_cupid_flutter_mobile_app-integration`, in
  the existing worktree at
  `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/integration-REQ-001_cupid_flutter_mobile_app`
  (not `main`).

## Next valid step
- Await Justin-BugFixer's result: `fix-evidence.md` + `BUG_FIX_COMPLETE:
  YES|NO`.
- Then route Reviewer (Iris-QC) bugfix review.
- Only after `Outcome: CLEAN`/`DEFERRED_ONLY`: mark this bug `DONE`, then
  dispatch `BUG-20260801-003_anti_ghost_entry_card_l10n_null` next.

## Do Not Re-read
- Do not re-derive the failure anchor; fully captured in `bug_master.md`.

## Note from BUG-20260801-001's review (Iris-QC-2, independently confirmed)
- `app_shell_test.dart` "unpaired" case, after BUG-001's fix, now fails with
  a DIFFERENT signature than the "paired" case: `TestFailure: Expected:
  exactly one matching candidate, Actual: ... Found 2 widgets with type
  InkWell` — not a GetIt registration error, not in this bug's originally
  filed scope (item 1 only lists the "paired" case for
  `CouplePairingStore`).
- When Justin-BugFixer-2 returns for this bug, verify whether the "unpaired"
  case now passes as a side effect, or still fails with the InkWell
  duplicate-widget signature. If it still fails with that signature after
  this bug's fix lands, it is a 4th distinct, previously-masked defect and
  must be filed as a new bug record (e.g. `BUG-20260801-004`), not folded
  into this bug's `DONE` closure or silently left failing.
