# Story Brief: STORY-003 Relationship Notebook

- Actor: solo user recording what they've learned about their partner.
- Capability: private, deletable notebook with structured
  preference/event fields plus a one-tap "just heard" quick-capture.
- Business value: the missing data layer that lets gifts, conversation
  starters, date scripts, portrait, and compatibility stop being generic
  (SB-129, PHẦN 2 tier 1b).
- Key business rules: never exportable (R-1f); records preferences/events
  only, never frequency/behavior (R-1i); private-by-default and deletable
  (XD4, Tầng 0 fence rules embedded as AC here, not a separate story).
- Key edge/failure case: a structured field must not let the user drift into
  behavior-tracking phrasing — enforced via prompt copy, not a hard filter.
- Existing system entry/discoverability seed: new screen; entry point set by
  UI/UX Designer.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; OQ-2 (compartment
  structure, not blocking).
- Complexity and why: standard — new data object and screen, no complex
  matrix logic. Lane: shared.
- Dependencies: NONE.
