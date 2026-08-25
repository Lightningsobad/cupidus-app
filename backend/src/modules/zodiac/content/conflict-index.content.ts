import {
  ZODIAC_SIGNS,
  ZodiacElement,
  ZodiacSignDefinition,
  ZodiacSignKey,
} from './zodiac-sign';

export interface ConflictIndexEntry {
  score: number;
  scoreMax: number;
  vi: {
    headline: string;
    body: string;
  };
}

const SCORE_MAX = 10;

const TRAIT_VI: Record<ZodiacSignKey, string> = {
  aries: 'nóng vội nhưng thích dẫn đầu',
  taurus: 'bền bỉ và ưa sự ổn định',
  gemini: 'linh hoạt, ham giao tiếp',
  cancer: 'nhạy cảm, giàu cảm xúc',
  leo: 'tự tin, thích được chú ý',
  virgo: 'cầu toàn, chỉn chu từng chi tiết',
  libra: 'hòa nhã, luôn tìm sự cân bằng',
  scorpio: 'sâu sắc và giữ nhiều bí mật',
  sagittarius: 'phóng khoáng, ưa tự do',
  capricorn: 'nghiêm túc, sống có kế hoạch',
  aquarius: 'độc lập, tư duy khác biệt',
  pisces: 'mơ mộng, giàu trực giác',
};

const ELEMENT_COMPATIBILITY: Record<
  ZodiacElement,
  Record<ZodiacElement, number>
> = {
  fire: { fire: 6, earth: 5, air: 8, water: 4 },
  earth: { fire: 5, earth: 7, air: 5, water: 8 },
  air: { fire: 8, earth: 5, air: 6, water: 5 },
  water: { fire: 4, earth: 8, air: 5, water: 7 },
};

function pairKey(a: ZodiacSignKey, b: ZodiacSignKey): string {
  return [a, b].sort().join('-');
}

function scoreBandPhraseVi(score: number): string {
  if (score >= 8) {
    return 'là một cặp rất ăn ý, dễ tìm được tiếng nói chung';
  }
  if (score >= 6) {
    return 'cần thêm thời gian để hiểu nhau, nhưng hoàn toàn có thể hòa hợp';
  }
  return 'dễ va chạm quan điểm và cần sự khéo léo để giữ hòa khí';
}

function buildEntry(
  a: ZodiacSignDefinition,
  b: ZodiacSignDefinition,
): ConflictIndexEntry {
  const score = ELEMENT_COMPATIBILITY[a.element][b.element];

  return {
    score,
    scoreMax: SCORE_MAX,
    vi: {
      headline: `${a.viLabel} và ${b.viLabel}`,
      body: `${a.viLabel} (${TRAIT_VI[a.key]}) và ${b.viLabel} (${TRAIT_VI[b.key]}) ${scoreBandPhraseVi(score)}.`,
    },
  };
}

function buildConflictIndex(): ReadonlyMap<string, ConflictIndexEntry> {
  const table = new Map<string, ConflictIndexEntry>();

  for (let i = 0; i < ZODIAC_SIGNS.length; i += 1) {
    for (let j = i; j < ZODIAC_SIGNS.length; j += 1) {
      const a = ZODIAC_SIGNS[i];
      const b = ZODIAC_SIGNS[j];
      table.set(pairKey(a.key, b.key), buildEntry(a, b));
    }
  }

  return table;
}

export const CONFLICT_INDEX: ReadonlyMap<string, ConflictIndexEntry> =
  buildConflictIndex();

export function getConflictIndexEntry(
  signA: ZodiacSignKey,
  signB: ZodiacSignKey,
): ConflictIndexEntry | undefined {
  return CONFLICT_INDEX.get(pairKey(signA, signB));
}
