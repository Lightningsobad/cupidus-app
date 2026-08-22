// Static content for the /zodiac page, lifted verbatim from
// `Cupid Web.dc.html` lines 285-383 and the `zodiac` array at 763-776, plus the
// `SIGNS` map in `Zodiac Icon.dc.html` lines 106-119.
//
// The fixed-length tuple aliases below are load-bearing: AC-4/5/6 pin the
// section sizes at 12 / 4 / 6, and `satisfies` turns a drifted count into an
// `astro check` failure instead of a silently short grid.

type Three<T> = readonly [T, T, T];
type Four<T> = readonly [T, T, T, T];
type Six<T> = readonly [T, T, T, T, T, T];
type Twelve<T> = readonly [T, T, T, T, T, T, T, T, T, T, T, T];

export type ZodiacKey =
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

export type ElementKey = 'fire' | 'earth' | 'air' | 'water';

export interface Sign {
  key: ZodiacKey;
  element: ElementKey;
  vi: string;
  en: string;
  /** Separator is space + EN DASH (U+2013) + space, exactly as sourced. */
  dates: string;
}

export const SIGNS = [
  { key: 'aries', element: 'fire', vi: 'Bạch Dương', en: 'Aries', dates: '21.3 – 19.4' },
  { key: 'taurus', element: 'earth', vi: 'Kim Ngưu', en: 'Taurus', dates: '20.4 – 20.5' },
  { key: 'gemini', element: 'air', vi: 'Song Tử', en: 'Gemini', dates: '21.5 – 20.6' },
  { key: 'cancer', element: 'water', vi: 'Cự Giải', en: 'Cancer', dates: '21.6 – 22.7' },
  { key: 'leo', element: 'fire', vi: 'Sư Tử', en: 'Leo', dates: '23.7 – 22.8' },
  { key: 'virgo', element: 'earth', vi: 'Xử Nữ', en: 'Virgo', dates: '23.8 – 22.9' },
  { key: 'libra', element: 'air', vi: 'Thiên Bình', en: 'Libra', dates: '23.9 – 22.10' },
  { key: 'scorpio', element: 'water', vi: 'Bọ Cạp', en: 'Scorpio', dates: '23.10 – 21.11' },
  { key: 'sagittarius', element: 'fire', vi: 'Nhân Mã', en: 'Sagittarius', dates: '22.11 – 21.12' },
  { key: 'capricorn', element: 'earth', vi: 'Ma Kết', en: 'Capricorn', dates: '22.12 – 19.1' },
  { key: 'aquarius', element: 'air', vi: 'Bảo Bình', en: 'Aquarius', dates: '20.1 – 18.2' },
  { key: 'pisces', element: 'water', vi: 'Song Ngư', en: 'Pisces', dates: '19.2 – 20.3' },
] as const satisfies Twelve<Sign>;

export function signByKey(key: ZodiacKey): Sign {
  return SIGNS.find((s) => s.key === key)!;
}

export interface ElementGroup {
  element: ElementKey;
  vi: string;
  en: string;
  labelColor: string;
  signs: Three<ZodiacKey>;
}

export const ELEMENTS = [
  {
    element: 'fire',
    vi: 'Hỏa',
    en: 'Fire',
    labelColor: 'var(--acc-peach)',
    signs: ['aries', 'leo', 'sagittarius'],
  },
  {
    element: 'earth',
    vi: 'Thổ',
    en: 'Earth',
    labelColor: 'var(--acc-butter)',
    signs: ['taurus', 'virgo', 'capricorn'],
  },
  {
    element: 'air',
    vi: 'Khí',
    en: 'Air',
    labelColor: 'var(--acc-lilac)',
    signs: ['gemini', 'libra', 'aquarius'],
  },
  {
    element: 'water',
    vi: 'Thủy',
    en: 'Water',
    labelColor: 'var(--acc-mint)',
    signs: ['cancer', 'scorpio', 'pisces'],
  },
] as const satisfies Four<ElementGroup>;

export interface Metric {
  vi: string;
  en: string;
  value: number;
  textColor: string;
  barColor: string;
}

export interface DailyRead {
  pair: readonly [ZodiacKey, ZodiacKey];
  /** Single source for both the ring's conic-gradient stop and its disc text. */
  score: number;
  captionVi: string;
  captionEn: string;
  metrics: Three<Metric>;
  nudgeLabelVi: string;
  nudgeLabelEn: string;
  nudgeBodyVi: string;
  nudgeBodyEn: string;
}

export const DAILY_READ = {
  pair: ['cancer', 'taurus'],
  score: 92,
  captionVi: 'hôm nay',
  captionEn: 'today',
  metrics: [
    { vi: 'Giao tiếp', en: 'Communication', value: 88, textColor: 'var(--acc-pink)', barColor: '#FF7FB6' },
    { vi: 'Thấu hiểu', en: 'Understanding', value: 94, textColor: 'var(--acc-lilac)', barColor: '#B78CF5' },
    { vi: 'Năng lượng', en: 'Energy', value: 71, textColor: 'var(--acc-mint)', barColor: '#79E2CD' },
  ],
  nudgeLabelVi: 'Lời khuyên hôm nay',
  nudgeLabelEn: "Today's nudge",
  nudgeBodyVi:
    'Kim Ngưu hôm nay hơi chậm nhịp — đừng giục. Cự Giải cứ nấu gì đó, im lặng cùng nhau cũng là nói chuyện.',
  nudgeBodyEn:
    "Taurus is running slow today — don't rush them. Cancer, cook something; sitting quietly together still counts as talking.",
} as const satisfies DailyRead;

export interface InSyncPair {
  /** Separator is the multiplication sign × (U+00D7), not a lowercase x. */
  vi: string;
  en: string;
  value: number;
}

export const IN_SYNC_PAIRS = [
  { vi: 'Cự Giải × Kim Ngưu', en: 'Cancer × Taurus', value: 96 },
  { vi: 'Song Ngư × Bọ Cạp', en: 'Pisces × Scorpio', value: 93 },
  { vi: 'Sư Tử × Nhân Mã', en: 'Leo × Sagittarius', value: 90 },
  { vi: 'Thiên Bình × Song Tử', en: 'Libra × Gemini', value: 88 },
  { vi: 'Ma Kết × Xử Nữ', en: 'Capricorn × Virgo', value: 85 },
  { vi: 'Bạch Dương × Bảo Bình', en: 'Aries × Aquarius', value: 82 },
] as const satisfies Six<InSyncPair>;
