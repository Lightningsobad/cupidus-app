# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has exactly one: `phase-P1-pets-page-body-and-entry-point.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first — here that
means `../../STORY-001/architecture/contract-summary.md` before touching any
`web/` file.
`cupid-app-design-system/Cupid Web.dc.html` is large: read only the line ranges
the phase names.
Both requirement-level open questions are RESOLVED; no scope on this page is
blocked.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision that
   the phase does not already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Story-Specific Stop Conditions

Stop and report instead of working around any of these:

- The page needs a color the token set lacks, or a shell change of any kind —
  that is a finding for Tech Lead, not an edit. Editing a shell file silently
  re-renders the other seven routes and invalidates their fidelity evidence.
- The design-fidelity lock still points at `Cupid App.dc.html` (mobile) rather
  than `Cupid Web.dc.html` — report `DESIGN_SOURCE_LOCK_MISMATCH`.
- A design-source string and the UX spec table disagree — the design source at
  the named line range wins; report the discrepancy, do not pick silently.
