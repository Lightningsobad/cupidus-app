# Story Brief: STORY-007 Activity Card Lifecycle

- Actor: solo user tracking an activity from idea to memory.
- Capability: 4-state card lifecycle (idea → scheduled → done → memory),
  with photo-as-memory-unit (C4/SB-08) as the terminal state's
  representation.
- Business value: the valid, non-streak replacement for a sense of progress
  and completion (SB-77/78) — fixes the "never feels done" failure mode.
- Key business rules: no streak/score/ranking anywhere (rule 1(f)); cards
  remain deletable at any state (XD4).
- Key edge/failure case: none new — state machine with a deletable terminal
  state.
- Existing system entry/discoverability seed: extends STORY-006's list/card
  surfaces.
- Direct AC/OQ anchors: AC1-6 in `story_master.md`; no story-level OQs.
- Complexity and why: standard — a state machine plus one media attachment,
  no new content-authoring burden. Lane: shared.
- Dependencies: STORY-006.
