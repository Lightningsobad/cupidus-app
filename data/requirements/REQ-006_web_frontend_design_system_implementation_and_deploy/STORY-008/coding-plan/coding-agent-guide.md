# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has one: `phase-P1-legal-page-body-and-entry-point.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first — here that is
`../../STORY-001/architecture/contract-summary.md`.
Both requirement-level open questions (OQ-REQ006-1, OQ-REQ006-2) are RESOLVED and
block nothing in this story; no OQ read is required.

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

## 5. Story-Specific Stop Rule

`web/src/pages/legal.astro` is the only file this story may write. If the work
appears to require editing `SiteLayout.astro`, `SiteHeader.astro`,
`SiteFooter.astro`, `tokens.css`, or `global.css`, stop and report it as a
finding for Tech Lead. Those files are shared by seven other in-flight page
stories: changing one silently re-renders the other pages and invalidates their
visual-fidelity evidence.
