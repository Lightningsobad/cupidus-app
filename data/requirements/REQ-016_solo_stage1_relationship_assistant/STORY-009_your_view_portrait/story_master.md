# Story Master: STORY-009 Chân dung "theo cách BẠN nhìn"

Status: TODO
Complexity: standard
Story-Class: standard
Implementation Lane: mobile-only (Tech Lead chốt: `owner_key` lấy từ
  `BackendUserIdStore` đã có, không đụng backend; AC-22 giải bằng một cửa ghi
  hẹp `recordAnsweredQuestion(...)` đặt bên trong chính module STORY-004 — xem
  `architecture/solution.md`)
Requirement: REQ-016
Screen: Chân dung "theo cách BẠN nhìn" — màn (8), **nhóm KHOÁ VỊ TRÍ**. Chỉ vào
được từ luồng (5) gợi ý quà hoặc (9) kịch bản buổi hẹn đang chạy.
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục C.8, D (SC-6),
F (3e); `req_master.md` R-1, R-1e, R-1g, R-13
Design-Screen: 8-chan-dung-theo-cach-ban-nhin

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`,
  `architecture/contract-summary.md`
- [x] Implementation (Development)
- [x] Review (Reviewer) — `review/review-report.md` (Outcome: DEFERRED_ONLY).
  Carry D-4 (DESIGN_DELTA_OPEN → Product Owner), D-5 (on-device onUpgrade 6→7
  evidence) and D-6 (STORY-009/STORY-010 both bump Drift schemaVersion to 7 →
  resolve at merge) into requirement integration review.

## Depends On
- STORY-004 — vào từ luồng gợi ý quà; đọc và ghi vào sổ tay.

## User Story
Là người muốn hiểu "mối" của mình rõ hơn, tôi muốn tự trả lời một bộ câu hỏi
**thay cho người kia theo cách tôi nhìn**, để thấy rõ mình đang đoán gì — và
biết mình cần hỏi thật những gì.

## In Scope
1. Bảng câu hỏi người dùng trả lời **thay** người kia, theo cách chính họ nhìn.
2. **Ghi rõ xuất xứ ở mọi nơi hiển thị kết quả**: "dựa trên những gì BẠN nhập".
   Đây là **chân dung TƯỞNG TƯỢNG**, không phải sự thật về người kia.
3. **Luật ba tầng R-1e**: user GHI ✅ · user ĐOÁN, app **không xác nhận** ✅ ·
   app SUY LUẬN/CHẤM ĐIỂM về người kia ❌. App được phép suy luận tính cách
   **chỉ trên dữ liệu người dùng tự nhập** (R-1a).
4. **R-1g — không kết luận**: mỗi phần chân dung kết thúc bằng **một câu để hỏi
   người thật**. Bài kiểm tra nghiệm thu: đọc xong, người dùng muốn hỏi người
   kia **nhiều hơn**.
5. **SC-6 / R-13 — khoá vị trí**: chỉ tới được bằng một liên kết trong luồng
   (5) hoặc (9). Không có trong menu chính, không có trong tab bar.
6. Câu trả lời đổ vào sổ tay (STORY-004) để các cửa vào khác dùng lại.
7. Kiểm duyệt nội dung hai lớp (SB-123).

## Out of Scope
- **Chấm điểm người kia bằng dữ liệu app tự thu** — R-1(d-sai) cấm.
- **So sánh và báo cáo hành vi người kia** — R-1(c) cấm.
- **Đọc tin nhắn, theo dõi mạng xã hội, nhập dữ liệu từ nguồn ngoài** —
  R-1(b) cấm.
- Bất kỳ câu nào app tự khẳng định là sự thật về người kia (R-1e tầng 3).
- Đường vào từ menu chính hoặc tab bar — vi phạm SC-6.
- Bảng tra ăn khớp — STORY-010.
- Xuất/chia sẻ chân dung ra ngoài app (nhất quán R-1f).

## Acceptance Criteria
1. Given người dùng đang ở luồng gợi ý quà, when họ bấm liên kết tới chân dung,
   then màn chân dung mở ra kèm nhãn xuất xứ "dựa trên những gì BẠN nhập" hiển
   thị ngay ở đầu.
2. Given người dùng duyệt toàn bộ menu chính và tab bar, when họ tìm màn chân
   dung, then **không** có mục nào dẫn tới nó (SC-6/R-13).
3. Given người dùng đã trả lời bộ câu hỏi, when kết quả chân dung hiện ra, then
   mỗi phần kết thúc bằng **một câu để hỏi người thật**, và **không** có bất kỳ
   câu nào app tự khẳng định là sự thật về người kia (R-1g, R-1e).
4. Given kết quả chân dung, when người dùng đọc, then **không** có điểm số,
   xếp hạng, hay đánh giá con người nào về người kia (R-1(d-sai)).
5. Given người dùng trả lời một câu hỏi có thể lưu được (sở thích, sự kiện),
   when họ hoàn tất, then dữ liệu đó xuất hiện trong sổ tay và dùng lại được ở
   các cửa vào khác.
6. Given người dùng bỏ dở giữa chừng, when họ thoát, then phần đã trả lời được
   giữ lại và màn không thúc ép hoàn thành.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — luồng gợi ý quà (STORY-004).
- Điểm vào: **duy nhất** từ một liên kết trong luồng (5) hoặc (9) đang chạy.
  Direct URL only acceptable: **NO** — điều hướng trực tiếp bằng route là vi
  phạm luật khoá vị trí.

## Dependencies
- Depends on: STORY-004 (luồng quà làm cửa vào, và sổ tay để đọc/ghi).
- Không yêu cầu story tương lai: xác nhận — nếu STORY-008 đã giao thì cửa vào
  thứ hai từ kịch bản buổi hẹn cũng dùng được, nhưng story này không cần nó.

## Open Question Impact
- OQ-3 — **ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Không còn chặn story này. Thành ràng buộc: bộ câu hỏi, đoạn chân
  dung, kho câu-để-hỏi, và luật ánh xạ là **dữ liệu có schema + id bền**
  (R-15a); **N là thuộc tính dữ liệu**, hành vi hết-vòng của kho câu-để-hỏi đúng
  với mọi N, không chỉ báo tiến độ (R-15b); R-1b, R-1e, R-1g, chống tâng bốc,
  cấm %, cấm streak cưỡng chế ở **cổng nhập chạy được** làm hỏng bản dựng
  (R-15c). Đây vẫn là story rủi ro "sượng" **cao nhất** vì nội dung nói trực
  tiếp về người kia, nên bộ câu hỏi chịu cổng nhập ở **tầng đầu vào** (BR-6 →
  AC-37), không chỉ đầu ra. Kiểm duyệt hai lớp (SB-123) giữ mức nghiêm nhất cho
  chất lượng biên tập, không còn là cổng chặn ship. Chi tiết: AC-31, AC-33..
  AC-37, BR-15..BR-17 trong `requirements/requirements.md`.
- Màn, điều hướng khoá vị trí, **bố cục nhãn xuất xứ**, cơ chế lưu-bỏ-dở, và
  đường ghi vào sổ tay chưa bao giờ bị chặn.
- Chi tiết đầy đủ: `requirements/requirements.md` → `## Open Question Impact`.
