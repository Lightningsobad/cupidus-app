# Story Brief: STORY-008 Kịch bản buổi hẹn 3 phần

- Actor: người dùng chặng 1 đã hẹn được ngày và đang chuẩn bị đi.
- Capability: màn kịch bản trước/trong/sau, sinh tất định từ trường của thẻ và
  sổ tay, với ba cửa ra bắt buộc (lời mời / thẻ mới / nhật ký).
- Business value: phủ J5; gỡ nỗi lo "ngồi im không biết nói gì" mà không cần
  người kia tham gia.
- Key business rules: **SC-6 khoá vị trí** — chỉ vào được từ thẻ *Đã hẹn ngày*,
  không có trong menu/tab bar, không route trực tiếp · SC-2 ba cửa ra · không
  AI runtime · **R-1(e) cấm kịch bản thao túng và A/B test** · R-1g kết thúc
  bằng câu để hỏi.
- Key edge/failure case: **J7 cố ý để trống** — phần "trong" là nội dung đọc
  trước khi đi; app tuyệt đối không gửi thông báo hay hiện màn lúc đang hẹn.
  Sổ tay trống → vẫn ra kịch bản mặc định.
- Existing system entry/discoverability seed: hành động "chuẩn bị" trên thẻ *Đã
  hẹn ngày*. Direct URL only acceptable: **NO**.
- Direct AC/OQ anchors: AC1-7 trong `story_master.md`; R-15 áp cho kho kịch
  bản.
- Complexity and why: standard — nội dung preset + mad-libs trên hạ tầng đã
  giao; ràng buộc khó nhất là điều hướng khoá vị trí và giới hạn J7.
- Dependencies: STORY-001, STORY-002, STORY-003, STORY-004.
