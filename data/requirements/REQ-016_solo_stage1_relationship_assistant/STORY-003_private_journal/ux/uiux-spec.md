# UX Spec: STORY-003 Nhật ký riêng

Requirement: REQ-016 · Story-Class: standard · Depends On: NONE (song song
được với STORY-001)
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../ux/requirement-ux-survey.md`. `DESIGN_SOURCE_NOT_DETECTED` bình thường —
spec dùng luật đo được.

## 1. Vị trí trong shell

Theo quyết định điều hướng đã khoá ở `../ux/requirement-ux-survey.md` mục 0:
lối vào từ tab **"Tôi"**, tái dùng nguyên mẫu `_MenuRow` (icon-badge + label +
chevron, có sẵn ở `me_screen.dart`) trong một khối card nhóm mới, tiêu đề
"Kho riêng của tôi", cạnh 2 hàng khác của STORY-004 (Sổ tay, Hồ sơ kỹ năng).
Story này chỉ cần thêm **một** hàng: "Nhật ký riêng" (icon sách/line variant),
chạm mở màn Nhật ký full-screen. Không thêm route ở tab khác, không thêm tab.

## 2. Bố cục màn Nhật ký

1. Header đơn giản: tiêu đề "Nhật ký riêng" + nút quay lại. Không hiện số mục
   đã viết, không hiện chuỗi ngày, không hiện "bạn đã viết X ngày liên tiếp".
2. Danh sách mục theo thời gian (mới nhất trên đầu), mỗi hàng: ngày viết
   (`caption 13pt`), 1-2 dòng trích đầu văn bản (`body 17pt`), ảnh thu nhỏ
   nếu có (hình vuông nhỏ, `--r-sm`). Chạm mở toàn văn.
3. Nút tạo mục mới: pill nổi góc dưới hoặc CTA trên header, nền `--grad`,
   nhãn "Viết điều gì đó" — đây là **hành động chính duy nhất** của màn.
4. Không có mục tiêu/thanh tiến trình viết hằng ngày ở bất kỳ đâu trên màn
   (AC-1, BR-4).

## 3. Soạn / sửa một mục

- Màn soạn full-screen riêng (không phải bottom sheet, vì nội dung có thể
  dài): ô nhập văn bản tự giãn chiều cao, nút đính ảnh (image picker OS, có
  thể chọn nhiều ảnh) ở thanh công cụ dưới bàn phím, nút "Lưu" ở góc trên
  phải.
- Sửa một mục đã lưu: mở lại đúng màn soạn, tiêu đề đổi thành "Sửa", lưu ghi
  đè bản cũ (AC-3) — không tạo bản sao, không hiện lịch sử phiên bản.
- Không có gợi ý viết bằng AI, không có nút "gợi ý mở đầu" sinh động — nếu
  cần một câu mồi viết, nó phải là **preset tĩnh cố định** (BR-8), hiển thị
  dạng placeholder mờ trong ô nhập (giống hint text thông thường), không phải
  nội dung sinh động mỗi lần mở khác nhau.

## 4. Riêng tư mặc định — không có affordance chia sẻ (R-12)

- Không có icon share, không có menu "..." dẫn tới "xuất"/"chia sẻ"/"copy
  toàn bộ" ở bất kỳ đâu trong danh sách, chi tiết mục, hay màn soạn (AC-6).
  Đây là **vắng mặt bắt buộc**: khi thiết kế menu ngữ cảnh của một mục (nếu
  có, ví dụ menu "..." cho xoá), menu đó chỉ được chứa đúng hành động **Xoá**,
  không được chứa hành động chia sẻ dù ở dạng ẩn/disabled.
- Ảnh đính kèm không xuất hiện ở bất kỳ bề mặt nào khác của app (màn 1, lời
  mời, widget, chân dung, bảng tra) — trừ đường liên kết có chủ đích do
  STORY-007 tạo sau này qua "điểm nhận" ở mục 6, không phải do màn này tự lộ
  ra.

## 5. Xoá — một mục và toàn bộ (AC-11, AC-12, AC-14)

- Xoá một mục: menu ngữ cảnh → "Xoá" → hộp thoại xác nhận trung tính ("Xoá
  mục này?" / Huỷ / Xoá màu `--red`) — không hỏi lý do.
- Xoá toàn bộ: một hàng riêng trong màn cài đặt của Nhật ký (hoặc menu "..."
  ở header) — "Xoá toàn bộ nhật ký" — dẫn tới **một** hộp thoại xác nhận duy
  nhất (không hai bước, không gõ lại chữ "XOÁ" để xác nhận — mức ma sát vừa
  đủ để tránh bấm nhầm nhưng không nhiều bước hơn xoá 1 mục, vì AC-12 yêu cầu
  "một thao tác"). Sau xác nhận: toàn bộ mục + ảnh biến mất ngay, quay về
  trạng thái rỗng lần đầu.
- Không thùng rác ẩn, không "hoàn tác trong 5 giây" kiểu snackbar giữ bản sao
  — xoá là tức thời và vĩnh viễn theo đúng AC-13.

## 6. Điểm nhận cho STORY-007 / STORY-008 (AC-15) — chỉ giao hợp đồng, không vẽ cửa vào

Story này chỉ cần đảm bảo có một cách tạo mục mới **kèm nội dung/ảnh khởi tạo
sẵn** (không phải màn trắng) — về UI, đây chính là màn soạn ở mục 3 nhưng mở
với trường đã điền sẵn (ảnh và/hoặc văn bản gợi ý ban đầu). Không cần vẽ thêm
UI nào khác ở story này; STORY-007/008 tự quyết định UI phía gọi (nút/khối
"đính ảnh" hay "ghi vào nhật ký").

## 7. Trạng thái rỗng (mục 3 của survey)

Trung tính, đúng 1 CTA "Viết điều gì đó" (không lặp lại 2-lời-mời của Phút-1
STORY-001 — đây là quy ước riêng của kho chung, không áp cho nhật ký). Một
dòng mô tả ngắn, giọng trung lập (ví dụ: "Chỉ mình bạn đọc được ở đây."),
không có hình minh hoạ lớn.

## 8. Ranh giới với Sổ tay (AC-17)

Không dùng chung màn, không dùng chung nút "+ tự thêm" với Sổ tay/Hồ sơ kỹ
năng dù cả ba cùng nằm trong khối "Kho riêng của tôi" ở tab "Tôi" — mỗi hàng
menu dẫn tới một màn độc lập hoàn toàn, không có tab con chuyển đổi giữa
chúng.

## Completion
Không có OQ nào chặn phạm vi UX của story này (`requirements.md` →
`## Open Question Impact`: KHÔNG CÓ). Spec trên đầy đủ.
