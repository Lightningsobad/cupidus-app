# Deployment Log: REQ-008 Android build variants for local/prod backend

## Entry 1 — Automatic development-local deployment (2026-08-24)

- Trigger: automatic post-requirement `development-local` deployment (skill
  rule 7), per `data/devops/system/devops_system_memory.md` §2/§3/§3.1/§3.2
  environment matrix (`development-local | YES | automatic after requirement
  DONE`). Not a user-requested staging/production deployment.
- Requirement status at trigger time: DONE (STORY-001 passed compact-story
  review with `Outcome: DEFERRED_ONLY`).
- Change surface: REQ-008 touches only the `mobile-app` runtime id —
  `mobile/android/app/build.gradle.kts` (native `backend` flavor dimension,
  `local`/`prod` flavors) and `mobile/pubspec.yaml` (`default-flavor: local`).
  It does not touch `backend-api`.
- Verification scope: scoped to the impacted runtime only
  (`mobile-app`), per the runtime-startup-smoke scoping rule in
  `.agent-contract/cache-policy.md`. `backend-api` is unaffected by this
  requirement's change surface and was not re-verified.
- Commands executed (matching `scripts/start-dev.sh`'s own mobile-app
  readiness signal, per `data/devops/system/runtime-command-registry.json`
  `runtimes.mobile-app.notes`: "scripts/start-dev.sh runs `flutter pub get` +
  `flutter test` as the dev readiness signal"):
  - `flutter pub get` (in `mobile/`) — succeeded, dependencies resolved.
  - `flutter test` (in `mobile/`) — `All tests passed!` (1357 passed, 2
    skipped, 0 failed), including `test/widget_test.dart: App boots to the
    home screen ready signal` (the registered `mobile-app` readiness widget
    test, `Key('home_screen_ready_signal')`). This exercises the new
    `pubspec.yaml` `default-flavor: local` entry, since `flutter test` runs
    under the default flavor (per this requirement's own
    `deployment/configuration-guide.md`) — confirms the flavor change did not
    break the existing local test/build path.
  - Prior test count on record in `devops_system_memory.md` §3/§3.1 was
    1317/1317 (2026-08-20, before this requirement); the higher count here
    (1357 passed + 2 skipped = 1359 total) reflects test suite growth from
    requirements delivered since then, not a regression.
- Result: mobile-app development-local readiness signal PASSED. No
  `backend-api` action required (out of this requirement's change surface).
- Deployment Status recorded in `req_master.md`: Development Environment =
  `DEPLOYED` (mobile-app scope; verified via registered readiness signal, not
  a device install/manual smoke — Flutter app launch itself remains
  interactive/manual per the runtime registry's `launch` block).
