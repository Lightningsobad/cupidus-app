import {
  DAILY_TIPS,
  DailyTipIcon,
  DailyTipTint,
} from './daily-tips.content';

const ALLOWED_TINTS: readonly DailyTipTint[] = [
  'mint',
  'pink',
  'amber',
  'lilac',
  'peach',
];

const ALLOWED_ICONS: readonly DailyTipIcon[] = [
  'videocam',
  'block',
  'local_cafe',
  'nightlight',
  'favorite',
  'chat_bubble',
  'savings',
  'self_improvement',
];

describe('daily-tips content pool — TIP_POOL_TOO_SMALL gate (AC2/UX §2 Card 3)', () => {
  it('has at least 12 tips', () => {
    expect(DAILY_TIPS.length).toBeGreaterThanOrEqual(12);
  });

  it('has stable, distinct ids', () => {
    const ids = DAILY_TIPS.map((tip) => tip.id);

    expect(new Set(ids).size).toBe(DAILY_TIPS.length);
    ids.forEach((id) => expect(id.trim().length).toBeGreaterThan(0));
  });

  it('draws icon and tint only from the contract-summary vocabularies', () => {
    DAILY_TIPS.forEach((tip) => {
      expect(ALLOWED_TINTS).toContain(tip.tint);
      expect(ALLOWED_ICONS).toContain(tip.icon);
    });
  });

  it('has non-empty vi title/body for every tip', () => {
    DAILY_TIPS.forEach((tip) => {
      expect(tip.vi.title.trim().length).toBeGreaterThan(0);
      expect(tip.vi.body.trim().length).toBeGreaterThan(0);
    });
  });
});
