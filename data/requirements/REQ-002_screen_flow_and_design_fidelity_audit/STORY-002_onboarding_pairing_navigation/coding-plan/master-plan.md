# Master Plan: STORY-002 Onboarding & Pairing Flow Navigation Correction

Story-Class: standard | Lane: mobile only | Phases: 5
Architecture: `../architecture/solution.md`
UX: `../ux/uiux-spec.md`

## 1. Scope Summary

Correct the onboarding/pairing navigation chain by moving chain order out of
scattered inline `Navigator.push` calls into one declarative table
(`solution.md` ADR-1), resolve the login resume branch from signals that
already exist (ADR-2), wire the chain tail that was left as null seams (ADR-4),
make deliberate sign-out and mid-session refresh failure distinguishable
(ADR-6), and enforce NO_CHROME/NO_TABS from the node table (ADR-7).

No backend change. No new endpoint, field, screen, or business rule.

## 2. Dependency Precondition

STORY-002 `Depends On` STORY-007 / STORY-009 / STORY-016 (otp, permissions,
vow screens). At `BaseHead` those three are absent
(`mobile/lib/main_preview.dart:222-233`).

- **P1 and P2 are buildable now** — neither references those screens.
- **Before P3**, rebase onto the requirement integration branch and confirm
  `otp`, `permissions`, and `vow` screens exist. If any is still missing, stop
  and report the exact missing dependency. Do **not** build those screens
  here (Product Owner Ruling 2026-08-14 forbids absorbing that work).

## 3. Phase Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|---|---|---|---|---|---|---|---|---|---|
| P1 Chain contract & progress resolver | mobile-dev | mobile | NONE | No (foundation) | `mobile/lib/core/navigation/onboarding_chain.dart`, `mobile/lib/core/navigation/onboarding_router.dart`, `mobile/lib/core/navigation/onboarding_progress_resolver.dart`, `mobile/test/core/navigation/**` | `solution.md` ADR-1/ADR-2, `ux/uiux-spec.md` §Corrected Navigation Graph, `features/account/domain/cupid_profile.dart`, `features/account/data/account_repository.dart`, `features/auth/data/auth_repository.dart` | `OnboardingNode` enum, `OnboardingChain.next`/`isChromeless`, `OnboardingRouter` builder registry + `goNext`/`replaceWith`/`resetTo`, `OnboardingProgressResolver` | Unit: forward-order table, chromeless membership, resolver 5-rule table + failure fallback | PENDING |
| P2 Session termination signal (AC5/AC6) | mobile-dev | mobile | P1 | Yes (with P3) | `mobile/lib/core/auth/session_termination.dart`, `mobile/lib/core/auth/cupid_auth_interceptor.dart`, `mobile/lib/core/di/service_locator.dart`, `mobile/lib/features/auth/presentation/sign_out_cubit.dart`, `mobile/lib/features/auth/presentation/sign_out_action.dart`, `mobile/lib/core/navigation/session_termination_listener.dart`, `mobile/test/core/auth/**` | `solution.md` ADR-6, D6, `cupid_auth_interceptor.dart`, `service_locator.dart:76-81` | `SessionTerminationReason` enum + notifier, interceptor emits `refreshFailed`, `SignOutCubit` emits `userInitiated`, root listener routing welcome vs login | Unit: notifier emission order (teardown before signal). Widget: sign-out → welcome, refresh failure → login | PENDING |
| P3 Auth-leg edges (AC1, AC2 entry) | mobile-dev | mobile | P1, §2 precondition | Yes (with P2) | `mobile/lib/features/auth/presentation/screens/welcome_screen.dart`, `login_screen.dart`, `register_screen.dart`, `forgot_screen.dart`, `mobile/test/features/auth/**` | `solution.md` D1/D2, ADR-1/ADR-2, `ux/uiux-spec.md` graph rows 1-6 | welcome → login/register via router, login → resolver-driven target, register → otp (replaces `HomeScreen` jump), forgot ↔ login back edge | Widget: each auth edge routes correctly; login branches across all 5 resolver outcomes | PENDING |
| P4 Pairing-leg edges & chrome (AC2 tail, AC3, AC4) | mobile-dev | mobile | P1, P3 | No | `mobile/lib/core/navigation/pair_gate_shell.dart`, `mobile/lib/features/pairing/presentation/screens/pairing_choice_screen.dart`, `invite_screen.dart`, `joincode_screen.dart`, `waiting_screen.dart`, `mobile/test/features/pairing/**` | `solution.md` D3/D4/D7/D8, ADR-3/ADR-4/ADR-5/ADR-7 | `_PairingStack` promoted to `PairingChoiceScreen`, header removed from invite/joincode with in-body back, `onPaired` defaults wired (invite→waiting→paired, joincode→paired) | Widget: pairing choice → invite/joincode, invite → waiting, waiting poll → paired, joincode → paired; no header on either screen | PENDING |
| P5 Post-pairing tail & chrome guard (AC3 tail, AC4) | mobile-dev | mobile | P4 | No | `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart`, `mobile/lib/features/love_contracts/presentation/widgets/love_contract_entry_tile.dart`, `mobile/lib/main_preview.dart`, `mobile/test/core/navigation/chain_chrome_guard_test.dart`, `mobile/test/features/love_contracts/**` | `solution.md` D5, ADR-7, `ux/uiux-spec.md` graph rows paired→home | `LoveContractEntry` mode (header hidden in-chain, kept standalone), paired → contract → vow → home tail wired, chain-wide chrome guard test | Widget: contract entry-mode chrome both ways, vow → home. Guard: no chain node mounts `AppBar`/`CupidHeader`/`CupidTabBar` | PENDING |

## 4. Sequencing

```
P1 ──┬── P2 ──┐
     │        ├── (P2 and P3 touch disjoint files; may run in parallel)
     └── P3 ──┘
              └── P4 ── P5
```

P2 and P3 both depend only on P1 and share no write-scope file, so they are
safe to run concurrently. P4 needs P3's router-driven auth edges in place
before it can wire the chain tail. P5 closes the tail and locks chrome.

## 5. Cross-Cutting Rules

- Every new navigation call goes through `OnboardingRouter`. Do not add a new
  inline `Navigator.push(MaterialPageRoute(builder: (_) => SomeScreen()))`
  inside a chain screen — that is the exact pattern this story removes.
- Do not edit the body/layout of `otp`, `permissions`, `vow`, or any Scope B
  screen. Register them in the router; nothing more.
- Preserve the existing `create*Cubit` function-injection seams. They are what
  keep these tests runnable without live Firebase or Dio.
- AC5 ordering is fixed: session teardown completes before any navigation
  fires. Do not invert it.
- Do not register `AuthRepository` in `getIt` — callers construct it, and that
  convention is load-bearing for the preview harness.

## 6. Verification Contract

Blockers (any of these fails the story):

1. Any chain screen renders a header or the 5-tab bar (AC4).
2. `register` success reaching `home` without traversing the chain (AC2).
3. `login` success reaching `home` for an unpaired or vow-incomplete account
   (AC1, ADR-2 rules 2-5).
4. Deliberate sign-out landing on `login`, or mid-session refresh failure
   landing on `welcome` (AC5/AC6 inverted).
5. Navigation firing before session teardown completes (AC5).
6. Any chain node unreachable or looping back to `welcome`/`login` mid-chain
   (AC2).

Gates: `flutter analyze` clean and `flutter test` green in the story worktree.
No e2e, Playwright, or emulator gate inside any implementation phase.
