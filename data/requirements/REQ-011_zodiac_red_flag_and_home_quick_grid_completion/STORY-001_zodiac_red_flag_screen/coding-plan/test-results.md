# Test Results

## P0 — Zodiac Content Tables And Pure Selector

- Date: 2026-08-25
- Command: `npx jest src/modules/zodiac` (in `backend`)
- Result: 4 suites passed, 4 total; 14 tests passed, 14 total.
  - `daily-tip.selector.spec.ts` — 4/4 passed (DETERMINISM_UNPROVEN gate)
  - `conflict-index.content.spec.ts` — 3/3 passed (CONTENT_TABLE_INCOMPLETE gate)
  - `daily-tips.content.spec.ts` — 4/4 passed (TIP_POOL_TOO_SMALL gate)
  - `zodiac-sign.spec.ts` — 3/3 passed (NORMALIZATION_UNPROVEN gate)
- Command: `npm run build` (in `backend`)
- Result: exit code 0 (`nest build`).

## P1 — Zodiac Module, Endpoint And Response Union

- Date: 2026-08-25
- Command: `npx jest src/modules/zodiac` (in `backend`)
- Result: 19 tests passed, 0 failed (5 suites total: the 4 P0 content suites plus `zodiac.service.spec.ts`).
  - `zodiac.service.spec.ts` — 5/5 passed (DEGRADED_PATH_UNPROVEN gate):
    - `ready` payload has exactly 2 partners (`partners[0].role === "self"`) and 3 distinct daily tips
    - `incomplete_profile` / `partner_link` (unpaired) — asserts key-absence for `conflictIndex`, `partners`, `dailyTips`
    - `incomplete_profile` / `self_zodiac` (self sign unset)
    - `incomplete_profile` / `partner_zodiac` (partner sign unrecognised, e.g. `'ophiuchus'`)
    - stable `contentDate` from the injected `ZODIAC_CLOCK` pinned to `2026-08-25`
- Command: `npm run build` (in `backend`)
- Result: exit code 0 (`nest build`) after fixing 3 TS1272 errors — DTO type-only imports (`ZodiacSignKey`, `DailyTipIcon`, `DailyTipTint`) needed `import type` under `isolatedModules` + `emitDecoratorMetadata`.

## P2 — Mobile Zodiac Data, Domain And State

- Date: 2026-08-25
- Command: `flutter test test/features/zodiac` (in `mobile`)
- Result: 20 tests passed, 0 failed (2 suites).
  - `zodiac_repository_test.dart` — 15/15 passed, fixtures copied verbatim from
    `../architecture/contract-summary.md` §1:
    - `ready` yields exactly 2 partners with `partners[0].role == self`
      (`cancer`/`pisces` via `CupidZodiacSign.tryParse`, lowercase, unchanged)
    - `ready` yields exactly 3 tips in wire order (`tip-04`, `tip-09`, `tip-02`)
    - `fillFraction` derives `7/10` from `score`/`scoreMax` (no hardcoded `10`)
    - `displayName: null` falls back to the sign's `viLabel`
    - `incomplete_profile` yields the incomplete variant with `missing`
    - unknown `status` (`ready_v2`) yields the incomplete variant, never `ready`
    - unknown `tint` (`chartreuse`) -> `ZodiacTipTint.neutral`, no throw
    - unknown `icon` (`rocket_launch`) -> `ZodiacTipIcon.favorite`, no throw
    - missing `conflictIndex.scoreMax`, missing `dailyTips`, unrecognised
      `zodiacSign` (`ophiuchus`), and a non-object body each throw
      `UnexpectedFailure` — no substituted default
    - `fetchToday()` calls `GET /zodiac/red-flag/today` with no query params and
      rethrows the mapped `CupidApiFailure` from `DioException.error`
  - `zodiac_cubit_test.dart` — 5/5 passed: initial `ZodiacLoading`; `ready` ->
    `ZodiacReady`; degraded -> `ZodiacIncompleteProfile` (not `ZodiacError`);
    failure -> `ZodiacError` carrying the `CupidApiFailure`; retry from error
    re-emits `ZodiacLoading` then `ZodiacReady`.
- Command: `flutter analyze lib/features/zodiac lib/core/di/service_locator.dart test/features/zodiac` (in `mobile`)
- Result: exit code 0, "No issues found!" — clean for every file this phase
  touched.
- Command: `flutter analyze` (whole `mobile` package)
- Result: exit code 1, 11394 issues — a pre-existing worktree baseline, not a
  P2 regression. It is dominated by `Undefined class 'AppL10n'` (285 lines):
  `flutter analyze` does not run `gen-l10n`, so the generated localization
  class is absent from a fresh worktree (`flutter test` generates it and
  passes). Zero of the 11394 findings are in `mobile/lib/features/zodiac`,
  `mobile/test/features/zodiac`, or `service_locator.dart`.
- Check: AC1 confinement — `git grep --untracked` over `mobile/lib` for
  `'/zodiac`, `'contentDate'`, `'conflictIndex'`, `'dailyTips'`, `'scoreMax'`,
  `'partners'`, `'missing'`, `'role'`, `'tint'`, `'ready'`,
  `'incomplete_profile'`, `'displayName'`.
- Result: every zodiac-payload occurrence is in
  `mobile/lib/features/zodiac/data/zodiac_repository.dart`. The only other hits
  are pre-existing and belong to unrelated contracts: `'displayName'` in
  `account/domain/cupid_profile.dart`, `chat/data/chat_partner_store.dart`,
  `love_contracts/data/love_contract_gate_repository.dart`; `'ready'` as a
  `vi/en` UI string in `vow/presentation/screens/vow_screen.dart` and as a
  dream-jar preview key in `main_preview.dart`; `'zodiacSign'` in
  `cupid_profile.dart` (the `/users/me` profile payload, not this endpoint).
- Check: AC5 — `git grep --untracked` for `DateTime.now`, `zodiacSignFor`,
  `birthday` under `mobile/lib/features/zodiac`.
- Result: one doc-comment mention of `DateTime.now()` in
  `domain/zodiac_red_flag.dart` stating the prohibition; no call site, no sign
  re-derivation (OQ2 RESOLVED).

## P3 — Mobile Zodiac Screen, Route And Preview Entry

- Date: 2026-08-25
- Command: `flutter test test/features/zodiac` (in `mobile`)
- Result: 40 tests passed, 0 failed (5 suites) — the 20 P2 tests plus 20 new
  ones. New suites:
  - `presentation/zodiac_red_flag_screen_test.dart` — 13/13 passed:
    - ready state mounts Card 1, `ZodiacConflictIndexCard`, `ZodiacDailyTipsCard`
    - eyebrow reads `RED FLAG · 29/07` from `contentDate`, with a negative
      assertion that today's `dd/MM` is absent — a `DateTime.now()` regression
      fails this test on any day but the fixture's
    - score renders `7/10` and the bar's `FractionallySizedBox.widthFactor`
      equals `conflictIndex.fillFraction`
    - the off-scale `3/6` fixture renders `3/6` at `widthFactor == 0.5`, which
      no hardcoded `10` denominator or `70%` width can produce
    - both partner discs are `CupidZodiacIcon` in wire order `[cancer, pisces]`
      with `color == null`, so element ink comes from the icon, not the caller
    - `displayName: null` falls back to `CupidZodiacSign.aries.viLabel` /
      `taurus.viLabel`; `'Bạn'`, `'Người ấy'`, `'Partner'`, `'You'` and `'—'`
      are each asserted absent
    - all three tip rows render in wire order; a 1-tip payload renders 1 row
  - `presentation/zodiac_red_flag_screen_test.dart`, degraded group:
    - state 2c renders `'Chưa đủ thông tin cung hoàng đạo'`
    - `ZodiacConflictIndexCard`, `ZodiacDailyTipsCard`, `CupidZodiacIcon` and
      `FractionallySizedBox` are each `findsNothing`; no partner name and no
      sign label appear; no `'Thử lại'` action is offered
    - error state renders `'Thử lại'`, and tapping it drives
      `FakeZodiacRepository.fetchCount` from 1 to 2
    - loading state renders the skeleton with `CupidHeader` already present
  - `presentation/zodiac_route_test.dart` — 5/5 passed:
    - `Navigator.pushNamed(ZodiacRedFlagScreen.routeName)` from the authenticated
      shell mounts `ZodiacRedFlagScreen` (AC5 reachability)
    - the route map never shadows `home:` — `app.home != null`,
      `routes` has no `'/'` key, and does have `ZodiacRedFlagScreen.routeName`
    - `main_preview.dart` no longer lists `'zodiac'` in `_notImplementedCanvasIds`
      and does declare `'zodiac': const PreviewScreenEntry(`
    - source guard over `lib/features/zodiac/**`: `RegExp(r'[♈-♓]')` matches
      nothing (AC4 — no Unicode zodiac glyph anywhere)
    - source guard over `lib/features/zodiac/**`:
      `RegExp(r'Color(\.fromRGBO|\.fromARGB)?\(0x|#[0-9a-fA-F]{6}')` matches
      nothing (design-system tokens only, no raw hex)
  - `presentation/zodiac_red_flag_screen_golden_test.dart` — 2/2 passed:
    `goldens/zodiac_red_flag_ready.png` and `goldens/zodiac_red_flag_incomplete.png`
    at the 412x915 Android reference viewport, dark theme + `vi`. Written once
    with `--update-goldens` after the visual-fidelity PASS, then re-verified
    without the flag.
- Command: `flutter test test/app` (in `mobile`)
- Result: 11 tests passed, 0 failed — `cupid_app.dart` gaining a `routes:` map
  regresses neither `cupid_app_entry_routing_test.dart` (7 tests, including the
  splash/dwell/lifecycle invariants) nor `feature_flags_test.dart` nor the
  dark-theme + `vi` locale resolution test.
- Command: `flutter analyze test/features/zodiac lib/features/zodiac lib/app/cupid_app.dart lib/main_preview.dart` (in `mobile`)
- Result: exit code 0, "No issues found! (ran in 1.6s)" — clean for every file
  this phase touched.
- Command: `flutter build apk --debug -t lib/main_preview.dart --dart-define=PREVIEW=zodiac --target-platform android-arm64` (in `mobile`)
- Result: exit code 0, `✓ Built build/app/outputs/flutter-apk/app-local-debug.apk` (37.6s).
- Check: per-story visual fidelity (device capture vs design reference).
- Result: `VISUAL_FIDELITY: PASS` — see
  `../visual-fidelity/visual-fidelity-report.md`. Capture artifact:
  `../visual-fidelity/implemented-zodiac-emulator-5554.png` (405x900, taken from
  the `cupidpreview://screen/zodiac` entrypoint on `emulator-5554` at
  `--width=540 --density=210`, i.e. a 411dp viewport matching the canvas' 412dp).
  Three intentional deltas are recorded there: the absent bottom tab bar (the
  screen is pushed above `AppShell`), real backend content prose instead of the
  canvas' hand-written sample copy, and no design reference existing for state 2c
  (verified by widget test and golden instead).

## Story Runtime Startup Smoke (backend half — Reviewer F-1)

- Date: 2026-08-25
- Scope: closes the backend half of review finding F-1 (rule 12g) —
  `npm run build` proves TypeScript type-checks only, not that
  `ZodiacModule`/`ZodiacController` and the `ZODIAC_CLOCK` provider actually
  resolve in Nest's DI graph at boot. This section is direct runtime-boot
  evidence for that claim.
- Worktree infra note: `.env.devstack` and `backend/service-account.json` are
  gitignored and are not carried into `git worktree` checkouts by git. The
  registry-reserved `api` port (21020) was already held by another live
  process at smoke time (`lsof -nP -iTCP:21020` showed a listening `node`
  PID), so this smoke leased a dedicated parallel-worktree port instead of
  reusing the shared reservation: `devstack port lease --slot
  REQ-011-STORY-001-devops-smoke --role api --path <Worktree>` ->
  `DEVSTACK_LEASE_API=22000`. A worktree-local `.env.devstack` was written
  with `POSTGRES_*`/`REDIS_*` copied unchanged from the shared tenant contract
  and `DEVSTACK_PORT_API`/`PORT`/`API_PORT` overridden to `22000`;
  `backend/service-account.json` was copied unchanged from the main checkout.
  Both are gitignored/machine-local, not part of the story diff.
- Command: `set -a && source .env.devstack && set +a && cd backend && npm run
  start:dev` (i.e. `nest start --watch`, the registry `backend-api.devCommand`)
  run in the background inside `Worktree`.
- DI-boot confirmation (from the process log): `[InstanceLoader] ZodiacModule
  dependencies initialized`, `[RoutesResolver] ZodiacController {/zodiac}`,
  `[RouterExplorer] Mapped {/zodiac/red-flag/today, GET} route`, followed by
  `[NestApplication] Nest application successfully started` — no
  `UnknownDependenciesException`, no `Nest can't resolve dependencies`, no
  `ERROR` line anywhere in the boot log (`ZODIAC_CLOCK` resolves cleanly).
- Readiness probe: `GET http://127.0.0.1:22000/api-docs-json` -> `HTTP 200`
  (registry `backend-api.readiness`, port substituted for the leased port).
- Supporting probe: `GET http://127.0.0.1:22000/zodiac/red-flag/today` ->
  `HTTP 401` (route handler executes and the auth guard runs — not a 500/DI
  fault).
- Shutdown: process killed by PID after the probes; `lsof -nP
  -iTCP:22000 -sTCP:LISTEN` confirmed no listener remained.
- Result: `PASS` — `ZodiacModule`/`ZodiacController`/`ZODIAC_CLOCK` resolve in
  Nest's DI graph at boot; readiness probe green; clean shutdown. F-1 backend
  half closed. Mobile half of F-1 and F-2 are out of scope for this smoke
  (owned separately).
