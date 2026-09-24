# Story Master: STORY-013 Lối ra khi im lặng/bị từ chối, và lối quay lại sau vắng

Status: DONE
Complexity: standard
Story-Class: standard
Implementation Lane: mobile (Tech Lead chốt 2026-09-11 — không AC nào cần máy
chủ, và một bản sao máy chủ vi phạm trực tiếp AC-27; xem
`architecture/solution.md` §4 Lane Handoff)
Requirement: REQ-016
Screen: Trạng thái đặc biệt của màn (1) (J11 đóng ngăn, J13 quay lại). Không
phải màn hình thứ 12.
Design-Screen: `j11-dong-ngan-gon-gang`, `ngan-da-hen-ngay-dang-doi`,
`j13-quay-lai-sau-3-thang` (surface `cupid-ch-ng-1`, platform `ios`; phân giải
và khoá trong P4/P5/P6 — VISUAL_FIDELITY: PASS, xem
`visual-fidelity/visual-fidelity-report.md`)
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục A (J11, J13),
B (Lối ra, Lối quay lại), D (SC-5), F (SB-100)

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`,
      `architecture/contract-summary.md`
- [x] Implementation (Development) — kế hoạch: `coding-plan/master-plan.md`
      (P1..P6, một lane Mobile, tuần tự)
- [x] Review (Reviewer) — `review/review-report.md`, Outcome: DEFERRED_ONLY

## Depends On
- STORY-001 — "đóng ngăn gọn gàng" tác động lên thẻ trong kho chung.
- STORY-004 — sổ tay và hồ sơ kỹ năng phải sống sót qua lối ra.

## User Story
Là người vừa bị từ chối hoặc vừa bỏ app ba tháng, tôi muốn có một cách đóng lại
gọn gàng và một cách quay lại không bị trách móc, để app không trở thành nơi
tôi sợ mở.

## In Scope
1. **SB-64 "đóng ngăn gọn gàng" (J11)**: một thao tác đóng lại toàn bộ những gì
   gắn với người này — thẻ, lời mời, chân dung — mà không xoá tài sản chung.
2. **SB-65 "tắt hồi tưởng"**: sau khi đóng ngăn, app ngừng hiện lại ký ức, ảnh,
   và nhắc nhở liên quan tới người đó.
3. **Giữ lại tài sản không gắn người cụ thể**: hồ sơ kỹ năng "phiên bản tôi",
   danh sách địa điểm, và những mục sổ tay không gắn với một người vẫn giữ
   nguyên cho lần sau.
4. **SB-100 màn quay lại không trách móc (J13)**: mở lại sau thời gian dài vắng
   → màn hỏi "mở lại từ đâu", không đếm ngày vắng, không nhắc chuỗi bị đứt.
5. **Xoá sạch một thao tác** ngay tại màn quay lại: một nút xoá toàn bộ dữ liệu
   chặng 1, không phải đi tìm trong cài đặt.
6. **SC-5 — không ngõ cụt**: mọi trạng thái, kể cả "tạch", đều có cửa ra.

## Out of Scope
- Xoá tài khoản / dữ liệu ngoài phạm vi chặng 1.
- Bất kỳ lời nhắc quay lại, chuỗi nhắc, hay email/thông báo "chúng tôi nhớ bạn"
  nào — mâu thuẫn với "không phạt khi im lặng".
- Đếm ngày vắng, chuỗi bị đứt, streak — R-1(f) cấm.
- Kịch tính hoá việc bị từ chối, hoặc gợi ý nhắn lại kiểu đeo bám — R-1c cấm.
- Lưu trữ ẩn dữ liệu đã "xoá sạch".
- Ghi lý do đóng ngăn dưới dạng đánh giá con người ("người này vô tâm") — R-1f
  cấm.

## Acceptance Criteria
1. Given người dùng có thẻ, lời mời, và dữ liệu gắn với một người cụ thể, when
   họ chọn "đóng ngăn gọn gàng", then trong **một** thao tác xác nhận, toàn bộ
   phần gắn với người đó được đóng lại và không còn hiện trong luồng thường
   ngày.
2. Given đã đóng ngăn, when người dùng dùng app những ngày sau, then app
   **không** hiện lại ký ức, ảnh, hay nhắc nhở liên quan tới người đó (SB-65).
3. Given đã đóng ngăn, when người dùng mở màn Hồ sơ kỹ năng và danh sách địa
   điểm, then chúng vẫn còn nguyên vì không gắn với người cụ thể nào.
4. Given app phản hồi việc bị từ chối hoặc đóng ngăn, when người dùng xem, then
   không có hiệu ứng kịch tính, không có lời trêu, không có gợi ý nhắn lại
   (R-1c).
5. Given người dùng không mở app trong một thời gian dài, when họ mở lại, then
   màn quay lại hỏi "mở lại từ đâu", và **không** hiển thị số ngày vắng, chuỗi
   bị đứt, hay bất kỳ lời trách móc nào (SB-100).
6. Given màn quay lại đang hiện, when người dùng muốn xoá hết, then có một nút
   xoá sạch ngay tại đó, và sau khi xác nhận, dữ liệu chặng 1 bị xoá thật, không
   giữ bản sao ẩn.
7. Given người dùng đang ở bất kỳ trạng thái nào, kể cả sau khi đóng ngăn, when
   họ xem màn (1), then luôn có ít nhất một đường đi tiếp — không trạng thái nào
   là ngõ cụt (SC-5).

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — màn (1), sổ tay, hồ sơ kỹ năng.
- Điểm vào: "đóng ngăn gọn gàng" là một hành động phụ trên màn (1); màn quay
  lại tự hiện khi mở app sau thời gian vắng dài.

## Dependencies
- Depends on: STORY-001, STORY-004.
- Không yêu cầu story tương lai: xác nhận — nếu STORY-002/008/009 đã giao,
  hành động đóng ngăn bao luôn dữ liệu của chúng; nếu chưa, nó chỉ bao phần đã
  tồn tại.

## Open Question Impact
- L45: story này là một trong ba story chịu tải cho định vị "kho tài sản" —
  điều làm chặng 1 không phải phòng chờ chính là việc tài sản không gắn người
  kia **sống sót** qua lối ra J11.
