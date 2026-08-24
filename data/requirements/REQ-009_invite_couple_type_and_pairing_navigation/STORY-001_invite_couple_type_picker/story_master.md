# Story Master: STORY-001 Invite Couple-Type Picker

Status: PENDING
Complexity: standard
Implementation Lane: shared
Story-Class: standard
Requirement: REQ-009
Screen: `invite` (Mã ghép đôi của bạn), Epic 1 (Core connection / onboarding),
NO_CHROME / NO_TABS

## Artifacts
- [ ] Requirements (Product Owner)
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE. Independent of STORY-002 — see `requirements/requirements.md`
  `## Recommended Story Sequence`.

## User Story
As the user creating a pairing code, I want to tell the app what kind of
couple we are right after my code is generated, so the app captures that
context before pairing continues.

## In Scope
1. On the invite/create-pairing-code screen, after the pairing code is
   already displayed, show a "Tụi mình thuộc kiểu nào?" section with exactly
   4 couple-type cards, then the Continue CTA below it.
2. Author and use the couple-type content catalog (card labels, hints/
   subtext, icon per card, vi + en copy) — see
   `requirements/requirements.md` `## Business Rules And Guardrails` for the
   authored catalog.
3. Persist the selected couple-type on `CupidProfile.coupleType`, surviving
   app restart.
4. Make selection mandatory: the Continue CTA stays disabled until exactly
   one card is selected.
5. Add/restore the design-system node(s) for the invite-screen couple-type
   cards so a fidelity reference exists (own UX Design phase).

## Out of Scope
- A couple-type picker on the join-code (invitee) screen.
- Editing the selected couple-type after this flow (e.g. from Account/profile
  settings).
- Displaying or surfacing the selected couple-type anywhere else in the
  product beyond storing it on `CupidProfile`.
- What screen Continue navigates to — owned by STORY-002; this story does not
  change the destination.
- Redesigning "Fingerprint Vow" or the 5-tab shell/FAB beyond this screen.

## Acceptance Criteria
1. Given a user has created a pairing code, when the invite/create-pairing-
   code screen renders, then the pairing code is shown first, followed below
   by a "Tụi mình thuộc kiểu nào?" section presenting exactly 4 couple-type
   cards (Yêu xa/Long-distance, Cùng thành phố/Same city, Mới hẹn hò/Just
   started dating, Gắn bó lâu dài/Long-term) each with its icon and vi/en
   label + subtext per the authored catalog, then the Continue CTA below the
   cards.
2. Given no couple-type card is selected, when the user views the Continue
   CTA, then it is disabled — the user cannot proceed without choosing
   exactly one couple-type.
3. Given the user selects a couple-type card, when selection changes, then
   exactly one card shows a selected state at a time (selecting a new card
   deselects any previous selection) and the Continue CTA becomes enabled.
4. Given a couple-type is selected and the user presses Continue, then the
   selection is persisted to `CupidProfile.coupleType`, surviving app
   restart — not merely held as local/in-memory UI state.
5. Given the user previously selected a couple-type and returns to this
   screen (e.g. via back navigation) before pairing completes, when the
   screen re-renders, then the previously selected card shows as selected.
6. Given the invite/create-pairing-code screen after this story, when
   compared to the design reference, then it matches the design source for
   the couple-type card section with no visible deviation in layout,
   spacing, colour, typography, or state.
7. Given the join-code (invitee) screen, when viewed after this story, then
   no couple-type picker is present on it.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: the current invite/create-code screen,
  already reachable via its existing navigation path — this story adds
  content to that screen, it does not change how the screen is reached.
- Direct URL only acceptable: N/A — existing reachable screen.

## Dependencies
- Depends on: NONE.
- Must not require any future story.

## Open Question Impact
OQ5 (light theme / EN locale) is unresolved but non-blocking for this story,
same disposition as REQ-002's STORY-011/STORY-036/STORY-037 — dark + `vi` is
the only enabled user-facing configuration; no dedicated light/EN rendered
pass is required.

### Scope Items BLOCKED in this story
- None.

### Scope Items NOT BLOCKED in this story
- All acceptance criteria (1-7) are unblocked.
