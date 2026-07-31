# Solution: STORY-016 Epic-6 — Profile / Privacy / Notifications (mobile-only)

Mode: compact-story-plan
Scope: REQ-001 / STORY-016_profile_privacy_notifs
Story-Class: standard | Complexity: M | Lanes: mobile-dev only
Inputs verified: `story_master.md`, `story_brief.md`, `ux/uiux-spec.md`,
`backend/src/modules/users/**`, `backend/src/modules/uploads/**`,
`backend/src/modules/data-export/data-export.controller.ts`,
`mobile/openapi/cupid_api/**`, `mobile/lib/**`,
`data/architecture/system/system_architecture_memory.md`.

**Outcome: PARTIAL — AC1, AC2(view), AC4 are fully solutioned and
implementable. AC2(change) and AC3 are BLOCKED on missing backend contract.
Do not start implementation of AC3 before BLOCKER-1 is decided.**

## 1. Endpoint Mapping — Resolved (story_master open item, UX §7.1)

The `users` module exposes exactly three routes
(`backend/src/modules/users/users.controller.ts:14,21,28`), all guarded by
`AuthGuard('firebase-jwt')` on the controller:

| Route | Handler | Body | Returns |
|---|---|---|---|
| `GET /users/me` | `getProfile` | — | full `User` entity |
| `PATCH /users/me` | `updateProfile` | `UpdateProfileDto` | updated `User` |
| `POST /users/vow` | `markVowTaken` | — | updated `User` (out of this story's scope) |

`UpdateProfileDto` (`dto/update-profile.dto.ts`) accepts exactly:
`displayName`, `birthday`, `relationshipStartDate`, `zodiacSign`, `language`,
`photoUrl`, `coupleType`, `isGhostModeEnabled`. All optional.
`UsersService.updateProfile` is a blind `Object.assign` + `save`, so a partial
PATCH is safe and unsent fields are preserved.

Mapping each UX surface to the real contract:

| UX surface | Required capability | Contract resolution |
|---|---|---|
| §3 `me` hub, profile summary card (view) | read display name, avatar, DOB, zodiac | `GET /users/me` — **OK** |
| §3 profile edit: display name | write | `PATCH /users/me` `displayName` — **OK** |
| §3 profile edit: DOB + derived zodiac chip | write | `PATCH /users/me` `birthday` + `zodiacSign` — **OK** (see §4.3) |
| §3 profile edit: avatar picker | upload + persist | `POST /uploads` then `PATCH /users/me` `photoUrl` — **OK, with a caveat (RISK-1)** |
| §3 Language row (UX §7.4) | write | `language` **is** a persisted `users` field (`user.entity.ts:29`, default `'vi'`) — **contract OK**, ship decision is OQ5's (see §4.4) |
| §4 privacy 3-tier explainer (view) | static content | no endpoint needed — **OK** |
| §4 privacy "Controls" (change) | ≥1 editable privacy field | only `isGhostModeEnabled` exists — **BLOCKER-2** |
| §5 notification toggles (7 rows, 3 groups) | read + write notification prefs | **no endpoint, no entity field, no module anywhere** — **BLOCKER-1** |
| §4 "Export all my data" | request export | `POST /data-export` exists but AC4 excludes it — **carried conflict, PO decision (UX §7.3)** |

Generated-client note: `mobile/openapi/cupid_api/lib/src/api/epic1_users_api.dart`
types **all three** users routes as `Future<Response<void>>` because the NestJS
controller declares no `@ApiResponse` schema. The request side of `PATCH` is
typed (`UpdateProfileDto`); the response side of `GET` is not. See §4.1.

## 2. Blockers — Escalate To Scrum Master Before Implementation

### BLOCKER-1 (hard, AC3): notification settings have no backend contract

AC3 requires the user "view and change notification settings **exposed by the
backend contract**." Verified by search across `backend/src/` and the vendored
OpenAPI spec: there is **no** notifications/preferences module, **no**
notification field on the `User` entity, and **no** endpoint of any kind
backing the seven toggles in UX §5. A1 freezes the backend, so this cannot be
built as specified and must not be worked around silently.

Reinforcing evidence that a server-side preference store would be inert today:
system architecture memory §8 (R9) records that the backend performs **no FCM
dispatch at all** — every push site is a `console.log` stub and no device token
is ever stored. Server-stored notification preferences would therefore gate
nothing in v1.

Options for Scrum Master / Product Owner (Tech Lead recommendation: **A**):
- **A. Re-scope AC3 to device-local preferences.** Persist the toggles on-device
  (`hydrated_bloc`, per ADR-007's "small ephemeral state only" bound) and have
  them gate *client-side* notification presentation. Honest, shippable, and
  consistent with R9. AC3 wording must change from "exposed by the backend
  contract" to device-local, and the story must state that preferences do not
  sync across devices.
- **B. A1 escalation** to add a preferences endpoint to the frozen backend.
  Highest fidelity, but breaks the freeze and blocks this story on backend work.
- **C. Defer AC3** to a later story and ship STORY-016 as profile + privacy only.

### BLOCKER-2 (medium, AC2): only one editable privacy field exists, and it is another story's control

The single user-editable privacy-shaped field in the whole `users` contract is
`isGhostModeEnabled` (`user.entity.ts:41`, `update-profile.dto.ts:50`). UX §6
explicitly assigns the Typing Ghost control to the `ghostset` screen, which is
owned by STORY-008 (Epic-2 anti-ghosting). So AC2's "change" half is either
empty or a duplicate write-surface for another story's toggle — two screens
PATCHing the same field with no shared state owner invites drift.

Options for Scrum Master / Product Owner (Tech Lead recommendation: **A**):
- **A. Revise AC2 to view-only** for this story. The 3-tier explainer (UX §4)
  fully satisfies a view-only AC2 with zero invented fields, and Typing Ghost
  stays solely with STORY-008.
- **B. Surface `isGhostModeEnabled` here** as the one "Controls" row. Then
  STORY-008 and STORY-016 must share one repository/cubit for that field, and
  the shared owner must be named before either story implements it.

### Carried conflict (not resolved here, per UX §7.3): data-export button

`POST /data-export`, `GET /data-export`, and `GET /data-export/:id/download`
all exist and are authenticated (`data-export.controller.ts`). So the design
source's export button *is* technically buildable; it is excluded only by this
story's AC4 wording. This is a product-scope call, not a technical one. Tech
Lead position: **keep it excluded** (AC4 read literally) and correct system UX
memory §8, which currently asserts the opposite. PO must record the decision
either way.

## 3. Coding Plan Decision — No `coding-plan/master-plan.md`

**Not required for this story.** A shared master plan exists to sequence work
across multiple concurrent lanes (backend/frontend/mobile/devops). STORY-016 is
mobile-only, single lane, one new feature folder, no backend change (A1), no
devops change, and no shared-foundation file that another story consumes. The
phase breakdown in §5 below is sufficient and lives entirely in this document.
Mobile Developer should implement directly from this solution doc plus the UX
spec.

## 4. Architecture For The Implementable Scope

Feature-first placement per ADR-005 / ADR-009. New folder:
`mobile/lib/features/account/{data,domain,presentation}/`.
Cubit (not Bloc) per ADR-003 — these are CRUD/settings surfaces, not rituals or
realtime flows.

### 4.1 Data layer — the `Response<void>` read gap

`Epic1UsersApi.usersControllerGetProfile()` returns `Future<Response<void>>`,
so the profile body is unreachable through the generated method's static type.
There is an established precedent for exactly this situation:
`mobile/lib/features/auth/data/auth_repository.dart:99-112`
(`_syncBackendProfile`) reads the body via the shared `Dio` directly
(`_api.dio.post<Object?>('/auth/login')`) and documents why.

`AccountRepository` follows that precedent, and only that precedent — do not
hand-edit the generated client (system architecture memory §3):
- **Read**: `_api.dio.get<Object?>('/users/me')`, then map the raw JSON in a
  hand-written `CupidProfile.fromJson`.
- **Write**: use the generated
  `Epic1UsersApi.usersControllerUpdateProfile(updateProfileDto: ...)` — its
  *request* type is generated and correct, so the typed contract is preserved
  on the side that matters. Re-read via `GET /users/me` after a successful
  PATCH rather than trusting the untyped PATCH response.
- **Errors**: rethrow the mapped `CupidApiFailure` from `DioException.error`
  (set by `CupidErrorInterceptor`), never the raw `DioException` — same rule as
  `AuthRepository`.

### 4.2 Domain model

`domain/cupid_profile.dart`: hand-written immutable model over the `User`
entity fields actually returned: `id`, `email`, `displayName`, `photoUrl`,
`birthday`, `relationshipStartDate`, `zodiacSign`, `language`, `partnerId`,
`coupleType`, `vowTaken`, `isGhostModeEnabled`, `createdAt`, `updatedAt`.

**AC4 constraint — `role` is deliberately excluded.** `GET /users/me` returns
`role: 'user' | 'admin'` (`user.entity.ts:44`). Do not map it, do not store it,
and do not branch any widget on it. Reading it into the model is the most
likely accidental route to an admin-adjacent surface existing in this story's
scope, which AC4 forbids.

### 4.3 Zodiac derivation

`zodiacSign` is a plain writable string on both the entity and the DTO — the
backend derives nothing. UX §3 requires the chip to update live as DOB changes,
so derivation is **client-side**: a pure `zodiacSignFor(DateTime birthday)`
function in `domain/`, unit-tested at all twelve boundaries, whose output is
sent alongside `birthday` in the same PATCH. Never let the two fields diverge —
always send both or neither.

### 4.4 Language field

Contract-wise this is settled: `language` is a persisted `users` field and is
PATCH-able, so UX §7.4 is answered — it is **not** client-only. Whether the row
*ships* is a product call gated on OQ5 (light theme / EN i18n in v1), which is
still open in `req_master.md`. Tech Lead recommendation: **omit the row from
the v1 profile-edit form** until OQ5 resolves; the persisted default `'vi'` is
then simply left untouched, and adding the row later is a pure additive change
with no migration. No blocker either way.

### 4.5 Avatar flow

Two steps, and the first is outside the `users` module:
1. `POST /uploads` (multipart field name **`file`**, 10 MB limit, authed —
   `uploads.controller.ts:13-25`) returns `{ url, filename, originalName,
   mimeType, size }`.
2. `PATCH /users/me` with `photoUrl: <url from step 1>`.

Treat this as one user-visible operation with one failure surface: if step 2
fails, the uploaded file is orphaned server-side and the UI must show the
profile as unchanged rather than optimistically showing the new avatar.

**RISK-1 (verify before building the avatar flow).** `UploadsService`
constructs `http://${HOST}:${PORT}/uploads/<file>`, defaulting to
`http://localhost:3000/...` (`uploads.service.ts:10-14`), while
`UpdateProfileDto.photoUrl` is validated with `@IsUrl()`
(`update-profile.dto.ts:39`). class-validator's default `@IsUrl()` requires a
TLD, which bare `localhost` does not have — so in a default local environment
step 2 may reject the URL that step 1 just produced with a 400. Mobile
Developer must verify this end-to-end against a running backend **before**
building UI on top of it. If it does reject: this is an environment/config
issue (set `HOST` to a real hostname), **not** a client bug and **not**
something to work around by rewriting the URL client-side — escalate to Scrum
Master for a DevOps config fix.

### 4.6 Presentation and navigation

- `presentation/account_cubit.dart` — loads `CupidProfile` for the `me` hub.
- `presentation/profile_edit_cubit.dart` — holds the draft, exposes
  `isDirty` (drives UX §3's disabled-until-changed Save), validates
  (non-empty name, DOB required), submits the partial PATCH.
- Screens: `me_screen.dart`, `profile_edit_screen.dart`, `privacy_screen.dart`
  (static content only), and — only if BLOCKER-1 resolves to option A —
  `notification_settings_screen.dart`.
- Reuse existing design-system pieces; add no new atoms: `CupidHeader` for the
  drill-in chrome, `CupidPrimaryButton`, tokens from `design_system/tokens/`.
  Inline field errors must reuse STORY-003's pattern verbatim (UX §3).
- Sign-out placement only — `SignOutAction` / `SignOutConfirmDialog` already
  exist in `features/auth/presentation/`. Do not reimplement (UX preamble).
- DI: register `AccountRepository` as a lazy singleton in
  `core/di/service_locator.dart`, consistent with the existing registrations.
  Cubits are constructed per-screen, not registered as singletons.

**GAP-1 (navigation, needs a Scrum Master ownership call).** UX §1 places these
screens inside "the main 5-tab app shell," but that shell does not exist:
`mobile/lib/core/navigation/app_shell.dart:12` returns `const HomeScreen()`
with no tab bar and no router, and no story in `req_master.md` owns building
it. STORY-016 must **not** invent the 5-tab shell — that is cross-story
foundation work affecting every epic. Recommendation: build the four screens
plus their drill-in navigation self-contained, reachable from a single entry
point wired into whatever shell exists at merge time, and let Scrum Master
assign shell ownership separately. Flag if this makes AC1 unverifiable in-app.

## 5. Phases (single mobile-dev lane)

- **P0 — Contract preflight.** Verify RISK-1 against a running backend. Confirm
  BLOCKER-1 / BLOCKER-2 decisions are recorded before touching AC2-change/AC3.
- **P1 — Data + domain.** `CupidProfile`, `fromJson`, `zodiacSignFor`,
  `AccountRepository` (read via raw dio, write via generated client), DI
  registration. Unit tests: mapping, zodiac boundaries, partial-PATCH shape,
  failure mapping.
- **P2 — AC1 `me` hub + profile edit.** Both cubits, both screens, dirty-state
  Save, inline validation, avatar flow (gated on P0's RISK-1 result).
- **P3 — AC2 privacy (view half).** Static 3-tier screen, verbatim content per
  UX §4. No export button (AC4). No "Controls" card unless BLOCKER-2 → option B.
- **P4 — AC3 notification settings.** **Gated on BLOCKER-1.** If option A: build
  the grouped toggle list against device-local persistence. Keep the numeric cap
  banner copy; omit the DND-bypass clause entirely (UX §5, system UX memory §7,
  ADR-002/D1 — it is STORY-009's to resolve).
- **P5 — AC4 exclusion audit.** Assert absence: no Digital Divorce row, no
  export button, no admin surface, no `role` reference anywhere in
  `features/account/`.

## 6. Verification Contract

- Unit: `CupidProfile.fromJson` against a real `GET /users/me` payload shape;
  `zodiacSignFor` at all twelve sign boundaries; repository failure mapping
  yields `CupidApiFailure`, never a raw `DioException`.
- Cubit (`bloc_test`): dirty-state gating of Save; validation blocks submit;
  successful save re-reads and emits the updated profile; failed save leaves
  state unchanged and surfaces the failure.
- Widget/golden: profile-edit screen and privacy screen, per the STORY-001
  golden convention (system architecture memory §6/R5).
- Grep-level AC4 gate (P5): zero occurrences of `role`, `admin`, `divorce`, or
  `data-export` under `mobile/lib/features/account/`.
- Blocker gate: this story may not reach the review gate with AC3 silently
  unimplemented and no recorded BLOCKER-1 decision.

## 7. System Architecture Memory

No update proposed. Every pattern used here (feature-first, Cubit for CRUD,
generated client for REST, the documented `Response<void>` raw-dio workaround,
`get_it` DI) is already recorded in
`data/architecture/system/system_architecture_memory.md` §6/§7/§10. Nothing in
this story establishes a new cross-story convention.

Two items are worth a memory update **only after Scrum Master/PO rules on
them**, and neither is Tech Lead's to write unilaterally: (a) system UX memory
§8's data-export claim, which UX §7.3 shows conflicts with AC4; (b) if
BLOCKER-1 resolves to option A, "notification preferences are device-local in
v1" becomes a genuine cross-story fact worth recording alongside R9.

## 8. Completion

TECH_LEAD_COMPLETE: YES (with blockers)

Endpoint mapping is confirmed and the story's own open item is resolved. AC1,
AC2(view), and AC4 are fully solutioned. AC2(change) is blocked on BLOCKER-2
and AC3 is hard-blocked on BLOCKER-1 — both are product-scope decisions
requiring Scrum Master escalation to Product Owner, not technical unknowns.
GAP-1 (no app tab shell owner) and RISK-1 (`@IsUrl()` vs `localhost` upload
URL) need Scrum Master routing but do not block P1-P3.
