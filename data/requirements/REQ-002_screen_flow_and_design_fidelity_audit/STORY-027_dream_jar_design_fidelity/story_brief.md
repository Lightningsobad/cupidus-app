# Story Brief: STORY-027 Design Fidelity — Dream Jar

- Actor: any paired user tracking a shared savings goal.
- Capability: the Dream Jar screen (animated SVG fill, quick-add presets,
  comparative contribution display) matches the locked design source
  exactly.
- Business value: visual/brand consistency for a shared money-goals
  feature; user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only.
- Key edge/failure case: N/A beyond per-state styling of fill/presets/
  contribution display.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
