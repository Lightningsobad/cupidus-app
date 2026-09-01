# Story Brief: STORY-014 Self-Authored Partner Portrait

- Actor: solo user reflecting on what they've noticed about their partner.
- Capability: a questionnaire the user answers on the partner's behalf,
  provenance-labeled in the layout, editable/deletable, never exported
  (SB-186/188/190, 3e).
- Business value: the R-1 tier-3 opening's flagship feature — a reflective
  "imagined portrait," explicitly framed as the user's own view, not a
  claim about the partner.
- Key business rules: SB-208 position constraint — never reachable from the
  home screen, only from a date or gift flow; R-1h bans asserting the
  partner's actual intent/feelings.
- Key edge/failure case: none new — self-declared-only input, no external
  data source to fail against.
- Existing system entry/discoverability seed: new screen; entry point is
  intentionally STORY-013 or STORY-010/STORY-011, never the home screen.
- Direct AC/OQ anchors: AC1-6 in `story_master.md`; governed directly by the
  amended Invariant Design Rules (R-1 tier-3 condition, R-1f, R-1h).
- Complexity and why: standard — a questionnaire and display screen with a
  policy-driven layout constraint, no complex matrix logic. Lane: shared.
- Dependencies: STORY-003, STORY-013.
