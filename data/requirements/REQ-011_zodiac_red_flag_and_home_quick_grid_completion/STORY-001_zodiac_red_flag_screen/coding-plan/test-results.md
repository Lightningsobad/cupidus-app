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
