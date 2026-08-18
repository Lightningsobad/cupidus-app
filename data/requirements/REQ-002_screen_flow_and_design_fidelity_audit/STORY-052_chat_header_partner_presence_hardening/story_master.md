# STORY-052: Chat Header Partner Pairing + Presence Chip

Status: RETRO_PENDING
Retro-Type: RED-PATCH
Fixes: STORY-018_chat_typing_ghost_design_fidelity
Complexity: standard
Story-Class: standard
Implementation Lane: shared (ui-ux-designer avatar/presence slot spec, then
tech-lead component contract, then mobile consumption)

## Artifacts

- [ ] Requirements (Product Owner)
- [ ] UX Design (UI/UX Designer)
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Background (Rework Item)

Source: `data/retro-audit/rework-backlog.md` — RWB-20260816-017, split out of
`STORY-040_chat_typing_ghost_design_fidelity_hardening`'s reviewer finding
R-1 while re-verifying that story's own evidence pair.

The design reference for the `chat` screen renders `Minh ↔ Linh` plus a
`đang online` presence chip at top-right of the header; the implemented
capture renders `Linh` alone with no presence chip. Root cause is
pre-existing and documented in code at `chat_screen.dart:164-169`:
`CupidHeader` exposes a title string only, with no avatar/presence slot, and
was reused as-is rather than reopening a frozen shared component. Not a
STORY-040 regression and not blocking there: the delta pre-dates that
hardening pass, and correcting it means touching `design_system/adaptive/`,
outside a chat-screen story's natural WriteScope either way. The defect
flagged by the reviewer was disclosure only — STORY-040's out-of-scope
enumeration had omitted this delta.

Exact remediation suggested by the surfacing reviewer: UI/UX Designer +
design-system owner to give `CupidHeader` an optional avatar/presence slot
(or an equivalent adaptive variant), then update `chat_screen.dart`'s header
composition to pass the partner pairing (`Minh ↔ Linh`) and online-presence
state, scoped as its own story rather than folded into a future chat
hardening pass.

`CupidHeader` is a shared `design_system/adaptive/` component. Product
Owner and Tech Lead must confirm whether any other screen currently
consuming `CupidHeader` needs the new slot to stay optional/backward
compatible (default: no visible change when the new slot is unset), so this
story does not regress any other `CupidHeader` consumer.

## In Scope
(Product Owner to complete)

## Out of Scope
(Product Owner to complete)

## Acceptance Criteria
(Product Owner to complete)
