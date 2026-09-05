# Idea Master: IDEA-20260831-001 Couple Milestone Achievements
Lifecycle: ACTIVE
Development Status: EXPANDED
Source: user
Created: 2026-08-31
Last Updated: 2026-09-04
Linked Requirement: N/A

## Seed

Original idea:

Brainstorm về các **"Dấu mốc"** của các cặp đôi — đúng hơn là một **hệ thống
Achievement cho cặp đôi để họ đi khoe**.

Hiện trạng quan sát được trong repo (business-level):

- **Chưa có module achievement/milestone/badge nào** ở backend lẫn mobile.
- `timeline` đã có `TimelineEvent` (coupleId, type, title, description, photoUrl,
  icon, createdAt) — nguyên thuỷ gần nhất với "dấu mốc", nhưng là nhật ký thủ
  công, không có khái niệm đạt được / hiếm / khoe được.
- Nhiều nguồn bằng chứng đã sẵn có để đúc dấu mốc: `gallery`, `expenses`,
  `pets` (level/happiness/totalInteractions), `love-contracts`, `dream-jar`,
  `vibes`, `zodiac`, `messages`, `themes`, `emojis`, `data-export`.
- Liên quan chéo: IDEA-20260828-001 (hearts = gương phản chiếu, không phải tiền
  game) và IDEA-20260829-001 (mở rộng chế độ 1 người ở chặng tán tỉnh).

## Current Business Framing

- **[CHỐT c2] Q1 — Khoe công khai ra internet.** Kích hoạt nhánh trang công khai
  của cặp, và kéo theo nghĩa vụ đồng thuận hai chiều + thu hồi URL.
- **[CHỐT c2] Q2 — Không so sánh chéo cặp.** Nguyên văn user: *"các con số không
  cần chính xác mà chỉ 'nâng cao sự tự hào, hãnh diện', thúc đẩy mối quan hệ tốt
  lên."* → **Hệ này là dụng cụ KỂ CHUYỆN, không phải dụng cụ ĐO LƯỜNG.**
- **[CHỐT c2] Q3 — CÓ làm nhóm "sẹo"** (mốc vượt qua chuyện khó).
- Problem: App hiện lưu được *dữ liệu* quan hệ nhưng không biến nó thành **niềm
  tự hào có hình hài**. Cặp đôi không có gì để cầm ra ngoài khoe, nên (a) không
  có lý do quay lại đều, (b) app không có kênh lan truyền tự nhiên nào.
- Target actor: Cặp mới yêu + **người ngoài xem bài khoe công khai** (kênh tăng
  trưởng) + người còn một mình ở chặng 1.
- Value hypothesis: Dấu mốc biến lịch sử quan hệ thành **hiện vật khoe được** mà
  đối thủ không dựng lại được, vì nó cần *thời gian thật + người thật làm chứng*.
- Căng thẳng trung tâm (**đã có lời giải ở c2**): "đi khoe" hướng ra ngoài, quan
  hệ hướng vào trong. Giải bằng L9 — **sẹo tạo chiều sâu bên trong, chỉ bóng tổng
  hợp của nó mới ra ngoài** ("đã cùng nhau đi qua 8 tháng yêu xa" khoe được;
  "3/4: lần đầu cãi nhau" thì không bao giờ).
- Why this might matter now: Đây là lớp duy nhất **thu hoạch chéo** được toàn bộ
  feature rời rạc đang có mà không phải xây feature mới, và là **faucet tự nhiên
  cho hearts**.
- Luật thiết kế (1-5 đề xuất từ c1, 6-9 từ c2, chờ user chốt thành luật cứng):
  1. **Không farm được**: mốc mua bằng thời gian và sự thật, không bằng số thao tác.
  2. **Không bao giờ so cá nhân** trong cặp.
  3. **Không phạt khi im lặng** (yêu xa, cãi nhau, quan hệ nguội không mất gì).
  4. **Không cần đối phương hợp tác** để một người mở khoá mốc thường.
  5. **Hearts không mua được badge; badge đúc ra hearts.**
  6. **Luật hai loại số**: được phép mơ hồ ở *phán xét* (lãng mạn, gắn bó); không
     được phép sai ở *sự kiện* (ngày tháng, có/không xảy ra). Cấm vĩnh viễn loại
     thứ ba — con số suy đoán giả vờ chính xác ("hợp nhau 92%").
  7. **App chỉ suy ra để HỎI, không bao giờ để KẾT LUẬN.**
  8. **Suy luận về chuyện xấu chỉ hỏi RIÊNG từng người**, không hỏi trong không
     gian chung.
  9. **Sẹo chỉ khoe được ở dạng đã vượt qua và đã tổng hợp**, không bao giờ ở dạng
     sự kiện đơn lẻ có ngày.
- Mô hình nguồn gốc dữ liệu 5 tầng (T1 sự kiện cứng · T2 tự khai · T3 gợi ý rồi
  xác nhận · T4 người làm chứng · T5 cảm tính chính chủ): xem
  `development.md` `## Current Snapshot`.
- **[CHỐT c3] Q4 = phương án (b)**: app được đọc tín hiệu im lặng/hoạt động **và
  nội dung chat chung** để **hỏi riêng**, gợi ý từ một **bộ bài mốc đóng**.
  Luật bổ sung: L10 hai lớp tín hiệu · L11 chỉ hỏi ở cửa sổ lành · L12 hạn ngạch ·
  L13 tắt dần · L14 không trích lại lời người dùng · L15 không hỏi người này về
  người kia · L16 một chiều nằm chờ · L17-L20 khớp mẫu trên máy, chỉ gửi mã tín
  hiệu, không lưu chữ, tắt được, cấm hiển thị thành chỉ số · L21 bộ bài đóng.
  Danh mục đầy đủ: `signal-patterns.md`.
- **[CHỐT c4] Giọng câu hỏi gợi ý: ẤM như người bạn**, kèm **L22 — ấm ở sự QUAN
  TÂM, không ấm ở sự SUY DIỄN** (được phép dịu dàng, không được phép khẳng định
  điều app chưa biết).
- **[CHỐT c4] L23 — Bỏ lỡ là chấp nhận được.** Không detect được thì chờ mốc khác;
  không có cơ chế đuổi bắt mốc đã lỡ. **Hệ quả: auto-detect là phần thưởng thêm,
  không phải xương sống**; lưới an toàn luôn là onboarding hồi tố + tự khai.
- **[CHỐT c4] Kích thước bộ bài = ba tập lồng nhau**, không phải một con số:
  tự khai ~30-40 loại mốc (rẻ) ⊃ có hiện vật khoe riêng ~15 (đắt về design) ⊃
  auto-detect 8-10 (đắt nhất: pattern + test + rủi ro hỏi sai). Đề xuất 9 lá
  auto-detect bản đầu nằm ở `signal-patterns.md` §0-bis.
- **[CHỐT c5] App xưng "tụi mình".** Mọi tên lá bài viết theo giọng đó.
- **[CHỐT c5] `couple.startDate` sửa lùi TỰ DO**, không khoá; chống lạm dụng bằng
  việc luôn báo cho người kia khi ngày bị đổi, không bằng khoá kỹ thuật.
- **[CHỐT c5] Người làm chứng KHÔNG cần cài app.** Đổi lại: trang công khai phải
  nhận thao tác ghi từ người lạ (chống spam bằng tên + quan hệ + giới hạn phiên +
  cặp đôi gỡ được), và lời mời cài app chỉ hiện **sau khi** đã làm chứng.
- **[CHỐT c6] Bộ bài: 147 lá / 12 nhóm — `milestone-deck.md`, đã duyệt vòng 1.**
  Bỏ G03/I10/I11 vì vi phạm luật 2/1/3. **Toàn bộ 147 lá đều có hiện vật khoe
  riêng**, thực thi bằng hệ sinh theo tham số (12 khung x 6 bố cục + 147 con dấu)
  chứ không phải 147 layout thủ công; giữ **phân cấp nghi lễ** ~15 lá lớn để
  "đẹp đều" không thành "không gì nổi bật". Onboarding hồi tố **lướt toàn bộ**,
  xếp theo xác suất đã xảy ra, dừng được, **nhóm G (sẹo) nằm sau vách ngăn**.
- **[CHỐT c7 — HỘI TỤ] Thứ tự giao hàng 4 đợt** (Impact/Effort trên 12 lát + PMI):
  - **Đợt 1 "Có cái để khoe"** = ngày & bộ đếm + widget màn hình khoá · onboarding
    hồi tố + bộ bài tự khai · trình sinh thiệp trên ảnh của họ · hộ chiếu trưng bày.
    PMI yêu cầu rút **147 con dấu xuống 12 con dấu theo nhóm** cho đợt này.
  - **Đợt 2 "Khoe ra ngoài thật"** = trang công khai + người làm chứng + thu hồi
    URL. (Wrapped chen lên trước nếu sát Tết/cuối năm — lỡ mùa là mất một năm.)
  - **Đợt 3 "Chiều sâu và bản sắc"** = sẹo đầy đủ + hệ sinh hiện vật + nghi lễ 15
    lá + hearts faucet.
  - **Đợt 4 "Tinh ý"** = auto-detect 9 lá.
- **[c7] Phát hiện hội tụ quan trọng nhất: auto-detect rơi vào ô "hố"** (effort
  rất cao, impact trung bình) — chính vì `L23` "không detect được thì chờ mốc
  khác" đã tự hạ nó xuống vai phần thưởng thêm. Thứ được brainstorm nhiều nhất
  lại là thứ đáng làm muộn nhất.
- **[c6] Bốn kiến trúc A/B/C/D đã tự hợp nhất** thành bốn lớp của cùng một sản
  phẩm: A trưng bày · B thứ ship ra ngoài · C nguồn tin cậy + lan truyền · D chiều
  sâu bên trong. Bước còn lại là xếp thứ tự, không phải chọn.
- **[ĐÍNH CHÍNH c3]** Luật "cấm đọc nội dung `messages`" ở c2 đã bị bãi bỏ: nó do
  brainstormer tự siết và mâu thuẫn với `[CHỐT c7]` của IDEA-20260828-002
  ("học từ chat chung, chỉ từ chặng 2").
- **[CHỐT v8 — 2026-09-04] Sáu quyết định A-01…A-06 đã chốt**, sinh **3 luật mới**:
  - **L24 ranh giới ghi/khoe** (A-01=d): ghi là việc của **một người**, hiện ngay,
    người kia nhận báo nhẹ, **không có hàng chờ duyệt** (hàng chờ vi phạm cả L3 lẫn
    L4). Khoe ra ngoài app chỉ với con dấu **mình đã tận mắt xem** — mở ra xem *là*
    xác nhận. **Gỡ là quyền phủ quyết tức thời của cả hai.** L4 nói về *mở khoá mốc*,
    chưa bao giờ nói về *khoe*; L24 chỉ kéo ranh giới Q1 đã có về đúng chỗ.
  - **L25 `expenses` chỉ ở mức sự kiện** (A-06=1, **user override** ngược khuyến
    nghị cắt): đọc **sự tồn tại · ngày · nhãn loại**. **Trường số tiền không tồn tại
    trong DTO/schema của module mốc** — bịt đường trượt sang loại số thứ ba (L6) ở
    tầng kiểu dữ liệu, không phải tầng kỷ luật.
  - **L26 widget chỉ mang lá `CK`** (A-03=2, **user override** ngược khuyến nghị
    chỉ-bộ-đếm): nhóm G và mọi lá khán giả `R` **cấm vĩnh viễn** khỏi màn khoá —
    màn khoá là bề mặt công khai nhất trong đời sống hằng ngày.
- **[CHỐT v8] A-02 = Hộ chiếu là chế độ xem thứ hai của `TimelineScreen`**, kèm điều
  kiện bắt buộc nâng lối vào lên hạng nhất trên `HomeScreen` (nay đang bị chôn ở
  `home_screen.dart:1087`). **A-04 = `onboarding_chain` chỉ giữ 1 câu ngày gốc + 5 lá
  xác suất cao nhất**, 142 lá còn lại ra ngoài Nhà. **A-05 = luật kích hoạt**: Đợt 1
  xong trước **15/10/2026** thì Wrapped chen trước trang công khai, sau đó thì mùa 2027.
- **[VÒNG 8 — HÌNH HÀI SẢN PHẨM] 19 tính năng / 3 lớp / 16 màn hình mới.**
  `design-brief.md` + `screen-map.md`. Ba lớp động từ: **Nạp** (đã xảy ra chưa) ·
  **Giữ** (đóng dấu, cất) · **Khoe** (in ra, gửi đi). Đợt 1 = `F-01…F-06 + F-08`,
  tốn **7 màn hình mới · 5 SỬA · 6 NỐI · 0 tab mới · 0 màn hình bị xoá**.
- **[v8-1] Idea này KHÔNG lấy tab nào.** App có 5 tab và **IDEA-20260828-002 đã xin
  ô "Ví chung"**. Hộ chiếu vào bằng thẻ trên `HomeScreen` + **chế độ xem thứ hai của
  `TimelineScreen`** (`Dòng thời gian | Hộ chiếu`) — timeline vốn đã là nguyên thuỷ
  gần nhất của dấu mốc, nên đây là chủ nhà tự nhiên chứ không phải chỗ ở tạm.
- **[v8-2 · SỬA KẾT LUẬN c7] S1 tách đôi.** S1a bộ đếm (thuần Dart, effort thấp,
  giữ vai mở màn) ≠ **S1b widget màn hình khoá** (native hai nền tảng; `pubspec.yaml`
  không có package widget nào → trung bình–cao). Thứ tự 4 đợt **không đổi**, nhưng
  trong Đợt 1 thì S1b rơi xuống sau khi vòng `M-01 → M-03 → M-06` đã đóng.
- **[v8-3] Buổi ôn lại hồi tố KHÔNG chèn vào `onboarding_chain`** — nó là nghi thức
  đầu tiên *trong* app, hoãn được, không phải bước đăng ký bắt buộc. L23 cho phép.
- **[v8-4 · LỖ HỔNG MỚI → A-01, ĐÃ CHỐT lối d] "Người kia thấy gì?"** L4 cho một người mở khoá mốc
  thường, nhưng con dấu là vật thể của **cặp** còn hành động là của **một người** —
  bảy vòng trước chưa thiết kế bề mặt cho người thứ hai. Đề xuất: **hiện ngay, báo
  nhẹ, hai người sửa/gỡ đối xứng**; không bắt duyệt, vì duyệt giết mốc ở đúng nhóm H
  yêu xa. **Chặn việc vẽ M-04.**
- **[v8-5] Hiện vật ngày-1 phải đẹp khi KHÔNG có ảnh** — người mới cài có 0 ảnh
  trong `gallery`, mà tấm thiệp đầu tiên là tấm quyết định lan truyền. "Số lớn" và
  "tem hộ chiếu" là hai bố cục được đầu tư nhất Đợt 1; "ảnh tràn" là phần thưởng thêm.
- **[v8] `ChatScreen` và `PetScreen` nằm ngoài phạm vi Đợt 1-3 một cách cố ý** —
  ràng buộc thiết kế, không phải thiếu sót.
- Cấm dùng làm nguồn: tần suất nhắn tin làm thước đo, số tiền trong `expenses`,
  level/happiness của `pets` (cày được). Cấm auto-detect: lần đầu nói yêu, thân
  mật thể xác, có thai/kết hôn/chia tay thật, mọi suy luận về lỗi của một người.


## Artifacts

- **Danh sách tính năng + mô tả: `design-brief.md`** (19 tính năng F-01…F-19)
- **Bản đồ màn hình + user journey: `screen-map.md`** (16 màn hình mới, 7 journey)
- Development: `development.md`
- Danh mục tín hiệu phán đoán: `signal-patterns.md`
- Bộ bài mốc (147 lá, đã duyệt vòng 1): `milestone-deck.md`
- Checkpoint: `brainstormer-checkpoint.md`
- Message bàn giao (chờ user gửi): `handoff-to-scrum-master.md`

## Routing Notes

- Current owner: brainstormer
- **A-01…A-06 ĐÃ CHỐT ngày 2026-09-04** (`screen-map.md` Phần 6). Không còn câu hỏi
  chặn. Khâu vẽ màn hình mở. `handoff-to-scrum-master.md` đã cập nhật theo bản chốt.
- Next action: **không còn bước brainstorm bắt buộc.** Idea đã EXPANDED và sẵn sàng
  bàn giao. Bước kế tiếp nằm ngoài skill này.
- Delivery handoff: explicit user switch to `scrum-master` (Helen-SC) only.
  **Khuyến nghị phạm vi requirement đầu tiên: Đợt 1** (`S1+S3+S2+S4`, con dấu rút
  gọn 12 cái). Đầu vào cho Product Owner: `idea.md` (23 luật + framing),
  `milestone-deck.md` (147 lá đã duyệt), `development.md` `## Convergence Notes`.
  `signal-patterns.md` KHÔNG thuộc phạm vi Đợt 1 — để dành đợt 4.
