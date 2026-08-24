# Requirement Master: REQ-008 Android build variants for local/prod backend
Status: DONE

## Deployment Status
- Development Environment: DEPLOYED (2026-08-24, automatic post-requirement
  deployment; mobile-app scope only — see
  `deployment/deployment-log.md` Entry 1)
- Staging: NOT_REQUESTED
- Production: NOT_REQUESTED

## Configuration Documentation
- Source of Truth: `deployment/configuration-guide.md`
- Status: NOT_REQUIRED
- Pending User Setup: NONE
- Last Updated:

## Business Scope

The user wants the Android build of the Flutter mobile app configured with
native Android build variants (Gradle product flavors) that are visible and
selectable in Android Studio's "Build Variants" panel, so a developer can pick
which backend the app talks to directly from the IDE instead of only via a
command-line flag. Concretely:

1. `local` variant — app points at the local development backend
   (localhost).
2. `prod` variant — app points at the production backend `api.cupidus.app`.
3. Both variants must appear as selectable Build Variants inside Android
   Studio (i.e. configured as native Android product flavors in the Android
   Gradle project, not only as a Flutter `--dart-define`/CLI-only flavor).

## Technical Constraints

- Mobile stack is Flutter (per bootstrap ADR-009 / System Architecture
  Memory). This requirement specifically needs the Android host project
  (`android/app/build.gradle` or `.gradle.kts`) to declare product flavors so
  they surface in Android Studio's Build Variants dropdown — a
  Flutter-only `--dart-define` flavor is not sufficient to satisfy "hiện để
  chọn được trong android studio".
- Must not break the existing local-development build path.
- REQ-007 already added a production API build flavor mechanism for the
  Flutter app (dart-define based) and validated it end-to-end. This
  requirement's job is to confirm/reconcile that existing mechanism against
  native Android product flavors so both are consistent and the variant
  picker in Android Studio is wired to the same `local` vs `prod` backend
  base URL, rather than introducing a second, conflicting config system.
- iOS is out of scope for this requirement; only the Android build variant
  configuration is requested.

## Dependencies

- Depends on REQ-005 (production domain & CI/CD standardization) for a live
  `api.cupidus.app` target.
- Related to REQ-007 (mobile app production API build configuration), which
  already introduced a local/production API build mechanism for the Flutter
  app; this requirement extends/reconciles that mechanism with native Android
  product flavors so it is selectable in Android Studio.

## Open Questions

- None yet; exact Gradle product-flavor structure (flavor dimension names,
  applicationIdSuffix/versionNameSuffix if any, and how flavor selection
  wires into the Dart-side API base URL from REQ-007) should be confirmed
  during Tech Lead story planning.

## User Stories
| ID | Title | Complexity | Status | Path |
|----|-------|------------|--------|------|
| STORY-001 | Android Studio Build Variants For Local/Prod Backend | standard | DONE | `data/requirements/REQ-008_android_build_variants_local_prod/STORY-001/story_master.md` |
