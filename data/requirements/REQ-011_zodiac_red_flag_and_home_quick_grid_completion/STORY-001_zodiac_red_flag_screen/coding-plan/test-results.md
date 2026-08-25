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
