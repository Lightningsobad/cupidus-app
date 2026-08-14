# Phase P4 — Pairing-Leg Edges & Chrome (AC2 tail, AC3, AC4)

Owner: mobile-dev | Lane: mobile | Depends On: P1, P3 | Parallelizable: No
Status: PENDING

## Precondition (blocking)

Confirm the `permissions` screen exists after rebase (STORY-009). If missing,
stop and report that dependency — do not build it here.

## Goal

Make `pairingChoice` a routable node, wire the pairing tail that was left as
null seams, and strip header chrome from the two in-chain pairing screens.

## Problems Being Fixed

- **D8** `pair_gate_shell.dart:159` — `pairing_choice` exists only as the
  private `_PairingStack` widget, not routable.
- **D3** `invite_screen.dart:130` — `appBar: CupidHeader(...)` on an in-chain
  screen.
- **D4** `joincode_screen.dart:94` — `appBar: CupidHeader(...)` on an in-chain
  screen.
- **D7** `waiting_screen.dart:18`, `joincode_screen.dart:17` — `onPaired` is a
  caller-supplied seam with no default target ("`paired_screen.dart` is a
  later phase not yet built"). That phase shipped; the seams were never wired.

## Write Scope

- `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart` (new)
- `mobile/lib/core/navigation/pair_gate_shell.dart` (edit)
- `mobile/lib/features/pairing/presentation/screens/invite_screen.dart` (edit)
- `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart` (edit)
- `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart` (edit)
- `mobile/test/features/pairing/**`

## Primary Inputs

- `../architecture/solution.md` D3, D4, D7, D8, ADR-3, ADR-4, ADR-5, ADR-7
- `../ux/uiux-spec.md` graph rows `pairing_choice` → `invite`/`join_code`,
  `invite` → `waiting`, `join_code` → `waiting`|`paired`, `waiting` → `paired`
- `mobile/lib/features/pairing/presentation/waiting_cubit.dart` (existing poll)

## Work

### 1. Promote `pairing_choice` (ADR-5)

Extract `_PairingStack` from `pair_gate_shell.dart:159-239` into
`pairing_choice_screen.dart` as a public `PairingChoiceScreen`, **content
unchanged** — same two actions, same copy, same `Key('pairing_stack')`. The
locked design source has no canvas for this node, so nothing new may be
designed here; this is purely making an existing surface routable.

Register it in `OnboardingRouter`. `pair_gate_shell.dart` keeps using it for
the `PairGateUnpaired` branch, now via the router.

### 2. Chrome removal (ADR-7, AC4)

Remove `appBar: CupidHeader(...)` from `invite_screen.dart` and
`joincode_screen.dart`. Both are in-chain, so NO_CHROME applies.

Do not lose the back affordance: move it to an in-body back control. In
`joincode_screen.dart` the header currently supplies
`onBack: () => Navigator.of(context).maybePop()` (line 96) — preserve that
exact behaviour on the new control.

This is chrome correction, not visual fidelity — AC4 explicitly assigns chrome
to this story while Scope B stories keep pixel fidelity.

### 3. Wire the tail (D7, ADR-4)

- `invite` → `waiting`: already pushes `WaitingScreen`
  (`invite_screen.dart:102`); move it onto the router.
- `waiting` → `paired`: give `WaitingScreen.onPaired` a router-backed default
  (`resetTo(paired)`) instead of leaving it null. Keep the optional parameter
  so tests can still override it.
- `joinCode` → `paired`: give `JoincodeScreen.onPaired` the same
  router-backed default.

**Keep the existing poll (ADR-3).** `WaitingCubit`/`PartnerLinkPoller` already
implement a bounded, lifecycle-aware poll with an `expiresAt` hard stop, a
`WaitingTimedOut` state, and `refreshNow()`. Do not replace it with push and
do not add a second polling path.

**Keep the invitee/inviter asymmetry (ADR-4).** `join_code` goes straight to
`paired` because `acceptInvitation(code)` confirms synchronously; `invite`
must go through `waiting` because the inviter has no synchronous confirmation.
This is a backend-model property, not a UX preference — do not "normalize" the
two paths.

Per `../ux/uiux-spec.md` § Transitional/Loading States, use the existing
in-place spinner/disabled state on `invite`/`join_code` while a pairing
attempt is in flight. No new route, no new loading screen.

## Tests

`mobile/test/features/pairing/`:

- `pairingChoice` → `invite` and → `joinCode`.
- `invite` → `waiting`; `waiting` poll resolving paired → `paired`
  (drive `WaitingCubit` through its `createPoller` seam with a fake clock —
  do not wait on real timers).
- `joinCode` accept success → `paired` directly, with no `waiting` frame in
  between.
- `invite` and `joincode` render **no** `AppBar`/`CupidHeader` (blocker §6.1).
- Back from `joincode` still pops.

## Completion

- `pairing_choice` is routable; the whole pairing leg advances without a
  caller supplying `onPaired`.
- No header on `invite` or `joincode`.
- `flutter analyze` clean, `flutter test` green.

## Stop Rule

If removing the header from `joincode_screen.dart` breaks a Scope B fidelity
test owned by another story, stop and report the conflicting test path rather
than editing that story's expectations.
