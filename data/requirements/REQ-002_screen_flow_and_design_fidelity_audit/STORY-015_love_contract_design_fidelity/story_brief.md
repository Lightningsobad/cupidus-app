# Story Brief: STORY-015 Design Fidelity — Love Contract

- Actor: any paired user reviewing/signing the Love Contract.
- Capability: the Love Contract screen (clauses, sign-status states) matches
  the locked design source exactly.
- Business value: visual/brand consistency for a key relationship ritual;
  user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Visual-only — does not touch the sign/
  acknowledge business logic already delivered in REQ-001 STORY-006/019.
- Key edge/failure case: per-partner sign-status state styling (unsigned,
  self-signed/awaiting-partner, both-signed) must match the design source.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
