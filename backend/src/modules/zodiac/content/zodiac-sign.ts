export type ZodiacElement = 'fire' | 'earth' | 'air' | 'water';

export type ZodiacSignKey =
  | 'aries'
  | 'taurus'
  | 'gemini'
  | 'cancer'
  | 'leo'
  | 'virgo'
  | 'libra'
  | 'scorpio'
  | 'sagittarius'
  | 'capricorn'
  | 'aquarius'
  | 'pisces';

export interface ZodiacSignDefinition {
  key: ZodiacSignKey;
  element: ZodiacElement;
  viLabel: string;
}

export const ZODIAC_SIGNS: readonly ZodiacSignDefinition[] = [
  { key: 'aries', element: 'fire', viLabel: 'Bạch Dương' },
  { key: 'taurus', element: 'earth', viLabel: 'Kim Ngưu' },
  { key: 'gemini', element: 'air', viLabel: 'Song Tử' },
  { key: 'cancer', element: 'water', viLabel: 'Cự Giải' },
  { key: 'leo', element: 'fire', viLabel: 'Sư Tử' },
  { key: 'virgo', element: 'earth', viLabel: 'Xử Nữ' },
  { key: 'libra', element: 'air', viLabel: 'Thiên Bình' },
  { key: 'scorpio', element: 'water', viLabel: 'Bọ Cạp' },
  { key: 'sagittarius', element: 'fire', viLabel: 'Nhân Mã' },
  { key: 'capricorn', element: 'earth', viLabel: 'Ma Kết' },
  { key: 'aquarius', element: 'air', viLabel: 'Bảo Bình' },
  { key: 'pisces', element: 'water', viLabel: 'Song Ngư' },
];

const ZODIAC_SIGN_KEYS: ReadonlySet<string> = new Set(
  ZODIAC_SIGNS.map((sign) => sign.key),
);

export function normalizeZodiacSign(
  input: string | null | undefined,
): ZodiacSignKey | null {
  if (input === null || input === undefined) {
    return null;
  }

  const normalized = input.trim().toLowerCase();

  if (normalized.length === 0 || !ZODIAC_SIGN_KEYS.has(normalized)) {
    return null;
  }

  return normalized as ZodiacSignKey;
}
