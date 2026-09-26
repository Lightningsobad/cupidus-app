# Story Master: STORY-008 Kịch bản buổi hẹn 3 phần

Status: PATCH_REQUIRED
Complexity: standard
Story-Class: standard
Implementation Lane: mobile (chốt ở `architecture/solution.md` §4 — không có
lane backend/devops; story không ghi DB, không gọi mạng, `schemaVersion` không đổi)
Requirement: REQ-016
Screen: Kịch bản buổi hẹn 3 phần — màn (9), **nhóm KHOÁ VỊ TRÍ**. Chỉ vào được
từ một thẻ *Đã hẹn ngày* ở màn (1).
Design-Screen: 9-kich-ban-buoi-hen
Design-Screen-Note: ios, resolved 2026-09-17 — see
`visual-fidelity/visual-fidelity-report.md`; alias `s1:datescript` là id trên
canvas `cupid-app` KHÔNG được neo, `req_master.md:13` neo
`Design-Surface: cupid-ch-ng-1`. Khung canvas có 5 mục DESIGN_SPEC_CONFLICT vs
AC ràng buộc — AC thắng theo tiền lệ canvas-vs-AC của REQ-016 — và 1 mục
DESIGN_ANCHOR_OPEN cần Product Owner phán quyết, không chặn ship.
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục C.9, D (SC-2,
SC-6), A (J5, J7), F (3d)

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`, `architecture/contract-summary.md`
- [x] Implementation (Development) — kế hoạch: `coding-plan/master-plan.md`
  (P1 → P2 → P3 → P4, một lane Mobile Developer)
- [x] Review (Reviewer) — `review/review-report.md`, `Outcome: DEFERRED_ONLY`
  (rework re-review 2026-09-24, lượt 4: F-1..F-5 và D-1 đều đóng; D-2..D-7,
  N-1, N-2 hoãn không chặn)

## Depends On
- STORY-001 — vào từ một thẻ *Đã hẹn ngày*.
- STORY-002 — cửa ra "lời mời".
- STORY-003 — cửa ra "nhật ký".
- STORY-004 — đọc sổ tay để kịch bản hết chung chung (SB-174).

## User Story
Là người sắp đi hẹn và hay lo mình sẽ ngồi im không biết nói gì, tôi muốn có
một kịch bản gợi ý cho trước / trong / sau buổi hẹn dựa trên đúng người này, để
tôi tự tin hơn khi bước ra khỏi nhà.

## In Scope
1. Màn kịch bản 3 phần: **trước / trong / sau** buổi hẹn, sinh tất định từ
   trường của thẻ (loại hoạt động, địa điểm, thời lượng) và sổ tay.
2. **Ba cửa ra bắt buộc** (SC-2): "xuất lời mời" (→ STORY-002) · "tạo thẻ mới"
   (→ màn 1) · "ghi vào nhật ký" (→ màn 4). Màn này không phải điểm dừng chân.
3. **SC-6 / R-13 — khoá vị trí**: chỉ vào được từ một thẻ *Đã hẹn ngày*. Không
   xuất hiện trong menu chính, không xuất hiện trong tab bar.
4. Nội dung là **preset + mad-libs**, không AI ở runtime.
5. **R-1g** — mọi phần nói về người kia kết thúc bằng một câu để hỏi người
   thật.
6. Sổ tay trống → kịch bản vẫn ra được bản mặc định, và app hỏi tại chỗ đúng
   một câu (cơ chế của STORY-004).
7. Kiểm duyệt nội dung hai lớp (SB-123).

## Out of Scope
- **Bất kỳ touchpoint nào chạy TRONG lúc đang hẹn (J7).** Phần "trong" của
  kịch bản là nội dung **đọc trước khi đi**, không phải thông báo, nhắc nhở,
  hay màn hình hiện lên lúc đang hẹn. J7 cố ý để trống theo triết lý "trợ lý
  trước/sau" — đây là quyết định, không phải thiếu sót.
- **Kịch bản thao túng, gài bẫy, hoặc A/B test lời nói** — R-1(e) cấm nguyên
  vẹn.
- Chấm điểm buổi hẹn, chấm điểm phản ứng của người kia — R-1e tầng 3 cấm.
- Đường vào từ menu chính hoặc tab bar — vi phạm SC-6.
- Màn (8) chân dung và màn (10) bảng tra ăn khớp — STORY-009/010 thêm liên kết
  khoá vị trí từ màn này về sau.

## Acceptance Criteria
1. Given người dùng đang ở một thẻ *Đã hẹn ngày*, when họ bấm "chuẩn bị", then
   màn kịch bản 3 phần mở ra với nội dung khớp loại hoạt động của thẻ.
2. Given người dùng duyệt toàn bộ menu chính và tab bar, when họ tìm màn kịch
   bản, then **không** có mục nào dẫn thẳng tới nó (SC-6).
3. Given màn kịch bản đang mở, when người dùng xem các hành động, then có đủ ba
   cửa ra: xuất lời mời, tạo thẻ mới, ghi vào nhật ký (SC-2).
4. Given người dùng bấm "ghi vào nhật ký", when hành động chạy, then một mục
   nhật ký được tạo/mở ở màn (4) mang ngữ cảnh của thẻ.
5. Given sổ tay còn trống, when kịch bản hiện ra, then nội dung vẫn dùng được
   và app hỏi tại chỗ đúng một câu để lần sau bớt chung chung.
6. Given người dùng đọc phần "trong buổi hẹn", when họ đóng app và đi hẹn,
   then app **không** gửi thông báo, không hiện màn hình, và không yêu cầu bất
   kỳ thao tác nào trong khoảng thời gian buổi hẹn (J7 để trống).
7. Given bất kỳ đoạn nào nói về người kia, when đọc hết đoạn, then nó kết thúc
   bằng một câu để hỏi người thật, không bằng một nhận định chốt hạ (R-1g).

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — thẻ *Đã hẹn ngày* ở màn (1).
- Điểm vào: **duy nhất** từ hành động "chuẩn bị" của thẻ *Đã hẹn ngày*. Khoá vị
  trí theo SC-6/R-13. Direct URL only acceptable: **NO** — điều hướng trực tiếp
  bằng route là vi phạm luật khoá vị trí.

## Dependencies
- Depends on: STORY-001, STORY-002, STORY-003, STORY-004.
- Không yêu cầu story tương lai: xác nhận — STORY-009/010 chỉ **thêm** liên kết
  đi ra từ màn này.

## Open Question Impact
- OQ-3 — **ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Kho kịch bản ba phần vẫn là nội dung có giọng điệu chạm cả R-1e lẫn
  R-1g, nhưng **không còn chặn việc SHIP**. Thành ràng buộc: preset là **dữ
  liệu có schema + id bền**, đổi nguồn sang CMS không sửa code (R-15a); **N là
  thuộc tính dữ liệu** — phép chọn preset và hành vi hết-tập phải đúng với mọi
  N chứ không phải cho seed 10 mục (R-15b); R-1b/R-1e/R-1g, chống tâng bốc, cấm
  %, cấm streak cưỡng chế ở **cổng nhập chạy được** làm hỏng bản dựng (R-15c).
  Kiểm duyệt hai lớp (SB-123) giữ cho chất lượng biên tập, không còn là cơ chế
  cưỡng chế luật bất biến. Chi tiết: AC-31, AC-33..AC-37, BR-16..BR-18.
- Màn (9) là **khoá vị trí theo tư cách thành viên nhóm (8)/(9)/(10)** — quyết
  định đã chốt, xem `requirements/requirements.md` → BR-1, BR-1a.
- Chi tiết đầy đủ: `requirements/requirements.md` → `## Open Question Impact`.
