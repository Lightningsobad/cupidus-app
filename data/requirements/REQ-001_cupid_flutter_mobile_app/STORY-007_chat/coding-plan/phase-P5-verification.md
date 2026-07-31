# Phase P5 – Mobile Verification

## 1. Objective

Verify the mobile lane output and STORY-007 readiness for the review gate.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-verification.md`
- Owner: Mobile Developer
- Lane: Mobile Verification

## 1B. Phase Metadata

- Depends On: P0, P1, P2, P3, P4
- Parallelizable: NO
- Write Scope:
  - lane-owned test files under `mobile/test/**`
  - `coding-plan/test-results.md`

## 2. Required Reads

- `../story_master.md` (AC1-AC5)
- `../architecture/solution.md` §4 Risk Surfaces And Source Of Truth
- `master-plan.md` §3A
- owned implementation outputs from P0-P4
- `../ux/uiux-spec.md` only for the AC2/AC3/AC4 behaviors already cited in the phase test scopes
- `../review/review-report.md` when present
- the `## 6. Test Scope` sections of P0, P1, P2, P3, P4

## 3. Verification Tasks

- confirm `master-plan.md` uses the required Phase Overview table schema
- confirm every listed phase has exactly one canonical `phase-Px-*.md` file
- confirm no duplicate phase files exist for the same phase id
- run the full mobile suite: `flutter test`
- run mobile static analysis: `flutter analyze`
- run the mobile build gate: `flutter build apk --debug` (runtime registry `mobile-app.buildCommand`)
- confirm `dart run build_runner build --delete-conflicting-outputs` is a no-op, proving the committed generated Drift code is not stale
- run the phase-specific regression checks named in each P0-P4 test scope
- verify AC1-AC5 against the risk-surface gates in `master-plan.md` §3A
- run the ADR-guard greps and record each as pass/fail:
  - no `pending`, `queued`, `outbox`, `retry`, `local`, or `sendState` column in the Drift `messages` schema (AC4 / ADR-007)
  - `markDelivered` appears nowhere under `mobile/lib/features/chat/` (ADR-013d)
  - no attachment/image control in `chat_composer.dart` (ADR-013a)
  - no `socket_io_client` or `firebase_messaging` import under `mobile/lib/features/chat/` (STORY-004 §2 boundary)
  - no ghost `content` written to Drift, `shared_preferences`, or any log call (ADR-013b / solution §2 invariant 3)
  - no STORY-005 pairing source file imported anywhere under `mobile/lib/features/chat/`
- confirm the `Key('home_screen_ready_signal')` readiness widget test still passes after P4's shell change
- do not plan or run mobile e2e, emulator/simulator lifecycle commands, signing, store upload, traces, or scenario reruns
- document results concisely in `coding-plan/test-results.md`, one row per risk surface and one row per AC

## 4. Acceptance Criteria

- required automated checks pass: `flutter test`, `flutter analyze`, `flutter build apk --debug`
- critical regressions are resolved
- AC1-AC5 are each verified and recorded with the asserting test
- every ADR-guard grep above is recorded as pass, or as a typed blocker
- critical gates for the seven risk surfaces in `master-plan.md` §3A are recorded as pass, not required, or blocked with a typed blocker
- requirement-level mobile visual audit evidence is recorded after the requirement is otherwise complete (requirement-level, not story-level — see §4A)
- next owner (Reviewer) can resume without guessing

## 4A. Verification Test Scope

- Source implementation phases: P0, P1, P2, P3, P4
- Platform / Surface: Flutter mobile (`mobile-app`), `chat` and `ghostset` screens plus the app shell
- Required levels:
  - unit: DAO paging/dedupe/schema-absence; mapper; `ChatRepository`; `ChatCubit`; `GhostCubit` timing constants and consent machine
  - integration: `ChatScreen`, `GhostSettingsScreen`, and `AppShell` widget tests
  - backend e2e: `DO NOT PLAN for ordinary continue`
  - browser e2e: `DO NOT PLAN for ordinary continue`
  - mobile e2e: `DO NOT PLAN for ordinary continue`
  - desktop/electron e2e: `DO NOT PLAN for ordinary continue`
  - visual inspection: widget-test tree assertions only at story level; screenshots are requirement-level only
  - accessibility: bubble single-node semantics, polite ghost live region, 3-state toggle semantic labels (`../ux/uiux-spec.md` §8)
  - mobile build/type-check/static-analysis: `REQUIRED` — `flutter analyze` and `flutter build apk --debug`
  - local setup gate: `DEVOPS only`
  - build gate: `mobile-dev uses package-native mobile build/type-check/static-analysis`
  - local dev startup gate: `STORY-RUNTIME-SMOKE only; implementation lanes do not run scripts/start-dev.sh`
- Required runtime signals:
  - backend response/log/assertion evidence: N/A — no backend change in this story
  - route/navigation entrypoint: chat destination present when paired, absent when unpaired; `ghostset` reachable from the chat header
  - screenshot artifacts: `requirement visual audit only`
- Evidence format:
  - concise `coding-plan/test-results.md` rows only
- Requirement mobile visual audit:
  - Required when requirement has mobile participation: YES
  - Affected screens/routes: `chat`, `ghostset`, app shell tab bar
  - Required entry surfaces: shell Chat destination; chat header `ghostset` action
  - Provided runtime/artifact/screenshot command: deferred to the requirement-level audit after all REQ-001 stories are otherwise complete; the runtime registry records that `flutter run` needs a connected device and is not headless, so this story does not attempt device screenshots
  - Screenshot budget: optimized small device/artifact screenshots
  - Required visual evidence: screenshot paths plus broken/misaligned mobile UI component findings
- Risk-surface gates:
  - touched risk surfaces: Local persistence (ADR-007); Realtime send/receive; Typing-ghost timing (AC2); Read-receipt correctness; Ghost consent + privacy; Pairing gate (AC5); Discoverability
  - source-of-truth artifacts: `../architecture/solution.md` §4 Risk Surfaces; `master-plan.md` §3A
  - critical gates: as listed per surface in `master-plan.md` §3A
  - blocked gates: record any gate that cannot run with a typed blocker rather than marking it pass
- Story-level runtime startup smoke: `NOT_APPLICABLE` — the runtime registry records that launching the app requires a connected device and is interactive, so `mobile-app` has no headless startup smoke. The registry-declared readiness signal is the `Key('home_screen_ready_signal')` widget test, which is verified above instead.
- Local runtime/port safety gate: not required — no Docker, Compose, local script, or runtime registry entry changed in this story
- Backend e2e gate: not added

## 5. Status

- Status: BLOCKED
- Last updated: 2026-07-31
- Evidence: `flutter test` 168/171 passed (3 failures); `flutter analyze` (scoped `lib test`) 32 pre-existing-pattern info notices only, no errors/warnings; `flutter build apk --debug` succeeded; `dart run build_runner build --delete-conflicting-outputs` confirmed no-op (empty `git status --porcelain`). All ADR-guard checks and AC1-AC5 pass. The 3 test failures are `mobile/lib/**` defects outside this phase's `mobile/test/**`-only write scope — see `coding-plan/test-results.md` §Blockers for root cause and exact failing tests.
