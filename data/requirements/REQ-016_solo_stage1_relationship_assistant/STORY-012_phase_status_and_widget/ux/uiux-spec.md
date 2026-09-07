# UX Spec: STORY-012 Trạng thái theo pha, widget, và bộ đếm "của cải đang lớn"

Trạng thái đặc biệt của màn (1) + widget màn hình chính hệ điều hành. **Không**
phải màn hình thứ 12 (tổng vẫn 11 màn). Đọc `requirement-ux-survey.md` mục 0-5
trước khi đọc file này — mọi token, action-tier, và bản đồ điều hướng đã chốt
ở đó không lặp lại tại đây.

## 1. Bốn pha — nhãn trạng thái rời rạc, KHÔNG phải điểm số

Cùng luật với DẢI (survey mục 8): pha là một trong bốn **nhãn văn bản tĩnh**
từ tập đóng, không phải một vị trí trên một trục liên tục.

| Pha | Điều kiện nguồn (AC-4, chỉ đọc trường STORY-001) | Cấm tuyệt đối |
|---|---|---|
| Đang đợi | Thẻ gần nhất đã xuất lời mời, cờ = *chưa trả lời* (STORY-001 AC-17) | Không hiển thị số ngày đã đợi, không ước lượng thời gian phản hồi, không so sánh lần trước (AC-6/AC-7) |
| Sắp hẹn | Thẻ gần nhất = *Đã hẹn ngày*, ngày hẹn trong tương lai | — |
| Đúng ngày hẹn | Ngày hẹn = hôm nay; phản chiếu pha "trước giờ đi" do STORY-006 phát (AC-1); nếu STORY-006 chưa giao, suy biến về pha này từ trường ngày hẹn (AC-2) | Không tự vẽ nội dung checklist mới — chỉ phản chiếu |
| Khoảng lặng | Không có thẻ ở hai pha trên (giữa hai lần hẹn) | Không đếm số ngày lặng, không leo thang nội dung |

Luật nghiệm thu (mượn nguyên câu hỏi DẢI): *nếu một thành phần hiển thị pha có
thể trả lời được "còn bao lâu tới pha sau" bằng một con số/thanh/vòng tròn, nó
sai.* Không progress bar giữa 4 pha, không dot-stepper kiểu "bước 2/4" — pha
kế tiếp không hiện cho tới khi dữ liệu thật đổi.

Tại màn (1): mỗi pha hiện thành đúng **một dòng trạng thái** ngay trên thẻ
gần nhất liên quan — icon (Material Symbols, biến thể `line`) + nhãn ngắn +
(riêng pha "Đang đợi") một CTA hành động phụ dẫn tới việc chuẩn bị cụ thể
(AC-5, SB-83) — dùng đúng cột "hành động phụ" ở bảng action-tier (survey mục
4): text button, không nền đặc, `caption 13pt`.

## 2. Widget hệ điều hành — bề mặt công cộng (BR-11)

Widget bị người ngoài nhìn thấy màn khoá → chịu luật chặt hơn nội dung trong
app:

- **Không bao giờ** hiển thị: nội dung nhật ký, nội dung sổ tay (kể cả tên
  hoạt động/món quà cụ thể nếu tên đó do người dùng tự gõ), nhận định về người
  kia, bất kỳ chỉ báo hành vi người kia nào (AC-11, AC-12).
- Nội dung widget chỉ lấy từ **preset/mẫu câu ship kèm app** (BR-13, tất
  định) — không lắp chuỗi tự do người dùng đã nhập vào widget, kể cả khi
  chuỗi đó vô hại; dùng nhãn khái quát ("Một ý tưởng quà đang được chuẩn bị")
  thay vì tên quà thật.
- Bố cục 1 khối: icon pha (leading) + 1 dòng nhãn pha (`body`, đậm vừa) +
  tối đa 1 dòng phụ (`caption`). Không carousel, không danh sách nhiều dòng.
- Nội dung theo pha (copy chính xác do đội nội dung soạn theo R-15 — đây là khung):

  | Pha | Dòng chính | Dòng phụ |
  |---|---|---|
  | Đang đợi | "Đang chờ ngày hẹn" | CTA việc chuẩn bị (SB-83), không nhắc người kia |
  | Sắp hẹn | Đếm ngược "còn N ngày" | Không hiển thị tên hoạt động nếu người dùng tự gõ tên riêng tư; dùng nhãn khái quát nếu cần |
  | Đúng ngày hẹn | "Hôm nay là ngày hẹn" | Phản chiếu 1 gợi ý "Trước giờ đi" nếu có (STORY-006), không danh sách đầy đủ |
  | Khoảng lặng | Ưu tiên: (1) tiến triển quà nếu đang chạy (AC-20, nhãn khái quát) → (2) nội dung nhỏ giọt nếu tới lượt (BR-9, tối đa 1 lần/tuần) → (3) bộ đếm "của cải đang lớn" dạng tĩnh làm nội dung mặc định | Không dòng nào ép buộc — khoảng lặng không có nội dung hợp lệ nào thì widget hiện trạng thái trung tính "Chưa có gì mới", không rỗng trơ |

  Thứ tự ưu tiên ở pha "Khoảng lặng" là **quyết định UX**, không phải AC bắt
  buộc — mục đích tránh widget trống một cách khó hiểu; không vi phạm AC-21
  (gift-progress) vì bộ đếm ở mục 4 vẫn hiển thị đúng luật "mô tả, không thúc"
  (BR-7).
- Bấm vào widget → mở thẳng chi tiết thẻ liên quan (không qua trang trung
  gian). Không thêm hành động thứ hai trên widget (không nút "đã xong" nhúng
  trong widget — tránh biến widget thành to-do có trạng thái tích luỹ, cùng
  tinh thần STORY-006 mục 2 "không checkbox").
- Widget là bề mặt **bổ trợ**: nếu người dùng không thêm, không mất tính năng
  nào (AC-13) — không banner nào trong app nhắc "thêm widget đi" lặp lại
  (tránh nagging, cùng tinh thần R-1c).

## 3. Đếm ngược trên thẻ *Đã hẹn ngày* (SB-86)

- Hiển thị ngay dưới tiêu đề thẻ trong danh sách và trong chi tiết thẻ:
  `caption 13pt` + icon `event` biến thể line, dạng "còn N ngày".
- Ngày hẹn đã qua mà thẻ chưa đổi trạng thái (AC-15): dòng đổi sang trung tính
  "Đã tới ngày hẹn" — không đếm số ngày trễ, không màu cảnh báo (`--red`
  không dùng ở đây, chỉ dành cho hành động phá huỷ theo token mục 5 survey).

## 4. "Về tới nhà chưa?" — nhắc nhẹ 23h (SB-85, J8)

- Thông báo hệ thống thời điểm ~23h ngày hẹn, nội dung hỏi **về người dùng**,
  không hỏi về người kia và không yêu cầu đánh giá buổi hẹn (AC-19).
- Chạm vào thông báo → mở thẳng luồng 2 bước gộp trong một sheet nhỏ: (1) tuỳ
  chọn đính ảnh (mở OS picker), (2) một ô nhập 1 câu → lưu vào nhật ký
  (STORY-003). Không ép cả hai bước — bỏ trống vẫn lưu được (đồng nhất "cất
  ảnh và viết một câu" nhưng không khoá nhau).
- Nếu STORY-003 chưa giao (AC-18): bỏ bước (2), chỉ giữ (1) cất ảnh; sheet co
  lại còn đúng phần dùng được, không hiện ô nhập bị vô hiệu hoá xám.
- Bỏ qua thông báo (AC-17): không nhắc lại thông báo đó nữa. Không icon/badge
  "còn 1 việc chưa làm" tồn đọng trên app icon hay trong app sau đó.

## 5. "Món quà đang lớn" và nhỏ giọt (SB-87/SB-99, khoảng lặng)

- Trong app (khác widget, có thể chi tiết hơn nhưng vẫn không nhận định về
  người kia): một khối gọn trên màn (1) trong pha "Khoảng lặng", tiêu đề "Món
  quà đang lớn" + tối đa 1 dòng mô tả tiến triển của **việc người dùng đang
  làm** (ví dụ "Đã chuẩn bị được 2/3 phần" nếu tiến triển đó là số bước rời
  rạc do chính người dùng tự đánh dấu — KHÔNG phải phần trăm liên tục, KHÔNG
  phải thanh progress đồ hoạ; dùng dạng chữ "X/Y phần" hoặc nhãn giai đoạn
  rời rạc, cùng tinh thần "DẢI = nhãn tĩnh").
- Không có ý tưởng quà đang chạy (AC-21): khối này **không hiện** — đây là
  trạng thái đúng. Không đặt CTA "tạo ý tưởng quà" vào chỗ trống đó (cấm dùng
  khoảng trống để thúc tạo dữ liệu).
- Nhỏ giọt (AC-22/BR-9): tối đa 1 lần/tuần, hiện dưới dạng 1 dòng caption
  trung tính, không banner nổi bật, không badge, không chấm đỏ.

## 6. Bộ đếm "của cải đang lớn" trên màn (1) + cột mốc J12

- Vị trí: một dòng tĩnh ngay dưới tiêu đề màn "Nhà" (nhánh solo), phía trên
  dải lối-vào-nhanh 3 ô (survey mục 0). Không đặt trong header sticky — đây
  không phải nhãn xuất xứ, chỉ là mô tả trạng thái.
- Hiển thị: icon `line` trung tính (ví dụ `auto_awesome` hoặc tương đương,
  không dùng icon cúp/huy hiệu) + số đếm + nhãn, ví dụ dạng "12 kỷ niệm đã
  lưu". **Chỉ một con số tĩnh** — không thanh tiến độ, không vòng tròn %,
  không mục tiêu kế bên (BR-7, AC-27).
- Cột mốc J12 (AC-28, BR-8): khi bộ đếm chạm một ngưỡng do backend định nghĩa,
  hiển thị **đúng một lần** một dòng caption phụ ngay dưới số đếm, ví dụ "Bạn
  vừa chạm một cột mốc" — tự ẩn ở lần mở màn kế tiếp, **không** dialog, không
  hiệu ứng confetti/âm thanh, không nút hành động nào (không "mời người kia",
  không "chia sẻ"). Đây là "nhận ra", không phải "ăn mừng" — khác biệt có chủ
  đích với mọi mẫu ăn mừng gamification.
- Vắng mặt dài (AC-26): số đếm giữ nguyên, không dòng nào nhắc số ngày vắng
  hay "chuỗi bị đứt" xuất hiện gần bộ đếm.
- Xoá thẻ (AC-29): số đếm cập nhật ngay, không hộp thoại/cảnh báo nào khác
  ngoài xác nhận xoá đã có ở STORY-001 mục 5 — không thêm bước hỏi lý do.

## 7. Cài đặt thông báo (D-1, AC-30/31/32)

Thêm đúng 2 hàng toggle vào màn Cài đặt thông báo có sẵn (`me_screen.dart`),
tái dùng nguyên component toggle-row đang có — không tạo màn cài đặt riêng:

1. "Nhắc về tới nhà chưa?" (SB-85)
2. "Nội dung nhỏ giọt khoảng lặng" (SB-99)

Tắt một hàng chỉ tắt đúng loại đó; countdown, pha, và bộ đếm không phải thông
báo đẩy nên không cần toggle riêng — chúng luôn hiển thị thụ động trong app.
Tắt toàn bộ (switch tổng có sẵn của OS/app) → không thông báo nào gửi, mọi
tính năng còn lại (pha, đếm ngược, bộ đếm) vẫn hoạt động bình thường (AC-30).

## 8. Ranh giới bàn giao

- Story này **đọc**, không **phát** — không tạo trường mới trên thẻ, không
  đổi hợp đồng STORY-001, không yêu cầu STORY-006 đổi (BR-1/BR-12).
- STORY-006 sở hữu nội dung "Trước giờ đi"; story này chỉ phản chiếu 1 dòng
  tóm tắt, không vẽ lại checklist đầy đủ trên widget hay trên dòng trạng thái
  màn (1).
- Gỡ widget hoặc gỡ toàn bộ story này không được làm hỏng bất kỳ AC nào của
  story khác (AC-3).

## Completion

- [x] Áp dụng đúng luật DẢI = nhãn tĩnh cho 4 pha (mục 1).
- [x] Widget tuân BR-11 (bề mặt công cộng, không nhật ký/sổ tay/nhận định).
- [x] Bộ đếm không thanh tiến độ, không mục tiêu; cột mốc J12 là "nhận ra" một
      lần, không ăn mừng (mục 6, BR-7/BR-8).
- [x] Không có bất kỳ chỉ báo hành vi người kia nào ở bất kỳ bề mặt nào trong
      spec này (R-1b xuyên suốt mục 1-6).
- Không phát hiện mâu thuẫn artifact mới ngoài các mục đã ghi ở
  `requirement-ux-survey.md` mục 6.
