# Architecture: STORY-002 Onboarding & Pairing Flow Navigation Correction

Story-Class: standard | Scope: A (Screen Flow / Navigation Correction)
Lane: mobile (Flutter). No backend, no devops, no schema change.

## 1. Problem Statement (grounded in current code)

Navigation across the onboarding/pairing chain is **decentralized**: every
screen hardcodes its own successor with an inline
`Navigator.push(MaterialPageRoute(builder: (_) => ConcreteScreen(...)))`.
There is no single place where the chain order is expressed, which is the
direct structural cause of the defects this story must fix.

Confirmed defects at `BaseHead` (0c98542):

| # | Location | Defect | AC |
|---|---|---|---|
| D1 | `mobile/lib/features/auth/presentation/screens/register_screen.dart:62` | `RegisterSuccess` → `pushReplacement(HomeScreen())`. Skips the entire otp → permissions → profile setup → pairing chain. | AC2 |
| D2 | `mobile/lib/features/auth/presentation/screens/login_screen.dart:116` | `SignInSuccess` → `pushReplacement(HomeScreen())` unconditionally. No paired-state branch, no resume-in-chain. | AC1 |
| D3 | `mobile/lib/features/pairing/presentation/screens/invite_screen.dart:130` | `appBar: CupidHeader(...)` on an in-chain screen. | AC4 |
| D4 | `mobile/lib/features/pairing/presentation/screens/joincode_screen.dart:94` | `appBar: CupidHeader(...)` on an in-chain screen. | AC4 |
| D5 | `mobile/lib/features/love_contracts/presentation/screens/love_contract_screen.dart:67` | `appBar: CupidHeader(...)`; screen is dual-entry (in-chain **and** post-home via `love_contract_entry_tile.dart:198`), so the header cannot simply be deleted. | AC4 |
| D6 | `mobile/lib/core/di/service_locator.dart:79` | `onSessionExpired: () => getIt<CupidSession>().signOut()` — a refresh failure is made **indistinguishable** from a deliberate sign-out, and nothing navigates on either. AC5 and AC6 therefore cannot differ today. | AC5, AC6 |
| D7 | `mobile/lib/features/pairing/presentation/screens/waiting_screen.dart:18`, `joincode_screen.dart:17` | `onPaired` is a caller-supplied seam with **no default target** ("`paired_screen.dart` is a later phase not yet built"). The chain tail is unwired. | AC3 |
| D8 | `mobile/lib/core/navigation/pair_gate_shell.dart:159` | `pairing_choice` exists only as the private `_PairingStack` widget inside the shell, unreachable as a routable chain node. | AC2 |

Fixing these edge-by-edge would leave the same failure mode in place. The
architecture below moves chain order into one testable table.

## 2. Signal Inventory (what the backend already gives us)

No new endpoint, field, or business rule is introduced. Everything the
routing decisions need already exists:

| Signal | Source | Used for |
|---|---|---|
| `CupidProfile.partnerId` | `AccountRepository.fetchProfile()` (`GET /users/me`) | pairing complete |
| `CupidProfile.vowTaken` | same | vow complete |
| `CupidProfile.displayName` | same | profile setup complete |
| `emailVerified` | `AuthRepository.reloadEmailVerified()` | otp/verification complete |
| `PartnerLink.partnerId` | `PairingRepository.getPartnerLink()` | `waiting` poll (already wired) |
| session state | `CupidSession.state` stream | authenticated vs signed out |
| refresh failure | `CupidAuthInterceptor.onSessionExpired` | AC6 trigger |

`CupidProfile` (`mobile/lib/features/account/domain/cupid_profile.dart`) is the
single richest read of `GET /users/me` and is the authoritative onboarding
progress source. `AccountRepository` is already registered in
`service_locator.dart:96`.

`AuthRepository` is **not** in `getIt`; callers construct it. Keep that
convention — do not add a registration.

## 3. Decisions

### ADR-1 — One declarative chain table, keep imperative Navigator

Add `mobile/lib/core/navigation/onboarding_chain.dart`:

- `enum OnboardingNode { welcome, login, register, forgotPassword, otp,
  permissions, profileSetup, pairingChoice, invite, joinCode, waiting, paired,
  loveContract, vow, home }`
- `OnboardingChain.next(OnboardingNode)` — the canonical forward order, the
  single source of truth for AC2/AC3 "in that order, no screen skipped".
- `OnboardingChain.isChromeless(OnboardingNode)` — AC4's NO_CHROME/NO_TABS
  membership, derived from the node set rather than restated per screen.

Add `mobile/lib/core/navigation/onboarding_router.dart`: a builder registry
mapping each node to a screen, plus `goNext(context, from)`,
`replaceWith(context, node)`, `resetTo(context, node)`.

**Rejected: `go_router`.** Adopting it would rewrite navigation for the whole
app (tabs, gallery viewer, jar detail, chat), far beyond a navigation-
correction story, and would collide with every in-flight Scope B story. The
registry gives us the one property we actually need — order expressed once,
unit-testable without widgets — at a fraction of the blast radius.

### ADR-2 — `OnboardingProgressResolver` resolves the login branch

`mobile/lib/core/navigation/onboarding_progress_resolver.dart`, over
`AccountRepository.fetchProfile()` + `AuthRepository.reloadEmailVerified()`.
Ordered rules, first match wins:

| # | Condition | Resume node |
|---|---|---|
| 1 | `partnerId != null && vowTaken` | `home` |
| 2 | `partnerId != null && !vowTaken` | `loveContract` |
| 3 | `partnerId == null && !emailVerified` | `otp` |
| 4 | `partnerId == null && displayName == null` | `profileSetup` |
| 5 | otherwise | `pairingChoice` |
| — | any failure/throw | `pairingChoice` |

Rule 2 is a deliberate refinement of AC1's "already paired → home": `vowTaken`
is available, and AC3 fixes the order paired → contract → vow → home, so a
paired user who never took the vow must resume at `loveContract`, not `home`.
Sending them to `home` would permanently strand the vow step.

The failure fallback mirrors the existing precedent in
`pair_gate_cubit.dart:39` — an unresolved check must never grant access to a
paired-only surface.

**Deviation from `ux/uiux-spec.md:32`** (flagged for Reviewer): the spec lists
`waiting` as a possible resume target. It is **not** in the table above. The
backend exposes no read for "an invitation I previously created and is still
outstanding" — `PairingRepository` has only `generateInvitation()` (create),
`getPartnerLink()`, and `acceptInvitation()`. Resuming into `waiting` would
require a new endpoint, which "Out of Scope" forbids. Resuming to
`pairingChoice` is lossless: the user re-enters `invite` (which regenerates a
code) or `join_code`. The UX spec delegates this rule to Tech Lead ("per
backend state — Tech Lead to define state-resolution rule"), so this is a
resolution of the open item, not an unapproved scope change.

`permissions` is likewise never a resume target: it is a first-run-only OS
prompt step. Re-prompting on every sign-in would be wrong, and OS grant state
is queryable locally when the chain actually reaches it.

### ADR-3 — `waiting` → `paired` stays **poll**, reusing what exists

`PartnerLinkPoller` + `WaitingCubit`
(`mobile/lib/features/pairing/presentation/waiting_cubit.dart`) already
implement a bounded, lifecycle-aware poll with an `expiresAt` hard stop, a
`WaitingTimedOut` state, and a manual `refreshNow()` fallback. Reuse it
unchanged.

**Rejected: push.** A `RealtimeCoordinator` exists for chat, but binding
pairing confirmation to it means a new backend event contract and new FCM
plumbing — out of scope, and it would replace a tested mechanism with an
untested one to no acceptance-criteria benefit. Resolves UX open item 2.

### ADR-4 — `join_code` → `paired` directly; `invite` → `waiting` → `paired`

The asymmetry is a property of the backend pairing model, not a UX choice:
`acceptInvitation(code)` confirms synchronously for the **invitee**, so
`JoincodeScreen` can advance straight to `paired`. The **inviter** has no
synchronous confirmation available and must observe via ADR-3's poll. This is
already the shape the code assumes (`joincode_screen.dart:15` "immediate — no
intermediate `waiting` step for the invitee"); this story makes it the
documented rule and wires the default targets that D7 left null. Resolves UX
open item 3.

### ADR-5 — No new screens; reuse the two nodes that already exist in disguise

The locked design source has **no canvas** for `pairing_choice` or for an
onboarding-specific profile setup (canvas ids in `main_preview.dart:101-233`
contain `profile`, but neither of the other two). "Out of Scope" forbids any
new onboarding step or screen not in the design source. Therefore:

- `pairingChoice` → promote the existing private `_PairingStack`
  (`pair_gate_shell.dart:159`) to `pairing_choice_screen.dart`, unchanged in
  content, so it becomes a routable node.
- `profileSetup` → the existing `ProfileEditScreen`
  (`features/account/presentation/screens/profile_edit_screen.dart`, canvas
  `profile`) entered in onboarding mode.

### ADR-6 — `SessionTerminationReason` makes AC5 and AC6 distinguishable

Today both paths converge on `CupidSession.signOut()` (D6), so no listener can
tell them apart, and no listener exists. Add
`mobile/lib/core/auth/session_termination.dart`:

- `enum SessionTerminationReason { userInitiated, refreshFailed }`
- `SessionTerminationNotifier` — a broadcast `Stream<SessionTerminationReason>`
  registered once in `service_locator.dart`.

Publishers: `CupidAuthInterceptor` emits `refreshFailed` **before** calling
`signOut()`; `SignOutCubit` emits `userInitiated` **after** teardown succeeds.
Consumer: a single `SessionTerminationListener` mounted once at the app root
(inside `PairGateShell`, alongside `ReminderOverlayHost`) routes
`userInitiated → welcome` and `refreshFailed → login` via
`OnboardingRouter.resetTo`.

AC5's ordering ("teardown first, then navigate") is preserved because the
notifier fires from `SignOutSuccess`, which is already post-teardown — the
existing `sign_out_action.dart:57` ordering is correct and must not be
inverted. `sign_out_action.dart`'s own inline `pushAndRemoveUntil` to
`WelcomeScreen` is removed in favour of the root listener, so sign-out behaves
identically from every future call site.

### ADR-7 — Chrome (AC4) is enforced by the node table, not per screen

- Remove `appBar: CupidHeader` from `invite_screen.dart` (D3) and
  `joincode_screen.dart` (D4). Both are in-chain. Their back affordance moves
  to an in-body control so back navigation is not lost.
- `LoveContractScreen` (D5) is dual-entry and gets an explicit entry mode
  (e.g. `LoveContractEntry { onboardingStep, standalone }`): header hidden for
  `onboardingStep`, retained for the post-home tile entry. Deleting the header
  outright would regress the standalone entry.
- The 5-tab bar needs **no code change**: `CupidTabBar` is mounted only in
  `AppShell` (`app_shell.dart:194`), which is reachable only through
  `PairGatePaired`. NO_TABS already holds structurally. Lock it with a guard
  test that asserts no chain screen mounts `CupidTabBar`, so a future story
  cannot regress it silently.

Chrome is in scope even though pixel fidelity is not: AC4 explicitly assigns
"confirm and correct chrome rules across this whole chain" to this story,
while "Out of Scope" only excludes visual/design fidelity.

## 4. Boundaries And Ownership

- **This story owns**: `mobile/lib/core/navigation/*` (chain, router,
  resolver, listener), the edge/callback wiring inside chain screens, chrome
  removal on in-chain screens, and the session-termination signal.
- **This story does not own**: the content, layout, or visual fidelity of
  `otp`, `permissions`, `vow` (STORY-007 / STORY-009 / STORY-016), or of any
  other Scope B screen. Register them in the router; do not edit their bodies.
- **File-overlap risk**: `love_contract_screen.dart` is owned for fidelity by
  STORY-019 (DONE). This story touches only its chrome/entry-mode parameter.
  Rebase before editing and keep the diff to the header seam.

## 5. Implementation Precondition (dependency gate)

`Depends On` is STORY-007 / STORY-009 / STORY-016 per the Product Owner Ruling
(2026-08-14). At `BaseHead`, `main_preview.dart:222-233` still lists `otp`,
`permissions`, and `vow` in `_notImplementedCanvasIds`, i.e. those three
screens are **not** present on this branch point.

Before P3 begins, the implementer must rebase onto the requirement integration
branch and confirm the three screens exist. Per ADR-1 the router registry is
the only file that names them, so a missing screen fails one file rather than
the whole chain — but the story must still stop on that exact dependency
rather than building the screens itself (the PO ruling forbids absorbing that
work).

This is a scheduling precondition, not a blocker on planning: P1 and P2 are
fully buildable today with no reference to those three screens.

## 6. Test Strategy

- **Unit (no widgets)**: `OnboardingChain.next` order table, chromeless
  membership, `OnboardingProgressResolver` rule table including the
  failure fallback. This is where AC1/AC2/AC3 ordering is actually proven.
- **Widget**: each corrected edge fires the right route; chrome guard test
  enumerating every chain node asserts no `AppBar`/`CupidHeader` and no
  `CupidTabBar`; sign-out → welcome vs refresh-failure → login.
- **Out of scope for implementation phases**: no e2e, no Playwright, no
  emulator gate. Existing seams (`create*Cubit` function injection) make all
  of the above runnable under `flutter test` with no live Firebase or Dio.
