# Phase P0 – Make `AuthRepository` reachable in production (ADR-7)

## 1. Objective

Give the app a real, constructible `AuthRepository`. AC2 and AC3 both terminate
on `LoginScreen` / `WelcomeScreen`, whose constructors require one, and today
`FirebaseSignInGateway` has no concrete implementation anywhere in `lib/`.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-auth-repository-reachability.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Status: NOT_STARTED
- Gate: do not start before Scrum Master / Product Owner acknowledges the
  ADR-7 SCOPE DISCOVERY in `../architecture/solution.md` section 3.
- Write Scope:
  - `mobile/lib/features/auth/data/firebase_auth_sign_in_gateway.dart` (new)
  - `mobile/lib/core/di/service_locator.dart` (registration only)
  - `mobile/test/features/auth/data/firebase_auth_sign_in_gateway_test.dart` (new)
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Test Command: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test`
    (Flutter is not on PATH on this machine)
  - Build Command: not required by this phase; `flutter analyze` is the gate
- Risk Surfaces:
  - R5 `AuthRepository` reachability
- Source Of Truth:
  - `../architecture/solution.md` ADR-7
  - existing interface: `mobile/lib/features/auth/data/firebase_sign_in_gateway.dart`
- Requirement Configuration Guide:
  - Update Required: NO — `firebase_auth`, `google_sign_in`,
    `sign_in_with_apple`, and `flutter_facebook_auth` are already declared in
    `mobile/pubspec.yaml`, and Firebase is already initialized in
    `mobile/lib/main.dart`.
- Phase Sizing:
  - Behavior Slice: one atomic capability — make the existing auth interface
    constructible in production.
  - Source/Test File Count: 3 paths, of which 1 is a registration-only edit.
  - Split Required: NO.

## 2. Required Reads

- `../architecture/solution.md` sections 2 (finding D5) and 3 (ADR-7)
- `mobile/lib/features/auth/data/firebase_sign_in_gateway.dart` (the interface
  to implement)
- `mobile/lib/features/auth/data/auth_repository.dart` (constructor shape)

## 3. Tasks

1. Implement the concrete gateway against the already-declared plugins. Map
   each interface method to its plugin call and map thrown provider errors onto
   the existing `CupidAuthFailure` taxonomy in
   `mobile/lib/core/auth/cupid_auth_failure.dart` — do not invent a second
   failure type.
2. Register `AuthRepository` in `service_locator.dart` following the existing
   `registerLazySingleton` idiom, wiring `gateway:` to the new concrete class,
   `api:` to `getIt<CupidApi>()`, `signOut:` to
   `() => getIt<CupidSession>().signOut()`, and `backendUserIdStore:` to
   `getIt<BackendUserIdStore>()`. `main_preview.dart:439` keeps its own
   preview-stub construction; do not change it.
3. Unit-test the gateway's error mapping with a faked `FirebaseAuth`. Do not
   attempt a live sign-in in tests.

## 4. Acceptance Criteria

- `getIt<AuthRepository>()` resolves in a production build without throwing.
- Email/password sign-in, registration, password reset, email verification, and
  verification reload are implemented against `firebase_auth`, not stubbed.
- Provider errors surface as `CupidAuthFailure`, never as a raw plugin
  exception.
- `flutter analyze` clean; the new test file passes.

## 5. Planned Outputs

- The three files in Write Scope.
- A note in `test-results.md` recording any missing native provider
  configuration found (Google OAuth client ids, Apple Sign In capability,
  Facebook app id). Report it; do not fix it — that is outside this story.

## 6. Test Scope

- `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test test/features/auth/`
- `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze`
- Excluded: e2e, emulator/simulator lifecycle, signing, live provider sign-in.

## 7. Status

NOT_STARTED
