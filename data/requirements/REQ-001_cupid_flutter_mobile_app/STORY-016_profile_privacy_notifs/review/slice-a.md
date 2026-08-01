# STORY-016 Review — Slice A: account-data-domain

Reviewer: Iris-QC
RunId: RUN-REQ-001_cupid_flutter_mobile_app-STORY-016-reviewer-sliceA
BaseHead: 0a467d03babf1ed4102c3fab09c61b2dec941a0b
Worktree HEAD at review time: 9c61e81b2d45f452b44cadfda38726da34b50e57

Scope reviewed (diff against BaseHead only):
- mobile/lib/core/di/service_locator.dart
- mobile/lib/features/account/data/account_repository.dart
- mobile/lib/features/account/data/notification_preferences_store.dart
- mobile/lib/features/account/domain/cupid_profile.dart
- mobile/lib/features/account/domain/zodiac.dart
- mobile/lib/l10n/arb/app_en.arb
- mobile/lib/l10n/arb/app_vi.arb
- mobile/test/features/account/data/account_repository_test.dart
- mobile/test/features/account/data/notification_preferences_store_test.dart
- mobile/test/features/account/domain/cupid_profile_test.dart
- mobile/test/features/account/domain/zodiac_test.dart

AC context used (worktree copy of `story_master.md`, reworded): AC2 is
view-only privacy (no editable privacy control in this story; ghost-mode
toggle stays owned by STORY-008). AC3 notification preferences are
device-local only, no backend endpoint.

## 1. `AccountRepository` calls only `GET /users/me` / `PATCH /users/me`

**PASS**

- `fetchProfile()` (`mobile/lib/features/account/data/account_repository.dart:70-77`)
  issues a raw `_api.dio.get<Object?>('/users/me')` — path is the literal
  string `/users/me`, method GET.
- `updateProfile(...)` (`account_repository.dart:84-114`) calls
  `_api.getEpic1UsersApi().usersControllerUpdateProfile(updateProfileDto: dto)`
  then re-reads via `fetchProfile()`. Verified the generated method body at
  `mobile/openapi/cupid_api/lib/src/api/epic1_users_api.dart:136-192`: it
  hard-codes `_path = r'/users/me'` and `method: r'PATCH'`. No other
  `Epic1UsersApi` method (`usersControllerGetProfile`,
  `usersControllerMarkVowTaken` → `/users/vow`) is referenced anywhere in
  `account_repository.dart`.
- No other `users`-prefixed path string appears in the slice's data-layer
  files. Endpoint surface matches `story_master.md`'s "Backend module" note
  and the AC2/AC3 decision that no new `users` endpoint exists (A1 frozen).

## 2. `NotificationPreferencesStore` persists device-local only

**PASS**

- `mobile/lib/features/account/data/notification_preferences_store.dart`
  imports only `dart:convert` and `package:shared_preferences/shared_preferences.dart`
  (plus `../../../core/auth/cupid_session.dart` for the `SessionScopedStore`
  interface). No `Dio`, `CupidApi`, or any network-layer import.
- `load()`, `setEnabled()`, and `clearOnSignOut()` all read/write exclusively
  through `SharedPreferences` (`_preferences()` → `getString`/`setString`/
  `remove` on `_storageKey = 'cupid_notification_preferences_v1'`). No request
  object, DTO, or backend model is constructed or referenced.
- `clearOnSignOut()` correctly implements `SessionScopedStore`
  (`core/auth/cupid_session.dart:10-12`, pre-existing interface) and is wired
  into `CupidSession.registerScopedStore` in the DI update
  (`service_locator.dart:26-30`), matching the existing sign-out teardown
  pattern for every other `SharedPreferences`-backed scoped store.
- Confirms AC3 ("persisted device-local only... no backend endpoint, no
  cross-device sync in v1").

## 3. Both `.arb` files carry the same key set for new strings

**PASS**

Extracted all non-`@`-metadata keys from both files (whole-file parity, not
just the new keys) with a JSON key-set diff:

```
en only: []
vi only: []
en count 61  vi count 61
```

Every key added in this diff (`app_shell_account_entry_tooltip`, `me_*`,
`profile_edit_*`, `account_error_*`, `privacy_*`, `notifs_*` — 55 new keys)
appears in both `app_en.arb` and `app_vi.arb` with no orphan on either side.
`app_vi.arb` additionally carries `@`-prefixed description metadata for each
new key (existing repo convention); `app_en.arb` does not, consistent with
the pre-existing pattern already in the file for `common_actions_continue`.

## 4. No dead/unused code introduced

**PASS**

- `service_locator.dart`: both new imports (`account_repository.dart`,
  `notification_preferences_store.dart`) back a `registerLazySingleton` call
  each; both registrations are exercised by DI (consumption in
  cubit/presentation code is out of this slice's scope, reviewed
  separately).
- `account_repository.dart`: every import is used — `UpdateProfileDto`/
  `UpdateProfileDtoCoupleTypeEnum` (constructing the PATCH DTO), `Dio`
  (catching `DioException`), `CupidApi` (constructor field type), `CupidProfile`
  (return type). `UnexpectedFailure` and `HttpStatusFailure`-style failures
  come from the pre-existing `core/network/cupid_api_failure.dart` export
  chain (`core/network/cupid_api.dart` exports it) — not newly introduced,
  not dead.
- `notification_preferences_store.dart`: no unused fields; `_preferences`,
  `_storageKey`, and `defaults` are all read from `load`/`setEnabled`/
  `_decode`/`clearOnSignOut`.
- `cupid_profile.dart`, `zodiac.dart`: no imports; every declared field/param
  in `CupidProfile` is populated from JSON and referenced by the test file;
  `zodiacSignFor` has no unused locals.
- Test files exercise every public method added in this slice
  (`fetchProfile`, `updateProfile`, `load`, `setEnabled`, `clearOnSignOut`,
  `CupidProfile.fromJson`, `zodiacSignFor`) — no orphaned test helpers found
  (`_FakeAdapter`, `_jsonBody`, `_profileJson`, `_buildApi` are all called).

Deliberate, documented, non-dead omission: `CupidProfile` excludes the
backend `role` field by design (AC4 — admin-only field must not be reachable
from account UI), verified against the real-payload test case in
`cupid_profile_test.dart:828-845` which includes `role`/`firebaseUid` in the
input and asserts they don't leak into any exposed getter.

## Tooling note

`flutter` was not available on this review host/worktree PATH, so `flutter
analyze`/`flutter test` could not be independently re-run for this slice;
this review is static/source-level only. `story_master.md`'s Role Completion
section already records `flutter analyze` clean / `flutter test` green from
Mobile Developer for phases covering this slice's files
(P0/P1/P2/P4/P5/P6). No static-analysis smell (unused import/field, dead
method, endpoint drift) was found in the reviewed diff.

## Outcome

All four checked points: **PASS**. No FAIL or blocking UNVERIFIED found in
slice "account-data-domain".

REVIEW_SLICE_COMPLETE: YES
