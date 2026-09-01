# Story Brief: STORY-008 Frictionless Activity Capture

- Actor: solo user adding a new activity idea from something they found
  elsewhere.
- Capability: paste-link-to-card (SB-06) plus OS share-sheet import (SB-36)
  into STORY-006's activity list.
- Business value: the two cheapest fixes in the whole 210-candidate
  brainstorm, closing the "hard to add ideas" failure modes (F1, F6).
- Key business rules: no AI parsing (rule 5) — deterministic metadata
  extraction only.
- Key edge/failure case: link metadata fetch fails — must still save the
  raw link rather than fail silently.
- Existing system entry/discoverability seed: extends STORY-006's list; OS
  share-sheet target is a new platform-level entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; no story-level OQs.
- Complexity and why: standard — share-sheet integration has real
  platform-specific work but no new content or policy risk. Lane: shared.
- Dependencies: STORY-006.
