# Story Master: STORY-002 Create-Code (Couple Types) Screen QR Display

Status: PENDING
Complexity: standard
Story-Class: standard
Implementation Lane: shared
Requirement: REQ-012
Screen: Create-code screen ("Tạo mã mời" / "Create the code") — this IS the
existing Couple Types screen, per REQ-009 identity constraint; updated in
place, not replaced.
Design reference: `cupid-app-design-system/Cupid Screens.dc.html` lines
170-224 (`isInvite` block: QR art + pulsing scan-line animation, 8-char
code, waiting-for-partner indicator, share/copy actions, simulate-join link,
then the couple-type picker "Tụi mình thuộc kiểu nào?" 4-card grid, then the
continue CTA)
Design-Screen: TBD (implementer resolves and records after rendering
candidates)
Design-Surface: cupid-app

## Artifacts
- [x] Requirements (Product Owner) — this file
- [x] UX Design (UI/UX Designer)
- [x] Architecture (Tech Lead)
- [x] Implementation (Development) — commit `76b25fdaa8aa100e740ca54d4ae419a52b604334`
      (mobile-dev, Alex-Mobile-Dev-3); BUG-20260825-002 confirmed pre-existing
      at BaseHead, deferred (non-blocking, not a STORY-002 regression)
- [ ] Review (Reviewer)

## Depends On
- NONE.

## User Story
As a user creating a pairing code, I want the Couple Types screen to display
my live pairing QR code alongside the existing text code, so my partner can
pair with me by scanning instead of retyping the code.

## In Scope
1. Render a live, scannable QR code encoding the same pairing code already
   shown as text on this screen, styled per the current design (card frame,
   center pairing-heart badge, subtle scan-line accent).
2. Keep the existing 8-character text code, "waiting for partner" indicator,
   share/copy actions, and expiry messaging unchanged in business behavior —
   only the addition of the QR representation of the same code is new.
3. Preserve the existing couple-type picker ("Tụi mình thuộc kiểu nào?",
   4-card grid) on this same screen, positioned after the code/QR, per the
   REQ-009-locked placement — do not move it earlier or extract it to a
   different screen.
4. Preserve this screen's identity as the existing Couple Types screen — no
   new/separate screen is created.
5. Continue CTA below the couple-type picker keeps its existing REQ-009-
   locked destination (Waiting-for-partner for the inviter). Only the CTA's
   visual styling may be updated to match the current design; its
   destination is unchanged (see `requirements/requirements.md` OQ2 — the
   design source's literal "Fingerprint Vow" CTA wiring is stale and must
   not be implemented).

## Out of Scope
- Couple-type card content (labels, icons, hints) — already authored under
  REQ-009; not touched here.
- Any change to the post-pairing navigation graph — REQ-009 locked, not
  reopened (OQ2).
- The pairing-method choice screen (STORY-001) and the join-code screen's
  scanning capability (STORY-003).
- QR-code expiry/regeneration mechanics beyond what the existing text-code
  expiry already governs — the QR encodes the same code and expires with it.

## Acceptance Criteria
1. Given a user is on the create-code (Couple Types) screen, when it
   renders, then a live QR code encoding the current pairing code is shown
   above the text code, matching the current design's visual treatment.
2. Given the pairing code has not yet expired, when a partner scans the
   displayed QR, then it resolves to the same code as the displayed text
   code (both represent one identical pairing code, not two different
   values).
3. Given the couple-type picker is shown on this screen, when the screen is
   compared to the current design and to REQ-009's locked placement rule,
   then the picker still appears after the code/QR block, unchanged in
   position.
4. Given the continue CTA is tapped after a couple type is selected, when
   navigation is evaluated, then it goes to the existing REQ-009-locked
   Waiting-for-partner destination — never to Fingerprint Vow.
5. Given the screen renders in the enabled dark theme + `vi` locale, when
   compared against `cupid-app-design-system`'s corresponding screen, then
   layout, spacing, color/token usage, and typography match, including the
   new QR element.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — the existing Couple Types / create-
  code screen; only its content (QR addition) is updated.
- Direct URL only acceptable: NO — reached via the existing pairing-method
  choice screen (STORY-001 updates that entry point's layout, not its
  routing into this screen).

## Dependencies
- Depends on: NONE.
- Must not require any future story: confirmed — this screen is reachable
  today via the existing choose-method screen regardless of STORY-001's or
  STORY-003's delivery order.

## Open Question Impact
OQ2 in `requirements/requirements.md` "Open Question Triage" is RESOLVED
(NO — CTA destination unchanged from REQ-009) and carried into AC4 and
Out of Scope above. No unresolved OQs remain for this story.
