# Brainstormer Checkpoint

Scope:

- Idea ID: IDEA-20260828-002_couple-feature-expansion
- Workflow: develop-idea
- Lifecycle: ACTIVE
- Development Status: EXPANDED

Current State:

- Last Session: 2026-08-29 (cycle 13)
- Latest Focus: **trục B — "mỗi bên chú ý gì ở đối phương"** (user đẩy lại D12-3 bằng
  hai ví dụ: "đèn đỏ" và "có tâm lý không").
- Facilitation Stance: `Ideate For Me`
- Approximate Raw Idea Count: ~265 qua 19 kỹ thuật, 18 domain shift, 19 cụm
- Convergence State: **XONG HOÀN TOÀN.** Affinity Clustering (c4 → c5, 19 cụm),
  Impact/Effort (c9), và thứ tự thi công theo lối B (c10, Phần J).
- Research State: **XONG.** WebSearch x6 + WebFetch x1 ở c6, x6 ở c11, x6 ở c12, x2 ở c13.
  Không lỗi công cụ lần nào.
  - Khoảng trống trung thực c12: **không có dữ liệu VN đương đại về ai trả tiền / ai
    chủ động** trong hẹn hò; và **không có bằng chứng ngoài cho D12-7** (60 giây đầu của
    người thứ hai) — D12-7 là suy luận từ phễu của ta, được ghi là suy luận.

Files Updated:

- idea.md
- development.md
- candidate-review.md (**Phần L mới ở c13** — trục B, GA1-GA4, L17; **Phần K ở c12** — chặng 1 solo; A-16/A-17 chờ user; L14/L15/L16)
- handoff-to-scrum-master.md (**tái sinh ở c12**: +4 story REQ-A, +3 story REQ-B, +3 ràng buộc)
- design-brief.md (**tái sinh ở c12**: mới 4.0, 4.5, 5.0; sửa 4.2, 4.3, 7.4, 8, 10, 12.
  Cho designer người thật — không phải agent ui-ux-designer)
- master_ideas_list.md (không đổi)

Next Valid Step:

- Action: **message handoff đã cập nhật** tại `handoff-to-scrum-master.md` (vẫn 2
  requirement: REQ-A chặng 1 + nền, REQ-B bản lề + chặng 2). User paste vào Helen-SC khi muốn.
- ⏳ **Hai quyết định chờ user, không chặn handoff nhưng chặn phần customize của đợt 1:**
  - **A-16 / OQ-12A:** customize rẽ theo **VAI** (đề xuất) hay theo **GIỚI** (user hỏi
    ban đầu)? Nếu theo vai: tự khai một câu hay suy từ hành vi?
  - **A-17:** chốt **L14** (đẩy ra ngoài, không chỉ hút vào) thành luật hay không?
  - **A-18 / OQ-13B:** có mở lại "đồng bộ chu kỳ và sức khoẻ" (đã loại ở §9) cho chặng 2
    không? **GA1 KHÔNG phải là mở lại nó.** Mở lại = đảo quyết định đã chốt + NĐ 356/2025
    + vector R8.
  - **OQ-13A:** cho cô ấy đọc lại chính chữ mình đã viết về anh ấy — tự soi hay app dựng
    hồ sơ buộc tội? **Chưa giải được.**
  - **OQ-12B:** CS2 (mời vào hoạt động) có làm loãng khoảnh khắc G-b không — chưa giải được.
- **không còn việc brainstorm nào.** Hội tụ xong, thứ tự xong, nghiên cứu
  xong, mọi luật đã chốt. Idea sẵn sàng handoff sang `scrum-master` — chỉ khi user
  nói rõ. Việc còn lại đều thuộc tech-lead.
- Output Paths:
  - `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/idea.md`
  - `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/development.md`
  - `data/brainstorms/IDEA-20260828-002_couple-feature-expansion/candidate-review.md`

Do Not Re-read:

- broad prior chat narrative
- source files đã quét ở c1-c5 (couple-theme.entity.ts, themes.service.ts,
  emojis.catalog.ts, pets.service.ts, mobile/lib/features/vow/, backend module list)
  — kết luận đã chưng cất vào `idea.md` và `candidate-review.md`

Large File Query Keys:

- development.md (~182 KB, PHẢI grep trước rồi ranged read):
  `## BMAD Session State` · `## Idea Inventory` · `## Current Snapshot` ·
  `## Convergence Notes` · `## Research Notes` · `## Session Log`
- candidate-review.md (~51 KB): `## Phần A` .. `## Phần L`. Mới nhất là **`## Phần L`**.
- design-brief.md (~39 KB): `## 4.0` · `### 4.5` · `**⭐ 5.0` · `**7.4` · `**L14` · `## 10`

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
