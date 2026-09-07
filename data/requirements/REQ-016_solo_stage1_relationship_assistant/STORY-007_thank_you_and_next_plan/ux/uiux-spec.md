# UX Spec: STORY-007 "Cảm ơn + chốt việc kế tiếp" (SB-212)

Requirement: REQ-016 · Story-Class: standard
Depends On: STORY-001, STORY-002, STORY-003, STORY-005
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../ux/requirement-ux-survey.md` mục 4 (bảng action-tier — BẮT BUỘC),
`STORY-001/ux/uiux-spec.md` mục 5 (chi tiết thẻ, "Ghi lại"),
`STORY-002/ux/uiux-spec.md` mục 6 (renderer đa danh mục),
`STORY-006/ux/uiux-spec.md` (mẫu khối con lồng cùng hệ thẻ — tái dùng nguyên
mẫu container). `DESIGN_SOURCE_NOT_DETECTED` bình thường ở giai đoạn này —
spec dùng luật đo được.

## 1. Vị trí — khối mở rộng trong "chế độ ghi ký ức"

Hành động chính cấp thẻ "Ghi lại" (thẻ *Đã đi rồi*, STORY-001 mục 5) mở chi
tiết thẻ ở **chế độ ghi ký ức** (trường ảnh/ghi chú do STORY-001 sở hữu).
Khối "Cảm ơn + chốt việc kế tiếp" là một **khối con lồng** nằm **dưới cùng**
các trường ảnh/ghi chú đó, dùng **đúng mẫu container** đã lập ở
`STORY-006/ux/uiux-spec.md` mục 2 (bo góc `--r-sm`, nền tách lớp, thụt trái
`md`) — hai khối (STORY-006 trên thẻ *Đã hẹn ngày*, khối này trên thẻ *Đã đi
rồi*) **không bao giờ** cùng hiện trên một thẻ vì khác trạng thái, nên dùng
chung một mẫu thị giác là nhất quán, không xung đột.

Khối chỉ hiện **một lần** — lần đầu người dùng mở chi tiết thẻ đó vào một
ngày lịch **sau** ngày thẻ chuyển *Đã đi rồi* (AC-1/AC-2). Sau lần hiện đó,
dù dùng hết ba phần, dùng một phần, hay không dùng gì, khối **không hiện lại
nữa cho thẻ đó** (AC-3) — không có cách nào từ UI để gọi lại nó (khác với
STORY-006, khối này không có nút "mở lại", vì SB-212 chủ ý "bỏ qua thì thôi
hẳn").

## 2. Header khối và cách đóng

- Tiêu đề khối: "Cảm ơn + chốt việc kế tiếp" (`body 17pt/600`), cùng tầng thị
  giác tiêu đề như khối STORY-006.
- Icon đóng (`close`, biến thể line, ≥44pt vùng chạm) ở góc phải header —
  bấm ẩn khối khỏi màn ngay, không hộp thoại xác nhận. Đóng bằng icon này
  **tương đương** với đã tiêu thụ lượt hiện một lần: khối không quay lại dù
  đóng bằng icon hay dùng xong cả ba phần (nhất quán AC-3).

## 3. Ba phần bên trong khối, từ trên xuống

Cả ba đều ở tầng "hành động phụ" theo bảng action-tier (không nền `--grad`
đặc, không cùng cấp thị giác với "Ghi lại").

**Phần 1 — Soạn lời cảm ơn** (luôn hiện): một hàng chip/text-button nhãn
"Soạn lời cảm ơn". Bấm → mở **đúng bottom sheet renderer của STORY-002**
(mục 2 spec đó), chỉ khác tham số danh mục preset = "lời cảm ơn sau hẹn" —
**không có UI mới nào được vẽ** cho bước này (AC-8/AC-9). Sau khi đóng sheet,
người dùng quay lại khối này (không quay lại "khu vực Chuẩn bị" của thẻ khác
— ngữ cảnh mở sheet quyết định điểm quay về, đúng nguyên tắc mục 6 của spec
STORY-002).

**Phần 2 — Đính ảnh** (chỉ hiện khi có ít nhất 1 ảnh đã lưu ở nhật ký/thẻ cho
buổi hẹn đó, AC-14/AC-15): một hàng thumbnail ảnh dạng lưới ngang cuộn được.
Mỗi thumbnail:
- Chỉ hiển thị **ảnh**, không có chữ, không ngày giờ, không nhãn nào của mục
  nhật ký đè lên (ranh giới riêng tư AC-17/BR-8 — chữ và siêu dữ liệu không
  bao giờ rời thiết bị qua đường này).
- Mặc định **chưa chọn** (không viền nhấn, không dấu tick) — AC-16 cấm app
  tự đính sẵn. Bấm vào thumbnail để chọn/bỏ chọn cho vật phẩm chia sẻ, hiện
  dấu tick nhỏ góc trên-phải khi đã chọn.
- Không có gợi ý/mũi tên "thêm ảnh mới" ở đây — phần này chỉ đọc ảnh **đã có
  sẵn**, không mở camera/thư viện (giữ boundary chỉ-đọc với nhật ký).

Khi chưa có ảnh nào: phần 2 **không tồn tại** trong khối — không hàng xám,
không placeholder khung ảnh rỗng, không CTA "thêm ảnh đi" (AC-15, BR-9).

**Phần 3 — Chốt việc kế tiếp** (luôn hiện, nhưng tuỳ chọn thật — AC-23): 2-3
chip gợi ý ngang hàng nhau (cùng kích thước, không chip nào nổi bật hơn),
nội dung lấy từ kho mồi STORY-005 hoặc dịp lịch âm gần nhất. Bấm một chip →
**tạo thẻ ngay lập tức** (không hộp thoại xác nhận chặn — đây chính là bước
"xác nhận" của AC-20), kèm snackbar đáy màn "Đã thêm vào kho hoạt động —
Hoàn tác" hiển thị 5 giây. Không chọn chip nào và đóng khối → không thẻ nào
được tạo, không nhắc lại, không dấu chưa-hoàn-thành ở bất kỳ đâu (AC-22).

## 4. Phần 1 — soạn lời cảm ơn, chia sẻ

Sau khi bấm "Chia sẻ" trong bottom sheet (hành động chính của sheet, theo
đúng mục 2.5 spec STORY-002), vật phẩm ra qua OS Share Sheet. Đóng sheet quay
lại khối này với phần 1 **vẫn hiện** (không tự ẩn sau khi dùng) vì phần 2/3
có thể chưa dùng và khối chỉ đóng theo AC-3 (lần hiện, không theo lượt dùng
từng phần).

## 5. Ngoại tuyến, tất định, ranh giới đạo đức

- Toàn bộ ba phần hoạt động đúng tới bước Share Sheet khi không có mạng —
  không skeleton chờ mạng (AC-29).
- Không phần tử nào ngụ ý AI đang soạn (không spinner sinh nội dung, không
  nhãn "AI viết giúp") — R-7, AC-30.
- Không nơi nào trong khối hiển thị/lưu chỉ báo hành vi người kia — không
  "đã xem lời cảm ơn", không "người ấy chưa phản hồi" (AC-26, R-1b).
- Đóng khối/bỏ qua không sinh hệ quả thị giác về sau — không huy hiệu thiếu,
  không bộ đếm bỏ lỡ, không streak (AC-25, AC-28).

## 6. Đồng cư với STORY-006 trong cùng hệ thẻ

Cả hai khối dùng **cùng một mẫu container, cùng vị trí tương đối** (dưới nội
dung chính của chi tiết thẻ) và **cùng bảng action-tier** — sự nhất quán này
là câu trả lời cho yêu cầu "UI/UX Designer chốt cách hai khối cùng tồn tại
trong một hệ thẻ nhất quán": chúng không bao giờ đồng thời hiện trên một thẻ
(khác trạng thái), nên không cần phân biệt thêm bằng màu sắc hay icon nhóm
đặc biệt nào khác ngoài tiêu đề khối.

## 7. Trách nhiệm bàn giao

- Chip "chốt việc kế tiếp" tạo thẻ qua đúng hợp đồng thẻ STORY-001/STORY-005;
  không tạo đường tạo thẻ thứ hai.
- Story này **không** đọc trạng thái pha của STORY-012 và không vẽ widget
  (AC-31) — khối J8 "23h vừa về" thuộc phạm vi khác, không xuất hiện ở đây.

## Completion

Điều kiện ship nội dung giọng điệu của danh mục preset "lời cảm ơn sau hẹn"
vào bản build người dùng thật nay là R-15: qua cổng nhập nội dung chạy được
(R-15c) và có truy vết duyệt qua id bền; không chặn cấu trúc UI, luồng kích
hoạt một lần, đính ảnh, hay cơ chế tạo thẻ ở trên (đối chiếu
`requirements.md` → `## Open Question Impact`). Spec trên đủ để build và
verify bằng nội dung placeholder nội bộ.
