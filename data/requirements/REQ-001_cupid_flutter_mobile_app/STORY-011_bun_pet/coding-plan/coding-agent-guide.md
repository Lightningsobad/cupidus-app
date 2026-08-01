# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
No PO Open Question is attached to this story; the binding constraints are the
five resolved UX Open Items carried in `../architecture/solution.md` §3.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. Execute only phases owned by your lane (every phase here is Mobile Developer).
3. Update status immediately when it changes.
4. Stop when the next actionable phase belongs to another owner.
5. Do not expand the phase scope into migration, rollout, or contract areas not
   assigned to your lane.
6. Stop and escalate if the assigned work requires a decision the phase does not
   already resolve.

## 4. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the whole plan during implementation.
- Escalate if the plan is materially wrong.

## 5. STORY-011 Standing Constraints

These apply to every phase; violating any of them is a review failure.

- `backend/` is frozen (A1). Any needed `pets` change is a Product Owner
  escalation, not an implementation decision.
- Never reimplement backend business rules client-side: happiness decay, mood
  thresholds, level math, and the milestone list all stay server-owned. Render
  what `GET /pets/status` returns.
- Do not call `Epic4LovePetApi`; its methods are typed `Response<void>`. Use the
  shared `Dio` through `PetRepository` only (`../architecture/solution.md` D1).
- `PetRepository` is the single JSON-parsing site. Widgets and cubits never touch
  `Dio` or raw maps.
- Catch `CupidApiFailure` subtypes only; never `DioException`, never
  `DioExceptionType`.
- Do not implement: `sleep` sprite state, day streaks, badges, per-species sprite
  art, or any distinct backend effect between Feed and Play.
- No new `pubspec.yaml` dependency and no `assets:` section.
- Import the design system only via
  `package:cupid_mobile/design_system/design_system.dart`.
- New `CupidIcons` codepoints must be read from the bundled
  `MaterialSymbolsRounded-Variable.ttf` cmap and documented; never guessed.
- Keep `Key('home_screen_ready_signal')` in `home_screen.dart` — the `mobile-app`
  runtime registry readiness probe depends on it.
- `home_screen.dart`, `service_locator.dart`, and `cupid_icons.dart` are shared
  files. Keep each edit to one contiguous additive block.
- Localized copy goes in the feature-local `viEn` extension
  (`pet_strings.dart`); do not edit `mobile/lib/l10n/arb/**`.
- Do not run mobile e2e, emulator/simulator lifecycle commands, signing, store
  upload, or `scripts/start-dev.sh` from an implementation phase.
