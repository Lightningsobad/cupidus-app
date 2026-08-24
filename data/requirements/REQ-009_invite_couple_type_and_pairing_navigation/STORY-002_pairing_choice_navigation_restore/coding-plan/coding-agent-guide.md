# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
`../architecture/solution.md` §1 `Key Discovery` is mandatory for both phases:
it records that the Flutter navigation graph is already correct and that the
`goVow` divergence is design-source only. Skipping it leads straight to
rewriting `mobile/lib/` navigation that no acceptance criterion asks for.
If the phase names OQ constraints, read the story requirements
`## Open Question Impact` section before coding and do not implement blocked
scope.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision
   that the phase does not already resolve.

## 4. Story-Specific Guardrails

- Never write `mobile/lib/features/pairing/presentation/screens/invite_screen.dart`
  or `joincode_screen.dart`. STORY-001 owns the invite screen in a parallel
  worktree; editing them here creates a merge conflict for behavior that is
  already correct.
- Never write any file under `mobile/lib/` in this story at all.
- Do not modify `mobile/test/core/navigation/chain_tail_edges_test.dart`.
- Apply `../ux/ux-spec.md` §1-2 verbatim; do not re-derive the design HTML.
- `flutter` is off the default PATH — prefix `PATH="$HOME/flutter/bin:$PATH"`.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
