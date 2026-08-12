# Story Brief: STORY-007 Design Fidelity — OTP Verification

- Actor: any user verifying an OTP code.
- Capability: the otp screen (code input, resend timer, all states) matches
  the locked design source exactly.
- Business value: visual/brand consistency and trust during verification;
  user directive is 100% match, not best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only.
- Key edge/failure case: error/invalid-code and resend-cooldown state
  styling must match the design source.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-4 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
