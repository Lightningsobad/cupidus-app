# Story Brief: STORY-013 Date Script Generator

- Actor: solo user planning an actual date.
- Capability: a before/during/after date plan generated from budget,
  duration, weather, season, relationship stage, and notebook content, with
  three exits (invite/journal/card) (SB-163..167, 3d).
- Business value: turns the notebook and activity list into a genuinely
  useful planning tool, not just data storage.
- Key business rules: partner-referencing content must comply with R-1g
  (ends in a question) and R-1h (no asserted intent/feelings); lunar-occasion
  input is explicitly deferred to STORY-019 to avoid a forward dependency.
- Key edge/failure case: no lunar-occasion data source yet — must omit that
  input cleanly, not render a broken field.
- Existing system entry/discoverability seed: new screen; also becomes the
  required entry point for STORY-014 and STORY-015 (SB-208 position
  constraint).
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; no story-level OQs.
- Complexity and why: standard — a rules-based generator over existing data
  objects, no new architecture. Lane: shared.
- Dependencies: STORY-003, STORY-005, STORY-006.
