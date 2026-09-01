# Story Brief: STORY-019 Vietnamese Lunar Calendar And Occasion Rhythm

- Actor: solo user who tracks occasions by the Vietnamese lunar calendar.
- Capability: lunar calendar library plus a named-occasion template library
  (BD2/C7), surfaced as an optional enhancement into gift ideas,
  conversation starters, and date scripts.
- Business value: Tầng-4 rhythm layer — makes the assistant feel culturally
  attuned without being required for any earlier story to work.
- Key business rules: must remain strictly optional everywhere it's
  surfaced — this is the story that resolves the STORY-013 forward-
  dependency risk identified during that story's design (dịp lịch âm was in
  PHẦN 2's item 3d but the library itself is Tầng 4).
- Key edge/failure case: STORY-010/012/013 must be independently verified
  to still work with zero occasion input.
- Existing system entry/discoverability seed: enriches STORY-010, STORY-012,
  STORY-013 screens; no dedicated primary screen.
- Direct AC/OQ anchors: AC1-3 in `story_master.md`; no OQs.
- Complexity and why: standard — a calendar library plus template content,
  no new complex UI. Lane: shared.
- Dependencies: STORY-001.
