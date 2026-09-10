# Coding Agent Guide – STORY-002 Xuất lời mời

## 1. Start Here

Luôn đọc:

- `master-plan.md`
- đúng file `phase-Px-*.md` được giao

## 2. Context Loading Rule

Chỉ đọc các artifact được nêu trong `Primary Inputs Summary` của phase đang làm.
Không nạp thêm file UX, kiến trúc, hay system memory không liên quan.

- Nếu phase nêu shared interface, đọc artifact của interface đó trước.
- OQ-3 đã đóng ngày 2026-09-06 bằng D-15 → R-15a/R-15b/R-15c. Story này **không
  còn OQ mở**; ràng buộc kế thừa từ D-15 đã được viết thành AC-25..AC-29, đọc ở
  `../requirements/`.
- Hợp đồng liên phase nằm ở `../architecture/contract-summary.md`. Đó là nguồn
  sự thật cho tên cột, tên trường, `schema_id`, và quy ước khoá asset — không
  suy ra tên từ trí nhớ hay từ file phase.

## 3. Execution Rule

1. Chỉ làm phase đã có mọi dependency ở `DONE`.
2. Chỉ làm phase thuộc lane của mình. Story này có một lane duy nhất: Mobile.
3. Cập nhật `## 7. Status` của phase ngay khi trạng thái đổi.
4. Dừng khi phase kế tiếp thuộc owner khác.
5. Không mở rộng phạm vi phase sang migration, rollout, hay vùng hợp đồng không
   được giao.
6. Dừng và báo lên nếu công việc đòi một quyết định OQ mà phase không tự giải.

Thứ tự rẻ nhất khi chỉ có một worker: P1, P3, P2, P4, P5, P6. P1 và P3 là hai
gốc độc lập nếu chạy song song được.

## 4. Story Invariants

Những điều dưới đây đúng cho **mọi** phase, kể cả khi file phase không nhắc lại:

- Không AI runtime, không gọi mạng để sinh nội dung. Mọi thứ là tất định,
  schema-driven.
- Câu chữ lời mời nằm trong asset JSON, không nằm trong `mobile/lib/` (R-15a).
- Luật kiểm duyệt bất biến nằm trong Dart ở `lib/`, không nằm trong asset —
  nếu không, CMS ngoài repo sẽ tự nới luật của chính nó (R-15c).
- Số lượng preset là thuộc tính dữ liệu. Không hằng số đếm, không chỉ báo tiến
  độ, không hiển thị số lượng ở bất kỳ đâu (R-15b/AC-26/AC-27).
- Mọi lời mời sinh ra phải mang một câu mở đường từ chối; đùa chỉ nhắm vào
  người gửi, không bao giờ nhắm người nhận (R-1c/R-1d).
- Kênh gửi duy nhất là OS Share Sheet. Không ô nhập người nhận, không kênh gửi
  trong app, không đọc `ShareResult` (AC-16/R-1b).
- Không read receipt, không theo dõi trả lời, không A/B test câu chữ, không API
  đếm/tổng hợp payload (R-1b/R-1e/AC-14).
- Vật phẩm lưu lại là payload có cấu trúc (`preset_id` + `filled_values`), không
  phải văn bản đã bẹt (SB-125/AC-17).
- Migration chỉ được cộng thêm. Bảng activity card và journal là dữ liệu chỉ tồn
  tại trên máy người dùng, không có bản trên server: recreate là mất trắng.
- Chỉ ship danh mục `invite`. Không tạo trước gói danh mục thứ hai (AC-22) —
  STORY-007 thêm nó sau bằng đúng schema và đúng cổng, không sửa code.

## 5. Plan Update Rule

- Cập nhật status, ghi chú thuộc phase, và bằng chứng test tại chỗ.
- Ghi bằng chứng test vào `test-results.md` cùng thư mục.
- Không thiết kế lại toàn bộ plan trong lúc cài đặt.
- Báo lên nếu plan sai về bản chất, ví dụ hợp đồng ở `contract-summary.md` mâu
  thuẫn với mã nguồn thật.
