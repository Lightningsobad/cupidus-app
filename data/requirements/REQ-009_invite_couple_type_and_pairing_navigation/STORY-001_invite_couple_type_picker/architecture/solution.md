# STORY-001 Invite Couple-Type Picker — solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-24

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC4/AC5 require server-backed persistence and pre-fill,
  not local UI state; AC2/AC3 require single-select gating of an existing CTA
  slot; the screen is already reachable, so no navigation work is in scope.
- Architectural invariants / non-goals: the couple-type value crosses the wire
  as an existing backend enum literal and is never a free-form string; the
  invite code card's render path must not become dependent on the profile read;
  `design_system/` and `mobile/lib/l10n/**` stay out of write scope (UX §7).
- Proposed technical direction: extend the existing `InviteCubit`/`InviteReady`
  with `selectedCoupleType` + `isSaving`, seed it from
  `AccountRepository.fetchProfile()`, persist on Continue through the existing
  `AccountRepository.updateProfile(coupleType:)`, and render the 4-card grid as
  screen-local widgets in the `pairing` feature.
- Why this fits the current system: it reuses the seam style already used by
  `InviteScreen._defaultInviteCubit` and `OnboardingProgressResolver`
  (`getIt<AccountRepository>().fetchProfile`), and adds no new layer.

### Key Discovery

Investigating the code changed the shape of this story in three ways.

1. **The persistence contract already exists end to end — this is a
   mobile-only story.** `story_master.md` says `Implementation Lane: shared`,
   but nothing needs to be built outside `mobile/`:
   `CupidProfile.coupleType` (`mobile/lib/features/account/domain/cupid_profile.dart:19,35,50`)
   already parses it, `AccountRepository.updateProfile`
   (`mobile/lib/features/account/data/account_repository.dart:44,51,63`)
   already sends it, and the backend already validates it
   (`backend/src/modules/users/dto/update-profile.dto.ts:4-9,42-45`,
   column at `backend/src/modules/users/entities/user.entity.ts:36`). No
   backend, DTO, migration, or OpenAPI regeneration work is in this story.
2. **The wire enum is closed at 4 values and only 3 of them match the authored
   catalog.** `CoupleType` is `SAME_CITY | LONG_DISTANCE | LIVING_TOGETHER |
   DATING`, and `@IsEnum(CoupleType)` rejects anything else, so an arbitrary
   string is not an option. Card 4 ("Gắn bó lâu dài / Long-term") has no exact
   value; `LIVING_TOGETHER` is the only remaining slot and carries a narrower
   meaning (cohabiting). See section 6 — the drift is accepted, not overlooked.
3. **`InviteCubit` re-emits `InviteReady` every 30 seconds.** `_emitReady`
   is called from `_scheduleTick` (`invite_cubit.dart:81-98`) to refresh the
   countdown. A selection stored on `InviteReady` is silently discarded on the
   next tick unless `_emitReady` carries it forward. This is the single most
   likely defect in this story and has its own risk row and gate.

## 2. Downstream Contract Pointer

- Cross-lane contract: `architecture/contract-summary.md` (STORY-002 consumes
  the Continue submit seam and the wire-value mapping).

## 3. Scope And Assumptions

- In Scope: `mobile/lib/features/pairing/presentation/**` (couple-type catalog,
  `InviteCubit` state/actions, `InviteScreen` section + Continue CTA) and its
  tests; optional `main_preview.dart` fixture seed.
- Out Of Scope: `backend/**`, `mobile/openapi/**`, `mobile/lib/design_system/**`,
  `mobile/lib/l10n/**`, and the destination of Continue (STORY-002).
- Assumptions affecting design: the invite screen is reached only by an
  authenticated user, so `GET /users/me` is available; OQ5 (light theme / EN
  locale) is non-blocking per `story_master.md`.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/pairing/presentation`.
- New or changed boundaries: the `pairing` feature gains a read/write dependency
  on `AccountRepository`, injected as two function seams at the composition
  root (`InviteScreen._defaultInviteCubit`), not as a direct import of
  `account/data` from `pairing/presentation` widgets. The generated
  `UpdateProfileDtoCoupleTypeEnum` must not leak past that seam — the cubit and
  widgets speak the local domain enum only.
- Shared patterns reused: `_MoodCell`'s selected/unselected visual contract
  (`mobile/lib/features/vibes/presentation/widgets/vibe_mood_grid.dart:122`),
  the local-`IconData` precedent in `invite_screen.dart:47-58`, and
  `PairingLocaleText.viEn` for copy.

### Affected Modules

- Mobile: `features/pairing/presentation` (+ its test package); read-only
  dependency on `features/account/data` and `features/account/domain`.

### Contracts And Integrations

- Error, retry, idempotency, and empty-state contract: the profile read is
  best-effort — a failure degrades to "no pre-selection" and must never emit
  `InviteFailed`, because AC1-AC4 are fully usable without it. The Continue
  PATCH is user-triggered and not idempotent-by-retry from the user's point of
  view, so it is guarded by `isSaving` (CTA disabled while in flight) and, on
  failure, surfaces a `SnackBar` and returns the CTA to enabled with the
  selection intact. Unknown/legacy `coupleType` strings read back from the
  profile parse to `null` (no card pre-selected), never to a thrown error.
- Compatibility posture: every new `InviteCubit` constructor parameter is
  optional with a null default, because `main_preview.dart:859-866` builds the
  cubit with `generateInvitation` alone and is a compiled target.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Couple-type wire enum fidelity | `backend/src/modules/users/dto/update-profile.dto.ts:4-9` | One local enum with a single `wireValue` per case; the 4 string literals appear in exactly one file; unknown inbound value parses to `null` | Unit test asserting all 4 `wireValue`s and unknown/`null` → `null` | `flutter test` unavailable → stop, do not hand-verify |
| Countdown re-emit dropping selection | `mobile/lib/features/pairing/presentation/invite_cubit.dart:81-98` | `_emitReady` carries `selectedCoupleType` and `isSaving` forward from the current state | Cubit test: select a card, fire the injected `timerFactory` tick, assert the selection survives | `flutter test` unavailable → stop |
| Pre-fill on return (AC5) | `mobile/lib/features/account/data/account_repository.dart:30-37` | Profile read runs independently of `generateInvitation`; its failure yields `InviteReady` with a null selection | Cubit tests for both branches: seeded value pre-selects, thrown failure still reaches `InviteReady` | `flutter test` unavailable → stop |
| Continue gating and single-select (AC2/AC3) | `ux/ux-spec.md` §6.4, §6.5 | CTA `enabled: selectedCoupleType != null && !isSaving`; selection is a single nullable field, so two cards cannot be selected even transiently | Widget tests: 0 selected → disabled, tap → enabled, tap another → exactly one selected | `flutter test` unavailable → stop |
| Icon codepoint fidelity | Bundled `mobile/assets/fonts/MaterialSymbolsRounded-Variable.ttf` cmap | Codepoints read from that font's cmap with `fontTools`, never from memory (`cupid_icons.dart:7-11`); `flight_takeoff` reuses the already-confirmed `CupidIcons.flightTakeoff` (0xe905) | The fontTools cmap lookup output for `location_city`, `auto_awesome`, `all_inclusive` pasted into `coding-plan/test-results.md` before the constants are written | `fontTools`/python unavailable → stop with a blocker; do not guess a codepoint |
| Preview/build compatibility | `mobile/lib/main_preview.dart:859-866` | New cubit parameters are optional with null defaults | `flutter analyze` clean + `flutter build apk --debug` succeeds | Flutter SDK unresolvable → stop |

### Lane Handoff

#### Mobile Lane

- Responsibilities: the couple-type catalog, `InviteCubit` state/actions, the
  `InviteScreen` section and Continue CTA, and their unit/widget tests.
- Authoritative inputs: `requirements/requirements.md`
  `## Business Rules And Guardrails` (copy), `ux/ux-spec.md` §6.5/§6.7/§6.8
  (visual contract, glyph choices, measurable fidelity criteria), this section.
- Guardrails: do NOT add a fifth value to the backend `CoupleType` enum or edit
  anything under `backend/` or `mobile/openapi/`. Do NOT promote the new
  `IconData` constants into `mobile/lib/design_system/`. Do NOT make the new
  `InviteCubit` parameters required. Do NOT wire Continue to any navigation —
  STORY-002 owns the destination. Do NOT change `_copyAndAdvance`'s existing
  push to `WaitingScreen`.

## 5. Non-Functional Impact

- The invite screen now issues a `GET /users/me` on entry. It must be started
  concurrently with `generateInvitation`, never awaited before it, so the code
  card's time-to-render is unchanged.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Map card 4 "Gắn bó lâu dài / Long-term" onto the existing `LIVING_TOGETHER` value | The wire enum is closed at 4 values and every card needs one | ACCEPTED | Semantic drift is real (`LIVING_TOGETHER` reads as cohabiting) but has no user-visible consequence in this story, because displaying the couple-type anywhere is explicitly out of scope. Record it as REQ-009 follow-up: the moment couple-type is surfaced in the product, rename or extend the backend enum in a backend-lane story. |
| Add `LONG_TERM` to the backend `CoupleType` enum | Removes the drift at the source | REJECTED | Pulls `backend/`, the TypeORM column, and an OpenAPI regeneration into a story whose requirement scopes it as invite-screen UI + persistence semantics; it would change REQ-009's scope and its story sequencing for no in-story user-visible gain. |
