# Story Brief: STORY-010 Gift Idea Index

- Actor: solo user looking for a gift idea for their partner.
- Capability: gift-typed activity cards indexed by occasion × relationship
  stage × notebook content, plus a free-gift branch and timely reminders
  (D-11, 3a).
- Business value: converts the notebook (STORY-003) into concrete,
  non-generic gift suggestions — one of the "hữu dụng thật" tier's core
  payoffs.
- Key business rules: no commerce, purchase link, or affiliate ever (D-11,
  SB-154) — this is the hardest guardrail in the story.
- Key edge/failure case: empty notebook must not produce an empty gift-idea
  screen — generic fallback required.
- Existing system entry/discoverability seed: new screen, entered from
  STORY-006's activity list as a gift-typed card.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ-3 BLOCKED for
  schedule commitment.
- Complexity and why: standard — indexing/filtering logic over existing data
  objects, no new architecture. Lane: shared.
- Dependencies: STORY-003, STORY-006.
