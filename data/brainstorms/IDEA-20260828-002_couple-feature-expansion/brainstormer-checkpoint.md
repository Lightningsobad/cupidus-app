# Brainstormer Checkpoint

Scope:

- Idea ID: IDEA-20260828-002_couple-feature-expansion
- Workflow: develop-idea
- Lifecycle: ACTIVE
- Development Status: EXPANDED

Current State:

- Last Session: 2026-09-03 (cycle 19)
- Latest Focus: **`design-brief.md` lên bản 4** — thêm **§0 "nguồn duy nhất"** để chặn
  tái lệch (bản 3 lệch vì **chép lại** thứ tệp khác sở hữu). **Mọi artifact nay đồng bộ,
  không còn tệp lỗi thời.** Vòng 18: ✅ **CHỐT `A-16=1 A-17=1 A-18=1 A-21=1`** → sinh **L14 (phủ định)** +
  **L19 (vai theo cấu trúc)** → **tái sinh `handoff-to-scrum-master.md`**.
  **Không còn quyết định nào treo. Idea sẵn sàng handoff.**
  Vòng 17: **đóng gói A-16/A-17/A-18/A-21 thành phương án** (`open-decisions.md`),
  kèm hai lần tự đính chính do đo mã: **D17-1** (`gender` không tồn tại ⇒ lập luận giá
  cả của A-16 ở c12 sai) và **D17-5** (lập luận cấu trúc của c13 về A-18 chỉ đúng cho
  chặng 1). Vòng 16: **A-19 CHỐT lối 3** → truy cơ chế → rút ra **L18** → **hồi sinh C8**.
  Vòng 15 (dưới): **bản đồ màn hình + user journey + 4 lối A-19.** User yêu cầu trực tiếp
  màn hình theo từng tính năng. Kết quả: `screen-map.md`. Vòng 14 (dưới đây) là nền:
  **móc nối — idea gặp mã nguồn.** User chặn handoff: chưa nối vào tính
  năng hiện có, chưa có bề mặt, chưa có user journey. Vòng đầu tiên chạy trên **mã
  nguồn thật** thay vì trên ý tưởng. Kết quả: `wiring-map.md`.
- Facilitation Stance: `Ideate For Me`
- Approximate Raw Idea Count: ~290 qua 24 kỹ thuật (T20-T23 ở c14, T24 Screen Mapping ở
  c15), 18 domain shift, 19 cụm
- Convergence State: **XONG HOÀN TOÀN.** Affinity Clustering (c4 → c5, 19 cụm),
  Impact/Effort (c9), và thứ tự thi công theo lối B (c10, Phần J).
- Research State: **XONG.** WebSearch x6 + WebFetch x1 ở c6, x6 ở c11, x6 ở c12, x2 ở c13.
  **c14 không dùng web** — là vòng chứng cứ nội bộ (đọc mã nguồn). Không lỗi công cụ lần nào.
  - Khoảng trống trung thực c12: **không có dữ liệu VN đương đại về ai trả tiền / ai
    chủ động** trong hẹn hò; và **không có bằng chứng ngoài cho D12-7** (60 giây đầu của
    người thứ hai) — D12-7 là suy luận từ phễu của ta, được ghi là suy luận.

Files Updated:

- **open-decisions.md (MỚI ở c17)** — 4 quyết định còn mở, 17 phương án, khuyến nghị
  `A-16=1 A-17=1 A-18=1 A-21=1`. **Đọc tệp này trước nếu user quay lại để chốt.**
- **screen-map.md (MỚI ở c15)** — 21 màn hình có mã S-01..S-21, 6 mô tả màn hình mới,
  5 journey, 4 lối A-19. **Đây là tệp đọc trước nếu câu hỏi là "màn hình nào / đi thế nào".**
- **wiring-map.md (MỚI ở c14)** — bản đồ móc nối, quét thanh lý 41 module, 5 user journey
- idea.md
- development.md
- candidate-review.md (**Phần L mới ở c13** — trục B, GA1-GA4, L17; **Phần K ở c12** — chặng 1 solo; A-16/A-17 chờ user; L14/L15/L16)
- handoff-to-scrum-master.md (**tái sinh ở c12**: +4 story REQ-A, +3 story REQ-B, +3 ràng buộc)
- design-brief.md (**tái sinh ở c12**: mới 4.0, 4.5, 5.0; sửa 4.2, 4.3, 7.4, 8, 10, 12.
  Cho designer người thật — không phải agent ui-ux-designer)
- master_ideas_list.md (không đổi)

Next Valid Step:

- ✅ **`handoff-to-scrum-master.md` ĐÃ TÁI SINH ở c18** theo c14-c18. **Paste được ngay.**
  Việc còn lại duy nhất: user paste vào Helen-SC khi muốn bắt đầu delivery.
  Brainstormer **không** tạo `data/requirements/` — đó là việc của `scrum-master`.
- ✅ **Toàn bộ quyết định đã đóng.** A-16=1 (vai đọc từ phễu ⇒ **L19**) · A-17=1
  (**L14 phủ định**: cấm cơ chế tăng thời-gian-trong-app vì chính nó) · A-18=1 (không mở
  lại chu kỳ; **lý do đúng = GA1 đủ + NĐ 356/2025 + R8**, KHÔNG phải "bất khả thi cấu
  trúc") · A-19=3 (zodiac đổi vai ⇒ **L18**, và **C8 hồi sinh**) · A-20 (bản đồ màn hình)
  · A-21=1 (pet: nhịp, không điểm).
- **Hai câu duy nhất còn mở, brainstorm CHƯA GIẢI ĐƯỢC, không chặn delivery:**
  **OQ-12B** (CS2 mời-vào-hoạt-động có làm loãng khoảnh khắc mời S-07 không) ·
  **OQ-13A** (cho người dùng đọc lại ghi chép của chính mình về người kia — tự soi hay
  app dựng hồ sơ buộc tội). Đã ghi vào handoff **đúng như chưa giải được**.
- **Nếu user quay lại để brainstorm tiếp:** không còn việc hội tụ nào. Vùng chưa đào:
  OQ-12B/OQ-13A, và quét L18 trên các module chưa soi (`themes`/`emojis`/`vibes`).

Do Not Re-read:

- broad prior chat narrative
- source files đã quét ở c1-c5 (couple-theme.entity.ts, themes.service.ts,
  emojis.catalog.ts, pets.service.ts, mobile/lib/features/vow/, backend module list)
  — kết luận đã chưng cất vào `idea.md` và `candidate-review.md`

Large File Query Keys:

- screen-map.md (~15 KB, đọc được cả tệp): `## Phần 1` ngân sách tab · `## Phần 2` bảng
  tổng S-01..S-21 · `## Phần 3` 6 màn hình mới · `## Phần 4` 5 journey · `## Phần 5` A-19
- wiring-map.md (~12 KB, đọc được cả tệp): `## Phần 1` hiện trạng bề mặt · `## Phần 2`
  D14-1..D14-10 · `## Phần 3` quét thanh lý module · `## Phần 4` 5 journey · `## Phần 5` A-19

- development.md (~182 KB, PHẢI grep trước rồi ranged read):
  `## BMAD Session State` · `## Idea Inventory` · `## Current Snapshot` ·
  `## Convergence Notes` · `## Research Notes` · `## Session Log`
- candidate-review.md (~51 KB): `## Phần A` .. `## Phần L`. Mới nhất là **`## Phần L`**.
- design-brief.md (~43 KB, **bản 4**): `## 0. Nguồn duy nhất` ← đọc trước · `### 4.0b` ·
  `## 8. Luật` (L14 viết lại, +L18/L19) · `## 9. Đã loại` (+zodiac, +pet) · `## 10` (4/9
  câu đã trả lời) · `## 12`. **Không còn giữ danh sách màn hình** — thuộc `screen-map.md`.

Open Threads:

- **[ĐÃ GIẢI c10] D9-3 thứ tự.** User chọn **lối B**: chặng 1 xếp trước, cùng một
  phase với chặng 2. Sao của lối C bị rút vì tiền đề sai (chặng 2 chưa có người dùng).
  Thứ tự 5 đợt ở `candidate-review.md` Phần J.
- **[KIỂM THỬ CHẶN ĐỢT 2] L1:** cuối đợt 1 phải trả lời được — chặng 1 có dùng trọn
  vẹn được kể cả nếu người kia không bao giờ tham gia? Không đạt thì dừng, đừng sang
  đợt 2. Đây là cách giảm thiểu duy nhất cho rủi ro D10-6 (không kiểm chứng gì trước
  khi trả M2).
- **[GIÁ CỦA B] D10-3:** GI3, KY2, GI7 và một phần C1 phải dựng hai lần (bản một
  người rồi bản cặp đôi). Nhẹ đi nếu M2 làm đúng ngay từ đợt 0.
- **[TECH-LEAD] G-3 / M2:** mô hình dữ liệu 1 chủ → 2 chủ. Không giải trong brainstorm.
- **[ĐÃ CHỐT c11] BD1 xưng hô anh/em** — vào đợt 0.
- **[ĐÃ CHẠY c11] Phần H — vòng đào AI.** Kết quả H-R1..H-R7, D11-1..D11-9.
  - ⭐⭐⭐ R-1 có bằng chứng thực nghiệm (*Science*, nịnh hót 73%, làm người ta ít xin lỗi).
  - ⚠️ G-1 là chỗ bốn rủi ro chồng lên nhau (chi phí 100-1000x · xuyên biên giới ·
    pháp lý đọc tin nhắn · bề mặt nịnh lớn nhất).
  - ⭐ **Luật AI-1 mới, cần tech-lead cưỡng chế:** AI đọc chat chỉ trích xuất hoạt
    động, không mô tả con người; ràng bằng schema đầu ra ở tầng API.
  - Đợt 1 không có AI. AI vào đợt 3-4, chỉ trên hoạt động. Chat thì on-device hoặc
    bỏ tính năng.
- **[ĐÃ CHẠY c12] Chặng 1 solo đào sâu.** R12-1..R12-5, D12-1..D12-7, CS1..CS12, L14-L16.
  - ⚠️ **D12-1:** chặng 1 pass L1 ở **ngày 30**, không pass ở **ngày 1**. 5/8 ô là hộp
    rỗng. Vá bằng CS7 (giao kèm nội dung VN) + CS8 (đẩy BD2 lên trước).
  - ⭐⭐⭐ **D12-2:** gánh nặng **đổi vai** đúng lúc app đổi chế độ — chặng 1 gánh *khởi
    xướng* (nghiêng nam), chặng 2 gánh *duy trì/mental load/kin-keeping* (nghiêng nữ).
    Failure mode: chặng 2 cũng phục vụ người khởi xướng ⇒ mankeeping số hoá. Vá bằng CS11.
  - ⭐ **D12-3:** đề xuất rẽ theo **VAI** không theo **GIỚI**. Pew 2024 (n=6,204) bác tiền
    đề "nam ít bạn hơn"; 50-75% phụ nữ đã từng chủ động. **Chờ user (A-16).**
  - ⭐ **D12-7:** lỗ to nhất — **không có tính năng nào phục vụ người thứ hai trong 60
    giây đầu**. Đường nối giữa hai chặng không ai sở hữu. Vá bằng CS5+CS6.
  - **Tự đính chính c11:** L4 nới từ "giấu AI" thành "không lấy AI làm đầu bài" (68% Gen Z
    VN tin AI gợi ý được chủ đề). R-1 và AI-1 **không** đổi.
- **[ĐÃ CHẠY c13] Trục B — chú ý gì ở đối phương.** R13-1/R13-2, D13-1..D13-7, GA1-GA4.
  - **Tôi sai ở c12 (D13-1):** hai trục, không một. Trục B bị bỏ trống hoàn toàn.
  - **Vẫn chặn hai ví dụ (D13-2..D13-4):** "đèn đỏ" chặng 1 bất khả thi về **cấu trúc**
    (chủ thể dữ liệu không có tài khoản ⇒ không có đường xin đồng ý), + R13-1 NĐ 356/2025,
    + R13-2 vector R8, + đã loại ở §9. "Tâm lý" = R-1 + XD2 + L13 + H-R1.
  - ⭐⭐ **D13-5:** R-1 có **tác dụng phụ theo giới** — JTBD người được rủ hình dạng *con
    người*, R-1 cấm theo định nghĩa ⇒ chặng 1 thành sản phẩm cho nam do **hình học**.
  - ⭐ **D13-6:** nguồn thứ ba — **người kia tự khai** — sạch R-1, chưa từng dùng.
  - ⭐ **D13-7:** cấu trúc giá trị hai chiều — cô ấy hưởng lợi từ tính năng **anh ấy** dùng.
  - **L17 mới** (thông tin về người kia chỉ đến từ chính người đó / tay người dùng ghi;
    app không bao giờ là nguồn) · **L15 nới** (giới đổi chữ + nội dung, không đổi cơ chế).
- **[KHOẢNG TRỐNG TRUNG THỰC]** phân loại pháp lý chính xác của "ghi chú tự gõ về chu kỳ
  người khác" là câu hỏi tech-lead/pháp lý, tôi không kết luận — lập luận chặn nằm ở
  **cấu trúc đồng ý**, không ở phân loại. Cũng không tìm được số sẵn sàng chi trả của sinh viên VN;
  dữ liệu phản ứng ngược với AI là US/UK/CA, không ngoại suy thẳng sang VN.
- **[MỞ]** Q-g / BE5 ghi chú về bạn bè người kia — user nói "chưa rõ ràng", không chặn.
- **[CẢNH BÁO]** RS-D4: cụm C14 không được biến thành một kênh chat nữa.
- **[TRUNG THỰC]** D8-18: khu riêng vô hình cũng có thể che giấu hành vi xấu.
- **[LIÊN KẾT]** TR4 bắc cầu sang IDEA-20260828-001 (đảo phần lớn rủi ro H5 ở đó).
  IDEA-001 vẫn ACTIVE/IN_PROGRESS, đang đỗ, chặn ở nghịch lý G1 (chọn G2-G6).
- **[c14] Bốn kết luận cấu trúc mới, dùng lại được ở mọi vòng sau:**
  - **D14-1** chặng 1 không có cửa (`OnboardingChain` một cạnh duy nhất ra khỏi
    `profileSetup`; `AppShell` chỉ mount sau `paired`) ⇒ M2 gồm **cả** tầng điều hướng.
  - **D14-4** nửa điều hướng của M2 **rẻ** — `ChatEntryGate` đã là mẫu tab-theo-chế-độ
    đang chạy; tổng quát hoá `ModeGate`. Nửa dữ liệu vẫn chưa ai chạm (G-3).
  - **D14-2/D14-5/D14-7** ba móc nối "không cần xây mới": tab Ví chung → C1 · dời
    `loveContract`/`vow` xuống nghi thức đổi chế độ · đổ nội dung vào
    `waiting`/`joinCode`/`paired`.
  - **Cả 5 journey chỉ cần 3 bề mặt mới:** chọn chế độ · Nhà hình thái một người · tab C1.
- **[c14, PHƯƠNG PHÁP]** 17 luật của idea chưa từng được đối chiếu với tập tính năng
  **đang chạy**. A-19 là ca đầu tiên lộ ra; có thể còn ca khác (xem `pets` — §6.12 cấm
  phản ánh điểm số, cùng họ với D14-8).
- **[c15] Chi phí bề mặt lần đầu được định lượng:** 39 màn hình hiện có → **6 MỚI ·
  9 SỬA · 1 DỜI · 3 NỐI · 2 CHỜ · 18 GIỮ · 0 XOÁ · 0 tab tăng thêm.** Chặng 1 dùng 3
  tab, chặng 2 dùng 5. Đây là con số phải mang theo vào handoff.
- **[c15] Hai bề mặt ưu tiên cao nhất, cả hai đều là SỬA chứ không MỚI:**
  **S-07** (`WaitingScreen` → khoảnh khắc mời G-b — hiện là spinner) và **S-08**
  (`JoinCodeScreen` → hành động trước tài khoản sau — hiện làm ngược).
- **[c15, ĐÍNH CHÍNH c14]** `vow` có route + cờ `profile.vowTaken`; `love_contracts` có
  lối vào từ `MeScreen`. Chôn thật chỉ còn `ExpenseHistoryScreen`, `GalleryScreen`.
- **[c16] L18 là phép thử dùng lại được cho mọi ca sau.** A-19 và A-21 là hai ca đầu
  tiên. Ca tiếp theo có thể là bất kỳ tính năng nào xuất ra một con số về hai người —
  quét `score|index|percent|compatibility|level|streak` trên payload là cách tìm.
- **[c17] Hai chỗ trí nhớ từng sai, đã sửa bằng đo:** `gender` **không tồn tại** trong
  repo (D17-1) · `coupleType` **đã dùng thật** (`SAME_CITY`, hiện trên Home), không rảnh
  để chở chế độ (D17-3). Đừng lặp lại hai giả định này.
- **[c17] Vai xác định bởi phễu, không bởi câu hỏi** (D17-2): `invitations.service.ts` đã
  có `inviter`; J3 = khởi xướng, J4 = được rủ.
- **[c18] Ba luật mới cùng một HÌNH DẠNG — đây là lý do chúng sống được:** **L18** cấm
  *trường điểm số* · **L14** cấm *cơ chế tăng thời gian trong app vì chính nó* · **L19**
  cấm *hỏi/suy đoán về vai*. Cả ba là **phép cấm quét được bằng máy**, cùng nước đi với
  AI-1. Phép kiểm nhanh cho reviewer: quét payload tìm
  `score|index|percent|compatibility|level|streak`.
- **[c18] Backlog đổi: -2 story, +2 story.** Xoá CS9 (thành L14) và CS10-hỏi-user (thành
  L19). Thêm **S-20 zodiac đổi vai** (REQ-A, *là* C8 hồi sinh) và **S-21 pet đổi vai**
  (REQ-B). Hai story mới đều là **sửa nợ luật đang chạy trong production** — loại việc
  không vòng nào trước c14 có thể phát hiện, vì trước c14 chưa vòng nào đọc mã nguồn.
- **[c19] Quy tắc chống lệch artifact, áp cho mọi vòng sau:** mỗi loại thông tin có
  **đúng một tệp sở hữu** — màn hình/journey → `screen-map.md` · móc nối module →
  `wiring-map.md` · luật → `candidate-review.md` Phần B · quyết định + lý do → Phần A ·
  phương án đã loại → `open-decisions.md` · định vị/hai chế độ/mẫu dùng lại →
  `design-brief.md`. **Đừng chép lại; hãy trỏ.** Bảng này nằm ở `design-brief.md` §0.
- **[c19] Lần thứ ba đọc nguồn gốc sửa được sai lệch do trí nhớ** (sau D17-1 `gender`,
  D17-5 lập luận cấu trúc): **D19-2** — `design-brief.md` §4.0b vốn đã **đúng**, bản tóm
  tắt c13 của tôi mới là chỗ trượt.
