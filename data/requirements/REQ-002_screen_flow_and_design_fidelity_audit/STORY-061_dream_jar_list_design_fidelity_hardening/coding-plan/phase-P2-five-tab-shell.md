# Phase P2 – Five-tab shell and preview mirror (AC8, AC9 evidence)

## 1. Objective

Convert `AppShell` from 3-tabs-plus-account-FAB to the design's 5 destinations
(Nhà / Trò chuyện / Pet / Ví chung / Tôi), mirror the change in the preview
harness so AC8 is visible in the AC9 capture, preserve Gallery's reachability,
and capture the AC9 evidence pair covering AC1-AC8.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-five-tab-shell.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/navigation/app_shell.dart`
  - `mobile/lib/preview/preview_app_shell_chrome.dart`
  - `mobile/lib/main_preview.dart` (the `activeTab` switch and the `jarlist`
    seed note only)
  - `mobile/lib/features/home/presentation/home_screen.dart` (Gallery entry card)
  - `mobile/test/core/navigation/app_shell_test.dart`
  - `mobile/test/features/home/home_screen_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Consumed:
  - `DreamJarListScreen(repository:)`, already resolvable via
    `getIt<DreamJarRepository>()`
- Risk Surfaces:
  - Shell destination regression
  - Gallery entry-point orphaning
  - Preview/production shell divergence
  - Design-reference conformance (AC9)
- Source Of Truth:
  - authoritative artifact: `../architecture/solution.md` §4 and
    `### Key Discovery` items 1 and 3
  - destination order and labels: `../ux/uiux-spec.md` §7
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC8, AC9
  - architecture: `../architecture/solution.md` `### Key Discovery` items 1-3,
    §4 risk table, Mobile lane guardrails
  - upstream phase outputs: P1's completed `jarlist` composition
  - UX constraints: `../ux/uiux-spec.md` §7
- Requirement Configuration Guide:
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: one shell destination set, applied to production and its
    preview mirror
  - Source/Test File Count: 4 source + 2 test
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` AC8, AC9
- `../architecture/solution.md`
- `../ux/uiux-spec.md` §7

## 3. Tasks

1. **Restructure `AppShell`'s destination model.** Replace the ad-hoc
   `chatIndex` / `safeIndex` conditional-slot logic (`app_shell.dart:134-190`)
   with one ordered list of destinations, each holding its `CupidTabBarItem` and
   its body builder. Chat's `isUnlocked` gating stays as a conditional entry in
   that list. Index math then reads straight off the list, so no later slot can
   drift as Chat appears or disappears. Keep the existing
   build-only-the-selected-destination behavior — do not introduce an
   `IndexedStack`.
2. **Wire the 5 destinations** in design order: Nhà (`Icons.home_rounded`,
   `HomeScreen`), Trò chuyện (`Icons.chat_bubble_outline`, existing gated Chat
   body including its `ghostset` overlay, unchanged), Pet (`CupidIcons.pets`,
   `const PetScreen()`), Ví chung (`CupidIcons.savings`,
   `DreamJarListScreen(repository: getIt<DreamJarRepository>())`), Tôi
   (`CupidIcons.person`, `MeScreen(accountRepository: getIt<AccountRepository>())`).
   Use `context.viEn(...)` labels, matching the existing pattern in this file.
3. **Remove the account FAB.** `Scaffold.floatingActionButton` and
   `_openAccountHub` go away — `MeScreen` is now the Tôi tab body. Remove the
   now-unused `app_shell_account_entry_tooltip` usage.
4. **Preserve Gallery.** The Gallery tab is displaced by the design's 5-tab set,
   and `app_shell.dart` is `GalleryScreen`'s only production reference. Add a
   Gallery entry card to `HomeScreen`'s existing entry-card stack (same pattern
   as `DreamJarEntryCard` / `VibeEntryCard`, `home_screen.dart:160-192`) pushing
   `const GalleryScreen()`. Do not delete the Gallery tab before this card
   exists.
5. **Mirror the shell in the preview harness.** Extend `PreviewAppShellTab` to
   the 5 destinations, rebuild `PreviewAppShellChrome`'s item list to match
   `AppShell`'s (same icons, same labels, same order), and drop its account FAB.
   Add the `jarlist` arm to `main_preview.dart`'s `activeTab` switch
   (`main_preview.dart:1523-1528`) mapping to the Ví chung tab. Without this the
   AC9 capture still renders three tabs and no active highlight, and AC8 cannot
   be evidenced.
6. **Capture the AC9 evidence pair.** Resolve `jarlist` via
   `node .ai-team-bundle/runtime/tools/render-design-canvas.js --list-screens`
   against the configured design entry; confirm the render depicts the Dream Jar
   list by content (jar collection, "+ Tạo hũ mới" CTA, "Ví chung" tab), not by
   id match. Capture a fresh `implemented-jarlist-*` / `design-reference-jarlist-*`
   pair covering the states relevant to AC1-AC8.

## 4. Acceptance Criteria

- The shell renders exactly 5 destinations in design order when Chat is
  unlocked, with Ví chung selected while `jarlist` is displayed.
- No account FAB remains on any shell screen.
- `GalleryScreen` is reachable from `HomeScreen` and is asserted so by a test.
- `PreviewAppShellChrome`'s item list matches `AppShell`'s destination set, and
  `jarlist` renders with the Ví chung tab highlighted.
- Home, Chat (both `isUnlocked` states), Pet, and Tôi each mount their intended
  body at their post-change index.
- A fresh `implemented-jarlist-*` / `design-reference-jarlist-*` pair exists and
  covers AC1-AC8.

## 5. Planned Outputs

- Code: the four source files in Write Scope
- Notes or evidence: `visual-fidelity/` evidence pair, plus a P2 entry in
  `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, `AppShell` and the preview shell chrome
- Required levels:
  - integration: `AppShell` widget tests asserting the destination set and the
    mounted body per index, for both `isUnlocked: true` (5 tabs) and
    `isUnlocked: false` (4 tabs, Ví chung and Tôi still correctly addressable);
    `HomeScreen` widget test asserting the Gallery entry card pushes
    `GalleryScreen`; `PreviewAppShellChrome` test asserting the 5-item set and
    the Ví chung active index
  - mobile build/type-check/static-analysis: `flutter analyze` and
    `flutter test` for the touched suites
  - visual inspection: the AC9 evidence pair
- Required checks: no account FAB remains; no new `IconData` codepoint added;
  `cupid_tab_bar.dart` and `cupid_header.dart` untouched
- Mobile discoverability / navigation integration: REQUIRED — this phase removes
  a tab that is a shipped feature's only entry point, so the replacement Home
  entry card must be asserted by test, not by inspection
- Required regression or contract coverage: existing `AppShell` and `HomeScreen`
  tests must be updated to the new destination set rather than deleted
- Evidence format: test command output plus evidence-pair paths in
  `coding-plan/test-results.md`
- Requirement mobile visual audit: REQUIRED — AC-by-AC over AC1-AC8 against the
  fresh pair
- Runtime startup smoke: NO

## 7. Status

- Status: IMPLEMENTED_BLOCKED_ON_BACKEND_RUNTIME
- Last updated: 2026-08-20
- Code is complete and every mobile gate command is green. Lane result is
  `MOBILE_COMPLETE: NO` with `BLOCKER: BACKEND_RUNTIME_UNAVAILABLE` (runtime id
  `backend-api`), because no live backend was available to verify against.
  Starting it is DevOps' lane. See `coding-plan/test-results.md` →
  `### Backend runtime gate`, and `### Build evidence gate` for the separate
  gate anomaly.
- Evidence: `coding-plan/test-results.md` → `## Phase P2`
- Build gate: `flutter build apk --debug` → `✓ Built app-debug.apk`
- Tests: `flutter test` → 1335 passed, 2 skipped, 0 failed
- AC9 pair: `visual-fidelity/implemented-jarlist-ready-emulator-5560.png` and
  `visual-fidelity/design-reference-jarlist-ready-emulator-5560.png`
- Required checks confirmed: no account FAB on any destination; no new
  `IconData` codepoint added (the removed `_galleryTabIcon` was the only one);
  `cupid_tab_bar.dart` and `cupid_header.dart` untouched
