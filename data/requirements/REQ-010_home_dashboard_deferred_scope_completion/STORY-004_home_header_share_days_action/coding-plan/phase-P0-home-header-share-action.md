# Phase P0 – Home Header Share Days-Together Action

## 1. Objective

Add a native-share capability to the app and wire it to a new share icon in the
Home dashboard hero header, so tapping the icon opens the OS share sheet with
the current days-together text.

## 1A. Ownership

- Phase ID: P0
- Canonical Phase File: `phase-P0-home-header-share-action.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/pubspec.yaml`
  - `mobile/pubspec.lock`
  - `mobile/lib/features/home/presentation/home_screen.dart`
  - `mobile/test/features/home/home_screen_test.dart`
  - `mobile/android/app/src/main/AndroidManifest.xml` (only if the resolved
    package's own README requires a manifest entry)
  - `mobile/ios/Runner/Info.plist` (only if the resolved package's own README
    requires a plist entry)
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE at phase level — owned by the story's
    verification step per `master-plan.md` section 4, not by this phase's tests
  - Build Command Source: runtime registry `buildCommand`
    (`flutter build apk --debug`)
  - Startup Command Source: runtime registry `runCommand` / `scripts/run-mobile.sh`
  - Readiness Check: N/A at phase level
  - Port Contract: N/A
- Risk Surfaces:
  - Unverified third-party API shape
  - Native plugin breaks app launch
  - Share payload correctness across locale and null-days
  - Header layout regression
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` section 4;
    `../ux/uiux-spec.md` §1 (tokens/structure) and §2 (payload, null-days rule)
  - consumer contract: none — no downstream consumer in this story
- Primary Inputs Summary:
  - requirements: `../story_master.md` Acceptance Criteria 1-3
  - architecture: `../architecture/solution.md` sections 1, 4
  - UX constraints: `../ux/uiux-spec.md` §1 and §2 — required; they carry the
    only authoritative token values and the null-days render rule
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one share affordance — dependency, header row, button,
    invocation, tests
  - Source/Test File Count: 4 (up to 6 with the two conditional native manifests)
  - Split Required: NO
  - Split Rationale: splitting the dependency line from its only consumer would
    create a phase whose whole output is one manifest line, and would let a build
    pass with nothing exercising the plugin.

## 2. Required Reads

- `../story_master.md`
- `../architecture/solution.md`
- `../ux/uiux-spec.md` §1 and §2
- the resolved `share_plus` package's own `README.md` in the pub cache, after
  `flutter pub add` (see Task 1)

## 3. Tasks

1. **Resolve the dependency, then read its API from the resolved package.**
   Run `flutter pub add share_plus` from `mobile/`. Flutter is not on this
   machine's PATH — prefix commands with
   `PATH="${FLUTTER_SDK_PATH:-$HOME/flutter}/bin:$PATH"` (runtime registry
   `mobile-app`, `resolvedBy` note). Then open the resolved package's own
   `README.md` and `lib/` in the pub cache and take from it: the import path, the
   exact plain-text share call signature, and whether iOS/iPad requires an
   origin-rect parameter or the platforms require a manifest/plist entry.
   Do NOT write the version constraint, import, or call signature from memory or
   from a tutorial — the API has changed across major versions and this
   repository has no prior usage to copy. If pub.dev is unreachable or no version
   is compatible with Dart SDK `^3.12.1`, stop with `SHARE_PACKAGE_UNRESOLVED`
   and do not substitute a clipboard implementation.
2. **Restructure the hero header top row.** In `home_screen.dart`, wrap the
   existing `_PresenceRow` (around line 337) and a new private header-actions row
   in a `Row` with `mainAxisAlignment: MainAxisAlignment.spaceBetween`.
   `_PresenceRow` stays intrinsically sized — do not wrap it in `Expanded`.
3. **Build the share button.** Inside the actions row, add the share action with
   the exact values from `../ux/uiux-spec.md` §1: width
   `context.cupidPlatform.tapTarget`, height `38`, centered content, icon size
   `23`, colour `colors.colorTextMuted`, glyph `CupidIcons.iosShare` on iOS and
   `CupidIcons.share` otherwise selected via `CupidPlatform.of(context)` (same
   branch shape as `cupid_add_action.dart`). Declare the `38` / `23` / `2`
   literals as file-local constants alongside the existing `_daysRowGap` /
   `_daysUnitFontSize` constants; do not map them onto `CupidSpacing`.
   Structure the actions row so STORY-005 can append a second icon as a sibling
   with a `2`px gap without touching the share subtree.
   Give the button a stable widget key (e.g. `Key('home_header_share_action')`)
   and an accessible label via `Semantics(label: _viEn(context, 'Chia sẻ số ngày
   bên nhau', 'Share days together'), button: true, ...)`.
4. **Gate rendering on a shareable value.** Render the share button only when the
   existing `int? days` (line 296) is non-null, matching the existing
   `if (days != null)` branch at line 342 (`../ux/uiux-spec.md` §2).
5. **Wire the invocation.** On tap, share the plain-text payload
   `_viEn(context, '$days ngày bên nhau rồi 💕', '$days days together 💕')` using
   the call signature resolved in Task 1. No subject, link, or attachment.
   Do not branch on the share result and do not show a snackbar, error state, or
   retry when the sheet is dismissed (AC3). Do not modify `invite_screen.dart`.
6. **Extend the Home widget tests** in the existing
   `mobile/test/features/home/home_screen_test.dart`.

## 4. Acceptance Criteria

- A share icon renders in the Home hero header at the §1 position, size, glyph,
  and colour, on both platform branches, in dark theme + `vi` locale (AC1).
- Tapping it invokes the native share sheet with exactly the §2 text for the
  currently displayed day count, in the active locale (AC2).
- The share icon does not render when `relationshipStartDate` is null.
- Dismissing the sheet produces no error state, snackbar, or crash (AC3).
- `_PresenceRow` keeps its existing appearance and position; existing Home tests
  still pass.

## 5. Planned Outputs

- Code: `mobile/pubspec.yaml`, `mobile/pubspec.lock`,
  `mobile/lib/features/home/presentation/home_screen.dart`
- Tests: `mobile/test/features/home/home_screen_test.dart`
- Notes or evidence: `coding-plan/test-results.md`, including the resolved
  `share_plus` version and the source (pub cache README) the call signature came
  from.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile — Home dashboard hero header
- Required levels:
  - unit: payload string composition for `vi` and `en`
  - mobile build/type-check/static-analysis: `flutter analyze`,
    `flutter build apk --debug`
  - visual inspection: header row against the locked design source
- Required checks:
  - share icon present when a day count renders; absent when
    `relationshipStartDate` is null
  - correct glyph per platform branch (`CupidIcons.iosShare` vs `CupidIcons.share`)
  - existing `home_days_counter` and `_PresenceRow` assertions still pass
- Mobile discoverability / navigation integration: the share icon is itself the
  entry point and must be mounted in the always-visible Home hero header — assert
  it is findable by its widget key on the Home screen as rendered, not only as an
  isolated widget.
- Minimum gates by risk surface:
  - Unverified third-party API shape: `flutter analyze` clean +
    `flutter build apk --debug` succeeds
  - Share payload correctness across locale and null-days: widget tests above
  - Header layout regression: existing Home widget tests pass + visual inspection
- Required regression coverage: full `flutter test` for
  `mobile/test/features/home/`
- Evidence format: command + result recorded in `coding-plan/test-results.md`
- Verification strategy:
  - Targeted tests: `flutter test test/features/home/home_screen_test.dart`
  - Build/type-check command: `flutter analyze` and `flutter build apk --debug`
    (prefix `PATH="${FLUTTER_SDK_PATH:-$HOME/flutter}/bin:$PATH"`)
  - Required assertion evidence: the share-tap test must assert the composed
    payload string, not merely that a tap handler fired.

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-08-25
