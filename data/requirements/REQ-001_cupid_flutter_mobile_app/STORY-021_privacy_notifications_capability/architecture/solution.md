# 021_privacy_notifications_capability-solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-12

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: AC2 needs a real write path for the one privacy field
  the frozen backend contract already exposes; AC3 needs a technical ruling on
  whether its "exposed by the backend contract" clause is satisfiable at all
  under A1.
- Architectural invariants / non-goals: A1 holds — no backend endpoint, DTO,
  entity, or module changes, and no OpenAPI regeneration. `features/chat/`
  (`ghost_settings_screen.dart`, `ghost_consent_store.dart`, `ghost_cubit.dart`)
  is not touched. `notification_settings_screen.dart` and its cubit/store are
  not touched.
- Proposed technical direction: AC2 ships as a mobile-only change — expose
  `isGhostModeEnabled` as a parameter on the existing
  `AccountRepository.updateProfile()`, and add the UX-specified
  `_PrivacyControlsSection` to `privacy_screen.dart` backed by its own
  `BlocProvider<AccountCubit>`. AC3 ships as an architecture finding plus a
  non-regression gate: no code change.
- Why this fits: both the wire contract and the state container already exist;
  this story only connects two halves that were never wired together.

### Key Discovery

1. **The write path is a one-parameter passthrough, not new integration.** The
   generated Dart client already models the field —
   `mobile/openapi/cupid_api/lib/src/model/update_profile_dto.dart:37,140`
   declares `isGhostModeEnabled`. `AccountRepository.updateProfile()`
   (`account_repository.dart:44-74`) simply never accepted or forwarded it. So
   the mobile lane adds one optional parameter and one `UpdateProfileDto` field
   assignment. No raw-Dio call (the `ghost_consent_store.dart:32-49` style) and
   no client regeneration are needed, which keeps A1 untouched.

2. **`PrivacyScreen` cannot see `MeScreen`'s cubit.** `MeScreen` creates
   `BlocProvider<AccountCubit>` at `me_screen.dart:40-41`, but pushes
   `const PrivacyScreen()` through `MaterialPageRoute(builder: (_) => ...)` at
   `me_screen.dart:121-125`. That builder resolves against the Navigator's
   context, above `MeScreen`, so the provider is out of scope on the pushed
   route. `PrivacyScreen` must own its own provider and take an injected
   `AccountRepository` — which in turn forces two one-line call-site updates
   (`me_screen.dart:123`, `main_preview.dart:363`) purely to keep compiling.

3. **The existing privacy test will stay green while becoming false.**
   `privacy_screen_test.dart:30-36` asserts `find.byType(Switch), findsNothing`.
   Because UX chose the custom `_TogglePill` shape over a Material `Switch`
   (`ux/uiux-spec.md` §1), that assertion still passes after the toggle ships,
   under a test named "renders no toggle and no export button". A green
   `flutter test` run is therefore not evidence for this story — the test must
   be rewritten deliberately, not merely observed to pass.

4. **AC3's clause has an empty referent (see §3, AC3 Feasibility Finding).**

## 3. Scope And Assumptions

- In Scope: `mobile/lib/features/account/` write path plus l10n keys; a
  documented AC3 feasibility finding.
- Out Of Scope: any backend change; `features/chat/` ghost surfaces;
  `notification_settings_screen.dart` behavior; unifying the two client writers
  of `isGhostModeEnabled`.
- Assumptions affecting design: `AccountCubit` calls `load()` from its own
  constructor (`account_cubit.dart:31-33`), so a fresh provider self-loads and
  needs no `..load()` cascade.

### AC3 Feasibility Finding (technical determination, resolves the story's Open Item)

Verified against current source, not inherited from the audit:

- `backend/src/modules/**/*.module.ts` contains 16 modules (`auth`, `users`,
  `invitations`, `uploads`, `alarms`, `vibes`, `messages`, `ghost-config`,
  `pets`, `admin`, `timeline`, `dream-jar`, `gallery`, `data-export`,
  `expenses`, `love-contracts`). None is a notification module.
- `backend/src/modules/users/entities/user.entity.ts` declares 13 columns; none
  is a notification preference. Its only user-writable behavior flag is
  `isGhostModeEnabled:41-42`, already claimed by AC2.
- The nearest candidate, `alarms` (`alarms.controller.ts:10-40`: `POST /alarms`,
  `GET /alarms`, `PATCH /alarms/:id/confirm`, `PATCH /alarms/:id/stop`), models
  alarm *instances*, not notification *preferences* — and D1 already removed
  real alarms from v1.
- A1 (`req_master.md:324`, "Thay đổi contract backend (A1: backend đóng băng,
  không đổi vì client)") forbids creating one.

**Determination:** the set of notification settings the backend contract
exposes is empty. AC3's clause "exposed by the backend contract" therefore has
no referent to target, and it cannot be given one without violating A1. The
only A1-compliant reading of "view and change notification settings" is the
device-local one, which the app already implements correctly and durably:
`NotificationSettingsScreen` → `NotificationSettingsCubit.setEnabled()`
(`notification_settings_cubit.dart:36-44`) → `NotificationPreferencesStore`
(`notification_preferences_store.dart:34-48`) → `SharedPreferences`, across 7
rows in 3 groups. AC3 closes as "mobile device-local settings, done correctly."

**No blocker is raised:** this story does not conclude that a new backend
module is required. Escalation trigger for later, not now — if the business
ever requires server-side or cross-device notification preferences (for example
server-driven push fan-out), that is an A1 exception and needs its own entry in
`req_master.md` § Open Question Triage / Approved Scope Change. It is out of
this story.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module: `mobile/lib/features/account/`.
- New or changed boundaries: `AccountRepository` becomes the single typed owner
  of `PATCH /users/me {isGhostModeEnabled}` for the account lane.
  `GhostConsentStore`'s raw-Dio write stays as-is in the chat lane; the two
  writers are deliberately left unreconciled (see risk table).
- Shared patterns reused: caller-side `getIt` resolution with constructor
  injection (`app_shell.dart:108`, `me_screen.dart:134`); `BlocProvider` +
  scoped `BlocBuilder`; `Semantics` + `ConstrainedBox(tapTarget)` from
  `ghost_settings_screen.dart`'s `_ToggleCard`.

### Affected Modules

- Mobile: `features/account/` (data + presentation), `l10n/arb`, `main_preview`.

### Contracts And Integrations

- Error / empty-state contract: on initial-load failure the toggle renders
  inert rather than defaulting to a guessed position — never offer a flip whose
  true state is unknown. On PATCH failure, roll back to the pre-tap position and
  surface a `SnackBar`; re-enable immediately, no backoff.
- Idempotency: taps are ignored (not queued) while a PATCH is in flight, so at
  most one write is outstanding per row.
- Compatibility posture: `updateProfile()` keeps its existing behavior of
  returning a refetched `CupidProfile` (`account_repository.dart:73`).
  `profile_edit_screen` depends on that. Consume the returned profile via
  `AccountCubit.applyUpdated()`; do not "optimize" the repository by removing
  its internal refetch.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Two client writers of `isGhostModeEnabled` | Server `User.isGhostModeEnabled` via `PATCH /users/me`; client-side `AccountLoaded.profile` | Privacy toggle writes only through typed `AccountRepository.updateProfile()`; it does not push into `ghost_cubit`/`ChatPartnerStore`, which re-read on their own lifecycle | Widget test asserts exactly one `updateProfile(isGhostModeEnabled: ...)` call per tap; `git diff` shows zero changes under `mobile/lib/features/chat/` | Generated `UpdateProfileDto` lacks the field — STOP, regeneration is outside A1 scope |
| AC3 device-local notification behavior | `NotificationPreferencesStore` + `SharedPreferences` | Zero write scope in the notification screen, cubit, or store | `notification_settings_screen_test.dart`, `notification_settings_cubit_test.dart`, `notification_preferences_store_test.dart` all pass **unmodified** | Any of the three needs editing to pass — the AC2 change leaked out of scope, STOP |
| AC4 no admin/data-export affordance | `privacy_screen_test.dart` export assertion | New section adds exactly one toggle row; no new nav item, CTA, or route | Rewritten privacy test keeps `find.textContaining('Export'), findsNothing` | None |
| Static tier cards must not hide behind a spinner | `ux/uiux-spec.md` §4 | `BlocProvider` at screen root; `BlocBuilder` scoped to the controls row only, never wrapping the `ListView` | Widget test pumps `AccountLoading` and asserts all three tier-card texts are already findable | None |
| Stale view-only invariant in source | `req_master.md` § Open Question Triage entry #5 (this ruling *is* the required new decision) | Rewrite `privacy_screen.dart:6-10`'s doc comment to cite STORY-021 instead of leaving a false "no toggle, no PATCH" invariant | Reviewer confirms the doc comment matches shipped behavior | None |

### Lane Handoff

#### Mobile Lane

- Responsibilities: the full AC2 implementation; confirming AC3 non-regression.
- Authoritative inputs: `ux/uiux-spec.md` §2-5 (placement, copy, states,
  accessibility) and this document.
- Guardrails:
  - Do not add, remove, or edit any file under `mobile/lib/features/chat/`.
  - Do not edit `notification_settings_screen.dart`, its cubit, its store, or
    their three test files. Duplicate the ~35-line `_TogglePill` as a private
    widget in `privacy_screen.dart`; do **not** promote it into
    `design_system/`, because promotion would force edits to the notification
    screen and its tests, breaking the AC3 non-regression gate.
  - Do not change the three `_TierCard` instances' props, content, order, or
    styling.
  - Do not change `updateProfile()`'s existing return contract or its other
    parameters.
  - Do not add an "Export all my data" or any admin affordance.

## 5. Non-Functional Impact

- Flutter is not on PATH on this machine; resolve it via
  `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter`
  (`runtime-command-registry.json` `mobile-app.sdk`) or `flutter` will appear
  missing and read as a false blocker.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| Add `isGhostModeEnabled` to typed `AccountRepository.updateProfile()` | Generated DTO already carries the field; keeps one typed owner per lane | ACCEPTED | One parameter + one assignment; no A1 impact |
| Reuse `GhostConsentStore.optIn()/optOut()` from the privacy screen | The write already exists and works | REJECTED | Pulls a chat-lane store with mutual-consent semantics into the account screen, and its raw-Dio call returns no profile, so `applyUpdated()` could not be fed |
