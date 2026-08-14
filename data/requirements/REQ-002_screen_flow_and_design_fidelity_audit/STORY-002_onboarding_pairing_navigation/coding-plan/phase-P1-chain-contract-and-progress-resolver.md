# Phase P1 — Chain Contract & Progress Resolver

Owner: mobile-dev | Lane: mobile | Depends On: NONE | Parallelizable: No
Status: PENDING

Foundation phase. Everything downstream imports from here. Buildable today —
does **not** reference the otp/permissions/vow screens.

## Goal

Move onboarding chain order out of scattered inline `Navigator.push` calls
into one declarative, unit-testable table, and resolve the login resume branch
from signals that already exist.

## Write Scope

- `mobile/lib/core/navigation/onboarding_chain.dart` (new)
- `mobile/lib/core/navigation/onboarding_router.dart` (new)
- `mobile/lib/core/navigation/onboarding_progress_resolver.dart` (new)
- `mobile/test/core/navigation/**` (new tests)

## Primary Inputs

- `../architecture/solution.md` ADR-1, ADR-2
- `../ux/uiux-spec.md` § Corrected Navigation Graph
- `mobile/lib/features/account/domain/cupid_profile.dart`
- `mobile/lib/features/account/data/account_repository.dart` (`fetchProfile`)
- `mobile/lib/features/auth/data/auth_repository.dart` (`reloadEmailVerified`)
- `mobile/lib/features/pairing/presentation/pair_gate_cubit.dart` (failure-
  fallback precedent)

## Work

### 1. `onboarding_chain.dart`

- `enum OnboardingNode { welcome, login, register, forgotPassword, otp,
  permissions, profileSetup, pairingChoice, invite, joinCode, waiting, paired,
  loveContract, vow, home }`
- `OnboardingChain.next(OnboardingNode) -> OnboardingNode?` — canonical
  forward order from the UX graph. This is the single source of truth for
  AC2/AC3 ordering:
  `register → otp → permissions → profileSetup → pairingChoice`,
  `invite → waiting → paired`, `joinCode → paired`,
  `paired → loveContract → vow → home`.
  Branching nodes (`welcome`, `login`, `pairingChoice`) have no single
  successor — return `null` and let the caller pick, rather than encoding a
  fake default.
- `OnboardingChain.isChromeless(OnboardingNode) -> bool` — true for every node
  except `home` (AC4: splash through vow are NO_CHROME/NO_TABS; `home` is the
  first 5-tab surface).

Plain Dart. No Flutter imports beyond none at all — keep it widget-free so the
order table is unit-testable.

### 2. `onboarding_router.dart`

- A builder registry: `Map<OnboardingNode, WidgetBuilder>`, injectable so
  tests can register stubs and so a not-yet-merged screen fails exactly one
  file (ADR-1, §2 precondition).
- `goNext(BuildContext, OnboardingNode from)` — pushes `OnboardingChain.next`.
- `replaceWith(BuildContext, OnboardingNode)` — `pushReplacement`.
- `resetTo(BuildContext, OnboardingNode)` — `pushAndRemoveUntil(..., (r) => false)`,
  used for sign-out/re-auth and for landing on `home`.
- Throws a clear, named error when a node has no registered builder. Do not
  silently no-op — a missing edge must be loud.

### 3. `onboarding_progress_resolver.dart`

Implements `solution.md` ADR-2's ordered rule table over
`AccountRepository.fetchProfile()` and `AuthRepository.reloadEmailVerified()`:

1. `partnerId != null && vowTaken` → `home`
2. `partnerId != null && !vowTaken` → `loveContract`
3. `partnerId == null && !emailVerified` → `otp`
4. `partnerId == null && displayName == null` → `profileSetup`
5. otherwise → `pairingChoice`
6. any throw/failure → `pairingChoice`

Take the two reads as injected functions (mirroring `PairGateCubit`'s and
`SessionGateCubit`'s existing seams), not whole repositories, so tests need no
Dio or Firebase.

`waiting` and `permissions` are deliberately **not** resume targets — see
ADR-2 for the reasoning. Do not add them.

## Tests

`mobile/test/core/navigation/`:

- `onboarding_chain_test.dart` — full forward-order table; branching nodes
  return `null`; `isChromeless` true for every node except `home`.
- `onboarding_router_test.dart` — `goNext` pushes the successor; unregistered
  node throws the named error; `resetTo` clears the stack.
- `onboarding_progress_resolver_test.dart` — one case per rule 1-5 plus the
  throw case; explicitly assert an unpaired account never resolves to `home`.

## Completion

- All three source files exist and are imported by nothing yet (that is fine).
- `flutter analyze` clean, `flutter test` green.
- Order and resolver rules proven by unit tests, not widget tests.

## Stop Rule

If `AccountRepository.fetchProfile()` or `CupidProfile` no longer exposes
`partnerId`, `vowTaken`, or `displayName` after rebase, stop and report —
ADR-2's rule table depends on those three fields and must not be silently
narrowed.
