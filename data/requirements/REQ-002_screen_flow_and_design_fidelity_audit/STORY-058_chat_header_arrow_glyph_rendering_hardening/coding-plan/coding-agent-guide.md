# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (`phase-P0-separator-glyph-remedy.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the phase's `Primary Inputs Summary`.
Do not load unrelated UX, architecture, or system-memory files. Do not reopen
STORY-018, STORY-040, or STORY-052 artifacts beyond the one AC6 line named in
the phase write scope.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Do not expand the phase scope beyond its declared write scope.
5. P0's `## 3. Tasks` is an ordered decision tree. Run Step 0 before any build,
   and let the capture result — not preference — select Path A or Path B.
6. Never ship a tofu or colour-tile render. If both paths fail their coverage
   check, revert to the STORY-052 baseline and stop with
   `GLYPH_FALLBACK_EXHAUSTED`.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Record which remedy path was actually executed in both
  `phase-P0-separator-glyph-remedy.md` section 7 and
  `../visual-fidelity/visual-fidelity-report.md`.
- Escalate if the plan is materially wrong.
