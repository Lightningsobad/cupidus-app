# Story Brief: STORY-015 Compatibility Lookup Table

- Actor: solo user curious about a lightweight compatibility read.
- Capability: static 144-cell (zodiac) + 256-cell (MBTI) hand-authored
  lookup table producing a range-based "quartet" output (D-14, 3f).
- Business value: the R-1 tier-3 opening's other flagship feature — a
  deterministic, non-flattering compatibility read that can never adapt to
  what the user wants to hear (rule 5's safety argument for opening R-1).
- Key business rules: SB-208 position constraint (never home screen);
  percentage display explicitly banned (D-14); every cell needs a point of
  friction (content-approval rule); R-1g/R-1h apply to every result.
- Key edge/failure case: none new — pure table lookup, no computed scoring.
- Existing system entry/discoverability seed: new screen; entry point is
  intentionally STORY-013 or STORY-010/STORY-011, never the home screen.
- Direct AC/OQ anchors: AC1-6 in `story_master.md`; OQ-3 BLOCKED for
  schedule commitment (400 cells is OQ-3's largest single content line
  item).
- Complexity and why: complex — largest single content-authoring burden
  after STORY-006, plus the highest policy sensitivity in the requirement
  (R-1 tier-3 opening applies directly). Lane: shared.
- Dependencies: STORY-003, STORY-013.
