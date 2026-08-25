# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md` (this story has one: `phase-P0-home-header-share-action.md`)

## 2. Context Loading Rule

Read only the source artifacts named in the phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
`../ux/uiux-spec.md` §1 and §2 ARE named inputs here — they hold the only
authoritative token values and the null-days render rule. Read those two
sections; do not full-read the spec.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.

## 4. Story-Specific Rules

- Flutter is not on this machine's PATH. Prefix every Flutter command with
  `PATH="${FLUTTER_SDK_PATH:-$HOME/flutter}/bin:$PATH"`.
- The `share_plus` version, import path, and call signature must come from the
  package resolved by `flutter pub add` and read from its own README/source in
  the pub cache. Writing them from memory is a defect — the API changed across
  major versions and this repo has no prior usage to copy.
- If the package cannot be resolved, stop with `SHARE_PACKAGE_UNRESOLVED`. Do NOT
  substitute the clipboard-copy pattern from `invite_screen.dart`: that path
  fails AC2 and reversing AC2 is a Product Owner decision.
- Do not add the `goNotifs` notifications icon or its badge — STORY-005.

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.
