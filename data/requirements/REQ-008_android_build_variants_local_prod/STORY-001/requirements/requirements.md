# Story Requirements: STORY-001 Android Studio Build Variants For Local/Prod Backend

## Identity

- Parent requirement: REQ-008_android_build_variants_local_prod
- Story master: `data/requirements/REQ-008_android_build_variants_local_prod/STORY-001/story_master.md`
- Complexity: standard
- Implementation lane: mobile-dev (native Android Gradle config), with a Tech Lead architecture decision on the flavor→dart-define wiring mechanism before implementation — not a single trivial lane.

## Actor / Capability / Business Value

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

## Acceptance Criteria

1. `android/app/build.gradle` (or `.gradle.kts`) declares `local` and `prod`
   as native Android Gradle product flavors, and both appear as selectable
   entries in Android Studio's Build Variants panel for the `android/app`
   module.
2. Building and running the `local` flavor from Android Studio (with no
   CLI dart-define flag supplied) produces an app that resolves its API base
   URL to the local development backend (localhost), matching the value
   REQ-007's `--dart-define` mechanism already uses for local dev.
3. Building and running the `prod` flavor from Android Studio (with no CLI
   dart-define flag supplied) produces an app that resolves its API base URL
   to `api.cupidus.app`, matching the value REQ-007's `--dart-define`
   mechanism already uses for production.
4. The native flavor selection is the single source of truth for which
   backend base URL a given Android build resolves to — a developer who only
   switches Build Variant in Android Studio (without separately passing a
   CLI `--dart-define` flag) gets the base URL matching the selected flavor,
   not a stale or mismatched value from a previous CLI invocation.
5. The existing local-development build/run path (as used before this
   story) still builds and runs successfully after the flavors are
   introduced — no regression to the pre-existing local build.
6. No second, independent backend-base-URL configuration system is
   introduced; the native flavor mechanism reconciles with/drives the same
   `local`/`prod` base URL values REQ-007 already established, rather than
   duplicating them.

## Business Rules / Guardrails

- Must resolve to the same backend base URL values REQ-007 already
  established via `--dart-define`, not a second/independent config system.
- Must not break the existing local-development build path.
- iOS is out of scope; only the Android host project (`android/app`) is
  affected by this story.
- Exact Gradle product-flavor structure (flavor dimension name,
  `applicationIdSuffix`/`versionNameSuffix` if any) and the concrete
  mechanism bridging native flavor selection to the Dart-side dart-define
  API base URL are Tech Lead architecture decisions, not fixed by this
  artifact.

## Edge Cases / Failure Modes

- Developer switches Build Variant in Android Studio only, without touching
  any CLI dart-define flag — the app must still resolve to the base URL
  matching the selected native flavor (AC 4), not silently fall back to a
  stale or default value.
- `prod` flavor build must not silently resolve to the local base URL (or
  vice versa) due to a missing/misconfigured build-time value defaulting
  incorrectly.
- Introducing the two flavors must not require every existing local build
  invocation (IDE run configs, existing scripts) to be manually updated
  just to keep working — the existing local-development build path must
  keep working (AC 5).

## Out of Scope

- iOS build configuration or Xcode schemes.
- Changing the production domain, CI/CD, or backend infrastructure (REQ-005
  scope).
- Changing the dart-define value contract or API base URL values REQ-007
  already defined.
- App Store Connect / Google Play Console registration, code signing, or
  applicationId changes for store submission.
- Any new user-facing feature or end-user-facing UI (this is
  developer/internal tooling surfaced only in Android Studio's Build
  Variants panel).

## Open Question Impact

### Scope Items BLOCKED in this story

- None.

### Scope Items NOT BLOCKED in this story

- All scope items (AC 1-6) are not blocked. req_master.md carries one
  UNRESOLVED, non-blocking inline open question (req_master.md inline OQ,
  no central OQ ID) on the exact Gradle product-flavor structure and the
  concrete flavor→dart-define wiring mechanism; the requirement-level Open
  Question Triage in
  `data/requirements/REQ-008_android_build_variants_local_prod/requirements/requirements.md`
  already resolved this as NOT BLOCKED for story creation, to be confirmed
  by Tech Lead during story-level architecture/coding-plan work. No item
  from the central Open Question registry
  (`data/intake/bootstrap/conflicts_open_questions.md`) applies to this
  story's scope.
