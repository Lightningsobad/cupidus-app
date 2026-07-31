# 011_bun_pet-solution.md

## 0. Metadata

- User Story ID: STORY-011
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-011_bun_pet/story_master.md`
- Complexity: M (`Story-Class: standard`)
- Referenced Inputs:
  - `../ux/uiux-spec.md` §1-§9
  - `../../req_master.md` STORY-011 row, A1 backend-frozen constraint
  - `backend/src/modules/pets/{pets.controller.ts,pets.service.ts,entities/pet.entity.ts,dto/adopt-pet.dto.ts}`
  - `backend/src/modules/users/users.controller.ts` (`GET /users/me`)
  - `mobile/openapi/cupid_api/lib/src/api/epic4_love_pet_api.dart`
  - `mobile/lib/core/network/`, `mobile/lib/core/di/service_locator.dart`,
    `mobile/lib/features/auth/data/auth_repository.dart:88-112`,
    `mobile/lib/design_system/`, `mobile/pubspec.yaml`
  - `data/devops/system/runtime-command-registry.json` → `mobile-app`
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md` (ADR-005, ADR-006 read by anchor; not modified by this story)
- Solution Number: 011
- Version: v1.0
- Date: 2026-07-30
- Status: Final

## 1. Decision Summary

- Mode: Brownfield
- Branch Action: None
- Architecture Drivers: A1 backend freeze (`pets` contract is read-only input);
  five-state mood surface; 5-second server-side interaction cooldown; hard
  pairing gate (AC3); the generated OpenAPI client cannot deliver `pets`
  response bodies.
- Architectural invariants / non-goals:
  - No `pets` endpoint, DTO, or business-rule change.
  - No client-side reimplementation of backend business rules (happiness decay,
    mood thresholds, level math, milestone list). The client renders what
    `GET /pets/status` returns.
  - No invented mechanics: no `sleep` state, no streak, no badges, no
    per-species sprite art, no separate feed/play effect.
  - No new pub dependency, no new image/animation asset pipeline.
- Proposed technical direction: a self-contained `mobile/lib/features/pet/`
  feature (data → cubit → presentation) that reads the `pets` REST surface
  through the shared `Dio` instance, maps the backend `mood` string onto a
  pure-Flutter `BunSprite` vector widget, and is reached from a `HomeScreen`
  preview card.
- Why this fits: it mirrors the STORY-003 auth feature layout (`features/<x>/
  data` + `presentation` + cubits + `get_it` registration) and reuses the
  STORY-001 design system and STORY-002 network stack without touching either.

### D1 — Read `pets` through the shared `Dio`, not the generated API class

`Epic4LovePetApi.petsControllerGetPet/GetStatus/Interact/Adopt` are all typed
`Future<Response<void>>` because the backend declares no `@ApiResponse` schema,
so the decoded body is statically unreachable. STORY-003 already solved this for
`/auth/login` by calling `_api.dio.post<Object?>(...)` directly
(`auth_repository.dart:94-108`). STORY-011 uses the same escape hatch for all
four `pets` calls plus `GET /users/me`, and hand-writes the response models.
Consequence: the repository is the single place that knows JSON key names.

### D2 — `GET /users/me` is the pairing source of truth for AC3

`GET /pets` and `GET /pets/status` both return `null` for "unpaired" **and**
"paired but no pet", so they cannot satisfy AC3 on their own. `GET /users/me`
returns the `User` row including `partnerId`, which distinguishes the two.
`POST /pets/adopt` failure-message parsing was rejected as an alternative
(both the unpaired case and the <24h case are `400` and differ only in prose).

### D3 — The 24h adopt gate stays attempt-based, not countdown-based

Per `ux/uiux-spec.md` §5 Open Item 5: the backend derives the 24h gate from
`user.createdAt` as an explicit proxy and exposes no countdown. The client shows
the adopt CTA whenever paired and converts the `400` into a friendly "not yet"
message. No client-side 24h arithmetic, so no drift when the backend replaces
the proxy with a real `pairedAt`.

### D4 — After a successful interact, refetch `GET /pets/status`

`PATCH /pets/interact` returns the raw pet row without `mood`. Recomputing mood
client-side would duplicate frozen backend thresholds, so the cubit chains
`interact` → `status`. Decay cannot double-apply because `interact` has just set
`lastInteraction = now`.

## 2. Downstream Contract Summary

- Backend contract: unchanged. Consumed read-only: `GET /users/me`,
  `GET /pets/status`, `PATCH /pets/interact`, `POST /pets/adopt`.
  `GET /pets` is **not** consumed (`/pets/status` is a superset).
- Frontend contract: not applicable (no web surface in this story).
- Mobile contract:
  - `PetRepository` (owner: mobile) exposes
    `Future<PetPairing> readPairing()`, `Future<PetStatus?> readStatus()`,
    `Future<PetStatus> interact()`, `Future<PetStatus> adopt({species, name})`.
    All failures surface as `CupidApiFailure` subtypes only.
  - `BunSpriteState` is the only mood→visual mapping point.
  - `PetPreviewCard` is the entry-point contract consumed by `HomeScreen`.
- DevOps / environment contract: unchanged. No env var, secret, port, or
  third-party integration change.
- Requirement configuration guide impact: NOT_APPLICABLE.
- Data model / migration contract: none (client-only story).
- API / event / worker queue contract: the `pet.milestone.reached` event is
  backend-internal (`timeline.service.ts` listener). The mobile app must not
  subscribe to it or mirror its thresholds.
- Test and verification expectations: `flutter analyze` clean plus targeted
  `flutter test` unit/widget coverage per phase. No mobile e2e, no
  emulator/simulator lifecycle, no signing, no store gate.
- Risk surfaces and verification contract: see §4.
- OQ constraints downstream lanes must preserve: no PO-level OQ is attached to
  this story. The five resolved UX Open Items (§3) are binding.

## 3. Scope And Assumptions

- In Scope: pet status display, the single interact action behind both
  Feed/Play buttons, the adopt flow, the unpaired hard gate, and the home
  entry point.
- Out Of Scope: everything in `ux/uiux-spec.md` §9, plus any `pets` endpoint
  change, streaks, badges, per-species art, and the `sleep` sprite state.
- Assumptions affecting design:
  1. UX Open Item 1: Feed and Play are one action; the 5s cooldown must be
     surfaced client-side.
  2. UX Open Item 2: the "day streak" / "badges" tiles are dropped and replaced
     by "interactions" + "next milestone".
  3. UX Open Item 3: the adopt flow is net-new UX accepted inside this story,
     because `POST /pets/adopt` is a hard precondition for AC1.
  4. UX Open Item 4: `BunSprite` renders for every species in v1.
  5. UX Open Item 5: attempt-based 24h gate (D3).
  6. The backend `milestone` string (`"100 interactions!"`) is English-only, so
     the UI renders a localized caption derived from `totalInteractions` and
     `nextMilestone` instead of printing that string.
  7. Locale copy follows the STORY-003 precedent: a feature-local
     `viEn(vi, en)` `BuildContext` extension, not the ARB pipeline
     (`mobile/lib/l10n/arb/**` stays out of this story's write scope).

### Open Question Constraints

| OQ ID | Status | Technical Scope Blocked | Technical Scope Allowed | Architecture Decision |
|-------|--------|-------------------------|-------------------------|-----------------------|
| None | — | — | full story scope | UX Open Items 1-5 are resolved in `ux/uiux-spec.md` §5 and carried as assumptions above |

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/pet/` (new).
- New or changed boundaries:
  - New: `features/pet/data` (REST + parsing), `features/pet/presentation`
    (cubits, screen, widgets).
  - Changed (additive only): `mobile/lib/core/di/service_locator.dart`
    (register `PetRepository`), `mobile/lib/features/home/presentation/
    home_screen.dart` (mount `PetPreviewCard`),
    `mobile/lib/design_system/icons/cupid_icons.dart` (five new glyphs).
- Shared patterns reused: shared-`Dio` untyped read (D1), `CupidApiFailure`
  error contract, `get_it` lazy singletons, `flutter_bloc` cubits, the
  `design_system` barrel import, and the STORY-003 `viEn` locale extension
  pattern.

### Affected Components And Layers

- Backend: none.
- Frontend: none.
- Mobile: `features/pet/**` (new), plus the three additive edits above.
- Data: none.
- Infrastructure: none.

### Contracts And Integrations

- APIs affected (consumed, unchanged):

| Call | Client shape | Notes |
|---|---|---|
| `GET /users/me` | `{ id, partnerId?, ... }` | only `partnerId` is read |
| `GET /pets/status` | `{ pet, mood, decayedHappiness, milestone, nextMilestone }` or empty body | empty/`null` body is HTTP 200, **not** 404 |
| `PATCH /pets/interact` | updated pet row | `400` when inside the 5s cooldown |
| `POST /pets/adopt` | `{ species, name }` → created pet row | `400` unpaired/<24h, `409` pet exists |

- Contract owner: backend (frozen). Mobile is a pure consumer.
- Connection pattern and dependency direction: `PetScreen` → `PetCubit` →
  `PetRepository` → shared `Dio` (auth + error interceptors already installed).
  No reverse dependency; no feature-to-feature import.
- Example payload (`GET /pets/status`):
  `{"pet":{"id":"…","coupleId":"…","species":"bunny","name":"Bún","happiness":72,"level":2,"totalInteractions":63,"lastInteraction":"2026-07-30T02:10:00.000Z"},"mood":"happy","decayedHappiness":72,"milestone":"50 interactions!","nextMilestone":100}`
- Error, retry, timeout, idempotency, empty-state contract:
  - Feature code catches `CupidApiFailure` only (never `DioException`, never
    `DioExceptionType`), per the STORY-002 error contract.
  - `HttpStatusFailure(400)` on interact → cooldown micro-state, never a raw
    error banner. `HttpStatusFailure(400)` on adopt → "not yet" copy.
    `HttpStatusFailure(409)` on adopt → dismiss + refresh.
  - `UnauthorizedFailure` is already handled globally by the auth interceptor;
    the feature does not special-case it.
  - No automatic retry of `interact` or `adopt` (both mutate server state and
    are non-idempotent).
  - Empty state: `readStatus()` returns `null` for an empty body; the cubit maps
    that to `PetNoPet`, not to an error.
- Compatibility posture: forward-compatible parsing. Unknown `mood` values fall
  back to `content`/`neutral` instead of throwing, so a future backend mood does
  not crash the screen.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Consumer Contract | Verification Gate | Blocker If Gate Cannot Run |
|---|---|---|---|---|
| Untyped `pets` REST parsing | `backend/src/modules/pets/` | `PetRepository` | unit tests over a stubbed `Dio` adapter asserting path/verb/body and parsing representative payloads incl. empty body | BLOCKED: contract parsing unverified |
| Mood → sprite mapping | `pets.service.ts` `computeMood` + `ux/uiux-spec.md` §3 | `BunSpriteState` | unit test over all 5 moods + unknown-value fallback | BLOCKED: AC1 mood fidelity unverified |
| Pairing hard gate (AC3) | `GET /users/me.partnerId` | `PetCubit` → `PetLocked` | widget test: locked state renders, no adopt CTA, no interact buttons, sheet unreachable | BLOCKED: AC3 unverified |
| 5s interaction cooldown | `pets.service.ts` `interact` | `PetCubit` cooldown state | cubit unit test with controlled clock: buttons disabled ~5s after a tap and after reload derived from `lastInteraction` | BLOCKED: raw 400 leaks to the user |
| Adopt input validation | `AdoptPetDto` (1-30 chars, enum species) | adopt sheet form | widget test: CTA disabled until valid, boundary lengths 1/30/31 | BLOCKED: AC2 adopt path unverified |
| New icon codepoints | bundled `MaterialSymbolsRounded-Variable.ttf` cmap | `CupidIcons` | codepoints read from the font cmap (never guessed) + widget render smoke | BLOCKED: wrong glyph/tofu shipped |
| Entry-point reachability | `ux/uiux-spec.md` §2.1 preview card | `HomeScreen` → `PetScreen` | widget test navigating from the preview card, and `Key('home_screen_ready_signal')` still pumps | BLOCKED: orphaned feature + broken runtime readiness signal |

### Mobile Lane Handoff

- Mobile responsibilities: all nine phases in `coding-plan/master-plan.md`.
- Authoritative inputs: this solution, `ux/uiux-spec.md`, and the `pets` /
  `users` controller signatures. The generated `cupid_api` pets class is
  explicitly **not** authoritative for response shapes (D1).
- UX dependencies: §2 screens/flows, §3 mood mapping, §4 copy, §6 fixed sprite
  sizes (206/74/46), §7 accessibility, §8 design-system reuse.
- Guardrails:
  - Import the design system only via `package:cupid_mobile/design_system/design_system.dart`; do not import token files directly.
  - Hero-card gradient `#7B4FBE → #B0518C → #5E7E96` matches neither
    `gradientDream` nor `gradientHot`. Declare it as a private `const
    LinearGradient` inside the pet hero widget; do **not** add a global token
    (STORY-001 owns the token set).
  - New `CupidIcons` entries must document the cmap-verified codepoint in the
    same style as the existing three constants.
  - `HomeScreen` must keep `Key('home_screen_ready_signal')`: the runtime
    registry `mobile-app` readiness probe depends on it.
  - No new `pubspec.yaml` dependency and no `assets:` section.

### Backend Lane Handoff

- Not participating. Any change request against `pets` is a scope escalation to
  Product Owner, not an implementation decision (A1 freeze).

### DevOps Lane Handoff

- Not participating.
- Requirement configuration guide update: NOT_APPLICABLE.

## 5. Non-Functional Impact

- Security / privacy: no new stored data; pet state is couple-scoped and read
  through the existing bearer-token pipeline. The unpaired gate is enforced
  server-side as well, so the client gate is UX, not the security boundary.
- Reliability / performance: two sequential requests on screen open
  (`/users/me`, `/pets/status`) and two per interact (D4), throttled by the 5s
  cooldown. Pairing state is cached for the screen's lifetime; only status is
  refetched.
- Observability: none beyond existing interceptor logging.
- Migration / rollout: additive feature; no flag required. `HomeScreen` keeps
  its current content, so a rollback is a revert of the preview-card mount.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|---|---|---|---|
| Regenerate `cupid_api` with `@ApiResponse` schemas | would give typed pets models | Rejected | requires a backend annotation change (A1 frozen) |
| Cast `Response<void>` to `Response<dynamic>` | avoids raw `Dio` calls | Rejected | relies on the generator's runtime type; brittle and undocumented |
| Recompute mood/decay client-side | saves one request per interact | Rejected | duplicates frozen backend rules; guaranteed drift |
| Distinguish unpaired via adopt `400` message text | avoids `/users/me` | Rejected | prose matching; both `400`s are indistinguishable structurally |
| Introduce the tab shell in this story | matches the design's `pet` nav tab | Deferred | `app_shell.dart` is shared across Epic-3/4 stories; a preview-card entry point satisfies reachability with a one-line shared-file edit |

## 7. Risks And Mitigations

| Risk | Impact | Mitigation |
|---|---|---|
| Untyped JSON parsing drifts from the backend row | Medium | repository is the only parsing site; unit tests pin every field name |
| Shared-file conflicts on `home_screen.dart`, `service_locator.dart`, `cupid_icons.dart` in a parallel wave | Medium | keep each edit to a single additive block; P8 touches `home_screen.dart` last |
| Guessed Material Symbols codepoints render tofu | Medium | codepoints read from the bundled TTF cmap; documented per constant |
| Hand-built sprite diverges from `Bun Sprite.dc.html` | Low | five states only, fixed 206/74/46 sizes, requirement-level mobile visual audit |
| Cooldown timer bypassed by backgrounding the app | Low | remaining cooldown is derived from `lastInteraction` on every load |

## 8. Handoff Notes

- Implementation guardrails: see Mobile Lane Handoff above; phase-level detail
  lives in `coding-plan/phase-P*.md`.
- Shared contract-first work required: YES — P1 (models + mood mapping) and P2
  (repository) gate every presentation phase.
- Shared coding plan required: YES — `coding-plan/master-plan.md`.
- Memory updates required: none by this story's write scope. Recommended for a
  later foundation pass: record "generated `cupid_api` REST calls without a
  declared response schema are typed `Response<void>`; read those bodies through
  the shared `Dio`" as an ADR-006 consequence, since STORY-003, STORY-004, and
  STORY-011 have each hit it.
- Open questions / blockers: none. Scope escalations to Product Owner (not
  blockers for this story): streak/badge system, per-species sprite art, and a
  real `pairedAt` field for a countdown-based adopt gate.
