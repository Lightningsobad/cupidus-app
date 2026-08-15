# Phase P3 — Auth-Leg Edges (AC1, AC2 entry)

Owner: mobile-dev | Lane: mobile | Depends On: P1 + §2 precondition | Parallelizable: Yes (with P2)
Status: PENDING

## Precondition (blocking)

Rebase onto the requirement integration branch and confirm the `otp` screen
exists (STORY-007). At `BaseHead` it is listed in
`mobile/lib/main_preview.dart` `_notImplementedCanvasIds`. If it is missing,
**stop and report that exact dependency** — do not build the otp screen here.

## Goal

Replace the two hardcoded jumps to `home` with router-driven, state-resolved
edges.

## Problems Being Fixed

- **D1** `register_screen.dart:62` — `RegisterSuccess` →
  `pushReplacement(HomeScreen())`. Skips otp → permissions → profileSetup →
  pairingChoice entirely. Direct AC2 violation.
- **D2** `login_screen.dart:116` — `SignInSuccess` →
  `pushReplacement(HomeScreen())` unconditionally. No paired-state branch, no
  resume-in-chain. Direct AC1 violation.

## Write Scope

- `mobile/lib/features/auth/presentation/screens/welcome_screen.dart` (edit)
- `mobile/lib/features/auth/presentation/screens/login_screen.dart` (edit)
- `mobile/lib/features/auth/presentation/screens/register_screen.dart` (edit)
- `mobile/lib/features/auth/presentation/screens/forgot_screen.dart` (edit)
- `mobile/test/features/auth/**`

## Primary Inputs

- `../architecture/solution.md` D1, D2, ADR-1, ADR-2
- `../ux/uiux-spec.md` graph rows `welcome`→`login`/`register`,
  `login`→`home`/resume/`forgot_password`, `register`→`otp`
- P1's `OnboardingRouter` and `OnboardingProgressResolver`

## Work

### `welcome_screen.dart`
Route "sign in" → `login` and "create account" → `register` through
`OnboardingRouter` instead of inline `MaterialPageRoute` builders
(lines 37, 45). Behaviour is already correct — this is the mechanism swap that
lets the chrome guard and order tests see these edges.

### `login_screen.dart`
On `SignInSuccess`, await `OnboardingProgressResolver` and route to the
resolved node with `resetTo` (not `pushReplacement`) — a resumed user must not
be able to swipe back into the login stack.

All five resolver outcomes must be reachable from this screen:
`home`, `loveContract`, `otp`, `profileSetup`, `pairingChoice`.

Show the in-place busy affordance already used by `SignInInProgress` while the
resolve is in flight — per `../ux/uiux-spec.md` § Transitional/Loading States,
no new route and no new loading screen.

Leave `_openForgot` (line 91) and `_openRegister` (line 99) behaviourally
unchanged; move them onto the router for consistency.

### `register_screen.dart`
On `RegisterSuccess`, route to `otp` (`OnboardingRouter.replaceWith`), not
`HomeScreen`. Registration verification is backed by
`AuthRepository.sendEmailVerification()` / `reloadEmailVerified()`, which
already exist — do not add a new verification mechanism.

Leave `_openLogin` (line 49) as a `replaceWith(login)`.

### `forgot_screen.dart`
Confirm back returns to `login` (UX graph row `forgot_password` → back →
`login`). If it already pops correctly, leave the behaviour and only note it —
do not add a redundant explicit route.

## Tests

`mobile/test/features/auth/`:

- welcome → login and welcome → register.
- register success → `otp` (assert it is **not** `home` — this is
  verification-contract blocker §6.2).
- login success × 5 resolver outcomes → correct node each time. Drive the
  resolver through its injected read functions; no Dio, no Firebase.
- login success for an unpaired account never reaches `home`
  (blocker §6.3).
- forgot back edge returns to `login`.

## Completion

- No `HomeScreen` import remains in `login_screen.dart` or
  `register_screen.dart`.
- `flutter analyze` clean, `flutter test` green.

## Stop Rule

If the rebased `otp` screen's constructor requires inputs this story cannot
supply (e.g. a verification token the auth chain does not produce), stop and
report the exact signature mismatch rather than inventing a parameter or
stubbing the screen.
