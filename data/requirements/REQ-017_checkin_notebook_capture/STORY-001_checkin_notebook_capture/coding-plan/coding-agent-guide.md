# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read the story requirements `## Open Question Impact`
section before coding and do not implement blocked scope. For this story no OQ is
blocking: OQ-1, OQ-2, and A-5 were all resolved 2026-09-27.

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

## 5. Story-Specific Guardrails

- `ContextNotebookRepository` is the only write door into `notebook_entries`. Do not
  open a second one anywhere, in any phase.
- New user-visible copy belongs in `assets/data/req017/checkin_capture.v1.json` only —
  never in ARB/l10n, never as a Dart constant. Invariant *rules* stay in Dart only.
- Do not add a value to `ContextEntrySource`. "Came from a check-in" is
  `origin_check_in_ref != null`.
- Do not gate visible UI on a nullable test seam. P3's block visibility is gated on the
  resolved content copy, not on the write seam.
- Never run bare `flutter test` for the whole suite: the REQ-016 baseline is red in
  `test/design_system/`, and one red combined run locks the build-evidence gate for the
  rest of the session. Run only the suites your phase names.
- Never pipe a build/test command's output. A piped run cannot be attributed afterwards.
- `flutter analyze` can never exit 0 in this repo (pre-existing warnings, 0 errors).
  Compare the delta for files you touched; do not use a zero exit as gate evidence.
