# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has one: `phase-P1-invite-page-body-and-entry-point.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the phase `Primary Inputs`. Do not load
unrelated UX, architecture, or system-memory files. `../ux/uiux-spec.md` §6.2 is
the measurement source of truth for this story — every size, color token,
gradient, and string is there with its `Cupid Web.dc.html` line citation, so
read it rather than re-deriving from the design source.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Do not expand scope beyond the phase Write Scope. The STORY-001 shell
   (`web/src/layouts/`, `web/src/components/shell/`, `web/src/styles/`,
   `web/src/scripts/`) is frozen for this story — a needed shell change is a
   finding to escalate, not an edit to make, because it silently re-renders the
   other seven pages and invalidates their fidelity evidence.
5. Copy is verbatim from the design source in both VI and EN. Do not paraphrase,
   re-translate, or normalize quotes, dashes, or capitalization.
6. Do not make the code cells or the "Open Cupid" CTA functional, and do not add
   copy explaining that they are not. Non-functionality is a source-confirmed
   requirement (AC-3/AC-4), not an unfinished placeholder.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Record all verification evidence in `coding-plan/test-results.md`.
- Do not redesign the plan during implementation; escalate if it is materially
  wrong.
