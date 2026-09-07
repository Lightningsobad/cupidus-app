# Story Brief: STORY-013 Lối ra khi im lặng/bị từ chối, và lối quay lại sau vắng

- Actor: người dùng chặng 1 vừa bị từ chối (J11) hoặc vừa quay lại sau nhiều
  tháng vắng (J13).
- Capability: "đóng ngăn gọn gàng" một thao tác + tắt hồi tưởng, giữ lại tài
  sản không gắn người cụ thể; màn quay lại không trách móc kèm nút xoá sạch một
  thao tác.
- Business value: giữ app khỏi trở thành "nơi tôi sợ mở"; đồng thời là bằng
  chứng cụ thể nhất cho định vị "kho tài sản" — tài sản sống sót qua lối ra.
- Key business rules: SC-5 không ngõ cụt · R-1c không kịch tính hoá từ chối,
  không gợi ý nhắn đeo bám · R-1(f) không đếm ngày vắng, không chuỗi bị đứt ·
  R-1f không ghi đánh giá con người làm lý do đóng ngăn · xoá sạch phải xoá
  thật, không bản sao ẩn.
- Key edge/failure case: đóng ngăn không được xoá nhầm hồ sơ kỹ năng "phiên bản
  tôi" và danh sách địa điểm — đó là tài sản cho lần sau.
- Existing system entry/discoverability seed: hành động phụ trên màn (1); màn
  quay lại tự hiện sau thời gian vắng dài.
- Direct AC/OQ anchors: AC1-7 trong `story_master.md`; L45 — story chịu tải cho
  định vị "kho tài sản".
- Complexity and why: standard — chủ yếu là quy tắc phạm vi dữ liệu (cái gì
  đóng, cái gì giữ) và ngôn ngữ màn quay lại.
- Dependencies: STORY-001, STORY-004.
