# Story Brief: STORY-022 Teach-Your-Skill Activity Generation

- Actor: solo user with a declared skill wanting a free date idea.
- Capability: reads STORY-004's skill profile and auto-generates a "teach
  your [skill]" free activity card into STORY-006's curated list (SB-206).
- Business value: Tầng-4 low-cost delight feature — turns existing profile
  data into a zero-authoring-cost personalized activity, deliberately kept
  last-tier per SB-174 rather than folded into STORY-011 (Tầng 3) to respect
  the mandatory tier ordering.
- Key business rules: no skill-quality scoring or comparison; read-only
  relationship to STORY-004 and STORY-006, no schema changes to either.
- Key edge/failure case: user has zero declared skills — must generate
  nothing and show no error, not a broken empty card.
- Existing system entry/discoverability seed: generated card surfaces inside
  STORY-006's existing curated activity list.
- Direct AC/OQ anchors: AC1-3 in `story_master.md`; no OQs.
- Complexity and why: trivial — a simple read-and-generate rule over two
  already-built data sources. Lane: shared.
- Dependencies: STORY-004, STORY-006.
