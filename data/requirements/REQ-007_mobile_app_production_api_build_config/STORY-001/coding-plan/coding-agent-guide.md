# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has one: `phase-P1-production-api-build-config.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the phase `Primary Inputs Summary`.
Do not load unrelated UX, architecture, or system-memory files. This story has no
`../ux/` directory — UX Design was recorded SKIPPED in `story_master.md`; do not
wait for or request a UX artifact.
There are no OQ constraints and no shared cross-lane contract for this story.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into Android/iOS project files, signing, CI, or
   any UI surface — all are out of scope per `../requirements/requirements.md`.

## 4. Story-Specific Traps

- `mobile/lib/core/config/app_config.dart` looks like this story's config file
  and is not. It is unreferenced dead scaffolding. Do not edit it.
- `CupidApiConfig.baseUrl` keeps its `defaultValue: 'http://localhost:3000'`.
  Changing or removing that default breaks AC2/AC4.
- `String.fromEnvironment` is compile-time const; the validation logic must live
  in a pure parameterized function or it cannot be unit tested.
- Installing and running on an emulator/simulator is the requirement-level mobile
  runtime audit gate, not part of the P1 test scope.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place
  (`coding-plan/test-results.md`).
- Do not redesign the plan during implementation.
- Escalate if the plan is materially wrong.
