# Story Master: STORY-011 Vỏ hoàng đạo / trắc nghiệm

Status: TODO
Complexity: standard
Story-Class: standard
Implementation Lane: mobile (chốt ở `architecture/solution.md` — AC-22/AC-23
cấm mọi API ngoài và bắt buộc chạy ngoại tuyến, nên không tồn tại bề mặt
backend nào)
Requirement: REQ-016
Screen: Vỏ hoàng đạo / trắc nghiệm — màn (7), nhóm CỬA VÀO
Design-Screen: 7-vo-hoang-dao-3-viec
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục C.7, D (SC-2),
F (Tầng 4); `req_master.md` SB-174, R-10

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`, `architecture/contract-summary.md`
- [ ] Implementation (Development)
- [ ] Review (Reviewer)

## Depends On
- STORY-001 — kết quả ra 3 thẻ hoạt động đẩy vào kho chung.
- STORY-004, STORY-005, STORY-008 — **SB-174**: vỏ hoàng đạo chỉ được phủ lên
  sau khi quà, mồi chuyện, và kịch bản đã hết chung chung.

## User Story
Là người muốn có một cớ nhẹ nhàng để bắt chuyện, tôi muốn một trắc nghiệm hoặc
lát hoàng đạo vui, nhưng kết quả phải dẫn tôi tới **việc làm được** chứ không
dừng ở một câu phán.

## In Scope
1. Màn vỏ hoàng đạo / trắc nghiệm với nội dung preset tất định, không AI ở
   runtime.
2. **Kết quả LUÔN kết thúc bằng 3 thẻ hoạt động đề xuất thêm vào màn (1)** —
   không bao giờ bằng một nhận định đứng một mình (SC-2).
3. **R-1g** — mọi nội dung nói về người kia kết thúc bằng một câu để hỏi người
   thật.
4. **R-10 — định vị**: đây là *vỏ* để bắt chuyện, không phải lời tiên tri. Ngôn
   ngữ phải giữ app ở vị trí "trợ lý hoạt động", không trượt sang "app bói
   toán".
5. Nội dung tham chiếu sổ tay (STORY-004) để bớt chung chung.
6. Kiểm duyệt nội dung hai lớp (SB-123).

## Out of Scope
- Kết quả trắc nghiệm đứng một mình, không kèm 3 thẻ hoạt động — vi phạm SC-2
  và là chính xác cái làm ra "app bói toán có kèm to-do list" mà SB-174 cấm.
- Bảng tra ăn khớp — STORY-010 (khoá vị trí, khác màn này).
- Chấm điểm hay xếp hạng người kia dựa trên kết quả trắc nghiệm — R-1e cấm.
- Trò chơi "đoán" không thắng thua (SB-144/145/146) — hoãn, chưa có màn chủ.
- Vận mệnh hằng ngày / tử vi theo ngày tạo thói quen mở app — mâu thuẫn với
  "không tối ưu DAU" và R-1(f).

## Acceptance Criteria
1. Given người dùng hoàn tất một lát hoàng đạo hoặc một trắc nghiệm, when kết
   quả hiện ra, then màn kết quả **luôn** kèm đúng 3 thẻ hoạt động đề xuất, và
   không có biến thể nào chỉ hiện nhận định (SC-2).
2. Given màn kết quả, when người dùng chọn một trong 3 thẻ đề xuất, then thẻ đó
   xuất hiện ở màn (1), trạng thái *Mới nghĩ ra*.
3. Given bất kỳ đoạn nội dung nào nói về người kia, when đọc hết đoạn, then nó
   kết thúc bằng một câu để hỏi người thật (R-1g).
4. Given kết quả hiện ra, when người dùng đọc, then **không** có điểm số hay
   xếp hạng nào về người kia (R-1e).
5. Given người dùng mở màn nhiều lần trong một ngày, when nội dung hiện ra,
   then app **không** dùng cơ chế nội dung mới mỗi ngày để tạo thói quen mở app
   (không tử vi hằng ngày, không streak).
6. Given thiết bị không có mạng, when người dùng dùng màn này, then nội dung
   vẫn dùng được vì là gói dữ liệu tĩnh.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — màn (1) và sổ tay đã có.
- Điểm vào: đường vào riêng từ menu chính (nhóm CỬA VÀO). **Khác với STORY-009
  và STORY-010**, màn này KHÔNG khoá vị trí.

## Dependencies
- Depends on: STORY-001, STORY-004, STORY-005, STORY-008 — phụ thuộc thứ tự
  SB-174, là một ràng buộc sản phẩm (làm ngược lại sẽ ra một app bói toán có
  kèm to-do list), không phải ràng buộc kỹ thuật.
- Không yêu cầu story tương lai: xác nhận.

## Open Question Impact
- OQ-3 — **ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Không còn chặn story này. Thành ràng buộc: kho trắc nghiệm, các lát
  hoàng đạo, văn bản ba thẻ, và luật ánh xạ là **dữ liệu có schema + id bền**
  (R-15a); **N là thuộc tính dữ liệu**, hành vi hết-vòng đúng với mọi N, không
  chỉ báo tiến độ — con số **3** thẻ (BR-2) là hợp đồng bố cục, **không** phải N
  (R-15b); R-1b (cả tầng câu HỎI đầu vào), R-1e, R-1g, SB-136 cấm giọng phán
  quyết, cấm %, cấm streak cưỡng chế ở **cổng nhập chạy được** làm hỏng bản dựng
  (R-15c). Kiểm duyệt hai lớp (SB-123) giữ mức nghiêm cho chất lượng biên tập,
  không còn là cổng chặn ship. Chi tiết: AC-29, AC-30..AC-34, BR-12..BR-14
  trong `requirements/requirements.md`.
- SB-144/145/146 (trò chơi "đoán") **không** thuộc story này.
