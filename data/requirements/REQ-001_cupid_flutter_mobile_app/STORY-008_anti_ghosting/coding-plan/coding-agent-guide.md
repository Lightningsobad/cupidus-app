# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
This story references no OQ ids, so no OQ triage read is required.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane. Every phase here is Mobile Developer.
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Escalate rather than guess if the frozen backend contract appears to disagree
   with `../architecture/solution.md` §2.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. STORY-008 Standing Guardrails

These apply to every phase and are the fastest way to fail review if ignored:

- The backend `ghost-config` module is **A1-frozen**. Do not edit anything under
  `backend/`. Do not regenerate or edit `mobile/openapi/**`.
- Do not create, edit, or import any file under `mobile/lib/features/chat/` —
  that path belongs to STORY-007 and does not exist on this branch.
- Do not add a `pubspec.yaml` dependency. `mocktail` and `bloc_test` are not
  available; write hand-written fakes as
  `mobile/test/features/auth/data/auth_repository_test.dart` does.
- Never write `Color(0x`, `Colors.`, `Platform.is`, or `defaultTargetPlatform`
  under `features/`, `core/`, or `app/` — `no_fork_guard_test` fails the build.
  Use `CupidColorTokens` and the adaptive widgets instead.
- Never reference `Icons.` directly. Add glyphs to `CupidIcons` as Material
  Symbols Rounded codepoints.
- Every new user-visible string goes into **both** `app_en.arb` and `app_vi.arb`.
  "Anti-Ghosting" and "Emoji Storm" stay in English in the `vi` locale.
- Edits to `service_locator.dart`, `cupid_icons.dart`, `home_screen.dart`, and the
  two ARB files must be **append-only**. Sibling parallel stories touch the same
  files; reordering or restructuring them creates merge conflicts.
- Never remove or rename `Key('home_screen_ready_signal')` in
  `home_screen.dart` — it is the runtime registry readiness signal for
  `mobile-app`.
- Flutter is not on PATH on this machine. Use
  `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter` for every command.
