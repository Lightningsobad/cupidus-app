# Story Master: STORY-011 Epic-3 — Bun Pet Đồng Hành

Status: DONE
Complexity: M
Epic: epic-3 (daily engagement)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/pets/`
Design reference: `cupid-mobile-design/` — "Bun Pet Art"/"Bun Sprite" design
files and daily engagement screen group (exact screen ids to be confirmed by
UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003.

## User Story
As a paired couple, we want a shared virtual pet ("Bun") that reflects our
daily engagement with each other, so the app rewards showing up for each
other in a playful way.

## In Scope
- Displaying the shared pet's state per the `pets` backend contract.
- Any pet interactions the backend contract exposes (feeding, care actions,
  etc. — whatever `pets` module actually supports).

## Out of Scope
- Any `pets` endpoint change (A1 frozen).
- Inventing pet mechanics not backed by the `pets` contract — if the design
  implies an interaction with no backend support, flag it rather than fake
  it client-side.

## Acceptance Criteria
1. Paired users can view the shared pet's current state.
2. Any pet interaction shown in the UI maps to an actual `pets` backend
   capability.
3. Unpaired users cannot access this feature.

## Role Completion

- [x] Architecture (Tech Lead) — `architecture/solution.md` v1.0 (D1-D4) and
  `coding-plan/master-plan.md` phases P1-P9, 2026-07-30.
- [x] Implementation (Development) — Mobile Developer, P1-P9 all DONE per
  `coding-plan/master-plan.md` §5 Phases Overview and
  `coding-plan/phase-P9-verification.md` (Status: DONE), 2026-07-31.
  `flutter analyze` 0 new issues, `flutter test` 214/214 (P6 no-fork-guard
  false positive resolved — both flagged lines already used the correct
  `context.cupidColors` token; guard substring-matched `Colors.` inside
  `cupidColors.`; fixed by extracting a local `colors` variable per the
  sibling-file pattern), AC1-AC3 PASS. No outstanding blockers. Ready for
  Reviewer.
- [x] Review (Reviewer) — `review/review-report.md`, Outcome: CLEAN,
  final-synthesis from slice-a (pet-data-di) + slice-b (P3-P9), 2026-07-31.

## Open Items For Downstream Roles
- [DONE — Tech Lead] Architecture (Tech Lead): `architecture/solution.md` v1.0
  (D1-D4) plus the shared coding plan `coding-plan/master-plan.md` (P1-P9,
  mobile-only lane). D1: the generated `Epic4LovePetApi` types every `pets` call
  `Response<void>`, so `PetRepository` reads them through the shared `Dio` (the
  STORY-003 `auth_repository` precedent) and owns all JSON parsing. D2:
  `GET /users/me.partnerId` is the AC3 pairing source of truth, because both
  `GET /pets` and `GET /pets/status` return `null` for unpaired *and* for
  no-pet-yet. D3: the 24h adopt gate stays attempt-based (handle the `400`), not
  a client-side countdown. D4: after `PATCH /pets/interact` the cubit refetches
  `GET /pets/status` rather than recomputing mood client-side. Backend untouched
  (A1). Configuration guide impact: NOT_APPLICABLE.
- [DONE — Tech Lead/UI-UX] Reconcile `cupid-mobile-design/`'s pet art assets
  against the actual `pets` module contract: resolved. `PATCH /pets/interact` is
  the only interaction endpoint, so Feed and Play are one action with a
  client-surfaced 5s cooldown; the 5 backend `mood` values map 1:1 onto 5 of the
  6 `Bun Sprite` states and the 6th (`sleep`) is not implemented; day-streak and
  badge tiles are dropped (no backing field) in favour of interactions +
  `nextMilestone`; `BunSprite` renders for all three species because only bunny
  art exists. Escalations to Product Owner (not story blockers): a real
  streak/badge system, per-species sprite art, and a `pairedAt` field for a
  countdown-based adopt gate.
