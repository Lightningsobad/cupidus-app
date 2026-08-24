# Story Brief: STORY-001 Android Studio Build Variants For Local/Prod Backend

## Identity

- Parent requirement: `data/requirements/REQ-008_android_build_variants_local_prod/req_master.md`
- Story master: `data/requirements/REQ-008_android_build_variants_local_prod/STORY-001/story_master.md`
- Final story requirements artifact: `data/requirements/REQ-008_android_build_variants_local_prod/STORY-001/requirements/requirements.md` (to be created by story-level Product Owner work)

## Brief

- Actor: mobile/backend developer building and running the Android app from
  Android Studio.
- Capability: select `local` or `prod` directly from Android Studio's Build
  Variants panel (native Android Gradle product flavors) and get an Android
  app build that targets the correct backend base URL — localhost for
  `local`, `api.cupidus.app` for `prod`.
- Business value: removes the need to hand-type a Flutter `--dart-define` CLI
  flag to choose the backend target, reducing the risk of a build accidentally
  pointed at the wrong backend and making backend switching a first-class,
  IDE-visible action.
- Key business rules or guardrails:
  - Must resolve to the same backend base URL values REQ-007 already
    established via `--dart-define`, not a second/independent config system.
  - Must not break the existing local-development build path.
  - iOS is out of scope.
- Key edge or failure case: a developer switches Build Variant in Android
  Studio without also changing any CLI dart-define flag — the app must still
  resolve to the base URL matching the selected native flavor, not a stale or
  mismatched value from a previous CLI invocation.
- Existing system entry / discoverability seed: Android Studio's native
  "Build Variants" tool window for the `android/app` module — this is
  developer/internal tooling, not end-user-facing UI, so there is no
  end-user-facing entry point to design.
- Complexity: standard
- Why this complexity: requires an architecture decision (owned by Tech Lead)
  on the concrete mechanism that bridges native Android product-flavor
  selection to the existing Flutter dart-define API base URL value — this is
  not a pre-established pattern already in the codebase, per req_master.md's
  own open question on flavor structure and dart-define wiring.
- Implementation lane seed: mobile (Android host project config); may involve
  Tech Lead architecture decisions before implementation.
- Depends on: none (only story in this requirement).

## Direct Anchors

- Requirement AC / BR anchors: req_master.md Business Scope items 1-3
  (`local` variant → localhost, `prod` variant → `api.cupidus.app`, both
  visible/selectable as native Android product flavors in Android Studio);
  req_master.md Technical Constraints (must not break existing local build
  path; must reconcile with REQ-007's existing mechanism rather than
  duplicate it; iOS out of scope).
- Open Question anchors: req_master.md inline Open Question — exact Gradle
  product-flavor structure (flavor dimension names,
  `applicationIdSuffix`/`versionNameSuffix` if any) and how flavor selection
  wires into the Dart-side API base URL from REQ-007; not blocking story
  creation, to be resolved during Tech Lead story planning.
- Related story dependencies: none within REQ-008. Builds on REQ-007 (DONE)
  as an existing, already-delivered mechanism — not a story dependency inside
  this requirement.

## Scope Seed

### In Scope

- Declaring `local` and `prod` as native Android Gradle product flavors in
  `android/app/build.gradle` or `android/app/build.gradle.kts` so both appear
  as selectable entries in Android Studio's Build Variants panel.
- Wiring the selected native flavor to the same `local`/`prod` backend base
  URL values REQ-007 already defined via Flutter `--dart-define`, so the
  native flavor and the dart-define value stay consistent for a given build.
- Verifying the existing local-development build path still works after the
  flavors are introduced.

### Out of Scope

- iOS build configuration or Xcode schemes.
- Changing the production domain, CI/CD, or backend infrastructure (REQ-005
  scope).
- Changing the dart-define value contract or API base URL values REQ-007
  already defined.
- App Store Connect / Google Play Console registration, code signing, or
  applicationId changes for store submission.
