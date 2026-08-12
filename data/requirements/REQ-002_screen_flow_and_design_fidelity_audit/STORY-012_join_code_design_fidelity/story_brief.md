# Story Brief: STORY-012 Design Fidelity — Join / Enter Pairing Code

- Actor: any user entering their partner's pairing code.
- Capability: the join/enter-code screen (code entry, all states) matches
  the locked design source exactly.
- Business value: visual/brand consistency and trust while completing
  pairing; user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only.
- Key edge/failure case: error/invalid-code state styling must match the
  design source.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
