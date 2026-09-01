# Story Brief: STORY-006 Curated Cross-Stage Activity List

- Actor: solo user browsing for activity/date ideas.
- Capability: a curated, versioned list of 150-250 hand-edited activity
  cards with real VNĐ price ranges, absorbing the existing `dream_jar`
  module as the "shared dreams" activity type (C1, SB-01/SB-61/SB-122).
- Business value: the backbone content object for nearly every downstream
  Stage-1 story (lifecycle, capture, gifts, conversation starters, date
  script, zodiac skin, invite export, teach-your-skill).
- Key business rules: static/versioned content only (rule 5); every card
  passes human content review before shipping.
- Key edge/failure case: `dream_jar` module's exact current backend state is
  unconfirmed — Tech Lead resolves at architecture time, not blocking this
  story's creation.
- Existing system entry/discoverability seed: new screen; entry point set by
  UI/UX Designer.
- Direct AC/OQ anchors: AC1-5 in `story_master.md`; pre-existing taxonomy OQ
  RESOLVED, `dream_jar` path OQ UNRESOLVED/non-blocking, OQ-3 resourcing
  BLOCKED for schedule commitment.
- Complexity and why: complex — largest content volume in the requirement,
  versioned content-package mechanics, plus folding in an existing partially
  built module. Lane: shared.
- Dependencies: STORY-001, STORY-002.
