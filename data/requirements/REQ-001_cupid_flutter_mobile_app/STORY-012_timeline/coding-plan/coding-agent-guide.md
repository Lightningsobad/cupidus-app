# Coding Agent Guide

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
If the phase names OQ constraints, read `../architecture/solution.md` §3
"Open Question Constraints" before coding and do not implement blocked scope.

This story has no `requirements/requirements.md`; `../story_master.md` and
`../architecture/solution.md` are the governing artifacts.

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

These come from `../architecture/solution.md` §4 and apply to every phase:

- No backend change of any kind, including OpenAPI/Swagger decorators (A1 frozen).
- No offline write queue, outbox, optimistic insert, client-generated id, or automatic retry (ADR-007).
- No libsodium, FFI, `image_picker`, `connectivity_plus`, or any package beyond the ones P1 adds. R3 is resolved as "no local encryption required" for this story.
- Import `mobile/lib/core/network/cupid_api.dart` only; never import `package:cupid_api/...` directly and never construct `Dio`.
- Switch on the sealed `CupidApiFailure` subtypes, never on `DioExceptionType`.
- Do not edit `mobile/lib/core/auth/**` or `mobile/lib/core/realtime/**`.
- Keep `Key('home_screen_ready_signal')` present and pumping — it is the app's runtime readiness signal.
- `mobile/lib/features/home/presentation/home_screen.dart`, `mobile/lib/core/di/service_locator.dart`, `mobile/lib/l10n/arb/app_en.arb`, and `mobile/lib/l10n/arb/app_vi.arb` are merge hotspots shared with sibling epic-4 stories in this wave: keep every edit additive and in one contiguous block.
- Out of scope by decision — do not build: photo attachment on create, delete-entry UI, pagination past the first 50 entries, the milestone/progress banner, offline photo caching.
