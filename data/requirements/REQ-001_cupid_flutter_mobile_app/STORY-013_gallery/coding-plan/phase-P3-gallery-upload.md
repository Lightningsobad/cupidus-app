# Phase P3 – Gallery Upload Sheet

## 1. Objective

Deliver AC1: multi-select photo upload from the device library with per-item
progress, per-item retry, an offline-disabled state, and the platform
permission entries the picker requires.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-gallery-upload.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: YES (with P4; disjoint write scope)
- Write Scope:
  - `mobile/lib/features/gallery/presentation/gallery_upload_cubit.dart`
  - `mobile/lib/features/gallery/presentation/gallery_upload_state.dart`
  - `mobile/lib/features/gallery/presentation/widgets/gallery_upload_sheet.dart`
  - `mobile/lib/features/gallery/presentation/widgets/gallery_upload_item.dart`
  - `mobile/android/app/src/main/AndroidManifest.xml`
  - `mobile/ios/Runner/Info.plist`
  - `mobile/test/features/gallery/gallery_upload_cubit_test.dart`
  - `data/requirements/REQ-001_cupid_flutter_mobile_app/deployment/configuration-guide.md`
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
  - `GalleryUploadCubit` / `GalleryUploadState` (per-item `queued | uploading | done | failed`)
  - Upload-success callback feeding `GalleryCubit.insertOptimistic`
- Shared Interfaces Consumed:
  - `GalleryRepository.uploadPhoto` from P0, `GalleryCubit` from P1, add-photo callback from P2
- Risk Surfaces:
  - Upload contract + 10 MB limit
  - Accessibility (UX §7)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §4 upload sequence, §5 D-2 downscale params
  - consumer contract: `POST /uploads` then `POST /gallery`, per item
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC1, `## Open Question Impact`
  - architecture: `../architecture/solution.md` §4, §5 D-2
  - OQ constraints: no offline write queue; no encryption of the payload
  - upstream phase outputs: P0 repository, P1 cubit, P2 add-photo affordance
  - UX constraints: `../ux/uiux-spec.md` §4.3, §5, §7
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: YES
  - Sections To Update: mobile platform permissions — add the photo-library entries this phase introduces (`NSPhotoLibraryUsageDescription` on iOS, `READ_MEDIA_IMAGES` on Android 13+)
- Phase Sizing:
  - Behavior Slice: upload flow only
  - Source/Test File Count: 6 source/test files plus 2 manifest edits and 1 doc edit
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` AC1 and `## Open Question Impact`
- `../ux/uiux-spec.md` §4.3, §5, §7
- `../architecture/solution.md` §4 upload sequence, §5 D-2
- P0, P1, P2 outputs

## 3. Tasks

- Implement `GalleryUploadCubit` holding a list of per-item upload records; `pick()` uses `image_picker.pickMultiImage(maxWidth: 2048, maxHeight: 2048, imageQuality: 85)` so payloads stay under the 10 MB multer limit.
- Upload items sequentially with at most 2 concurrent requests, driving each item's progress from the `POST /uploads` `onSendProgress` callback.
- On per-item success, call `GalleryCubit.insertOptimistic` with the created `GalleryItem` so the tile appears at grid head.
- On per-item failure, mark only that item `failed` and expose a retry that restarts that item from `POST /uploads`; never restart the whole batch.
- Build `GalleryUploadSheet` as an `r-sheet` (28 px) bottom sheet with a horizontal strip of selected thumbnails; keep it dismissible mid-upload with uploads continuing in the background.
- Build `GalleryUploadItem` rendering queued / progress ring / done checkmark / failed states, with a text equivalent for each state (not color or icon alone) and live-region announcements per UX §7.
- When offline, disable the picker and show the inline "no connection" message; do not queue.
- Add the platform permission entries and record them in the requirement configuration guide.

## 4. Acceptance Criteria

- Selecting N photos produces N independent upload records; a failure in one leaves the others unaffected.
- Retry on a failed item issues `POST /uploads` again for that item only.
- A step-1 (`POST /uploads`) failure never issues `POST /gallery` for that item.
- Successful upload inserts a tile at grid head without a full refetch (AC1).
- Picker invocation passes `maxWidth: 2048`, `maxHeight: 2048`, `imageQuality: 85`, asserted in a unit test.
- Offline state disables the picker and renders the explanatory message; no queued write is persisted.
- Every per-item state exposes a text equivalent readable by a screen reader.
- Both platform manifests contain the photo-library entries, and the configuration guide documents them.

## 5. Planned Outputs

- Code: upload cubit, upload state, upload sheet, upload item widget
- Contracts: `GalleryUploadCubit` / `GalleryUploadState`
- Requirement configuration guide updates: mobile photo-library permission entries
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, upload flow
- Required levels:
  - unit: `gallery_upload_cubit_test.dart` covering per-item state transitions, retry isolation, step-1-failure short-circuit, downscale params, offline branch
  - integration: widget test over the sheet for per-item state rendering and text equivalents
  - visual inspection: sheet composition against `../ux/uiux-spec.md` §4.3
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: manifest entries present in both platform files
- Minimum gates by risk surface: upload contract asserted against a faked repository; UX §7 text equivalents asserted in the widget test
- Evidence format: test names plus pass/fail counts recorded in the phase status
- Verification strategy:
  - Targeted tests: `flutter test test/features/gallery/gallery_upload_cubit_test.dart`
  - Static analysis: `flutter analyze`

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-31
