# Phase P4 – Full-Screen Photo Viewer

## 1. Objective

Deliver the chromeless full-screen viewer opened from a grid tile: swipe
navigation in grid order, pinch-to-zoom, letterboxed rendering, fading caption
overlay, and non-gesture equivalents for every gesture.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-gallery-viewer.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: YES (with P3; disjoint write scope)
- Write Scope:
  - `mobile/lib/features/gallery/presentation/screens/gallery_viewer_screen.dart`
  - `mobile/lib/features/gallery/presentation/widgets/gallery_viewer_photo.dart`
  - `mobile/test/features/gallery/gallery_viewer_test.dart`
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
  - `GalleryViewerScreen(items, initialIndex)` route opened by `GalleryGridView.onTileTap`
- Shared Interfaces Consumed:
  - `GalleryItem` and `galleryMediaUrl` from P0, `onTileTap` from P2
- Risk Surfaces:
  - Low-end Android image memory (R4)
  - Accessibility (UX §7)
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §4.4 and §6
  - consumer contract: viewer receives the already-loaded page items, it does not refetch
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC2
  - architecture: `../architecture/solution.md` §5 D-2 (full-resolution decode only in the viewer, one image at a time)
  - OQ constraints: no edit, delete, or report affordance in the viewer
  - upstream phase outputs: P0 model and URL builder, P2 tap callback
  - UX constraints: `../ux/uiux-spec.md` §4.4, §6, §7
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: viewer only
  - Source/Test File Count: 3 (2 new source, 1 test)
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §4.4, §6, §7
- `../architecture/solution.md` §5 D-2
- P0 and P2 outputs

## 3. Tasks

- Build `GalleryViewerScreen` on a `PageView` seeded with `initialIndex`, preserving the grid's chronological order and returning the grid to the same scroll position on dismiss.
- Build `GalleryViewerPhoto` with `InteractiveViewer` pinch-to-zoom and `BoxFit.contain` so non-matching aspect ratios letterbox rather than crop.
- Decode at full resolution only for the visible page; do not set a `memCacheWidth` cap here, and do not keep more than the adjacent pages alive.
- Render a caption overlay (date, location, uploader initial badge) that fades in on tap and fades out after roughly 2 seconds of no interaction.
- Provide an explicit close control positioned per platform convention (top-left on iOS, top-right on Android) in addition to swipe-down dismissal.
- Provide previous/next controls or screen-reader custom actions so navigation is never gesture-only; no edit, delete, or report affordance.

## 4. Acceptance Criteria

- Opening from grid index N shows item N, and swiping advances in the same order as the grid.
- Photos with an aspect ratio different from the device letterbox, with no cropping.
- Pinch-to-zoom changes the transform scale, asserted in a widget test.
- A visible close control is present and dismisses the viewer without a gesture.
- Previous/next navigation is reachable without a swipe gesture (control or semantic custom action).
- The caption overlay is hidden by default and appears on tap.
- No edit, delete, or report control exists in the viewer.

## 5. Planned Outputs

- Code: `gallery_viewer_screen.dart`, `gallery_viewer_photo.dart`
- Contracts: `GalleryViewerScreen(items, initialIndex)`
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, viewer
- Required levels:
  - integration: widget tests for initial index, page navigation, close control, non-gesture nav affordance, caption toggle
  - unit: zoom transform assertion
  - visual inspection: viewer composition against `../ux/uiux-spec.md` §4.4
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: `BoxFit.contain` asserted on the photo widget
- Minimum gates by risk surface: UX §7 non-gesture equivalents asserted in widget tests
- Evidence format: test names plus pass/fail counts recorded in the phase status
- Verification strategy:
  - Targeted tests: `flutter test test/features/gallery/gallery_viewer_test.dart`
  - Static analysis: `flutter analyze`

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-31
