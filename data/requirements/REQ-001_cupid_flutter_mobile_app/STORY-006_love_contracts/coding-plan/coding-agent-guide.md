# Coding Agent Guide — STORY-006 Love Contracts

## 1. Start Here

Always read:

- `master-plan.md`
- your assigned `phase-Px-*.md`

## 2. Context Loading Rule

Read only the source artifacts named in the current phase `Primary Inputs`.
Do not load unrelated UX, architecture, or system-memory files.
If the phase names shared interfaces, read those artifacts first.
`../architecture/solution.md` ADR-006a, ADR-006b, and ADR-006c are the binding technical
decisions for this story; read the ADR your phase cites before writing code.

## 3. Execution Rule

1. Work only on actionable phases whose dependencies are `DONE`.
2. This story is single-lane and strictly sequential: `P0 → P1 → P2 → P3 → P4 → P5`. No two phases
   may run together.
3. Update phase status immediately when it changes.
4. Do not expand a phase's scope into another phase's write scope.
5. Stop and escalate if the work requires resolving OQ-006A (the AC2/AC3 capability limit) — that
   is a Product Owner / user decision, not an implementation choice.

## 4. Story Guardrails

- No file under `backend/` may be modified. The `love-contracts` contract is frozen (A1).
- No new pub dependency. `flutter_bloc` and `get_it` are already present; do not add `freezed`,
  `bloc_test`, `bloc_concurrency`, `equatable`, or `build_runner`.
- Never import `package:cupid_api/...` from feature code and never construct `Dio`. Go through
  `mobile/lib/core/network/cupid_api.dart`.
- `Key('home_screen_ready_signal')` in `mobile/lib/features/home/presentation/home_screen.dart` is
  the `mobile-app` runtime readiness signal. It must survive every edit.
- Every new user-facing string is an ARB key added to **both** `mobile/lib/l10n/arb/app_vi.arb`
  (template locale) and `app_en.arb` in the same commit.
- Never render a partner-facing sign affordance (ADR-006c) and never surface a raw
  `CupidApiFailure` type name, status code, or server message.
- No new design token, no new adaptive widget, no per-platform screen fork (D3).
- No local persistence in this feature (OQ4 stays open).
- Flutter SDK is not on `PATH`; commands resolve it via `FLUTTER_SDK_PATH` (default `$HOME/flutter`).

## 5. Plan Update Rule

- Update phase status, owned notes, and test evidence in place.
- Do not redesign the plan during implementation.
- Escalate if the plan is materially wrong.
