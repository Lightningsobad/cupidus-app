import { DailyTip } from './daily-tips.content';

const FNV_OFFSET_BASIS = 0x811c9dc5;
const FNV_PRIME = 0x01000193;

function fnv1a32(input: string): number {
  let hash = FNV_OFFSET_BASIS;

  for (let i = 0; i < input.length; i += 1) {
    hash ^= input.charCodeAt(i);
    hash = Math.imul(hash, FNV_PRIME);
  }

  return hash >>> 0;
}

const SELECTED_TIP_COUNT = 3;

/**
 * Pure, deterministic tip selector. The couple key and content date are the
 * only inputs — no clock or RNG is read here so the same pair always
 * resolves to the same three tips for a given calendar day.
 */
export function selectDailyTips(
  coupleKey: string,
  contentDate: string,
  pool: readonly DailyTip[],
): DailyTip[] {
  const baseSeed = fnv1a32(`${coupleKey}#${contentDate}`);
  const usedIndices = new Set<number>();
  const selected: DailyTip[] = [];

  for (let slot = 0; slot < SELECTED_TIP_COUNT; slot += 1) {
    const slotSeed = fnv1a32(`${baseSeed}:${slot}`);
    let index = slotSeed % pool.length;

    while (usedIndices.has(index)) {
      index = (index + 1) % pool.length;
    }

    usedIndices.add(index);
    selected.push(pool[index]);
  }

  return selected;
}
