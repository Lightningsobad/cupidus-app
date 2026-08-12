# Story Master: STORY-001 App Launch / Session-Based Entry Routing Correction

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
- NONE. Independently testable from a cold/terminated app launch regardless
  of STORY-002 or any Scope B story's status.

## User Story
As a user opening the Cupid app (cold start or resume from a fully terminated
state), I want the app to route me to the screen that matches my actual
session/pairing state, so that I always land on a screen that makes sense for
my situation instead of a wrong default (e.g. a login screen when I already
have a valid session, or the wrong screen entirely).

## Background / Confirmed Defect
User-reported, confirmed: opening the app today does not land on the correct
screen for the current session state (concrete example given: it is not the
login screen when it should be). `data/ux/system/ui_ux_system_memory.md` §11
already documents the intended splash-as-auth-check-gate pattern; this story
audits the current entry-routing implementation against that pattern and
corrects the deviation.

## In Scope
1. Splash behaves as the auth-check gate: holds for a minimum dwell (2s),
   resolves the current session/refresh-token state during that hold, then
   routes forward based on that resolution — not a fixed timer-only splash
   that always lands on the same next screen.
2. Routing outcomes: valid/refreshable session → home (main app,
   post-pairing); previously-authenticated session that is now expired/
   invalid → login; no session at all (first install, or after a prior
   deliberate sign-out) → welcome.
3. This routing decision runs once per cold app launch / resume-from-
   terminated-state; it does not re-run (and does not re-navigate the user
   away from their current screen) on every foreground/background transition
   of an already-running, still-valid session.
4. Audit the current entry-route implementation and correct it to match
   AC1/AC2 below.

## Out of Scope
- Visual/design fidelity of the splash, welcome, login, or home screens
  themselves — each has its own Scope B story
  (STORY-003/STORY-004/STORY-005/STORY-017).
- Deliberate sign-out and mid-session forced-re-auth navigation targets —
  those are triggered from within an already-running session, not at cold
  launch, and are covered by STORY-002.
- Any change to how the session/refresh token itself is issued, stored, or
  validated by the backend (backend contract is frozen).

## Acceptance Criteria
1. Given a user with a currently valid (or silently refreshable) session
   opens the app from a cold/terminated state, when the splash's minimum
   dwell and session check complete, then the app routes to home.
2. Given a user with a previously-authenticated but now expired/invalid
   session opens the app from a cold/terminated state, when the splash's
   session check completes, then the app routes to login (not welcome, not
   home).
3. Given a user with no session at all (first install, or after a prior
   deliberate sign-out) opens the app from a cold/terminated state, when the
   splash's session check completes, then the app routes to welcome (not
   login).
4. Given the splash session check is in progress, when the user is on the
   splash screen, then no navigation happens before both the minimum dwell
   and the session resolution complete (no premature or flickering
   redirect).
5. Given the app is merely resumed from background with an already-running,
   still-valid session (not a cold/terminated launch), when the user
   foregrounds the app, then the app does not re-run the full entry-routing
   decision and does not navigate the user away from their current screen.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the app's own cold-launch splash sequence —
  no new entry point is created; this story fixes which screen the existing
  launch sequence lands on.
- Direct URL only acceptable: N/A (not applicable — this is the app's own
  launch behavior, not a feature reached by a link).

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — no dependency on STORY-002
  or any Scope B story.

## Open Question Impact
No open question from the central registry (`conflicts_open_questions.md`)
has direct impact on this story's scope. OQ5 (light theme/`en` locale) only
affects Scope B visual fidelity, not entry-routing logic.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-5) are unblocked.

## Open Items For Downstream Roles
- [UI/UX Designer] Confirm any visual treatment for the splash's session-
  check hold (e.g. loading indicator) does not itself introduce a design
  deviation — coordinate with STORY-003 (Splash design fidelity) so the two
  stories do not produce conflicting splash-screen changes; this story owns
  routing logic only, STORY-003 owns splash visual fidelity.
- [Tech Lead] Decide the exact mechanism for resolving session state during
  the splash hold (e.g. silent token refresh call, local token expiry check)
  and how "resume vs. cold launch" is distinguished at the platform/Flutter
  navigation layer for AC5.
