// Content arrays lifted verbatim from `Cupid Web.dc.html` lines 780-792
// (`DCLogic.renderVals()`). Every VI/EN string is character-for-character
// identical to the source, including the inner `"mình cần nói chuyện"` quotes
// and each card's own `color-mix` tint percentage.

export interface Topic {
  vi: string;
  en: string;
}

export interface Post {
  cvi: string;
  cen: string;
  color: string;
  tint: string;
  tvi: string;
  ten: string;
  dvi: string;
  den: string;
  author: string;
  read: number;
  avatar: string;
}

export const topics: Topic[] = [
  { vi: "Yêu xa", en: "Long distance" },
  { vi: "Giải quyết xung đột", en: "Conflict" },
  { vi: "Ngôn ngữ tình yêu", en: "Love languages" },
  { vi: "Hoàng đạo", en: "Zodiac" }
];

export const posts: Post[] = [
  { cvi: "Yêu xa", cen: "Long distance", color: "var(--acc-lilac)", tint: "color-mix(in oklab,var(--acc-lilac) 15%,transparent)", tvi: "Hai múi giờ, một buổi tối", ten: "Two time zones, one evening", dvi: "Bảy cặp đôi yêu xa kể cách họ tạo ra một giờ chung mỗi ngày, dù lệch nhau nửa vòng trái đất.", den: "Seven long-distance couples on carving out one shared hour a day, half a world apart.", author: "Minh Khôi", read: 6, avatar: "linear-gradient(140deg,#B78CF5,#79E2CD)" },
  { cvi: "Thói quen", cen: "Habits", color: "var(--acc-mint)", tint: "color-mix(in oklab,var(--acc-mint) 14%,transparent)", tvi: "Vì sao việc nhỏ giữ được người ta lâu hơn việc lớn", ten: "Why small things outlast grand gestures", dvi: "Một chuyến du lịch không bù được ba mươi ngày không hỏi nhau hôm nay thế nào.", den: "A holiday can't repay thirty days of not asking how today went.", author: "Linh Đàm", read: 5, avatar: "linear-gradient(140deg,#FF7FB6,#FFC97E)" },
  { cvi: "Xung đột", cen: "Conflict", color: "var(--acc-pink)", tint: "color-mix(in oklab,var(--acc-pink) 14%,transparent)", tvi: "Câu hỏi nên hỏi trước khi nói \"mình cần nói chuyện\"", ten: "Ask this before saying \"we need to talk\"", dvi: "Một câu đơn giản làm hạ nhiệt gần như mọi cuộc tranh luận lúc nửa đêm.", den: "One simple line that cools almost every midnight argument.", author: "Thu Hà", read: 4, avatar: "linear-gradient(140deg,#79E2CD,#B78CF5)" },
  { cvi: "Hoàng đạo", cen: "Zodiac", color: "var(--acc-butter)", tint: "color-mix(in oklab,var(--acc-butter) 16%,transparent)", tvi: "Đọc hoàng đạo kiểu không mê tín", ten: "Reading zodiac without the superstition", dvi: "Xem nó như một cái cớ để hỏi nhau, không phải một bản án về tính cách.", den: "Treat it as an excuse to ask questions, not a verdict on character.", author: "Bảo An", read: 7, avatar: "linear-gradient(140deg,#FFC97E,#FF7FB6)" },
  { cvi: "Ngôn ngữ tình yêu", cen: "Love languages", color: "var(--acc-peach)", tint: "color-mix(in oklab,var(--acc-peach) 15%,transparent)", tvi: "Khi hai người thương nhau bằng hai thứ tiếng", ten: "When two people love in different languages", dvi: "Bạn tặng quà, người kia chỉ cần bạn ngồi yên đó. Không ai sai cả.", den: "You give gifts; they just want you sitting there. Neither of you is wrong.", author: "Minh Khôi", read: 6, avatar: "linear-gradient(140deg,#FFAB93,#B78CF5)" },
  { cvi: "Hậu trường", cen: "Behind Cupid", color: "var(--acc-lilac)", tint: "color-mix(in oklab,var(--acc-lilac) 15%,transparent)", tvi: "Chúng mình bỏ tính năng xếp hạng cặp đôi", ten: "We deleted couple leaderboards", dvi: "Nó làm hai người thi nhau thay vì hiểu nhau. Đây là lý do nó bị xoá.", den: "It made partners compete instead of connect. Here's why it's gone.", author: "Đội Cupid", read: 3, avatar: "linear-gradient(140deg,#FF7FB6,#B78CF5)" }
];
