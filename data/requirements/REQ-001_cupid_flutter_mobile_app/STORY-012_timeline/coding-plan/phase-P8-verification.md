# Phase P8 – Mobile Verification

## 1. Objective

Verify the mobile lane output and STORY-012 readiness for the review gate: all
four acceptance criteria demonstrated, every risk-surface gate recorded, and plan
hygiene confirmed.

## 1A. Ownership

- Phase ID: P8
- Canonical Phase File: `phase-P8-verification.md`
- Owner: Mobile Developer
- Lane: Mobile Verification

## 1B. Phase Metadata

- Depends On: P1, P2, P3, P4, P5, P6, P7
- Parallelizable: NO
- Write Scope:
  - lane-owned test files under `mobile/test/**`
  - `coding-plan/test-results.md`

## 2. Required Reads

- `../story_master.md` (AC1–AC4)
- `../architecture/solution.md` §2 test expectations, §4 Risk Surfaces And Source Of Truth
- owned implementation outputs from P1–P7
- `../ux/uiux-spec.md` §2 only, to confirm every state has a verifying test
- `data/devops/system/runtime-command-registry.json` — `mobile-app` entry only
- the `## 6. Test Scope` section of each of P1–P7

## 3. Verification Tasks

- confirm `master-plan.md` uses the required Phase Overview table schema
- confirm every listed phase has exactly one canonical `phase-Px-*.md` file
- confirm no duplicate phase files exist for the same phase id
- run the lane-relevant automated tests: `flutter test` from `mobile/`
- run mobile static analysis: `flutter analyze` from `mobile/`
- run the mobile build gate: `flutter build apk --debug` (registry `mobile-app.buildCommand`) — this is the real proof that adding `sqlite3_flutter_libs` did not break the native build
- do not plan or run mobile e2e, emulator/simulator lifecycle commands, signing, store upload, traces, scenario reruns, or `scripts/start-dev.sh`
- verify each acceptance criterion against a named test:
  - AC1 create → P6 cubit/sheet tests
  - AC2 both partners view the shared timeline → P2 decode + P3 read-through + P5 render + P7 reachability (the couple-scoping itself is enforced server-side by `coupleId`; the client assertion is that the fetched page renders unmodified)
  - AC3 offline read after at least one sync, writes still require connectivity → P3 `offlineWithCache` / `offlineNoCache` tests + P6 offline-blocked create test
  - AC4 unpaired users cannot access the feature → P3 pairing-store tests + P7 hidden-card tests
- verify every risk-surface gate in `../architecture/solution.md` §4 is recorded as pass, not required, or blocked with a typed blocker
- confirm no libsodium, FFI, `image_picker`, `connectivity_plus`, or other unplanned package entered `pubspec.yaml`
- confirm no file under `backend/` was modified (A1)
- confirm `Key('home_screen_ready_signal')` is still present and pumping
- confirm both `.arb` files carry the same key set
- document results in concise form in `coding-plan/test-results.md`

## 4. Acceptance Criteria

- required automated checks pass (`flutter test`, `flutter analyze`, `flutter build apk --debug`)
- critical regressions are resolved
- AC1–AC4 are each verified and mapped to a named test
- contract-sensitive behavior owned by this lane is verified: wire decode, read-through caching, no offline write queue, pairing gate
- critical gates for touched risk surfaces are recorded as pass, not required, or blocked with a typed blocker
- required targeted mobile checks are recorded
- requirement-level mobile visual audit is deferred and recorded as such, to run after all REQ-001 stories are otherwise complete
- next owner (Reviewer) can resume without guessing

## 4A. Verification Test Scope

- Source implementation phases: P1, P2, P3, P4, P5, P6, P7
- Platform / Surface: Flutter (`mobile`), unit + widget tests on the host VM
- Required levels:
  - unit: P1–P4, P6 unit tests
  - integration: P3 repository over in-memory Drift, P6 sheet-to-list flow, P7 card-to-screen navigation
  - backend e2e: `DO NOT PLAN for ordinary continue`
  - browser e2e: `DO NOT PLAN for ordinary continue`
  - mobile e2e: `DO NOT PLAN for ordinary continue`
  - desktop/electron e2e: `DO NOT PLAN for ordinary continue`
  - visual inspection: deferred to the requirement-level mobile visual audit
  - accessibility: semantics labels asserted in P5 and P7 widget tests
  - mobile build/type-check/static-analysis: `REQUIRED` — `flutter analyze` and `flutter build apk --debug`
  - local dev startup gate: `STORY-RUNTIME-SMOKE only; implementation lanes do not run scripts/start-dev.sh`
- Required runtime signals:
  - backend response/log/assertion evidence: none — no backend change and no live backend is required; network behavior is asserted against fakes
  - screenshot artifacts: `requirement visual audit only`
- Evidence format:
  - concise `coding-plan/test-results.md` rows only
- Requirement mobile visual audit:
  - Required when requirement has mobile participation: YES, but deferred to the requirement-level audit after all REQ-001 stories are otherwise complete
  - Affected screens/routes: dashboard entry card, Love Timeline screen, create-memory sheet
  - Required entry surfaces: dashboard "Love Timeline" card
  - Screenshot budget: optimized small device/artifact screenshots
- Risk-surface gates:
  - touched risk surfaces: untyped REST body; Drift read-through cache; offline write prohibition; AC4 pairing gate; session data leakage; runtime readiness signal; native build with bundled SQLite
  - source-of-truth artifacts: `../architecture/solution.md` §4 table; frozen `backend/src/modules/timeline/*`; runtime registry `mobile-app`
  - critical gates: `flutter test`, `flutter analyze`, `flutter build apk --debug`, plus the per-surface assertions listed in §3
  - blocked gates: record any gate that cannot run as a typed blocker rather than marking it pass
- Backend e2e gate:
  - Do not add for ordinary continue

## 5. Status

- Status: NOT_STARTED
- Last updated: 2026-07-30
