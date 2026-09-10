# Story Master: STORY-001 Danh sách việc-cần-làm — kho chung và vòng đời thẻ

Status: DONE
Complexity: complex
Story-Class: shared-foundation
Implementation Lane: shared (backend + mobile; ranh giới chính xác do Tech Lead chốt)
Requirement: REQ-016
Screen: Danh sách việc-cần-làm — màn (1) trong bản đồ 11 màn hình, màn "về nhà"
Spec reference: `data/brainstorms/IDEA-20260829-001_solo-stage1-breadth-expansion/idea.md`
→ `## Đặc tả sản phẩm (vòng 9-10)` mục C.1, D (SC-1', SC-4, SC-5), B (Phút 1)

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead)
- [x] Implementation (Development)
- [x] Review (Reviewer) — Outcome: DEFERRED_ONLY (round-13, scoped-slice)

## Depends On
- NONE.

## User Story
Là người đã có một "mối" cụ thể, tôi muốn có **một chỗ duy nhất** chứa mọi ý
tưởng hẹn hò và theo được chúng từ lúc mới nghĩ ra tới lúc thành kỷ niệm, để
không ý tưởng nào rơi rụng và tôi thấy được "của cải" của mình đang lớn dần.

## In Scope
1. Màn danh sách việc-cần-làm là **kho chung duy nhất** của chặng 1 (SC-1'):
   mọi thẻ sinh ra ở bất kỳ cửa vào nào sau này đều nằm ở đây.
2. Bốn trạng thái thẻ dùng làm bốn "ngăn" lọc: *Mới nghĩ ra · Đã hẹn ngày · Đã
   đi rồi · Đã thành kỷ niệm* (OQ-2, phần đã trả lời).
3. Mô hình thẻ có cấu trúc (SB-76) đủ trường để các story sau đọc được: tiêu
   đề, loại hoạt động, ngày hẹn, giá, khoảng cách, cần đặt trước, trong
   nhà/ngoài trời, ghi chú, ảnh/ký ức.
4. **Bắt ý tưởng trong 5 giây** (J1): nút "+" nhập nhanh và **dán link**, không
   bắt điền đủ trường.
5. **SC-4 — đúng một hành động chính mỗi trạng thái**: *Mới nghĩ ra* → "hẹn
   ngày" · *Đã hẹn ngày* → "chuẩn bị" · *Đã đi rồi* → "ghi lại" · *Đã thành kỷ
   niệm* → "xem lại".
6. Chuyển trạng thái thủ công theo cả hai chiều, và xoá thẻ.
7. **Trạng thái rỗng của Phút 1**: không có form dài; hai lời mời duy nhất là
   "dán 1 link em vừa thấy" và "để app gợi ý 1 việc theo dịp gần nhất", chọn 1
   là có 1-2 thẻ trong 60 giây.
8. Nếu thẻ có mang ý niệm "đã rủ", trạng thái phản hồi chỉ được là **đã trả lời
   / chưa trả lời**, do user tự đánh dấu (R-1b).

## Out of Scope
- Xuất lời mời (bottom sheet, mad-libs) — STORY-002. Ở story này hành động
  chính của *Đã hẹn ngày* là "chuẩn bị", chưa có "xuất lời mời".
- Khối "Trước giờ đi" (SB-211) — STORY-006.
- Khối "Cảm ơn + chốt việc kế tiếp" (SB-212) — STORY-007.
- Widget, đếm ngược, bộ đếm "của cải đang lớn", pha theo thời gian — STORY-012.
- Màn không trách móc khi quay lại sau vắng (J13) và đóng ngăn gọn gàng (J11)
  — STORY-013.
- Mọi cửa vào sinh nội dung (quà, mồi chuyện, hoàng đạo) — story riêng.
- Bất kỳ danh sách thứ hai nào cạnh tranh với màn này (vi phạm SC-1').

## Acceptance Criteria
1. Given người dùng mở app lần đầu, when màn danh sách hiện ra, then nó ở
   trạng thái rỗng, **không có** biểu mẫu onboarding, và chỉ đưa ra hai lời mời
   "dán 1 link" hoặc "để app gợi ý 1 việc theo dịp gần nhất".
2. Given người dùng chọn một trong hai lời mời đó, when hoàn tất, then có ít
   nhất 1 thẻ ở trạng thái *Mới nghĩ ra* mà không phải điền thêm trường nào.
3. Given một thẻ bất kỳ, when người dùng xem nó trong danh sách, then đúng
   **một** hành động chính hiện ra và nó khớp với trạng thái hiện tại theo
   SC-4.
4. Given người dùng bấm hành động chính của *Mới nghĩ ra*, when đặt một ngày
   hẹn, then thẻ chuyển sang *Đã hẹn ngày* và xuất hiện trong đúng ngăn lọc đó.
5. Given người dùng đang ở bất kỳ ngăn nào, when họ chuyển ngăn, then danh sách
   chỉ hiển thị thẻ đúng trạng thái đó và không có ngăn nào là ngõ cụt: mọi
   ngăn đều có ít nhất một đường đi tiếp hoặc đường xoá (SC-5).
6. Given một thẻ có ý niệm "đã rủ", when người dùng xem nó, then app **chỉ**
   cho đánh dấu *đã trả lời / chưa trả lời* do chính người dùng bấm, và không
   hiển thị bất kỳ chỉ báo "đã xem", giờ mở, hay số lần mở nào (R-1b).
7. Given người dùng xoá một thẻ, when xác nhận, then thẻ biến mất khỏi kho và
   app không kịch tính hoá hành động đó (R-1c).

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: NO — chặng 1 chưa có màn hình gốc nào.
- Điểm vào: đây là màn "về nhà" của chế độ 1 người, phải có đường vào trực tiếp
  từ menu chính. Không phải màn khoá vị trí.

## Dependencies
- Depends on: NONE.
- Không yêu cầu bất kỳ story tương lai nào: xác nhận — kho thẻ dùng được trọn
  vẹn một mình, các cửa vào sau chỉ **thêm** nguồn sinh thẻ.

## Open Question Impact
- OQ-2 (một ngăn hay nhiều ngăn): phần sản phẩm đã chốt — 4 trạng thái = 4
  ngăn lọc. Chi tiết trình bày UI (tab/chip/segmented) giao UI/UX trong story
  này.
- L45: story này là một trong ba story chịu tải cho định vị "kho tài sản" —
  màn hình phải trả lời được "tài sản của tôi đang ở đâu, đã lớn tới đâu",
  không phải "có gì mới từ người kia không".
