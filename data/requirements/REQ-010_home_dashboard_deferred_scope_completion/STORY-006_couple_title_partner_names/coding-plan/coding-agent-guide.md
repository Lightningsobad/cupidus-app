# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in your phase `Primary Inputs` and
`Required Reads`. Do not load unrelated UX, architecture, or system-memory
files. Read `../architecture/contract-summary.md` first — it is self-contained
and carries the whole cross-lane contract, so you do not need
`../architecture/solution.md` for wire facts.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`. Both P0 and
   P1 have no dependencies and may run concurrently.
2. Execute only phases owned by your lane.
3. Update phase status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.

## 4. Story-Specific Guardrails

- `partnerDisplayName` already ships on `GET /users/me` today
  (`../architecture/solution.md` §1 Key Discovery). Neither lane builds a new
  endpoint, and neither renames, reshapes, or removes that key.
- `null`, `""`, and an absent key are one single degraded state: the caller's
  own name alone. No placeholder, no `&`, no error UI — ever.
- P0 must not introduce serialization or transformation on `GET /users/me`;
  the runtime body stays byte-identical.
- P1 must not touch container sizing, spacing, colors, or type tokens in the
  couple-presence header, and must not add a second network call.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the plan during implementation.
- Escalate if the plan is materially wrong.
