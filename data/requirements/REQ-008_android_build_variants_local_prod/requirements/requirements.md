# Requirement Breakdown: REQ-008 Android build variants for local/prod backend

## Source Artifacts

- Requirement master: `data/requirements/REQ-008_android_build_variants_local_prod/req_master.md`
- Additional input files: `data/intake/bootstrap/conflicts_open_questions.md`
- Existing related requirement artifacts: `data/requirements/REQ-007_mobile_app_production_api_build_config/req_master.md` (DONE — introduced the Flutter `--dart-define`-based local/production API base URL mechanism this requirement reconciles with)

## Context Summary

- Request summary: configure the Android host project with native Android Gradle
  product flavors, `local` and `prod`, that appear as selectable Build Variants
  inside Android Studio, and wire the selected flavor to the same local/prod
  backend base URL mechanism REQ-007 already delivered for the Flutter app
  (dart-define based), instead of creating a second, conflicting config system.
- Primary actors: mobile/backend developers building and running the Android
  app from Android Studio.
- Problem to solve: today the local/prod backend target is only selectable via
  a Flutter CLI `--dart-define` flag (REQ-007); it is not visible or
  selectable as a native Android build variant in Android Studio's Build
  Variants panel, which is the workflow the user wants.
- Business outcome: a developer can pick `local` or `prod` directly from
  Android Studio's Build Variants dropdown and get an app build pointed at the
  correct backend (`localhost` for `local`, `api.cupidus.app` for `prod`)
  without hand-typing CLI flags or risking a build pointed at the wrong
  backend.
- Success signal: both `local` and `prod` product flavors appear in Android
  Studio's Build Variants panel for `android/app`, and building/running each
  variant results in the app calling the correct backend base URL, using the
  REQ-007 dart-define mechanism as the underlying source of truth rather than
  a duplicate config path.
- Notes on current project context: REQ-007 (DONE) is the existing
  local/production API build mechanism (dart-define based). iOS is explicitly
  out of scope. Depends on REQ-005 for a live `api.cupidus.app` target
  (already available per requirement dependency).

## Scope Decision

### In Scope

- Native Android Gradle product flavors `local` and `prod` declared in
  `android/app/build.gradle` or `android/app/build.gradle.kts`, so both are
  visible and selectable in Android Studio's Build Variants panel.
- Wiring the selected native flavor to the same `local`/`prod` backend base
  URL values REQ-007 already established via Flutter `--dart-define`, so the
  IDE-selected variant and the CLI-driven dart-define value stay consistent
  (single source of truth for the backend base URL per environment).
- Preserving the existing local-development build path so it keeps working
  after the flavors are introduced.

### Out of Scope

- iOS build configuration or Xcode schemes/configurations (explicitly out of
  scope per req_master.md).
- Any change to the production domain, CI/CD pipeline, or backend
  infrastructure itself (owned by REQ-005).
- Any change to the dart-define value contract or API base URL values REQ-007
  already defined, beyond wiring the native flavor to select between them.
- App Store Connect / Google Play Console registration, code signing, or real
  bundle-id/applicationId changes for store submission (separate, unrelated,
  and explicitly flagged as future work in the bootstrap conflicts registry).

### Business Rules And Guardrails

- The native Android product flavor mechanism must not introduce a second,
  independent config system; it must resolve to the same backend base URL
  values REQ-007 already defined for `local` and `prod`.
- The existing local-development build path must keep working unmodified from
  a developer's point of view after this story ships.
- iOS is out of scope; no iOS scheme/configuration work is included here.
- Exact Gradle flavor dimension naming, `applicationIdSuffix`/
  `versionNameSuffix` usage (if any), and the concrete mechanism for wiring
  flavor selection to the Dart-side API base URL are Tech Lead decisions to be
  made during story planning, not fixed by this breakdown.

## Open Question Triage

> Central registry checked: `data/intake/bootstrap/conflicts_open_questions.md`
> has no `## OQ-to-REQ Index` and carries no live, unresolved item scoped to
> Android build variants, Gradle product flavors, or the REQ-007 dart-define
> mechanism.

| OQ ID | Status | Scope Items BLOCKED | Scope Items NOT BLOCKED | Decision |
|-------|--------|---------------------|------------------------|----------|
| req_master.md inline OQ (no central OQ ID) | UNRESOLVED | None — exact flavor dimension naming and dart-define wiring mechanism are unspecified | All in-scope items above (story creation, story sequencing) | Proceed with story creation; Tech Lead confirms the exact Gradle flavor structure and flavor→dart-define wiring mechanism during story-level architecture/coding-plan work |

### OQs reviewed but not applicable to this requirement

- OQ5 (light theme & EN locale scope): not applicable — unrelated to Android
  build variants.
- R8 (backend Socket.IO auth gap): not applicable — unrelated to build
  configuration.
- D1/Critical-Alerts copy conflict: not applicable — unrelated UI copy issue.
- Nginx VPS-target ambiguity: not applicable — concerns a separate,
  unconfirmed VPS deployment target, not the already-in-scope
  `api.cupidus.app` production target this requirement uses.
- Mobile bundle id / org placeholder (`com.snapsofts.cupid_mobile`): reviewed,
  not blocking — noted only as context for Tech Lead in case flavor
  `applicationIdSuffix` choices interact with the existing placeholder
  applicationId; no story-creation impact.

## Seed To Story Mapping

> Not applicable — `req_master.md` does not carry a `## Story Seeds` table.

### Distinct user outcomes in this requirement

1. A developer can select `local` or `prod` from Android Studio's Build
   Variants panel and get an Android build that talks to the correct backend,
   consistent with the existing REQ-007 dart-define mechanism.

Only one distinct user outcome was identified. Native flavor declaration and
wiring to the existing dart-define mechanism are two phases of that same
outcome (nothing is observable to a developer until both are done), so they
form a single story rather than two.

## Coverage Map

| Requirement / Need | Planned Story ID(s) | Notes |
|--------------------|---------------------|-------|
| Native `local`/`prod` Gradle product flavors visible in Android Studio Build Variants panel | STORY-001 | |
| Flavor selection wired to REQ-007's existing dart-define local/prod backend base URL mechanism (single source of truth) | STORY-001 | |
| Existing local-development build path continues to work | STORY-001 | Guardrail, not a separate slice |
| iOS build configuration | Out of scope | Explicitly excluded per req_master.md |

## Recommended Story Sequence

| Story ID | Title | Complexity | Depends On | Why This Order | Observable After This Story |
|----------|-------|------------|------------|----------------|-----------------------------|
| STORY-001 | Android Studio Build Variants For Local/Prod Backend | standard | None | Only story in this requirement; no other story to sequence against | A developer can select `local` or `prod` in Android Studio's Build Variants panel and the resulting app build targets the correct backend base URL |

## Story Index

| Story ID | Title | Brief File | Primary Scope | Key AC/OQ Anchors |
|----------|-------|------------|---------------|-------------------|
| STORY-001 | Android Studio Build Variants For Local/Prod Backend | `data/requirements/REQ-008_android_build_variants_local_prod/STORY-001/story_brief.md` | `android/app/build.gradle(.kts)` product flavors + wiring to REQ-007 dart-define mechanism | req_master.md Business Scope items 1-3; req_master.md inline OQ (flavor structure/wiring) |

INTEGRATION_VERIFICATION_REQUIRED: NO
