# Handoff → Helen-SC (scrum-master)

Nguồn: `IDEA-20260831-001_couple-milestone-achievements` (ACTIVE / EXPANDED).
Đây là **khuyến nghị bàn giao**, không phải requirement. Brainstormer không tạo
artifact trong `data/requirements/`.

## Message để user dán vào Helen-SC

---

thêm yêu cầu: Hệ thống "Dấu mốc" cho cặp đôi — Đợt 1 "Có cái để khoe".

Nguồn ý tưởng đã EXPANDED: `data/brainstorms/IDEA-20260831-001_couple-milestone-achievements/`.
Đọc theo thứ tự hẹp nhất: `idea.md` (framing + 23 luật thiết kế) →
`development.md` `## Convergence Notes` (lưới Impact/Effort, 4 đợt, PMI Đợt 1) →
`milestone-deck.md` (bộ bài 147 lá đã duyệt, 12 nhóm A–L).
KHÔNG đọc `signal-patterns.md` — nó thuộc Đợt 4, ngoài phạm vi.

Phạm vi Đợt 1 (8 khối, PO tự chia story):
1. `couple.startDate` sửa lùi tự do về quá khứ; mỗi lần đổi phải báo cho người kia.
2. Mốc thời gian nhóm A (16 lá) tự sinh từ `startDate` — không cần user nhập.
3. Widget màn hình khoá đếm ngày (kênh khoe bị động, ưu tiên cao hơn vẻ ngoài của nó).
4. Onboarding hồi tố: lướt toàn bộ 147 lá, xếp theo xác suất đã xảy ra (suy từ độ
   dài quan hệ vừa khai), dừng/tiếp tục bất cứ lúc nào, KHÔNG bắt buộc hoàn thành.
   Nhóm G ("sẹo") nằm cuối, sau vách ngăn: "Phần tiếp theo nói về những lúc khó.
   Xem sau cũng được."
5. Bộ bài tự khai 147 lá: bấm "đã xảy ra rồi" + chọn ngày. Zero typing là yêu cầu
   thiết kế, không phải mong muốn — tự khai chết khi phải gõ.
6. Trình sinh hiện vật: thiệp tỉ lệ story đè lên ảnh của chính họ từ `gallery`,
   dùng 12 con dấu chung theo nhóm (KHÔNG phải 147) x 6 bố cục theo loại dữ liệu
   (số lớn / bản đồ / ảnh tràn / danh sách tích luỹ / chứng nhận / tem hộ chiếu),
   + chia sẻ qua share sheet hệ thống.
7. Hộ chiếu: màn hình trưng bày con dấu theo dòng thời gian.
8. Mốc nhóm G cần đồng thuận hai chiều mới vào hộ chiếu chung — tái dùng pattern
   mutual-consent đã có ở themes/reminders.

Ràng buộc cứng phải sống sót vào acceptance criteria:
- Không farm được: cấm streak, cấm đếm tần suất hoạt động, cấm mọi thứ cày ra được.
- Không so sánh giữa hai người trong cặp. Không so sánh giữa các cặp.
- Không phạt khi im lặng: quan hệ nguội / cãi nhau / yêu xa không được mất gì.
- Luật hai loại số: *sự kiện* (ngày tháng, có/không xảy ra) không được phép sai;
  *phán xét* (lãng mạn, gắn bó) được phép mơ hồ. CẤM số suy đoán giả vờ chính xác
  kiểu "hợp nhau 92%".
- Bộ bài đóng: hệ thống không bao giờ tự sinh loại mốc mới ngoài 147 lá.
- Mốc "sẹo" mặc định riêng tư; nếu sau này lộ ra ngoài thì chỉ ở dạng đã vượt qua
  và đã tổng hợp ("đã cùng đi qua 8 tháng yêu xa"), không bao giờ ở dạng sự kiện
  đơn lẻ có ngày.
- Giọng: app xưng "tụi mình", ấm như người bạn, nhưng chỉ ấm ở sự quan tâm chứ
  không ấm ở sự suy diễn — không khẳng định điều app chưa biết.
- Cấm dùng làm nguồn mốc: pet level/happiness, vibe streak, số tiền trong
  `expenses` (chỉ lấy sự kiện), tần suất nhắn tin.

Ngoài phạm vi Đợt 1 (đừng kéo vào): trang công khai · người làm chứng ·
đọc/phán đoán từ chat · Cupid Wrapped · hệ sinh hiện vật đầy đủ 147 con dấu +
nghi lễ 15 lá · hearts faucet · bản in vật lý · mốc solo chặng 1.

Lưu ý giao thoa: Đợt 3 sẽ nối `hearts` (mốc đúc ra hearts — faucet cho
IDEA-20260828-001) và Đợt 2 phụ thuộc quyết định công khai internet. Đừng thiết
kế Đợt 1 theo cách chặn hai hướng đó.

---

## Ghi chú cho scrum-master

- Đợt 1 cố tình không chạm luật rủi ro nào (không đọc chat, chưa công khai, không
  so sánh) → nếu sai hướng thì rút lui rẻ.
- Khối lượng lớn nhất của Đợt 1 là **nội dung + thiết kế** (147 lá text + 12 con
  dấu + 6 bố cục), không phải backend. Dữ liệu nguồn đã có sẵn trong repo.
- Rủi ro cần đo sớm, không đoán: **thời lượng thật của onboarding hồi tố**.
