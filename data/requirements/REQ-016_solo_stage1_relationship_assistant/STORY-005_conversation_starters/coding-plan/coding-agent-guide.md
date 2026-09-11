# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
`../architecture/contract-summary.md` is self-contained: read it instead of
reopening STORY-001's or STORY-004's solution documents. When it points at a
dependency contract section, read that exact section only.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision
   that the phase does not already resolve. No OQ blocks this story.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. Flutter Toolchain Notes For This Repository

- Prefix the Flutter SDK on `PATH` before any `flutter` command; run
  `flutter gen-l10n` first in a fresh worktree or generated l10n symbols will be
  missing.
- Scope static analysis as `flutter analyze lib test`. Its exit code is **not**
  a gate here: the baseline is non-zero (pre-existing warnings, zero errors).
  The gate is "zero analyzer **errors**, and no new warning in files this phase
  touched".
- Never pipe a build command's output. A piped build wedges the evidence gate
  and the culprit becomes unidentifiable.
- Prefer targeted `flutter test <exact paths>` runs over one combined suite run
  while iterating; a single red combined run can lock the whole session.
