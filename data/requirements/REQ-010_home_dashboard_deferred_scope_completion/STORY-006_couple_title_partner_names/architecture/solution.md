# STORY-006 Couple Title Shows Both Partner Names — Solution

## 0. Metadata

- Complexity: standard
- Date: 2026-08-25

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC1/AC2 need a partner display name on the Home
  dashboard header; AC3 forbids any fabricated placeholder when it is absent.
- Architectural invariants / non-goals:
  - `partnerDisplayName` is the single wire key for the partner's name. It is
    nullable and `null` is a first-class, silent state — never a placeholder,
    never an error surface.
  - `GET /users/me` stays one round trip. No second partner-profile call, no
    new endpoint, no new mobile repository.
  - The response shape of `GET /users/me` is not narrowed by this story.
- Proposed technical direction: lock the already-shipping `partnerDisplayName`
  key into the published `GET /users/me` contract (backend lane), then map and
  render it through the existing `CupidProfile` -> `_CoupleHero` ->
  `_PresenceRow` path (mobile lane).
- Why this fits the current system: both lanes already own every file that
  changes; no new module, boundary, or transport is introduced.

### Key Discovery

The story premise is stale against the code. `story_master.md` In-Scope item 1
and `ux/uiux-spec.md` §6.2 both state that `GET /users/me` exposes only the
caller's `displayName` plus an opaque `partnerId`. It does not:
`backend/src/modules/users/users.service.ts:30-40` (`getProfileWithPartner`)
already resolves the partner row and returns `partnerDisplayName`, the
controller already calls it (`users.controller.ts:14-19`), four unit tests
already cover paired / unpaired / dangling-`partnerId` / null-name
(`users.service.spec.ts:69-131`), and the value reaches the wire untouched
because no `ClassSerializerInterceptor` is registered anywhere in
`backend/src`. `AccountRepository.fetchProfile()` reads the raw JSON map, so
the key is already delivered to the mobile process today.

Two consequences the plan is built on:

1. The backend lane is **not** "build the partner-profile API". It is
   "publish and regression-lock a contract that currently exists only as an
   accidental byproduct of `return { ...user, partnerDisplayName }`". A future
   refactor swapping `getProfileWithPartner` back to `findByFirebaseUid` would
   silently blank the Home title with no failing test.
2. The mobile lane is **not** blocked on the backend lane — the data it needs
   is already on the wire at `BaseHead`. The two phases are genuinely
   parallel, not ordered. See `master-plan.md` §2.

The real gap is entirely mobile-side: `CupidProfile` (`cupid_profile.dart:22-37`)
never maps the key, so `_PresenceRow` has nothing to render.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md`

## 3. Scope And Assumptions

- In Scope: `GET /users/me` response documentation + controller regression
  lock; `CupidProfile.partnerDisplayName` mapping; `_PresenceRow` title
  composition, partner avatar initial, and title overflow handling.
- Out Of Scope: partner photo/avatar image, pairing state changes, profile
  editing, the header's share/notifications actions (STORY-004/STORY-005).
- Assumptions affecting design:
  - The partner's `displayName` is the only partner field the header needs;
    the avatar initial is derived client-side from it (`ux/uiux-spec.md` §6.5),
    so no new backend field is required.
  - The `&` glyph is literal in both `vi` and `en` (`ux/uiux-spec.md` §6.5) —
    no localization key is introduced.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `backend/src/modules/users` produces the value;
  `mobile/lib/features/account/domain` owns the read model; the Home header
  is the only consumer in this story.
- New or changed boundaries: none. The `GET /users/me` boundary gains a
  documented field, not a new shape.
- Shared patterns reused: the existing "resolve once per mount, hide when
  unavailable" posture of `_CoupleHeroHeader`, and the nullable-name fallback
  `_PresenceRow` already applies to `displayName` and `coupleTypeLabel`.

### Affected Modules

- Backend: `modules/users` (controller + response documentation + controller spec).
- Mobile: `features/account/domain` (read model), `features/home/presentation`
  (header rendering).

### Contracts And Integrations

- Error, retry, timeout, idempotency, and empty-state contract: a partner name
  that is absent, `null`, or empty is indistinguishable to the consumer and
  must render identically — self name alone, no `&`, no partner initial, no
  toast/banner/retry. A failed `GET /users/me` is already handled upstream by
  `_CoupleHeroHeader` hiding the whole header; this story adds no new failure
  path.
- Compatibility posture: additive and backward compatible in both directions.
  An older mobile build ignores the key; a newer build treats a missing key as
  `null` and degrades per AC3.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Undeclared `/users/me` partner key | `backend/src/modules/users/users.controller.ts` | Document the field on the endpoint and assert it in a controller-level spec so the delegation to `getProfileWithPartner` cannot be silently reverted | `users.controller.spec.ts` asserts `partnerDisplayName` is present in the `GET /users/me` result; `npm run build` passes | Report `BACKEND_VERIFY_REQUIRED` naming the failing spec |
| Response-shape narrowing | `backend/src/modules/users/users.controller.ts` | The response DTO is a Swagger schema type only — no `ClassSerializerInterceptor`, no `plainToInstance`, no `@Exclude` | Controller spec asserts the caller's existing keys (`id`, `displayName`, `partnerId`, `isGhostModeEnabled`) are still present alongside `partnerDisplayName` | Report `BACKEND_VERIFY_REQUIRED` |
| Fabricated partner name (AC3) | `ux/uiux-spec.md` §6.4 Degraded state | Title composition is a single pure expression whose null/empty branch returns the self name unchanged; partner initial is passed only when the name is non-empty | `home_screen_test.dart` cases for null, empty, and present partner names assert no `&` and no partner initial in the degraded cases | Report `MOBILE_VERIFY_REQUIRED` |
| Combined-title overflow in the header row | `ux/uiux-spec.md` §6.6 | Let the name/label column shrink (`Flexible`) and set the title `Text` to one line with `TextOverflow.ellipsis` | Widget test pumps a long combined name at the narrowest supported width and asserts no overflow exception | Report `MOBILE_VERIFY_REQUIRED` |

### Lane Handoff

#### Backend Lane

- Responsibilities: publish and regression-lock the `partnerDisplayName` key
  on `GET /users/me`.
- Authoritative inputs: `architecture/contract-summary.md`,
  `backend/src/modules/users/users.service.ts:30-40`.
- Guardrails:
  - Do not change `getProfileWithPartner`'s behavior or its existing specs —
    they already cover all four resolution cases.
  - Do not introduce serialization/transformation on this endpoint. The
    response DTO is documentation only; the runtime body must stay byte-identical.
  - Do not add a partner endpoint, a partner DTO for the mobile lane, or any
    additional partner field.

#### Mobile Lane

- Responsibilities: map the key into `CupidProfile` and render the combined
  title plus partner initial in `_PresenceRow`.
- Authoritative inputs: `architecture/contract-summary.md`,
  `ux/uiux-spec.md` §6.4-§6.6.
- Guardrails:
  - Do not change `_PresenceRow`'s existing `displayName`, `coupleTypeLabel`,
    or `isPaired` semantics, and do not touch `_Avatar`'s implementation —
    only what is passed to the partner instance.
  - Do not add a second network call, a cubit/bloc, or a new repository; the
    value arrives on the profile future the header already awaits.
  - Do not reuse `ChatPartnerStore` here — it is chat-scoped session state,
    not the header's source of truth.
  - Do not touch container sizing, spacing, colors, or type styles
    (`ux/uiux-spec.md` §6.7); only text content, the partner `initial`, and
    the overflow affordance from §6.6 change.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Map `partnerDisplayName` onto the existing `GET /users/me` profile future | Zero new transport; the value already ships on this response | ACCEPTED | Keeps the header at one round trip and one failure mode |
| Dedicated `GET /users/me/partner` endpoint (the story's original premise) | Assumed necessary by `story_master.md` In-Scope 1 | REJECTED | The premise is stale — the field already exists; a second endpoint adds a second failure/loading state for one string |
