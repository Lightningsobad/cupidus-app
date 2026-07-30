# Phase P4 – Verification

## 1. Objective

Verify the mobile lane output and STORY-008 readiness for the review gate.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-verification.md`
- Owner: Mobile Developer
- Lane: Mobile Verification

## 1B. Phase Metadata

- Depends On: P0, P1, P2, P3
- Parallelizable: NO
- Write Scope:
  - lane-owned test files
  - `coding-plan/test-results.md`

## 2. Required Reads

- `../story_master.md` (AC1-AC3)
- `../architecture/solution.md` §4 Risk Surfaces And Source Of Truth
- `master-plan.md` §3A
- the `## 6. Test Scope` section of `phase-P0`, `phase-P1`, `phase-P2`, `phase-P3`
- `../ux/uiux-spec.md` §2.4 only for the AC2 deferral wording

## 3. Verification Tasks

- confirm `master-plan.md` uses the required Phase Overview table schema
- confirm every listed phase has exactly one canonical `phase-Px-*.md` file
- confirm no duplicate phase files exist for the same phase id
- run the full mobile suite: `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter test`
  in `mobile/`
- run `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter analyze` in `mobile/`
- run the registry build command
  `${FLUTTER_SDK_PATH:-$HOME/flutter}/bin/flutter build apk --debug` in `mobile/`
  as the mobile build/type-check gate
- do not plan or run mobile e2e, emulator/simulator lifecycle commands, signing,
  store upload, traces, scenario reruns, repository-root local script gates, or
  runtime startup smoke
- verify each risk-surface gate in `master-plan.md` §3A is recorded as pass, not
  required, or blocked with a typed blocker
- verify AC1 and AC3 are demonstrated by P1's cubit and widget tests, and that
  AC2's widget behaviour is demonstrated by P3's tests
- record the AC2 mount deferral explicitly: `GhostStateRow` is delivered and
  tested, but its chat mount is STORY-007 / requirement-integration scope
  (ADR-3). Do not record AC2 as end-to-end verified in this branch.
- confirm the `home_screen.dart` diff is additive and
  `Key('home_screen_ready_signal')` still resolves
- confirm no file under `mobile/lib/features/chat/` and no file under
  `mobile/openapi/` appears in the story diff
- confirm `pubspec.yaml` is unchanged
- document results concisely in `test-results.md`

## 4. Acceptance Criteria

- required automated checks pass
- critical regressions are resolved
- AC1 and AC3 are verified; AC2's widget behaviour is verified with the mount
  deferral recorded
- critical gates for touched risk surfaces are recorded as pass, not required, or
  blocked with a typed blocker
- required targeted mobile checks are recorded
- requirement-level mobile visual audit evidence is deferred to the
  requirement-level audit after all stories are otherwise complete
- next owner can resume without guessing

## 4A. Verification Test Scope

- Source implementation phases: P0, P1, P2, P3
- Platform / Surface: Flutter mobile (`mobile-app`)
- Required levels:
  - unit: repository, `AntiGhostCubit`, `GhostStormCubit`
  - integration: `AntiGhostScreen`, `AntiGhostEntryCard` tap-to-navigate,
    `GhostStateRow` render cases
  - backend e2e: `DO NOT PLAN for ordinary continue`
  - browser e2e: `DO NOT PLAN for ordinary continue`
  - mobile e2e: `DO NOT PLAN for ordinary continue`
  - desktop/electron e2e: `DO NOT PLAN for ordinary continue`
  - accessibility: radio-group semantics on the penalty control, accessible
    disabled reason in State B, value-bearing Accept/Decline labels, single
    live-region announcement for the chat CTA
  - mobile build/type-check/static-analysis: REQUIRED — `flutter analyze` plus
    registry `buildCommand`
  - local setup gate: `DEVOPS only`
  - build gate: `mobile-dev uses package-native mobile build/type-check/static-analysis`
  - local dev startup gate: `STORY-RUNTIME-SMOKE only; implementation lanes do not run scripts/start-dev.sh`
- Required runtime signals:
  - screenshot artifacts: `requirement visual audit only`
- Evidence format:
  - concise `coding-plan/test-results.md` rows only
- Requirement mobile visual audit:
  - Required when requirement has mobile participation: YES
  - Affected screens/routes: `HomeScreen` (Anti-Ghosting card), `AntiGhostScreen`
    States A/B/C/D, and the chat ghost-state row once STORY-007 mounts it
  - Required entry surfaces: the home Anti-Ghosting card
  - Provided runtime/artifact/screenshot command: deferred to the
    requirement-level audit; not run in this story
  - Screenshot budget: optimized small device/artifact screenshots
  - Required visual evidence: screenshot paths plus broken/misaligned mobile UI
    findings
- Risk-surface gates:
  - touched risk surfaces: frozen wire contract; pairing gate; approval-role
    derivation; no-fork guard; runtime readiness key; l10n parity; storm polling
    lifecycle; cross-story merge surfaces
  - source-of-truth artifacts: `backend/src/modules/ghost-config/`;
    `../ux/uiux-spec.md` §1/§2.3/§2.4/§4; `mobile/test/design_system/no_fork_guard_test.dart`;
    registry `mobile-app.readiness`; `mobile/test/l10n/arb_parity_test.dart`
  - critical gates: as listed in `master-plan.md` §3A
  - blocked gates: AC2 end-to-end mount — blocked by design on STORY-007, record
    as a typed cross-story deferral, not a failure
- Story-level runtime startup smoke: NOT_APPLICABLE — `mobile-app` readiness is a
  widget-test signal, not an HTTP probe, and no runtime registry entry changed
- Local runtime/port safety gate: NOT_APPLICABLE — no Docker, Compose, local
  script, or registry change
- Backend e2e gate: Do not add for ordinary continue

## 5. Status

- Status: DONE
- Last updated: 2026-07-30
- Evidence: full results in `coding-plan/test-results.md`.
  - `flutter test`: 181/181 passed — "All tests passed!". The one
    deterministic failure found during initial verification
    (`test/features/auth/presentation/splash_screen_test.dart`,
    "CupidSessionSignedIn with a resolving token routes to HomeScreen") was
    root-caused to a pre-existing gap in that (auth-lane, prior-story)
    test's own `MaterialApp` harness, which never registered
    `AppL10n.localizationsDelegates`/`supportedLocales`. P2's additive
    `AntiGhostEntryCard` mount on `HomeScreen` calls `AppL10n.of(context)`,
    which null-checked and threw against that harness, with a cascading
    `RenderFlex` overflow as a secondary symptom of the same crash. Scrum
    Master reviewed and approved a narrow, test-harness-only fix (expanding
    this run's write scope by exactly one file): added
    `localizationsDelegates: AppL10n.localizationsDelegates` and
    `supportedLocales: AppL10n.supportedLocales` to
    `splash_screen_test.dart`'s `_harness()` `MaterialApp`, matching the
    existing pattern already used in `test/widget_test.dart` and
    `anti_ghost_entry_card_test.dart`. Re-run confirmed all 181 tests green
    with no further failures. This was a genuine cross-story test-harness
    regression, not the known/accepted AC2 STORY-007 mount deferral (ADR-3).
  - `flutter analyze` (scoped to this story's touched files): 0
    errors/warnings, 7 pre-existing-pattern `info` hints (same tolerated
    style as P1/P3). Full unscoped `flutter analyze` reports only pre-existing
    noise inside the untracked `build/ios/SourcePackages/checkouts/flutterfire/`
    tree, unrelated to this story.
  - `flutter build apk --debug`: PASS — `✓ Built
    build/app/outputs/flutter-apk/app-debug.apk`.
  - AC1/AC3: verified by P1's cubit/screen tests. AC2 widget behaviour:
    verified by P3's tests; end-to-end chat mount correctly deferred to
    STORY-007 / requirement integration per ADR-3 — not attempted here.
  - `home_screen.dart` diff (P2) confirmed additive;
    `Key('home_screen_ready_signal')` still resolves via `test/widget_test.dart`
    (real `CupidApp` boot path).
  - No file under `mobile/lib/features/chat/` or `mobile/openapi/` appears in
    the story diff; `pubspec.yaml` is unchanged.
  - `master-plan.md`'s P1-P3 status cells were found stale (`NOT_STARTED`
    despite each phase's own file already recording `DONE`); corrected as
    part of this pass.
- Next owner: story is ready for the review gate.
