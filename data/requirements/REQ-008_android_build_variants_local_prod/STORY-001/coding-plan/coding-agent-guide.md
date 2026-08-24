# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files. This story has
no `../ux/` directory: UX-Spec is WAIVED in `story_master.md`.

`../architecture/solution.md` section 1 carries two `Key Discovery` findings
that already rule out the two most likely wrong implementations. Read them
before writing Gradle code, not after a failed build.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into iOS, CI/CD, domain, signing, or
   `google-services.json` changes — all are explicitly out of scope.
6. Stop and escalate if the assigned work requires an unresolved OQ decision
   that the phase does not already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
