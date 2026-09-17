# Story Master: STORY-012 Trạng thái theo pha, widget, và bộ đếm "của cải đang lớn"

Status: TODO
Complexity: complex
Story-Class: standard
Implementation Lane: mobile (ranh giới đã chốt 2026-09-11 — `architecture/solution.md` §1 Key Discovery: không có lane backend, xem STORY-001 contract-summary §1 + system memory R9)
Requirement: REQ-016
Screen: Trạng thái đặc biệt của màn (1) + widget màn hình chính hệ điều hành.
Không phải màn hình thứ 12.
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục A (J4, J5,
J10, J12), B (Ngày 7, Ngày 30), F (SB-83/84/85, SB-87, SB-99)
Design-Surface: cupid-ch-ng-1
Design-Screen: hub-waiting, hub-upcoming, hub-date_day, hub-quiet,
  evening-check-in-sheet, quiet-surfaces, widget-phases

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`, `architecture/contract-summary.md`
- [x] Coding Plan (Tech Lead) — `coding-plan/master-plan.md`, `coding-plan/coding-agent-guide.md`, P1–P8
- [x] Implementation (Development) — mobile-dev P1-P8 complete per
  `coding-plan/master-plan.md` Phases Overview (all Status: DONE). P6 blocker
  (AC_CONFLICT_CROSS_REQUIREMENT vs REQ-002/STORY-021 AC4) resolved
  2026-09-17 by user decision (Option 1: narrow the guard's
  `flutter_local_notifications` clause to an import boundary under
  `lib/features/reminders/**`, keep the ban on other 3 packages, keep
  REQ-002/STORY-021 DONE). See `coding-plan/phase-P6-evening-check-in.md` §7/§8.
- [ ] Review (Reviewer)

## Depends On
- STORY-001 — mọi pha đọc từ trạng thái thẻ trong kho chung.

## User Story
Là người dùng app 1-2 lần một tuần, tôi muốn app nhắc tôi **đúng lúc cần** mà
không làm phiền, và cho tôi thấy "của cải" của mình đang lớn dần, để tôi có lý
do quay lại mà không cần ai trả lời gì cả.

## In Scope
1. **SB-83 "Đừng đoán — chuẩn bị" (J4)**: khi có thẻ đã rủ mà chưa trả lời, màn
   (1) hướng người dùng sang việc chuẩn bị, **không** hướng sang việc phỏng
   đoán người kia đang nghĩ gì.
2. **SB-84 widget theo pha**: widget màn hình chính đổi nội dung theo pha của
   thẻ gần nhất — *đang đợi · sắp hẹn · đúng ngày hẹn (phản chiếu khối "Trước
   giờ đi") · khoảng lặng*.
3. **SB-86 đếm ngược** tới ngày hẹn trên thẻ *Đã hẹn ngày*.
4. **SB-85 "23h, về tới nhà chưa?" (J8)**: nhắc nhẹ tối ngày hẹn, dẫn tới cất
   ảnh và viết một câu vào nhật ký (STORY-003).
5. **SB-87 "món quà đang lớn"**: hiển thị tiến triển của một ý tưởng quà cần
   thời gian, trong khoảng lặng giữa hai lần hẹn (J10).
6. **SB-99 nhỏ giọt**: nội dung nhỏ giọt trong khoảng lặng, tần suất thấp.
7. **Bộ đếm "của cải đang lớn"**: màn (1) hiển thị kho đang lớn tới đâu (ví dụ
   "12 chỗ → 15 chỗ"). Đây là **mặt user-visible duy nhất của việc nhận diện
   cột mốc J12** trong REQ-016.
8. Thông báo là **nhắc nhẹ** (D-1) — đủ mạnh để thấy, không phải báo thức thật;
   tắt được toàn bộ.

## Out of Scope
- **Tự thực hiện lời mời cài app khi chạm cột mốc J12** — chặng 1.5, ngoài phạm
  vi. REQ-016 dừng ở chỗ *nhận ra* cột mốc.
- **Streak, chuỗi ngày, bảng xếp hạng** — R-1(f) cấm nguyên vẹn.
- Bất kỳ chỉ báo nào về hành vi người kia: "đã xem", giờ mở, số lần mở — R-1b
  cấm. Widget chỉ phản ánh **thẻ của người dùng**, không phản ánh người kia.
- Báo thức thật / thông báo cưỡng bức không tắt được.
- Nội dung nhỏ giọt thúc mở app hằng ngày — mâu thuẫn "không tối ưu DAU".
- Khối "Trước giờ đi" (STORY-006) và "Cảm ơn + chốt việc kế tiếp" (STORY-007)
  — story này chỉ **phản chiếu** pha của chúng lên widget.

## Acceptance Criteria
1. Given có một thẻ đã rủ mà người dùng đánh dấu "chưa trả lời", when họ mở màn
   (1), then app hướng họ sang một việc chuẩn bị cụ thể và **không** hiển thị
   bất kỳ suy đoán nào về người kia (SB-83, R-1b).
2. Given thẻ gần nhất đang ở pha "sắp hẹn", when người dùng xem widget, then
   nội dung widget khớp pha đó; given thẻ chuyển sang "đúng ngày hẹn", then
   widget đổi sang pha thứ tư phản chiếu khối "Trước giờ đi".
3. Given một thẻ *Đã hẹn ngày* có ngày trong tương lai, when người dùng xem
   thẻ, then có đếm ngược tới ngày hẹn (SB-86).
4. Given hôm nay là ngày hẹn của một thẻ, when tới khoảng 23h, then app gửi một
   nhắc nhẹ "về tới nhà chưa?" dẫn tới cất ảnh / viết một câu vào nhật ký, và
   nếu bỏ qua thì không nhắc lại (SB-85).
5. Given người dùng có nhiều thẻ đã chuyển *Đã thành kỷ niệm* theo thời gian,
   when họ mở màn (1), then bộ đếm "của cải đang lớn" phản ánh đúng số đó và
   tăng lên khi có thêm kỷ niệm.
6. Given người dùng duyệt toàn app, when họ tìm chỉ số gắn kết, then **không**
   có streak, chuỗi ngày, hay bảng xếp hạng nào (R-1(f)).
7. Given người dùng tắt thông báo của app, when các mốc nhắc tới, then app
   không gửi thông báo nào và các tính năng còn lại vẫn dùng được bình thường.
8. Given người dùng không mở app trong nhiều ngày, when họ mở lại, then app
   **không** hiển thị bất kỳ nội dung trách móc, đếm ngày vắng, hay chuỗi bị
   đứt nào.

## System Integration And Discoverability
- UI-facing story: YES (gồm cả bề mặt widget của hệ điều hành).
- Existing user-visible surface: YES — màn (1), thẻ, nhật ký.
- Điểm vào: widget do người dùng tự thêm vào màn hình chính theo cơ chế của hệ
  điều hành; các pha còn lại tự hiện trong màn (1).

## Dependencies
- Depends on: STORY-001. Nếu STORY-003 và STORY-006 đã giao thì cửa ra nhật ký
  (AC4) và pha thứ tư của widget (AC2) trỏ vào chúng; nếu chưa, phần đó suy
  biến gọn gàng chứ không chặn story.
- Không yêu cầu story tương lai: xác nhận.

## Open Question Impact
- OQ-3 — **ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Kiểm duyệt hai lớp vẫn **không** áp cho story này (BR-14: nội dung ở
  đây nói về tài sản/việc của chính người dùng), và story này chưa bao giờ bị
  chặn. Nhưng **R-15 có áp** vì story ship nội dung pha/nhắc/nhỏ giọt dạng
  preset: gói dữ liệu có schema + id bền, cấm chuỗi cứng trong mã **widget**
  (R-15a); N là thuộc tính dữ liệu, kho nhỏ giọt cạn thì im lặng chứ không nới
  trần tần suất BR-9 (R-15b); ranh giới BR-14 thành cổng nhập chạy được (R-15c).
  Chi tiết: AC-37..AC-39, BR-15..BR-17 trong `requirements/requirements.md`.
- L45: story này là một trong ba story chịu tải cho định vị "kho tài sản" — bộ
  đếm "của cải đang lớn" (N3) là lý do quay lại được chọn thay cho "có người
  đang chờ trả lời" (N7, ngoài phạm vi).
