# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read the story requirements `## Open Question Impact`
section before coding and do not implement blocked scope.

For this story the two authoritative reads are `../architecture/contract-summary.md`
(identifiers, field shapes, the `portrait_answers` column list, the consumer
prohibitions) and `../architecture/solution.md` section 4 (the risk table each
phase's `Risk Surfaces` points at). Do not restate or renegotiate either one
inside a phase file.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision that the phase does not already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Mobile Lane Notes For This Story

- Flutter is not on this machine's PATH. Resolve it the way the runtime registry
  entry `mobile-app` does (`FLUTTER_SDK_PATH`, default `$HOME/flutter`) instead of
  assuming a bare `flutter` command works.
- In a fresh worktree run `flutter gen-l10n` before anything else. Without it the
  generated l10n sources do not exist and every other command fails for the wrong
  reason.
- Scope static analysis to `flutter analyze lib test`. Its baseline here is NOT
  zero — the branch carries pre-existing warnings with zero errors — so the gate
  is "no new errors", never an exit code.
- Never pipe a build or test command through another process. A wedged piped run
  cannot be traced back to a culprit file afterwards.
- P2 reads the live `schemaVersion` from `cupid_database.dart` on this branch and
  adds one. Do not use a remembered number, and fix the resulting assertion ripple
  inside P2 rather than handing the next phase a red repo.
- The per-story visual fidelity gate in P4 is that story's own gate, checked at its
  own review. It is never satisfied by, and never deferred to, the
  requirement-level audit. Eyeball the captured images: a green capture run still
  produces worthless output when glyphs render as tofu.
- Edit files inside your phase's `Write Scope` and leave `git commit` to Scrum
  Master.
