# UX Spec: STORY-002 Xuất lời mời — khung nhại + mad-libs

Requirement: REQ-016 · Story-Class: shared-foundation · Depends On: STORY-001
Nguồn bắt buộc: `story_master.md`, `requirements/requirements.md`,
`../ux/requirement-ux-survey.md`. `DESIGN_SOURCE_NOT_DETECTED` bình thường ở
giai đoạn này — spec dùng luật đo được.

## 1. Vị trí và cách mở

Bottom sheet, **không phải màn/route riêng** (AC-3). Mở từ bên trong luồng
"Chuẩn bị" mà nhãn hành động chính "Chuẩn bị" của thẻ *Đã hẹn ngày* dẫn tới
(STORY-001 mục 2, bảng SC-4). Trong màn "Chuẩn bị", "Xuất lời mời" là **một
lựa chọn trong danh sách lựa chọn** (cùng cấp với các lựa chọn khác mà
STORY-006/STORY-008 sẽ thêm sau này), không phải nút thay thế nhãn "Chuẩn
bị". Bottom sheet bo góc trên `--r-sheet` (28px), chiều cao mặc định ~70% màn
hình, kéo giãn được tới full-screen, kéo xuống để đóng — không mất dữ liệu
thẻ khi đóng (BR-3).

## 2. Bố cục bottom sheet, từ trên xuống

1. Tay cầm kéo (grab handle) + tiêu đề "Soạn lời mời" (`card title 22pt/600`).
2. **Dải chọn khung nhại** — hàng chip cuộn ngang, mỗi chip = tên một khung
   nhại (ví dụ "Rạp phim", "Cà phê nhanh"). Chip đang chọn: nền `--pink` nhạt
   (khác cường độ với hành động chính để không lẫn CTA), chữ `body 17pt/600`.
   Chip chưa chọn: viền mỏng, chữ `colorTextMuted`. Đổi chip render lại ngay
   nội dung bên dưới (AC-5), không có nút "áp dụng" phụ.
3. **Khối xem trước** — thẻ nội dung đã render, bo góc `--r-card`, đủ rộng để
   đọc toàn văn không cuộn ngang; văn bản `body 17pt`, cho phép nhiều dòng.
   Đây là vùng **sửa được trực tiếp** (AC-7): chạm vào khối chuyển thành text
   field chỉnh sửa tại chỗ (inline edit), không mở màn soạn thảo riêng.
4. **Dòng cửa từ chối** hiển thị như một câu trong chính văn bản lời mời (nó
   là một phần của mad-libs, không phải UI phụ tách rời) — không cần khối
   thị giác riêng, nhưng QA/preview text phải luôn thấy câu này nằm trong
   khối xem trước (đối chiếu AC-10).
5. **Hành động chính của bottom sheet**: pill full-width, nền `--grad`, nhãn
   "Chia sẻ" — mở OS Share Sheet (AC-16). Đây là hành động chính của **bottom
   sheet**, tách biệt với hành động chính của **thẻ** ("Chuẩn bị") — hai tầng
   khác nhau, không mâu thuẫn AC-2/SC-4.
6. Không có nút "Gửi" nào khác ngoài "Chia sẻ" qua Share Sheet — không có ô
   nhập số điện thoại/liên hệ, không có icon Zalo/Messenger riêng (AC-16,
   BR-đối chiếu "không tích hợp kênh gửi trong app").

## 3. Trường thiếu dữ liệu (AC-6)

Khi thẻ thiếu trường (không có địa điểm/giờ), renderer bỏ hẳn mệnh đề chứa
trường đó khỏi câu, không để lại khoảng trống hay dấu ngoặc. Ràng buộc trình
bày: preset phải được soạn ở dạng nhiều câu ngắn rời (mỗi câu mang tối đa 1-2
trường) để việc bỏ một câu không làm gãy ngữ pháp câu còn lại — đây là ràng
buộc nội dung/preset, ghi lại ở đây để Tech Lead và đội nội dung (R-15) biết
khi thiết kế khuôn preset.

## 4. Sau khi xuất — quay lại thẻ (AC-13, R-1b)

Đóng bottom sheet quay về chi tiết thẻ (không quay về danh sách). Chi tiết
thẻ lúc này hiện toggle "Chưa trả lời / Đã trả lời" đã định nghĩa ở
`STORY-001/ux/uiux-spec.md` mục 2 — story này **không vẽ lại** toggle, chỉ
đảm bảo nó xuất hiện ngay sau lần xuất lời mời đầu tiên nếu thẻ chưa có cờ đó.
Không thêm bất kỳ UI đếm số lần đã xuất lời mời, không thêm biểu tượng "đã
gửi" chồng lên toggle sẵn có.

## 5. Phản hồi từ chối/chưa trả lời (AC-12, R-1c)

Không có màn hình hay hiệu ứng riêng cho "bị từ chối" — vì app không bao giờ
biết người kia đã từ chối, chỉ biết người dùng tự đánh dấu "chưa trả lời".
Khi người dùng bấm "Chưa trả lời": không toast, không animation kịch tính,
chỉ đổi trạng thái chip trong im lặng (giống đổi bất kỳ cờ nào khác trong
app). Không hiện gợi ý "thử nhắn lại" ngay sau đó.

## 6. Renderer đa danh mục (AC-20..AC-22) — chỉ ảnh hưởng UI ở điểm sau

Về mặt UX, "danh mục preset" là một tham số ẩn với người dùng — người dùng
chỉ thấy dải chip khung nhại thuộc **đúng một** danh mục đang hoạt động trong
ngữ cảnh mở sheet (ví dụ: mở từ "Chuẩn bị" → danh mục "lời mời"; STORY-007 mở
từ khối "Cảm ơn" → danh mục "lời cảm ơn sau hẹn"). Bottom sheet không hiện bộ
chọn danh mục cho người dùng chọn tay — danh mục do ngữ cảnh mở sheet quyết
định. Đây là ràng buộc UX cho AC-21: STORY-007 chỉ cần gọi lại đúng bottom
sheet này với danh mục khác, giao diện không đổi cấu trúc.

## 7. Kiểm duyệt nội dung (R-15 — cổng nhập nội dung, không chặn phần UI)

Khi kho preset chưa qua kiểm duyệt hai lớp, dải chip khung nhại vẫn hiện đầy
đủ nhưng dùng **nội dung placeholder nội bộ** rõ ràng đánh dấu là nội bộ
(không hiển thị cho người dùng thật) — đây là hành vi build/QA, không phải
trạng thái UI người dùng cuối cần thiết kế riêng. Không cần màn "đang chờ
duyệt nội dung" cho người dùng.

## 8. Ranh giới với STORY-001 (không đổi hợp đồng)

- Không thêm hành động chính thứ hai lên thẻ (AC-2) — xác nhận lại quyết định
  đã khoá ở `STORY-001/ux/uiux-spec.md` bảng SC-4.
- Không xuất hiện trong dải lối-vào-nhanh 3 ô hay bất kỳ menu nào (AC-3).

## Completion
Điều kiện ship nội dung preset thật (mục 7) nay là R-15: đi qua cổng nhập nội
dung chạy được (R-15c) và có truy vết duyệt qua id bền — không còn chờ user
chỉ định người duyệt lớp 2. Không quyết định bố cục/tương tác nào ở trên bị
chặn. Toàn bộ UX của story có thể xây và verify bằng placeholder nội bộ.
