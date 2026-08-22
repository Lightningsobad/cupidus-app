# Review Scope Gate: STORY-001 Production API Build Flavor For Mobile App

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Note: the handoff requested `compact-story-review` and explicitly said not to
create this file (skill rule 5a says the same for compact reviews). The
`validate-reviewer-two-phase.sh` stop hook requires it regardless, so this file
records the same scope that was already applied and written inline in
`review-report.md`. It is a transcription of the scope actually used, not a
re-scoped second pass.

## Identity

- Review type: `compact-story-review`
- Review report path: `data/requirements/REQ-007_mobile_app_production_api_build_config/STORY-001/review/review-report.md`
- Scope gate path: `data/requirements/REQ-007_mobile_app_production_api_build_config/STORY-001/review/scope-gate.md`

## Scope Decision

- Scope status: `PROCEED`
- Why this review is within budget or why it must stop: 7 source/test/config files inspected against the compact budget of 8; 0 governing artifacts over roughly 20 KB. The story changes 3 mobile files plus 1 configuration guide.
- Current story or bug status: `PENDING` in `story_master.md`; Implementation checked with P1 DONE, Review unchecked.

## Governing Inputs

- Primary artifacts: `STORY-001/story_master.md`; `STORY-001/requirements/requirements.md` (AC1-AC5, Business Rules, Edge Cases, Open Question Impact); `STORY-001/architecture/solution.md` §3 and §4; `STORY-001/coding-plan/phase-P1-production-api-build-config.md` §1B, §4, §6; `STORY-001/scrum-master-checkpoint.md`
- Existing review findings: `N/A` — first review pass for this story
- Test evidence: `STORY-001/coding-plan/test-results.md` (sections 1-8 and Summary)
- Extra artifacts required beyond the default minimum: `data/requirements/REQ-007_mobile_app_production_api_build_config/deployment/configuration-guide.md` (setup/configuration impact, rule 12a)

## Source/Test Files In Scope

- `mobile/lib/core/config/cupid_api_config.dart` (changed)
- `mobile/lib/main.dart` (changed)
- `mobile/test/core/config/cupid_api_config_test.dart` (new)
- `data/requirements/REQ-007_mobile_app_production_api_build_config/deployment/configuration-guide.md` (new)
- `mobile/lib/core/network/cupid_api_client.dart` (ranged read, lines 1-28 — dual-transport gate)
- `mobile/lib/core/di/service_locator.dart` (ranged read, lines 190-207 — dual-transport gate)
- `scripts/` directory listing (configuration-guide accuracy)

## Evidence Files In Scope

- `STORY-001/coding-plan/test-results.md`
- `STORY-001/coding-plan/phase-P1-production-api-build-config.md`
- `STORY-001/architecture/solution.md`
- `STORY-001/requirements/requirements.md`
- `STORY-001/story_master.md`
- `STORY-001/scrum-master-checkpoint.md`
- Git boundary diff: `git -C <Worktree> diff beb1c551941fb902a872f4f2919f9451b25787f4`

## Risk Surfaces And Critical Gates

- Touched risk surfaces: runtime/configuration; app lifecycle (startup guard added to `main()`); external integration (production API origin); typed contract consumers of `CupidApiConfig.baseUrl`. Not touched: persistence/schema, security/auth, frontend or mobile UI interaction, navigation/discoverability, permissions/device API, local storage/offline, deep link/push, data migration.
- Source-of-truth artifacts or contracts: `architecture/solution.md` §4 "Risk Surfaces And Source Of Truth" table; `mobile/lib/core/config/cupid_api_config.dart`; consumer contract in `cupid_api_client.dart` and `service_locator.dart`
- Critical gates to verify: (1) production origin resolution — production-define build compiles and resolves the TLS origin from one named constant; (2) silent local-dev fallback — `validationError()` rejects `production` paired with any non-production origin, thrown before any transport exists; (3) local-dev build regression — no-defines build plus full regression suite; (4) dual-transport origin leak — REST and socket both read the single const; (5) build-time-only selection (AC5) — static analysis plus no writable origin anywhere in `lib/`; (6) mobile runtime startup smoke (rule 12g) — app launches on device and reaches its first screen
- Mandatory web Playwright/browser-e2e gate: `NOT_APPLICABLE in ordinary continue`
- Requirement visual audit evidence: `NOT_APPLICABLE` — no frontend participation in this story
- Mandatory mobile e2e/emulator/signing/store gate: `NOT_APPLICABLE in ordinary continue`
- Requirement mobile visual audit evidence: `REQUIRED when requirement had mobile participation` — AC3/AC4 device observation is routed to the requirement-level mobile runtime audit by phase file §6 and `architecture/solution.md` §4; tracked as deferred finding D1 against REQ-007 closure, not as a story-level failure. Rule 12e2/12g2 per-story rendered design fidelity is `NOT_APPLICABLE`: the story ships no screen or UI state (UX SKIPPED).
- Missing gate evidence or blocker: gate (6) is unmet — `coding-plan/test-results.md` has no `## Story Runtime Startup Smoke` section (it records `Startup smoke: NOT_APPLICABLE for this phase`) and `story_master.md` records no `Runtime-Smoke: WAIVED — <reason>` line, while `mobile/lib/main.dart:20` adds a throwing assertion to the app entrypoint. Recorded as blocking finding B1.

## Query Keys

- AC ids: AC1, AC2, AC3, AC4, AC5
- Symbols: `CupidApiConfig.baseUrl`, `CupidApiConfig.environment`, `productionBaseUrl`, `localEnvironment`, `productionEnvironment`, `validationError`, `assertValidConfig`, `SocketTransport.url`, `BaseOptions.baseUrl`, `AppConfig`
- Defines: `CUPID_ENV`, `CUPID_API_BASE_URL`
- Headings/lines: `architecture/solution.md` "Risk Surfaces And Source Of Truth"; `requirements.md` "Open Question Impact"; phase file §1B "Write Scope" and §6 "Test Scope"; `test-results.md` sections 1-8; `story_master.md` `Runtime-Smoke` / `Startup Smoke`
- Commands: `flutter test test/core/config/cupid_api_config_test.dart`; `flutter analyze lib test`; `flutter build apk --debug`; `flutter build apk --debug --dart-define=CUPID_ENV=production --dart-define=CUPID_API_BASE_URL=https://api.cupidus.app`; `flutter test --reporter compact`

## Phase 2 Approval

- Phase 2 may proceed: `YES`
- If `NO`, final review outcome should be: `N/A` — Phase 2 was approved and completed
- If `NO`, exact blocker or re-scope instruction: `N/A`
