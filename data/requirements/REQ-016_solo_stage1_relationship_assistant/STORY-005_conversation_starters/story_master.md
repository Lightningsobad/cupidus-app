# Story Master: STORY-005 Mồi chuyện — kho câu thường xanh và sự kiện có lịch

Status: DONE
Complexity: standard
Story-Class: standard
Implementation Lane: mobile-only (Tech Lead chốt: toàn bộ bề mặt nằm trong
  tiến trình Dart + Drift cục bộ; AC-15/AC-16 cấm gọi mạng nên không có lane
  backend — xem `architecture/solution.md` §1 Key Discovery 1)
Requirement: REQ-016
Screen: Mồi chuyện — màn (6), nhóm CỬA VÀO
Design-Screen: `6-moi-chuyen-a-a` (surface `cupid-ch-ng-1`, biến thể ios; xem
  `visual-fidelity/visual-fidelity-report.md`). Báo cáo đó mang
  `DESIGN_ANCHOR_ADJUDICATION_REQUIRED: YES` — 6 chỗ canvas-vs-lời-văn-spec
  chưa được phán quyết, xem §7 của báo cáo.
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục C.6, D (SC-2),
F (3c, C1, C7)

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`,
      `architecture/contract-summary.md`
- [x] Implementation (Development) — mobile-dev P1-P4 complete, committed
      3ff29be43d1e754548767a87246df3e0c1e181a2. **Rework round (Design
      Ruling Log 2026-09-20, "Neo thiết kế") added P5-P7 on the same story
      branch**: P5 `ae908e93`, P6 `9ab00f48`, P7 `fa9c0ad5` (own scoped
      tests green, `flutter analyze` 0 error), status-flip doc commit
      `353c648e` (P7 blocked→DONE, citing `BUG-20260923-001` — pre-existing
      Drift schemaVersion drift in `test/core/database/`, out of this
      story's scope). Run
      `RUN-REQ-016_solo_stage1_relationship_assistant-STORY-005_conversation_starters-mobile-dev`
      is `status: COMPLETED`, `completion_marker: MOBILE_COMPLETE: YES`.
- [x] Review (Reviewer) — Outcome: DEFERRED_ONLY (2026-09-17,
      `review/review-report.md`) covers ONLY P1-P4 (merge `2b5d841f`,
      re-merged `2406c82e` after the visual-confirm patch).
      `design-reference-6-moi-chuyen-a-a-ios.png` was produced 2026-09-20 (see
      `visual-fidelity/visual-fidelity-report.md` §3) and directly eyeballed
      against `implemented-6-moi-chuyen-a-a-material.png`;
      `VISUAL_FIDELITY: PASS` confirmed for P1-P4. The report also carries
      `DESIGN_ANCHOR_ADJUDICATION_REQUIRED: YES` for 6 canvas-vs-spec-text
      items with no AC backing (§7) — a scope judgment call, not an
      implementation defect, so it did not block P1-P4 `Status: DONE` (see
      report §8). **P5-P7 rework is NOT yet covered by any Reviewer
      report** — a fresh `full-story-review` against `BaseHead
      bf1fc94cd5ac89a20567ba2184de1716a574a7a4` (the P1-P4 merged tip) is
      pending, dispatched round 10b/11.

## Depends On
- STORY-001 — bản A+ đổi thẳng thành thẻ trong kho chung.
- STORY-004 — đọc sổ tay để câu mồi hết chung chung (SB-174).

## User Story
Là người hay bí chuyện để nhắn, tôi muốn có sẵn câu gợi chuyện hợp với người
này và những sự kiện sắp tới đáng rủ đi, để tôi mở lời được mà không phải nghĩ.

## In Scope
1. **Bản A — kho câu gợi chuyện thường xanh**: dùng **tại chỗ**, copy đi nhắn,
   **không** thành thẻ (đúng đặc tả C.6).
2. Câu mồi được lọc/xếp theo sổ tay đã có (sở thích, sự kiện) để hết chung
   chung. Sổ tay trống → vẫn ra được câu mồi mặc định, và app hỏi tại chỗ đúng
   một câu (dùng cơ chế của STORY-004).
3. **Bản A+ — "sự kiện có lịch"**: sự kiện có ngày cụ thể (phim ra rạp, lễ hội,
   dịp lịch âm C7) **đổi thẳng thành thẻ hoạt động** trong màn (1) ở trạng thái
   *Mới nghĩ ra* (SC-2).
4. Nguồn dữ liệu sự kiện là **gói dữ liệu tĩnh ship kèm app + lịch âm tính tất
   định**. Không gọi API tin tức, không AI ở runtime.
5. **R-1g** — mọi câu mồi nói về người kia phải kết thúc bằng một câu để hỏi
   người thật, không bằng một kết luận.
6. Kiểm duyệt nội dung hai lớp (SB-123) cho kho mồi.

## Out of Scope
- **Bản B — feed tin thật** (crawl/API tin tức): `req_master.md` `## Out of
  Scope` — cần hạ tầng, đánh giá lại ở chặng 1.5.
- Một "danh sách mồi chuyện riêng" cạnh tranh với màn (1) — vi phạm SC-1'.
- Trò chơi "đoán" không thắng thua (SB-144/145/146) — hoãn, chưa có màn chủ.
- Gửi tin nhắn thay người dùng.
- Dùng kho mồi làm nguồn cho "chốt việc kế tiếp" sau buổi hẹn — STORY-007.

## Acceptance Criteria
1. Given người dùng mở màn Mồi chuyện, when màn hiện ra, then có sẵn câu gợi
   chuyện dùng được ngay, copy đi được, và **không** tạo thẻ nào (bản A).
2. Given sổ tay đã có sở thích của người kia, when câu mồi được xếp ra, then
   nội dung có tham chiếu tới sở thích đó chứ không phải câu chung chung.
3. Given sổ tay còn trống, when người dùng mở màn, then app vẫn ra câu mồi dùng
   được và hỏi tại chỗ **đúng một câu** để lần sau bớt chung chung.
4. Given một mục "sự kiện có lịch", when người dùng bấm hành động chính, then
   một thẻ mới xuất hiện ở màn (1), trạng thái *Mới nghĩ ra*, đã mang sẵn ngày
   của sự kiện (bản A+, SC-2).
5. Given người dùng mở màn khi thiết bị không có mạng, when nội dung hiện ra,
   then kho câu mồi và danh sách sự kiện vẫn dùng được vì chúng là gói dữ liệu
   tĩnh — app không gọi API tin tức ngoài.
6. Given bất kỳ câu mồi nào nói về người kia, when đọc hết câu, then nó kết
   thúc bằng một câu để hỏi người thật, không bằng một nhận định chốt hạ
   (R-1g).

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — màn (1) và sổ tay đã có.
- Điểm vào: đường vào riêng từ menu chính (nhóm CỬA VÀO).

## Dependencies
- Depends on: STORY-001 (kho chung), STORY-004 (sổ tay để de-genericize).
- Không yêu cầu story tương lai: xác nhận — STORY-007 chỉ **đọc lại** kho mồi
  đã giao.

## Open Question Impact
- OQ-3 — **ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Không còn chặn story này. Thành ràng buộc: kho mồi và gói sự kiện là
  **dữ liệu có schema + id bền** (R-15a); **N là thuộc tính dữ liệu**, hành vi
  hết-vòng phải đúng với mọi N chứ không phải cho seed 10 mục (R-15b); R-1b,
  chống tâng bốc, cấm %, cấm streak, R-1g cưỡng chế ở **cổng nhập chạy được**
  làm hỏng bản dựng (R-15c). Kiểm duyệt hai lớp (SB-123) giữ cho chất lượng
  biên tập, không còn là cơ chế cưỡng chế luật bất biến. Chi tiết: AC-25..AC-30,
  BR-15..BR-17 trong `requirements/requirements.md`.
- SB-144/145/146 (trò chơi "đoán") **không** thuộc story này; hoãn sang
  requirement sau theo triage cấp requirement.
