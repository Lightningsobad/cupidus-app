# Story Brief: STORY-026 Design Fidelity — Private Gallery

- Actor: any paired user viewing the shared Private Gallery.
- Capability: the gallery screen, including its Level-1 lock affordance,
  matches the locked design source exactly.
- Business value: visual/brand consistency plus trustworthy sensitive-
  content protection cues; user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Level-1 data sensitivity model (UX
  memory §5/§8) requires a lock/re-auth visual affordance — confirm
  present and correctly styled.
- Key edge/failure case: lock affordance missing or mis-styled must be
  corrected; underlying re-auth logic is out of scope.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
