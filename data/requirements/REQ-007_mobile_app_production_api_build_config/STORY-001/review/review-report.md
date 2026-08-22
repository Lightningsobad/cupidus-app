# Story Review Report: REQ-007 / STORY-001 Production API Build Flavor For Mobile App

Outcome: DEFERRED_ONLY

- Review type: `compact-story-review`, then `completion/resume` for patch cycle 1 (finding B1 only)
- Reviewer run: `RUN-REQ-007_mobile_app_production_api_build_config-STORY-001-reviewer`
- Worktree: `/Users/alantravala/workspace/snapsofts/.ai-team-worktrees/cupid-apps/story-REQ-007_mobile_app_production_api_build_config-STORY-001`
- Diff baseline: `beb1c551941fb902a872f4f2919f9451b25787f4` (initial pass); patch-cycle-1 delta reviewed at `d10b12dd48acaae1e033d9680a3ff56157ac940f..40f71aae22d3a6eda3a8b36b8a2c4cd9e848f4b6`
- Blocking findings: 0 (B1 resolved in patch cycle 1) · Deferred findings: 4

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
| Mobile app lifecycle / startup (surface added by this story, not in the plan table) | Registry-backed runtime startup smoke: app launches on device and reaches its first screen | PASS — closed in patch cycle 1, see B1 below |

## Resolved Findings

### B1 — RESOLVED in patch cycle 1

Re-verified against the delta `d10b12dd..40f71aae` (test-results.md, review
artifacts, checkpoint and story_master only — **no source file changed**, so the
code verified in the initial pass is byte-identical to what was launched).

`coding-plan/test-results.md` now carries `## Story Runtime Startup Smoke`, and
it satisfies rule 12g on every point the finding asked for:

- **Registry-backed.** Runtime id `mobile-app`; build command from the registry
  `buildCommand`; the launch/readiness probe is the registry's own
  `mobile-app.readiness` block executed verbatim, with its `shutdownCommand`.
  The evidence also explains why `scripts/run-mobile.sh` was not the vehicle
  (registry marks it `interactive: true` / `ciSafe: false`), which is the right
  call rather than a shortcut.
- **Both builds launch.** No-defines build (§A) and production-define build (§B),
  each freshly built, uninstalled-then-`adb install -r` so the launched binary is
  provably the flavor just built. `am start -W` returns `Status: ok`,
  `LaunchState: COLD`, exit 0 for build/install/probe/shutdown in both.
- **First screen reached.** The Welcome screen is described concretely in both
  runs (title, tagline, body copy, both auth actions, debug banner) — not a bare
  "launched OK" assertion.
- **No crash or error screen.** Logcat buffer cleared immediately before each
  launch; `FATAL EXCEPTION`, `StateError`, and `E/flutter` each matched 0 lines.

The negative control (§C) was not required by B1 and is not treated as one, but
it materially raises the value of the evidence: by omitting only the URL define
and catching the guard's exact `StateError` text in logcat, it proves
`--dart-define` genuinely reaches the compiled binary and that
`assertValidConfig()` executes on every real launch. That in turn upgrades §B's
clean launch into runtime evidence that `baseUrl` resolved to
`https://api.cupidus.app` — the guard compares the two resolved consts and would
have thrown for any other origin. That is a stronger result than the initial
review asked for, and the device was left clean (broken APK uninstalled,
production build reinstalled).

§D's disclosure that the registry `ResumedActivity` probe still exits 0 when the
Dart entrypoint throws is a correct and useful caveat; the pass rests on the
observed screen plus the cleared-buffer logcat check, not on the probe alone.
Recorded as D4 for the registry owner.

Original finding, for the record: the story added a throwing statement to the app
entrypoint (`CupidApiConfig.assertValidConfig()` at `mobile/lib/main.dart:20`,
before `Firebase.initializeApp`), changing the launch path of every build, while
the evidence proved only that the app **compiled** (two APK builds) and that the
guard was **logically** a no-op on the local pair (a Dart-VM unit test). Nothing
proved the app **started**. `story_master.md` carried no
`Runtime-Smoke: WAIVED — <reason>` line, so rule 12g's story-level gate applied
and was unmet.

Residual housekeeping only, no action required: `phase-P1-...md:33` still reads
`Startup Smoke: NOT_APPLICABLE`, written at planning time before the design added
the startup assertion. `test-results.md` §8 explicitly amends it, so the stale
line is superseded in the authoritative evidence.

## Deferred Findings

- **D1 — AC3/AC4 device observation deferred to the requirement-level gate.** Both ACs literally require install-and-observe on a real emulator/simulator. `phase-P1-...md:147-152` and the `architecture/solution.md` §4 risk table both route this to the requirement-level mobile runtime audit, and this handoff scoped it out, so it is not treated as a story-level failure. It remains the primary behavioral proof of the story: **REQ-007 must not be marked DONE until `integration-review/mobile-visual-audit.md` records the production build reaching `api.cupidus.app` and the local-dev build still reaching local dev, with no `localhost`/`10.0.2.2` attempt from either the REST or the socket transport in the production build.** Patch cycle 1 checked for this opportunistically while the emulator was up and correctly reported it as *not* closed (`test-results.md` §E): both builds sit on the pre-auth Welcome screen, which issues no API call, and the Dio/socket stack logs no request URLs — the 0 logcat matches are absence of traffic, not evidence of correct traffic. The audit needs an authenticated session that actually exercises the transports. Note that §C's negative control now gives *indirect* runtime evidence of correct origin resolution in the production build, which narrows D1 to observing real traffic rather than proving the define took effect.
- **D4 — Registry `mobile-app.readiness` probe cannot detect a Dart-level startup failure.** `test-results.md` §D reports that in the negative control the probe still exited 0: the Android activity reaches `ResumedActivity` even though the Dart entrypoint threw and no UI rendered. The `ResumedActivity` check is therefore not sufficient as the documented readiness contract for a Flutter app whose failure mode is an unhandled Dart exception. Out of scope for this story (the smoke verdict here rests on the observed screen plus the cleared-buffer logcat check, not on the probe). [devops] Consider strengthening the `mobile-app.readiness` probe in `data/devops/system/runtime-command-registry.json`, since other stories will lean on it.
- **D2 — `flutter analyze` exits 1 on a pre-existing lint baseline.** 80 `info`-level issues, none in the files this story touched, byte-identical to BaseHead (test-results §2). Pre-existing, not made worse. No action.
- **D3 — Unverified port literal in the configuration guide.** `deployment/configuration-guide.md:41,44` hardcodes `21020` in its local-dev emulator examples. `.env.devstack` is absent from this worktree and reading the control checkout's copy was blocked by `bash-safety-guard.sh` as potential credential exposure, so the literal is unverified. The guide names `DEVSTACK_PORT_API` in the runtime registry as the source of truth, so a reader has the correct path. Low risk; worth a check when a devstack-aware role is next in this area.

## Traceability

- Requirements: `requirements/requirements.md` AC1-AC5. `## Open Question Impact` declares no BLOCKED scope items and one non-blocking implementation note (flavor vs. `--dart-define`), resolved by Tech Lead to `--dart-define` only. OQ discipline is correct — no blocked scope was implemented and no unblocked AC was skipped on OQ grounds.
- UX: correctly SKIPPED — the story ships no screen, state, or UI surface, so rules 12e1 (entry-point reachability) and 12e2/12g2 (rendered design fidelity) do not apply.
- Architecture: `architecture/solution.md` §3 In Scope matches the delivered file set exactly; §4 mandates the pure-function guard design, which the implementation follows. The `app_config.dart` guardrail holds — empty diff against BaseHead plus source-guard test `+12`.
- Write scope: the diff touches only the four files in `phase-P1-...md:21-25` write scope, plus the story's own artifacts. No out-of-scope file was modified.
- Configuration guide (rule 12a): `deployment/configuration-guide.md` exists and accurately documents the delivered setup surface — both `--dart-define` keys with values and defaults, the unchanged local-dev invocation, the production invocation carrying both defines, the fact that one define moves both transports, and the two `StateError` failure modes with their remedy. It matches the shipped code. Verified accurate apart from D3.

## State Recommendation

- Story status: `DONE`.
- Keep `Implementation (Development)` checked; check `Review (Reviewer)`.
- Story branch is merge-eligible into `codex/REQ-007_mobile_app_production_api_build_config-integration`.
- Carry D1 forward as a requirement-closure condition: REQ-007 must not be marked `DONE` until the requirement-level mobile visual/runtime audit observes the actual REST/socket destinations for both flavors. D4 is a DevOps registry note, not a REQ-007 blocker.
