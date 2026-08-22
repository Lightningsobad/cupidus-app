# Story Review Report: REQ-007 / STORY-001 Production API Build Flavor For Mobile App

Outcome: PATCH_REQUIRED

- Review type: `compact-story-review`
- Reviewer run: `RUN-REQ-007_mobile_app_production_api_build_config-STORY-001-reviewer`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-007_mobile_app_production_api_build_config-STORY-001`
- Diff baseline: `beb1c551941fb902a872f4f2919f9451b25787f4`
- Blocking findings: 1 · Deferred findings: 3

## Scope Gate

- Scope gate path: `data/requirements/REQ-007_mobile_app_production_api_build_config/STORY-001/review/scope-gate.md` (written to satisfy the `validate-reviewer-two-phase.sh` stop hook, which requires it even for `compact-story-review`; it transcribes the scope below, it is not a second pass)
- Review report path: `data/requirements/REQ-007_mobile_app_production_api_build_config/STORY-001/review/review-report.md`
- Source/test/config files in scope (7, within the compact budget of 8):
  - `mobile/lib/core/config/cupid_api_config.dart` (changed)
  - `mobile/lib/main.dart` (changed)
  - `mobile/test/core/config/cupid_api_config_test.dart` (new)
  - `data/requirements/REQ-007_mobile_app_production_api_build_config/deployment/configuration-guide.md` (new)
  - `mobile/lib/core/network/cupid_api_client.dart` (ranged read, dual-transport gate)
  - `mobile/lib/core/di/service_locator.dart` (ranged read, dual-transport gate)
  - `scripts/` listing (config-guide accuracy)
- Evidence files in scope: `coding-plan/test-results.md`; `coding-plan/phase-P1-production-api-build-config.md` §1B/§4/§6; `architecture/solution.md` §3/§4; `requirements/requirements.md` AC1-AC5 + Open Question Impact; `story_master.md`; `scrum-master-checkpoint.md`
- Query keys: `CUPID_ENV`, `CUPID_API_BASE_URL`, `productionBaseUrl`, `validationError`, `assertValidConfig`, `Runtime-Smoke`, `Startup Smoke`
- Large governing artifacts over ~20 KB read: 0
- Tool constraint: the platform `Grep` tool returned `No such tool available: Grep`, `ToolSearch` returned `No such tool available: ToolSearch. ToolSearch is disabled for this session`, and `guard-query-first-bash-read.sh` blocked shell `grep` over artifacts (`SHELL_GREP_SOURCE`). All verification below therefore used the Git boundary diff plus ranged/whole `Read` of small files.

## Acceptance Criteria

| AC | Verdict | Evidence |
|----|---------|----------|
| AC1 production flavor resolves to `api.cupidus.app` via standard `--dart-define` | PASS | `cupid_api_config.dart:15-24` (`String.fromEnvironment('CUPID_ENV')`, `productionBaseUrl`); test-results §4 build with both defines, exit 0 |
| AC2 local-dev build unchanged | PASS | `baseUrl` default `http://localhost:3000` untouched in the diff; `environment` defaults to `local`; guard is a no-op on that pair (unit case `+2`); test-results §3 build, exit 0; §7 regression 1348 pass / 0 fail |
| AC3 production build installed on emulator/simulator, observed calling `api.cupidus.app` | NOT VERIFIED AT STORY LEVEL | Routed to the requirement-level mobile runtime audit by phase file §6 and `architecture/solution.md` §4 risk table. See D1. |
| AC4 local-dev build installed on emulator/simulator, observed still calling local dev | NOT VERIFIED AT STORY LEVEL | Same routing as AC3. See D1. |
| AC5 build-time-only selection, no runtime toggle | PASS | `baseUrl`/`environment` are `static const` (Dart forbids assignment); source-guard test `+11` asserts no `set baseUrl`/`set apiBaseUrl`/`set environment` accessor and no `CupidApiConfig.<field> =` assignment anywhere in `lib/` |

## Touched Risk Surfaces And Critical Gates

| Risk surface (`architecture/solution.md` §4) | Critical gate | Result |
|---|---|---|
| Production origin resolution | Production-define build compiles and resolves the TLS origin from one named constant | PASS — test-results §4 exit 0; `productionBaseUrl` verified as the single `lib/` occurrence by source-guard test `+10` |
| Silent local-dev fallback | `validationError()` rejects `production` paired with a non-production origin | PASS — `cupid_api_config.dart:36-42`; unit cases `+6` (localhost), `+7` (cleartext), `+8` (wrong host), `+9` (empty). `main.dart:20` runs the guard before `Firebase.initializeApp` and `setupServiceLocator()`, so no transport exists when it throws |
| Local-dev build regression | No-defines build + full regression suite | PASS — test-results §3 exit 0, §7 `1348 pass, 2 skip, 0 fail` |
| Dual-transport origin leak | Both REST and socket read the one const | PASS — independently verified: `cupid_api_client.dart:15` `baseUrl: CupidApiConfig.baseUrl` and `service_locator.dart:199` `SocketTransport(url: CupidApiConfig.baseUrl)`. No second origin exists to drift |
| Build-time-only selection (AC5) | Static analysis + no writable origin | PASS — `flutter analyze lib test` byte-identical to BaseHead (0 error, 0 warning, 80 pre-existing info); source-guard test `+11` |
| Mobile app lifecycle / startup (surface added by this story, not in the plan table) | Registry-backed runtime startup smoke: app launches on device and reaches its first screen | **FAIL — B1** |

## Blocking Findings

### B1 — Mandatory mobile runtime startup smoke is absent and not waived

This story inserts a new throwing statement into the app entrypoint:
`CupidApiConfig.assertValidConfig()` at `mobile/lib/main.dart:20`, executing
after `WidgetsFlutterBinding.ensureInitialized()` and before
`Firebase.initializeApp`. That changes the launch path of every build of the app.

Reviewer rule 12g makes registry-backed runtime startup smoke a mandatory
story-level operational gate for every non-trivial `mobile`-lane story — for
mobile, that the app *launches* on the provided device/emulator and reaches its
first screen without a crash or error screen — unless `story_master.md` records
`Runtime-Smoke: WAIVED — <reason>`.

Current state:
- `coding-plan/test-results.md:15` records `Startup smoke: NOT_APPLICABLE for this phase.` and has no `## Story Runtime Startup Smoke` section.
- `story_master.md` (13 lines, read in full) carries no `Runtime-Smoke:` line at all.
- `phase-P1-...md:33` declares `Startup Smoke: NOT_APPLICABLE`, but that was written at planning time, *before* the design added a startup-time assertion to `main()`. The declaration is now stale relative to what shipped.

Every gate that passed above proves the app **compiles** (two APK builds) and that
the guard function is **logically** a no-op on the local pair (a Dart-VM unit
test). None proves the app **starts**. This is precisely the gap rule 12g was
written for. The DONE gate enforces this line independently, so the story cannot
be closed on a `CLEAN` verdict regardless of this report.

Action items — either one clears B1:
- [mobile-dev] Launch the app on the emulator/simulator (`scripts/run-mobile.sh android` exists in the worktree) for the no-defines build and for the production-define build, confirm each reaches the first screen with no crash or error screen, and record a `## Story Runtime Startup Smoke` section in `coding-plan/test-results.md` with the exact command, exit status, and observed first screen.
- [scrum-master] Or record `Runtime-Smoke: WAIVED — <reason>` in `story_master.md` if the device gate is deliberately deferred to the requirement-level audit; the waiver must be explicit, since the absence of the line is what fails the gate.

Note for whoever runs the smoke: with the emulator already up, the AC3/AC4
observation in D1 costs almost nothing extra and would close that gap in the same
session.

## Deferred Findings

- **D1 — AC3/AC4 device observation deferred to the requirement-level gate.** Both ACs literally require install-and-observe on a real emulator/simulator. `phase-P1-...md:147-152` and the `architecture/solution.md` §4 risk table both route this to the requirement-level mobile runtime audit, and this handoff scoped it out, so it is not treated as a story-level failure. It remains the primary behavioral proof of the story: **REQ-007 must not be marked DONE until `integration-review/mobile-visual-audit.md` records the production build reaching `api.cupidus.app` and the local-dev build still reaching local dev, with no `localhost`/`10.0.2.2` attempt from either the REST or the socket transport in the production build.**
- **D2 — `flutter analyze` exits 1 on a pre-existing lint baseline.** 80 `info`-level issues, none in the files this story touched, byte-identical to BaseHead (test-results §2). Pre-existing, not made worse. No action.
- **D3 — Unverified port literal in the configuration guide.** `deployment/configuration-guide.md:41,44` hardcodes `21020` in its local-dev emulator examples. `.env.devstack` is absent from this worktree and reading the control checkout's copy was blocked by `bash-safety-guard.sh` as potential credential exposure, so the literal is unverified. The guide names `DEVSTACK_PORT_API` in the runtime registry as the source of truth, so a reader has the correct path. Low risk; worth a check when a devstack-aware role is next in this area.

## Traceability

- Requirements: `requirements/requirements.md` AC1-AC5. `## Open Question Impact` declares no BLOCKED scope items and one non-blocking implementation note (flavor vs. `--dart-define`), resolved by Tech Lead to `--dart-define` only. OQ discipline is correct — no blocked scope was implemented and no unblocked AC was skipped on OQ grounds.
- UX: correctly SKIPPED — the story ships no screen, state, or UI surface, so rules 12e1 (entry-point reachability) and 12e2/12g2 (rendered design fidelity) do not apply.
- Architecture: `architecture/solution.md` §3 In Scope matches the delivered file set exactly; §4 mandates the pure-function guard design, which the implementation follows. The `app_config.dart` guardrail holds — empty diff against BaseHead plus source-guard test `+12`.
- Write scope: the diff touches only the four files in `phase-P1-...md:21-25` write scope, plus the story's own artifacts. No out-of-scope file was modified.
- Configuration guide (rule 12a): `deployment/configuration-guide.md` exists and accurately documents the delivered setup surface — both `--dart-define` keys with values and defaults, the unchanged local-dev invocation, the production invocation carrying both defines, the fact that one define moves both transports, and the two `StateError` failure modes with their remedy. It matches the shipped code. Verified accurate apart from D3.

## State Recommendation

- Story status: `IN_PROGRESS` (return to the mobile lane for B1).
- Leave `Review (Reviewer)` unchecked; uncheck `Implementation (Development)`.
- Re-review scope on return: B1 only — the `## Story Runtime Startup Smoke` evidence or the recorded waiver. Everything else in this report is verified and does not need re-checking.
