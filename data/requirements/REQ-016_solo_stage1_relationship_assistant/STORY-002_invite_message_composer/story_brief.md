# Story Brief: STORY-002 Xuất lời mời — khung nhại + mad-libs

- Actor: người dùng chặng 1 sắp rủ "mối" của mình đi chơi.
- Capability: bottom sheet soạn lời mời tất định (khung nhại + mad-libs) gắn
  trên một thẻ *Đã hẹn ngày*, xuất ra qua OS Share Sheet.
- Business value: gỡ đúng điểm nghẽn "sượng khi rủ"; đồng thời giao **renderer
  dùng chung** mà STORY-007 sẽ tái dùng cho lời cảm ơn sau hẹn.
- Key business rules: không AI ở runtime · cửa từ chối sạch một chạm trong mọi
  lời mời (R-1c) · preset chỉ đùa về **người gửi** (R-1d) · cấm A/B test lời
  nhắn (R-1e) · cấm mọi chỉ báo "đã xem" (R-1b) · lưu dưới dạng **payload
  render được** cho móc SB-125.
- Key edge/failure case: thẻ thiếu trường → lời mời vẫn phải đọc được, bỏ mệnh
  đề thiếu dữ liệu, không lộ placeholder rỗng. Bị từ chối → app không kịch tính
  hoá, không gợi ý nhắn đeo bám.
- Existing system entry/discoverability seed: hành động chính của trạng thái
  *Đã hẹn ngày* trên thẻ ở màn (1). Không có destination riêng.
- Direct AC/OQ anchors: AC1-7 trong `story_master.md`; **OQ-3 ĐÃ ĐÓNG
  2026-09-06 (user) — D-15 → R-15.** Điều kiện ship nội dung nay là **cổng nhập
  chạy được (R-15c)** + truy vết duyệt qua **id bền**, không còn là quyết định
  nhân sự.
- Complexity and why: complex — engine nội dung tất định đa danh mục, kho
  preset cần kiểm duyệt hai lớp, và một ràng buộc lưu trữ (payload SB-125) ảnh
  hưởng tới requirement chặng 1.5 sau này.
- Dependencies: STORY-001.
