// Content arrays lifted verbatim from `Cupid Web.dc.html` lines 734-754
// (`DCLogic.renderVals()`). Every VI/EN string is character-for-character
// identical to the source, including the inner `"sao thế?"` quotes and the
// em dash in the `mood` EN description.

export interface Feature {
  icon: string;
  color: string;
  tint: string;
  tvi: string;
  ten: string;
  dvi: string;
  den: string;
}

export interface Pet {
  dc: string;
  name: string;
  bg: string;
  color: string;
  tvi: string;
  ten: string;
  dvi: string;
  den: string;
}

export interface Step {
  n: string;
  tvi: string;
  ten: string;
  dvi: string;
  den: string;
}

export const features: Feature[] = [
  { icon: "pets", color: "var(--acc-pink)", tint: "color-mix(in oklab,var(--acc-pink) 14%,transparent)", tvi: "Pet chung", ten: "A shared pet", dvi: "Bé pet lớn lên bằng những việc nhỏ: check-in, lời nhắn, thử thách hoàn thành cùng nhau.", den: "Your pet grows on small things: check-ins, notes, and quests you finish together." },
  { icon: "mood", color: "var(--acc-lilac)", tint: "color-mix(in oklab,var(--acc-lilac) 15%,transparent)", tvi: "Tâm trạng thật", ten: "Honest moods", dvi: "Một chạm để nói hôm nay bạn thế nào. Đối phương thấy ngay, không cần hỏi \"sao thế?\".", den: "One tap to say how today feels. They see it instantly — no need to ask what's wrong." },
  { icon: "auto_awesome", color: "var(--acc-butter)", tint: "color-mix(in oklab,var(--acc-butter) 16%,transparent)", tvi: "Hoàng đạo mỗi ngày", ten: "Daily zodiac", dvi: "Chỉ số tương hợp và một gợi ý nhỏ cho hai bạn, đọc trong mười giây.", den: "A compatibility read and one small nudge for the two of you, in ten seconds." },
  { icon: "lock", color: "var(--acc-mint)", tint: "color-mix(in oklab,var(--acc-mint) 14%,transparent)", tvi: "Chỉ hai người", ten: "Just the two", dvi: "Không feed, không người lạ. Việc quan trọng cần cả hai bấm đồng ý.", den: "No feed, no strangers. Anything that matters needs both of you to agree." }
];

// `dvi`/`den` are carried through unchanged even though the Home pet-cast
// teaser renders only `name`/`bg`/`color`/`tvi`/`ten`: they are the same rows
// the Pets page (STORY-002) reads.
export const pets: Pet[] = [
  { dc: "Bo Sprite", name: "Bo", bg: "rgba(255,127,182,.12)", color: "var(--acc-pink)", tvi: "Trung thành", ten: "Loyal", dvi: "Vui là quẫy cả người. Bạn bỏ quên một ngày là Bo ngồi ngóng ở cửa.", den: "Wags with its whole body. Skip a day and Bo waits by the door." },
  { dc: "Bun Sprite", name: "Bun", bg: "rgba(183,140,245,.13)", color: "var(--acc-lilac)", tvi: "Nhút nhát", ten: "Shy", dvi: "Cần dỗ mới ra. Nhưng đã thân thì dính suốt ngày.", den: "Needs coaxing to come out. Once it trusts you, it never leaves." },
  { dc: "Kem Sprite", name: "Kem", bg: "rgba(121,226,205,.12)", color: "var(--acc-mint)", tvi: "Bình tĩnh", ten: "Calm", dvi: "Không bao giờ hoảng. Là bé phù hợp cho cặp hay cãi nhau lúc nửa đêm.", den: "Never panics. The right pet for couples who argue at midnight." },
  { dc: "Mochi Sprite", name: "Mochi", bg: "rgba(255,201,126,.13)", color: "var(--acc-butter)", tvi: "Nghịch ngợm", ten: "Playful", dvi: "Đòi chơi cả ngày. Bỏ mặc là tự nghĩ ra thử thách cho hai bạn.", den: "Wants to play all day. Ignore it and it invents quests for you." },
  { dc: "Sua Sprite", name: "Sua", bg: "rgba(255,171,147,.13)", color: "var(--acc-peach)", tvi: "Nhõng nhẽo", ten: "Clingy", dvi: "Dỗi rất nghệ thuật. Dỗ đúng cách thì thương gấp đôi.", den: "Sulks artistically. Comfort it right and it loves you double." },
  { dc: "Xoai Sprite", name: "Xoài", bg: "rgba(255,127,182,.1)", color: "var(--acc-pink)", tvi: "Lì lợm", ten: "Stubborn", dvi: "Không dễ hài lòng, nhưng lớn nhanh nhất khi hai bạn đều đặn.", den: "Hard to please, but grows fastest when you two stay consistent." }
];

export const steps: Step[] = [
  { n: "01", tvi: "Ghép đôi bằng mã", ten: "Pair with a code", dvi: "Một người tạo mã sáu ký tự, người kia nhập. Không cần tìm kiếm, không cần bạn bè chung.", den: "One creates a six-character code, the other enters it. No search, no mutual friends." },
  { n: "02", tvi: "Chọn một bé pet", ten: "Choose a pet", dvi: "Cả hai bấm chọn cùng lúc. Bé pet là của hai người, không của riêng ai.", den: "You both confirm together. The pet belongs to both of you, never to one." },
  { n: "03", tvi: "Sống cùng nó", ten: "Live with it", dvi: "Check-in tâm trạng, làm thử thách, xem bé lớn lên. Mỗi mốc sinh ra một tấm thẻ kỷ niệm.", den: "Check in, finish quests, watch it grow. Every milestone mints a keepsake card." }
];
