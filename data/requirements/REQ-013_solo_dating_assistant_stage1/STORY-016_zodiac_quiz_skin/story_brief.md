# Story Brief: STORY-016 Zodiac Quiz Skin

- Actor: solo user browsing the app for lightweight fun.
- Capability: a zodiac/quiz-styled presentation skin over the curated
  activity list, always resolving to 3 concrete activity suggestions.
- Business value: Tầng-4 "vỏ" (skin) layer — adds playful engagement without
  creating new content or violating R-1's no-scoring rule.
- Key business rules: must never end in a verdict/label alone — always 3
  concrete activities (anti-flattery, anti-fortune-telling guardrail).
- Key edge/failure case: none new — presentation layer only, no new data.
- Existing system entry/discoverability seed: extends STORY-006's curated
  activity list surface.
- Direct AC/OQ anchors: AC1-3 in `story_master.md`; no OQs.
- Complexity and why: standard — presentation/content-mapping layer over an
  existing data source, no new content authoring. Lane: shared.
- Dependencies: STORY-006.
