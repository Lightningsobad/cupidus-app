# Phase P2 – Gallery Grid, Empty State, And Responsive Columns

## 1. Objective

Render the shared gallery grid with uploader attribution, the empty state,
responsive column rules, pagination, pull-to-refresh, and the R4 image-decode
budget.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-gallery-grid.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/gallery/presentation/widgets/gallery_grid_view.dart`
  - `mobile/lib/features/gallery/presentation/widgets/gallery_tile.dart`
  - `mobile/lib/features/gallery/presentation/widgets/gallery_empty_view.dart`
  - `mobile/lib/features/gallery/presentation/widgets/gallery_grid_columns.dart`
  - `mobile/test/features/gallery/gallery_grid_test.dart`
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
  - `GalleryGridView` with an `onTileTap(index)` callback consumed by P4
  - `galleryColumnCount(double widthDp)` resolver
  - Add-photo affordance callback consumed by P3
- Shared Interfaces Consumed:
  - `GalleryCubit` / `GalleryState` from P1, `GalleryItem` and `galleryMediaUrl` from P0
- Risk Surfaces:
  - Low-end Android image memory (R4)
  - Accessibility (UX §7)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §5 D-2 performance budget
  - consumer contract: every remote image widget must set a decode width cap
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC1-AC2
  - architecture: `../architecture/solution.md` §5 D-2
  - OQ constraints: no delete/report affordance on tiles
  - upstream phase outputs: P0 model and URL builder, P1 state machine
  - UX constraints: `../ux/uiux-spec.md` §4.1, §4.2, §6, §7
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: grid presentation only
  - Source/Test File Count: 5 (4 new source, 1 test)
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §4.1, §4.2, §6, §7
- `../architecture/solution.md` §5 D-2
- P0 and P1 outputs
- `mobile/lib/design_system/tokens/`, `mobile/lib/design_system/adaptive/cupid_add_action.dart`

## 3. Tasks

- Implement `galleryColumnCount(widthDp)`: 2 columns below 430 dp, 3 columns at or above 430 dp. Width-based only, not orientation-based.
- Build `GalleryTile`: fixed `aspect-ratio: 3/4`, `r-sm` radius and shadow tokens, `cached_network_image` with `memCacheWidth` set to tile width in physical pixels capped at 640, bottom-left date/location caption chip over a `rgba(23,17,41,.6)` scrim, and a 24 px uploader-initial badge top-right derived from `item.userId == state.currentUserId`.
- Give every tile a `Semantics` label combining date, location, and uploader (UX §7).
- Build `GalleryEmptyView` per UX §4.1: soft icon at low opacity, headline, supporting copy, and an adaptive CTA via `cupid_add_action.dart`.
- Build `GalleryGridView` on `GridView.builder` with `addAutomaticKeepAlives: false`, `addRepaintBoundaries: true`, no `shrinkWrap`; pinned dashed add-photo tile as the **last** cell; `RefreshIndicator` pull-to-refresh; `loadMore()` triggered when the last 6 tiles enter the viewport; shimmer skeleton tiles while the next page loads.
- Wire `onTileTap` and the add-photo callback as no-ops for now; P4 and P3 attach the real destinations.

## 4. Acceptance Criteria

- `galleryColumnCount` returns 2 below 430 dp and 3 at or above 430 dp, asserted at both boundaries.
- Every rendered tile passes a non-null `memCacheWidth` no greater than 640.
- The add-photo tile is the last cell in the grid, never the first.
- A tile whose `userId` differs from `currentUserId` renders the partner badge variant; a matching one renders the self variant.
- Each tile exposes a semantic label containing date and uploader.
- Reaching the tail triggers exactly one `loadMore()` call, not one per frame.
- No delete, report, or lock affordance exists anywhere in the grid.

## 5. Planned Outputs

- Code: `mobile/lib/features/gallery/presentation/widgets/`
- Contracts: `GalleryGridView` tap and add callbacks, `galleryColumnCount`
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, widget layer
- Required levels:
  - unit: `galleryColumnCount` boundary assertions
  - integration: widget tests over the grid for pagination trigger, add-tile position, badge variants, and semantics labels
  - visual inspection: grid composition against `../ux/uiux-spec.md` §4.2 at 360 dp and 430 dp
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: `memCacheWidth` assertion on every tile widget
- Minimum gates by risk surface: R4 decode cap and UX §7 semantic labels both asserted in widget tests
- Evidence format: test names plus pass/fail counts recorded in the phase status
- Verification strategy:
  - Targeted tests: `flutter test test/features/gallery/gallery_grid_test.dart`
  - Static analysis: `flutter analyze`

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-31
