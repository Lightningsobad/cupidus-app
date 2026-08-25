import { CONFLICT_INDEX, getConflictIndexEntry } from './conflict-index.content';
import { ZODIAC_SIGNS, ZodiacSignKey } from './zodiac-sign';

function allSortedPairKeys(): string[] {
  const keys: string[] = [];
  const signKeys = ZODIAC_SIGNS.map((sign) => sign.key);

  for (let i = 0; i < signKeys.length; i += 1) {
    for (let j = i; j < signKeys.length; j += 1) {
      keys.push([signKeys[i], signKeys[j]].sort().join('-'));
    }
  }

  return keys;
}

describe('conflict-index content table — CONTENT_TABLE_INCOMPLETE gate (AC1)', () => {
  it('covers all 78 unordered sign pairs', () => {
    const pairKeys = allSortedPairKeys();

    expect(pairKeys).toHaveLength(78);
    expect(new Set(pairKeys).size).toBe(78);
    expect(CONFLICT_INDEX.size).toBe(78);
  });

  it('resolves every sorted pair key to an entry with non-empty vi headline/body and a valid score', () => {
    const missingPairKeys: string[] = [];

    for (const pairKey of allSortedPairKeys()) {
      const entry = CONFLICT_INDEX.get(pairKey);

      const isValid =
        entry !== undefined &&
        entry.vi.headline.trim().length > 0 &&
        entry.vi.body.trim().length > 0 &&
        entry.score >= 0 &&
        entry.score <= entry.scoreMax;

      if (!isValid) {
        missingPairKeys.push(pairKey);
      }
    }

    expect(missingPairKeys).toEqual([]);
  });

  it('is order-independent for a lookup by two sign keys', () => {
    const a: ZodiacSignKey = 'cancer';
    const b: ZodiacSignKey = 'pisces';

    expect(getConflictIndexEntry(a, b)).toEqual(getConflictIndexEntry(b, a));
  });
});
