# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has one: `phase-P1-blog-page-body.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
The phase names shared interfaces consumed from STORY-001 — read
`../../STORY-001/architecture/contract-summary.md` before writing markup; it is
self-contained, so do not open STORY-001's other artifacts.
This story has no unresolved OQ constraints (both requirement-level OQs are
RESOLVED); do not re-open them.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision
   that the phase does not already resolve.

## 4. Story-Specific Stop Conditions

Stop and report instead of improvising when any of these occur:

- The page appears to need a change to `SiteLayout.astro`, `SiteHeader.astro`,
  `SiteFooter.astro`, `tokens.css`, or `global.css` — a shell edit silently
  re-renders seven sibling pages and invalidates their fidelity evidence.
- A color, spacing, or typography value the design source needs has no existing
  token — report it as a finding; do not invent a token.
- `node -v` is below 22.12.0 — report `NODE_ENGINE_MISMATCH`; do not unpin or
  downgrade Astro.
- The rendered design reference for the review gate is missing — report
  `DESIGN_REFERENCE_UNAVAILABLE` and name
  `render-design-canvas.js --screen=blog`; do not self-approve visual fidelity.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
