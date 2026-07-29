# 003_auth-solution.md

## 0. Metadata

- User Story ID: REQ-001 / STORY-003_auth
- User Story Path: `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-003_auth/story_master.md`
- Complexity: M (Story-Class `standard`)
- Referenced Inputs: `story_master.md`; `ux/uiux-spec.md` (§3, §4, §5, §9); `req_master.md` (D0-D5 row table, R8/A1); `STORY-002/architecture/solution.md` §2 Downstream Contract Summary + Interceptor Pipeline Contract; `system_architecture_memory.md` §7 (ADR-006..009), §8 (R8 row), §9 (F3), §10 (auth verification contract); `mobile/openapi/cupid-api.json` (`/auth/login`, `/auth/register`, `firebase-jwt` security scheme); `backend/src/modules/auth/auth.controller.ts`; `backend/src/modules/auth/firebase-auth.strategy.ts:16`; `backend/src/modules/messages/chat.gateway.ts:40`; `mobile/lib/core/network/cupid_interceptor_slots.dart`; `mobile/lib/core/network/cupid_auth_token_provider.dart`; `mobile/lib/core/network/cupid_api_client.dart`; `mobile/pubspec.yaml`
- System Architecture Memory Path: `data/architecture/system/system_architecture_memory.md`
- Solution Number: 003
- Version: v1.0
- Date: 2026-07-29
- Status: Final

## 1. Decision Summary

- Mode: Brownfield (STORY-002 already installed the `auth` slot, the token-provider interface, and the failure hierarchy; this story only fills them)
- Branch Action: Scan architecture — the plug points exist and are contract-frozen; the open question was the refresh *mechanism*, resolved from the backend contract below.
- **Governing discovery (changes the story's shape): the backend exposes no refresh endpoint and no token-exchange endpoint.** `firebase-jwt` is a bearer scheme over a Firebase **ID token**, verified server-side by `admin.auth().verifyIdToken(token, true)` (`backend/src/modules/auth/firebase-auth.strategy.ts:16`). The whole spec contains exactly two auth paths, `POST /auth/login` and `POST /auth/register`, and **both are themselves guarded by `firebase-jwt`** — they are backend profile-provisioning calls made *after* a Firebase sign-in, not credential exchange. Therefore "refresh token" in this story is not an HTTP call the client makes; it is `User.getIdToken(forceRefresh: true)` inside the Firebase SDK, which redeems the SDK-held refresh token against Google's identity service. AC2 is satisfiable with zero backend interaction and therefore fully inside A1.
- Architecture Drivers: A1 (backend frozen), AC2 (transparent refresh), AC3 (cold-start persistence), AC4 (sign-out clears cached authenticated data), R8 (Socket.IO forward-compat), D2 (Bloc), ADR-010f (no codegen deps yet).
- Invariants: (a) the Firebase ID token is never written to app-owned storage, logs, or Drift; (b) exactly one interceptor occupies `CupidInterceptorSlot.auth` and it performs at most one retry per request; (c) `firebase_auth` is the single source of session truth — no parallel hand-rolled session cache; (d) exactly one refresh is in flight at a time regardless of concurrent 401s.
- Non-goals: OTP screen implementation (downstream of this story per UX §2), biometric app-lock implementation (ADR-011f), Socket.IO wiring (STORY-004), Drift (F5), `injectable`/`freezed`.
- Technical direction: `firebase_core` + `firebase_auth` supply the session; a `FirebaseIdTokenProvider` implements STORY-002's `CupidAuthTokenProvider`; a `CupidAuthInterceptor` replaces `PassthroughInterceptor` in the `auth` slot with bearer-attach + single-flight refresh-and-retry-once on 401; a `CupidSession` façade exposes the token and a token stream for R8 and drives the splash gate.

## 2. Downstream Contract Summary

Authoritative for STORY-004 and every later authenticated story.

- `CupidSession` (`package:cupid_mobile/core/auth/cupid_auth.dart`, the single public surface — feature code must not import `package:firebase_auth/...` directly):
  - `Stream<CupidSessionState> get state` — `sealed class CupidSessionState { Unknown | SignedOut | SignedIn(uid, email) }`. Drives the splash gate (UX §3) and the forced-re-auth route (UX §4b).
  - `Future<String?> idToken({bool forceRefresh = false})` — **the R8 contract.** STORY-004 calls this to populate `handshake.auth.token`. It never issues an HTTP request of its own.
  - `Stream<String?> get idTokenStream` — emits on every token rotation (backed by `FirebaseAuth.idTokenChanges()`). **STORY-004 must subscribe and re-handshake on emit:** Socket.IO evaluates `handshake.auth` once per connection, while an ID token lives ~1 hour, so a long-lived socket otherwise holds a stale credential. This stream is the entire reason STORY-004 does not need to re-derive auth logic.
  - `Future<void> signOut()` — Firebase sign-out, then ordered `SessionScopedStore.clearOnSignOut()` teardown (AC4).
- `abstract interface class SessionScopedStore { Future<void> clearOnSignOut(); }` — registration hook for any store holding authenticated data. STORY-003 registers none beyond in-memory Bloc disposal; F5/Drift and STORY-013/gallery register theirs here rather than adding a second sign-out path. This exists because UX §5's confirm copy explicitly promises device data is cleared.
- `AuthRepository` — `signInWithEmail`, `registerWithEmail`, `signInWithGoogle`, `signInWithApple` (iOS), `signInWithFacebook` (Material), `sendEmailVerification`, `sendPasswordResetEmail`, `reloadEmailVerified`. Each social/email sign-in completes Firebase first, then calls `POST /auth/login` (falling back to `POST /auth/register` on the documented 404 `User not registered`) through the generated client so the backend profile row exists.
- STORY-002 contract consumed unchanged: `CupidApiClient.create(slotOverrides: {CupidInterceptorSlot.auth: CupidAuthInterceptor(...)})`. Slot order, slot names, and `mobile/openapi/**` are untouched.
- Failure contract: reuse STORY-002's `sealed class CupidApiFailure`. Add nothing to it. Firebase-origin errors surface as a separate `sealed class CupidAuthFailure` (`InvalidCredentialFailure`, `EmailAlreadyInUseFailure`, `WeakPasswordFailure`, `SessionExpiredFailure`, `AuthNetworkFailure`, `UnexpectedAuthFailure`) so UX §6's inline field errors map from one closed set and raw `FirebaseAuthException` codes never reach the UI.
- DevOps / environment contract: new platform config files `mobile/android/app/google-services.json` and `mobile/ios/Runner/GoogleService-Info.plist`, plus the generated `mobile/lib/firebase_options.dart`. **These are project-identifying config, not secrets, but they are environment-specific — `deployment/configuration-guide.md` becomes REQUIRED for this story** (STORY-002 left it NOT_REQUIRED). No new `--dart-define` key.
- Data model / migration contract: none.

## 3. Scope And Assumptions

- In Scope: Firebase initialization, email/password + social sign-in, register, password reset, the `auth` slot interceptor, session persistence and the splash gate, sign-out with teardown hook, the R8 token/stream contract.
- Out Of Scope: the `otp` screen implementation (ADR-011e resolves its *mechanism* only), biometric app-lock (ADR-011f), socket wiring, Drift, `injectable`, `freezed`.
- Assumptions: (a) a Firebase project matching the backend's service account is available and `flutterfire configure` can be run — if not, this is a Scrum Master/DevOps blocker, not a reason to stub auth; (b) the backend's Firebase project and the app's are the same project, otherwise `verifyIdToken` rejects every token — this must be confirmed against `backend/service-account.json`'s `project_id` before Phase P2 is considered green.

## 4. Architecture Delta

### Boundaries And Ownership

- `mobile/lib/core/auth/` is the only place allowed to import `package:firebase_auth/...`, `package:google_sign_in/...`, `package:sign_in_with_apple/...`, or `package:flutter_facebook_auth/...`.
- `mobile/lib/core/network/` stays STORY-002's; this story edits exactly one file in it (`cupid_interceptor_slots.dart`, diagnostics redaction per ADR-011d) and adds none.
- `mobile/lib/features/auth/` holds the presentation lane (Cubits + the `welcome`/`login`/`register`/`forgot`/`splash` screens), per ADR-009 feature-first layout.
- Contract owner: Tech Lead for every §2 name. Mobile Developer may not rename them without a new architecture pass.

### Affected Components And Layers

- `mobile/pubspec.yaml` — adds `firebase_core`, `firebase_auth`, `google_sign_in`, `sign_in_with_apple`, `flutter_facebook_auth`, `flutter_bloc`, `get_it`.
- `mobile/lib/firebase_options.dart` + platform config files — generated by `flutterfire configure`; treated like STORY-002's generated package (machine output, never hand-edited).
- `mobile/lib/core/auth/cupid_session.dart` — `CupidSession`, `CupidSessionState`, `SessionScopedStore`.
- `mobile/lib/core/auth/firebase_id_token_provider.dart` — implements `CupidAuthTokenProvider`.
- `mobile/lib/core/auth/cupid_auth_interceptor.dart` — the `auth` slot occupant.
- `mobile/lib/core/auth/cupid_auth_failure.dart` — the sealed Firebase-origin failure set.
- `mobile/lib/core/auth/cupid_auth.dart` — barrel; the only public surface.
- `mobile/lib/core/di/service_locator.dart` — `get_it` registrations (ADR-011g).
- `mobile/lib/features/auth/data/auth_repository.dart`, `presentation/{sign_in_cubit,register_cubit,session_gate_cubit}.dart`, `presentation/screens/*.dart`.
- `mobile/lib/core/network/cupid_interceptor_slots.dart` — diagnostics redaction only (ADR-011d).

### ADR-011 — Firebase session, refresh, and token exposure

#### ADR-011a — Refresh is a Firebase SDK force-refresh, not an HTTP call

`CupidAuthTokenProvider.readAccessToken()` maps to `currentUser?.getIdToken()`; `refreshAccessToken()` maps to `currentUser?.getIdToken(true)`. No refresh endpoint is invented, requested, or stubbed — the backend has none and A1 forbids adding one. The non-forced call already auto-refreshes when the token is within ~5 minutes of expiry, so the common path costs nothing. Rejected alternative: a hand-rolled refresh-token grant against Google's `securetoken.googleapis.com` — it would duplicate SDK state, require storing the refresh token ourselves, and add a second revocation path the backend's `checkRevoked: true` would then disagree with.

#### ADR-011b — Session persistence is Firebase SDK persistence; no `flutter_secure_storage`

`firebase_auth` already persists the refresh token in the iOS Keychain and Android encrypted storage and restores `currentUser` before the first frame. AC3 is satisfied by `authStateChanges()`. This is a deliberate narrowing of system memory §9 F3's phrase "secure token storage": adding our own secure store would create two sources of truth, a second revocation gap, and a real leak surface, in exchange for nothing. The ID token is held in memory only and is never persisted by app code.

#### ADR-011c — `CupidAuthInterceptor`: bearer attach + single-flight, retry-exactly-once

- `onRequest`: attach `Authorization: Bearer <idToken>` when a token exists; otherwise forward unchanged (unauthenticated calls stay legal).
- `onError`: act only when `response?.statusCode == 401` **and** `options.extra['cupid_auth_retried'] != true`. Force-refresh, mark `extra['cupid_auth_retried'] = true`, replay the request once on the shared `Dio`. Never retry twice; never retry a non-401.
- **Single-flight is mandatory**: hold one shared `Future<String?>` for the in-flight refresh so N concurrent 401s produce exactly one refresh and one token, not N. Without it a screen issuing parallel calls triggers a refresh storm.
- If refresh yields `null` or throws (`user-token-expired`, `user-disabled`, `user-not-found`), emit `SessionExpiredFailure`, drive `CupidSession` to `SignedOut`, and forward the original error so the UX §4b route to `login` fires. Do not throw from the interceptor.
- Slot order is untouched: `auth` remains slot 1, still ahead of `diagnostics` and `errorMapping`, which is exactly what lets the retry resolve before `CupidErrorInterceptor` maps 401 to `UnauthorizedFailure`.

#### ADR-011d — Debug diagnostics must redact the bearer header (cross-story correction)

STORY-002 §5 reasoned that `LogInterceptor` is debug-only so STORY-003's tokens "never reach release logs". That holds for release and **fails for debug**: `diagnostics` is slot 2, so it runs *after* `auth` sets the header, and Dio's `LogInterceptor` defaults to `requestHeader: true` — it would print a live ID token to the console on every debug request. Fix: construct the diagnostics occupant as `LogInterceptor(requestHeader: false)`. This changes an occupant's *configuration* only; it reorders and renames nothing, so STORY-002's slot contract is intact. Escalate to Scrum Master if `cupid_interceptor_slots.dart` is outside the implementation write scope.

#### ADR-011e — `otp` resolves to a link-based inbox-wait screen (UX §9 item 1)

Firebase email verification is link-based; the spec has no OTP endpoint, so a typed 6-digit code cannot be verified without a backend change A1 forbids. **Chosen: UX option (b), bounded.** Keep the `otp` screen, its layout, and its tokens; replace the interactive digit boxes with the inbox-wait copy ("tap the link we sent, then come back" / vi equivalent), a "Resend email" action bound to `sendEmailVerification()` behind a cooldown, and an auto-advance driven by `currentUser.reload()` on app-foreground plus a slow poll. Option (a) — keeping typeable-but-decorative digit boxes — is rejected: an input that accepts a code the system never sent is a UI lie that fails the first user who tries it, and the copy change is strings-only in both locales with no layout or token impact. Second, load-bearing finding: **the backend never checks `email_verified`** (`verifyIdToken`'s second argument is `checkRevoked`, not verification), so a hard client-side block buys no security. Recommend verification be send-and-continue in v1 — flagged to Product Owner as a scope confirmation, not a blocker, since AC1-AC4 do not mention OTP and UX §2 places the screen downstream of this story.

#### ADR-011f — Biometric row is a local app-lock gate; implementation deferred (UX §9 item 2)

UX's framing is **confirmed**: `login`'s `bioLabel` row is `local_auth` quick-unlock over an already-persisted Firebase session, not a second credential — it yields no token and must gate *navigation only*, never token issuance, with the interceptor still validating every call. Two bounds: (1) it is unrelated to the backend's `POST /users/vow` "Mark biometric vow as taken", which is an epic-1 partner ritual — do not conflate them; (2) no AC in this story mentions biometrics, so implementation is deferred to the app-lock owner (STORY-016, epic-6 privacy) and the `bioLabel` row stays hidden in v1. UX §3's flow map needs no revision.

#### ADR-011g — Introduce `flutter_bloc` and `get_it`; keep `injectable` and `freezed` deferred

D2 requires Bloc and the sign-in screens are its first real consumer, so `flutter_bloc` lands here. `get_it` lands as the single app-wide composition root every later story registers into — it is runtime-only with no build step. `injectable` and `freezed` stay deferred per ADR-010f because both require `build_runner` in the app package, and this story's states are small enough for Dart 3 `sealed class`, exactly as `CupidApiFailure` already is. The line for future stories: runtime deps yes, codegen deps only when a story genuinely needs generated unions.

#### ADR-011h — Splash never blocks on the network (UX §3)

The splash gate reads `authStateChanges().first` (local, no network) and then `getIdToken()` **non-forced** under a 3s timeout. On timeout it proceeds to Home optimistically and lets ADR-011c handle any 401 lazily. This makes UX §3's 2s dwell budget trivially satisfiable and prevents a slow network from holding a user on the splash screen. Forced refresh at cold start is explicitly rejected as a needless startup network dependency.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Minimum Gate | Blocker If Gate Cannot Run |
|---|---|---|---|
| Refresh-on-401 (AC2) | `cupid_auth_interceptor.dart` | Unit test with a mock `Dio` adapter: 401 -> one refresh -> one retry -> success; and 401 -> failed refresh -> `SessionExpiredFailure`, no second retry | none |
| Refresh storm | same | Unit test: 5 concurrent 401s trigger exactly **one** `refreshAccessToken()` call | none |
| Token leak (system memory §10 blocker) | `cupid_interceptor_slots.dart` | Unit test asserting the debug diagnostics interceptor emits no `Authorization` value; grep gate that no app code persists a token | Token observed in debug log output -> blocker, ADR-011d not applied |
| Session persistence (AC3) | `cupid_session.dart` | Widget test: seeded signed-in `FirebaseAuth` mock -> splash resolves to `SignedIn` without a sign-in screen; and unseeded -> `SignedOut` | none |
| Sign-out teardown (AC4) | `cupid_session.dart` | Unit test: `signOut()` calls Firebase sign-out and every registered `SessionScopedStore.clearOnSignOut()` exactly once, in registration order | none |
| Firebase project match | `backend/service-account.json` `project_id` vs `firebase_options.dart` `projectId` | Values are identical | Mismatch -> every call 401s; escalate to Scrum Master/DevOps, do not work around |
| R8 token exposure | `CupidSession.idToken` / `idTokenStream` | Unit test: `idTokenStream` emits after a forced refresh | none |
| App build | `mobile-app` runtime registry id | `flutter analyze` clean, `flutter test` green, `flutter build apk --debug` succeeds | Flutter not on PATH -> resolve via the registry `sdk.resolutionOrder` |

### Mobile Lane Handoff

Owns every item in Affected Components and every gate above. Must not: add a backend endpoint or edit `backend/`, reorder/rename interceptor slots, hand-edit `mobile/openapi/**` or `firebase_options.dart`, add `injectable`/`freezed`/`flutter_secure_storage`, or implement `local_auth`/OTP screen logic.

### DevOps Lane Handoff

Obtain the Firebase project config for both platforms and confirm its `project_id` matches the backend service account. Own the `deployment/configuration-guide.md` update (Firebase project setup, `flutterfire configure`, the two platform config files, and their non-secret-but-environment-specific status). No runtime registry change — `mobile-app` covers this story unchanged.

### Backend Lane Handoff

None. `backend/` is read-only (A1). The R8 gateway hardening at `backend/src/modules/messages/chat.gateway.ts:40` stays a pre-production escalation owned by system memory §8, not this story.

## 5. Non-Functional Impact

- Startup: ADR-011h keeps cold start off the network on the critical path.
- Security: net improvement — ADR-011d closes a debug token-logging hole STORY-002 left open; ADR-011b keeps the only persisted secret inside platform-managed storage.
- Binary size: five new plugin dependencies, all first-party or widely used; social providers are required by the existing design source, not added by this story.

## 6. Option Evaluation

| Option | Verdict | Reason |
|---|---|---|
| Firebase SDK `getIdToken(true)` as the refresh mechanism | CHOSEN | The only mechanism the frozen backend supports; zero new endpoints |
| Hand-rolled refresh grant + own secure storage | REJECTED | Duplicates SDK state, adds a second revocation path, contradicts `checkRevoked: true` |
| Backend refresh endpoint | REJECTED | Violates A1; no such endpoint exists in the spec |
| Typed 6-digit OTP (UX option a) | REJECTED | Non-functional input; needs a backend code endpoint A1 forbids |
| `get_it` composition root now | CHOSEN | Runtime-only, no build step, unblocks every later story |
| `injectable` + `freezed` now | REJECTED | Adds `build_runner` to the app package for states a `sealed class` already covers |

## 7. Risks And Mitigations

| Risk | Mitigation |
|---|---|
| App and backend point at different Firebase projects | Verify `project_id` equality before P2 is green; hard blocker, escalate |
| `flutterfire configure` unavailable / no Firebase project access | Escalate to Scrum Master/DevOps; do not stub or fake auth to get a green build |
| Concurrent 401s cause a refresh storm | Single-flight future in ADR-011c, with a dedicated unit test |
| Debug logs leak a live ID token | ADR-011d redaction plus an explicit test gate |
| Social sign-in needs per-platform native setup (Google `SHA-1`, Apple capability, Facebook app id) | Treat as configuration-guide work in P1/P5, not code; missing setup fails at runtime only, so P5 must exercise at least one social path on a real device or emulator |
| Long-lived socket holds a stale token (R8) | `idTokenStream` in §2; STORY-004 must subscribe — recorded as its inherited constraint |

## 8. Embedded Coding Plan

`WriteScope` for this run is `architecture/**` only, so no separate `coding-plan/master-plan.md` was written. The story is single-lane (mobile) with one small DevOps dependency, so the plan below is complete on its own; it uses the required Phase Overview schema so Scrum Master can lift it verbatim into `coding-plan/master-plan.md` if the standard-story gate requires that file — **this is a flagged Scrum Master decision, not a silent skip.**

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|---|---|---|---|---|---|---|---|---|---|
| P1 | DevOps | devops | — | yes (with P2) | `mobile/android/app/`, `mobile/ios/Runner/`, `mobile/lib/firebase_options.dart`, `deployment/configuration-guide.md` | §2 DevOps contract, ADR-011b | Firebase config for both platforms; `project_id` match confirmed; configuration guide updated | `flutter build apk --debug` compiles with Firebase initialized | PENDING |
| P2 | Mobile | mobile | — | yes (with P1) | `mobile/lib/core/auth/**`, `mobile/pubspec.yaml` | ADR-011a/b/c, §2 | `cupid_session.dart`, `firebase_id_token_provider.dart`, `cupid_auth_failure.dart`, `cupid_auth.dart` | Unit: token read/force-refresh, session state transitions | PENDING |
| P3 | Mobile | mobile | P2 | no | `mobile/lib/core/auth/cupid_auth_interceptor.dart`, `mobile/lib/core/network/cupid_interceptor_slots.dart`, `mobile/lib/core/di/service_locator.dart` | ADR-011c/d/g | Interceptor in the `auth` slot; diagnostics redaction; `get_it` registrations | Unit: refresh-on-401, single retry, single-flight, no token in debug log | PENDING |
| P4 | Mobile | mobile | P3 | no | `mobile/lib/features/auth/**` | UX §3/§4b/§6, §2 `AuthRepository` | Repository, three Cubits, `splash`/`welcome`/`login`/`register`/`forgot` wiring incl. session-expired heading variant and inline error mapping | Widget: splash gate branches; unit: `CupidAuthFailure` mapping | PENDING |
| P5 | Mobile | mobile | P1, P4 | no | `mobile/test/**` | all ACs | Sign-out confirm + teardown; AC1-AC4 verification | `flutter analyze` clean, `flutter test` green, `flutter build apk --debug`, one real sign-in path exercised on device/emulator | PENDING |

Phase sizing: each phase is at or under six source/test files. No phase depends on raw UX artifacts beyond the constraints already derived into §2 and ADR-011e/h. No e2e, Playwright, or runtime-startup-smoke gates are assigned.

## 9. Handoff Notes

- Single implementation lane: `mobile`, plus one DevOps phase (P1) for Firebase project config.
- STORY-004 reads §2 and ADR-011a only. Its inherited constraint is explicit: subscribe to `idTokenStream` and re-handshake, because Socket.IO evaluates `handshake.auth` once per connection.
- System memory update recommended (out of this run's write scope): add ADR-011 and correct §9 F3's "secure token storage" phrasing per ADR-011b; §8's R8 row is unchanged and still accurate.
