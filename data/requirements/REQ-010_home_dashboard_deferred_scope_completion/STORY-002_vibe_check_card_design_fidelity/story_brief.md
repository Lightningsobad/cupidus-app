# Story Brief: STORY-002 Vibe-Check Card Design Fidelity

- Actor: paired user viewing the Home dashboard.
- Capability: the already-mounted vibe-check card matches the locked
  design source's two-tile layout exactly.
- Business value: visual consistency for the daily engagement vibe-check
  feature already shipped; closes STORY-017 deferral F6 for this widget.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only.
- Key edge/failure case: N/A beyond the visual-fidelity check.
- Existing system entry/discoverability seed: existing mounted widget on
  Home, already reachable — no new entry point.
- Direct AC/OQ anchors: AC1-3 in `story_master.md`; no open questions.
- Complexity and why: trivial — existing widget, pure visual-fidelity fix,
  no new UX/architecture decision. Lane: mobile.
- Dependencies: NONE.
