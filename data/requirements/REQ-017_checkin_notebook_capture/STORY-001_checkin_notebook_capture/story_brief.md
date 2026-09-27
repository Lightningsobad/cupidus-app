# Story Brief: STORY-001 Ghi điều mới biết về người ấy vào sổ tay ngay trên màn check-in 23h

- Actor: người dùng solo chặng 1, vừa về sau một buổi hẹn.
- Capability: một lời hỏi-tại-chỗ tuỳ chọn "Hôm nay biết thêm gì về người ấy?"
  trên màn check-in 23h; người dùng gõ một ý và tự chọn loại (sở thích / sự
  kiện-dịp); ý đó thành một mục sổ tay mang xuất xứ "từ buổi hẹn <thẻ>", sửa/xoá
  được ở màn Sổ tay sẵn có.
- Business value: sổ tay đầy lên từ trải nghiệm thật đúng lúc giàu thông tin
  nhất, nên gợi ý quà / mồi chuyện / kịch bản bớt chung chung.
- Vì sao chỉ một story: lời hỏi trên check-in và phần xuất xứ + sửa/xoá ở Sổ tay
  là hai bước của cùng một workflow; tách ra thì phần nào cũng không quan sát được
  một mình. Hai bề mặt là thứ tự pha trong coding plan, không phải ranh giới story.
- Key business rules: R-1f chỉ sở thích + sự kiện, không đánh giá, không xuất ·
  SC-3 hỏi-tại-chỗ, tuỳ chọn, một mục một lần · câu nhật ký **không bao giờ** sang
  sổ tay (O-1a loại) · app không tự đoán loại/nội dung (R-7, O-1c hoãn) · R-15 câu
  hỏi + nhãn xuất xứ là dữ liệu có id bền qua cổng nhập · thẻ chỉ đọc (BR-12) ·
  widget/thông báo không hiện nội dung sổ tay (BR-11) · không màn mới (O-3).
- Key edge/failure case: tên thẻ không đọc được hoặc thẻ bị xoá/đóng ngăn → xuất
  xứ suy biến "từ một buổi hẹn", mục không mất; ghi sổ tay lỗi → người dùng thấy
  và thử lại được, nhật ký/ảnh không mất, không ghi đôi; lưu lặp không tạo mục trùng.
- Existing system entry/discoverability seed: màn check-in modal 23h (REQ-016
  STORY-012 AC-16, chỉ tới từ nhắc 23h) và màn Sổ tay (REQ-016 STORY-004). Không
  điểm vào mới. Canvas: `23h-vua-ve-j8`, chip "+ ghi vào sổ tay".
- Direct AC/OQ anchors: AC1-15 trong `story_master.md`; OQ-1 (STORY-012 AC-19)
  và OQ-2 RESOLVED 2026-09-27 (`../req_master.md` `## User Decisions`), không
  chặn gì.
- Complexity and why: standard — một năng lực gói gọn trên hai bề mặt sẵn có, thêm
  một thuộc tính xuất xứ cho mục sổ tay và một mục nội dung; không màn mới, không
  luồng mới. Rủi ro chính là ranh giới riêng tư nhật ký ↔ sổ tay và hợp đồng
  AC-19 của một story đã DONE, cả hai đã thành AC.
- Dependencies: REQ-016 STORY-003, STORY-004, STORY-012 (DONE).
