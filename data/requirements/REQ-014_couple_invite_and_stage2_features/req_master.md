# Requirement Master: REQ-014 One-to-two invite moment & Stage 2 couple features
Status: PENDING

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
**REQ-B of 2** (paired with `REQ-013`). Source artifacts (read before
breakdown, do not re-derive):
- `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/candidate-review.md`
  — Phần B (design rules), Phần C (candidates), Phần H (AI research), Phần I
  (Impact/Effort), Phần J (build order, Đợt 2/3/4).
- `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/idea.md` —
  locked business decisions (Phần A / Current Business Framing).
- `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/handoff-to-scrum-master.md`
  — the paste-ready handoff this requirement was seeded from verbatim.

## Requirement Gate — Do Not Start Before This Passes

This requirement is in the **same phase** as `REQ-013`, sequenced after it,
and has a **hard dependency** on `REQ-013`'s M2 shared-foundation story.
Additionally, per the user's explicit handoff, `REQ-013`'s own closing gate
("is Stage 1 fully usable solo?") must have passed before this requirement's
Product Owner breakdown begins. Scrum Master must verify both before routing
this requirement's first story.

## Business Framing

Where `REQ-013` builds a solo-usable Stage 1 assistant, this requirement
builds the mechanism that turns one user into two ("gia nhập"), plus the
Stage 2 (existing couple app) feature set that is cheap because it reuses
primitives already running in the codebase (mutual consent / "two-key" flows
across 6 modules, blind-reveal, `notifications`, `alarms`, `messages`,
`timeline`).

## Invariant Design Rules (load into every story; do not reopen)

Identical to `REQ-013`'s Invariant Design Rules, plus the rules that only
take effect once a second account exists:

1. **R-1 — the assistant works on ACTIVITIES, never on THE OTHER PERSON.**
   No comparing partners, no reporting one partner's behavior to the other,
   no scoring/ranking, no streaks. Experimentally backed (Phần H, H-R1).
2. **G-1 — "learns from chat" applies ONLY to the shared in-app chat, ONLY
   from this requirement onward, and is gated by a mutual two-key toggle.**
   Never reads Zalo/Messenger/any other app. Legal backing:
   Vietnam's Personal Data Protection Law (effective 2026-01-01) and Decree
   356/2025 classify sex life/orientation data as sensitive; reading messages
   without consent is prohibited (Phần H, H-R2).
3. **G-2 (ii-b) — the private space is public and symmetric for both
   accounts; what is invisible is the CONTENT and whether-anything-exists AT
   ALL.** There must be no path — not even a password — for one account to
   view the other's private space. `data-export` must exclude the private
   space entirely. Never display a count of unshared items.
4. **AI-1 — if a model is ever allowed to read chat, its output must be
   constrained to EXTRACTED ACTIVITIES only, never a description of a
   person.** Enforce with structured output / JSON schema at the API layer —
   an enforceable architecture constraint, not a policy promise.
5. AI only enters at the "Nhóm dày" (heavy) group of this requirement, and
   only on activity data. Anything that touches chat must run on-device, or
   the feature is dropped — "send it to the server" is not an acceptable
   fallback.
6. Never market this as an AI app.

## Story Seeds

### Hinge story — build first in this requirement

- **C0 — solo mode -> invitation -> mode switch -> "graduation."** The
  invitation is framed as *"đây là N chỗ anh đã ghi lại để đưa em đi"* ("here
  are the N things I've already noted down to take you to"), pulled directly
  from the C1 activity list and C6 journal that `REQ-013` accumulated. This
  is the **only** place in the whole idea that solves the adoption-barrier
  problem (X1). It only works if `REQ-013`'s Đợt-1 stories actually shipped
  and accumulated real content — do not schedule this story before `REQ-013`
  is `DONE`.

### Cheap group — schedule immediately after the hinge story

- **XD6** — an "I'm upset, can't talk about it yet, but don't worry" button.
  Best value-to-cost ratio in the entire candidate set (Impact 5 / Effort 1).
- **RS1** — mutual two-key agreement on contact-frequency expectations
  (replaces the rejected GI10 "message-cadence asymmetry display" pattern).
- **SC7 + DS2** — surprise gifts via `wishlistThemeId` (field already exists
  on the entity, not yet wired into a flow).
- **DS1** — backend for `vow` (mobile UI already exists; only the server half
  is missing).
- **XD7** — a cooldown timer for conflicts, closed out with mutual two-key
  confirmation.
- **SC3** — cancelling a plan also requires mutual two-key confirmation
  (prevents impulsive unilateral cancellation).
- The Stage-2 versions of GI3 (a real ping to the other person, not just a
  private-journal write) and KY2 (both partners flip/reveal their answer).

### Heavy group — schedule after the cheap group

- **KY1** — `timeline` auto-written from C1 + TR2 activity/photo data; user
  only confirms.
- **SC2** — both partners choose blind, auto-resolves on match (merges
  PRIM-1 two-key + PRIM-2 blind-reveal primitives).
- **C3** — the first trip together (documented as the most differentiated,
  least-copied candidate in the set).
- **RS4** — cross-device sync treated as a first-class feature (16% of the
  category's complaints are sync bugs against this exact primitive).
- **TR1** — the app auto-silences notifications when both devices are
  physically near each other.
- **TR4** — a "put the phone down" mode. This is also the bridge item to the
  parked `IDEA-20260828-001_hearts-currency-economy` idea (see `## Out of
  Scope`).
- **GI5** — a shared co-working/parallel-presence session.

### Existing primitives this requirement reuses (do not rebuild)

Mutual consent ("two-key") already runs across 6 backend modules but has
never been named as a primitive; blind-reveal; `notifications`; `alarms`;
`messages`; `timeline`. Tech Lead should confirm/name these as the shared
contract this requirement's stories build on, not re-implement.

Exact story splitting, sequencing, and complexity classification (trivial /
standard / complex) remain Product Owner's decision at breakdown time; the
grouping above (hinge -> cheap -> heavy) is brainstorm-approved build order
(`candidate-review.md` Phần J Đợt 2/3/4), not a prescribed story list.

## Out of Scope

- Stage 3 (chặng 3 / C12) — explicitly deferred per locked decision A-11.
- Any AI use outside the "heavy group, activity-only" carve-out in rule 5
  above. In particular: no chat-content AI unless it runs fully on-device;
  no "send transcripts to a server" fallback under any circumstance.
- Any feature that analyzes, scores, profiles, or predicts the other
  person's behavior or intent — excluded by R-1 regardless of stage (see
  `candidate-review.md` Phần E, N1-N7).
- Commerce/partnerships, printed yearbook (KY4), double-date /
  "couple-friends" features (BE7 — waiting for user density), notes about the
  other person's friends (BE5 — undecided).
- `IDEA-20260828-001_hearts-currency-economy` — a separate, still-parked
  idea. TR4 in this requirement bridges toward it conceptually, but the idea
  itself has not been handed off and must not be pulled into this phase.

## Gate Criteria (Acceptance Criteria must encode)

- The hinge story (C0) cannot be marked `DONE` unless it demonstrably pulls
  real accumulated content from `REQ-013`'s C1/C6 data (not placeholder/mock
  data) into the invitation moment.
- Every mutual-consent ("two-key") feature in this requirement (RS1, XD7,
  SC3, SC2, and the shared primitive itself) must be verified against G-2's
  symmetry rule: neither account can ever see whether the other has
  unresolved/pending private state beyond what the two-key flow explicitly
  reveals.
- Any story touching chat-derived learning (G-1) must have its two-key
  opt-in gate and its "extraction only, never a person-description" output
  contract (AI-1) verified before `DONE`, not assumed from design intent.

## Open Questions For Product Owner

- OQ: For SC7 + DS2 (surprise gifts via `wishlistThemeId`), confirm the
  exact current shape of that entity field and whether any existing
  mobile/backend code already partially consumes it.
- OQ: For KY1 (`timeline` auto-write), confirm what "user only confirms"
  means as an interaction pattern — auto-populate + swipe-to-confirm, a
  review queue, or something else — this is UX scope, not decided in
  brainstorm.

## Dependencies

- **Hard dependency:** `REQ-013` M2 shared-foundation story must be
  `MERGE_COMPLETE` before any story in this requirement starts. Record as
  `Depends-On: REQ-013/<M2 story id>` at story-boundary time.
- **Hard gate:** `REQ-013`'s own closing AC ("Stage 1 fully usable solo")
  must have passed before this requirement's Product Owner breakdown begins.
- Reuses existing runtime primitives named in `## Story Seeds` above
  (mutual-consent modules, blind-reveal, `notifications`, `alarms`,
  `messages`, `timeline`) — Tech Lead confirms exact module paths at
  architecture time.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
