// Content arrays for the Invite page. `codeCells` and `keepsakeCards` are
// lifted verbatim from `Cupid Web.dc.html` lines 778 and 794-798
// (`DCLogic.renderVals()`); `inviteSteps` is lifted from the inline markup at
// lines 419-433. Every VI/EN string is character-for-character identical to the
// source, including the em dashes in the `favorite` step and the `Milestone`
// and `Zodiac` card sub-copy.
//
// `inviteSteps` is deliberately separate from `home-content.ts`'s `steps`: the
// two sections share a card anatomy but not a copy set (uiux-spec §6.2.5).

export interface InviteStep {
  icon: string;
  color: string;
  tvi: string;
  ten: string;
  dvi: string;
  den: string;
}

export interface KeepsakeCard {
  tag: string;
  color: string;
  bg: string;
  big: string;
  svi: string;
  sen: string;
}

export const codeCells: string[] = ["C", "U", "P", "1", "D", "7"];

export const inviteSteps: InviteStep[] = [
  { icon: "qr_code_2", color: "var(--acc-pink)", tvi: "Nhận mã", ten: "Get a code", dvi: "Người kia tạo mã sáu ký tự trong app và gửi cho bạn.", den: "They create a six-character code in the app and send it over." },
  { icon: "favorite", color: "var(--acc-lilac)", tvi: "Xác nhận cả hai", ten: "Both confirm", dvi: "Hai người cùng bấm đồng ý — không ai bị ghép một mình.", den: "You both tap yes — nobody gets paired alone." },
  { icon: "pets", color: "var(--acc-mint)", tvi: "Chọn bé pet", ten: "Pick a pet", dvi: "Bé pet đầu tiên nở sau ba ngày cả hai đều check-in.", den: "Your first pet hatches after three days of you both checking in." }
];

// `tag` is a literal brand label in both languages, per the source data.
export const keepsakeCards: KeepsakeCard[] = [
  { tag: "Milestone", color: "var(--acc-pink)", bg: "linear-gradient(150deg,rgba(255,127,182,.24),rgba(183,140,245,.16)),var(--screen)", big: "214", svi: "ngày cùng nhau, Bo đã thành linh thú", sen: "days together — Bo became a spirit" },
  { tag: "Streak", color: "var(--acc-mint)", bg: "linear-gradient(150deg,rgba(121,226,205,.2),rgba(23,17,41,.4)),var(--screen)", big: "30/30", svi: "check-in tâm trạng, không bỏ ngày nào", sen: "mood check-ins, no day missed" },
  { tag: "Zodiac", color: "var(--acc-butter)", bg: "linear-gradient(150deg,rgba(255,201,126,.2),rgba(183,140,245,.14)),var(--screen)", big: "92%", svi: "tương hợp hôm nay — Cự Giải × Kim Ngưu", sen: "compatible today — Cancer × Taurus" }
];
