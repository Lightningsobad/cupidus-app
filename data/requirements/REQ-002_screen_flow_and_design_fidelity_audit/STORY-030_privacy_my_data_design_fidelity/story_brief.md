# Story Brief: STORY-030 Design Fidelity — Privacy / My Data

- Actor: any paired user reviewing data/privacy controls.
- Capability: the screen's 3-tier sensitivity presentation and PDPA
  export copy/control match the locked design source exactly.
- Business value: visual/brand consistency plus user trust in data
  handling; user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. 3-tier model per UX memory §8; PDPA
  export copy fidelity only, no backend logic change.
- Key edge/failure case: N/A beyond per-tier and export-control styling
  check.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
