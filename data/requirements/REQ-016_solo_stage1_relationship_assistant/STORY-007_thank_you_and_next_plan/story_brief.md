# Story Brief: STORY-007 "Cảm ơn + chốt việc kế tiếp" (SB-212)

- Actor: người dùng chặng 1, sáng hôm sau một buổi hẹn.
- Capability: khối mở rộng một-lần trên thẻ *Đã đi rồi* — soạn lời cảm ơn (tái
  dùng renderer STORY-002), đính ảnh từ nhật ký, và chốt việc kế tiếp thành một
  thẻ mới.
- Business value: phủ J9; giữ đà sau một buổi hẹn vui, hướng ra ngoài (đối lập
  J8 hướng vào trong).
- Key business rules: **kích hoạt đúng một lần, bỏ qua thì thôi hẳn** — không
  lặp, không phạt im lặng · bắt buộc tái dùng renderer STORY-002, không xây
  engine mới · cấm đo lường người kia đã đọc chưa (R-1b) · phần chốt việc kế
  tiếp là tuỳ chọn.
- Key edge/failure case: chưa có ảnh nào ở nhật ký → phần đính ảnh không hiện,
  khối vẫn dùng được. Người dùng bỏ qua → không nhắc lại, không dấu trách móc.
- Existing system entry/discoverability seed: tự động trên chi tiết thẻ; không
  thêm destination, không phải màn thứ 12.
- Direct AC/OQ anchors: AC1-7 trong `story_master.md`; R-15 áp cho danh mục
  preset mới.
- Complexity and why: standard — ba phần đều tái dùng hạ tầng đã giao; phần
  khó nhất là quy tắc kích hoạt một lần.
- Dependencies: STORY-001, STORY-002, STORY-003, STORY-005.
