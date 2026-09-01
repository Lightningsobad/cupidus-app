# Story Brief: STORY-011 Handmade Gift Ideas By Skill

- Actor: solo user wanting to make a meaningful, personal gift.
- Capability: skill × notebook matrix producing hour-indexed, step-by-step
  handmade gift recipes with a "2 hours tonight" filter (D-11, 3b — the
  strongest branch of the whole vòng 6 brainstorm round).
- Business value: research-backed (RS-E2) — recipients rate handmade gifts
  as more meaningful than bought ones, even when less polished.
- Key business rules: hour-indexed, never VNĐ-indexed (SB-196); never
  suggests "go buy it instead."
- Key edge/failure case: empty skill profile — must redirect to STORY-004 or
  STORY-010, not produce broken/empty output. Flagged as the single highest
  implementation-risk item in the whole requirement.
- Existing system entry/discoverability seed: new screen, entered from the
  gift flow (STORY-010) or the skill profile (STORY-004).
- Direct AC/OQ anchors: AC1-6 in `story_master.md`; OQ-3 BLOCKED for
  schedule commitment.
- Complexity and why: complex — matrix-generation logic across two data
  foundations plus recipe-format content authoring, and the flagged highest
  adoption risk. Lane: shared.
- Dependencies: STORY-003, STORY-004, STORY-006.
