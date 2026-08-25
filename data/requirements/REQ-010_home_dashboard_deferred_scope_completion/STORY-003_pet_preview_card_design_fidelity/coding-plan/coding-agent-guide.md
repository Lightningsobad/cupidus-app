# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has one: `phase-P1-pet-preview-card-fidelity-and-fixture.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
`../ux/uiux-spec.md` is a named input for P1 and owns every per-property
correction value; do not re-derive those values from the design source yourself,
and do not widen the read to other stories' specs.
This story has no OQ constraints and no shared interface from another lane.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into the pet screen, pet data/cubit layer,
   design-system token files, or the four undepicted compact card states.
6. Stop and escalate if the fixture cannot resolve the card to `PetReady`, or if
   the rendered capture cannot be produced — do not assert AC1 or AC3 from code
   reading.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
