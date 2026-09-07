# Story Brief: STORY-006 "Trước giờ đi" — checklist tất định (SB-211)

- Actor: người dùng chặng 1, đúng ngày hẹn, sắp ra khỏi nhà.
- Capability: khối mở rộng tự hiện trên chi tiết thẻ *Đã hẹn ngày, hôm nay*,
  sinh checklist **tất định bằng bảng tra tay** từ trường thật của thẻ.
- Business value: phủ J6 — journey duy nhất trước đây bị trống ngoài ý muốn.
- Key business rules: không AI, **không gọi API ngoài** (thời tiết/bản đồ/giao
  thông) · chỉ hiện mục khớp trường thật có trên thẻ · khối trống là hành vi
  chấp nhận được · đúng một hành động chính "Xong hết rồi, đi thôi" (SC-4) ·
  "chia sẻ vị trí" là **một lần** qua OS Share Sheet, không theo dõi liên tục,
  không vi phạm R-1b.
- Key edge/failure case: thẻ thiếu trường → khối ngắn hoặc trống, và app
  **không** được thúc người dùng đi điền thêm.
- Existing system entry/discoverability seed: tự động hiện trên chi tiết thẻ;
  không thêm destination, không phải màn thứ 12.
- Direct AC/OQ anchors: AC1-8 trong `story_master.md`; không có OQ.
- Complexity and why: standard — một bảng tra nhỏ, một điều kiện hiển thị theo
  ngày, và một hành động đóng khối.
- Dependencies: STORY-001.
