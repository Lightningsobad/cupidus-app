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
| P0 | Mobile Developer | Mobile | None | NO | `mobile/lib/features/gallery/domain/gallery_item.dart`, `mobile/lib/features/gallery/data/*`, `mobile/lib/core/di/service_locator.dart`, `mobile/pubspec.yaml`, `mobile/test/features/gallery/gallery_repository_test.dart` | `../architecture/solution.md` §2, §4 Contracts; `../requirements/requirements.md` AC1-AC3 | `GalleryItem`, `GalleryApi`, `GalleryRepository`, `GalleryLocalCache`, `galleryMediaUrl`, DI registration, new deps | unit tests, `flutter analyze` | DONE |
| P1 | Mobile Developer | Mobile | P0 | NO | `mobile/lib/features/gallery/presentation/gallery_cubit.dart`, `gallery_state.dart`, `screens/gallery_screen.dart`, `widgets/gallery_locked_view.dart`, `mobile/lib/core/navigation/app_shell.dart`, `mobile/test/features/gallery/gallery_cubit_test.dart` | P0 outputs; `../ux/uiux-spec.md` §3 flow map, §4.5; `../requirements/requirements.md` AC3 | Cubit + state machine, gallery screen host, pairing-gated view, gallery tab mounted in `AppShell` | unit + widget tests, `flutter analyze` | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | `mobile/lib/features/gallery/presentation/widgets/gallery_grid_view.dart`, `gallery_tile.dart`, `gallery_empty_view.dart`, `gallery_grid_columns.dart`, `mobile/test/features/gallery/gallery_grid_test.dart` | P0, P1 outputs; `../ux/uiux-spec.md` §4.1, §4.2, §6, §7; `../architecture/solution.md` §5 D-2 | Responsive grid, tile with caption chip + uploader badge, empty state, pagination + pull-to-refresh | unit + widget tests, `flutter analyze` | DONE |
| P3 | Mobile Developer | Mobile | P2 | YES (with P4) | `mobile/lib/features/gallery/presentation/gallery_upload_cubit.dart`, `gallery_upload_state.dart`, `widgets/gallery_upload_sheet.dart`, `widgets/gallery_upload_item.dart`, `mobile/android/app/src/main/AndroidManifest.xml`, `mobile/ios/Runner/Info.plist`, `mobile/test/features/gallery/gallery_upload_cubit_test.dart`, `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md` | P0, P1 outputs; `../ux/uiux-spec.md` §4.3, §5, §7; `../architecture/solution.md` §4 upload sequence | Multi-select upload sheet, per-item progress/retry, offline disabled state, permission entries, config guide update | unit + widget tests, `flutter analyze` | DONE |
| P4 | Mobile Developer | Mobile | P2 | YES (with P3) | `mobile/lib/features/gallery/presentation/screens/gallery_viewer_screen.dart`, `mobile/lib/features/gallery/presentation/widgets/gallery_viewer_photo.dart`, `mobile/lib/features/gallery/presentation/screens/gallery_screen.dart` (additive edit — wire in `GalleryGridView`/`GalleryEmptyView` per the P2 wiring gap), `mobile/test/features/gallery/gallery_viewer_test.dart` | P0, P2 outputs; `../ux/uiux-spec.md` §4.4, §6, §7 | Full-screen viewer, swipe nav, pinch-zoom, letterbox, fading caption, non-gesture close/nav controls; `gallery_screen.dart` renders `GalleryGridView`/`GalleryEmptyView` instead of placeholder `Text` widgets | unit + widget tests, `flutter analyze` | DONE |
| P5 | Mobile Developer | Mobile | P3, P4 | NO | `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-013_gallery/coding-plan/test-results.md` | all phase outputs; `../requirements/requirements.md` AC1-AC3 | Consolidated verification evidence and AC mapping | full `flutter test`, `flutter analyze`, `flutter build apk --debug`, mobile visual audit | DONE (verification ran, found BLOCKER-1/2/3; see P6) |
| P6 | Mobile Developer | Mobile | P5 | NO | `mobile/lib/features/gallery/presentation/screens/gallery_screen.dart`, `gallery_viewer_screen.dart`, `widgets/gallery_tile.dart`, `widgets/gallery_upload_item.dart`, `data/requirements/REQ-001_cupid_flutter_mobile_app/STORY-013_gallery/coding-plan/phase-P6-blocker-fix.md` | P5 verification blockers | Fix BLOCKER-2 (raw `Colors.*` fork-guard literals) and BLOCKER-3 (wire `GalleryUploadSheet`/`GalleryUploadCubit` into `gallery_screen.dart`) | targeted `flutter test`, `flutter analyze` | DONE (BLOCKER-2, BLOCKER-3 fixed, commit `324b1f35`; BLOCKER-1 explicitly out of mobile scope — see Risks, deferred pending backend AC2 fix) |

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
  - **P1 wiring gap (verified, analogous to STORY-012 P8)**: `GalleryLockedView`'s pairing CTA has no real pairing/invite screen to route to in this worktree — only `auth`, `gallery`, and the placeholder `home` features exist at this story's `BaseHead` (STORY-002's pairing/invite screens are not merged here). `GalleryLockedView.onPairingCta` was made a **required** callback (no silent default) and `GalleryScreen`'s default implementation shows a documented placeholder snackbar (`_showPairingFlowUnavailable`) instead of navigating anywhere. AC3's locked state IS reachable end-to-end from the mounted `AppShell` gallery tab (verified by the `AppShell gallery destination` widget test tapping the tab and asserting `GalleryScreen` mounts), but the CTA's actual navigation target still needs wiring once STORY-002's pairing screens land on the integration branch — Scrum Master/Tech Lead should route `onPairingCta` to the real pairing screen at that point.
- OQ-driven constraints: A1 frozen (no backend/OpenAPI change); Open Item #1 (no device-only encryption, biometric, auto-lock, screenshot detection); Open Item #3 (no delete/report affordance or `DELETE /gallery/{id}` call).
- Migration / rollout notes: none; additive mobile feature.
- Notes:
  - Do not use the generated `Epic4PrivateGalleryApi` — every method returns `Response<void>` and `/uploads` is absent from the OpenAPI spec. Use the shared `Dio` from `CupidApiClient` with hand-written JSON mapping.
  - `isEncrypted` and `encryptionKeyId` on `GalleryItem` are vestigial; ignore them and render no lock affordance (R3 closed as NO).
  - New pubspec dependencies (P0): `image_picker`, `cached_network_image`.
  - **P2 wiring gap**: `GalleryGridView` and `GalleryEmptyView` are not yet
    consumed by `gallery_screen.dart` (a P1 file, not in P2's Write Scope, and
    not currently listed in any later phase's Write Scope either).
    `GalleryScreen` still renders placeholder `Text` widgets for the
    `GalleryEmpty`/`GalleryLoaded` states. Scrum Master/Tech Lead should add
    `gallery_screen.dart` to P4's (or a dedicated) Write Scope so a future
    phase wires these widgets into the screen before P5 verification.
  - **P2 AC2 note**: BLOCKER-1 (AC2 couple-scoping gap, see Risks above) does
    not block grid wiring — `GalleryTile`'s uploader-badge variant is derived
    purely from `item.userId == currentUserId`, which renders correctly for
    whatever items the (currently user-scoped) repository returns. No P2 code
    depends on or works around the backend scoping gap.

## 7. Result Log

- P2 (Gallery Grid, Empty State, Responsive Columns) — DONE, 2026-07-31
  - Implemented: `mobile/lib/features/gallery/presentation/widgets/gallery_grid_columns.dart`,
    `gallery_tile.dart`, `gallery_empty_view.dart`, `gallery_grid_view.dart`,
    `mobile/test/features/gallery/gallery_grid_test.dart`.
  - `flutter analyze` (5 targeted files): No issues found.
  - `flutter test test/features/gallery/gallery_grid_test.dart`: 14 tests, All
    tests passed (0 failures).
  - Notes: see P2 wiring gap and P2 AC2 note above.
- Scrum Master routing (2026-07-31): the P2 wiring gap is resolved by adding
  `gallery_screen.dart` as an additive-edit entry to P4's Write Scope (see §5
  table above) instead of a dedicated phase, since P4 already touches the
  gallery viewer route that `gallery_screen.dart` navigates into.
- P4 (Gallery Viewer, Screen Wiring) — DONE, 2026-07-31
  - Implemented:
    `mobile/lib/features/gallery/presentation/widgets/gallery_viewer_photo.dart`
    (letterboxed `InteractiveViewer` pinch-zoom photo, no new pub dependency),
    `mobile/lib/features/gallery/presentation/screens/gallery_viewer_screen.dart`
    (chromeless `PageView`-based full-screen viewer: platform-positioned close
    control per `ux/uiux-spec.md` §4.4's chevron/arrow-back convention,
    always-visible prev/next on-screen buttons alongside swipe paging, and a
    tap-to-toggle/auto-hide-after-2s caption showing date + uploader
    attribution — no location field exists on `GalleryItem` at P0's scope, so
    it is omitted rather than invented), and an additive edit to
    `mobile/lib/features/gallery/presentation/screens/gallery_screen.dart`
    that closes the P2 wiring gap: `GalleryEmpty`/`GalleryLoaded` now render
    the real `GalleryEmptyView`/`GalleryGridView` (replacing the placeholder
    `Text` widgets) and grid tile taps push `GalleryViewerScreen` at the
    tapped index; the add-photo affordance shows a placeholder snackbar
    (`_showUploadFlowUnavailable`, mirroring the existing pairing-CTA
    placeholder pattern) since P3's upload sheet has not landed in this
    worktree.
  - Added `mobile/test/features/gallery/gallery_viewer_test.dart`: 5 widget
    tests covering initial-index rendering, swipe paging in both directions,
    the on-screen prev/next buttons, close-button back navigation, and a
    grid-to-viewer wiring test (identical wiring to `gallery_screen.dart`)
    asserting a tile tap opens the viewer at the tapped index and the close
    button returns to the grid.
  - `flutter analyze` (4 touched files: `gallery_viewer_screen.dart`,
    `gallery_viewer_photo.dart`, `gallery_screen.dart`,
    `gallery_viewer_test.dart`): No issues found.
  - `flutter test test/features/gallery/gallery_viewer_test.dart`: 5 tests,
    all passed (0 failures).
  - `flutter test test/features/gallery/`: full gallery suite (31 tests
    across `gallery_viewer_test.dart`, `gallery_cubit_test.dart`,
    `gallery_grid_test.dart`, `gallery_repository_test.dart`) — all passed
    (0 failures), confirming the `gallery_screen.dart` wiring change causes
    no regression (including the existing `AppShell gallery destination`
    test in `gallery_cubit_test.dart`).
  - P2 wiring gap: confirmed closed — `gallery_screen.dart` now renders
    `GalleryGridView`/`GalleryEmptyView` from cubit state instead of
    placeholder `Text` widgets.
  - No P0/P1/P2 data/domain files were touched; no new pub dependency was
    added.
- P3 (Gallery Upload Sheet) — DONE, 2026-07-31
  - Implemented:
    `mobile/lib/features/gallery/presentation/gallery_upload_state.dart`
    (`GalleryUploadRecord`/`GalleryUploadState`, one independent record per
    selected photo), `gallery_upload_cubit.dart` (`GalleryUploadCubit`: picks
    via an overridable `GalleryImagePicker` seam at the R4/D-2 downscale
    budget of 2048x2048/quality 85, a bounded 2-worker upload pool driving
    `GalleryRepository.uploadPhoto`'s existing two-step `POST /uploads` then
    `POST /gallery` sequence per item, per-item `retry`, and an overridable
    `GalleryConnectivityCheck` seam — no `connectivity_plus` dependency added
    since `pubspec.yaml` is outside this phase's write scope; defaults to a
    real DNS-lookup probe), `widgets/gallery_upload_item.dart` (per-item
    thumbnail + progress ring/checkmark/retry glyph with a `Semantics`
    live-region text equivalent for every status per UX §7), and
    `widgets/gallery_upload_sheet.dart` (`r-sheet` 28px modal bottom sheet,
    horizontal thumbnail strip, offline message that disables the pick
    button instead of queueing per UX §5).
  - Platform permissions: added
    `android.permission.READ_MEDIA_IMAGES` to
    `mobile/android/app/src/main/AndroidManifest.xml` and
    `NSPhotoLibraryUsageDescription` to `mobile/ios/Runner/Info.plist`;
    documented both in a new "Photo Library Permissions (STORY-013)" section
    of `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`.
  - Added `mobile/test/features/gallery/gallery_upload_cubit_test.dart`: 11
    tests covering the offline-disables-picker branch, the downscale params
    passed to the picker, N independent per-item records with one failure
    not affecting its sibling, the step-1-failure-never-issues-step-2
    contract, retry restarting only the failed item, per-item
    text-equivalent semantics for every status, tap-to-retry, and
    `GalleryUploadSheet` rendering (offline message/disabled button, one
    `GalleryUploadItem` per selection). The two multi-file-upload widget
    tests exercise the cubit's real `MultipartFile`/Dio path through
    `tester.runAsync`, since real dart:io async I/O never resolves under
    `testWidgets`' faked-timer zone otherwise.
  - `flutter analyze` (5 touched files: `gallery_upload_cubit.dart`,
    `gallery_upload_state.dart`, `gallery_upload_sheet.dart`,
    `gallery_upload_item.dart`, `gallery_upload_cubit_test.dart`): No issues
    found.
  - `flutter test test/features/gallery/`: full gallery suite, 40 tests, all
    passed (0 failures) — confirms no regression in the existing P0-P2/P4
    gallery tests.
  - Scope discipline: `gallery_screen.dart`, `gallery_viewer_screen.dart`,
    and `gallery_viewer_photo.dart` were not touched. Wiring
    `GalleryUploadSheet`/`GalleryUploadCubit` into `gallery_screen.dart`'s
    add-photo affordance (replacing the P4 placeholder snackbar) is left to
    a future phase, since `gallery_screen.dart` is outside this phase's
    write scope.
