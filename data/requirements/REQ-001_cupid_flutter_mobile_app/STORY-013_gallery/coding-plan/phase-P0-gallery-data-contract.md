# Phase P0 – Gallery Data Contract

## 1. Objective

Establish the mobile-side gallery data contract every later phase consumes:
domain model, network access over the shared `Dio`, media URL derivation,
offline snapshot cache, and DI registration.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-gallery-data-contract.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/gallery/domain/gallery_item.dart`
  - `mobile/lib/features/gallery/data/gallery_api.dart`
  - `mobile/lib/features/gallery/data/gallery_repository.dart`
  - `mobile/lib/features/gallery/data/gallery_local_cache.dart`
  - `mobile/lib/core/di/service_locator.dart`
  - `mobile/pubspec.yaml`
  - `mobile/test/features/gallery/gallery_repository_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A for this phase
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `GalleryItem` (`id`, `userId`, `filename`, `thumbnailUrl?`, `mimeType?`, `createdAt`)
  - `GalleryRepository` (`fetchPage`, `uploadPhoto`, `currentUser`, `cachedPage`)
  - `galleryMediaUrl(String filename)`
  - `GalleryLocalCache` (first-page JSON snapshot)
- Shared Interfaces Consumed:
  - `CupidApiClient` shared `Dio`, `CupidApiConfig.baseUrl`, `get_it` locator
  - Backend `GET /gallery`, `POST /uploads`, `POST /gallery`, `GET /users/me`
- Risk Surfaces:
  - Gallery read contract
  - Upload contract + 10 MB limit
  - Media URL derivation
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §2 Downstream Contract Summary
  - consumer contract: `GalleryRepository` is the only network entry point for gallery data
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC1-AC3, `## Open Question Impact`
  - architecture: `../architecture/solution.md` §2, §4 Contracts And Integrations, §5 D-1/D-2
  - OQ constraints: A1 frozen; no encryption; no delete
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO (permission entries land in P3)
- Phase Sizing:
  - Behavior Slice: data layer only, no UI
  - Source/Test File Count: 6 (4 new source, 2 edits, 1 test)
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` `## Open Question Impact`
- `../architecture/solution.md` §2 and §4 Contracts And Integrations
- `mobile/lib/core/network/cupid_api_client.dart`, `mobile/lib/core/config/cupid_api_config.dart`, `mobile/lib/core/di/service_locator.dart`

## 3. Tasks

- Add `image_picker` and `cached_network_image` to `mobile/pubspec.yaml`.
- Define `GalleryItem` with `fromJson`/`toJson`. Do not model `isEncrypted` or `encryptionKeyId`.
- Implement `galleryMediaUrl(filename)` returning `${CupidApiConfig.baseUrl}/uploads/$filename`; prefer a non-empty `thumbnailUrl` when the server ever provides one.
- Implement `GalleryApi` over the shared `Dio`:
  - `fetchPage({int limit = 30, int offset = 0})` -> `GET /gallery`
  - `uploadFile(File, {ProgressCallback onSendProgress})` -> `POST /uploads` with `FormData` field `file`
  - `createItem({required String filename, String? mimeType})` -> `POST /gallery`
  - `fetchMe()` -> `GET /users/me`, exposing `id` and `partnerId`
- Implement `GalleryLocalCache` on `shared_preferences`, key `gallery.snapshot.v1`, storing the first page only.
- Implement `GalleryRepository`: read-through (cache on success, serve cache on network failure), and `uploadPhoto` sequencing `uploadFile` then `createItem`, surfacing a per-step failure.
- Register `GalleryApi`, `GalleryLocalCache`, and `GalleryRepository` as lazy singletons in `service_locator.dart`.

## 4. Acceptance Criteria

- `GalleryRepository.fetchPage` maps a recorded `GET /gallery` JSON fixture into `GalleryItem` values with correct `createdAt` parsing.
- On a `DioException`, `fetchPage` returns the cached snapshot instead of throwing, and marks the result as stale.
- `uploadPhoto` calls `POST /uploads` then `POST /gallery`, and a step-1 failure never issues step 2.
- `galleryMediaUrl` produces `<baseUrl>/uploads/<filename>` with no double slash.
- No import of `package:cupid_api` gallery APIs anywhere in `features/gallery/`.

## 5. Planned Outputs

- Code: `mobile/lib/features/gallery/domain/`, `mobile/lib/features/gallery/data/`
- Contracts: `GalleryItem`, `GalleryRepository`, `galleryMediaUrl`
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, data layer
- Required levels:
  - unit: `gallery_repository_test.dart` covering JSON mapping, cache fallback, upload sequencing, URL derivation
  - mobile build/type-check/static-analysis: `flutter analyze` clean for `mobile/lib/features/gallery/`
- Required checks: `flutter pub get` resolves the two new dependencies
- Minimum gates by risk surface: gallery read contract and media URL derivation both covered by unit assertions against the recorded fixture
- Evidence format: test names plus pass/fail counts recorded in the phase status
- Verification strategy:
  - Targeted tests: `flutter test test/features/gallery/gallery_repository_test.dart`
  - Static analysis: `flutter analyze`

## 7. Status

- Status: DONE
- Last updated: 2026-07-31
- Evidence:
  - `flutter test test/features/gallery/gallery_repository_test.dart` — 5/5 passed (JSON mapping w/ `createdAt` parsing, cache-fallback + stale marking on `DioException`, upload sequencing incl. step-1-failure-blocks-step-2, `galleryMediaUrl` derivation).
  - `flutter test` (full suite) — 124/124 passed, no regressions.
  - `flutter analyze lib/features/gallery test/features/gallery lib/core/di/service_locator.dart` — 0 errors/warnings (1 pre-existing-style `info` lint, `use_null_aware_elements`, matches this codebase's existing tolerance, e.g. `AuthRepository`'s own unaddressed `prefer_initializing_formals` info).
  - `flutter pub get` resolved `image_picker: 1.2.3` and `cached_network_image: 3.4.1` cleanly.
- P5 verification confirmation (2026-07-31): no P0 defect found. `coding-plan/test-results.md` §4 confirms `gallery_api.dart` uses the shared `Dio` and never touches `Epic4PrivateGalleryApi`, `DELETE /gallery`, or any encryption path, and §2.2 confirms the single `GET /gallery` read path carries no client-side workaround for BLOCKER-1. The one remaining `use_null_aware_elements` `info` at `gallery_api.dart:88` is informational and was left unchanged.
