# Story Brief: STORY-001 Danh sách việc-cần-làm — kho chung và vòng đời thẻ

- Actor: người dùng chặng 1 (đã có một "mối" cụ thể, đối phương chưa cài app).
- Capability: màn "về nhà" chứa mọi ý tưởng hẹn hò dưới dạng thẻ có cấu trúc,
  lọc theo 4 trạng thái, bắt ý tưởng trong 5 giây.
- Business value: đây là **kho chung duy nhất** (SC-1') mà 12 story còn lại đổ
  thẻ vào; nó cũng là câu trả lời cụ thể cho định vị "kho tài sản, không phải
  phòng chờ" (OQ-18/L45).
- Key business rules: SC-1' một kho duy nhất · SC-4 đúng một hành động chính
  mỗi trạng thái · SC-5 không ngõ cụt · R-1b chỉ *đã trả lời / chưa trả lời*
  do user tự đánh dấu, cấm mọi chỉ báo hành vi người kia.
- Key edge/failure case: **Phút 1 — màn rỗng**. Đây là rủi ro chính (L46).
  Không được dùng form onboarding; chỉ hai lời mời một chạm.
- Existing system entry/discoverability seed: màn có đường vào trực tiếp từ
  menu chính (không phải nhóm khoá vị trí).
- Direct AC/OQ anchors: AC1-7 trong `story_master.md`; OQ-2 phần UI giao UX ở
  story này.
- Complexity and why: complex — mô hình dữ liệu thẻ nền tảng cho cả
  requirement, 4 trạng thái với chuyển tiếp, nhập liệu không ma sát, và trạng
  thái rỗng phải thiết kế đúng.
- Dependencies: NONE.
