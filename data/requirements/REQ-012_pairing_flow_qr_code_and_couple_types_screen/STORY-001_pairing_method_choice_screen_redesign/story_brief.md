# Story Brief: STORY-001 Pairing-Method Choice Screen Redesign

- Actor: user starting the pairing flow (either side, pre-pairing).
- Capability: update the "how do you want to pair" screen to the current
  design's three-option layout (create code / enter code manually / scan
  partner's QR), replacing the older two-option layout.
- Business value: brings the app's entry point into the pairing flow back in
  line with the current design system, and exposes the new QR-scan path so
  users know it exists.
- Key business rules: the "scan QR" option routes to the same join-code
  screen as "enter code manually" (matching the current design's own
  routing) — it is a faster input method for the same screen, not a
  separate destination.
- Key edge/failure case: none new at this screen level — routing targets
  already exist and function today.
- Existing system entry/discoverability seed: existing screen, existing
  entry point into the pairing flow; only layout/options change.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; no story-level open
  questions.
- Complexity and why: standard — new UX layout decision (3rd option added,
  visual redesign) but no new architecture or backend work. Lane: shared.
- Dependencies: NONE.
