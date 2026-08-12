# Story Master: STORY-002 Onboarding & Pairing Flow Navigation Correction

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-002
Scope: A (Screen Flow / Navigation Correction)

## Artifacts
- [x] Requirements (Product Owner)
- [x] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. Independently testable starting from the welcome/login screen
  regardless of STORY-001's status (a tester can reach welcome/login directly
  without exercising the cold-launch decision).

## User Story
As a user moving through account creation, verification, permission grants,
profile setup, and partner pairing, I want each screen to lead me to the
correct next screen in the intended sequence, so that I complete onboarding
and pairing without getting stuck, looped, or dropped onto the wrong screen.

## In Scope
1. Audit and correct forward/back navigation across the full onboarding/
   pairing chain: welcome → login or register; register → otp; otp success →
   permissions; login → forgot-password (and back) or → home if a pairing is
   already complete for that account; permissions → onboarding profile
   setup; profile setup → invite (create code) or join-code (enter code)
   choice; invite → waiting; join-code → waiting or directly to paired (per
   the backend's supported pairing-confirmation flow); waiting → paired;
   paired → love contract; contract → fingerprint vow; vow completion →
   home.
2. Confirm and correct chrome rules across this whole chain: no header
   (NO_CHROME) and no bottom tab bar (NO_TABS) on every screen in this
   sequence; the 5-tab bar must not appear until the user lands on home
   post-pairing.
3. Sign-out navigation: a deliberate, user-initiated sign-out from anywhere
   in the authenticated app tears down the session first, then routes to
   welcome (not login).
4. Mid-session forced re-auth: if a refresh-token failure occurs while the
   app is in active use (not at cold launch), the app routes to login (not
   welcome), preserving the distinction from sign-out.

## Out of Scope
- The cold-launch entry-routing decision itself (splash → welcome/login/home
  resolution) — that is STORY-001.
- Visual/design fidelity of any screen in this chain — each has its own
  Scope B story (STORY-004 through STORY-016).
- Any new onboarding step, screen, or business rule not already present in
  the locked design source.
- The main in-app 5-tab navigation behavior once inside home/chat/pet/money/
  me — only its correct entry point from vow → home is in scope here.

## Acceptance Criteria
1. Given a user on welcome, when they choose to sign in vs. create an
   account, then they reach login or register respectively, and each of
   those in turn leads to its correct next screen (otp for register; home or
   forgot-password for login) per the design source's flow.
2. Given a user completes otp verification for the first time, when otp
   succeeds, then they are routed through permissions → onboarding profile
   setup → invite/join-code choice, in that order, with no chain screen
   skipped and no loop back to welcome/login.
3. Given a user is mid-pairing (has created or entered a pairing code but
   pairing is not yet complete), when they reach the waiting screen, then
   completing pairing on the backend's supported flow routes them to paired,
   then contract, then vow, then home, in that order.
4. Given any screen in the onboarding/auth/pairing chain (splash through
   vow), when it renders, then it has no header chrome and no bottom tab
   bar, and the 5-tab bar first appears only on home after vow completes.
5. Given an authenticated user performs a deliberate sign-out, when the
   sign-out completes, then their session is torn down first and they are
   routed to welcome.
6. Given an authenticated user's session expires or refresh fails while they
   are actively using the app (not at cold launch), when that failure is
   detected, then they are routed to login, not welcome.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the app's own onboarding/pairing screen
  sequence — no new entry point created; this story fixes the transitions
  between already-existing screens.
- Direct URL only acceptable: N/A (not applicable — internal flow
  navigation, not a feature reached by a link).

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — no dependency on STORY-001
  or any Scope B story.

## Open Question Impact
No open question from the central registry has direct impact on this
story's scope.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-6) are unblocked.

## Open Items For Downstream Roles
- [Tech Lead] Decide the exact navigation-guard/routing implementation for
  branching login → home vs. login → forgot-password vs. registration chain,
  and how the backend's pairing-confirmation signal (waiting → paired
  transition) is observed (poll vs. push) — implementation detail within
  this story's approved scope.
- [UI/UX Designer] Confirm no chain screen needs a transitional/loading state
  not already implied by the design source when waiting on a backend
  response (e.g. otp verification in flight, pairing confirmation in
  flight).
