# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read the story requirements
`## Open Question Impact` section before coding and do not implement blocked
scope. For this story OQ5 is non-blocking: dark theme + `vi` is the only
configuration to build and verify.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane. In this story specifically: `backend/`,
   `mobile/openapi/`, `mobile/lib/design_system/`, and `mobile/lib/l10n/` are
   out of scope, and Continue's navigation destination belongs to STORY-002.
6. Stop and escalate if the assigned work requires an unresolved OQ decision
   that the phase does not already resolve.
7. Stop and escalate rather than guessing an icon codepoint. P1 task 1 is an
   ordered prerequisite: the codepoints come from the bundled font's cmap.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
