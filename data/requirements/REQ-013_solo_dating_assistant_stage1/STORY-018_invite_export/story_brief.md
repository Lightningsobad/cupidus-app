# Story Brief: STORY-018 Invite Export

- Actor: solo user wanting to invite their partner to a planned activity.
- Capability: export an activity card as a shareable image/card via
  mock-formal or mad-libs templates plus a voice/tone choice, built as a
  SB-125 payload object for REQ-014 continuity (C5).
- Business value: turns internal planning into an actual outward invite
  action — the bridge moment from solo planning to real-world date.
- Key business rules: R-1b (no tracking/read receipts), R-1c (clean decline
  — no implied "seen and ignored"), R-1d (jokes target sender only).
- Key edge/failure case: recipient never responds — app must not surface
  any signal implying they saw and ignored it.
- Existing system entry/discoverability seed: extends STORY-006/STORY-007
  activity cards with a new export action.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; no OQs.
- Complexity and why: complex — multiple templates, tone options, and a
  payload data shape that must anticipate REQ-014 extension without
  requiring it. Lane: shared.
- Dependencies: STORY-006.
