# Story Brief: STORY-003 Nhật ký riêng

- Actor: người dùng chặng 1, viết cho chính mình.
- Capability: màn nhật ký độc lập — viết/sửa/xoá mục (chữ + ảnh), riêng tư mặc
  định, xoá sạch được trong một thao tác.
- Business value: một trong bốn màn KHO; là cửa ra "hướng vào trong" (J8) mà
  kịch bản buổi hẹn và lời cảm ơn sau hẹn sẽ dùng lại.
- Key business rules: R-12 riêng-tư-mặc-định, xoá được · **không có chức năng
  chia sẻ/xuất** · không streak, không mục tiêu viết hằng ngày (R-1(f)).
- Key edge/failure case: xoá toàn bộ phải thật sự xoá cả ảnh đính kèm, không
  giữ bản sao ẩn.
- Existing system entry/discoverability seed: đường vào trực tiếp từ menu chính
  (nhóm KHO), không phải khoá vị trí.
- Direct AC/OQ anchors: AC1-5 trong `story_master.md`; không có OQ.
- Complexity and why: standard — CRUD một thực thể cộng ràng buộc riêng tư và
  xoá sạch; không phụ thuộc story nào.
- Dependencies: NONE.
