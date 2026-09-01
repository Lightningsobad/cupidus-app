# Story Brief: STORY-020 Solo End-Of-Day Closing Ritual

- Actor: solo user winding down at the end of the day.
- Capability: a lightweight "just got home" (~23h) closing prompt (GI7
  solo) that writes a quick capture directly into the private journal.
- Business value: Tầng-4 retention micro-touchpoint — low-effort daily habit
  hook built entirely on top of the existing journal foundation.
- Key business rules: solo-only, no partner-facing content; must respect
  journal's private-by-default/deletable defaults.
- Key edge/failure case: user dismisses without writing — must not create an
  empty entry or repeat-nag in the same session.
- Existing system entry/discoverability seed: writes into STORY-005's
  private journal; contextual touchpoint, not a primary screen.
- Direct AC/OQ anchors: AC1-3 in `story_master.md`; no OQs.
- Complexity and why: trivial — a single prompt writing to an already-built
  journal, no new data model. Lane: shared.
- Dependencies: STORY-005.
