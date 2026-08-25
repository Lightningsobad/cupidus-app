# Story Brief: STORY-003 Pet Preview Card Design Fidelity

- Actor: paired user viewing the Home dashboard.
- Capability: the already-mounted pet preview card matches the locked
  design source exactly, and renders its real state (not a load-failure
  placeholder) under the design-fidelity capture harness.
- Business value: visual consistency for the pet feature preview already
  shipped; closes STORY-017 deferral F6 for this widget, and closes the
  req_master.md non-blocking note about the capture-state gap.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only; add a fixture-mode path mirroring
  `PREVIEW_HOME_FIXTURE` so real state is captured, not a load failure.
- Key edge/failure case: the load-failure state seen today under the
  preview harness (no authenticated backend) is a capture gap, not a
  production defect — must not be "fixed" by changing production
  behavior, only by adding a fixture path for verification.
- Existing system entry/discoverability seed: existing mounted widget on
  Home, already reachable — no new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; no open questions.
- Complexity and why: standard — existing widget plus a new fixture-mode
  path (small but real behavior addition beyond a pure visual tweak).
  Lane: mobile.
- Dependencies: NONE.
