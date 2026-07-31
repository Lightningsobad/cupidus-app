# Story Master: STORY-014 Epic-4 — Dream Jar / Hũ Ước Mơ Chung

Status: DONE
Complexity: S
Epic: epic-4 (intimacy/memories)
Story-Class: standard
Requirement: REQ-001
Backend module: `backend/src/modules/dream-jar/`
Design reference: `cupid-mobile-design/` — dream jar screen group (exact
screen ids to be confirmed by UI/UX Designer).

## Depends On
- STORY-001, STORY-002, STORY-003.

## User Story
As a paired couple, we want a shared "dream jar" where we can each drop in
wishes/dreams for our relationship, so we build a collection of shared
aspirations over time.

## In Scope
- Adding a dream/wish entry to the shared jar.
- Viewing the shared jar's contents.

## Out of Scope
- Any `dream-jar` endpoint change (A1 frozen).

## Acceptance Criteria
1. A paired user can add a dream/wish entry to the shared jar.
2. Both partners can view the jar's contents.
3. Unpaired users cannot access this feature.

## Non-Functional / Risk Notes
- R3 (libsodium FFI) — if dream jar entries require local encryption, flag
  for Tech Lead spike before implementation (per req_master's risk table).

## Role Completion

- [x] Architecture (Tech Lead) — `architecture/solution.md` v1.0 (ADR-014a..g)
  and `coding-plan/master-plan.md` phases P1-P6, 2026-07-30.
- [x] P1 Data Contract (Mobile Developer) — `DreamJar`/`Contribution`
  models, `DreamJarRepository`, `DreamJarUnpairedFailure`,
  `DreamJarAmountFormat` landed in `mobile/lib/features/dream_jar/data/`;
  `coding-plan/phase-P1-data-contract.md` §7 has full evidence, 2026-07-30.
- [x] P2-P5 Implementation (Mobile Developer) — jar detail/list/create,
  contribution history + partner split, Home entry point; all `DONE` in
  `coding-plan/master-plan.md` §5, 2026-07-31.
- [x] P6 Verification (Mobile Developer) — full `flutter analyze` +
  `flutter test` + `flutter build apk --debug`, `coding-plan/test-results.md`,
  2026-07-31.
- [x] Review (Reviewer) — `review/review-report.md`, `Outcome: DEFERRED_ONLY`
  (re-review closing the prior `PATCH_REQUIRED` High finding), 3 non-blocking
  Low findings deferred, 2026-07-31.

## Open Items For Downstream Roles
- [DONE — Tech Lead] Architecture (Tech Lead): `architecture/solution.md` v1.0
  (ADR-014a..g) plus the coding-plan bundle (`coding-plan/master-plan.md`,
  P1-P6). R3 confirmed and closed for this story as ADR-014a: **no client-side
  encryption, no libsodium/FFI, no new dependency, no spike needed**. Rationale:
  A1 freezes the backend, and `targetAmount`/`currentAmount`/`amount` are
  `decimal` columns the server itself reads in `computeProgress()`, so field-level
  E2EE is impossible without a backend change; encrypting only `name`/`note`
  would still not be Level 2 and would need a couple key-agreement protocol that
  does not exist. Dream Jar is therefore Level 3 (TLS 1.3 in transit, server-side
  at rest) in v1, and no Dream Jar surface may claim end-to-end encryption.
  Also resolved: UX §0.3 freshness → pull-to-refresh + refresh-on-focus
  (ADR-014b; the `dream-jar` backend module has no gateway and emits no realtime
  event, so there is nothing to subscribe to under A1). AC3 → the backend 404
  `User not found or not paired` is mapped to `DreamJarUnpairedFailure`, making
  AC3 verifiable without depending on STORY-005.
- Product Owner (flagged by UX §0.1, confirmed by Tech Lead): the User Story and
  AC wording describe a text wish list, but the frozen contract and design source
  are a shared monetary savings jar. `coding-plan/master-plan.md` §2 records the
  AC1-AC3 mapping onto the real feature; please correct the wording and reconcile
  the epic-4 vs epic-5 tag.
- Product Owner (deferred out of v1 by Tech Lead, decision needed before a
  follow-up story): the 4th custom-amount quick-add tile and `note` field
  (UX §1.4), edit/archive/delete jar (UX §1.7, including whether delete notifies
  the partner), multi-currency, and a "show archived" toggle.
- Follow-up outside this story's write scope: correct the Privacy / "My data"
  screen tier and copy for Dream Jar (Level 2 → Level 3), reclassify it in
  `ui_ux_system_memory.md` §8, and note in `system_architecture_memory.md` that
  Dream Jar no longer depends on R3.
