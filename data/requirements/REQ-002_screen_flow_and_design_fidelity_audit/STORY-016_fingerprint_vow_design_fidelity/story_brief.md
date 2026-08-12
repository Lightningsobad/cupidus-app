# Story Brief: STORY-016 Design Fidelity — Fingerprint Vow

- Actor: any paired user completing the Fingerprint Vow.
- Capability: the Fingerprint Vow screen (hold-to-sign gesture, dual-touch
  confirmation states) matches the locked design source exactly.
- Business value: visual/brand consistency for a key relationship ritual;
  user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Visual/gesture-affordance only — does not
  redesign the underlying dual-confirmation business logic.
- Key edge/failure case: idle/holding/first-partner-signed/both-signed state
  styling must match the design source exactly.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
