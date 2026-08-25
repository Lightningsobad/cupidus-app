# Story Brief: STORY-006 Couple Title Shows Both Partner Names

- Actor: paired user viewing the Home dashboard.
- Capability: the couple title reads "A & B" (both partner names) with a
  real partner-avatar initial, backed by a new partner-profile API
  surface.
- Business value: accurate pairing identity display; closes STORY-017
  deferral F4 (couple title previously showed only the signed-in user's
  own name, `GET /users/me` exposed no partner profile).
- Key business rules: one story with ordered phases (backend surface, then
  mobile display) per the producer/consumer rule — nothing is observable
  until both phases ship, so this is not two stories.
- Key edge/failure case: must degrade honestly (own name only, no
  fabricated partner name) when partner-profile data is unavailable.
- Existing system entry/discoverability seed: existing couple-presence
  header on Home, already reachable — no new entry point, only extended
  data/rendering.
- Direct AC/OQ anchors: AC1-3 in `story_master.md`; no open questions.
- Complexity and why: standard — a real backend contract addition plus
  mobile consumption, ordered phases within one story. Lane: backend +
  mobile.
- Dependencies: NONE.
