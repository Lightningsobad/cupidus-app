# STORY-001 Production API Build Flavor For Mobile App – solution.md

## 0. Metadata

- Complexity: standard
- Date: 2026-08-22

## 1. Decision Summary

- Mode: Brownfield
- Architecture Drivers: additive second build configuration (AC1), zero change to
  the local-dev build path (AC2, AC4), no silent fallback to local dev (AC5 +
  requirements `Edge Cases`), build-time-only selection with no runtime UI toggle
  (AC5).
- Architectural invariants / non-goals:
  - `CupidApiConfig.baseUrl` stays the single compile-time source of the API
    origin. No second config source, no runtime setter, no UI toggle.
  - No Android `productFlavors`, no iOS scheme/xcconfig variants, no
    applicationId/bundleId variants. Signing, store upload, and CI are out of
    scope, and Gradle/Xcode flavors cannot be added without touching them.
  - The local-dev default value and default behavior are frozen by AC2.
- Proposed technical direction: resolve the open mechanism question in favor of
  plain `--dart-define`, extending the key that already exists
  (`CUPID_API_BASE_URL`) with a second key `CUPID_ENV` (`local` | `production`,
  default `local`), plus a fail-fast startup guard that refuses to run a build
  declaring `CUPID_ENV=production` while pointing anywhere other than
  `https://api.cupidus.app`. "Production flavor" is therefore a documented pair
  of build-time defines, not a Gradle/Xcode product flavor.
- Why this fits the current system or new area: the mechanism is already in the
  codebase and already carries the API origin in production-shaped code —
  `mobile/lib/core/config/cupid_api_config.dart` reads
  `String.fromEnvironment('CUPID_API_BASE_URL')`, and the same
  `String.fromEnvironment` pattern is the established convention in
  `core/config/cupid_feature_flags.dart` and the preview harness. This story adds
  a guard and documentation, not plumbing.

### Key Discovery

Two findings from reading the code change the shape of this story:

1. **The silent local-dev fallback the requirement fears is already built in.**
   `CupidApiConfig.baseUrl` declares `defaultValue: 'http://localhost:3000'`. A
   production build that omits or mistypes `--dart-define=CUPID_API_BASE_URL=...`
   compiles cleanly, ships, and quietly talks to localhost. AC2 forbids changing
   that default, so the fallback cannot be removed — it must be *detected*. This
   is why the design adds a separate `CUPID_ENV` declaration and a startup
   assertion instead of only documenting a longer build command: the intent
   ("this is a production build") becomes independently checkable against the
   resolved URL.

2. **One constant switches both transports.** `CupidApiConfig.baseUrl` is
   consumed by the REST client (`core/network/cupid_api_client.dart:15`) *and* by
   the realtime socket (`core/di/service_locator.dart:199`,
   `SocketTransport.url`). A single define therefore moves both, and the
   emulator/simulator observation must confirm neither transport is still
   reaching localhost — not just the first REST call.

3. **There is a decoy config file.** `mobile/lib/core/config/app_config.dart`
   declares `AppConfig.defaultConfig` with `apiBaseUrl: 'http://localhost:3000'`
   and `environment: 'local'` — the exact shape this story is about — but a
   repo-wide grep finds no reference to `AppConfig` outside its own file. It is
   unreferenced scaffolding from a foundation story. An implementer searching for
   "the environment config" will land there first and wire the wrong file.
   Guardrail below forbids touching it.

## 2. Downstream Contract Pointer

- Cross-lane contract: none. Single-lane (mobile) story with no consumer in
  another lane, repository, or later story; `architecture/contract-summary.md` is
  intentionally not written.

## 3. Scope And Assumptions

- In Scope: `mobile/lib/core/config/cupid_api_config.dart` build-time config
  surface, its startup assertion call site in `mobile/lib/main.dart`, unit
  coverage for the assertion, and the requirement configuration guide.
- Out Of Scope: Android/iOS project files, signing, CI, backend, and any UI.
- Assumptions affecting design:
  - `https://api.cupidus.app` is live per REQ-005 (DONE) and serves the same API
    surface as local dev; this story does not verify API parity, only origin.
  - The existing local-dev workflow is plain `flutter run` relying on the
    compiled-in default, i.e. no local-dev invocation has to change.

## 4. Architecture Delta

### Boundaries And Ownership

- Owning module / service: `mobile` app, `lib/core/config`.
- New or changed boundaries: none. `CupidApiConfig` remains the only boundary
  between build-time environment input and every API consumer.
- Shared patterns reused or introduced: reuses the existing const
  `String.fromEnvironment` config pattern. Introduces one new pattern — a pure,
  parameterized validation function (`validationError(environment, baseUrl)`)
  behind a const-fed wrapper — because `String.fromEnvironment` is compile-time
  const and therefore cannot be varied inside a unit test. The pure function is
  what makes the guard testable at all.

### Affected Modules

- Mobile: `lib/core/config`, `lib/main.dart` (entrypoint call site only).

### Contracts And Integrations

- Error, retry, timeout, idempotency, and empty-state contract: the guard fails
  loudly and early — it throws before `setupServiceLocator()`, so a misconfigured
  production build cannot reach a network call at all. There is no degraded mode
  and no retry: a build either declares a consistent environment or does not run.
  Timeouts (`connectTimeout` / `receiveTimeout`) are unchanged.
- Compatibility or versioning posture: strictly additive. Omitting both defines
  reproduces today's behavior byte-for-byte, which is how AC2 and AC4 are held.
- External or trust-boundary implications: the production build moves traffic
  from cleartext `http://localhost:3000` to TLS `https://api.cupidus.app`. The
  production URL must be `https`; the guard enforces the exact expected origin,
  so a cleartext or wrong-host production build is rejected rather than shipped.

### Risk Surfaces And Source Of Truth

| Risk Surface | Source Of Truth | Mitigation | Verification Gate | Blocker If Gate Cannot Run |
|--------------|-----------------|------------|-------------------|----------------------------|
| Production origin resolution | `mobile/lib/core/config/cupid_api_config.dart` | `CUPID_API_BASE_URL` + `CUPID_ENV` defines resolve to `https://api.cupidus.app` | Requirement-level mobile runtime audit: production-define build installed and run on emulator/simulator, observed making a live call to `api.cupidus.app` | `api.cupidus.app` unreachable, or no emulator/simulator available |
| Silent local-dev fallback | same file, `defaultValue: 'http://localhost:3000'` | `validationError()` rejects `CUPID_ENV=production` paired with any origin other than the production URL; thrown before service-locator setup | Unit tests over `validationError()` covering missing define, typo'd define, and cleartext production origin | none — pure-function tests always runnable |
| Local-dev build regression | `cupid_api_config.dart` default + `main.dart` call site | defaults unchanged (`local`, `http://localhost:3000`); guard is a no-op on the local pair | Same-run regression: local-dev build (no defines) built and run on emulator/simulator, observed still calling the local-dev API | local backend not running under devstack |
| Dual-transport origin leak | `core/network/cupid_api_client.dart:15`, `core/di/service_locator.dart:199` | both consumers read the one `CupidApiConfig.baseUrl` const; no second origin exists to drift | Runtime audit confirms no `localhost` / `10.0.2.2` connection attempt from either REST or socket transport in the production build | same as production origin resolution |
| Build-time-only selection (AC5) | absence of any writable origin | `baseUrl` is `static const`; Dart forbids assignment, so no runtime toggle is representable | Static analysis + reviewer check that no widget, settings screen, or service writes an API origin | none |

### Lane Handoff

#### Mobile Lane

- Responsibilities: extend `CupidApiConfig`, add the pure validation function and
  its `main.dart` call site, unit-test the validation, and author the requirement
  configuration guide with both build invocations.
- Authoritative inputs: `../requirements/requirements.md` AC1–AC5, this section 4.
- Guardrails:
  - Do NOT modify `mobile/lib/core/config/app_config.dart`. It is unreferenced
    (see section 1 Key Discovery 3) and is not the config this story extends.
  - Do NOT change `defaultValue: 'http://localhost:3000'` or the default
    `CUPID_ENV` value — AC2/AC4 depend on the unchanged local-dev default.
  - Do NOT add Android `productFlavors`, iOS schemes/xcconfig, or any
    applicationId/bundleId variant.
  - Do NOT expose the origin or environment anywhere in the app UI.
  - Do NOT hard-code `https://api.cupidus.app` at any call site; the only literal
    occurrence outside the guard's expected-value constant is in documentation.
- Requirement configuration guide update: REQUIRED — the story introduces two
  build-time values (`CUPID_API_BASE_URL`, `CUPID_ENV`) and a second documented
  build invocation, which is exactly what the guide exists to record.

## 5. Non-Functional Impact

- The startup guard runs before `Firebase.initializeApp` completes its effect on
  app readiness and must stay allocation-free and synchronous, so it adds no
  measurable launch cost; a guard that performed a network probe would violate
  the fail-fast-without-side-effects property this design relies on.

## 6. Option Evaluation

| Option | Why Considered | Decision | Notes |
|--------|----------------|----------|-------|
| `--dart-define` on existing `CUPID_API_BASE_URL` + new `CUPID_ENV` + startup guard | The key, the reader, and the `String.fromEnvironment` convention already exist; the only genuinely missing piece is fallback detection | ACCEPTED | Resolves req_master.md `Open Questions`: mechanism is `--dart-define`, not Gradle/Xcode product flavors |
| Android `productFlavors` + iOS schemes | AC1 names "flavor"; gives a first-class `--flavor production` switch | REJECTED | Requires per-flavor applicationId/bundleId, new Xcode schemes, and per-flavor signing configuration — all explicitly out of scope in `requirements.md`. It would also add a second origin source next to `CupidApiConfig`, contradicting the section 1 invariant |
