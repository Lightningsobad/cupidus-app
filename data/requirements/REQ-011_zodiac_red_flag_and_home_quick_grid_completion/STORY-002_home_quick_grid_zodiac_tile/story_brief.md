# Story Brief: STORY-002 Home Dashboard Quick Grid — Zodiac Red Flag Tile

- Actor: paired user viewing the Home dashboard.
- Capability: a new `Zodiac Red Flag` tile in the Home quick grid,
  alongside `Synced Alarm`, navigating to STORY-001's screen.
- Business value: completes the Home dashboard's 2-column quick-grid
  design fidelity (closes REQ-010's parked deferral item) and gives the
  new Zodiac Red Flag feature a real discovery path.
- Key business rules: matches the locked design's 2-column layout exactly;
  tap target navigates to STORY-001's route.
- Key edge/failure case: none beyond normal navigation — no new loading/
  error state introduced by this story.
- Existing system entry/discoverability seed: new tile on the existing,
  always-reachable Home dashboard quick grid; no new top-level entry point.
- Direct AC/OQ anchors: AC1-3 in `story_master.md`; no open questions.
- Complexity and why: standard — new UI element plus real navigation
  wiring to a screen built in a separate story, not a pure visual tweak.
  Lane: mobile.
- Dependencies: STORY-001 (screen/route must exist first).
