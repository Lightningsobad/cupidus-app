import { readFileSync } from 'fs';
import { join } from 'path';

import { DAILY_TIPS } from './daily-tips.content';
import { selectDailyTips } from './daily-tip.selector';

const SAMPLE_COUPLE_KEYS = [
  'user-1#user-2',
  'user-3#user-4',
  'user-5#user-6',
  'user-7#user-8',
];

describe('selectDailyTips — DETERMINISM_UNPROVEN gate (AC2)', () => {
  it('returns the identical 3 ids across 100 calls for a fixed (coupleKey, contentDate)', () => {
    const coupleKey = 'user-1#user-2';
    const contentDate = '2026-08-25';

    const first = selectDailyTips(coupleKey, contentDate, DAILY_TIPS).map(
      (tip) => tip.id,
    );

    for (let call = 0; call < 100; call += 1) {
      const result = selectDailyTips(coupleKey, contentDate, DAILY_TIPS).map(
        (tip) => tip.id,
      );
      expect(result).toEqual(first);
    }
  });

  it('always returns exactly 3 distinct ids', () => {
    SAMPLE_COUPLE_KEYS.forEach((coupleKey) => {
      const result = selectDailyTips(coupleKey, '2026-08-25', DAILY_TIPS);

      expect(result).toHaveLength(3);
      expect(new Set(result.map((tip) => tip.id)).size).toBe(3);
    });
  });

  it('changes the selection for at least one sampled couple when contentDate changes', () => {
    const dateA = '2026-08-25';
    const dateB = '2026-08-26';

    const changed = SAMPLE_COUPLE_KEYS.some((coupleKey) => {
      const resultA = selectDailyTips(coupleKey, dateA, DAILY_TIPS).map(
        (tip) => tip.id,
      );
      const resultB = selectDailyTips(coupleKey, dateB, DAILY_TIPS).map(
        (tip) => tip.id,
      );
      return JSON.stringify(resultA) !== JSON.stringify(resultB);
    });

    expect(changed).toBe(true);
  });

  it('never calls Math.random, Date.now, or new Date inside the selector source', () => {
    const source = readFileSync(
      join(__dirname, 'daily-tip.selector.ts'),
      'utf8',
    );

    expect(source).not.toMatch(/Math\.random/);
    expect(source).not.toMatch(/Date\.now/);
    expect(source).not.toMatch(/new Date/);
  });
});
