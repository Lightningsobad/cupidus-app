# Master Coding Plan – STORY-016 Profile / Privacy / Notifications

## 1. Planning Metadata

- Story ID: REQ-001 / STORY-016_profile_privacy_notifs
- Complexity: M, Story-Class `standard`
- Planning Owner: Tech Lead (`Mode: coding-plan`, RunId
  `RUN-REQ-001_cupid_flutter_mobile_app-STORY-016-tech-lead`)
- Source Story: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-016_profile_privacy_notifs/story_master.md`
- Source Requirements (AC ruling):
  `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-016_profile_privacy_notifs/requirements/requirements.md`
- Source UX: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-016_profile_privacy_notifs/ux/uiux-spec.md` (§1–§6)
- Source Architecture: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-016_profile_privacy_notifs/architecture/solution.md`
- P0 preflight result: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-016_profile_privacy_notifs/coding-plan/p0-contract-preflight.md`
- OQ constraints still open: OQ5 (light theme / EN i18n in v1) — see §7 OQ-A

### Relationship to `architecture/solution.md` §3

solution.md §3 concluded no `master-plan.md` was needed (mobile-only, single
lane). That conclusion is superseded: `AGENTS.md` requires
`coding-plan/master-plan.md` for standard-class stories, and the P0 preflight
result plus four codebase findings in §2A below materially change the phase
list solution.md §5 proposed. This file is now the authoritative phase list;
solution.md remains authoritative for architecture (§4 layering, contracts,
model shape).

### Phase file layout

This run's declared `WriteScope` is exactly
`coding-plan/master-plan.md` (single file). Per the STORY-003 precedent, full
phase detail is therefore **inline in §6 of this file**, not in separate
`coding-plan/phase-P*.md` files. Each phase id below is defined exactly once.
Do not re-run Tech Lead to produce phase files — read §6 directly.

## 2. Planning Goal

- Shared contract owner: Tech Lead (`architecture/solution.md` §4)
- Contract-first phase required: YES — P1 produces `CupidProfile` +
  `AccountRepository`, which P2 and P3 consume. P1 must land before either.
- Parallel execution possible: NO across phases. This is a single mobile-dev
  lane, and P2/P4/P5 all write `mobile/lib/l10n/arb/app_{vi,en}.arb` and
  `mobile/lib/core/di/service_locator.dart`. Those shared write paths make
  concurrent phases a merge-conflict surface for zero throughput gain.
  P-DEVOPS is the one genuinely parallel item (different lane, different
  files, off the critical path).
- Critical path: `P1 -> P2 -> P4 -> P5 -> P6`
- Off critical path: `P-DEVOPS` (devops lane, may start immediately and run
  concurrently with all mobile phases) and `P3` (gated on P-DEVOPS; may land
  any time after P2 and before P6, or be deferred out of the story entirely
  per §4 DEC-1).

## 2A. Codebase Findings That Change The Plan

These four facts were verified in the worktree at BaseHead
`119b17d5b249dcc9fb0ead856a829cec3478b6f4` and each corrects or constrains
`architecture/solution.md`:

| # | Finding | Evidence | Consequence |
|---|---|---|---|
| F1 | `hydrated_bloc` is **not** a dependency; `shared_preferences: ^2.5.5` **is** | `mobile/pubspec.yaml:53` | AC3 device-local persistence uses `SharedPreferences` following the `PendingEventStore` precedent (`mobile/lib/core/realtime/pending_event_store.dart:16-24`), **not** `hydrated_bloc` as solution.md §2 option A suggested. No new dependency needed. |
| F2 | `image_picker` is **not** a dependency | `mobile/pubspec.yaml:30-53` | The avatar picker (UX §3) needs a new pubspec dependency. This is P3-only work, so it does not block P2. |
| F3 | `bloc_test` and `mocktail` are **not** dev-dependencies; every existing test uses bare `flutter_test` with hand-written fakes | `mobile/pubspec.yaml:55-64`, `mobile/test/features/auth/presentation/sign_out_cubit_test.dart` | solution.md §6's "Cubit (`bloc_test`)" is not achievable without adding a dependency. Cubit tests use hand-written fakes + `Cubit.stream` `expectLater`, matching the existing auth-cubit tests. |
| F4 | No golden test exists anywhere in `mobile/test/`; no `matchesGoldenFile` call | grep across `mobile/test/**` | solution.md §6's "widget/golden per the STORY-001 golden convention" has no live convention to follow. Use plain widget tests (`splash_screen_test.dart` / `adaptive_widgets_test.dart` pattern). Do not introduce goldens as a side effect of this story. |

Two further constraints that are not corrections but bind every UI phase:

- **ARB parity is an enforced gate.** `mobile/test/l10n/arb_parity_test.dart`
  fails if `app_vi.arb` and `app_en.arb` key sets diverge.
  `mobile/l10n.yaml` sets `arb-dir: lib/l10n/arb`, `template-arb-file:
  app_vi.arb`. Every new user-facing string in P2/P4/P5 must land in **both**
  ARB files in the same phase.
- **`CupidFeatureFlags` is the established exposure-gating pattern.**
  `mobile/lib/core/config/cupid_feature_flags.dart` uses
  `bool.fromEnvironment(...)` and gates *exposure only, never existence*. P3
  reuses this pattern rather than inventing a new gate.

## 3. Cross-Lane Contract Summary

Mobile is the only implementation lane. The one cross-lane item is P-DEVOPS.

**Mobile -> DevOps (P-DEVOPS request).** The avatar flow needs `POST /uploads`
to emit a `photoUrl` that `PATCH /users/me`'s `@IsUrl()` validator accepts.
Proven at BaseHead (`coding-plan/p0-contract-preflight.md`, class-validator
0.14.3):

```
http://localhost:3000/uploads/test.jpg   -> REJECTED (isUrl)
http://localhost/uploads/test.jpg        -> REJECTED (isUrl)
http://api.example.com/uploads/test.jpg  -> ACCEPTED
```

Required from DevOps: a `HOST` value that resolves to a TLD-bearing hostname
in local dev and in every deployed environment, such that
`UploadsService.getUpdloadUrl` (`backend/src/modules/uploads/uploads.service.ts:8-15`)
emits a URL in the accepted shape. Mobile consumes the resulting URL verbatim.

**Explicitly forbidden in every mobile phase:** rewriting, normalizing,
appending a TLD to, or client-side-validating the upload URL to make
`@IsUrl()` pass. Per solution.md §4.5 and the P0 preflight conclusion, this is
an environment/config defect, not a client defect. A client workaround would
mask a real deployment bug and is a review-gate failure condition.

## 4. Decisions Carried Into This Plan

- **DEC-1 (avatar / RISK-1).** No phase on the critical path depends on a live
  avatar save. P2 builds the profile-edit screen with the avatar rendered
  read-only from `photoUrl`. P3 adds the picker + upload + save, gated behind
  `CupidFeatureFlags.enableAvatarUpload` (default `false`) and covered only by
  fake-transport tests. If P-DEVOPS has not landed when P6 is reached, P3 stays
  flag-off and the story ships without a user-reachable avatar change. AC1
  ("view and edit their own profile") is still satisfied by display name + DOB
  + derived zodiac; record the avatar sub-capability as a known limitation for
  the review gate rather than blocking the story.
- **DEC-2 (AC3 scope).** Re-verified against
  `requirements/requirements.md` §"Decision: BLOCKER-1 — Option A adopted".
  AC3 is **device-local only**, explicitly "no backend endpoint, no
  cross-device sync in v1", gating "client-side notification presentation
  only". This is unambiguous and does not contradict solution.md, whose §2
  BLOCKER-1 option A is the same ruling. **No open question.** P5 must add no
  network call of any kind.
- **DEC-3 (AC2 scope).** Re-verified against `requirements/requirements.md`
  §"Decision: BLOCKER-2 — Option A adopted". AC2 is **view-only**, static
  read-only content, and explicitly "does not add or own any editable privacy
  control"; `isGhostModeEnabled` stays solely with STORY-008. This is
  unambiguous and matches solution.md §2 BLOCKER-2 option A. **No open
  question.** P4 must add no toggle, no PATCH, and no "Controls" card — UX §4's
  conditional 4th-card structure is explicitly not built.
- **DEC-4 (GAP-1, app shell).** Unchanged and still open at BaseHead:
  `mobile/lib/core/navigation/app_shell.dart:12` returns `const HomeScreen()`
  with no tab bar. `CupidTabBar` exists in `mobile/lib/design_system/adaptive/`
  but nothing consumes it. This story does **not** build the 5-tab shell. P2
  wires a single entry point into `AppShell` so the screens are reachable and
  AC1 is demonstrable; shell ownership stays a Scrum Master routing item.
- **DEC-5 (data export).** AC4 read literally: no export button, per
  `requirements/requirements.md` §Unchanged. The system UX memory §8
  correction is out of this story's scope and non-blocking.
- **DEC-6 (DND banner copy).** P5 ships the numeric cap copy only. The "Only
  Synced Alarm may break DND" clause is omitted entirely (UX §5, system UX
  memory §7, STORY-009's to resolve).

## 5. Lane Summary

- Backend required: NO (A1 frozen, read-only reference)
- Frontend required: NO
- Mobile required: YES (P1–P6)
- DevOps required: YES (P-DEVOPS only — `HOST` configuration)
- Initial implementation owner: Mobile Developer (P1)
- Final verification owner: Mobile Developer (P6)
- Shared contract owner: Tech Lead (`architecture/solution.md` §4)
- Impacted runtime services/apps:
  - `mobile-app`: mobile lane, startup smoke per the P6 gate
    (`flutter analyze`, `flutter test`, `flutter build apk --debug`),
    command source `data/devops/system/runtime-command-registry.json` ->
    `mobile-app`
  - `backend`: **not modified**. P-DEVOPS changes environment configuration
    only, no source change.

## 6. Phases

### 6.1 Phase Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Planned Outputs | Test Scope | Status |
|---|---|---|---|---|---|---|---|---|
| P0 | Mobile | mobile | — | — | `coding-plan/p0-contract-preflight.md` | RISK-1 verification result | n/a | COMPLETE (at BaseHead) |
| P-DEVOPS | DevOps | devops | — | yes (with all mobile phases) | `backend/.env.example`, `docker-compose.yml`, `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` | `HOST` resolves to a TLD-bearing hostname in local + deployed envs | Manual: `POST /uploads` -> `PATCH /users/me` returns 200 | NOT_STARTED |
| P1 | Mobile | mobile | — | no | `mobile/lib/features/account/domain/**`, `mobile/lib/features/account/data/**`, `mobile/lib/core/di/service_locator.dart`, `mobile/test/features/account/**` | `CupidProfile`, `zodiacSignFor`, `AccountRepository`, DI registration | Unit: JSON mapping, 12 zodiac boundaries, partial-PATCH shape, failure mapping | COMPLETE |
| P2 | Mobile | mobile | P1 | no | `mobile/lib/features/account/presentation/**`, `mobile/lib/l10n/arb/app_{vi,en}.arb`, `mobile/lib/core/navigation/app_shell.dart`, `mobile/test/features/account/**` | `AccountCubit`, `ProfileEditCubit`, `me_screen.dart`, `profile_edit_screen.dart`, entry-point wiring | Unit: dirty-gating, validation; widget: hub renders, edit screen renders | COMPLETE |
| P3 | Mobile | mobile | P2, P-DEVOPS | no | `mobile/pubspec.yaml`, `mobile/lib/features/account/data/**`, `mobile/lib/features/account/presentation/profile_edit_*`, `mobile/lib/core/config/cupid_feature_flags.dart`, `mobile/test/features/account/**` | `image_picker` dep, upload+save path, `enableAvatarUpload` flag | Unit: two-step failure leaves profile unchanged (fake transport) | NOT_STARTED |
| P4 | Mobile | mobile | P2 | no | `mobile/lib/features/account/presentation/screens/privacy_screen.dart`, `mobile/lib/l10n/arb/app_{vi,en}.arb`, `mobile/test/features/account/**` | Static 3-tier privacy screen | Widget: three tier cards render; no toggle, no export button | NOT_STARTED |
| P5 | Mobile | mobile | P2 | no | `mobile/lib/features/account/data/notification_preferences_store.dart`, `mobile/lib/features/account/presentation/**`, `mobile/lib/l10n/arb/app_{vi,en}.arb`, `mobile/lib/core/di/service_locator.dart`, `mobile/test/features/account/**` | Device-local prefs store, `NotificationSettingsCubit`, `notification_settings_screen.dart` | Unit: persistence round-trip, defaults, clear-on-sign-out; widget: 7 rows in 3 groups | NOT_STARTED |
| P6 | Mobile | mobile | P1, P2, P4, P5 | no | `mobile/test/features/account/**` | AC1–AC4 verification + exclusion audit | `flutter analyze` clean, `flutter test` green, `flutter build apk --debug`, AC4 grep gate | NOT_STARTED |

Phase sizing: each phase is at or under six source/test files.

### 6.2 Phase Detail

#### P0 — Contract preflight (COMPLETE at BaseHead)

Result: RISK-1 **REPRODUCED**. See
`coding-plan/p0-contract-preflight.md` for the full probe and exact outputs.
Do not re-run. Its single actionable output is P-DEVOPS and DEC-1.

#### P-DEVOPS — `HOST` configuration (DevOps lane, non-blocking)

Inputs: `coding-plan/p0-contract-preflight.md` (accepted/rejected URL shapes),
`backend/src/modules/uploads/uploads.service.ts:8-15`,
`backend/src/modules/users/dto/update-profile.dto.ts:37-40`.

Work: choose and document a `HOST` value that produces a TLD-bearing upload
URL in local dev and in each deployed environment, and record it in the
requirement configuration guide. Backend source stays frozen (A1) — this is
configuration only.

Explicitly **not** in scope for this phase: relaxing `@IsUrl()` options on the
DTO. That is a backend source change under the A1 freeze and requires its own
escalation; do not do it as a shortcut.

Done when: a documented `HOST` value exists and `POST /uploads` followed by
`PATCH /users/me { photoUrl: <that url> }` returns 200.

Note for Scrum Master: P-DEVOPS may be routed as a separate story/task rather
than a phase of STORY-016. Nothing on this story's critical path waits on it.

#### P1 — Data + domain

Per solution.md §4.1/§4.2/§4.3.

- `domain/cupid_profile.dart` — immutable model over the `User` fields
  actually returned. **Do not map `role`** (solution.md §4.2, AC4).
- `domain/zodiac.dart` — pure `zodiacSignFor(DateTime birthday)`.
- `data/account_repository.dart` — read via `_api.dio.get<Object?>('/users/me')`
  following the documented precedent at
  `mobile/lib/features/auth/data/auth_repository.dart:99-112`; write via the
  generated `Epic1UsersApi.usersControllerUpdateProfile`; re-read after PATCH.
  Rethrow the mapped `CupidApiFailure`, never a raw `DioException`. Do not
  hand-edit the generated client.
- Register `AccountRepository` as a lazy singleton in
  `mobile/lib/core/di/service_locator.dart`.

Tests (bare `flutter_test`, hand-written fakes per F3): `fromJson` against a
real `GET /users/me` payload shape; `zodiacSignFor` at all twelve boundaries;
PATCH body contains only changed fields; error path yields `CupidApiFailure`.

#### P2 — AC1 `me` hub + profile edit (no avatar save)

Per UX §3, solution.md §4.6.

- `presentation/account_cubit.dart` — loads `CupidProfile` for the hub.
- `presentation/profile_edit_cubit.dart` — draft state, `isDirty`, validation
  (name non-empty, DOB required), partial PATCH submit.
- `presentation/screens/me_screen.dart` — profile summary card + settings menu
  rows. **Omit the Digital Divorce row entirely** (UX §6). Keep "Typing Ghost"
  and "Love Contract" as forward links only. Place the existing
  `SignOutAction` — do not reimplement sign-out.
- `presentation/screens/profile_edit_screen.dart` — editable name field,
  DOB picker, live-updating zodiac chip. Avatar renders from `photoUrl`
  read-only in this phase; the camera badge is either absent or inert until
  P3. Send `birthday` and `zodiacSign` together or not at all (solution.md
  §4.3).
- Reuse `CupidHeader`, `CupidPrimaryButton`, and `design_system/tokens/**`.
  Add no new design-system atoms. Reuse STORY-003's inline field-error pattern
  verbatim.
- Omit the Language row (solution.md §4.4, OQ5 still open — see §7 OQ-A).
- Wire one entry point into `mobile/lib/core/navigation/app_shell.dart` so the
  hub is reachable. Do **not** build the 5-tab shell (DEC-4).
- Add every new string to both ARB files.

#### P3 — Avatar flow (gated; off critical path)

Do not start before P-DEVOPS reports a working `HOST`, per DEC-1.

- Add `image_picker` to `mobile/pubspec.yaml` (F2).
- Add `enableAvatarUpload` to `CupidFeatureFlags` via `bool.fromEnvironment`,
  `defaultValue: false`, matching the existing exposure-gating pattern.
- Implement `POST /uploads` (multipart field name **`file`**, 10 MB limit) then
  `PATCH /users/me { photoUrl }` as one user-visible operation. If step 2
  fails, show the profile unchanged — never optimistically show the new avatar
  (solution.md §4.5).
- Tests use a fake transport only. No test may depend on a live backend.
- Forbidden: any client-side rewrite/normalization/validation of the returned
  upload URL (§3).

#### P4 — AC2 privacy, view-only

Per UX §4 and DEC-3.

- `presentation/screens/privacy_screen.dart` — the three tier cards verbatim
  as static informational content.
- No "Controls" card. No toggle. No PATCH. No `isGhostModeEnabled` reference.
- No "Export all my data" button (DEC-5).
- Both ARB files updated.

#### P5 — AC3 notification settings, device-local

Per UX §5 and DEC-2.

- `data/notification_preferences_store.dart` — `SharedPreferences`-backed,
  following `mobile/lib/core/realtime/pending_event_store.dart:16-24`
  (inject `Future<SharedPreferences> Function()` so tests can substitute).
  Implement `SessionScopedStore` (`mobile/lib/core/auth/cupid_session.dart:10`)
  and clear on sign-out — see §7 OQ-B for the one judgement call here.
- `presentation/notification_settings_cubit.dart` and
  `presentation/screens/notification_settings_screen.dart` — 7 toggle rows in
  3 groups (CRITICAL 2, ENGAGEMENT 3, INFO 2), banner with the numeric cap
  copy only (DEC-6).
- **No network call of any kind in this phase.** Any HTTP in the notification
  path is an AC3 violation.
- Register the store in `service_locator.dart`; both ARB files updated.

#### P6 — AC4 exclusion audit + verification

- Grep gate: zero occurrences of `role`, `admin`, `divorce`, or `data-export`
  under `mobile/lib/features/account/`.
- Assert absence in-screen: no Digital Divorce row, no export button, no admin
  surface.
- `flutter analyze` clean, `flutter test` green (including
  `test/l10n/arb_parity_test.dart`), `flutter build apk --debug` succeeds.
- Record the avatar limitation for the review gate if P3 did not land or
  shipped flag-off (DEC-1).

## 7. Open Questions

Both AC scope questions raised in the handoff were re-verified against
`requirements/requirements.md` and are **closed** — see DEC-2 (AC3 is
unambiguously device-local-only) and DEC-3 (AC2 is unambiguously view-only).
Neither contradicts `architecture/solution.md`. The two items below are
genuinely open.

- **OQ-A (carried, non-blocking): Language row.** solution.md §4.4 confirms
  `language` is a real PATCH-able `users` field, but whether the row ships is
  gated on OQ5 (light theme / EN i18n in v1), still open in `req_master.md`.
  Plan assumes **omitted** from the v1 profile-edit form. Adding it later is
  purely additive with no migration. Owner: Product Owner via OQ5. Does not
  block any phase.
- **OQ-B (new, P5-scoped): should device-local notification preferences clear
  on sign-out?** Every existing `SharedPreferences` consumer in this codebase
  (`PendingEventStore`, `BackendUserIdStore`) implements `SessionScopedStore`
  and clears on sign-out, which is the right default on a potentially shared
  device — otherwise a second user inherits the first user's preferences.
  The cost is that preferences are lost on every ordinary sign-out/sign-in
  cycle, which users may read as a bug. P5 above assumes **clear on sign-out**
  for codebase consistency and shared-device safety. If Reviewer or PO prefers
  persistence across sign-out, the alternative is keying preferences by backend
  user id via the existing `BackendUserIdStore` — a small change confined to
  P5. Flagging rather than silently choosing, because it is user-visible
  behavior not specified by any AC or by UX §5.

## 8. Result Log

(Dated notes appended here as each phase completes.)

- **2026-07-31, P1 (re-verified, no fix commit).** Mobile Developer
  independently reran the P1 test scope and `flutter analyze` against
  `domain/cupid_profile.dart`, `domain/zodiac.dart`,
  `data/account_repository.dart`, and the `service_locator.dart` DI
  registration. 43/43 pre-existing P1 tests passed, `flutter analyze lib test`
  was clean aside from pre-existing unrelated info lints. No changes needed;
  no commit made for P1.
- **2026-07-31, P2 (complete).** Implemented `AccountCubit`,
  `ProfileEditCubit`, `me_screen.dart`, `profile_edit_screen.dart`, wired the
  single `AppShell` entry point (DEC-4), added the 18 new strings to both ARB
  files, and added unit tests (dirty-gating, validation, partial-PATCH
  coupling of `birthday`/`zodiacSign`) plus widget tests (hub loading/loaded/
  failed states, edit-screen field population, Save dirty-gating, inline
  validation error). `authRepository` is optional on `MeScreen` and
  `AppShell` supplies none, since no concrete `FirebaseSignInGateway` exists
  yet (`firebase_sign_in_gateway.dart` dartdoc); `SignOutAction` is placed
  unmodified only when a repository is supplied. `flutter analyze lib test`
  and `flutter test test/features/account test/l10n` both pass with zero
  issues introduced by this phase.
