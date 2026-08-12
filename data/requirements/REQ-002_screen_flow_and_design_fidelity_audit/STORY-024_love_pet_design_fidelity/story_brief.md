# Story Brief: STORY-024 Design Fidelity — Love Pet

- Actor: any paired user viewing the shared Love Pet "Bún".
- Capability: the Love Pet screen's static/vector visuals match the locked
  design source exactly.
- Business value: visual/brand consistency for the flagship relationship-
  growth feature; user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Vector placeholder is confirmed correct;
  Lottie animation deferral is scheduling, not a fidelity gap — out of
  scope.
- Key edge/failure case: N/A beyond per-growth-state static styling check.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
