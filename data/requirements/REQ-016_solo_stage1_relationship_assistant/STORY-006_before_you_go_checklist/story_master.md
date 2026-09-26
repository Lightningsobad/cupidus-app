# Story Master: STORY-006 "Trước giờ đi" — checklist tất định (SB-211)

Status: PATCH_REQUIRED
Complexity: standard
Story-Class: standard
Implementation Lane: mobile (Tech Lead chốt 2026-09-11 — không AC nào cần
server và AC-22/AC-23 cấm mạng, nên backend lane không tham gia)
Requirement: REQ-016
Screen: Khối mở rộng trên chi tiết thẻ ở màn (1). **Không phải màn hình thứ 12**
— tổng vẫn là 11 màn hình.
Design-Screen: sb-211-truoc-gio-di (ios, resolved P2 — see
`visual-fidelity/visual-fidelity-report.md`; canvas frame has 6 logged
DESIGN_SPEC_CONFLICT items vs. binding ACs, ACs govern per standing
canvas-vs-AC precedent, not re-litigated)
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục E (SB-211),
A (J6), C.1

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`,
      `architecture/contract-summary.md`, `coding-plan/` (P1, P2)
- [x] Implementation (Development) — P1 + P2 DONE; F-1/F-2 patch round
      2026-09-11 closed both PATCH_REQUIRED findings (Story Runtime Startup
      Smoke PASS, Entry Point Reachability `Reachable: YES`), independently
      verified on disk incl. runtime-smoke capture; no source change made.
- [x] Review (Reviewer) — Round 2 re-review 2026-09-11: `Outcome: DEFERRED_ONLY`
      (0 blocking, 2 deferred: D-1 schemaId/schema_id doc-only, D-2
      `scheduledOn: '2026-10-01'` fixture time bomb — both routed to
      requirement backlog, not gating). `review/review-report.md`.

## Depends On
- STORY-001 — khối gắn trên chi tiết thẻ trạng thái *Đã hẹn ngày*.

## User Story
Là người sắp ra khỏi nhà đi hẹn, tôi muốn app nhắc đúng những thứ tôi hay quên
cho **buổi hẹn này**, để tôi không tới nơi mới phát hiện thiếu tiền mặt hay
thiếu áo mưa.

## In Scope
1. Khối "Trước giờ đi" **tự động hiện** trên chi tiết thẻ khi thẻ ở trạng thái
   *Đã hẹn ngày* **và** ngày hẹn = hôm nay.
2. Nội dung sinh **tất định bằng bảng tra tay** từ các trường có sẵn của thẻ —
   không AI, **không gọi API ngoài** (không thời tiết, không bản đồ):

   | Điều kiện trên thẻ | Gợi ý hiện ra |
   |---|---|
   | có giá > 0, hình thức trả tại chỗ | "mang đủ tiền mặt" |
   | khoảng cách vượt ngưỡng | "đổ xăng / sạc xe trước khi đi" |
   | mùa = mùa mưa theo miền | "mang áo mưa/ô, có phương án B trong nhà" |
   | cần đặt trước = có | "xác nhận lại chỗ đã đặt" |
   | luôn có | "chia sẻ vị trí" |

3. **Chỉ hiện mục khớp trường thật có trên thẻ.** Buổi xem phim trong nhà thì
   không có dòng "mang áo mưa".
4. Thẻ thiếu trường → khối ngắn hoặc trống. **Đây là hành vi chấp nhận được**,
   không phải lỗi, và app không thúc người dùng đi điền thêm trường.
5. **Một hành động chính duy nhất**: "Xong hết rồi, đi thôi" — đóng khối
   (SC-4).
6. "Chia sẻ vị trí" đi qua **OS Share Sheet có sẵn, một lần**. Không theo dõi
   thời gian thực. Đây là an toàn cá nhân của **chính người dùng**, không phải
   giám sát người kia — không vi phạm R-1b.

## Out of Scope
- Phản chiếu pha thứ tư lên widget — STORY-012.
- Báo thức thật / thông báo cưỡng bức: D-1 chỉ cần thông báo nhắc đủ mạnh.
- Theo dõi vị trí thời gian thực, chia sẻ vị trí liên tục, hoặc bất kỳ hình
  thức định vị nào của người kia (R-1b).
- Gọi API thời tiết, bản đồ, hoặc giao thông. Mùa mưa suy ra tất định theo miền
  và ngày, từ gói dữ liệu ship kèm.
- Bất kỳ mục checklist nào không suy được từ một trường thật trên thẻ.

## Acceptance Criteria
1. Given một thẻ ở trạng thái *Đã hẹn ngày* có ngày hẹn = hôm nay, when người
   dùng mở chi tiết thẻ, then khối "Trước giờ đi" hiện ra tự động, không cần
   thao tác bật.
2. Given ngày hẹn của thẻ **không** phải hôm nay, when người dùng mở chi tiết
   thẻ, then khối "Trước giờ đi" **không** hiện.
3. Given thẻ có giá > 0 và trả tại chỗ, khoảng cách vượt ngưỡng, và cần đặt
   trước, when khối hiện ra, then đúng ba dòng tương ứng cộng dòng "chia sẻ vị
   trí" xuất hiện.
4. Given một thẻ xem phim trong nhà không có trường mùa mưa, when khối hiện ra,
   then **không** có dòng "mang áo mưa/ô".
5. Given một thẻ gần như trống trường, when khối hiện ra, then khối chỉ có dòng
   "chia sẻ vị trí" hoặc trống, và app không hiện lời nhắc đi điền thêm trường.
6. Given khối đang hiện, when người dùng bấm "Xong hết rồi, đi thôi", then khối
   đóng lại và không hiện lại cho thẻ đó trong ngày.
7. Given người dùng bấm "chia sẻ vị trí", when hành động chạy, then app mở OS
   Share Sheet **một lần** và không bật bất kỳ chế độ theo dõi vị trí liên tục
   nào.
8. Given thiết bị không có mạng, when khối hiện ra, then toàn bộ nội dung vẫn
   đúng vì nó sinh tất định từ trường của thẻ và gói dữ liệu tĩnh.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — chi tiết thẻ ở màn (1).
- Điểm vào: tự động, không cần người dùng tìm. Không thêm destination mới.

## Dependencies
- Depends on: STORY-001 (thẻ, trạng thái, và các trường giá/khoảng cách/đặt
  trước/mùa).
- Không yêu cầu story tương lai: xác nhận.

## Open Question Impact
- Không có câu hỏi mở nào chặn story này.
- OQ-3 — **ĐÃ ĐÓNG 2026-09-06 (user) bằng D-15 → luật R-15** (`req_master.md`
  mục 15). Kiểm duyệt hai lớp vẫn **không** áp (BR-14: dòng checklist là nhãn
  chức năng). Nhưng **R-15 có áp** vì story ship một **bảng tra tay kèm app**:
  gói dữ liệu có schema + id bền, cấm chuỗi cứng trong widget/code (R-15a); số
  dòng là thuộc tính dữ liệu, khối thưa hợp lệ với mọi N kể cả N = 0 (R-15b);
  ranh giới BR-14 thành cổng nhập chạy được (R-15c). Chi tiết: AC-29..AC-31,
  BR-15..BR-17 trong `requirements/requirements.md`.
