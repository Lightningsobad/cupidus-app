# STORY-001_zodiac_red_flag_screen-solution.md

## 0. Metadata

- Complexity: complex (Story-Class `standard`, Implementation Lane `shared`)
- Date: 2026-08-25

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC2 determinism (same couple + same calendar day =>
  same content, across devices and restarts), AC3 honest degradation, AC1
  "real profile values, not fixtures", and OQ1's no-CMS constraint.
- Architectural invariants / non-goals: curated content is immutable and ships
  as compiled code, not rows — no table, no migration, no seed runner, no admin
  surface. The endpoint is pure and read-only: it performs no write and has no
  per-couple persisted state, so "today's content" is recomputed, never stored.
- Proposed technical direction: a new NestJS `zodiac` module holding two static
  content modules (78-entry conflict-index table keyed by the sorted sign pair,
  and a fixed daily-tip pool of >= 12 entries) plus one authenticated read
  endpoint that joins the requester and `user.partnerId` and returns a
  discriminated `ready` / `incomplete_profile` payload. Mobile adds a
  `features/zodiac` slice following the existing repository + cubit + screen
  shape, registered in `service_locator.dart`.
- Why this fits the current system: `VibesModule` is the exact precedent for a
  couple-scoped daily read (controller resolves the user via
  `usersService.findByFirebaseUid(req.user.uid)`, service resolves the partner
  via `user.partnerId`, module imports `UsersModule`). `backend/src/app.module.ts`
  runs TypeORM with `synchronize: true` and the repository has **no**
  `migrations/` and **no** seed infrastructure — a content table would have to
  invent both. `partnerDisplayName` already exists on `MeProfileResponseDto`,
  and `CupidZodiacSign.tryParse` already accepts a lowercase canonical name and
  already color-codes by element, so AC4's icon requirement needs no new client
  domain type.

### Key Discovery

`zodiacSign` is **not** a validated enum anywhere. It is
`@Column({ nullable: true }) zodiacSign: string` (`user.entity.ts:26-27`),
accepted as a bare `@IsString() @IsOptional()` in `update-profile.dto.ts:27-30`,
and written with inconsistent casing by existing callers — the DTO documents
`example: 'Aries'`, `users.service.spec.ts:46` asserts `'capricorn'`, and the
mobile writer `zodiacSignFor()` returns TitleCase (`'Aries'`, `'Pisces'`).
Therefore "unset" is not the only unusable state: a set-but-unrecognised string
is equally unusable, and the story's AC3 branch must cover both or a legacy /
mistyped row silently produces a lookup miss. The architecture makes
normalization (`trim().toLowerCase()` -> canonical key, else `null`) the single
gate, and folds unrecognised into the same `missing` reason as unset. This also
means the wire value is lowercase, which is what `CupidZodiacSign.tryParse`
already normalises to — so no second casing convention enters the system.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md`

## 3. Scope And Assumptions

- In Scope: new backend `zodiac` module (static content + one GET endpoint),
  new mobile `features/zodiac` slice, its DI + named-route registration, and
  its `main_preview.dart` canvas entry.
- Out Of Scope: any persistence, any content-authoring surface, the Home
  quick-grid tile (STORY-002), and a deep link from state 2c to profile edit.
- Assumptions affecting design: server-local time is the app's operating
  timezone; both partners resolve to the same `contentDate` because the value
  is computed server-side once per request from the same clock. `partnerId` is
  the only pairing link (there is no couples module or couple entity).

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `backend/src/modules/zodiac` owns the `/zodiac`
  route prefix, the curated content, and the selection algorithm.
- New or changed boundaries: content selection is a backend-only concern.
  Mobile is a pure renderer of the payload and derives only display formatting
  and the bar fraction.
- Shared patterns reused: `VibesModule` module/controller/service shape;
  `JwtAuthGuard` + `findByFirebaseUid`; `VibesRepository`'s rule that exactly
  one Dart file knows the paths and JSON keys and rethrows the mapped
  `CupidApiFailure` from `DioException.error`.

### Affected Modules

- Backend: `modules/zodiac` (new), `app.module.ts` (register `ZodiacModule`).
- Mobile: `features/zodiac` (new), `core/di/service_locator.dart`,
  `app/cupid_app.dart`, `main_preview.dart`.

### Contracts And Integrations

- Empty-state semantics: an unpaired user, an unset sign, and an unrecognised
  sign all return HTTP `200` with `status: "incomplete_profile"`. Using a 4xx
  here would force mobile to branch on error codes and would be logged as a
  fault by any future monitoring — this is a normal state, not a fault.
- Determinism contract: `conflictIndex` is date-independent (per-pair curated),
  so only tip selection varies by day. Selection is
  `FNV-1a-32(sortedUserIdPair + '#' + contentDate)` seeding three distinct pool
  indices by linear probing — a pure function of inputs, with no `Math.random`,
  no `Date.now()` inside the selector, and the clock injected at the service
  boundary so tests can pin the day.
- Idempotency: `GET` only, no writes, safe to retry; mobile may re-fetch freely.
- The pair key is the two canonical sign keys sorted and joined, so the table
  is 78 unordered entries and a lookup is order-independent by construction.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Content-table completeness (AC1) | `conflict-index.content.ts` | table keyed by sorted pair; exhaustive-by-construction authoring | Jest: every one of the 78 sorted sign pairs resolves to an entry with non-empty `headline`/`body` and `0 <= score <= 10` | `CONTENT_TABLE_INCOMPLETE` naming the missing pair keys |
| Per-day determinism (AC2) | `daily-tip.selector.ts` | pure seeded selector, injected clock | Jest: same `(coupleKey, date)` returns identical ids across 100 calls; a different date changes the set for at least one sampled couple; result is always 3 distinct ids | `DETERMINISM_UNPROVEN` |
| Tip-row-count guarantee (AC2/UX §2 Card 3) | `daily-tips.content.ts` | pool length >= 12 asserted in test; selector always returns 3 | Jest: pool length >= 3 and selector output length == 3 with no duplicates | `TIP_POOL_TOO_SMALL` |
| Free-string `zodiacSign` normalization (AC3) | `zodiac-sign.ts` | `normalizeZodiacSign` gate; unrecognised == unset | Jest: `'Aries'`, `'aries'`, `' ARIES '` -> `aries`; `''`, `null`, `'ophiuchus'` -> `null` | `NORMALIZATION_UNPROVEN` |
| Degraded payload honesty (AC3) | `ZodiacController` + response DTO | union payload omits content keys entirely | Jest: unpaired / self-unset / partner-unset each return `200` with `status: "incomplete_profile"` and no `conflictIndex`/`partners`/`dailyTips` key; widget test asserts the 2c card renders and no score/tip widget is in the tree | `DEGRADED_PATH_UNPROVEN` |
| Design fidelity, dark + `vi` (AC4) | `ux/ux-spec.md` §2 + `Cupid Screens.dc.html` 601-635 | tokens only; `CupidZodiacIcon` for every sign | mobile visual audit: `implemented-zodiac-*.png` vs the design reference pair | `VISUAL_AUDIT_BLOCKED` |
| Reachability (AC5) | `cupid_app.dart` routes map | named route + preview canvas entry | Flutter test: `ZodiacRedFlagScreen.routeName` resolves via `Navigator.pushNamed` in a pumped `CupidApp`; `'zodiac'` absent from `_notImplementedCanvasIds` | `ROUTE_NOT_REGISTERED` |

### Lane Handoff

#### Backend Lane

- Responsibilities: `zodiac` module, the two content modules, the pure
  selector, the response DTOs, and registration in `app.module.ts`.
- Authoritative inputs: `architecture/contract-summary.md`; `VibesModule` as
  the structural precedent.
- Guardrails: do not add an entity, a table, a migration, or a seed script. Do
  not call `Math.random()` or read the clock inside the selector. Do not return
  a 4xx for an incomplete profile. Do not widen or validate `zodiacSign` on the
  existing profile write path — this story only reads it.

#### Mobile Lane

- Responsibilities: `features/zodiac` slice, DI registration, the named route
  in `cupid_app.dart`, and the `main_preview.dart` canvas entry.
- Authoritative inputs: `architecture/contract-summary.md`; `ux/ux-spec.md` §2
  and §5 for layout and tokens.
- Guardrails: only `zodiac_repository.dart` may know `/zodiac` paths or JSON
  keys. Never re-derive the sign from `birthday` or from `zodiacSignFor()` on
  this screen. Never render a Unicode zodiac glyph — `CupidZodiacIcon` only.
  Never render Card 1/2/3 in the degraded state. When adding `routes:` to the
  existing `MaterialApp`, keep `home:` intact and do not add a `'/'` key
  (Flutter asserts on that combination).

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Static TS content modules + pure per-request computation | OQ1 requires curated static content with no CMS | ACCEPTED | Zero schema surface; content is diffable and reviewable in PR; determinism is a property of a pure function, not of stored rows |
| Persisted `zodiac_daily_reading` row per couple per day | The obvious way to make "same content all day" literally true | REJECTED | Buys nothing a pure function does not already give, and costs a table under `synchronize: true` plus a write on a read path; a stored row would also drift from the content table whenever copy is corrected |
