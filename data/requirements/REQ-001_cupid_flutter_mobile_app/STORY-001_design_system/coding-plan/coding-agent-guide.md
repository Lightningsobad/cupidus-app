# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read `../architecture/solution.md` section 3
"Open Question Constraints" before coding and do not implement blocked scope.

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

## 5. Story-Specific Rules

- The Flutter SDK is not on PATH on this machine. Run every command as
  `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter <args>` from `mobile/`, per the
  `mobile-app` runtime registry entry.
- Public names in `../architecture/solution.md` section 2 are a contract for all
  15 remaining REQ-001 stories. Do not rename them; escalate instead.
- Token values come verbatim from `../ux/uiux-spec.md` sections 2–4. The only
  sanctioned deviation is ADR-004c (`colorAccentPurpleDark` light carry-over).
  Never invent a color, radius, or spacing value.
- ADR-004b is binding: in light theme, accent pink and purple are for large
  text, icons, borders, and gradients only — never body or caption text.
- Only `mobile/lib/design_system/adaptive/` may branch on platform, and it must
  read `context.cupidPlatform`, never `Platform.is*` or `defaultTargetPlatform`.
- Flags gate exposure, never existence. Light theme and `en` must stay
  compilable and test-constructible at all times.
- `Key('home_screen_ready_signal')` in the home screen is the runtime registry
  readiness signal. Do not remove or rename it.
- This story builds no screens and adds no navigation. If a task seems to
  require one, stop and escalate.
