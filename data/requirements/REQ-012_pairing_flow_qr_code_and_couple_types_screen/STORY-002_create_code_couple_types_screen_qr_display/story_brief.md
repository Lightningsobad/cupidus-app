# Story Brief: STORY-002 Create-Code (Couple Types) Screen QR Display

- Actor: user creating a pairing code (inviter).
- Capability: display a live, scannable QR code encoding the existing
  pairing code on the Couple Types screen, alongside the current text code
  and couple-type picker.
- Business value: lets the partner pair by scanning instead of retyping an
  8-character code, matching the current design system.
- Key business rules: the create-code screen IS and stays the existing
  Couple Types screen (REQ-009 identity, not a new screen); the couple-type
  picker stays positioned after the code/QR (REQ-009 locked order); the
  continue CTA's destination is unchanged from REQ-009 (Waiting-for-partner,
  never Fingerprint Vow) even though the literal design source shows stale
  "Fingerprint Vow" CTA wiring.
- Key edge/failure case: QR must always represent the identical code as the
  text code — no separate/second code value.
- Existing system entry/discoverability seed: existing screen, reached via
  the existing pairing-method choice screen; only content changes.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ2 resolved at
  requirement level (CTA destination unchanged).
- Complexity and why: standard — new UX element (QR rendering) integrated
  into an existing screen, no new backend contract expected (same code
  value, just a QR encoding of it). Lane: shared.
- Dependencies: NONE.
