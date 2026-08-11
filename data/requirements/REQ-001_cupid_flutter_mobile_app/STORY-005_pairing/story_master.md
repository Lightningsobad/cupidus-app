# Story Master: STORY-005 Epic-1 — Pairing / 1:1 Connection

Status: DONE
Complexity: M
Epic: epic-1 (core connection)
Story-Class: standard
Implementation Lane: mobile
Requirement: REQ-001
Backend module: `backend/src/modules/invitations/`
Design reference: `cupid-mobile-design/` — pairing/invite screen group (exact
screen ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001 (design system), STORY-002 (API client), STORY-003 (auth).

## User Story
As a user, I want to invite my partner and form an exclusive 1:1 pair so the
app becomes "ours" and no one else can join our space.

## In Scope
- Invitation creation/send flow (however the backend's invitations module
  exposes it — invite code/link, whatever the frozen contract supports).
- Accepting an invitation and establishing the 1:1 pair.
- Handling the couple-only constraint: once paired, no third party can join;
  UI must reflect paired/unpaired state correctly.

## Out of Scope
- Any invitations endpoint change (A1 frozen).
- Un-pairing/breakup flows unless the backend contract already supports them
  — if it doesn't, this is an open item, not a silent scope decision.

## Acceptance Criteria
1. A user can generate/send an invitation through the app.
2. The invited partner can accept it and the app reflects an active 1:1 pair
   for both users.
3. The app enforces couple-only pairing: a third invitation attempt against
   an already-paired user is rejected/blocked in the UI consistent with
   whatever the backend contract returns.
4. Paired vs. unpaired state is visually distinguishable and gates access to
   paired-only features (chat, timeline, etc. built in later stories).

## Open Items For Downstream Roles
- Tech Lead/Backend: confirm whether the `invitations` module supports an
  unpair/leave flow; if not, flag back to Scrum Master rather than assume.
