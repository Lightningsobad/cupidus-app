# Story Master: STORY-010 Bảng tra ăn khớp

Status: TODO
Complexity: complex
Story-Class: standard
Implementation Lane: mobile (Tech Lead chốt 2026-09-11 — **không có lane
backend**: AC-28/AC-29 cấm mọi lời gọi mạng, phần "cổng nhập nội dung" là Dart
validator chạy trong `mobile/test/`, không phải service. Xem
`architecture/solution.md` §1 Key Discovery 1.)
Requirement: REQ-016
Screen: Bảng tra ăn khớp — màn (10), **nhóm KHOÁ VỊ TRÍ**. Chỉ vào được từ luồng
(5) gợi ý quà hoặc (9) kịch bản buổi hẹn đang chạy.
Spec reference: `idea.md` → `## Đặc tả sản phẩm (vòng 9-10)` mục C.10, D (SC-6),
F (3f); `req_master.md` R-7, R-8, R-13

## Artifacts
- [x] Requirements (Product Owner) — `requirements/requirements.md`
- [x] UX Design (UI/UX Designer) — `ux/uiux-spec.md`
- [x] Architecture (Tech Lead) — `architecture/solution.md`,
  `architecture/contract-summary.md`
- [x] Coding Plan (Tech Lead) — `coding-plan/master-plan.md`,
  `coding-plan/coding-agent-guide.md`, sáu file phase P1–P6
- [x] Implementation (Development) — mobile-dev P1-P6 complete per
  `coding-plan/master-plan.md` Phases Overview (all Status: COMPLETE)
- [ ] Review (Reviewer)

## Depends On
- STORY-004 — vào từ luồng gợi ý quà; đọc sổ tay để lấy dữ liệu người dùng tự
  nhập.

## User Story
Là người muốn chuẩn bị cho mối quan hệ này, tôi muốn biết chỗ nào hai đứa dễ
hợp và chỗ nào dễ va, để tôi lường trước thay vì bất ngờ.

## In Scope
1. **Bảng tra tay ship như gói dữ liệu**, runtime tất định: 144 ô hoàng đạo và
   256 ô MBTI. **Không AI ở runtime** (R-7). Việc **soạn đủ 400 ô** nằm trong
   phạm vi story này (user chốt lối (a), 2026-09-06): giữ cả hai trục, không
   cắt trục MBTI.
2. **Mỗi ô bắt buộc có ít nhất một điểm cọ xát**, không chỉ lời khen (R-7).
3. **Đầu ra bắt buộc là bộ bốn**, đủ cả bốn mục, không thiếu mục nào:
   *chỗ dễ hợp · chỗ dễ va · 1 hoạt động nên thử · 1 câu để hỏi*.
4. **Hiển thị DẢI, không hiển thị %** (R-8). Không có điểm số, không có thanh
   phần trăm, không có "hợp 87%".
5. Đầu vào là dữ liệu **người dùng tự nhập** (R-1a): dấu hoàng đạo / MBTI của
   mình và của người kia do chính người dùng ghi hoặc đoán, lấy từ sổ tay hoặc
   hỏi tại chỗ.
6. **SC-6 / R-13 — khoá vị trí**: chỉ tới được bằng một liên kết trong luồng
   (5) hoặc (9). Không có trong menu chính, không có trong tab bar.
7. Mục "1 hoạt động nên thử" có hành động đẩy thành một thẻ vào màn (1) (SC-2).
8. Kiểm duyệt nội dung hai lớp (SB-123) cho toàn bộ 144 + 256 ô; lớp 2 của bộ
   seed là **user** (D-15).
9. **Cổng nhập nội dung theo R-15** (D-15): gói có schema + id ô ổn định, kích
   thước trục và tập nhãn DẢI đọc từ dữ liệu, và bản dựng **hỏng** khi một ô vi
   phạm R-1b / chống tâng bốc / cấm % / cấm streak, hoặc khi độ phủ thiếu ô.

## Out of Scope
- Bất kỳ con số phần trăm, điểm số, hay xếp hạng ăn khớp nào — R-8 cấm.
- Suy ra dấu hoàng đạo / MBTI của người kia từ dữ liệu app tự thu — R-1(d-sai)
  cấm. Người dùng phải tự nhập.
- Sinh nội dung ăn khớp bằng AI ở runtime — R-7 cấm.
- Định vị "app bói toán" (R-10): màn này là công cụ chuẩn bị, không phải lời
  tiên tri.
- Đường vào từ menu chính hoặc tab bar — vi phạm SC-6.
- Chân dung "theo cách BẠN nhìn" — STORY-009.

## Acceptance Criteria
1. Given người dùng đang ở luồng gợi ý quà hoặc kịch bản buổi hẹn, when họ bấm
   liên kết tới bảng tra ăn khớp, then màn mở ra; và given họ duyệt menu chính
   và tab bar, then **không** có mục nào dẫn tới nó (SC-6/R-13).
2. Given đủ dữ liệu hai bên do người dùng tự nhập, when kết quả hiện ra, then
   nó có đủ **cả bốn** mục: chỗ dễ hợp, chỗ dễ va, 1 hoạt động nên thử, 1 câu
   để hỏi.
3. Given bất kỳ ô nào trong bảng tra, when kết quả hiện ra, then luôn có ít
   nhất một điểm cọ xát, không có ô nào chỉ toàn lời khen (R-7).
4. Given kết quả hiện ra, when người dùng đọc toàn màn, then **không** có bất
   kỳ con số phần trăm, điểm số, hay thanh tỉ lệ nào — chỉ có DẢI (R-8).
5. Given người dùng chưa nhập dấu hoàng đạo/MBTI của người kia, when họ mở màn,
   then app **hỏi tại chỗ** để người dùng tự nhập, và **không** tự suy ra từ bất
   kỳ nguồn nào khác (R-1a, R-1(d-sai)).
6. Given mục "1 hoạt động nên thử", when người dùng bấm hành động chính, then
   một thẻ mới xuất hiện ở màn (1), trạng thái *Mới nghĩ ra* (SC-2).
7. Given thiết bị không có mạng, when kết quả hiện ra, then nội dung vẫn đúng
   và đầy đủ vì bảng tra là gói dữ liệu tĩnh, runtime tất định.

## System Integration And Discoverability
- UI-facing story: YES.
- Existing user-visible surface: YES — luồng gợi ý quà (STORY-004).
- Điểm vào: **duy nhất** từ một liên kết trong luồng (5) hoặc (9) đang chạy.
  Direct URL only acceptable: **NO** — điều hướng trực tiếp bằng route là vi
  phạm luật khoá vị trí.

## Dependencies
- Depends on: STORY-004 (cửa vào và sổ tay). Theo SB-174, story này chạy sau
  STORY-004/005/008 — vỏ hoàng đạo chỉ được phủ lên sau khi quà/mồi chuyện/kịch
  bản đã hết chung chung.
- Không yêu cầu story tương lai: xác nhận.

## Open Question Impact
- **OQ-3 — ĐÃ ĐÓNG 2026-09-06 (user), D-15.** Đội AI soạn offline trong lúc
  delivery; user duyệt bộ seed; duyệt lâu dài chuyển sang CMS ngoài repo; nội
  dung bản đầu ship kèm app. Không còn mục nào của story này bị chặn.
- Khối lượng **"10 mục / gói xoay vòng"** của D-15 **không áp** cho story này:
  bảng tra là gói **phủ toàn phần**, ràng buộc đúng là **độ phủ 100%** (AC-38).
- Ràng buộc chống tâng bốc, cấm %, và R-1b nay là **validation ở tầng schema**
  chạy trên cả 400 ô (AC-37), không phải lời hứa biên tập — vì nội dung CMS
  tương lai không đi qua review của repo này.
- Chi tiết: `requirements/requirements.md` → `## Open Question Impact`,
  `### Nhóm J`, BR-14, BR-15.
