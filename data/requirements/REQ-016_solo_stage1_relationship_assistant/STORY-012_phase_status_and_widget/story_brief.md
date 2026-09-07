# Story Brief: STORY-012 Trạng thái theo pha, widget, và bộ đếm "của cải đang lớn"

- Actor: người dùng chặng 1 với tần suất thật 1-2 lời mời một tuần.
- Capability: pha theo thời gian trên màn (1) và widget hệ điều hành (đang đợi
  / sắp hẹn / đúng ngày hẹn / khoảng lặng), đếm ngược, nhắc "23h về tới nhà
  chưa?", "món quà đang lớn", nhỏ giọt, và bộ đếm "của cải đang lớn".
- Business value: giải bài toán "được nhớ tới đúng lúc cần" mà không tối ưu
  DAU; bộ đếm của cải là mặt user-visible duy nhất của việc nhận diện cột mốc
  J12 trong REQ-016.
- Key business rules: **R-1(f) cấm streak / chuỗi ngày / bảng xếp hạng** ·
  **R-1b widget chỉ phản ánh thẻ của người dùng, không phản ánh người kia** ·
  D-1 nhắc nhẹ, không báo thức thật, tắt được toàn bộ · không nhắc lại khi bỏ
  qua · không nội dung trách móc khi vắng lâu.
- Key edge/failure case: người dùng tắt thông báo → app vẫn dùng được đầy đủ.
  Vắng nhiều ngày → không đếm ngày vắng, không chuỗi bị đứt.
- Existing system entry/discoverability seed: widget do người dùng tự thêm theo
  cơ chế OS; các pha còn lại tự hiện trong màn (1).
- Direct AC/OQ anchors: AC1-8 trong `story_master.md`; L45 — story chịu tải cho
  định vị "kho tài sản".
- Complexity and why: complex — bề mặt widget của hệ điều hành, lịch nhắc theo
  pha, và nhiều quy tắc "không được làm" dễ vi phạm.
- Dependencies: STORY-001 (STORY-003 và STORY-006 là tuỳ chọn làm giàu, không
  chặn).
