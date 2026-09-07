# Story Master: STORY-002 Xuất lời mời — khung nhại + mad-libs

Status: TODO
Complexity: complex
Story-Class: shared-foundation
Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
Requirement: REQ-016
Screen: Xuất lời mời — hành động (11), bottom sheet gắn trên một thẻ ở màn (1).
Không chiếm một destination riêng.
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục C.11, F (C5)

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [ ] Architecture (Tech Lead)
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-001 — bottom sheet gắn trên một thẻ đang tồn tại trong kho chung.

## User Story
Là người muốn rủ "mối" của mình đi chơi, tôi muốn app soạn giúp một lời mời
nghe có duyên chứ không sượng, để tôi copy sang Zalo gửi mà không phải tự nghĩ
câu chữ.

## In Scope
1. Bottom sheet "xuất lời mời" mở từ hành động chính của một thẻ ở trạng thái
   *Đã hẹn ngày* (hoàn thiện hành động chính SC-4 mà STORY-001 để lại).
2. Bộ soạn nội dung tất định: **khung nhại** (nhại một định dạng quen thuộc) +
   **mad-libs** (điền chỗ trống bằng trường thật của thẻ). Không AI ở runtime.
3. Kho preset lời mời có phân loại; **renderer dùng chung**, thiết kế sẵn để
   phục vụ danh mục preset thứ hai ("lời cảm ơn sau hẹn") do STORY-007 thêm
   vào — chỉ thiết kế renderer đa danh mục, không ship danh mục thứ hai ở đây.
4. **Cửa từ chối sạch (R-1c/R-1d)**: mọi lời mời sinh ra phải chứa sẵn một
   đường từ chối một chạm cho người nhận (ví dụ "bận thì nhắn 'để hôm khác'
   nhé"). App không kịch tính hoá lời từ chối.
5. **Nội dung preset chỉ được đùa về NGƯỜI GỬI**, không đùa về người nhận
   (R-1d).
6. Đầu ra là vật phẩm người dùng tự copy/chia sẻ sang Zalo qua OS Share Sheet.
   Không gửi thay người dùng, không có kênh gửi trong app.
7. **Móc SB-125**: vật phẩm lời mời phải được lưu dưới dạng **payload render
   được** (dữ liệu có cấu trúc + id template), không phải chuỗi text đã bẹp, để
   chặng 1.5 không phải thiết kế lại.
8. Kiểm duyệt nội dung hai lớp (SB-123) trước khi kho preset vào bản build
   người dùng thật.

## Out of Scope
- Danh mục preset "lời cảm ơn sau hẹn" — STORY-007 thêm vào renderer này.
- Link hai chiều để người kia trả lời trong app — **chặng 1.5, ngoài phạm vi**.
  Story này chỉ để lại payload, không xây kênh phản hồi.
- A/B test lời nhắn, xếp hạng hiệu quả lời mời — **R-1(e) cấm nguyên vẹn**.
- Bất kỳ đo lường nào về việc người nhận đã đọc/đã xem (R-1b).
- Vào từ kịch bản buổi hẹn — STORY-008 thêm cửa vào thứ hai.

## Acceptance Criteria
1. Given một thẻ ở trạng thái *Đã hẹn ngày*, when người dùng bấm "xuất lời
   mời", then bottom sheet mở ra với ít nhất một lời mời đã soạn sẵn, các chỗ
   trống đã điền bằng trường thật của thẻ (tên hoạt động, ngày, địa điểm).
2. Given thẻ thiếu một số trường, when lời mời được soạn, then app vẫn ra một
   lời mời đọc được (bỏ mệnh đề thiếu dữ liệu), không hiện placeholder rỗng.
3. Given một lời mời bất kỳ được sinh ra, when đọc toàn văn, then nó chứa một
   đường từ chối một chạm cho người nhận, và mọi câu đùa trong đó nhắm vào
   **người gửi**, không nhắm vào người nhận (R-1c/R-1d).
4. Given người dùng đã chọn một lời mời, when họ bấm chia sẻ, then vật phẩm đi
   ra qua OS Share Sheet và app **không** tự gửi tới bất kỳ ai.
5. Given một lời mời đã xuất, when nó được lưu lại, then bản lưu là payload có
   cấu trúc render lại được (id template + các giá trị đã điền), không phải
   chuỗi text đã bẹp (SB-125).
6. Given người dùng quay lại thẻ sau khi xuất lời mời, when họ cập nhật tình
   hình, then lựa chọn duy nhất là *đã trả lời / chưa trả lời* do họ tự bấm;
   app không hiển thị và không suy ra bất kỳ chỉ báo hành vi nào của người kia
   (R-1b).
7. Given người dùng đánh dấu "chưa trả lời" hoặc bị từ chối, when app phản hồi,
   then không có hiệu ứng kịch tính, không có lời trêu, không có gợi ý nhắn
   lại lần hai kiểu đeo bám (R-1c).

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — thẻ ở màn (1) do STORY-001 giao.
- Điểm vào: hành động chính của trạng thái *Đã hẹn ngày*. Không chiếm
  destination riêng, không xuất hiện trong menu chính (đúng mô tả hành động
  (11)).

## Dependencies
- Depends on: STORY-001 (thẻ trong kho chung để gắn bottom sheet).
- Không yêu cầu story tương lai: xác nhận — STORY-007 chỉ **thêm** một danh mục
  preset vào renderer đã giao, không sửa hành vi của story này.

## Open Question Impact
- OQ-3 (ai duyệt kho nội dung preset) — **ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15
  → luật R-15** (`req_master.md` mục 15). **Không còn chặn story này vào
  delivery.** Đây vẫn là story đầu tiên có kho preset, nên lược đồ và cổng nhập
  nó giao là **tiền lệ** cho mọi story preset sau. Thành ràng buộc: preset,
  khung nhại, biến mad-libs là **dữ liệu có schema + id bền** dùng chung với
  payload SB-125, đổi nguồn sang CMS không sửa code (R-15a); **N là thuộc tính
  dữ liệu** — hành vi hết-tập khi đổi khung nhại phải đúng với mọi N chứ không
  phải cho seed 10 mục (R-15b); R-1b/R-1c/R-1d/R-1e/R-10, chống tâng bốc, cấm
  %, cấm streak cưỡng chế ở **cổng nhập chạy được** làm hỏng bản dựng (R-15c).
  Kiểm duyệt hai lớp (SB-123) giữ cho chất lượng biên tập, không còn là cơ chế
  cưỡng chế luật bất biến. Chi tiết: AC-23..AC-29, BR-14..BR-16.
