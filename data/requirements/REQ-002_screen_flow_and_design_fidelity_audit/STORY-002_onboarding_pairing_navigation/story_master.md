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
- STORY-007 (otp_design_fidelity), STORY-009 (permissions_design_fidelity),
  STORY-016 (fingerprint_vow_design_fidelity). These three Scope B stories
  own building the otp, permissions, and vow screens themselves to the
  locked design source; STORY-002 only wires the routing/transitions into
  and out of those screens and cannot be implemented against screens that do
  not yet exist in the app. See "Product Owner Ruling" below.
- Independent of STORY-001: a tester can still reach welcome/login directly
  without exercising the cold-launch decision, so STORY-001's status does
  not block this story; only the otp/permissions/vow legs are gated on
  STORY-007/STORY-009/STORY-016.

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
   skipped and no loop back to welcome/login. (The otp and permissions
   screens themselves are built by STORY-007 and STORY-009 respectively;
   this criterion covers only the transition into and out of each screen,
   not the screen content.)
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

## Product Owner Ruling (2026-08-14)

A prior Tech Lead attempt on this story (blocker `MISSING_CHAIN_SCREENS`,
recorded 2026-08-12) found AC2/AC3 route through the otp, permissions, and
vow screens and, at that time, found those screens had no implementation
anywhere in the repo — recommending either new build stories that STORY-002
would depend on, or reclassifying STORY-002 as complex to absorb three
net-new screens. Re-checked against the current repo: `mobile/lib/main_preview.dart`
still lists `otp`, `permissions`, and `vow` in `_notImplementedCanvasIds`
with no shipped screen, confirming the blocker's finding was accurate at the
time. However, each of these three screens already has a dedicated Scope B
design-fidelity story in this same requirement's backlog — STORY-007
(otp_design_fidelity), STORY-009 (permissions_design_fidelity, registry
status DONE), and STORY-016 (fingerprint_vow_design_fidelity, build tasks
in progress/complete as of this ruling). Scope B design-fidelity stories in
this requirement are "fix, not audit" scope (see STORY-009 AC2: "the
deviation is corrected in the rendered app... and re-verified"), so they own
building each screen to match the locked design source, not merely auditing
a screen assumed to already exist.

Ruling: STORY-002's `Depends On` becomes STORY-007, STORY-009, STORY-016,
replacing NONE. These three stories own building/shipping the otp,
permissions, and vow screens themselves; STORY-002 owns only the
routing/transition logic connecting them, consistent with its existing "Out
of Scope" item ("Visual/design fidelity of any screen in this chain — each
has its own Scope B story"). Creating brand-new net-new-build stories, or
reclassifying STORY-002 as complex to absorb screen construction, is
unnecessary — the build owners already exist in the backlog. AC2 is amended
to make explicit that STORY-002 covers only the transition into and out of
the otp/permissions screens, not their content.

This does not authorize STORY-002 to build or modify the otp/permissions/vow
screen content itself, and does not change STORY-007/STORY-009/STORY-016's
independent design-fidelity scope. If any of those three stories is not yet
`MERGE_COMPLETE` when STORY-002 implementation is scheduled, STORY-002 stays
blocked on that exact dependency rather than absorbing the missing build
work.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the app's own onboarding/pairing screen
  sequence — no new entry point created; this story fixes the transitions
  between already-existing screens.
- Direct URL only acceptable: N/A (not applicable — internal flow
  navigation, not a feature reached by a link).

## Dependencies
- Depends on: STORY-007, STORY-009, STORY-016 (see "Product Owner Ruling"
  above).
- Must not require STORY-001: confirmed — no dependency on STORY-001's
  cold-launch entry-routing decision.

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
