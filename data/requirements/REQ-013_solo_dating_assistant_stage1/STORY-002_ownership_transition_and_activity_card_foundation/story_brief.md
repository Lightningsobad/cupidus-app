# Story Brief: STORY-002 Ownership Transition + Structured Activity-Card Foundation

- Actor: solo (unpaired) user, and later the same user post-pairing.
- Capability: full solo operation with no `coupleId`-shaped blocking
  assumptions, plus a structured activity-card data foundation (price
  range, duration, timeslot, season, headcount, booking-required, distance).
- Business value: this is the single largest, riskiest item in the whole
  requirement (Impact 5 / Effort 5) and unblocks every other Stage-1 and
  `REQ-014` story.
- Key business rules: PO scopes user-visible transition behavior only; Tech
  Lead owns the actual data model (`req_master.md` Story Seeds note).
- Key edge/failure case: existing `coupleId`-assuming code paths must not
  error for a solo user.
- Existing system entry/discoverability seed: none — foundational, mostly
  invisible except where UX surfaces a "solo mode" state.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; no story-level OQs.
- Complexity and why: complex — the whole app's ownership model changes from
  single-owner to two-owner. Lane: shared.
- Dependencies: NONE.
