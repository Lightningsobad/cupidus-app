# Story Brief: STORY-005 Mồi chuyện — kho câu thường xanh và sự kiện có lịch

- Actor: người dùng chặng 1 đang bí chuyện để nhắn.
- Capability: màn Mồi chuyện với bản A (kho câu thường xanh, dùng tại chỗ,
  không thành thẻ) và bản A+ (sự kiện có lịch → đổi thẳng thành thẻ ở màn 1).
- Business value: phủ J1/J3/J10; gỡ điểm nghẽn "hết chuyện" mà không cần vòng
  lặp xã hội nào.
- Key business rules: **bản B feed tin thật là out of scope** · nguồn sự kiện
  là gói dữ liệu tĩnh + lịch âm tất định, không API ngoài, không AI runtime ·
  SC-1' không được có danh sách riêng · R-1g mọi câu nói về người kia kết thúc
  bằng một câu để hỏi.
- Key edge/failure case: sổ tay còn trống → vẫn phải ra câu mồi dùng được, kèm
  một câu hỏi tại chỗ; không mạng → nội dung vẫn dùng được.
- Existing system entry/discoverability seed: đường vào riêng từ menu chính
  (nhóm CỬA VÀO).
- Direct AC/OQ anchors: AC1-6 trong `story_master.md`; R-15 áp cho kho mồi.
- Complexity and why: standard — chủ yếu là gói nội dung tĩnh + một chuyển đổi
  sang thẻ; hạ tầng sổ tay và kho chung đã có sẵn từ STORY-001/004.
- Dependencies: STORY-001, STORY-004.
