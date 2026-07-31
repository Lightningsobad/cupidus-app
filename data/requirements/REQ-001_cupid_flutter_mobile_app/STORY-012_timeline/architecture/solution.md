# 012_timeline-solution.md

## 0. Metadata

- User Story ID: STORY-012
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-012_timeline/story_master.md`
- Complexity: M (`Story-Class: standard`)
- Referenced Inputs: story `story_master.md`; story `ux/uiux-spec.md` (§1 screens, §2 states, §5 open items); `req_master.md` (STORY-012 row, R3 risk row); `requirements/requirements.md` (Cross-Story Notes A1/R3); `system_architecture_memory.md` (ADR-007 range only); frozen backend `backend/src/modules/timeline/*`, `backend/src/modules/uploads/*`, `backend/src/modules/users/users.controller.ts`; existing mobile `core/network/*`, `core/auth/cupid_session.dart`, `core/di/service_locator.dart`, `core/navigation/app_shell.dart`, generated `openapi/cupid_api` timeline API
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md`
- Solution Number: 012
- Version: v1.0
- Date: 2026-07-30
- Status: Final

## 1. Decision Summary

- Mode: Brownfield
- Branch Action: Scan Architecture (narrow: frozen `timeline` backend contract + existing mobile network/session seams)
- Architecture Drivers: A1 frozen backend; ADR-007 read-through Drift cache with no offline write queue; AC3 offline read; AC4 pairing gate that must also hold offline; R3 libsodium question must be resolved before coding.
- Architectural invariants / non-goals: no backend change; no offline write/outbox queue; no new realtime surface (timeline has no socket event); feature code never constructs `Dio` and never imports `package:cupid_api/...` directly (imports `core/network/cupid_api.dart`); no libsodium/FFI in this story.
- Proposed technical direction: mobile-only feature slice. Drift becomes the app's first local persistence layer (`AppDatabase`) and is the single UI source of truth for the timeline; the network layer refreshes it. Reads/writes go through the existing shared `Dio` from `CupidApi` because the generated timeline operations are typed `Response<void>`. Pairing state is read once from `GET /users/me`, cached, and drives the AC4 gate offline.
- Why this fits the current system or new area: it lands the ADR-007 F5 persistence seam exactly where ADR-007 already mandated it, reuses the STORY-002/003 network + session-scoped-store seams without editing `core/auth`, and adds no native plugin beyond the SQLite bundle Drift requires.

### R3 (libsodium FFI) — RESOLVED, no spike required for STORY-012

`story_master.md` and `ux/uiux-spec.md` §5.1 both defer this to Tech Lead. Resolution: **timeline content requires no local encryption, so R3 does not gate this story.**

Verified against the frozen backend: `TimelineEvent` (`backend/src/modules/timeline/entities/timeline-event.entity.ts`) persists `title`, `description`, `photoUrl`, and `icon` as plaintext Postgres columns, and `GET /timeline` returns them as plaintext JSON over the transport. The server already holds this content in the clear, so encrypting the on-device read-through mirror would add no confidentiality against any actor the current design protects against — it would only add a libsodium FFI dependency, a dual-platform build risk (R3), and key-management scope with no threat-model benefit. The existing privacy invariant is unchanged and still honoured: **credentials** stay in platform secure storage and never enter Drift (system memory §"Tokens in platform secure storage, never in `hydrated_bloc`/Drift").

Instead of encryption, device-level confidentiality is met by lifecycle scoping: `AppDatabase` registers as a `SessionScopedStore` and wipes all couple-scoped rows on sign-out (D-012-5), so a second user on the same device never reads the first couple's memories.

Scope note: this resolution covers STORY-012 only. STORY-013 (gallery) and STORY-014 (dream jar) carry the same R3 open item and must be resolved on their own content sensitivity; gallery in particular may reach a different answer.

## 2. Downstream Contract Summary

- Backend contract: **frozen, unchanged.** `POST /timeline` (`CreateTimelineEventDto`: `title` required ≤100; optional `description` ≤500, `photoUrl`, `icon`, `type`, `date` ISO string), `GET /timeline?limit&offset` (newest-first by `createdAt`), `DELETE /timeline/:id`, `POST /uploads` (multipart `file`), `GET /users/me`. No endpoint, DTO, or spec change.
- Frontend contract: not applicable (no web lane).
- Mobile contract:
  - `AppDatabase` (`mobile/lib/core/database/app_database.dart`) owns tables `timeline_entries` and `timeline_sync_state`; exposes `watchFirstPage()`, `replaceFirstPage(...)`, `lastSyncedAt`, and `clearOnSignOut()`.
  - `TimelineRepository` (`mobile/lib/features/timeline/data/timeline_repository.dart`) is the only feature-facing seam: `Stream<List<TimelineEntry>> watchEntries()`, `Future<TimelineRefreshOutcome> refresh()`, `Future<void> createEntry(TimelineDraft)`.
  - `CouplePairingStore` (`mobile/lib/core/couple/couple_pairing_store.dart`) exposes `Future<PairingStatus> resolve()` returning `paired | unpaired | unknown`, cached across restarts, cleared on sign-out.
- DevOps / environment contract: no new env var owned by this story. `POST /uploads` builds absolute `photoUrl` values from backend `HOST`/`PORT` (default `localhost:3000`), which is unreachable from a device/emulator; existing timeline photos may therefore fail to load in non-local environments.
- Requirement configuration guide impact: REQUIRED (one note only) — record in `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` that backend `HOST` must be a device-reachable host for timeline photos to render, and that the mobile app now ships a bundled SQLite (`sqlite3_flutter_libs`). Owning phase: P5.
- Data model / migration contract: Drift schema version 1, created by this story. Cache-only and disposable — a schema bump may drop and recreate tables rather than migrate, because the server is authoritative (ADR-007).
- API / event / worker queue contract: REST only. No socket event, no FCM topic, no worker.
- Test and verification expectations: Drift DAO unit tests on in-memory `NativeDatabase`; DTO decode tests; repository read-through/offline tests with a fake remote source; cubit tests for the six UI states; widget tests for the entry-point card gate; `flutter analyze` + `flutter test` + `flutter build apk --debug` (registry `mobile-app`). No mobile e2e, no emulator lifecycle, no signing, no store gates.
- Risk surfaces and verification contract: see §4 "Risk Surfaces And Source Of Truth".
- OQ constraints that downstream lanes must preserve: ADR-007 (OQ4) — Drift is a read-through cache, server-authoritative, and there is **no** offline write/outbox queue. A failed create must surface an explicit retry affordance and must never be queued or optimistically inserted.

## 3. Scope And Assumptions

- In Scope: Drift `AppDatabase` foundation; timeline read-through cache; timeline list screen with loading/empty/offline/offline-no-cache states; create-memory bottom sheet (title, date, description); dashboard entry point with the AC4 unpaired gate; vi/en strings.
- Out Of Scope: any backend change (A1); offline write/outbox queue (ADR-007); photo **attachment on create** (D-012-7); delete-entry UI; timeline pagination beyond the first 50 entries (D-012-8); the milestone/progress banner (D-012-9); offline photo caching; libsodium/local encryption (R3 resolved above).
- Assumptions affecting design:
  - `GET /users/me` returns the `User` entity including `partnerId`; `partnerId != null` means paired. (Same raw-body read pattern STORY-003 already uses for `/auth/login`.)
  - Timeline volume per couple is low enough that one 50-row page satisfies AC2; ADR-007's paging concern is driven by chat history, not timeline.
  - The `home_screen.dart` placeholder is the current dashboard surface; a real dashboard story may later re-home the entry card.

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| OQ4 / ADR-007 | RESOLVED | Offline write queue, outbox, optimistic insert, client-generated ids | Drift read-through cache, server-authoritative reads, fail-fast writes with retry affordance | D-012-1, D-012-3 |
| A1 (backend freeze) | RESOLVED | New/changed `timeline` endpoint, DTO, or OpenAPI response schema | Client-side decode of existing plaintext responses | D-012-2 |
| R3 (libsodium FFI) | RESOLVED for STORY-012 | Adding libsodium/FFI or an encrypted Drift cipher in this story | Plaintext cache with sign-out wipe | See §1 R3 |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/timeline/` (feature) plus two new core seams, `mobile/lib/core/database/` and `mobile/lib/core/couple/`.
- New or changed boundaries: Drift persistence boundary (new, app-wide); couple-pairing read boundary (new, minimal); no change to `core/auth`, `core/network`, or `core/realtime` source.
- Shared patterns reused or introduced: reused — `core/network/cupid_api.dart` as the only REST surface, `CupidApiFailure` taxonomy, `CupidSession.registerScopedStore` for sign-out teardown, `get_it` registration in `core/di/service_locator.dart`, design-system `CupidHeader`/`CupidAddAction`/`CupidPrimaryButton` and tokens. Introduced — `AppDatabase` + DAO methods as the UI source of truth.

### Affected Components And Layers

- Backend: none (read-only consumer of the frozen contract).
- Frontend: none.
- Mobile: `pubspec.yaml`; `core/database/`; `core/couple/`; `core/di/service_locator.dart`; `core/navigation/` route to the timeline screen; `features/timeline/**`; `features/home/presentation/home_screen.dart` (entry card, additive); `lib/l10n/arb/app_en.arb`, `lib/l10n/arb/app_vi.arb`.
- Data: new local SQLite file (Drift, schema v1). No server schema change.
- Infrastructure: bundled SQLite via `sqlite3_flutter_libs` (affects the Android/iOS build, no runtime service change).

### Contracts And Integrations

- APIs / events / schemas affected: `GET /timeline`, `POST /timeline`, `GET /users/me`, `POST /uploads` (display path only). All consumed as-is.
- External or trust-boundary implications: the local Drift file is plaintext couple content on the device; mitigated by sign-out wipe (D-012-5). Tokens remain in secure storage and never enter Drift.
- Contract owner: backend owns the wire shape (frozen); mobile owns the local `TimelineEntry` domain model and the Drift schema.
- Connection pattern and dependency direction: `TimelineScreen` → `TimelineCubit` → `TimelineRepository` → (`AppDatabase` for reads, `TimelineRemoteDataSource` for network). UI never touches the remote source or the DAO directly. Dependencies point inward only; `core/` never imports `features/`.
- Example request / response / payload / signature:
  - `POST /timeline` body: `{"title":"First fight, survived","description":"...","icon":"favorite","type":"memory","date":"2026-05-14T00:00:00.000Z"}`
  - `GET /timeline?limit=50&offset=0` → `[{"id":"<uuid>","coupleId":"<id>","type":"memory","title":"...","description":null,"photoUrl":null,"icon":"favorite","createdAt":"2026-05-14T00:00:00.000Z"}, ...]`
- Error, retry, timeout, idempotency, and empty-state contract:
  - Errors reach callers as `CupidApiFailure` on `DioException.error`; feature code must switch on the sealed `CupidApiFailure` subtypes, never on `DioExceptionType`.
  - `NetworkUnavailableFailure` / `TimeoutFailure` on refresh → serve cache, mark connectivity offline. On create → keep the sheet populated, show inline retry copy, never queue.
  - `HttpStatusFailure(404)` on create → "pairing required" state (the backend 404s an unpaired create).
  - `UnauthorizedFailure` → propagate to the existing session/re-auth path; this story adds no second auth path.
  - No idempotency key exists on the wire, so retry is user-initiated only (ADR-007).
  - Empty state is ambiguous on the wire: `GET /timeline` returns `[]` both for a truly empty timeline **and** for an unpaired user. Disambiguation is client-side via `CouplePairingStore` plus `timeline_sync_state.lastSyncedAt`.
- Compatibility or versioning posture: Drift schema v1 is disposable cache; drop-and-recreate is acceptable on future bumps.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Consumer Contract | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|-------------------|-------------------|----------------------------|
| Untyped REST body (generated timeline ops are `Response<void>`) | frozen `timeline.controller.ts` + `timeline-event.entity.ts` | `TimelineEventDto.fromJson` | DTO decode unit tests incl. null/absent optional fields and unknown `type` | Cannot assert wire mapping; block P2 |
| Drift read-through cache (ADR-007) | `app_database.dart` schema v1 | `watchEntries()` / `replaceFirstPage()` | DAO + repository unit tests on in-memory `NativeDatabase`, incl. never-synced vs synced-empty | AC3 unverifiable; block P3 |
| Offline write prohibition (ADR-007) | ADR-007 bounds | `createEntry()` fail-fast + retry affordance | cubit test: create under `NetworkUnavailableFailure` keeps input, emits retry, writes nothing to Drift | Silent data loss risk; block P6 |
| AC4 pairing gate (must hold offline) | `GET /users/me.partnerId` + cached `PairingStatus` | `CouplePairingStore.resolve()` | store unit tests (paired/unpaired/unknown, cached-offline, cleared on sign-out) + entry-card widget test | AC4 unverifiable; block P7 |
| Session data leakage across users | `CupidSession.registerScopedStore` | `AppDatabase.clearOnSignOut()` | unit test: rows gone after sign-out teardown | Privacy regression; block P1 |
| Native build after adding bundled SQLite | runtime registry `mobile-app.buildCommand` | `flutter build apk --debug` | build gate in P8 | Cannot ship; block P8 |
| Runtime readiness signal | registry `mobile-app.healthCheck.sourceFile` = `home_screen.dart` | `Key('home_screen_ready_signal')` must survive the entry-card edit | widget test asserting the key still pumps | Runtime smoke breaks for the whole app; block P7 |

### Mobile Lane Handoff

- Mobile responsibilities: everything in this story. Single lane, sequential phases P1→P8.
- Mobile inputs that are authoritative: this solution, `story_master.md`, `ux/uiux-spec.md` §1/§2/§3/§4 for the named screen and states, and the frozen backend files cited in §2.
- Mobile constraints derived from UX: skeleton count 5 (§2); newest-first order; dashed "Add a memory" affordance; offline banner rather than silent stale data; distinct offline-no-cache state; date/timestamp text raised to ≥11pt per UX §4 deviation note; accent colors for icons/dots only, never for body text.
- Mobile guardrails: import `core/network/cupid_api.dart` only; do not construct `Dio`; do not edit `core/auth/**` or `core/realtime/**`; do not add `image_picker`, `connectivity_plus`, libsodium, or any FFI package; keep `Key('home_screen_ready_signal')` intact; additive-only edits to `home_screen.dart`, `service_locator.dart`, and the two `.arb` files (they are merge hotspots shared with sibling epic-4 stories in this wave).

### Backend / Frontend / DevOps Lane Handoff

- Backend: not participating (A1 frozen).
- Frontend: not participating.
- DevOps: not participating as an implementing lane. Requirement configuration guide update: REQUIRED (one note, written by P5).

## 5. Non-Functional Impact

- Security / privacy: couple content is cached in plaintext SQLite by design (see §1 R3). Sign-out wipes it. Tokens never enter Drift. No new permission is requested (no camera/photo access, because create-with-photo is deferred).
- Reliability / performance / scalability: Drift `watch` query drives one stream to the UI, so refresh never rebuilds from network state directly; single 50-row page keeps the query trivial; no `hydrated_bloc` whole-state serialization on emit (the R4 low-end-Android concern ADR-007 raised).
- Observability / operations: failures surface as typed `CupidApiFailure` states in the UI; no new logging surface.
- Migration / rollout / rollback constraints: no server migration. Rollback is code-only; a stale local SQLite file is harmless because the cache is disposable and server-authoritative.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Read timeline via generated `timelineControllerGetTimeline` | Preferred client per ADR-006 | Rejected as a typed path, reused as transport-only | The OpenAPI spec declares no response schema, so the generated op returns `Response<void>`; the body is unreachable as a typed model. Same gap STORY-003 hit on `/auth/login`. Use the shared `Dio` with a hand-written DTO (D-012-2). |
| Regenerate the client after adding response schemas | Would give typed models | Rejected | Requires editing backend Swagger decorators = A1 violation. |
| `hydrated_bloc` instead of Drift | Already a lighter path, no codegen | Rejected | ADR-007 mandates Drift for `timeline` and forbids whole-state serialization for long-history domains. |
| Add `connectivity_plus` for offline detection | UX §2 asks for a proactive offline signal | Rejected | New native plugin + platform config for a signal already derivable from `NetworkUnavailableFailure`/`TimeoutFailure` on the last call (D-012-4). |
| Encrypt the Drift cache with libsodium (R3) | Story open item | Rejected | No threat-model benefit; server already stores plaintext. See §1. |
| Ship photo attachment on create | UX §1.3 lists it as optional | Deferred (D-012-7) | Needs `image_picker` + iOS/Android permission strings; no AC requires it; `POST /uploads` also returns a `localhost`-based URL that a device cannot fetch. Display of existing `photoUrl` stays in scope. |

## 7. Risks And Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Bundled SQLite breaks the Android/iOS build (first native dependency added since bootstrap) | Story cannot ship | P8 runs the registry `buildCommand` (`flutter build apk --debug`) as an explicit gate |
| Drift codegen (`build_runner`) is new to this repo and must stay reproducible | Later stories inherit a broken generator | P1 commits the generated `.g.dart` and records the exact `dart run build_runner build` command in the phase evidence |
| `home_screen.dart`, `service_locator.dart`, and the `.arb` files are also edited by sibling epic-4 stories in this wave | Merge conflicts at integration | Keep every edit additive and single-block; card widget lives under `features/timeline/`, not inside `home_screen.dart` |
| `Key('home_screen_ready_signal')` removed while adding the entry card | Requirement-wide runtime readiness signal breaks | Named guardrail + widget test in P7 |
| `photoUrl` points at `http://localhost:3000/...` | Photos silently fail to load | Graceful image-error placeholder in P5 + configuration-guide note |
| STORY-005 (pairing) may land its own pairing gate | Two divergent unpaired treatments | `CouplePairingStore` is deliberately minimal and single-purpose; UX §5.5 already asks for reconciliation — flagged to Scrum Master |
| Auto-generated server entries (`type: milestone` from the pet-milestone listener) appear in the same feed | Feed looks broken or entries seem unauthored | Render all `type` values; show the UX "auto-added" pill for `type != memory`; never offer delete for `milestone` (backend 400s it) — resolves UX §5.2 |

## 8. Handoff Notes

Story-local decisions (ids are story-scoped on purpose; sibling parallel stories are also allocating ADR numbers, so promote any of these to a system `ADR-0NN` only at integration/system-memory update time):

- D-012-1: Drift `AppDatabase` is the single UI source of truth; network refresh writes to Drift and the UI reads only the Drift stream.
- D-012-2: Timeline REST reads/writes use the shared `Dio` from `CupidApi` with a hand-written `TimelineEventDto`, because the generated ops are `Response<void>`.
- D-012-3: No optimistic insert, no outbox, no auto-retry on create (ADR-007).
- D-012-4: Connectivity is derived from the last call's `CupidApiFailure`, not from a connectivity plugin.
- D-012-5: `AppDatabase` registers as a `SessionScopedStore` and wipes on sign-out.
- D-012-6: `timeline_sync_state.lastSyncedAt` distinguishes never-synced from synced-empty (required by UX §2).
- D-012-7: Photo attachment on create is deferred; photo display stays in scope.
- D-012-8: First page only (`limit=50&offset=0`); no pagination UI.
- D-012-9: Milestone/progress banner is out of scope (UX §5.4 answered: deferred).

Other handoff items:

- Implementation guardrails: see "Mobile guardrails" in §4.
- OQ-driven constraints to preserve: ADR-007 read-through + no offline write queue; A1 backend freeze.
- Shared contract-first work required: YES — P1 (Drift schema + DAO) and P2 (DTO/domain model) are the contract-first phases every later phase consumes.
- Shared coding plan required: YES — `coding-plan/master-plan.md` with phases P1–P8.
- Memory updates required: none in this run. Candidates for a later system-memory pass, to be decided by Scrum Master at integration: the R3 resolution rationale, the `Response<void>` raw-body pattern (now hit twice), and the ADR-007 Drift instantiation.
- Open questions / blockers: none blocking. UX §5 open items are all answered here (5.1 R3 → no encryption; 5.2 auto entries → render read-only, no delete; 5.3 create sheet → bottom sheet confirmed; 5.4 banner → deferred; 5.5 unpaired gate → minimal `CouplePairingStore`, reconcile with STORY-005). Deferrals D-012-7/8/9 narrow the UX spec and should be visible to Product Owner.
