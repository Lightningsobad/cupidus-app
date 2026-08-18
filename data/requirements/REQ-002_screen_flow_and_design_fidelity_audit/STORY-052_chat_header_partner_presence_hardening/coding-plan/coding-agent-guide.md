# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read `../architecture/contract-summary.md`
first — it is self-contained and you do not need `solution.md` to implement
against it.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Story-Specific Guardrails

- `GET /users/me` `displayName` is the **caller's own** name and always has
  been. `ChatPartnerStore`'s pre-split dartdoc calls it the partner's name and
  is wrong. If a change you are about to make depends on the old reading,
  stop and escalate.
- No phase regenerates the API client. See `../architecture/solution.md` §3
  "Generated API Client" before adding a regeneration step.
- P1 must not leave a compatibility `ChatPartnerStore.displayName` getter
  behind; the compile errors it would suppress are the point of the split.
- P2 must wire the new `trailing` slot in both `_IosHeader` and
  `_MaterialHeader`. `CupidHeader.build` branches on platform.
