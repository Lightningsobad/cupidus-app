# Story Master: STORY-006 Couple Title Shows Both Partner Names

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: backend + mobile
Requirement: REQ-010
Screen: Home dashboard — couple-presence header (`_CoupleHeroHeader` /
`_PresenceRow` in `home_screen.dart`)
Design reference: `cupid-app-design-system` (couple title format "Minh &
Linh"; region audited by REQ-002 `STORY-017`)

## Artifacts
- [x] Requirements (Product Owner) — this file
- [x] UX Design (UI/UX Designer)
- [x] Architecture (Tech Lead)
- [x] Implementation (Development) — P0 backend (`coding-plan/test-results.md`
  Phase P0) and P1 mobile (`coding-plan/test-results.md` Phase P1,
  `visual-fidelity/visual-fidelity-report.md`)
- [ ] Review (Reviewer)

## Depends On
- NONE. Ordered phases (backend surface, then mobile consumption) live
  inside this one story, not as separate stories.

## User Story
As a paired user viewing the Home dashboard, I want the couple title to
show both partners' names, so the dashboard correctly represents our
pairing instead of only my own name.

## In Scope
1. Backend: expose the paired partner's profile data (display name, and
   whatever field the mobile UI needs to render a partner-avatar initial)
   from a user-facing endpoint. `GET /users/me` today returns only the
   signed-in user's `displayName` plus an opaque `partnerId` — this story
   closes that gap.
2. Mobile: consume the new partner-profile data and render the couple
   title in the design's "A & B" format, with the partner avatar disc
   showing the partner's initial.

> Architecture note (Tech Lead, 2026-08-25): In Scope item 1's premise is
> stale. `GET /users/me` already returns `partnerDisplayName`
> (`backend/src/modules/users/users.service.ts:30-40`, covered by
> `users.service.spec.ts:69-131`). The backend phase therefore publishes and
> regression-locks that existing field rather than building a new endpoint, and
> the two phases are parallel, not ordered. See
> `architecture/solution.md` §1 Key Discovery.

## Out of Scope
- Any broader profile-editing UI — already covered by
  `account/presentation/screens/profile_edit_screen.dart`.
- Any change to the couple-presence header's other elements (avatar disc
  layout, couple-type label, days counter) already delivered and
  design-matched by `STORY-017`.

## Acceptance Criteria
1. Given two paired users, when either views the Home dashboard, then the
   couple title displays both partners' names in the design's "A & B"
   format.
2. Given the partner's avatar disc, when the Home dashboard renders, then
   it shows the partner's initial, sourced from the new partner-profile
   data.
3. Given the partner-profile data is temporarily unavailable (for example,
   a network failure), when the Home dashboard renders, then it degrades
   honestly — showing the signed-in user's own name only, with no
   fabricated partner name — rather than erroring.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the couple-presence header already
  mounted and reachable on the Home dashboard; this story extends its data
  source and rendering, it does not add a new screen.
- Direct URL only acceptable: N/A — existing reachable surface, not new.

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed.

## Open Question Impact
NONE.
