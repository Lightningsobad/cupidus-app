# Story Master: STORY-007 "Cảm ơn + chốt việc kế tiếp" (SB-212)

Status: DONE
Complexity: standard
Story-Class: standard
Implementation Lane: mobile-only (Tech Lead chốt: một lane Mobile Developer
  duy nhất viết hợp đồng và toàn bộ consumer trong cùng lane, tuần tự — xem
  `coding-plan/master-plan.md` mục 2)
Requirement: REQ-016
Screen: Khối mở rộng trên chi tiết thẻ ở màn (1). **Không phải màn hình thứ 12.**
Design-Screen: sb-212-cam-on-chot-viec-ke-tiep
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục E (SB-212),
A (J9), C.11

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`,
      `architecture/contract-summary.md`,
      `coding-plan/master-plan.md` (5 phase, contract-first: NO, parallel: NO)
- [x] Implementation (Development) — P1-P5 tất cả `DONE` (xem
      `coding-plan/master-plan.md` mục 5). P1 activation ledger, P2 block
      shell + entry point, P3 thank-you preset category, P4 photo-attach
      (đóng `JOURNAL_SOURCE_CONTRACT_CLOSED` lối A, commit `7b7612d0`), P5
      next-plan suggestions. Ghi nhận các `DESIGN_SPEC_CONFLICT` cần Reviewer
      xem qua (không tự giải quyết): P2 có 4 mục, P4 có 2 mục (canvas lộ
      metadata nhật ký vi phạm AC-17/BR-8; canvas ngụ ý đích điều hướng thứ
      hai vi phạm AC-7) — cả 6 mục đều làm theo AC/spec, không theo canvas.
      Nhánh nhật ký của AC-14/AC-4 kiểm bằng hàng gieo sẵn (chưa có caller
      trong phạm vi story này; STORY-008 sẽ cung cấp màn tạo-mục-từ-thẻ).
- [x] Review (Reviewer) — `review/review-report.md` (final-synthesis),
      `Outcome: DEFERRED_ONLY`. 0 phát hiện chặn trên cả 5 slice. Mục cần
      chuyển tiếp lên PO (không chặn DONE): lượt kích hoạt trọn-đời bị
      `consume()` lúc màn dựng, không phải lúc khối lọt vào tầm mắt — xem
      `review/review-report.md` mục 4.

## Depends On
- STORY-001 — khối gắn trên chi tiết thẻ trạng thái *Đã đi rồi*.
- STORY-002 — tái dùng renderer khung nhại + mad-libs.
- STORY-003 — đính ảnh đã lưu ở nhật ký.
- STORY-005 — "chốt việc kế tiếp" lấy gợi ý từ kho mồi.

## User Story
Là người vừa có một buổi hẹn vui tối qua, tôi muốn app nhắc nhẹ **một lần** vào
sáng hôm sau để gửi lời cảm ơn thật và chốt luôn việc kế tiếp, để cái đà không
nguội đi.

## In Scope
1. Khối "Cảm ơn + chốt việc kế tiếp" hiện **sáng hôm sau** khi thẻ đã chuyển
   *Đã đi rồi* hôm qua. Đây là touchpoint **hướng ra ngoài**, đối lập trực tiếp
   với J8 (hướng vào trong).
2. **Kích hoạt đúng MỘT LẦN.** Bỏ qua thì thôi hẳn — không lặp lại, không nhắc
   lần hai, không tạo cảm giác tội lỗi (nhất quán luật "không phạt khi im
   lặng").
3. **Phần 1 — soạn lời cảm ơn**: thêm một **danh mục preset mới** "lời cảm ơn
   sau hẹn" vào renderer của STORY-002. Không xây engine mới.
4. **Phần 2 — đính ảnh**: liên kết sang nhật ký/ký ức nếu người dùng đã lưu ảnh
   ở khối "23h vừa về" (J8). Nếu chưa có ảnh, phần này không hiện.
5. **Phần 3 — chốt việc kế tiếp**: 2-3 gợi ý nhẹ lấy từ kho mồi (STORY-005)
   hoặc dịp lịch âm gần nhất; chọn 1 → thẻ mới vào màn (1) ở trạng thái *Mới
   nghĩ ra*. **Không bắt buộc.**
6. Đầu ra lời cảm ơn đi qua OS Share Sheet để người dùng tự gửi sang Zalo.

## Out of Scope
- Engine nội dung mới — bắt buộc tái dùng renderer STORY-002.
- Nhắc lại lần hai, chuỗi nhắc, hoặc bất kỳ cơ chế nào phạt việc bỏ qua.
- Gửi tin nhắn thay người dùng.
- Đo lường xem người kia đã đọc lời cảm ơn chưa (R-1b).
- Khối "23h vừa về tới nhà chưa?" (SB-85, J8) — STORY-012.

## Acceptance Criteria
1. Given một thẻ chuyển sang *Đã đi rồi* hôm qua, when người dùng mở app sáng
   hôm sau, then khối "Cảm ơn + chốt việc kế tiếp" hiện một lần dưới dạng nhắc
   nhẹ.
2. Given người dùng bỏ qua khối đó, when họ mở app những lần sau, then khối
   **không** hiện lại cho thẻ đó và app không hiển thị bất kỳ lời trách móc,
   dấu chưa-hoàn-thành, hay chỉ số bỏ lỡ nào.
3. Given người dùng bấm "soạn lời cảm ơn", when nội dung hiện ra, then nó được
   dựng bằng **cùng renderer** khung nhại + mad-libs của STORY-002, chỉ khác
   danh mục preset.
4. Given người dùng đã lưu ảnh ở nhật ký cho buổi hẹn đó, when khối hiện ra,
   then phần "đính ảnh" hiện và liên kết tới đúng ảnh đó.
5. Given người dùng chưa lưu ảnh nào, when khối hiện ra, then phần "đính ảnh"
   **không** hiện và khối vẫn dùng được bình thường.
6. Given người dùng chọn một gợi ý ở phần "chốt việc kế tiếp", when họ xác
   nhận, then một thẻ mới xuất hiện ở màn (1), trạng thái *Mới nghĩ ra*.
7. Given người dùng không chọn gợi ý nào, when họ đóng khối, then không có thẻ
   nào được tạo và không có lời nhắc nào sau đó.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — chi tiết thẻ ở màn (1).
- Điểm vào: tự động, một lần, sáng hôm sau. Không thêm destination mới.

## Dependencies
- Depends on: STORY-001, STORY-002, STORY-003, STORY-005 — tất cả đều là hành
  vi đã giao mà story này gọi lại, không phải file dùng chung.
- Không yêu cầu story tương lai: xác nhận.

## Open Question Impact
- OQ-3 — **ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Không còn chặn story này. Thành ràng buộc: danh mục preset "lời cảm
  ơn sau hẹn" là **dữ liệu thêm vào gói của STORY-002**, cùng lược đồ, id bền
  (R-15a); **N là thuộc tính dữ liệu**, hành vi hết-vòng đúng với mọi N, không
  chỉ báo tiến độ (R-15b); R-1b, R-1g, chống tâng bốc, cấm %, cấm streak cưỡng
  chế ở **cùng cổng nhập của STORY-002** — story này **không** dựng nhánh cổng
  riêng (R-15b, STORY-002 AC-29). Kiểm duyệt hai lớp (SB-123) giữ cho chất lượng
  biên tập, không còn là cổng chặn ship. Chi tiết: AC-33..AC-36, BR-16..BR-18
  trong `requirements/requirements.md`.
- Engine, UI, luồng kích hoạt, đính ảnh, và tạo thẻ chưa bao giờ bị chặn.
- Chi tiết đầy đủ: `requirements/requirements.md` → `## Open Question Impact`.
