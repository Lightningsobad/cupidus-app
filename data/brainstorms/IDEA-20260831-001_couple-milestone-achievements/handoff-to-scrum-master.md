# Handoff → Helen-SC (scrum-master)

Nguồn: `IDEA-20260831-001_couple-milestone-achievements` (ACTIVE / EXPANDED).
Cập nhật **2026-09-04, vòng 8** — thêm lớp sản phẩm (19 tính năng, 16 màn hình,
7 user journey) và **6 quyết định đã chốt** A-01…A-06.

Đây là **khuyến nghị bàn giao**, không phải requirement. Brainstormer không tạo
artifact trong `data/requirements/`.

## Message để user dán vào Helen-SC

---

thêm yêu cầu: Hệ thống "Dấu mốc" cho cặp đôi — Đợt 1 "Có cái để khoe".

Nguồn ý tưởng đã EXPANDED:
`data/brainstorms/IDEA-20260831-001_couple-milestone-achievements/`.

Đọc theo thứ tự hẹp nhất:
1. `design-brief.md` — 19 tính năng F-01…F-19, mô tả đầy đủ 8 tính năng Đợt 1,
   6 quyết định đã chốt (§1b), 26 luật thiết kế (§6), danh sách đã loại (§7).
2. `screen-map.md` — bảng tổng màn hình (16 mới / 8 SỬA / 7 NỐI / 21 GIỮ),
   7 user journey, dây phụ thuộc Đợt 1 (Phần 5), bản chốt A-01…A-06 (Phần 6).
3. `milestone-deck.md` — bộ bài 147 lá đã duyệt, 12 nhóm A–L.
4. `idea.md` — framing gốc, chỉ khi cần truy nguyên một luật.

KHÔNG đọc `signal-patterns.md` — thuộc Đợt 4, ngoài phạm vi.
KHÔNG đọc `development.md` trừ khi cần lưới Impact/Effort — nó là nhật ký 8 vòng.

Phạm vi Đợt 1 = F-01…F-06 + F-08, rồi F-07 cuối đợt. PO tự chia story.

- **F-01 Ngày gốc & bộ đếm** — `couple.startDate` sửa lùi tự do về quá khứ, không
  khoá; mỗi lần đổi phải báo cho người kia (ngày cũ → ngày mới → ai đổi). Sinh 16
  mốc nhóm A tự động. A12 (kỷ niệm hằng tháng) mặc định TẮT.
- **F-02 Bộ bài & kho tra cứu 147 lá** — bộ bài ĐÓNG, hệ thống không bao giờ tự
  sinh loại mốc mới. Kho luôn mở, không giấu lá nào; nhóm G sau vách ngăn.
- **F-03 Buổi ôn lại hồi tố** — tách hai nửa theo A-04: **5 lá xác suất cao nhất
  nằm TRONG `onboarding_chain`** (cứng dưới 60 giây, không lá nhóm G), **142 lá còn
  lại NGOÀI chain** như lời mời hoãn được trên `HomeScreen`. Xếp theo xác suất đã
  xảy ra suy từ độ dài quan hệ vừa khai. Dừng/tiếp bất cứ lúc nào, KHÔNG bắt buộc
  hoàn thành. Nhóm G cuối cùng, sau vách ngăn: "Phần tiếp theo nói về những lúc
  khó. Xem sau cũng được."
- **F-04 Tự khai & sửa mốc** — bấm "đã xảy ra rồi", ngày là tuỳ chọn và nhận được
  khoảng thời gian ("khoảng hè 2024"). **Zero typing là yêu cầu thiết kế, không
  phải mong muốn** — tự khai chết khi phải gõ. Cả hai người sửa/gỡ đối xứng.
- **F-05 Hộ chiếu** — theo A-02, đây là **chế độ xem thứ hai của `TimelineScreen`**
  (`Dòng thời gian | Hộ chiếu`), KHÔNG phải tab mới, KHÔNG phải màn hình rời.
  Điều kiện bắt buộc: **nâng lối vào lên hạng nhất trên `HomeScreen`** — hiện nó
  đang bị chôn (push từ `home_screen.dart:1087`). Lá chưa đạt hiện mờ; cấm thanh
  tiến độ, phần trăm, và mọi cách nói "còn thiếu bao nhiêu".
- **F-06 Xưởng hiện vật** — thiệp tỉ lệ story, chia sẻ qua share sheet hệ thống
  (`share_plus` đã có trong `pubspec.yaml`). Đợt 1 dùng **12 con dấu chung theo
  nhóm (KHÔNG phải 147)** và **3 bố cục**: số lớn · tem hộ chiếu · ảnh tràn.
  ⚠️ Hai bố cục **không cần ảnh** phải là hai bố cục đẹp nhất: người vừa cài app
  có 0 ảnh trong `gallery`, mà tấm thiệp đầu tiên là tấm quyết định lan truyền.
- **F-08 Mốc tự sinh từ sự kiện cứng** — thu hoạch chéo module đã có, không xây
  feature mới: `gallery` (I02 ảnh thứ N, I03 album đầu) · `timeline` (I04) ·
  `dream-jar` (I05) · `themes` (I06) · `data-export` (I07) · `love-contracts`
  (giao ước xong, đã sẵn consent hai phía) · `pairing` (I01).
- **F-07 Widget màn hình khoá — LÀM CUỐI ĐỢT** — bản đầy đủ theo A-03: bộ đếm +
  mốc gần nhất + mốc sắp tới. Bộ đếm và mốc sắp tới là hàm thuần của `startDate`
  nên widget tự tính offline; chỉ "mốc gần nhất đã đạt" cần app ghi một bản ghi
  sang App Group (iOS) / DataStore (Android) rồi reload. Không gọi mạng từ widget.
  **Quy tắc trượt: nếu cuối Đợt 1 widget chưa xong thì nó trượt sang Đợt 2, KHÔNG
  kéo dài Đợt 1.** Vòng giá trị M-01 → M-03 → M-06 mới là thứ định nghĩa Đợt 1
  xong hay chưa.

Ràng buộc cứng phải sống sót vào acceptance criteria:
- **Không farm được**: cấm streak, cấm đếm tần suất hoạt động, cấm mọi thứ cày ra.
- **Không so sánh** giữa hai người trong cặp, cũng không giữa các cặp.
- **Không phạt khi im lặng**: quan hệ nguội / cãi nhau / yêu xa không mất gì.
- **Luật hai loại số**: *sự kiện* (ngày tháng, có/không xảy ra) không được sai;
  *phán xét* (lãng mạn, gắn bó) được phép mơ hồ. CẤM số suy đoán giả vờ chính xác
  kiểu "hợp nhau 92%".
- **Bộ bài đóng**: không bao giờ sinh loại mốc mới ngoài 147 lá.
- **L24 ranh giới ghi/khoe**: ghi là việc của một người và hiện ngay, người kia
  nhận thông báo nhẹ; **KHÔNG có hàng chờ duyệt** (hàng chờ vi phạm cả L3 lẫn L4).
  Khoe ra ngoài app chỉ với con dấu mình đã tận mắt xem — mở ra xem *là* xác nhận,
  không cần nút "duyệt". **Gỡ là quyền phủ quyết tức thời của cả hai.**
- **L25 `expenses` chỉ ở mức sự kiện**: module mốc đọc được **sự tồn tại · ngày ·
  nhãn loại**, hết. **Trường số tiền không được tồn tại trong DTO/schema của module
  mốc** — ràng buộc ở tầng kiểu dữ liệu, không phải ở tầng lưu ý cho lập trình viên.
- **L26 widget chỉ mang lá khán giả `CK`**: nhóm G (sẹo) và mọi lá khán giả `R` bị
  cấm vĩnh viễn khỏi màn hình khoá.
- Mốc "sẹo" mặc định riêng tư; nếu lộ ra ngoài thì chỉ ở dạng đã vượt qua và đã
  tổng hợp ("đã cùng đi qua 8 tháng yêu xa"), không bao giờ ở dạng sự kiện đơn lẻ.
- Giọng: app xưng "tụi mình", ấm như người bạn, nhưng **chỉ ấm ở sự quan tâm chứ
  không ấm ở sự suy diễn** — không khẳng định điều app chưa biết.
- Cấm làm nguồn mốc: pet level/happiness, vibe streak, tần suất nhắn tin.

Ngoài phạm vi Đợt 1 (đừng kéo vào): trang công khai · người làm chứng ·
đọc/phán đoán từ chat · Cupid Wrapped · hệ sinh hiện vật đầy đủ 147 con dấu +
nghi lễ 15 lá · hearts faucet · bản in vật lý · mốc solo chặng 1.

`ChatScreen` và `PetScreen` nằm ngoài phạm vi Đợt 1–3 **một cách cố ý**. Đó là
ràng buộc thiết kế, không phải thiếu sót cần bổ sung.

Lưu ý giao thoa và lịch:
- **Xung đột tab với IDEA-20260828-002**: idea đó đã xin ô tab "Ví chung". Dấu Mốc
  đã tự tránh (A-02 = chế độ xem của Timeline, không lấy tab). Người xếp lịch cần
  biết để không vô tình cấp tab cho cả hai.
- **Mốc lịch A-05**: nếu Đợt 1 xong **trước 15/10/2026** thì Cupid Wrapped chen lên
  trước trang công khai ở Đợt 2; sau mốc đó thì giữ thứ tự cũ, Wrapped làm mùa 2027.
  Lỡ mùa là mất một năm.
- Đợt 3 sẽ nối `hearts` (mốc đúc ra hearts — faucet cho IDEA-20260828-001). Đừng
  thiết kế Đợt 1 theo cách chặn hướng đó.

---

## Ghi chú cho scrum-master

- Đợt 1 cố tình không chạm luật rủi ro nào (không đọc chat, chưa công khai, không
  so sánh) → nếu sai hướng thì rút lui rẻ.
- **Khối lượng lớn nhất của Đợt 1 là nội dung + thiết kế**, không phải backend:
  147 tên lá theo giọng "tụi mình" + 12 con dấu theo nhóm + 3 bố cục. Nội dung này
  nên xong trước khi code bắt đầu.
- Backend chỉ cần **một module mới `milestones`**: bộ bài (tĩnh), con dấu (theo
  cặp), lịch sử sửa `startDate`. Mọi nguồn khác chỉ **đọc** từ module đã có.
- Đợt 1 tốn **7 màn hình mới · 5 SỬA · 6 NỐI · 0 tab mới · 0 màn hình bị xoá**.
- Rủi ro cần đo sớm, không đoán: **thời lượng thật của buổi ôn lại (M-02b)**. Nếu
  lướt 142 lá mất 20 phút thì tính năng tự giết chính nó.
- Rủi ro số hai: **lối vào Hộ chiếu**. Nếu `TimelineScreen` vẫn bị chôn như hiện
  tại thì trái tim sản phẩm nằm dưới đáy và cả Đợt 1 mất tác dụng.
- Hai quyết định A-03 (widget bản đầy đủ) và A-06 (giữ `expenses`) là **user
  override** ngược khuyến nghị brainstormer. Cả hai đã được nhận kèm luật chặn
  (L26, L25). Đừng "tối ưu" chúng ngược lại mà không hỏi user.
