# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has one: `phase-P1-home-quick-grid-zodiac-tile.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the phase's `Primary Inputs Summary`.
Do not load unrelated UX, architecture, or system-memory files. This story has
no OQ constraints and no upstream phase outputs.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane (Mobile).
3. Update phase status immediately when it changes.
4. Do not expand scope into `ZodiacRedFlagScreen`, other Home entry cards, the
   tab bar, or the app shell.
5. Honour the Mobile Lane guardrails in `../architecture/solution.md` section 4;
   they are prohibitions, not suggestions.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the plan during implementation.
- Escalate if the plan is materially wrong — in particular if the
  `auto_awesome` codepoint cannot be read from the bundled font cmap
  (`CMAP_LOOKUP_UNAVAILABLE`): stop rather than guess.
