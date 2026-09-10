# Phase P8 – Hợp đồng ghi trường sau khi tạo

## 1. Objective

Cho `ActivityCardRepository` một đường ghi trường sau khi tạo, để những gì màn
chi tiết cho người dùng sửa thật sự nằm trong store chứ không chỉ trong bộ nhớ
của cubit. Đây là chỗ khoá lỗi mất dữ liệu âm thầm của AC-15.

## 1A. Ownership

- Phase ID: P8
- Canonical Phase File: `phase-P8-card-field-write-path.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2, P6
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/activity_cards/domain/activity_card_repository.dart`
  - `mobile/lib/features/activity_cards/domain/activity_card.dart`
  - `mobile/lib/features/activity_cards/data/activity_card_repository_impl.dart`
  - `mobile/lib/core/database/daos/activity_card_dao.dart`
  - `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart`
  - `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart`
  - `mobile/test/features/activity_cards/card_lifecycle_ui_test.dart`
  - `mobile/test/features/activity_cards/activity_card_repository_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: REQUIRED (phán quyết R-2, `master-plan.md` §6)
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `updateCardDetails(String cardId, ActivityCardEdit edit)` — đường ghi trường
    dùng chung cho 11 story tiêu thụ hợp đồng shared-foundation này
  - `ActivityCardEdit` (11 trường sửa được) + `ActivityCardEdit.from(card)`
  - `updateStatus` / `clearScheduledDate` trả `Future<int>` row count
- Shared Interfaces Consumed:
  - repository thẻ và `ActivityCard` (P2); DAO thẻ (P1); màn chi tiết + cubit (P6)
- Risk Surfaces:
  - AC-15 mất dữ liệu âm thầm khi lùi trạng thái (nguyên nhân gốc, không phải
    triệu chứng ở tầng UI)
  - AC-12 đặt/đổi ngày không kèm chuyển trạng thái
  - S2-F2-3: row count bị bỏ rơi nên "không phải thẻ của mình" không phân biệt
    được với "ghi thành công"
- Source Of Truth:
  - authoritative artifact: `master-plan.md` §7 (đặc tả Tech Lead của B-2)
  - consumer contract: STORY-002+ đọc hợp đồng này; STORY-007 thêm đường ảnh
    **không** sửa dòng nào của P8 (§7.8)
- Primary Inputs Summary:
  - requirements: AC-6, AC-12, AC-15, AC-17, AC-18
  - architecture: `../architecture/solution.md` §4 Contracts And Integrations
  - upstream phase outputs: P1 (DAO), P2 (hợp đồng gốc), P6 (màn chi tiết)
  - review findings: B-2, B-3; deferred gom vào: S2-F2-3, S6-F-2, S4-F-4, S6-F-6
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — đường ghi trường từ hợp đồng xuống SQLite và lên
    lại màn chi tiết.
  - Source/Test File Count: 8
  - Split Required: NO

## 2. Required Reads

- `master-plan.md` §7 (toàn bộ — đây là đặc tả gốc của phase này)
- `../review/review-report.md` § B-2, § B-3
- `phase-P2-card-domain-repository.md` §1B Shared Interfaces Produced

## 3. Tasks

- Thêm `updateCardDetails(String cardId, ActivityCardEdit edit)` vào hợp đồng
  repository. Ngữ nghĩa **ảnh chụp toàn phần**: mọi trường trong `edit` được ghi
  đúng như đưa vào, nên `null` là lệnh xoá cột, không phải "giữ nguyên". Không
  bao giờ chạm `id`, `owner_key`, `status`, `origin`, `created_at`; luôn bump
  `updated_at`. Trả số hàng đã ghi — `0` nghĩa là thẻ không thuộc owner hiện tại.
- Thêm `ActivityCardEdit` vào `domain/activity_card.dart` với đúng 11 trường sửa
  được: `title`, `activityType`, `scheduledOn`, `priceVnd`, `distanceKm`,
  `needsBooking`, `indoorOutdoor`, `note`, `sourceLink`, `invited`, `replyState`.
  Kèm `factory ActivityCardEdit.from(ActivityCard card)` để cubit gọi một dòng.
- Đổi `updateStatus` và `clearScheduledDate` từ `Future<void>` sang `Future<int>`
  (đóng S2-F2-3).
- Hiện thực ở `ActivityCardRepositoryImpl` bằng `ActivityCardsCompanion` **gọi
  tên đủ mọi cột sửa được**, để một `null` đi xuống SQLite thành `NULL` thật chứ
  không thành "bỏ qua cột".
- DAO ghi có `WHERE id = ? AND owner_key = ?` và trả row count. (Đã có sẵn từ P1
  — kiểm tra rồi mới kết luận là không cần sửa.)
- Nối `ActivityCardDetailCubit`: mỗi lần sửa trường gọi `updateCardDetails` ngay,
  rồi mới `emit`. **Ghi-rồi-emit**, không emit lạc quan: `state.card` không bao
  giờ được nói một giá trị mà store không giữ. `rows == 0` hoặc lỗi ghi →
  `failed: true` và state đứng yên.
- Màn chi tiết quyết định **thời điểm** ghi: ô văn bản ghi khi submit hoặc mất
  focus (một câu gõ vào ghi chú là một lần ghi row, không phải bốn mươi); điều
  khiển rời rạc (chip, toggle, date picker) ghi ngay khi chốt. Tiêu đề rỗng
  không bao giờ ghi xuống, và ô được trả về giá trị đang lưu (S6-F-6).

## 4. Acceptance Criteria

- Đặt ngày ở màn chi tiết rồi mở lại thẻ: ngày còn nguyên trong store (AC-12).
- Lùi trạng thái sau khi đã hẹn ngày: `_needsScheduledDateQuestion` thấy
  `scheduled_on` có giá trị nên câu hỏi AC-15 bật lên; nhánh "giữ" giữ thật.
- Sửa từng trường SB-76 rồi đọc lại: giá trị mới nằm trong store; xoá trường về
  rỗng thì cột thành `NULL`.
- Ghi vào thẻ của owner khác trả `0` và không đổi hàng nào.
- `invited` / `replyState` bền qua vòng dispose (AC-17, AC-18; đóng S6-F-2,
  S4-F-4).

## 5. Planned Outputs

- Code: hợp đồng repository, `ActivityCardEdit`, impl, detail cubit, màn chi tiết.
- Tests: sửa hai test ở §7.6 của master-plan + test repository cho đường ghi mới.
- Notes: bằng chứng test ghi vào `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope` (`master-plan.md` §7.6)
- Platform / Surface: Flutter mobile, tầng domain/data + presentation
- Required levels:
  - unit: repository/DAO cho đường ghi mới, gồm nhánh row count `0`
  - widget: màn chi tiết ghi thật qua cubit, gồm nhánh store từ chối ghi
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
- Required checks:
  - **Sửa test bắt buộc, không phải dọn dẹp tuỳ chọn.** Suite xanh không phải
    bằng chứng ở đây: hai test đang chứng nhận lỗi là hành vi đúng.
    `card_lifecycle_ui_test.dart:266–278` bật đèn xanh cho cú lùi trạng thái âm
    thầm; `:127–138` tên là *"picking a date saves it"* trong khi assert rằng
    ngày **không** được lưu. Cả hai phải assert persistence thật.
  - Test repository: ghi đủ 11 cột và **không** chạm `id`/`owner_key`/`status`/
    `origin`/`created_at`.
  - Test repository: trường `null` xoá cột, không phải bỏ qua cột.
  - Test repository: ghi thẻ của owner khác trả `0`, không đổi gì.
  - Test widget: ghi bị từ chối thì màn không nhúc nhích (trạng thái không đi
    trước store).
- Minimum gates by risk surface: cả ba risk surface ở §1B đều có gate ở trên.
- Evidence format: output `flutter test` ghi vào `coding-plan/test-results.md`.
- Per-story visual fidelity: NOT_APPLICABLE cho P8 — phase này không thêm bề mặt
  hiển thị mới; gate visual fidelity của màn chi tiết thuộc P6.
- Startup smoke: REQUIRED sau khi P8 và bản vá P4/P6 cùng vào (phán quyết R-2).
  Một lần chạy DI thật bằng `main.dart` (không `main_preview.dart`, không
  fixture): migration v2→v3 trên máy đã cài schema v2, phiên chưa ghép đôi vào
  hub solo, mở một thẻ sang màn chi tiết P6.
- Verification strategy:
  - Targeted tests: `flutter test test/features/activity_cards/`
  - Build/type-check: `flutter analyze lib test`
  - Required assertion evidence: tên test + kết quả pass.

## 7. Constraints

- **S2-F2-1 (ảnh) giữ DEFERRED**, không gom vào P8 — chuyển chủ sở hữu sang
  STORY-007 (`master-plan.md` §7.8). Gom vào sẽ đẩy P8 quá một specialist
  lifecycle trong khi B-3 lại bắt P8 merge cùng vòng với bản vá P4/P6.
- **Ràng buộc B-3**: P8 và bản vá P4/P6 phải cùng vào một vòng merge. P8 một
  mình sửa đường ghi mà không ai thấy; P4/P6 một mình biến lỗi tiềm ẩn thành lỗi
  lộ mặt người dùng.
- Đánh đổi đã chấp nhận của ảnh chụp toàn phần: người ghi sau đè người ghi
  trước. Chấp nhận được vì store cục bộ một người dùng, mỗi lúc chỉ một màn
  detail mở.

## 8. Status

- Status: CODE_COMPLETE_PENDING_GATE
- Last updated: 2026-09-08
- Evidence: `coding-plan/test-results.md` § Phase P8
- Đã đóng: đường ghi trường (`updateCardDetails` + `ActivityCardEdit`),
  `updateStatus`/`clearScheduledDate` trả `Future<int>`, cubit ghi ngay từng
  chỉnh sửa. Cả 8 implementer đã sửa sau khi WriteScope được mở rộng;
  `flutter analyze lib test` 0 error, suite phạm vi `+230 ~3` xanh.
- Blocker còn lại: startup smoke R-2 không thoả được điều kiện "phiên chưa ghép
  đôi vào thẳng hub solo". `pair_gate_shell.dart:142` chặn phiên chưa ghép đôi
  vào `PairingChoiceScreen` trước `HomeScreen`, nên `_SoloHomeGate` không bao giờ
  chạy trong sản xuất và migration v2→v3 cũng không được kích hoạt. File đó
  ngoài WriteScope và việc bỏ cổng ghép đôi cho Stage-1 solo là quyết định
  kiến trúc/sản phẩm ngoài `master-plan.md` §7.
