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

## 5. Story-Specific Stop Conditions

- P1 task 1 is a real gate. If `flutter pub add mobile_scanner
  permission_handler` fails to resolve, or either package is discontinued, stop
  and escalate. Substituting a different package silently invalidates every
  later phase.
- If any phase seems to need a new `PairingFailure` subtype, a change to
  `JoincodeCubit`/`PairingRepository`, or a second pairing call, stop: AC2's
  parity invariant is being broken.
- `mobile/pubspec.yaml` is also edited by STORY-002 on a sibling branch. Append
  only; never reorder or reformat the dependency block.
