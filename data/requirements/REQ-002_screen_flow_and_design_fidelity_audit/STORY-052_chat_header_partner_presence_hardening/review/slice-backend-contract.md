# Review Slice — Backend Contract (`GET /users/me` `partnerDisplayName`)

Review type: `scoped-slice` (slice 1 of 2)
Story: `REQ-002_screen_flow_and_design_fidelity_audit/STORY-052_chat_header_partner_presence_hardening`
Slice verdict: PASS — AC1 satisfied, 0 blocking findings, 2 deferred notes
Story-level verdict is NOT decided here; the final-synthesis reviewer owns it.

## Slice Scope

- ACs verified: AC1 only.
- Diff baseline: `25b92d884c555124e87ff7f1cd7d1cf3eb641c6b..212e50c4bdeb63808f647480bd70684c446db150`
- Source/test files in scope (3):
  - `backend/src/modules/users/users.controller.ts` (+2/-2)
  - `backend/src/modules/users/users.service.ts` (+12/-0)
  - `backend/src/modules/users/users.service.spec.ts` (+64/-0)
- Evidence in scope: `coding-plan/test-results.md` §P0; `coding-plan/phase-P0-users-me-partner-display-name.md`; `architecture/contract-summary.md` §2-§3.
- Supporting reads for the "shape otherwise unchanged" claim: `entities/user.entity.ts`, `src/main.ts` (serialization check).
- Out of slice: AC2-AC7, all mobile files, story-level runtime startup smoke, visual fidelity.
- Retro gate (rule 1a): `data/retro-audit/rework-backlog.md` has PENDING/IN_PROGRESS items, but STORY-052 IS the remediation for `RWB-20260816-017` (IN_PROGRESS) — this handoff is retro/rework work, so the gate does not refuse it.

## Verification Table

| # | Check | Verdict | Evidence |
|---|-------|---------|----------|
| 1 | Paired caller's `GET /users/me` includes `partnerDisplayName` from the partner's real `User.displayName` | PASS | `users.service.ts:30-40` resolves the partner row by `user.partnerId` and returns `partner?.displayName`; `users.controller.ts:18` repoints `GET me` to `getProfileWithPartner`. Spec case "resolves partnerDisplayName for a paired caller…" asserts `'Linh'` |
| 2 | Existing self-identity field shape otherwise unchanged | PASS | Return is `{ ...user, partnerDisplayName }` — append-only, no key renamed/removed/reordered. `displayName` still the caller's own name (spec asserts `result.displayName === caller.displayName` alongside `id`, `partnerId`, `isGhostModeEnabled`) |
| 3 | No serialization regression from returning a plain object instead of a `User` instance | PASS | `user.entity.ts` has no `@Exclude`/`@Expose`; `main.ts` registers only `ValidationPipe` (no `ClassSerializerInterceptor`). The response was already the raw entity shape, so spreading changes nothing but the added key |
| 4 | Unpaired / dangling `partnerId` / null partner name do not throw | PASS | `getProfileWithPartner` uses the non-throwing `userRepository.findOne` (NOT `findOne(id)`, which raises `NotFoundException`) and guards on `if (user.partnerId)`; `partner?.displayName ?? null`. 3 spec cases cover all three, each asserting `toBeNull()` |
| 5 | Partner row not leaked beyond the one field | PASS | Only `partner?.displayName` is read; the partner object is never spread or returned. Response carries no partner `email`/`firebaseUid`/`photoUrl` — matches `contract-summary.md` §3 |
| 6 | Key spelling / null contract match the cross-lane contract | PASS | `contract-summary.md` §2 requires exact lowerCamelCase `partnerDisplayName`; implementation matches. §3's three null cases all return `null`, never an error, and no trim/normalize is applied |
| 7 | 3 pre-existing spec cases untouched | PASS | Spec diff is `+64/-0`; the new `describe('getProfileWithPartner')` block is purely additive |
| 8 | Test evidence: `npm test -- users.service` 7/7 PASS, `npm run build` clean | PASS | `test-results.md` §P0 records `Tests: 7 passed, 7 total` (3 pre-existing + 4 new, names match the spec diff exactly) and `nest build` with no type errors. Evidence dated 2026-08-18, consistent with the diff; not rerun per evidence-reuse rule |
| 9 | Phase AC "no new endpoint/controller/module/entity/migration/`@ApiResponse` DTO" | PASS | Diff touches 3 files only; no new route, no new DTO, no migration |

Critical gates for the touched risk surface (typed contract expansion on an
existing endpoint): targeted unit coverage — PASS; backend build/type-check —
PASS. No persistence, migration, auth, or configuration surface touched, so
`deployment/configuration-guide.md` needs no update (phase file records
`Update Required: NO`).

## Blocking Findings

None.

## Deferred Findings

- **D-B1 (LOW, cross-slice note for final synthesis)** — `GET /users/me` carries
  no `@ApiResponse`/typed return, so `/api-docs-json` exposes no response schema
  for it and `partnerDisplayName` cannot appear in any OpenAPI-generated client
  model. This is per plan (phase P0 AC explicitly forbids adding a DTO), so it is
  not a defect against AC1, but story In Scope item 3 says the mobile lane
  "regenerate the API client for the expanded `/users/me` response". Slice 2 /
  final synthesis should confirm the mobile lane reads the raw JSON map (as
  `contract-summary.md` §3's "a missing key must be treated as `null`" implies)
  rather than depending on regenerated typed models.
- **D-B2 (LOW)** — An empty-string partner `displayName` (`''`) is returned
  as-is rather than as `null`, because `??` only collapses null/undefined.
  `contract-summary.md` §3 scopes its "never an empty string" wording to the
  three named cases (`partnerId` null, dangling row, partner `displayName` null),
  and it also forbids backend trim/normalization, so the current behavior is the
  contract-faithful reading. Worth a consumer-side note only. Also minor: the
  partner lookup loads the whole row when `select: ['displayName']` would do —
  no response impact, since only the one field is read.

## Traceability

- AC1: `story_master.md` `## Acceptance Criteria` item 1 → `users.service.ts:30-40`, `users.controller.ts:18` → `users.service.spec.ts` `describe('getProfileWithPartner')` → `test-results.md` §P0.
- Architecture: `architecture/contract-summary.md` §2 (identifier spelling), §3 (null contract, no-normalization, no-other-partner-field) — all satisfied.
- Plan: `coding-plan/phase-P0-users-me-partner-display-name.md` §3 Tasks and §4 Acceptance Criteria — all satisfied, including the explicit "do not call `UsersService.findOne`" directive.

## Recommendation

AC1 requires no rework. The story-level outcome depends on slice 2 (AC2-AC7,
mobile lane) and the story-level runtime/visual gates, which are outside this
slice.

REVIEW_SLICE_COMPLETE: YES
