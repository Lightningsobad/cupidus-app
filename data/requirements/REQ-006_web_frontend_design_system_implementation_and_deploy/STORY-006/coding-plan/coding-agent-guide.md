# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.

This story has no unresolved OQ: `OQ-REQ006-1` and `OQ-REQ006-2` are both
RESOLVED before its scope begins, so no scope here is blocked.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision that the phase does not already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Story-Specific Hard Rules

- **Never edit the shell.** `SiteLayout.astro`, `SiteHeader.astro`,
  `SiteFooter.astro`, `tokens.css`, `global.css`, and `theme-lang-boot.ts` are
  owned by STORY-001 and shared by seven other pages. A change you think this
  page needs is a finding to report, not an edit to make.
- **Copy, do not compose.** Every string and every inline `style` value comes
  verbatim from `../ux/uiux-spec.md` §6.2 (which cites exact
  `Cupid Web.dc.html` lines). Do not paraphrase, re-translate, normalize quotes
  or dashes, invent a token, or add a hover state the spec does not name.
- **Two localization traps that look like bugs and are not.** The three stat
  numbers (`48.000+`, `31.500`, `2,1 triệu`) are unlocalized literals and stay
  identical in English; the timeline's 2026 entry *does* localize its separator
  (`48.000` VI / `48,000` EN). Reproduce both. "Fixing" either into consistency
  is a fidelity defect.
- **Build on Node >=22.12.0.** astro@6.0.5 requires it and the machine default is
  v20.20.2. Record the Node version in every evidence line; a v20 failure is not
  a code defect and must not be reported as one.
- **Evidence goes in `coding-plan/test-results.md`** and gates your
  `FRONTEND_COMPLETE: YES` marker.
