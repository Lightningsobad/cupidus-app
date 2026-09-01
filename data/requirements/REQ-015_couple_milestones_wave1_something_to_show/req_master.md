# Requirement Master: REQ-015 Couple Milestones ("Dấu mốc") — Wave 1 "Có cái để khoe"
Status: PENDING

## Source
- Idea: `data/brainstorms/IDEA-20260831-001_couple-milestone-achievements/idea.md`
  (23 design laws + business framing)
- Convergence: `data/brainstorms/IDEA-20260831-001_couple-milestone-achievements/development.md`
  `## Convergence Notes` (Impact/Effort grid over 12 slices, 4-wave delivery
  order, PMI pressure-test on Wave 1 = `S1+S3+S2+S4`)
- Approved card deck: `data/brainstorms/IDEA-20260831-001_couple-milestone-achievements/milestone-deck.md`
  (147 cards, 12 groups A–L, approved round 1)
- Explicitly OUT of scope for this requirement: `signal-patterns.md` in the same
  idea folder — that file belongs to Wave 4 (auto-detect), not Wave 1. Do not
  load it when planning or implementing this requirement.

## Business Framing (from idea.md)
- The app already stores relationship *data* (timeline, gallery, expenses,
  pets, love-contracts, dream-jar, vibes, zodiac, themes, emojis, data-export)
  but never turns it into a **prideful physical artifact** a couple can show
  off. No reason to return regularly, no organic sharing channel.
- Value hypothesis: milestones turn relationship history into a **showable
  artifact** that competitors cannot fake, because it needs real time + real
  people as witnesses.
- Voice: the app speaks as "tụi mình" ("us"), warm like a close friend — warm
  in *attentiveness*, never warm in *inference*. Never assert something the
  app does not actually know.
- This is a **storytelling tool, not a measurement tool.** Numbers exist to
  raise pride and nudge the relationship forward, never to rank or compare.

## Wave 1 Scope — "Có cái để khoe" (8 blocks; Product Owner splits into stories)

1. **Free backdating of `couple.startDate`.** No lock. Every change must notify
   the other partner. Abuse is deterred by mandatory notification, not by a
   technical lock.
2. **Group A time milestones (16 cards) auto-generate from `startDate`.** Zero
   user input required. Full card list: A01–A16 in `milestone-deck.md` §A
   (day 7, 1 month, 100 days, 6 months, 200 days, 1 year, 500 days, 1000 days,
   year N, 2000 days, monthly anniversary [default OFF], "through all four
   seasons", first birthday together, birthday N together, palindrome dates).
3. **Lock-screen widget that counts days together.** A passive show-off
   channel. Getting the counting logic right and shipping the widget matters
   more than its visual polish for this wave.
4. **Retroactive onboarding sweep.** Scroll through all 147 cards, ordered by
   probability-of-having-already-happened (inferred from the relationship
   length just entered during onboarding). User can stop/resume at any point;
   completion is never required. Group G ("sẹo"/scars) sits last, behind an
   explicit partition screen: "Phần tiếp theo nói về những lúc khó. Xem sau
   cũng được." ("The next part is about the hard times. You can come back to
   it later.")
5. **147-card self-declare deck.** User taps "this already happened" + picks a
   date. Zero typing is a hard design requirement, not a nice-to-have —
   self-declare dies the moment it demands typed text.
6. **Artifact generator.** Story-ratio card overlaying the couple's own photo
   from their gallery, using **12 shared group stamps** (NOT 147 individual
   card stamps — that full 147-stamp system is Wave 3 scope) × **6
   data-type layouts** (big number / map / full-bleed photo / cumulative list
   / certificate / passport stamp), plus sharing through the OS share sheet.
7. **Passport screen.** Displays stamps along a timeline.
8. **Group G ("sẹo") mutual-consent gate.** A Group G milestone requires
   two-way consent before it enters the shared/couple passport. Reuse the
   existing mutual-consent pattern already implemented for
   themes/reminders — do not design a new consent mechanism.

## Hard Constraints — must survive into acceptance criteria for every story

- **No farming.** No streaks, no activity-frequency counters, nothing that can
  be grinded.
- **No comparison.** Never compare the two partners against each other. Never
  compare one couple against another couple.
- **No penalty for silence.** A cooling relationship, an argument, or a
  long-distance stretch must never cause anything to be lost or reset.
- **Two-number-types law.** *Events* (dates, did/did-not-happen) must never be
  wrong. *Judgments* (romantic, bonded) are allowed to stay fuzzy. Permanently
  forbidden: a fabricated-precision judgment number, e.g. "92% compatible".
- **Closed deck.** The system must never auto-generate a new milestone type
  outside the approved 147 cards.
- **"Sẹo" (Group G) defaults private.** If a scar milestone is ever surfaced
  outside the couple, it may only appear already-overcome and summarized
  (e.g., "đã cùng đi qua 8 tháng yêu xa" / "we made it through 8 months of
  long distance together"), never as a single dated event.
- **Voice.** The app speaks as "tụi mình" ("us"), warm like a close friend —
  warm in attentiveness only, never warm in inference. Never assert something
  the app has not actually confirmed.
- **Forbidden milestone sources.** Never derive a milestone from: pet
  level/happiness, vibe streaks, the money amount in `expenses` (event-only —
  e.g. "first shared fund" is fine, the dollar figure is not), or messaging
  frequency.

## Out of Scope for Wave 1 (do not pull in)

- Public couple page, external witnesses (Group K), reading/inferring from
  chat, Cupid Wrapped, the full 147-individual-stamp artifact system + the
  ~15-card ritual tier, hearts faucet, physical print fulfillment, solo Stage-1
  milestones (Group J).
- Wave 1 uses only **12 group stamps**, not the full 147-stamp system (that is
  Wave 3 / `S6`).

## Intersection Notes — do not design Wave 1 in a way that blocks these

- **Wave 3** will connect hearts (milestones minting hearts — a faucet for
  `IDEA-20260828-001`).
- **Wave 2** depends on a still-open decision about public internet exposure.
- Keep the milestone data model, artifact generator, and passport screen
  extensible for a later 147-stamp upgrade and a later hearts-minting hook,
  without building either now.

## Deployment Status
- Development Environment: NOT_DEPLOYED
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
