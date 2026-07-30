# Story Master: STORY-003 Auth (Firebase sign-in + refresh-token interceptor)

Status: DONE
Complexity: M
Epic: Foundation
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/auth/`

## Depends On
- STORY-001 (login/onboarding screens need tokens).
- STORY-002 (needs the generated client to call auth endpoints and attach
  refresh logic to the base HTTP client).

## User Story
As a user of the Cupid app, I want to sign in once with Firebase and stay
signed in across sessions so I don't have to re-authenticate constantly.

## In Scope
- Firebase Auth sign-in flow (screens per `cupid-mobile-design/` onboarding
  group — UI/UX Designer to confirm exact screen ids).
- Refresh-token interceptor on the generated API client (STORY-002) so
  expired tokens are transparently refreshed.
- Session persistence across app restarts.

## Out of Scope
- Any backend auth endpoint/flow change — contract frozen (A1).
- Socket.IO handshake auth wiring itself (that is STORY-004's forward-compat
  concern, though it consumes the same Firebase token this story produces).

## Acceptance Criteria
1. User can sign in via the Firebase flow and reach the app's authenticated
   area.
2. An expired access token is refreshed transparently by the interceptor
   without forcing a full re-login, as long as the refresh token is valid.
3. Session persists across a full app restart (cold start after sign-in).
4. Signing out clears local session state and any cached authenticated data.

## Open Items For Downstream Roles
- Tech Lead: ADR must also cover exposing the Firebase token for
  `handshake.auth.token` (Socket.IO forward-compat, R8) so STORY-004 can
  consume it without re-deriving auth logic.
