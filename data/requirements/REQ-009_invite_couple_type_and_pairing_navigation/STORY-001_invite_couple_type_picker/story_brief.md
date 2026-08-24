# Story Brief: STORY-001 Invite Couple-Type Picker

## Identity

- Parent requirement: REQ-009_invite_couple_type_and_pairing_navigation
- Story master: `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-009_invite_couple_type_and_pairing_navigation/STORY-001_invite_couple_type_picker/requirements/requirements.md`

## Brief

- Actor: the user creating a pairing invitation (inviter), on the
  invite/create-pairing-code screen.
- Capability: after the pairing code is already shown, select one of 4
  couple-type cards, which is required before Continue is enabled.
- Business value: captures relationship-type context early for
  personalization; closes the content gap STORY-011 explicitly excluded.
- Key business rules or guardrails: mandatory selection (Continue disabled
  until one card chosen); persists to `CupidProfile.coupleType` (field
  already exists in the mobile domain model/DTO, confirm actual
  persistence path with Tech Lead); authored 4-card vi/en catalog is in
  `requirements/requirements.md` `## Business Rules And Guardrails` —
  reuse it verbatim, do not re-author.
- Key edge or failure case: user backs out and returns to this screen before
  pairing completes — prior selection must still show as selected.
- Existing system entry / discoverability seed: existing reachable invite
  screen, no new entry point.
- Complexity: standard — new UX decision (new card grid), new content
  catalog, needs UX Design + Tech Lead persistence-contract confirmation.
  Lane: shared.
- Depends on: NONE (independent of STORY-002; see requirement-level
  `## Recommended Story Sequence`).

## Direct Anchors

- Requirement AC / BR anchors: `req_master.md` `## Locked Navigation
  Decisions` item 1; `requirements/requirements.md` `## Business Rules And
  Guardrails` (authored catalog + persistence/mandatory-selection rules).
- Open Question anchors: OQ5 (light theme/EN locale) — non-blocking, same
  disposition as REQ-002 STORY-011/036/037.
- Related story dependencies: STORY-002 (Pairing-choice navigation restore)
  — no structural dependency; STORY-002 owns what Continue navigates to,
  this story does not change or assume that destination.

## Scope Seed

### In Scope

- 4-card couple-type grid below the already-shown pairing code, above
  Continue.
- Authored vi/en content catalog (icons/labels/subtext) — see requirement
  artifact.
- `CupidProfile.coupleType` persistence, mandatory selection, pre-fill on
  return.
- Design-system node(s) for the invite-screen couple-type cards.

### Out of Scope

- Couple-type picker on the join-code screen.
- Editing the selection after this flow (e.g. Account/profile settings).
- Surfacing the selected couple-type anywhere else in the product.
- What Continue navigates to (STORY-002's scope).
