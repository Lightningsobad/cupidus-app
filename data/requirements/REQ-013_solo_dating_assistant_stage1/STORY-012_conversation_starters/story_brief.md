# Story Brief: STORY-012 Conversation Starters

- Actor: solo user who has run out of things to talk about or plan.
- Capability: evergreen topic-tagged conversation-starter cards (bản A) plus
  a scheduled seasonal-events pack (bản A+) that converts directly into an
  activity card (D-13, 3c).
- Business value: closes the "hết chuyện để nói" (nothing left to talk
  about) failure mode with content that's cheap to ship since it's already
  scheduled/dated.
- Key business rules: bản A+ never contains bad/negative news; bản B (a real
  live feed) is explicitly excluded from this requirement.
- Key edge/failure case: none new — static content with date windows.
- Existing system entry/discoverability seed: new screen; entry point set by
  UI/UX Designer.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ-3 BLOCKED for
  schedule commitment.
- Complexity and why: standard — two related static content types shipped
  together as one capability, per PHẦN 2's own single-item grouping.
  Lane: shared.
- Dependencies: STORY-001, STORY-006.
