// Content arrays lifted verbatim from `Cupid Web.dc.html` lines 511-611 and the
// `principles`/`palette` data at `:800-812`. Every VI/EN string is
// character-for-character identical to the source.
//
// Two localization-format facts are deliberate and must not be normalized into
// each other (uiux-spec §6.2.3 / §6.2.5): `Stat.value` is a single unlocalized
// literal, while the `48.000` / `48,000` separator inside `Timeline` entry 4 is
// translated prose and legitimately differs by language.

export interface Principle {
  tvi: string;
  ten: string;
  dvi: string;
  den: string;
}

export interface Stat {
  value: string;
  lvi: string;
  len: string;
}

export interface TimelineEntry {
  year: string;
  tvi: string;
  ten: string;
  dvi: string;
  den: string;
}

export interface TeamMember {
  name: string;
  gradient: string;
  rvi: string;
  ren: string;
}

export interface PaletteSwatch {
  hex: string;
  name: string;
}

export const principles: Principle[] = [
  { tvi: "Couple-first", ten: "Couple-first", dvi: "Mọi màn hình đều có dấu vết của người kia. Không có chế độ một mình.", den: "Every screen carries a trace of the other person. There is no solo mode." },
  { tvi: "Dual-confirmation", ten: "Dual-confirmation", dvi: "Đổi pet, xoá ảnh, rời đi — đều cần cả hai bấm đồng ý.", den: "Changing the pet, deleting a memory, leaving — all need both taps." },
  { tvi: "Dỗi cho đáng yêu", ten: "Sulk, sweetly", dvi: "Cảm xúc xấu vẫn được nói ra, chỉ là bằng ngôn ngữ dễ thương hơn.", den: "Hard feelings still get said — just in a softer language." },
  { tvi: "Không quảng cáo", ten: "No ads", dvi: "Không bán dữ liệu, không feed. Kiếm tiền bằng phụ kiện cho pet.", den: "No data selling, no feed. We earn from pet accessories." }
];

export const stats: Stat[] = [
  { value: "48.000+", lvi: "cặp đôi đang dùng", len: "couples on Cupid" },
  { value: "31.500", lvi: "bé pet đã nở", len: "pets hatched" },
  { value: "2,1 triệu", lvi: "thẻ kỷ niệm đã tạo", len: "keepsake cards minted" }
];

export const timeline: TimelineEntry[] = [
  { year: "2024", tvi: "Một cái bảng trắng", ten: "A whiteboard", dvi: "Hai người trong nhóm đang yêu xa, và không app nào giúp được họ.", den: "Two of us were long-distance, and no app was helping." },
  { year: "2025", tvi: "Bản thử đầu tiên", ten: "First build", dvi: "Ba trăm cặp đôi thử. Bé pet đầu tiên tên Bo, và nó chết vì không ai cho ăn.", den: "Three hundred couples tried it. The first pet was Bo, and it died unfed." },
  { year: "2025", tvi: "Dual-confirmation", ten: "Dual-confirmation", dvi: "Chúng mình bỏ mọi hành động một người có thể làm thay hai người.", den: "We removed every action one person could take on behalf of two." },
  { year: "2026", tvi: "Ra mắt Việt Nam", ten: "Vietnam launch", dvi: "48.000 cặp đôi trong bốn tháng, gần như hoàn toàn nhờ thẻ kỷ niệm được chia sẻ.", den: "48,000 couples in four months, almost entirely through shared keepsake cards." },
  { year: "2026", tvi: "Sắp tới", ten: "Next", dvi: "Album chung có in ảnh thật, và một chế độ dành cho những cặp mới quen.", den: "A printable shared album, and a mode for couples who just met." }
];

export const team: TeamMember[] = [
  { name: "Minh Khôi", gradient: "linear-gradient(140deg,#FF7FB6,#B78CF5)", rvi: "Sản phẩm", ren: "Product" },
  { name: "Linh Đàm", gradient: "linear-gradient(140deg,#B78CF5,#79E2CD)", rvi: "Thiết kế", ren: "Design" },
  { name: "Thu Hà", gradient: "linear-gradient(140deg,#FFC97E,#FF7FB6)", rvi: "Kỹ thuật", ren: "Engineering" }
];

export const palette: PaletteSwatch[] = [
  { hex: "#FF7FB6", name: "Pink" },
  { hex: "#B78CF5", name: "Lilac" },
  { hex: "#79E2CD", name: "Mint" },
  { hex: "#FFC97E", name: "Butter" },
  { hex: "#FFAB93", name: "Peach" },
  { hex: "#171129", name: "Nebula" },
  { hex: "#241B42", name: "Surface" },
  { hex: "#FFF6FB", name: "Cotton" }
];
