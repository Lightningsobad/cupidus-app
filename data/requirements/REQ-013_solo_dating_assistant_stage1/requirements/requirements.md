# Requirement Breakdown: REQ-013 Solo dating assistant — Stage 1 activities & private journal

## Source Artifacts

- Requirement master: `data/requirements/REQ-013_solo_dating_assistant_stage1/req_master.md`
  (amended `## Invariant Design Rules` — R-1 tier-3 opening, R-1e..R-1i,
  content-approval rule, rule 5 runtime-scope clarification — before this
  breakdown was drafted).
- `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/development.md`
  `## Convergence Notes` → `### ★ BẢN BÀN GIAO CUỐI (v7)` — PHẦN 0-4 (lines
  1461-1652). This is the effective handoff; the "Bổ sung vòng 4/5/6" blocks
  elsewhere in the same file are superseded reasoning history, not used here.
- `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/idea.md` —
  locked decisions D-1..D-14.
- `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/brainstormer-checkpoint.md`.

## Context Summary

- Request summary: Stage 1 ("chặng 1") of the app is "mờ nhạt" (thin) — 10/13
  journeys are empty and the activity card is a dead line of text with no
  lifecycle. A 7-round brainstorm converged on a breadth expansion for this
  stage, gated on first amending REQ-013's R-1 invariant rule (done in
  `req_master.md` before this file was drafted).
- Primary actor: a single user who already has a specific real-life "mối"
  (D-1) but whose partner has not installed the app. Stage 1 must be fully
  usable alone.
- Problem to solve: the app currently has no structured activity object, no
  data about the specific relationship, and no lifecycle/result — so every
  suggestion is generic and nothing ever feels "done."
- Business outcome: three parallel data foundations (structured activity
  card, relationship notebook, skill profile) unlock a stack of concrete
  utility features (gifts, conversation starters, date scripts, a
  self-authored partner portrait, a compatibility lookup), topped by a
  retention/rhythm layer (zodiac/quiz skin, guessing game, invite export,
  lunar-calendar rhythm) — in that mandatory order (SB-174).
- Success signal: the requirement's hard gate below passes — Stage 1 is fully
  usable end-to-end by a single, unpaired user.
- Notes on current project context: this requirement absorbs
  `IDEA-20260829-001` in place (D-2) rather than becoming a new requirement.
  It does **not** absorb PHẦN 3 of the v7 handoff (bidirectional link /
  "chặng 1.5", portrait-reconciliation reward, real-news feed) — that is
  candidate scope for `REQ-014`.

## Scope Decision

### In Scope

Five build-order tiers (SB-174, mandatory — do not reorder), plus two
pre-existing req_master seeds not covered by PHẦN 2 (BD1, sequenced first
since it touches all copy).

1. **Prerequisite/foundation wave** — STORY-001 (BD1 address terms),
   STORY-002 (M2 ownership transition, extended with the SB-76 structured
   activity-card data foundation), STORY-003 (relationship notebook,
   SB-129), STORY-004 (skill profile, SB-197), STORY-005 (private journal,
   C6). Tầng 0's "hàng rào" rules (default-private, deletable, clean decline
   door, no export) are **not** their own story — they are cross-cutting
   acceptance criteria embedded in STORY-003, STORY-004, STORY-005, and every
   later story that touches notebook/portrait/compatibility data, because
   PHẦN 2 itself describes Tầng 0 as "mostly rules and defaults" that "can't
   be patched in later," not a delivery slice with its own standalone value.
2. **Tầng 2 — hết nhạt**: STORY-006 (curated activity list, C1, absorbing
   the original req_master C1 seed and the `dream_jar` module), STORY-007
   (activity card lifecycle, C2, absorbing the C4/SB-08 "photo is the memory
   unit" decision as the memory-stage representation), STORY-008
   (frictionless capture, C3), STORY-009 (solo "thinking of you" gesture,
   GI3 solo — placed here, not Tầng 4, because it is a cheap journey-gap fix
   whose only dependency is STORY-005).
3. **Tầng 3 — hữu dụng thật**: STORY-010 (gift idea index), STORY-011
   (handmade gift ideas by skill), STORY-012 (conversation starters, mồi
   chuyện bản A + A+), STORY-013 (date script generator), STORY-014
   (self-authored partner portrait), STORY-015 (compatibility lookup table).
   STORY-014 and STORY-015 must not be entered from the home screen (SB-208)
   — entry is only from a date (STORY-013) or a gift flow (STORY-010/011).
4. **Tầng 4 — vỏ, nhịp, giữ chân (last)**: STORY-016 (zodiac/quiz skin),
   STORY-017 (no-win guessing game), STORY-018 (invite export, C5, designed
   as an SB-125 payload object for `REQ-014`), STORY-019 (Vietnamese lunar
   calendar & occasion rhythm, extending the original BD2 seed with the C7
   template library), STORY-020 (GI7 solo, incorporating the "23h vừa về"
   touchpoint), STORY-021 (KY2 solo, incorporating the "đang đợi"
   touchpoint), STORY-022 (SB-206 teach-your-skill activity generation).

### Out of Scope

- Everything already listed in `req_master.md` `## Out of Scope`, including
  the PHẦN 3 forward note added there (bidirectional link/"chặng 1.5",
  portrait reconciliation, real-news feed — all `REQ-014` candidate scope).
- Tier 4 of the R-1 scale (surveillance/manipulation) — never in scope, per
  the amended `## Invariant Design Rules` rule 1.
- Any lunar-calendar-driven occasion suggestion inside STORY-013 (date
  script) before STORY-019 lands — see STORY-013's own Out of Scope; adding
  it earlier would create a forward dependency on a Tầng-4 story, which is
  not allowed.
- A dedicated "hàng rào" (Tầng 0) story — folded into the acceptance criteria
  of the stories that need it (see Scope Decision item 1); a rules-and-
  defaults-only story has no standalone observable value of its own.

### Business Rules And Guardrails

- SB-174 tier order is mandatory: foundation → hết nhạt → hữu dụng thật → vỏ.
  Reordering (e.g. shipping the zodiac skin before the notebook/skill/gift
  substance) is explicitly the failure mode the brainstorm warns against
  ("một app bói toán có kèm to-do list").
- Every Invariant Design Rule in `req_master.md` (as amended) applies to
  every story below; story briefs reference it rather than restating it.
- The content-approval rule (every lookup-table cell needs at least one
  point of friction) applies to STORY-006, STORY-010, STORY-011, STORY-012,
  STORY-015, STORY-019 — anywhere hand-authored content ships.

## Open Question Triage

### OQ-2 — One "ngăn" (compartment) or many, for the notebook/portrait/gift
data surfaces

**Status: NOT BLOCKED — deferred to UI/UX Designer at STORY-002/STORY-003
design time.** The brainstorm explicitly declined to choose (D-3; brainstorm
checkpoint: "PO/UX chốt khi làm M2"). No story in this breakdown is blocked
on it; UI/UX resolves the information-architecture question when designing
STORY-002 and STORY-003.

### OQ-3 — Content-authoring/review resourcing capacity

**Status: BLOCKED for tier-2/tier-3 story schedule/priority commitment; NOT
BLOCKING tier-1 foundation stories.** Scope: who authors and approves the
content assets this requirement needs — 144+256 compatibility lookup cells
(STORY-015), 150-250 activity/date preset cards (STORY-006), the
conversation-starter library (STORY-012), seasonal scheduled events
(STORY-012), the gift index (STORY-010), and handmade-gift recipes
(STORY-011). This is a resourcing decision only the user can make, not a
Product Owner scope decision, and it is not resolved here. STORY-001 through
STORY-005 (the foundation wave) do not depend on this content and are not
blocked. Scrum Master must raise OQ-3 to the user before committing any
tier-2 or tier-3 story to a schedule.

### Pre-existing req_master OQs (not from the brainstorm)

- **"Exact MVP taxonomy/authoring source for the hand-edited
  activity/date-suggestion presets"** — **RESOLVED** by PHẦN 2 Tầng 2: the
  same static, versioned curated-content-table pattern already used for
  `REQ-011`'s zodiac content (SB-122, "gói nội dung tải về được, có
  version"). Recorded in STORY-006.
- **"Confirm the exact current backend module path/state of `dream_jar`"** —
  **UNRESOLVED, not blocking.** This is a technical discovery question, not
  a product question; deferred to Tech Lead at STORY-006 solutioning time.
  Recorded as a note in STORY-006's story brief.

## Seed To Story Mapping

| Seed (req_master `## Story Seeds` or PHẦN 2 item) | Story | Notes |
|---|---|---|
| M2 (ownership model) | STORY-002 | Extended with SB-76 structured activity-card fields per PHẦN 2 tier 1a — PO describes user-visible transition only, per req_master's own Tech-Lead-ownership note |
| BD1 (address-term handling) | STORY-001 | Unchanged from req_master seed; PHẦN 2 does not address it |
| C1 (cross-stage activity list) + `dream_jar` | STORY-006 | Enriched with PHẦN 2 tier-2 curated presets, VNĐ price range, versioned content package |
| C6 (private journal) | STORY-005 | Unchanged from req_master seed; also satisfies PHẦN 2 Tầng 0 fence requirements |
| BD2 (Vietnamese lunar calendar/holidays) | STORY-019 | Extended with PHẦN 2 Tầng 4 C7 template library ("nối seed BD2") |
| KY2 (solo) | STORY-021 | Incorporates PHẦN 2 Tầng 4 "đang đợi" (SB-83) touchpoint |
| GI7 (solo) | STORY-020 | Incorporates PHẦN 2 Tầng 4 "23h vừa về" (SB-85) touchpoint |
| GI3 (solo) | STORY-009 | Unchanged intent; sequenced in Tầng 2 (cheap, depends only on STORY-005) |
| SB-129 (relationship notebook) | STORY-003 | New foundation object, not in original req_master seeds |
| SB-197 (skill profile) | STORY-004 | New foundation object, not in original req_master seeds |
| C2 (card lifecycle) + C4/SB-08 (photo = memory unit) | STORY-007 | C4 folded in as the memory-stage representation, not a separate story |
| C3 (frictionless capture) | STORY-008 | — |
| 3a (gift index) | STORY-010 | — |
| 3b (handmade gifts by skill) | STORY-011 | — |
| 3c (mồi chuyện A + A+) | STORY-012 | A and A+ shipped together as one content package/story |
| 3d (date script) | STORY-013 | Lunar-occasion input deferred to STORY-019 (see Out of Scope) |
| 3e (self-authored portrait) | STORY-014 | — |
| 3f (compatibility lookup) | STORY-015 | — |
| Zodiac/quiz skin | STORY-016 | — |
| No-win guessing game | STORY-017 | — |
| C5 (invite export) | STORY-018 | Designed as SB-125 payload for `REQ-014` |
| SB-206 (teach-your-skill activities) | STORY-022 | Kept at Tầng 4 timing per PHẦN 2's explicit placement, not merged into STORY-011 |

## Coverage Map

| Requirement / Need | Planned Story ID(s) | Notes |
|---|---|---|
| Amended `## Invariant Design Rules` (R-1 tier 3, R-1e..R-1i, content-approval rule, rule 5 clarified) | (all stories) | Landed in `req_master.md` directly; every story's AC must comply |
| Two-owner data-ownership transition (M2) | STORY-002 | Tech-Lead-owned architecture; PO scopes user-visible transition |
| Structured activity-card data foundation (SB-76) | STORY-002 | Extends M2 per PHẦN 2 |
| Vietnamese address-term handling (BD1) | STORY-001 | — |
| Relationship notebook (SB-129) | STORY-003 | — |
| Skill profile (SB-197) | STORY-004 | — |
| Private journal (C6) | STORY-005 | — |
| Curated activity list + `dream_jar` fold-in (C1) | STORY-006 | — |
| Activity card lifecycle + memory (C2/C4) | STORY-007 | — |
| Frictionless capture (C3) | STORY-008 | — |
| GI3 solo gesture | STORY-009 | — |
| Gift index | STORY-010 | — |
| Handmade gift ideas | STORY-011 | Highest implementation risk (skill-profile response rate) |
| Conversation starters | STORY-012 | — |
| Date script | STORY-013 | — |
| Self-authored portrait | STORY-014 | SB-208 position constraint |
| Compatibility lookup | STORY-015 | SB-208 position constraint; highest policy sensitivity |
| Zodiac/quiz skin | STORY-016 | — |
| No-win guessing game | STORY-017 | — |
| Invite export (C5) | STORY-018 | SB-125 payload for `REQ-014` |
| Lunar calendar & occasion rhythm (BD2/C7) | STORY-019 | — |
| GI7 solo ritual | STORY-020 | — |
| KY2 solo ritual | STORY-021 | — |
| Teach-your-skill activities (SB-206) | STORY-022 | — |
| Requirement gate: fully usable by a single unpaired user | (cross-story, verified at requirement close) | Covers STORY-006, STORY-005, STORY-019, STORY-020, STORY-021, STORY-009 minimum |

## Recommended Story Sequence

Mandatory build order per SB-174 — do not reorder tiers. Within a tier, order
reflects dependency, not additional priority.

| Story ID | Title | Complexity | Depends On | Tier | Observable After This Story |
|---|---|---|---|---|---|
| STORY-001 | Vietnamese pair-specific address-term handling | standard | NONE | Foundation | Every screen the user reaches renders address terms correctly for their relationship stage |
| STORY-002 | Ownership transition + structured activity-card foundation | complex | NONE | Foundation | User can operate the app solo without any `coupleId`-shaped error; new activity cards carry price/duration/timeslot/season/headcount/booking/distance fields |
| STORY-003 | Relationship notebook | standard | NONE | Foundation | User can write and read private, deletable notes about their partner |
| STORY-004 | Skill profile | standard | NONE | Foundation | User can declare and view their own skills, broadly defined |
| STORY-005 | Private journal | standard | NONE | Foundation | User can write, read, and delete private journal entries |
| STORY-006 | Curated cross-stage activity list | complex | STORY-001, STORY-002 | Tầng 2 | User browses 150-250 curated activity/date cards with real VNĐ price ranges |
| STORY-007 | Activity card lifecycle | standard | STORY-006 | Tầng 2 | A card visibly moves idea → scheduled → done → memory |
| STORY-008 | Frictionless activity capture | standard | STORY-006 | Tầng 2 | User creates a card by pasting a link or using the share sheet |
| STORY-009 | Solo "thinking of you" journal gesture | trivial | STORY-005 | Tầng 2 | One tap writes a note into the private journal |
| STORY-010 | Gift idea index | standard | STORY-003, STORY-006 | Tầng 3 | User browses gift ideas indexed by occasion/stage/notebook, with a free-gift branch |
| STORY-011 | Handmade gift ideas by skill | complex | STORY-004, STORY-003, STORY-006 | Tầng 3 | User sees step-by-step handmade gift ideas filtered by "doable in 2 hours tonight" |
| STORY-012 | Conversation starters | standard | STORY-001, STORY-006 | Tầng 3 | User browses evergreen + scheduled-event conversation-starter cards, convertible to an activity card |
| STORY-013 | Date script generator | standard | STORY-003, STORY-005, STORY-006 | Tầng 3 | User gets a full before/during/after date plan with three exits (invite/journal/card) |
| STORY-014 | Self-authored partner portrait | standard | STORY-003, STORY-013 | Tầng 3 | User fills a "how YOU see them" questionnaire, entered only from a date/gift flow |
| STORY-015 | Compatibility lookup table | complex | STORY-003, STORY-013 | Tầng 3 | User sees a range-based compatibility quartet, entered only from a date/gift flow |
| STORY-016 | Zodiac/quiz skin | standard | STORY-006 | Tầng 4 | Zodiac/quiz result ends in 3 concrete activity cards, not a verdict |
| STORY-017 | No-win guessing game | standard | NONE | Tầng 4 | User plays a no-score guessing game; output is "3 places we see differently" |
| STORY-018 | Invite export | complex | STORY-006 | Tầng 4 | User renders an activity card as a shareable image/card via a mock-formal + mad-libs template |
| STORY-019 | Vietnamese lunar calendar & occasion rhythm | standard | NONE | Tầng 4 | User sees upcoming Vietnamese occasions/holidays feeding timely suggestions |
| STORY-020 | Solo end-of-day closing ritual | trivial | STORY-005 | Tầng 4 | User completes an end-of-day ritual prompt, written to the journal |
| STORY-021 | Solo post-date reflection question | trivial | STORY-005, STORY-007 | Tầng 4 | After a card reaches "done," user answers one solo reflection question |
| STORY-022 | Teach-your-skill activity generation | trivial | STORY-004, STORY-006 | Tầng 4 | Skill profile generates a "teach someone what you're good at" activity card |

No story promises behavior only a later story adds: STORY-013's date-script
output treats lunar occasion as an optional tag until STORY-019 exists (see
STORY-013 Out of Scope), and STORY-014/STORY-015 depend on STORY-013 already
existing as their required non-home-screen entry point (SB-208), which the
tier order already guarantees.

## Story Index

| Story ID | Title | Brief File |
|---|---|---|
| STORY-001 | Vietnamese pair-specific address-term handling | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-001_vietnamese_address_term_handling/story_brief.md` |
| STORY-002 | Ownership transition + structured activity-card foundation | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-002_ownership_transition_and_activity_card_foundation/story_brief.md` |
| STORY-003 | Relationship notebook | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-003_relationship_notebook/story_brief.md` |
| STORY-004 | Skill profile | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-004_skill_profile/story_brief.md` |
| STORY-005 | Private journal | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-005_private_journal/story_brief.md` |
| STORY-006 | Curated cross-stage activity list | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-006_curated_activity_list/story_brief.md` |
| STORY-007 | Activity card lifecycle | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-007_activity_card_lifecycle/story_brief.md` |
| STORY-008 | Frictionless activity capture | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-008_frictionless_activity_capture/story_brief.md` |
| STORY-009 | Solo "thinking of you" journal gesture | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-009_solo_thinking_of_you_gesture/story_brief.md` |
| STORY-010 | Gift idea index | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-010_gift_idea_index/story_brief.md` |
| STORY-011 | Handmade gift ideas by skill | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-011_handmade_gift_ideas_by_skill/story_brief.md` |
| STORY-012 | Conversation starters | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-012_conversation_starters/story_brief.md` |
| STORY-013 | Date script generator | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-013_date_script_generator/story_brief.md` |
| STORY-014 | Self-authored partner portrait | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-014_self_authored_partner_portrait/story_brief.md` |
| STORY-015 | Compatibility lookup table | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-015_compatibility_lookup_table/story_brief.md` |
| STORY-016 | Zodiac/quiz skin | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-016_zodiac_quiz_skin/story_brief.md` |
| STORY-017 | No-win guessing game | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-017_no_win_guessing_game/story_brief.md` |
| STORY-018 | Invite export | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-018_invite_export/story_brief.md` |
| STORY-019 | Vietnamese lunar calendar & occasion rhythm | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-019_vietnamese_lunar_calendar_and_occasion_rhythm/story_brief.md` |
| STORY-020 | Solo end-of-day closing ritual | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-020_solo_end_of_day_closing_ritual/story_brief.md` |
| STORY-021 | Solo post-date reflection question | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-021_solo_post_date_reflection_question/story_brief.md` |
| STORY-022 | Teach-your-skill activity generation | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-022_teach_your_skill_activity_generation/story_brief.md` |
