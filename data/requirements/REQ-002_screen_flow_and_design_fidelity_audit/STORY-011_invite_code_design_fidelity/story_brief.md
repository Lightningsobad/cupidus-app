# Story Brief: STORY-011 Design Fidelity — Invite / Create Pairing Code

- Actor: any user creating a pairing code to invite their partner.
- Capability: the invite/create-code screen (code display/share component)
  matches the locked design source exactly.
- Business value: visual/brand consistency and trust during pairing setup;
  user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only.
- Key edge/failure case: code display/share component styling (mono type if
  specified) must match the design source.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
