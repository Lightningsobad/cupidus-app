# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
`../architecture/contract-summary.md` is the authoritative cross-lane contract:
copy identifiers from it verbatim and do not re-derive them from the other
lane's code.
If the phase names OQ constraints, read the story requirements
`## Open Question Impact` section before coding.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision that the phase does not already resolve.

## 4. Cross-Lane Rule For This Story

The mobile lane is NOT blocked on backend code. P2 may start immediately
against the contract document. Backend-first applies to deploy order only.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Record every test and build result in `coding-plan/test-results.md`.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
