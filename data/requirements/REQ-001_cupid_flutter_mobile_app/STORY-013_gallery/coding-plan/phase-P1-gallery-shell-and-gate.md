# Phase P1 – Gallery Shell, State Machine, And Pairing Gate

## 1. Objective

Introduce the gallery state machine, the screen host, the unpaired gate
(`gallery-locked`, AC3), and mount the gallery as a discoverable tab in
`AppShell` so the feature is reachable rather than orphaned.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-gallery-shell-and-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P0
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/gallery/presentation/gallery_cubit.dart`
  - `mobile/lib/features/gallery/presentation/gallery_state.dart`
  - `mobile/lib/features/gallery/presentation/screens/gallery_screen.dart`
  - `mobile/lib/features/gallery/presentation/widgets/gallery_locked_view.dart`
  - `mobile/lib/core/navigation/app_shell.dart`
  - `mobile/test/features/gallery/gallery_cubit_test.dart`
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
  - `GalleryCubit` / `GalleryState` (`loading`, `locked`, `empty`, `loaded`, `failure`; `loaded` carries `items`, `isStale`, `hasMore`, `currentUserId`)
  - Gallery tab entry point in `AppShell`
- Shared Interfaces Consumed:
  - `GalleryRepository`, `GalleryItem` from P0
- Risk Surfaces:
  - Pairing gate (AC3)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §4 Contracts And Integrations
  - consumer contract: presentation reads state only from `GalleryCubit`
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC3, `## Open Question Impact`
  - architecture: `../architecture/solution.md` §2, §4
  - OQ constraints: gate must be an access-state, never a lock/encryption state
  - upstream phase outputs: P0 `GalleryRepository`
  - UX constraints: `../ux/uiux-spec.md` §3 flow map, §4.5 `gallery-locked`, §7 gate CTA bullet
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: state machine plus gate plus entry point
  - Source/Test File Count: 6 (4 new source, 1 edit, 1 test)
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` AC3 and `## Open Question Impact`
- `../ux/uiux-spec.md` §3, §4.5, §7
- P0 outputs (`GalleryRepository`, `GalleryItem`)
- `mobile/lib/core/navigation/app_shell.dart`, `mobile/lib/features/auth/presentation/sign_in_cubit.dart` as the Cubit pattern reference

## 3. Tasks

- Define `GalleryState` with `loading`, `locked`, `empty`, `loaded`, `failure` variants.
- Implement `GalleryCubit.load()`: resolve `GET /users/me` first; when `partnerId` is null emit `locked` and issue no `GET /gallery` call; otherwise fetch page 0 and emit `empty` or `loaded` with `currentUserId` set for uploader attribution.
- Implement `refresh()` (pull-to-refresh, resets to offset 0) and `loadMore()` (offset += 30, no-op while already loading or when `hasMore` is false); expose `insertOptimistic(GalleryItem)` for P3.
- Build `GalleryScreen` as the state-driven host with the adaptive header, rendering the locked view for `locked` and delegating `empty`/`loaded` to P2 widgets (temporary placeholders until P2 lands).
- Build `GalleryLockedView` using the `link_off`-style icon, headline, supporting copy, and a CTA routing to the existing pairing/invite flow. Do not use lock or fingerprint iconography.
- Mount the gallery as a discoverable tab in `AppShell` (bottom-nav destination with label and icon), not a direct-route-only screen.

## 4. Acceptance Criteria

- `partnerId == null` emits `locked` and no `GET /gallery` request is made (AC3).
- `partnerId != null` with an empty list emits `empty`; with items emits `loaded` carrying `currentUserId`.
- A repository failure with a cached snapshot emits `loaded` with `isStale: true`; with no cache it emits `failure`.
- `AppShell` exposes a labelled gallery destination that opens `GalleryScreen`.
- The locked view CTA has a screen-reader label describing navigation to the pairing flow, and contains no lock/biometric iconography or copy.

## 5. Planned Outputs

- Code: `mobile/lib/features/gallery/presentation/` (cubit, state, screen, locked view)
- Contracts: `GalleryCubit` / `GalleryState`
- Notes: none

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, state and navigation
- Required levels:
  - unit: `gallery_cubit_test.dart` covering locked / empty / loaded / stale / failure transitions with a faked repository
  - visual inspection: locked-state composition against `../ux/uiux-spec.md` §4.5
  - mobile build/type-check/static-analysis: `flutter analyze` clean
- Required checks: no `GET /gallery` call in the locked branch, asserted on the fake
- Mobile discoverability / navigation integration: gallery destination present in `AppShell` and reachable by tap in a widget test
- Minimum gates by risk surface: pairing gate covered in both branches
- Evidence format: test names plus pass/fail counts recorded in the phase status
- Verification strategy:
  - Targeted tests: `flutter test test/features/gallery/`
  - Static analysis: `flutter analyze`

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-07-31
