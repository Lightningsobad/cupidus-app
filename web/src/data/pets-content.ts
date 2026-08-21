// Content array lifted verbatim from `Cupid Web.dc.html` lines 756-760
// (`DCLogic.renderVals().stages`). Every VI/EN string is character-for-character
// identical to the source. `pets` is NOT re-declared here: it lives in
// `home-content.ts` and is imported from there, so BR-2 keeps one source.

export interface Stage {
  n: string;
  tvi: string;
  ten: string;
  dvi: string;
  den: string;
}

export const stages: Stage[] = [
  { n: "01", tvi: "Trứng", ten: "Egg", dvi: "Ba ngày đầu. Cần cả hai check-in mới nở.", den: "First three days. Hatches only when both check in." },
  { n: "02", tvi: "Bé con", ten: "Baby", dvi: "Học tên hai bạn, bắt đầu đòi ăn và đòi chơi.", den: "Learns both names, starts asking for food and play." },
  { n: "03", tvi: "Trưởng thành", ten: "Grown", dvi: "Mở nhật ký chung, album ảnh và thử thách khó.", den: "Unlocks the shared journal, album, and harder quests." },
  { n: "04", tvi: "Linh thú", ten: "Spirit", dvi: "Sau 365 ngày. Có hào quang riêng và thẻ kỷ niệm giới hạn.", den: "After 365 days. Gains an aura and a limited keepsake card." }
];
