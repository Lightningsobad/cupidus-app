import { normalizeZodiacSign, ZODIAC_SIGNS } from './zodiac-sign';

describe('normalizeZodiacSign — NORMALIZATION_UNPROVEN gate (AC3)', () => {
  it('maps recognised signs regardless of casing or surrounding whitespace', () => {
    expect(normalizeZodiacSign('Aries')).toBe('aries');
    expect(normalizeZodiacSign('aries')).toBe('aries');
    expect(normalizeZodiacSign(' ARIES ')).toBe('aries');
  });

  it('maps empty, missing, and unrecognised input to null', () => {
    expect(normalizeZodiacSign('')).toBeNull();
    expect(normalizeZodiacSign(null)).toBeNull();
    expect(normalizeZodiacSign(undefined)).toBeNull();
    expect(normalizeZodiacSign('ophiuchus')).toBeNull();
  });

  it('exposes exactly the 12 canonical lowercase sign keys', () => {
    const keys = ZODIAC_SIGNS.map((sign) => sign.key);

    expect(keys).toHaveLength(12);
    expect(new Set(keys).size).toBe(12);
    keys.forEach((key) => expect(key).toBe(key.toLowerCase()));
  });
});
