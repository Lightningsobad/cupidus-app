# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has one: `phase-P0-pairing-choice-three-row-rebuild.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the phase `Primary Inputs Summary`.
Do not load unrelated UX, architecture, or system-memory files.
This story's UX spec IS a named phase input — sections 2, 3, 4, and 8 carry the
exact spacing, alphas, glyph names, and row-to-destination mapping, and no other
artifact repeats them.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update phase status immediately when it changes.
4. Do not expand the phase scope into the invite screen, the join-code screen,
   the pair gate, or QR camera capture.
5. Stop and escalate rather than guessing on either of this story's two known
   escalation points: an unconfirmable Material Symbols codepoint, and the
   "later, look around first" link, which `../architecture/solution.md` D1
   removes from scope because it has no reachable destination.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the plan during implementation.
- Escalate if the plan is materially wrong.
