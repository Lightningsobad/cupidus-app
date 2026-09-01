# Idea Master: IDEA-20260831-001 Couple Milestone Achievements
Lifecycle: ACTIVE
Development Status: EXPANDED
Source: user
Created: 2026-08-31
Last Updated: 2026-08-31
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
- Cấm dùng làm nguồn: tần suất nhắn tin làm thước đo, số tiền trong `expenses`,
  level/happiness của `pets` (cày được). Cấm auto-detect: lần đầu nói yêu, thân
  mật thể xác, có thai/kết hôn/chia tay thật, mọi suy luận về lỗi của một người.


## Artifacts

- Development: `development.md`
- Danh mục tín hiệu phán đoán: `signal-patterns.md`
- Bộ bài mốc (147 lá, đã duyệt vòng 1): `milestone-deck.md`
- Checkpoint: `brainstormer-checkpoint.md`
- Message bàn giao (chờ user gửi): `handoff-to-scrum-master.md`

## Routing Notes

- Current owner: brainstormer
- Next action: **không còn bước brainstorm bắt buộc.** Idea đã EXPANDED và sẵn sàng
  bàn giao. Bước kế tiếp nằm ngoài skill này.
- Delivery handoff: explicit user switch to `scrum-master` (Helen-SC) only.
  **Khuyến nghị phạm vi requirement đầu tiên: Đợt 1** (`S1+S3+S2+S4`, con dấu rút
  gọn 12 cái). Đầu vào cho Product Owner: `idea.md` (23 luật + framing),
  `milestone-deck.md` (147 lá đã duyệt), `development.md` `## Convergence Notes`.
  `signal-patterns.md` KHÔNG thuộc phạm vi Đợt 1 — để dành đợt 4.
