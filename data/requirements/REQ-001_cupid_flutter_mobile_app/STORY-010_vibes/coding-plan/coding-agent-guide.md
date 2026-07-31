# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
Do not read prior stories' solutions, coding plans, or review reports; the two
contracts this story reuses are already quoted in
`../architecture/solution.md` §2 (`CupidApi.dio` REST precedent) and §4 D-010-1
(why STORY-004 realtime is not wired here).

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane (all phases here are Mobile Developer).
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires an unresolved OQ decision that
   the phase does not already resolve.

## 4. Story-Specific Guards

- A1: never edit `backend/**`, `mobile/openapi/**`, or the OpenAPI spec.
- Mood strings exist only in `domain/vibe_mood.dart`.
- `Dio`, `cupid_api`, and `/vibes*` path literals exist only in `data/`.
- Do not edit `mobile/lib/l10n/**` (D-010-6); use `vibe_strings.dart`.
- `service_locator.dart` and `cupid_icons.dart` edits are append-only single
  lines (R-010-4, parallel-wave conflict avoidance).
- Do not wire `RealtimeCoordinator` (D-010-1) and do not add a screen-level
  pairing guard (UX §7).
- Flutter is not on PATH: use `"${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter"`.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
