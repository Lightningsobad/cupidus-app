# Master Coding Plan – STORY-013 Shared Gallery

## 1. Planning Metadata

- Story ID: STORY-013
- Complexity: M (`standard`)
- Planning Owner: Tech Lead
- Source Requirements: `../requirements/requirements.md`
- Source UX: `../ux/uiux-spec.md` (§2 screen inventory, §4 screen detail, §5 freshness, §6 responsive, §7 accessibility)
- Source Architecture: `../architecture/solution.md`
- OQ Constraints Source: `../requirements/requirements.md` `## Open Question Impact`
- Review Input: none yet
- Requirement Configuration Guide: `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`

## 2. Planning Goal

- Shared contract owner: Mobile Developer (P0 owns `GalleryRepository` + `GalleryItem`; backend contract itself is frozen and externally owned)
- Contract-first phase required: YES (P0)
- Parallel execution possible: YES (P3 and P4 after P2)
- Critical path: P0 -> P1 -> P2 -> P4 -> P5
- Parallelism notes: P3 (upload sheet) and P4 (viewer + grid tap) touch disjoint files and may run concurrently once P2 is DONE. All other phases are sequential.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Connection Pattern | Producer Phase | Consumer Phase | Example Artifact / Payload |
|---|---|---|---|---|---|
| `GET /gallery?limit=&offset=` | Backend (frozen, A1) | REST over shared `Dio` | external | P0 | `[{ id, userId, filename, thumbnailUrl, mimeType, createdAt }]` |
| `POST /uploads` | Backend (frozen, A1) | multipart field `file`, <= 10 MB | external | P0, P3 | `{ url, filename, originalName, mimeType, size }` |
| `POST /gallery` | Backend (frozen, A1) | REST JSON | external | P0, P3 | `{ filename, mimeType }` |
| `GET /users/me` | Backend (frozen) | REST JSON | external | P0, P1 | `{ id, partnerId, ... }` |
| `GalleryItem` (Dart) + `GalleryRepository` | Mobile Developer | `get_it` singleton | P0 | P1, P2, P3, P4 | `features/gallery/domain/gallery_item.dart` |
| `galleryMediaUrl(filename)` | Mobile Developer | pure function | P0 | P2, P4 | `${CupidApiConfig.baseUrl}/uploads/${filename}` |
| `GalleryCubit` / `GalleryState` | Mobile Developer | `flutter_bloc` | P1 | P2, P3, P4 | `locked / loading / empty / loaded / failure` |
| Gallery tab mount in `AppShell` | Mobile Developer | widget tree | P1 | P5 | `core/navigation/app_shell.dart` |

## 3A. Risk Surfaces And Verification Contract

| Risk Surface | Source Of Truth | Consumer Contract | Minimum Gate | Required Dependency | Blocker If Gate Cannot Run |
|---|---|---|---|---|---|
| Gallery read contract | `backend/src/modules/gallery/gallery.controller.ts` | `GalleryItem[]` mapping | P0 repository unit test on a recorded JSON fixture | none | AC2 rendering unverifiable |
| Upload contract + 10 MB limit | `backend/src/modules/uploads/uploads.controller.ts` | multipart `file` | P0/P3 unit test asserting picker downscale params | none | 413 at runtime |
| Media URL derivation | `backend/src/app.module.ts` (`serveRoot: '/uploads'`) | `galleryMediaUrl` | P0 unit test | none | Broken thumbnails |
| Pairing gate (AC3) | `GET /users/me.partnerId` | null -> locked state | P1 Cubit unit test, both branches | P0 | AC3 unverifiable |
| Low-end Android image memory (R4) | `../architecture/solution.md` §5 D-2 | decode-constrained tiles | P2 widget test asserts `memCacheWidth` set on every tile | P0 | R4 unmitigated |
| Accessibility (UX §7) | `../ux/uiux-spec.md` §7 | semantic labels, non-gesture equivalents | P2/P3/P4 widget tests on `Semantics` labels and visible controls | P1 | UX §7 unverifiable |
| Shared visibility (AC2) | `gallery.service.ts` `findAll` (user-scoped) | see solution BLOCKER-1 | **Cannot run in this story** | backend follow-up | **AC2 blocked — escalate before review** |

## 4. Lane Summary

- Backend required: NO
- Frontend required: NO
- Mobile required: YES
- DevOps required: NO
- Initial implementation owner: Mobile Developer
- Final verification owner: Mobile Developer
- Shared contract owner: Mobile Developer (P0)
- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` for implementation phases; readiness is the `Key('home_screen_ready_signal')` widget-test signal, exercised by `flutter test` in P5. Build/test commands come from `data/devops/system/runtime-command-registry.json` (`mobile-app.buildCommand`, `mobile-app.testCommand`).

## 5. Phases Overview

The following table is mandatory. Keep all columns exactly as shown so Scrum
Master and implementation agents can route phases without guessing.

| Phase | Owner | Lane | Depends On | Parallelizable | Write Scope | Primary Inputs | Planned Outputs | Test Scope | Status |
|---|---|---|---|---|---|---|---|---|---|
| P0 | Mobile Developer | Mobile | None | NO | `mobile/lib/features/gallery/domain/gallery_item.dart`, `mobile/lib/features/gallery/data/*`, `mobile/lib/core/di/service_locator.dart`, `mobile/pubspec.yaml`, `mobile/test/features/gallery/gallery_repository_test.dart` | `../architecture/solution.md` §2, §4 Contracts; `../requirements/requirements.md` AC1-AC3 | `GalleryItem`, `GalleryApi`, `GalleryRepository`, `GalleryLocalCache`, `galleryMediaUrl`, DI registration, new deps | unit tests, `flutter analyze` | NOT_STARTED |
| P1 | Mobile Developer | Mobile | P0 | NO | `mobile/lib/features/gallery/presentation/gallery_cubit.dart`, `gallery_state.dart`, `screens/gallery_screen.dart`, `widgets/gallery_locked_view.dart`, `mobile/lib/core/navigation/app_shell.dart`, `mobile/test/features/gallery/gallery_cubit_test.dart` | P0 outputs; `../ux/uiux-spec.md` §3 flow map, §4.5; `../requirements/requirements.md` AC3 | Cubit + state machine, gallery screen host, pairing-gated view, gallery tab mounted in `AppShell` | unit + widget tests, `flutter analyze` | NOT_STARTED |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/features/gallery/presentation/widgets/gallery_grid_view.dart`, `gallery_tile.dart`, `gallery_empty_view.dart`, `gallery_grid_columns.dart`, `mobile/test/features/gallery/gallery_grid_test.dart` | P0, P1 outputs; `../ux/uiux-spec.md` §4.1, §4.2, §6, §7; `../architecture/solution.md` §5 D-2 | Responsive grid, tile with caption chip + uploader badge, empty state, pagination + pull-to-refresh | unit + widget tests, `flutter analyze` | NOT_STARTED |
| P3 | Mobile Developer | Mobile | P2 | YES (with P4) | `mobile/lib/features/gallery/presentation/gallery_upload_cubit.dart`, `gallery_upload_state.dart`, `widgets/gallery_upload_sheet.dart`, `widgets/gallery_upload_item.dart`, `mobile/android/app/src/main/AndroidManifest.xml`, `mobile/ios/Runner/Info.plist`, `mobile/test/features/gallery/gallery_upload_cubit_test.dart`, `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` | P0, P1 outputs; `../ux/uiux-spec.md` §4.3, §5, §7; `../architecture/solution.md` §4 upload sequence | Multi-select upload sheet, per-item progress/retry, offline disabled state, permission entries, config guide update | unit + widget tests, `flutter analyze` | NOT_STARTED |
| P4 | Mobile Developer | Mobile | P2 | YES (with P3) | `mobile/lib/features/gallery/presentation/screens/gallery_viewer_screen.dart`, `mobile/lib/features/gallery/presentation/widgets/gallery_viewer_photo.dart`, `mobile/test/features/gallery/gallery_viewer_test.dart` | P0, P2 outputs; `../ux/uiux-spec.md` §4.4, §6, §7 | Full-screen viewer, swipe nav, pinch-zoom, letterbox, fading caption, non-gesture close/nav controls | unit + widget tests, `flutter analyze` | NOT_STARTED |
| P5 | Mobile Developer | Mobile | P3, P4 | NO | `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-013_gallery/coding-plan/test-results.md` | all phase outputs; `../requirements/requirements.md` AC1-AC3 | Consolidated verification evidence and AC mapping | full `flutter test`, `flutter analyze`, `flutter build apk --debug`, mobile visual audit | NOT_STARTED |

The final phase must be a verification phase for `standard` and `complex`
stories. Tech Lead work is incomplete until that phase file exists.

Phase file mapping:

| Phase | Canonical Phase File |
|---|---|
| P0 | `phase-P0-gallery-data-contract.md` |
| P1 | `phase-P1-gallery-shell-and-gate.md` |
| P2 | `phase-P2-gallery-grid.md` |
| P3 | `phase-P3-gallery-upload.md` |
| P4 | `phase-P4-gallery-viewer.md` |
| P5 | `phase-P5-verification.md` |

Artifact hygiene:

- Each phase id in the table above maps to exactly one canonical
  `phase-Px-*.md` file.
- Do not leave duplicate files for the same phase id.
- Backend/frontend/mobile implementation phases must fit one specialist lifecycle
  (roughly six source/test files max) or be split.
- Implementation phase test scopes must not include backend e2e/test_e2e,
  Playwright/browser e2e, traces, or scenario reruns.

## 6. Risks And Notes

- Risks:
  - **BLOCKER-1 (AC2)**: `GET /gallery` is user-scoped, not couple-scoped, so a partner's photos are never returned. A1 forbids fixing it here. The mobile build is written so no client change is needed once the backend is couple-scoped, but AC2 cannot pass review as-is. Scrum Master must route a backend story or accept AC2 as deferred. See `../architecture/solution.md` §7.
  - Two-step upload (`POST /uploads` then `POST /gallery`) is not transactional; a step-2 failure leaves an orphaned file. Accepted.
- OQ-driven constraints: A1 frozen (no backend/OpenAPI change); Open Item #1 (no device-only encryption, biometric, auto-lock, screenshot detection); Open Item #3 (no delete/report affordance or `DELETE /gallery/{id}` call).
- Migration / rollout notes: none; additive mobile feature.
- Notes:
  - Do not use the generated `Epic4PrivateGalleryApi` — every method returns `Response<void>` and `/uploads` is absent from the OpenAPI spec. Use the shared `Dio` from `CupidApiClient` with hand-written JSON mapping.
  - `isEncrypted` and `encryptionKeyId` on `GalleryItem` are vestigial; ignore them and render no lock affordance (R3 closed as NO).
  - New pubspec dependencies (P0): `image_picker`, `cached_network_image`.
