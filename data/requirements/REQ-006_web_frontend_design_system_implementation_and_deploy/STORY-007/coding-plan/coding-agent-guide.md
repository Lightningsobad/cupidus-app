# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has one: `phase-P1-support-faq-page.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read the story requirements
`## Open Question Impact` section before coding and do not implement blocked
scope.

`cupid-app-design-system/Cupid Web.dc.html` is large. Read only the two ranges
the phase names (614-637 and 814-821); never full-read it.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision
   that the phase does not already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Story-Specific Stop Conditions

Stop and report to Scrum Master rather than improvising if:

- The page appears to need a change to `SiteLayout.astro`, `SiteHeader.astro`,
  `SiteFooter.astro`, `tokens.css`, `global.css`, or the theme/lang boot script.
  Per the STORY-001 contract §6 that is a Tech Lead finding, because such a
  change silently re-renders the other seven pages.
- The page needs a color that the STORY-001 token set does not define. Report
  it; do not invent a token or hardcode a hex value.
- The requirement's design-source fidelity lock still points at
  `Cupid App.dc.html` when the visual audit is due.
