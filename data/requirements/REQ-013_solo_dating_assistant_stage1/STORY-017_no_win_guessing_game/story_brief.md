# Story Brief: STORY-017 No-Win Guessing Game

- Actor: solo user curious about how well they know their partner.
- Capability: a guessing game with no score/winner, output framed as
  "places we see differently," real-answer reconciliation locked until
  Stage 2.
- Business value: a low-stakes, non-comparative curiosity hook that
  deliberately avoids false confidence — sets up REQ-014's two-way
  reconciliation feature without needing it.
- Key business rules: R-1 (no scoring/ranking); real answers must never be
  available solo, since they require the partner's own input.
- Key edge/failure case: none new — self-contained game, no external data.
- Existing system entry/discoverability seed: new standalone screen, no
  position constraint from source material.
- Direct AC/OQ anchors: AC1-3 in `story_master.md`; no OQs.
- Complexity and why: standard — a game UI and framing logic, no matrix
  content authoring. Lane: shared.
- Dependencies: NONE.
