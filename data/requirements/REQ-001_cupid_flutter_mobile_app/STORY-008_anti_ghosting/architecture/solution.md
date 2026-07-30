# 008_anti-ghosting-configuration-solution.md

## 0. Metadata

- User Story ID: STORY-008
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-008_anti_ghosting/story_master.md`
- Complexity: S (Story-Class `standard`)
- Referenced Inputs: `story_master.md`; `ux/uiux-spec.md` §0-§6; `req_master.md` row STORY-008 + line 43; `backend/src/modules/ghost-config/` (controller routes, `GhostConfig` entity, `CreateGhostConfigDto`, `getStormStatus`); `mobile/openapi/cupid_api/lib/src/api/epic23_ghost_config_anti_ghosting_api.dart`; `mobile/lib/core/{di,network,realtime}`; `mobile/lib/design_system/`; `data/devops/system/runtime-command-registry.json` (`mobile-app`)
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md` (not updated by this story)
- Solution Number: 008
- Version: v1.0
- Date: 2026-07-30
- Status: Final

## 1. Decision Summary

- Mode: Brownfield
- Branch Action: None
- Architecture Drivers: the `ghost-config` backend module is **A1-frozen**; its
  approval lifecycle (propose -> partner approve/reject) has no push channel;
  the AC2 surfacing point lives inside STORY-007's chat screen, which does not
  exist on this story's `BaseHead`.
- Architectural invariants / non-goals: no backend change of any kind; no
  regeneration of `mobile/openapi/cupid_api`; no new mobile package
  dependency; no edit to chat-owned files; no realtime/FCM work.
- Proposed technical direction: one self-contained mobile feature module
  `mobile/lib/features/anti_ghosting/` with a hand-written Dio repository over
  the frozen REST contract, two cubits (config lifecycle, storm status), the
  `antighost` settings screen, and two **exported surfacing widgets** — a home
  entry card mounted now, and a chat ghost-state row delivered as a mount seam
  for STORY-007.
- Why this fits the current system or new area: it reuses the established
  `features/<name>/{data,presentation}` + Cubit + `get_it` + design-system-token
  layering already set by STORY-001..004, and reuses the codebase's existing
  "occupant supplied by another story" seam idiom (`CupidInterceptorSlot`).

## 2. Downstream Contract Summary

- Backend contract: **unchanged / read-only consumption.** `POST /ghost-config`
  (body `{timeoutMinutes: int 1-120, penalty: 'emoji_storm'|'noise'|'none'}`),
  `GET /ghost-config` (active or null), `GET /ghost-config/pending` (array),
  `PATCH /ghost-config/:id/approve`, `PATCH /ghost-config/:id/reject`,
  `GET /ghost-config/storm-status/:partnerId` -> `{eligible: bool, penalty: string|null}`.
  Entity fields consumed: `id`, `coupleId`, `timeoutMinutes`, `penalty`,
  `proposedBy`, `approvedBy`, `status`, `createdAt`, `updatedAt`.
  `status` wire values: `active | pending_approval | rejected | superseded`.
- Frontend contract: NOT_APPLICABLE (no web lane in this requirement).
- Mobile contract: feature barrel `mobile/lib/features/anti_ghosting/anti_ghosting.dart`
  exports `AntiGhostScreen`, `AntiGhostEntryCard`, `GhostStateRow`,
  `GhostStormCubit`, `AntiGhostCubit`, `GhostConfigRepository`.
- DevOps / environment contract: none. No env var, secret, port, or registry
  change. Runtime registry id stays `mobile-app`.
- Requirement configuration guide impact: NOT_APPLICABLE.
- Data model / migration contract: none. `ghost_configs` table already exists.
- API / event / worker queue contract: no events. Pull-model only (ADR-2).
- Test and verification expectations: `flutter test` + `flutter analyze` +
  registry `buildCommand` (`flutter build apk --debug`). No mobile e2e, no
  emulator lifecycle, no signing, no runtime startup smoke.
- Risk surfaces and verification contract: see §4 table.
- OQ constraints that downstream lanes must preserve: no OQ ids are referenced
  by this story. UX §6 open items are resolved as ADR-2 and ADR-5 below.

## 3. Scope And Assumptions

- In Scope: anti-ghosting config read/propose/approve/reject on mobile; the
  `antighost` settings screen with UX states A-D; pairing guard; the home entry
  card; the chat ghost-state row widget plus its storm-status polling.
- Out Of Scope: any `ghost-config` endpoint or DTO change; OpenAPI client
  regeneration; the typing-ghost indicator (STORY-007); the home dashboard
  redesign; the `ghostAlert` home banner (UX §2.2 — see Assumption 3); the
  mockup's public-countdown / sound-override toggles and custom emoji grid
  (ADR-5); server-side notification of proposals.
- Assumptions affecting design:
  1. `mobile/lib/features/chat/**` is owned exclusively by STORY-007 and is
     absent from `BaseHead a07aa98`. STORY-008 therefore mounts nothing into
     chat and delivers a seam instead (ADR-3).
  2. `HomeScreen` is still the foundation placeholder and carries the runtime
     registry readiness key `home_screen_ready_signal`. Edits to it must be
     additive and must not remove or rename that key.
  3. UX §2.2's `ghostAlert` home banner presumes a real home dashboard that does
     not exist yet. It is deferred: AC2 is satisfied by UX §2.4 (the chat row),
     which the UX spec itself names as "the AC2 gate". §2.2 is explicitly
     "not the AC2 gate".
  4. The current user's backend user id is obtainable from
     `BackendUserIdStore` (`mobile/lib/core/realtime/backend_user_id_store.dart`).

### Open Question Constraints

No OQ ids are referenced by `story_master.md`, `req_master.md` STORY-008, or the
UX spec. UX §6 items 1-3 are resolved as architecture decisions (ADR-5, ADR-2);
UX §6 item 4 (epic label) is a backlog-labelling matter with no technical impact.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile/lib/features/anti_ghosting/` (new).
- New or changed boundaries: one new mobile feature module. Additive-only
  touches to four shared files: `core/di/service_locator.dart`,
  `design_system/icons/cupid_icons.dart`,
  `features/home/presentation/home_screen.dart`, `l10n/arb/app_{en,vi}.arb`.
- Shared patterns reused or introduced: reused — `features/<name>/{data,presentation}`,
  Cubit (`flutter_bloc`), `get_it` lazy singletons, `CupidApiFailure` error
  mapping via the existing `errorMapping` interceptor slot, `CupidColorTokens`
  theme extension, `CupidPrimaryButton`/`CupidHeader` adaptive widgets.
  Introduced — one exported cross-story widget seam (ADR-3).

### Affected Components And Layers

- Backend: none.
- Frontend: none.
- Mobile: new `features/anti_ghosting/{data,presentation}`; additive edits to
  `core/di/service_locator.dart`, `design_system/icons/cupid_icons.dart`,
  `features/home/presentation/home_screen.dart`, `l10n/arb/app_en.arb`,
  `l10n/arb/app_vi.arb`.
- Data: none.
- Infrastructure: none.

### Contracts And Integrations

- APIs / events / schemas affected: none changed; six existing endpoints
  consumed (§2).
- External or trust-boundary implications: all six calls are Firebase-JWT
  bearer-authenticated through the existing `auth` interceptor slot. No new
  trust boundary.
- Contract owner: backend `ghost-config` module (frozen). Mobile is a pure
  consumer and must never widen or reinterpret the contract.
- Connection pattern and dependency direction: mobile -> backend REST over the
  single shared `Dio` obtained from `CupidApi.dio`.
- Example request / response / payload / signature:
  - `POST /ghost-config` request `{"timeoutMinutes": 10, "penalty": "emoji_storm"}`
    -> a `pending_approval` config owned by `proposedBy = <caller>`.
  - `GET /ghost-config/storm-status/<partnerId>` -> `{"eligible": true, "penalty": "emoji_storm"}`.
- Error, retry, timeout, idempotency, and empty-state contract:
  - Every failure surfaces as `CupidApiFailure` (already set on
    `DioException.error` by `CupidErrorInterceptor`); the repository catches
    only `CupidApiFailure`, matching `AuthRepository`.
  - `GET /ghost-config` legitimately returns null and `GET /ghost-config/pending`
    legitimately returns `[]` — both are empty states, never errors.
  - `HttpStatusFailure(400)` on propose/approve/reject means "not paired" or
    "not your config to approve": render the guard/stale state and refetch, do
    not retry blindly.
  - No client retry loops. Timeouts come from `CupidApiConfig`.
  - Propose is not idempotent server-side; the UI must disable the CTA while
    the call is in flight to avoid duplicate `pending_approval` rows.
- Compatibility or versioning posture: additive consumer only; no version bump.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Consumer Contract | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|-------------------|-------------------|----------------------------|
| Frozen `ghost-config` wire contract | `backend/src/modules/ghost-config/` controller + entity + DTO | exact paths, payload keys, enum wire values | repository unit test asserting each path, method, body key, and `penalty`/`status` wire strings | BLOCKER: contract drift ships silently |
| Pairing gate (AC3) | UX §1 + backend `BadRequestException('You must be paired...')` | unpaired -> guard state, zero mutating calls | cubit + widget test: no `partnerId` renders guard, propose/approve never invoked | BLOCKER: AC3 unverified |
| Approval-role derivation (`proposedBy == me`) | `GhostConfig.proposedBy` + `BackendUserIdStore` | State B vs State C selection | cubit test covering proposed-by-me, proposed-by-partner, and unknown-id cases | BLOCKER: user could be shown the wrong action |
| Design-system no-fork guard | `mobile/test/design_system/no_fork_guard_test.dart` (`Color(0x`, `Colors.`, `Platform.is`, `defaultTargetPlatform`) | tokens + adaptive widgets only | that existing test stays green | BLOCKER: AC4-class regression for the requirement |
| Runtime readiness key | registry `mobile-app.readiness.widgetKey` | `Key('home_screen_ready_signal')` must survive the home edit | `mobile/test/widget_test.dart` stays green | BLOCKER: breaks the foundation dev readiness signal |
| l10n parity | `mobile/test/l10n/arb_parity_test.dart` | every new key in both `app_en.arb` and `app_vi.arb` | that existing test stays green | BLOCKER: localization regression |
| Storm polling lifecycle | ADR-2 | timer runs only while row visible + foregrounded | cubit test asserting the timer is cancelled on `close()` and on background | BLOCKER: battery/timer leak |
| Cross-story merge surfaces | `service_locator.dart`, `cupid_icons.dart`, `home_screen.dart`, both ARB files | additive-only edits, no restructuring | integration-branch merge of STORY-005/006/007 stays conflict-resolvable | Non-blocking, but must be flagged to Scrum Master |

### Mobile Lane Handoff

- Mobile responsibilities: the entire story. Mobile is the only participating lane.
- Mobile inputs that are authoritative: this solution §2/§4; UX spec §0-§5;
  the backend `ghost-config` source files for wire truth.
- Mobile constraints derived from UX: penalty is a **single-select radio group**,
  not three switches (UX §2.3, §4); timeout offers 5/10/15 presets plus a
  1-120 custom control (UX §2.3 State A); State B controls are **disabled and
  visible**, never hidden (UX §2.3, §4); the chat CTA is penalty-branched and
  suppressed for `none`/no-config while the neutral seen-row still renders
  (UX §2.4); "Anti-Ghosting" and "Emoji Storm" stay untranslated in `vi`
  (UX §5); amber signals must pair colour with an icon plus text label (UX §4).
- Mobile guardrails: no raw colour literal, no `Colors.`, no `Platform.is`, no
  `defaultTargetPlatform` anywhere under `features/`, `core/`, `app/`; no new
  pubspec dependency (no `mocktail`/`bloc_test` — use hand-written fakes as the
  existing tests do); do not touch `mobile/openapi/**`; do not create or edit
  any file under `mobile/lib/features/chat/`.

### Backend / DevOps Lane Handoff

- Not required. Requirement configuration guide update: NOT_APPLICABLE.

## 5. Non-Functional Impact

- Security / privacy: no new data at rest beyond existing shared prefs usage;
  no new credential path; approval authorization stays server-side — the client
  must treat its `proposedBy` comparison as presentation only, never as the
  authorization decision.
- Reliability / performance / scalability: at most one 60s poll while the chat
  ghost-state row is visible and foregrounded; three reads on settings-screen
  entry. No background work.
- Observability / operations: unchanged; failures already log through the
  debug-only `diagnostics` interceptor slot (token-safe per ADR-011d).
- Migration / rollout / rollback constraints: none. The feature is inert until
  a couple proposes a config.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Use the generated `Epic23GhostConfigAntiGhostingApi` | it already exists and is the nominal client | **Rejected** | Every generated method is typed `Future<Response<void>>` because the backend declares no Swagger response schema, so all three read bodies are statically discarded. Reading them would require an unsound cast. |
| Add `@ApiResponse` types to the backend and regenerate the client | yields a typed client | **Rejected** | The module is A1-frozen and this is a mobile-only lane; it would also force an OpenAPI regeneration touching a shared generated package mid-parallel-wave. |
| Hand-written Dio repository over `CupidApi.dio` | ADR-1 | **Chosen** | Exactly the precedent already set at `mobile/lib/features/auth/data/auth_repository.dart:101` (`_api.dio.post<Object?>('/auth/login')`). |
| Mount the ghost-state row directly into STORY-007's chat screen | satisfies AC2 in one branch | **Rejected** | The chat screen does not exist on `BaseHead a07aa98`; writing it here would fork a file another parallel story owns. |
| Export the row as a mount seam consumed by STORY-007 | ADR-3 | **Chosen** | Mirrors the existing `CupidInterceptorSlot` idiom ("`auth`'s real occupant is supplied by STORY-003 via override"). |

### Architecture Decisions

- **ADR-1 — Hand-written Dio repository.** `GhostConfigRepository` calls the six
  paths directly on `CupidApi.dio` with `Object?` response typing and maps JSON
  into immutable models. It does not depend on the generated ghost-config API
  class. Reason: the generated client discards response bodies (§6).
- **ADR-2 — Pull-model refresh (resolves UX §6 item 3).** There is no push
  channel: `GhostConfigService.create()` only emits a `logger.log` stub
  (consistent with STORY-004's R9 finding). Refresh triggers are: settings
  screen entry; app foreground resume; immediately after a successful
  propose/approve/reject; chat-screen focus; and, only while the ghost-state row
  is visible **and** the app is foregrounded, a single 60s periodic timer that
  is cancelled on dispose and on background. No polling anywhere else.
- **ADR-3 — Chat surfacing is a mount seam, not a chat edit.** `GhostStateRow`
  is a self-contained widget exported from the `anti_ghosting` barrel and
  requires only `partnerId`. STORY-007's chat screen mounts it below the message
  list and above the composer (UX §2.4: below the typing-ghost bubble).
  STORY-008 proves the row's behaviour with widget tests; end-to-end AC2
  evidence is produced when the mount lands. Scrum Master must schedule that
  one-line mount in STORY-007 or at requirement integration.
- **ADR-4 — Approval role is derived from the backend user id.** State B vs
  State C is chosen by comparing `GhostConfig.proposedBy` against
  `BackendUserIdStore`, never against the Firebase uid. If the backend user id
  is unknown, render the read-only pending summary with no actions rather than
  guessing.
- **ADR-5 — Contract-shaped controls only (resolves UX §6 item 1).** `penalty`
  is one mutually exclusive enum, and only `timeoutMinutes` + `penalty` are
  persisted. The mockup's public-countdown toggle, sound-override toggle, and
  custom storm-emoji grid are dropped; nothing client-only is invented in their
  place. Product Owner confirmation is a labelling formality, not a blocker,
  because the frozen contract admits no alternative.
- **ADR-6 — No withdraw path.** The frozen contract has no cancel/delete
  endpoint, so State B exposes no withdraw action; its controls are disabled and
  visible with an accessible disabled reason (UX §2.3, §4).

## 7. Risks And Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| AC2 cannot be demonstrated end-to-end inside this branch | story review could read as incomplete | ADR-3 seam + widget-test evidence; Scrum Master schedules the one-line chat mount (STORY-007 or integration). Recorded here, not hidden. |
| `home_screen.dart` / `cupid_icons.dart` / `service_locator.dart` / ARB files also edited by sibling parallel stories | merge conflicts on the integration branch | additive-only edit rule; append new members at the end of each list; never reorder or restructure |
| Removing `Key('home_screen_ready_signal')` while adding the entry card | breaks the registry readiness signal and dev startup | explicit phase acceptance criterion + existing `widget_test.dart` gate |
| `CupidIcons` currently defines only 3 glyphs | new icons needed (blur/cyclone/volume/timer) | add Material Symbols Rounded codepoints to `CupidIcons` additively; never use `Icons.` directly (no-fork guard) |
| Duplicate `pending_approval` rows from double-tap | confusing partner-side state | disable the propose CTA while the request is in flight |
| Client-side `proposedBy` comparison mistaken for authorization | privilege confusion | ADR-4: presentation only; server remains the authority and its 400 is handled as a stale-state refetch |

## 8. Handoff Notes

- Implementation guardrails: ADR-1..ADR-6 plus the Mobile Lane guardrails in §4.
- OQ-driven constraints to preserve: none (no OQ ids in scope).
- Shared contract-first work required: YES — P0 (`GhostConfigRepository` +
  models) is the contract phase every later phase consumes.
- Shared coding plan required: YES — `coding-plan/master-plan.md`.
- Memory updates required: none for this story. If the ADR-3 widget-seam idiom
  is reused by a third story, promote it to system memory then.
- Open questions / blockers: none blocking. One scheduling item for Scrum
  Master: the STORY-007 chat mount of `GhostStateRow` (ADR-3).
