# Story Brief: STORY-021 Solo Post-Date Reflection Question

- Actor: solo user right after finishing a planned date.
- Capability: a short reflection prompt (KY2 solo "waiting" touchpoint)
  triggered by an activity card reaching STORY-007's "done" state, writing
  to the private journal.
- Business value: Tầng-4 retention micro-touchpoint — captures reflection at
  the moment of highest recall, deepening the journal/notebook loop.
- Key business rules: R-1 — never scores/rates the date or the partner;
  solo-only content.
- Key edge/failure case: user dismisses without answering — must not create
  an empty entry or repeat-nag.
- Existing system entry/discoverability seed: triggered from STORY-007's
  lifecycle state, writes into STORY-005's private journal.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; no OQs.
- Complexity and why: trivial — one prompt wired to an existing lifecycle
  transition and an existing journal. Lane: shared.
- Dependencies: STORY-005, STORY-007.
