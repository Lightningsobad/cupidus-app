# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has exactly one: `phase-P1-privacy-ghost-toggle.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the phase `Primary Inputs`. For P1 that
is `../architecture/solution.md` and `../ux/uiux-spec.md` §2-5. Do not load
prior-story artifacts, review reports, or system memory.

`../ux/uiux-spec.md` is the authority for placement, copy, on/off semantics,
state behavior, and accessibility strings. Do not re-derive them.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update phase status immediately when it changes.
4. Do not expand scope beyond the phase `Write Scope`.
5. Stop and escalate if the work appears to require a backend change — A1
   freezes the backend contract for this requirement, and
   `../architecture/solution.md` §3 already establishes that no backend change
   is needed here.

## 4. Story-Specific Stop Conditions

Stop and report instead of working around any of these:

- The generated `UpdateProfileDto` does not accept `isGhostModeEnabled`.
- Satisfying a test requires editing `notification_settings_screen.dart`, its
  cubit, its store, or their test files — that breaks the AC3 non-regression
  gate.
- Satisfying the phase requires editing anything under
  `mobile/lib/features/chat/`.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Record command output and pass/fail counts in `test-results.md`.
- Do not redesign the plan during implementation; escalate if it is materially
  wrong.
