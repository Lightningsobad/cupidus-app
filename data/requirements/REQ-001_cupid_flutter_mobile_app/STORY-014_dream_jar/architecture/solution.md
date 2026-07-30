# 014_dream_jar-solution.md

## 0. Metadata

- User Story ID: STORY-014
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-014_dream_jar/story_master.md`
- Complexity: S (Story-Class `standard`)
- Referenced Inputs: `story_master.md`; `ux/uiux-spec.md` §0.1-0.3, §1.1-1.8, §4; `req_master.md` (STORY-014 row, R3 risk row); `backend/src/modules/dream-jar/**` (frozen contract); `mobile/openapi/cupid_api/lib/src/api/epic5_dream_jar_api.dart`; `mobile/lib/features/auth/data/auth_repository.dart` (repository precedent); `data/devops/system/runtime-command-registry.json` (`mobile-app`)
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md` (queried for R3 only; not updated by this story)
- Solution Number: 014
- Version: v1.0
- Date: 2026-07-30
- Status: Final

## 1. Decision Summary

- Mode: Brownfield
- Branch Action: None
- Architecture Drivers: A1 backend freeze (no `dream-jar` endpoint change); AC1-AC3; UX §0.2 R3 contract gap; UX §0.3 freshness expectation; existing mobile network/DI/l10n foundations from STORY-001..004.
- Architectural invariants / non-goals:
  - No backend file is touched. `dream-jar` routes, DTOs, entities, and OpenAPI spec stay byte-identical.
  - No regeneration of `mobile/openapi/cupid_api/` (STORY-002 owns generation; the spec is unchanged so the generated client is already current).
  - No new third-party dependency. No `libsodium`/FFI, no crypto package (see ADR-014a).
  - Dream Jar is a **shared monetary savings-goal jar**, not a free-text wish list (UX §0.1). AC1-AC3 intent is preserved and mapped onto the real feature; the story wording is a Product Owner correction, not a scope change.
- Proposed technical direction: one new mobile feature module `mobile/lib/features/dream_jar/` in the established `data/` + `presentation/` shape, consuming the frozen REST contract through the shared `CupidApi.dio` instance, exposing Cubit-backed screens, wired into `HomeScreen` through a discoverable Money entry card and into `service_locator.dart`.
- Why this fits: identical layering, failure mapping, DI, and l10n conventions already proven by `features/auth`; zero backend/DevOps surface; all risk stays inside one mobile lane.

## 2. Downstream Contract Summary

- Backend contract: **frozen, consume-only**. `@Controller('dream-jar')` with bearer Firebase JWT: `POST /dream-jar`, `GET /dream-jar?limit&offset`, `GET /dream-jar/:id`, `PATCH /dream-jar/:id`, `DELETE /dream-jar/:id`, `POST /dream-jar/:id/contributions`, `GET /dream-jar/:id/contributions?limit&offset`. Bodies: `CreateDreamJarDto { name, targetAmount, deadline?, currency? }`, `UpdateDreamJarDto { name?, targetAmount?, deadline?, status? }`, `AddContributionDto { amount, note? }`. Amount bounds: `1 .. 999999999999`.
- Frontend contract: NOT_APPLICABLE (no web surface in this story).
- Mobile contract (owned here): `DreamJarRepository` is the single boundary to HTTP; screens/Cubits never touch `Dio`, `Response`, or JSON. See §4 `Contracts And Integrations` for the exact model and failure contract.
- DevOps / environment contract: no env var, secret, port, or runtime-registry change. Runtime registry id `mobile-app` (`flutter build apk --debug`, `flutter test`).
- Requirement configuration guide impact: NOT_APPLICABLE — no phase updates `deployment/configuration-guide.md`.
- Data model / migration contract: none. No migration, no schema change, no local persistence.
- API / event / worker queue contract: no new events. The `dream-jar` backend module contains **no WebSocket gateway and emits no realtime event**, so no `RealtimeCoordinator` subscription is possible without a backend change (ADR-014b).
- Test and verification expectations: `flutter analyze` clean, `flutter test` green, `flutter build apk --debug` succeeds. Unit tests for JSON decoding + failure mapping, cubit tests for state transitions, widget tests for the discoverable entry point and the unpaired notice. No mobile e2e, no emulator lifecycle, no signing.
- Risk surfaces and verification contract: see §4 `Risk Surfaces And Source Of Truth`.
- OQ constraints that downstream lanes must preserve: R3 is resolved as "no client-side encryption in v1" (ADR-014a). No Dream Jar screen may render an "end-to-end encrypted" claim, lock badge, or shield affordance.

## 3. Scope And Assumptions

- In Scope: create a jar; list jars; jar detail with progress; add a preset contribution; paginated contribution history; per-partner contribution split derived client-side; discoverable entry point from Home; unpaired-user handling; DI registration; `app_en.arb`/`app_vi.arb` strings.
- Out Of Scope (deferred, with reason):
  - Edit / archive / delete jar (UX §1.7) — backend supports it, but AC1-AC3 do not require it and delete needs a Product Owner decision on partner notification. Defer to a follow-up story.
  - 4th "custom amount" quick-add tile and the `note` field (UX §1.4, §1.1) — awaiting the Product Owner confirmation UX §1.1 explicitly requested. v1 ships the 3 confirmed mockup presets only.
  - Multi-currency selector — VND only, relying on the backend `currency` default (UX §1.3).
  - "Show archived" toggle — archived jars are filtered out client-side in v1 (ADR-014f).
  - Realtime push freshness (ADR-014b) and a server-side per-partner aggregate endpoint (ADR-014d); both need a backend change blocked by A1.
- Assumptions affecting design:
  - TypeORM `decimal` columns (`targetAmount`, `currentAmount`, `Contribution.amount`) are serialized by the `pg` driver as **JSON strings**, not numbers, while `progress` (computed in `@AfterLoad`) is a number. Mobile decoding must accept both `num` and `String` (ADR-014c).
  - The generated `Epic5DreamJarApi` declares every method `Future<Response<void>>` because the controller publishes no response schema, so response bodies are unreachable through it (same limitation `AuthRepository` already documents for `/auth/login`).
  - No couple/partner profile API is wired in the mobile app yet (STORY-005 owns pairing), so partner identity is expressed as "You" vs "Partner" (ADR-014e).

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| R3 (libsodium FFI / local encryption) | RESOLVED for STORY-014; still open as a system risk for other Level-2 data | Field-level end-to-end encryption of jar name/amounts; any `libsodium`/FFI dependency; any "encrypted" badge or copy on Dream Jar surfaces | Plaintext JSON over TLS 1.3 to the frozen endpoints; server-side at-rest storage | ADR-014a: adopt UX §0.2 option (a). No new spike is required for this story. |
| UX §0.1 (feature framing / epic tag) | Flagged to Product Owner; does not block | Redesigning the backend contract to fit "wish list" wording | Building the confirmed monetary savings-goal feature | Build against the frozen contract; PO corrects `story_master.md` wording and the epic-4/epic-5 tag separately. |
| UX §1.1 (4th custom-amount tile), UX §1.7 (delete notification) | Open, Product Owner owned | Shipping a custom-amount sheet or delete/archive actions in v1 | 3 confirmed presets; read/create only | Deferred out of v1 scope (see §3 Out Of Scope). |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/dream_jar/` (new). No other module gains responsibility.
- New or changed boundaries: `DreamJarRepository` is the only HTTP boundary; `HomeScreen` gains a navigation edge to the Dream Jar list; `service_locator.dart` gains one registration.
- Shared patterns reused: `CupidApi`/`CupidApiClient` shared `Dio` (`core/network/`), `CupidErrorInterceptor` → `CupidApiFailure` mapping, `getIt` DI (`core/di/service_locator.dart`), `flutter_bloc` Cubits (mirroring `features/auth/presentation/*_cubit.dart`), design-system tokens/adaptive widgets (`lib/design_system/`), `intl` for VND formatting, ARB-based l10n with enforced `app_en`/`app_vi` key parity.

### Affected Components And Layers

- Backend: none (A1 frozen).
- Frontend: none.
- Mobile: new `features/dream_jar/data/` (models, repository) and `features/dream_jar/presentation/` (cubits, screens, widgets); edits to `features/home/presentation/home_screen.dart`, `core/di/service_locator.dart`, `lib/l10n/arb/app_en.arb`, `lib/l10n/arb/app_vi.arb`.
- Data: none.
- Infrastructure: none.

### Contracts And Integrations

- Contract owner: backend (frozen). Mobile is a pure consumer; dependency direction is mobile → backend only.
- Connection pattern: `DreamJarRepository` calls `CupidApi.dio` directly (`_api.dio.get<Object?>('/dream-jar', queryParameters: ...)`), exactly as `AuthRepository._syncBackendProfile()` does, because the generated client's `Response<void>` return type makes bodies unreachable. The generated `Epic5DreamJarApi` is intentionally not used; the auth interceptor slot on the shared `Dio` supplies the Firebase bearer token, so no token is threaded through the repository.
- Mobile domain models (owned by this story):
  - `DreamJar { String id, String name, num targetAmount, num currentAmount, DateTime? deadline, String currency, DreamJarStatus status, int progress, DateTime createdAt }`
  - `Contribution { String id, String dreamJarId, String userId, num amount, String? note, DateTime createdAt }`
  - `enum DreamJarStatus { active, completed, archived }`, decoded from the lowercase wire values with an `active` fallback for an unknown value.
- Example payloads:
  - Request `POST /dream-jar/{id}/contributions` → `{"amount": 200000}`
  - Response `GET /dream-jar` → `[{"id":"<uuid>","coupleId":"<uuid>","name":"Trip to Da Lat","targetAmount":"50000000.00","currentAmount":"12000000.00","deadline":null,"currency":"VND","status":"active","createdAt":"...","updatedAt":"...","progress":24}]`
- Error, retry, timeout, idempotency, and empty-state contract:
  - All failures surface as the existing sealed `CupidApiFailure` (`NetworkUnavailableFailure`, `TimeoutFailure`, `UnauthorizedFailure`, `HttpStatusFailure`, `UnexpectedFailure`) set on `DioException.error` by `CupidErrorInterceptor`. Repository methods rethrow the mapped failure, never a raw `DioException`.
  - AC3 gate: every `dream-jar` route calls `getCoupleIdForUser()`, which throws `NotFoundException('User not found or not paired')` for an unpaired user. The repository maps `HttpStatusFailure(404, message)` whose message contains `not paired` to a story-owned `DreamJarUnpairedFailure`; a 404 with any other message stays a jar-not-found failure. This makes AC3 verifiable inside STORY-014 without depending on STORY-005's shell gate.
  - No retry and no idempotency key: `POST /:id/contributions` is not idempotent, so the quick-add control must be disabled while a contribution is in flight to prevent double submission. Timeouts come from `CupidApiConfig`.
  - Empty state: `GET /dream-jar` returning `[]` is a valid success, rendered as the UX §1.5 empty state, never as an error.
- Compatibility or versioning posture: additive mobile-only change; no contract version moves.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Consumer Contract | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|-------------------|-------------------|----------------------------|
| Decimal-as-string JSON decoding | `dream-jar.entity.ts` / `contribution.entity.ts` column types | `DreamJar.fromJson` / `Contribution.fromJson` accept `num` and `String` | Unit tests over string-amount and number-amount fixtures | Amounts render as 0/NaN or throw; jar progress is wrong |
| Unpaired access (AC3) | `dream-jar.service.ts` `getCoupleIdForUser()` 404 | `DreamJarUnpairedFailure` → unpaired notice state | Repository unit test on the 404 message split + cubit state test | AC3 unverifiable; unpaired users see a generic error |
| Entry-point discoverability | `app_shell.dart` / `home_screen.dart` (Home is currently the only rendered surface) | Home Money entry card navigates to the jar list | Widget test asserting the card exists and pushes the jar route | Feature is orphaned and unreachable |
| Progress / liquid-fill bounds | UX §1.1 (`liquidY = 154 - 108 * min(1, current/target)`) and entity `computeProgress()` | Clamp `progress` to 0..100 client-side; never divide by a zero target | Unit test for `target = 0`, `current > target`, `current = 0` | Visual overflow or divide-by-zero crash |
| Double contribution submission | `POST /:id/contributions` non-idempotent | Quick-add disabled while in flight | Cubit test asserting a second tap during submission is ignored | Duplicated contributions corrupt the shared total |
| ARB key parity | `mobile/test/l10n/arb_parity_test.dart` | Every new key exists in `app_en.arb` and `app_vi.arb` | Existing `flutter test` parity gate | l10n gate fails and blocks the story |

### Backend Lane Handoff

- Backend responsibilities: none. Backend Developer does not participate in this story.
- Backend guardrails: if any need for a backend change is discovered (aggregate endpoint, ciphertext column, realtime event), stop and escalate to Scrum Master — A1 freeze means it is a separate story, not an in-story fix.

### Frontend Lane Handoff

- Frontend responsibilities: none (no web surface).
- Mobile responsibilities (this story's only implementation lane): everything in §4 `Affected Components And Layers` → Mobile.
- Mobile inputs that are authoritative: this solution, `story_master.md` AC1-AC3, `ux/uiux-spec.md` §1.1-1.8 §2 §3 §4, the frozen backend contract files.
- Mobile guardrails: no backend edit; no `mobile/openapi/` edit; no new pubspec dependency; no "encrypted" claim on any Dream Jar surface; all user-visible strings through ARB; all colors/spacing/typography through design-system tokens.

### DevOps Lane Handoff

- DevOps responsibilities: none.
- Requirement configuration guide update: NOT_APPLICABLE.

## 5. Non-Functional Impact

- Security / privacy: jar names and amounts travel as plaintext JSON over TLS 1.3 and are stored server-side unencrypted. Under the `ui_ux_system_memory.md` §8 tiering this makes Dream Jar **Level 3 (server-side)**, not Level 2. Follow-up required outside this story: correct the Privacy / "My data" screen grouping and copy so the app does not make an untrue end-to-end-encryption claim. Route auth relies entirely on the existing Firebase bearer interceptor plus backend couple scoping; the client performs no authorization decisions of its own.
- Reliability / performance / scalability: all lists paginated with the endpoint's own `limit`/`offset`; no local cache and no background polling, so there is no cache-coherence surface. Freshness is user-initiated (pull-to-refresh + refresh-on-focus).
- Observability / operations: no new logging or metrics; backend already logs jar creation and contributions.
- Migration / rollout / rollback constraints: none. Rollback is removal of the mobile feature module plus its two integration edits.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| ADR-014a-alt: client-side encryption of `name`/`note` only (UX §0.2 option b) | Would partially honour the Level-2 privacy claim without a backend change | Rejected | Cannot cover `targetAmount`/`currentAmount`/`amount` — the server reads those `decimal` columns in `computeProgress()`, so ciphertext there breaks the API. Partial encryption still is not Level 2, and it would require a couple key-agreement protocol that does not exist anywhere in the system, plus the unproven dual-platform libsodium FFI (R3). Cost and risk buy no honest privacy gain. |
| ADR-014a: no client-side encryption in v1 (UX §0.2 option a) | Only option compatible with A1 and honest about the delivered guarantee | **Adopted** | Dream Jar is Level 3 in v1; Privacy-screen copy must be corrected by a follow-up. R3 stays an open *system* risk for genuinely Level-2 features, but is not a STORY-014 blocker and needs no spike here. |
| Use generated `Epic5DreamJarApi` for requests | Prefer generated client over hand-rolled HTTP | Rejected for reads | Every generated method returns `Response<void>` (no response schema in the spec), so bodies are unreachable; `findAll` also requires `limit`/`offset` as non-optional `String`. ADR-014g: use `CupidApi.dio` directly, matching the documented `AuthRepository` precedent. |
| ADR-014b-alt: subscribe to `RealtimeCoordinator` for jar freshness (UX §0.3) | Partner-visible freshness is expected | Rejected for v1 | The `dream-jar` backend module has no gateway and emits no event; there is nothing to subscribe to, and adding emission is a backend change blocked by A1. ADR-014b: pull-to-refresh + refresh-on-screen-focus. Wiring a subscription later is additive. |
| ADR-014d-alt: server aggregate for the per-partner split | Exact totals for the UX §1.1 comparison card | Rejected | No such endpoint and A1 is frozen. ADR-014d: derive the split client-side by grouping the fetched `GET /:id/contributions` pages by `userId`, and label the card as covering the loaded contributions. |

## 7. Risks And Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Decimal fields arrive as strings, not numbers | High — silent wrong amounts | Tolerant `fromJson` numeric parsing plus unit-test fixtures in both shapes (ADR-014c) |
| Per-partner split is only as complete as the fetched contribution pages | Medium — cosmetic card can understate a partner | Card is explicitly cosmetic (UX §1.1: no gameplay effect); label it as covering loaded contributions; exact totals deferred to ADR-014d follow-up |
| Privacy screen keeps claiming end-to-end encryption for Dream Jar | Medium — untrue user-facing privacy claim | ADR-014a records the correction as required follow-up; no Dream Jar surface in this story renders an encryption claim |
| Partner display name unavailable before STORY-005 | Low | ADR-014e: "You"/"Partner" labels from `BackendUserIdStore` id comparison; no cross-story dependency |
| Home screen has no real navigation stack yet (`app_shell.dart` renders `HomeScreen` only) | Medium — entry point could be built but unreachable | Dedicated entry-point phase (P5) owns the Home card plus `Navigator.push` route and a widget test asserting reachability |
| Story wording still describes a wish list | Low — reviewer/AC confusion | AC1-AC3 mapping to the real feature is recorded in `master-plan.md` §2; PO correction tracked as a flagged open item |

## 8. Handoff Notes

- Implementation guardrails: mobile lane only; no backend/OpenAPI/pubspec change; repository is the sole HTTP boundary; every string through ARB; no encryption claim.
- OQ-driven constraints to preserve: ADR-014a (no encryption, no libsodium, no encrypted badge); deferred items in §3 stay deferred until Product Owner decides.
- Shared contract-first work required: YES — P1 (models, repository, failure contract, amount formatting) must land before any UI phase.
- Shared coding plan required: YES — `coding-plan/master-plan.md` with 6 phases (P1-P5 implementation, P6 mobile verification).
- Memory updates required: none in this story. Follow-ups for whoever owns them next: (1) `system_architecture_memory.md` R3 row should note Dream Jar no longer depends on libsodium; (2) `ui_ux_system_memory.md` §8 should reclassify Dream Jar to Level 3; (3) Privacy / "My data" screen copy correction. All are outside STORY-014's write scope.
- Open questions / blockers: none blocking implementation. Product Owner decisions outstanding on the custom-amount tile, edit/archive/delete scope, and the epic-4/epic-5 tag; all are cleanly deferred and do not gate AC1-AC3.
