# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first — for this
story that is `../architecture/contract-summary.md`, which is written to be
self-contained so you do not need `solution.md` for the wire format.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires a decision the phase does not
   already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Story-Specific Notes

- P1 and P2 have no dependency on each other and may run concurrently. Neither
  lane may edit the other's files.
- The field name `publicCountdown` and its default `true` are frozen by
  `../architecture/contract-summary.md`. If either lane believes it must change,
  stop and escalate — a unilateral rename breaks the other lane silently, since
  the mobile read falls back to `true` instead of failing loudly.
- AC5 is a do-not-touch criterion. `_PenaltyRadioGroup`, the `Penalty` enum, and
  their existing tests must come out of this story byte-identical.
