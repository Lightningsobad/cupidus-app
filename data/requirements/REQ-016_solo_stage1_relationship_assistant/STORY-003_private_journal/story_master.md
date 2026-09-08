# Story Master: STORY-003 Nhật ký riêng

Status: TODO
Complexity: standard
Story-Class: standard
Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
Requirement: REQ-016
Screen: Nhật ký riêng — màn (4) trong nhóm KHO, có đường vào trực tiếp từ menu
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục C.4, F (C6)

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- NONE.

## User Story
Là người đang để ý một ai đó, tôi muốn ghi lại cảm xúc và ảnh của riêng mình mà
chắc chắn không ai đọc được, để tôi dám viết thật.

## In Scope
1. Màn nhật ký độc lập: viết, sửa, xoá một mục nhật ký (chữ + ảnh).
2. **Riêng tư mặc định** (R-12): mọi mục mặc định chỉ mình người dùng thấy;
   không có chế độ chia sẻ, không có nút xuất, không có liên kết ra ngoài.
3. **Xoá được**: xoá từng mục và xoá toàn bộ nhật ký, không giữ bản sao ẩn.
4. Nhật ký là một trong ba cửa ra hợp lệ của các luồng khác (SC-2) — story này
   giao **màn và điểm nhận** để story sau (STORY-007, STORY-008) đẩy nội dung
   sang.
5. Trạng thái rỗng trung tính, không thúc giục viết mỗi ngày, không streak
   (R-1(f) cấm streak).

## Out of Scope
- Nhắc nhở "23h vừa về tới nhà chưa?" (SB-85) — STORY-012.
- Ký ức/ảnh gắn với thẻ *Đã thành kỷ niệm* — thuộc tính thẻ ở STORY-001, story
  này chỉ giao nhật ký độc lập.
- Đính ảnh từ nhật ký vào lời cảm ơn — STORY-007.
- Cửa ra "ghi vào nhật ký" từ kịch bản buổi hẹn — STORY-008.
- Bất kỳ hình thức chia sẻ, xuất file, hoặc backup ra ngoài thiết bị mà người
  dùng không chủ động bật.

## Acceptance Criteria
1. Given người dùng mở màn nhật ký lần đầu, when màn hiện ra, then trạng thái
   rỗng trung tính, không có mục tiêu viết hằng ngày, không có streak, không có
   bất kỳ chỉ số đếm chuỗi ngày nào.
2. Given người dùng viết một mục nhật ký kèm ảnh, when họ lưu, then mục được
   giữ lại và chỉ hiển thị trong màn nhật ký của chính họ.
3. Given một mục nhật ký bất kỳ, when người dùng tìm cách chia sẻ hoặc xuất nó,
   then app **không** cung cấp bất kỳ chức năng chia sẻ/xuất nào.
4. Given người dùng xoá một mục, when xác nhận, then mục biến mất và không truy
   hồi được từ trong app.
5. Given người dùng chọn "xoá toàn bộ nhật ký", when xác nhận, then toàn bộ mục
   và ảnh đính kèm bị xoá trong một thao tác.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — màn mới.
- Điểm vào: đường vào trực tiếp từ menu chính (nhóm KHO). Không phải màn khoá
  vị trí.

## Dependencies
- Depends on: NONE. Có thể giao song song với STORY-001.
- Không yêu cầu story tương lai: xác nhận — nhật ký dùng được trọn vẹn một
  mình; STORY-007/008 chỉ thêm cửa vào.

## Open Question Impact
NONE.
