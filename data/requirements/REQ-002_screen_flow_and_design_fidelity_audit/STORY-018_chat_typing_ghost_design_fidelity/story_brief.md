# Story Brief: STORY-018 Design Fidelity — Chat & Typing Ghost

- Actor: any paired user chatting with their partner.
- Capability: the chat screen (bubbles, Typing Ghost fade, lock affordance)
  matches the locked design source exactly.
- Business value: visual/brand consistency and appropriate privacy signaling
  during a Level-1 data conversation; user directive is 100% match, not
  best-effort.
- Key business rules: audit + fix against `cupid-app-design-system`, dark +
  `vi` enabled configuration only. Level-1 lock affordance must always be
  visible (§5/§8). Typing Ghost fade uses `ghostFade` keyframe exactly.
- Key edge/failure case: N/A beyond the lock-affordance and ghost-fade
  fidelity checks.
- Existing system entry/discoverability seed: existing reachable screen, no
  new entry point.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ5 does not block this
  story.
- Complexity and why: trivial — existing patterns, no new UX/architecture
  decision, matching an already-locked design. Lane: mobile.
- Dependencies: NONE.
