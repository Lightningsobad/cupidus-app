# Story Master: STORY-004 Gợi ý quà, và sổ tay / hồ sơ kỹ năng thu thập tại chỗ

Status: DONE
Complexity: complex
Story-Class: shared-foundation
Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
Requirement: REQ-016
Screen: Gợi ý quà — màn (5), nhóm CỬA VÀO · Sổ tay người yêu — màn (2) · Hồ sơ
kỹ năng "phiên bản tôi" — màn (3), cả hai thuộc nhóm KHO
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục C.2, C.3, C.5,
D (SC-2, SC-3), B (Ngày 1), F (3a/3b, SB-129, SB-197, SB-206)
Design-Screen: `2-so-tay-nguoi-yeu`, `3-ho-so-ky-nang-phien-ban-toi`,
`5-goi-y-qua-thang-cong-suc` (surface `cupid-ch-ng-1`, platform `ios`; phân
giải và khoá trong P4/P7 — xem `visual-fidelity/visual-fidelity-report.md`)

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`, `architecture/contract-summary.md`
- [x] Implementation (Development)
- [x] Review (Reviewer) — `review/review-report.md`, `Outcome: DEFERRED_ONLY`

## Depends On
- STORY-001 — đầu ra của gợi ý quà là một thẻ đẩy vào kho chung (SC-1'/SC-2).

## User Story
Là người muốn tặng quà có ý nghĩa mà không cần giàu, tôi muốn app gợi ý quà hợp
với **đúng người này** và đúng dịp, hỏi tôi đúng một câu nó còn thiếu ngay lúc
cần, để tôi không phải điền một cái hồ sơ dài trước khi nhận được gì.

## In Scope

Ba pha theo đúng thứ tự SB-174 (sổ tay trước, rồi mới de-genericize quà). Đây
là **thứ tự pha bên trong một story**, không phải ba story.

**Pha 1 — kho ngữ cảnh (SB-129 sổ tay + SB-197 hồ sơ kỹ năng):**
1. Kho dữ liệu sổ tay người yêu: **chỉ sở thích và sự kiện** (R-1f).
2. Kho dữ liệu hồ sơ kỹ năng "phiên bản tôi": những gì người dùng tự làm được.
3. **Cơ chế hỏi-tại-chỗ (SC-3)**: một cửa vào cần một trường chưa có → hỏi
   **đúng một câu**, dùng luôn câu trả lời, âm thầm lưu vào sổ tay/kỹ năng.
   Không có màn xác nhận "đã lưu vào hồ sơ" ồn ào.
4. Màn (2) và màn (3): chỉ **xem/sửa/xoá** những gì đã thu thập, cộng một nút
   "+ tự thêm" cho ai chủ động. **Không có luồng điền-trước, không phải nơi
   onboarding** (SC-3).

**Pha 2 — gợi ý quà (3a):**
5. Chỉ mục quà theo **dịp Việt × giai đoạn quen nhau × sổ tay**.
6. Nhánh **"quà không tốn tiền"**.
7. Lọc theo **thang CÔNG SỨC (số giờ)**, không theo VNĐ (R-11). Có bộ lọc
   nhanh "làm được trong 2 tiếng tối nay".

**Pha 3 — quà handmade theo kỹ năng (3b / SB-206):**
8. Nhánh quà handmade sinh từ hồ sơ kỹ năng: kỹ năng → hoạt động/quà làm được.
9. **Chống rủi ro #2 (SB-199)**: hồ sơ kỹ năng **không** được trình bày kiểu
   CV. "Nhớ dai", "biết chỗ ăn ngon", "gói quà đẹp", "chọn nhạc hợp cảnh" phải
   được tính là kỹ năng hợp lệ và phải có mặt trong bộ gợi ý mồi.

**Xuyên suốt:**
10. **SC-2 — không phải điểm dừng chân**: mỗi gợi ý quà có một hành động rõ
    ràng đẩy thành một thẻ vào màn (1) ở trạng thái *Mới nghĩ ra*.
11. Kiểm duyệt nội dung hai lớp (SB-123) cho kho quà.

## Out of Scope
- **Thương mại, affiliate, giá tiền, link mua** — R-11 cấm tuyệt đối. Quà chỉ
  là Ý TƯỞNG.
- Một "danh sách quà riêng" cạnh tranh với màn (1) — vi phạm SC-1'.
- Xuất/chia sẻ sổ tay — R-1f cấm.
- Ghi đánh giá con người vào sổ tay ("hay trả lời chậm", "hơi vô tâm") — R-1f
  và R-1b cấm.
- Màn (8) chân dung và màn (10) bảng tra ăn khớp — STORY-009 và STORY-010 thêm
  liên kết khoá vị trí từ luồng quà này về sau.
- Mồi chuyện — STORY-005.
- Bất kỳ luồng onboarding nào bắt điền sổ tay/kỹ năng trước khi dùng.

## Acceptance Criteria
1. Given người dùng mở "Gợi ý quà" lần đầu và sổ tay còn trống, when họ xem
   gợi ý, then app hỏi **đúng một câu** nó còn thiếu, dùng luôn câu trả lời để
   ra gợi ý, và **không** hiển thị màn "đã lưu vào hồ sơ".
2. Given người dùng đã trả lời một câu hỏi tại chỗ, when họ mở màn Sổ tay, then
   trường đó đã có mặt và sửa/xoá được.
3. Given người dùng mở màn Sổ tay hoặc Hồ sơ kỹ năng lần đầu, when màn hiện ra,
   then **không có** luồng "điền trước"/onboarding; chỉ có danh sách đã thu
   thập (có thể rỗng) và một nút "+ tự thêm" (SC-3).
4. Given người dùng đang xem gợi ý quà, when họ dùng bộ lọc công sức, then lựa
   chọn là **số giờ** và **không có bất kỳ mức giá VNĐ nào** ở bất cứ đâu trên
   màn (R-11).
5. Given người dùng bấm bộ lọc "làm được trong 2 tiếng tối nay", when kết quả
   hiện ra, then mọi gợi ý đều nằm trong ngưỡng công sức đó.
6. Given người dùng chọn một gợi ý quà, when họ bấm hành động chính, then một
   thẻ mới xuất hiện trong màn (1) ở trạng thái *Mới nghĩ ra*, và màn quà không
   giữ một danh sách riêng nào (SC-1'/SC-2).
7. Given hồ sơ kỹ năng còn trống, when app hỏi về kỹ năng, then câu hỏi và các
   lựa chọn mồi bao gồm cả kỹ năng "mềm" ("nhớ dai", "biết chỗ ăn ngon"), và
   **không** trình bày dưới dạng biểu mẫu CV (rủi ro #2).
8. Given người dùng nhập một mục vào sổ tay, when họ xem các trường có thể ghi,
   then chỉ có **sở thích và sự kiện**; app không cung cấp trường đánh giá con
   người và không có chức năng xuất/chia sẻ sổ tay (R-1f).

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — thẻ ở màn (1) do STORY-001 giao.
- Điểm vào: "Gợi ý quà" có đường vào riêng từ menu chính (nhóm CỬA VÀO). Sổ
  tay và Hồ sơ kỹ năng có đường vào từ menu (nhóm KHO) nhưng **chỉ để xem/sửa**
  — chúng không phải cửa vào để điền trước.

## Dependencies
- Depends on: STORY-001 (kho chung để nhận thẻ).
- Không yêu cầu story tương lai: xác nhận — quà + sổ tay dùng được trọn vẹn
  với STORY-001; STORY-005/008/009/010 chỉ **đọc thêm** sổ tay đã có.

## Open Question Impact
- OQ-3 — **ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Không còn chặn story này. Thành ràng buộc: kho quà, bộ mồi kỹ năng,
  bộ câu hỏi hỏi-tại-chỗ, và bảng tra chỉ mục quà là **dữ liệu có schema + id
  bền** (R-15a); **N là thuộc tính dữ liệu**, hành vi hết-tập và trạng thái rỗng
  từng nhánh đúng với mọi N (R-15b); R-1b, R-1f (cả tầng câu HỎI đầu vào), R-1g,
  R-11 (công sức, không VNĐ), cấm %, cấm streak cưỡng chế ở **cổng nhập chạy
  được** làm hỏng bản dựng (R-15c). Kiểm duyệt hai lớp (SB-123) giữ cho chất
  lượng biên tập, không còn là cổng chặn ship. Chi tiết: AC-31, AC-32..AC-36,
  BR-16..BR-18 trong `requirements/requirements.md`.
- Rủi ro #2 (SB-199) đã chuyển thành guardrail cứng ở In Scope mục 9 và AC7.
- SB-174: thứ tự pha trong story này (sổ tay → quà → handmade) là bắt buộc,
  Tech Lead phải giữ nguyên trong `coding-plan/master-plan.md`.
