# Requirement Master: REQ-013 Solo dating assistant — Stage 1 activities & private journal
Status: IN_PROGRESS

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## Source

Brainstorm `IDEA-20260828-002_couple-feature-expansion`, explicit user
handoff (2026-08-29): "thêm yêu cầu: Mở rộng Cupid theo hướng 'trợ lý cho
người đang yêu' ... Tách thành đúng 2 requirement, không hơn." This is
**REQ-A of 2** (paired with `REQ-014`). Source artifacts (read before
breakdown, do not re-derive):
- `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/candidate-review.md`
  — Phần B (design rules), Phần C (candidates), Phần H (AI research), Phần I
  (Impact/Effort), Phần J (build order).
- `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/idea.md` —
  locked business decisions (Phần A / Current Business Framing).
- `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/handoff-to-scrum-master.md`
  — the paste-ready handoff this requirement was seeded from verbatim.

## Business Framing

Stage 1 ("chặng 1") of a three-stage relationship-lifecycle product: Stage 1
= person still courting, alone · Stage 2 = existing Cupid couple app · Stage
3 = cohabiting couple (deferred, out of scope). One object — "a thing the two
of them will do together" — runs through all three stages, changing owner
count as the relationship progresses: my list -> shared list -> shared
operating plan.

This requirement's product goal: a solo relationship assistant that is
**fully usable even if the other person never joins the app** — practical
help planning and preparing dates/activities (not tactical analysis of the
other person), plus a private journal. **No AI in this requirement**; every
suggestion is a hand-edited, static preset.

## Invariant Design Rules (load into every story; do not reopen)

Locked product/ethics rules from `candidate-review.md` Phần B, the user's
explicit handoff, and `IDEA-20260829-001` D-9..D-14 (the "nấc 3" / tier-3
opening of R-1, approved by the user 2026-08-29, superseding the prior
absolute-ban wording of R-1 below). Product Owner, UI/UX, Tech Lead, and every
implementation lane treat these as binding constraints, not features to
renegotiate:

1. **R-1 — the assistant works on ACTIVITIES.** The assistant is **allowed**
   to describe personality patterns and a match/compatibility level **only
   when** every data input is self-entered or self-declared by the user, and
   every output states its provenance — "based on what YOU entered" — directly
   in the screen layout, not as a small-print footnote (tier 3 of 5 per
   `IDEA-20260829-001` D-12).
   Still **absolutely forbidden**: (b) reading the other person's messages or
   monitoring their social media; (c) comparing the two partners, or
   reporting one partner's behavior to the other; (e) manipulation scripts or
   A/B-testing of messages; (f) streaks and leaderboards. Has experimental
   backing (Phần H, H-R1: sycophancy risk study) — this is a hard
   architecture rule, not a style preference. Tier 4 of the R-1 scale (full
   surveillance/manipulation) is never in scope, under any framing.
   - **R-1e — three-tier rule.** RECORD (the user observes and writes it
     down) — allowed. GUESS (the user guesses; the app never confirms) —
     allowed. INFER/SCORE (the app asserts a conclusion about the other
     person) — allowed only under the tier-3 condition above (self-entered
     data plus stated provenance); never otherwise.
   - **R-1f — the relationship notebook can never be exported** as a
     shareable link, image, or any other artifact that leaves the device;
     data about a third party never leaves the device.
   - **R-1g — any content about the other person must end in a question to
     ask the real person**, never in a conclusion. Mandatory test for every
     such screen: "after reading this, does the user want to ask the other
     person more, or less?" An honest answer of "less" means the design is
     wrong and must be redone before content ships.
   - **R-1h — hard ban on asserting a specific person's intent or feelings**
     (e.g. "she likes you"). Describing a general pattern from a lookup table
     is allowed; inventing a specific person's inner state is not.
   - **R-1i — the relationship notebook records preferences and events
     only** (allowed — e.g. an allergy, a stated like, an important date); it
     never records frequency or behavior (forbidden — e.g. "often replies
     slowly"). This is the boundary between R-1i and R-1b below.
   - **R-1b/c/d — unchanged.** (b) no measuring the other person's behavior on
     any invite/link (no "seen" receipts, no open time, no open count — only
     answered/not-answered); (c) every invite always has a clean, one-tap
     decline door, never dramatized or evaded; (d) preset content only jokes
     about the sender, never about the recipient.
   - **Content-approval rule** — every lookup-table cell (the R-1(a)/(d)
     match/compatibility content) must contain at least one point of
     friction, never praise only. This is a content-approval criterion
     applied at authoring/review time, not a style preference.
2. Whatever can be saved must be deletable (XD4).
3. Framing is "taking care of each other," logistics — never promise an
   emotional outcome and deliver a calendar (RS3).
4. No paywall on the core feature set (RS7).
5. **No AI anywhere in this requirement at runtime.** The shipped product
   never calls a model; Stage 1 suggestions and lookup content are fixed,
   hand-edited presets shipped as versioned data packages. AI **may** be used
   **outside the product**, during content authoring only, with every line
   still going through human review before it ships (`IDEA-20260829-001`
   D-4) — this is a content-authoring tool, never a runtime dependency of
   Stage 1. AI-in-product remains `REQ-014`-and-later scope, gated by rule
   G-1.
6. The C6 private journal built here must already be private-by-default and
   deletable so the `REQ-014` G-2 (ii-b) symmetric-private-space treatment
   does not require a data-model rework later.

## Story Seeds

**Superseded by the formal breakdown.** The seeds below were the pre-breakdown
input; the actual story set, sequencing, and seed-to-story mapping are now
recorded in `requirements/requirements.md` (`## Seed To Story Mapping`,
`## Recommended Story Sequence`) and in `## User Stories` below. Kept here for
provenance only — do not re-derive story boundaries from this section.

### Shared-foundation story — must complete before every other story in this
requirement AND before any `REQ-014` story

- **M2 — single-owner -> two-owner data ownership model.** Today everything
  in the codebase is keyed/locked to `coupleId`. This is the single largest
  and riskiest item in the whole idea (Impact 5 / Effort 5,
  `candidate-review.md` Phần I "Nhóm 0") and it blocks all of REQ-013 +
  REQ-014. This is **Tech Lead-owned architecture work**, not Product Owner
  scope — Product Owner should describe the user-visible ownership-transition
  behavior (solo mode -> invite -> paired mode -> "graduation") without
  prescribing the data model itself.
- **BD1 — Vietnamese pair-specific address-term handling** (anh/em and
  similar forms of address). Touches every user-facing string, so it must be
  decided before other stories generate copy. Impact 4 / Effort 3.
- The `## Invariant Design Rules` section above is the "12 luật thiết kế"
  this story must formalize as enforced constraints (already recorded in
  this `req_master.md`); downstream story briefs reference this section
  rather than restating the rules.

### Remaining Stage-1 stories (after the shared-foundation story lands)

- **C1 — cross-stage activity list.** The backbone object; also absorbs the
  already partially-built `dream_jar` backend module as the future-tense
  "shared dreams" activity type (see Open Questions below for exact path
  confirmation).
- **C6 — private journal**, private-by-default, deletable (XD4), built to
  already satisfy the `REQ-014` G-2 (ii-b) symmetry rule even though Stage 1
  is single-owner.
- **BD2 — Vietnamese lunar calendar + Vietnamese holidays/observances** (Tết,
  Trung thu, 8/3, 20/10, the "14th of the month" date sequence).
- **KY2 (solo version)** — one question asked after a date/outing, answered
  by the single user. (The paired "both flip an answer" version is `REQ-014`
  scope.)
- **GI7 (solo version)** — an end-of-day closing ritual, solo variant.
- **GI3 (solo version)** — a one-tap "thinking of you" gesture that, in this
  solo requirement, writes into the private journal (C6) and is never sent
  anywhere (no paired recipient exists in Stage 1).

Exact story splitting, sequencing, and complexity classification (trivial /
standard / complex) remain Product Owner's decision at breakdown time; the
grouping above is brainstorm-approved scope, not a prescribed story list.

## Out of Scope

- **Any AI feature.** All suggestion content is a hand-edited/static preset
  set; no model calls, no "learns from chat" behavior (that begins at
  `REQ-014`+, gated by rule G-1).
- Any feature that analyzes, scores, profiles, or predicts the other
  person's behavior or intent — excluded by R-1 (see `candidate-review.md`
  Phần E, N1-N7, for the specific already-rejected patterns).
- `REQ-014` / Stage 2 scope: the invite/graduation moment (C0), mutual-consent
  ("two-key") features, paired versions of KY2/GI3/GI7, and everything in
  `candidate-review.md` Phần J Đợt 3/Đợt 4.
- Stage 3 (chặng 3 / C12) — explicitly deferred per locked decision A-11.
- **PHẦN 3 of `IDEA-20260829-001`'s v7 handoff** (bidirectional link /
  "chặng 1.5", the "cậu đoán đúng mấy phần" portrait-reconciliation reward
  moment, and re-evaluating the real-news feed) — candidate scope for
  `REQ-014_couple_invite_and_stage2_features`, not this requirement. See
  `REQ-014` for eventual pickup; no `REQ-013` story is created from it.
- Commerce/partnerships, printed yearbook (KY4), double-date /
  "couple-friends" features (BE7 — waiting for user density), notes about the
  other person's friends (BE5 — undecided) — none pulled into this phase.
- `IDEA-20260828-001_hearts-currency-economy` — a separate, still-parked
  idea, not yet handed off. Do not pull it into this requirement, even though
  a later `REQ-014` item (TR4) will eventually bridge to it.

## Gate Criteria To Close This Requirement (mandatory Acceptance Criteria)

Per the user's explicit handoff, this is a **hard gate**, not an aspirational
goal — Product Owner must encode it as an explicit, testable AC, and Scrum
Master must verify it passes before routing `REQ-014`'s first story
(including its Product Owner breakdown):

> Is Stage 1 fully usable even if the other person never joins? Cover the
> activity list, the private journal, the Vietnamese calendar/holiday
> content, and all three solo rituals (KY2, GI7, GI3 solo versions) in an
> end-to-end scenario exercised entirely by a single, unpaired user. If this
> does not pass, STOP — do not open `REQ-014`.

## Open Questions For Product Owner

- OQ: Exact MVP taxonomy/authoring source for the hand-edited
  activity/date-suggestion presets referenced under C1 — a curated static
  content table (same pattern as `REQ-011`'s zodiac content) or something
  else?
- OQ: Confirm the exact current backend module path/state of `dream_jar`
  to fold into C1 (`candidate-review.md` DS4 marks it "already partially
  built, not yet wired").

## Dependencies

- `REQ-014` has a hard dependency on this requirement's M2 shared-foundation
  story (record as `Depends-On` at story-boundary time for every `REQ-014`
  story).
- No dependency on any other existing requirement; `REQ-001`..`REQ-012` are
  all `DONE`.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | Vietnamese pair-specific address-term handling | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-001_vietnamese_address_term_handling/story_master.md` |
| STORY-002 | Solo-to-paired ownership transition + structured activity-card foundation | complex | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-002_ownership_transition_and_activity_card_foundation/story_master.md` |
| STORY-003 | Relationship notebook | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-003_relationship_notebook/story_master.md` |
| STORY-004 | Skill profile ("phiên bản tôi") | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-004_skill_profile/story_master.md` |
| STORY-005 | Private journal | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-005_private_journal/story_master.md` |
| STORY-006 | Curated cross-stage activity list | complex | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-006_curated_activity_list/story_master.md` |
| STORY-007 | Activity card lifecycle | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-007_activity_card_lifecycle/story_master.md` |
| STORY-008 | Frictionless activity capture | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-008_frictionless_activity_capture/story_master.md` |
| STORY-009 | Solo "thinking of you" journal gesture | trivial | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-009_solo_thinking_of_you_gesture/story_master.md` |
| STORY-010 | Gift idea index | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-010_gift_idea_index/story_master.md` |
| STORY-011 | Handmade gift ideas by skill | complex | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-011_handmade_gift_ideas_by_skill/story_master.md` |
| STORY-012 | Conversation starters (mồi chuyện) | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-012_conversation_starters/story_master.md` |
| STORY-013 | Date script generator | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-013_date_script_generator/story_master.md` |
| STORY-014 | Self-authored partner portrait | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-014_self_authored_partner_portrait/story_master.md` |
| STORY-015 | Compatibility lookup table | complex | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-015_compatibility_lookup_table/story_master.md` |
| STORY-016 | Zodiac / personality-quiz skin | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-016_zodiac_quiz_skin/story_master.md` |
| STORY-017 | No-win "how well do you know me" guessing game | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-017_no_win_guessing_game/story_master.md` |
| STORY-018 | Invite export | complex | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-018_invite_export/story_master.md` |
| STORY-019 | Vietnamese lunar calendar & occasion rhythm | standard | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-019_vietnamese_lunar_calendar_and_occasion_rhythm/story_master.md` |
| STORY-020 | Solo end-of-day closing ritual | trivial | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-020_solo_end_of_day_closing_ritual/story_master.md` |
| STORY-021 | Solo post-date reflection question | trivial | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-021_solo_post_date_reflection_question/story_master.md` |
| STORY-022 | Teach-your-skill activity generation | trivial | PENDING | `data/requirements/REQ-013_solo_dating_assistant_stage1/STORY-022_teach_your_skill_activity_generation/story_master.md` |

## Design Source

- **Design-Source: UPDATED 2026-09-01T12:52:11Z (applied) — STORY-004/STORY-005/ui-ux-designer independently
  found a third, previously-unregistered design canvas
  (`cupid-app-design-system/Cupid Một Mình Screens.dc.html`, screens `skills`
  and `diary`, prop-driven via `screen` prop) that the locked `design_sources[]`
  set does not cover. Re-run the detector to add it as a new surface
  (`id: cupid-solo`) alongside the existing `cupid-app`/`cupid-web` entries;
  do not touch those two.**
- **Design-Source: UPDATED 2026-09-01T12:58:00Z (applied) — the auto-applied re-detection above picked the
  wrong file for the new surface. `cupid-app-design-system` has two
  near-duplicate-named canvases (`Cupid Một Mình.dc.html` vs `Cupid Một Mình
  Screens.dc.html`); the generic name-slug heuristic collapsed both to id
  `cupid-m-t-m-nh` and kept the DOM-driven `Cupid Một Mình.dc.html`
  (`data-screen-btn`, no `data-props`) — verified by direct grep to be
  UNRELATED to `skills`/`diary`. The file STORY-004/STORY-005 actually need is
  the sibling `Cupid Một Mình Screens.dc.html` — verified by direct grep to
  contain `data-props` (prop-driven) and the `isDiary` flag matching the
  confirmed `diary` screen. Correct that one entry's `entry`/`screens_from`/
  `screen_prop`/`id` fields (identity tuple `(location, type)` unchanged; only
  disambiguating which sibling file this id/entry points at) to
  `entry: "Cupid Một Mình Screens.dc.html"`, `screens_from: "prop:screen"`,
  `screen_prop: "screen"`, `id: "cupid-solo"`. Do not touch `cupid-app`,
  `cupid-web`, or the `cupid-d-u-m-c` entry.**
