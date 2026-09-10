# Master Coding Plan – Kho thẻ hoạt động (activity card hub)

## 1. Planning Metadata

- Story ID: STORY-001 (REQ-016)
- Complexity: complex (Story-Class: shared-foundation)
- Requirement Configuration Guide impact: NOT_APPLICABLE — story không thêm env
  var, secret, hay tích hợp bên thứ ba nào (`../architecture/solution.md` §4).

## 2. Planning Goal

- Shared contract owner: Mobile Developer (P1 + P2), theo
  `../architecture/contract-summary.md`.
- Contract-first phase required: NO — cùng một specialist viết hợp đồng và toàn
  bộ consumer trong story này, tuần tự, trong một lane duy nhất. Hợp đồng nằm
  trong P1/P2 chứ không tách phase riêng.
- Parallel execution possible: NO — single lane (mobile).
- Critical path: P1 → P2 → P4 → P7 → P5/P6.
- Parallelism notes: P3 (gói dữ liệu dịp) chỉ phụ thuộc P2 và có thể chạy xen
  giữa P2 và P4 nếu lịch cho phép; mọi phase còn lại tuần tự.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| Bảng `activity_cards` + `activity_card_photos` | Mobile Developer | P1 | P2, STORY-002/004/005/006/007/008/011/012/013 | `../architecture/contract-summary.md` §3 |
| `createCard` + `ActivityCardStatus` + định danh `origin` | Mobile Developer | P2 | P4, P5, P6, và 11 story sau | `../architecture/contract-summary.md` §1, §2 |
| Gói nội dung `ContentPackage` (asset JSON có `id`+`version`) | Mobile Developer | P3 | P5, kho preset của STORY-002+ | `../architecture/contract-summary.md` §2 |
| `ActivityType` — từ vựng đóng của `activity_type` | Mobile Developer | P7 | P5, P6, STORY-002/004/005/006/007/008/011/012/013 | `../architecture/contract-summary.md` §2, §3 |
| `updateCardDetails` + `ActivityCardEdit` — cửa ghi cho trường sau khi tạo | Mobile Developer | P8 | P6, STORY-002/004/005/006/007/008/011/012/013 | §7 dưới đây (bổ sung cho `../architecture/contract-summary.md` §1) |
| 5 cột B-1 + `TimeOfDaySlot` + `schemaVersion` 4 | Mobile Developer | P11 | P12, P13, STORY-002/004/006/007/008 | `../architecture/contract-summary.md` §3 (đã vá theo B-1), `../ux/uiux-spec.md` §8 |
| Formatter/parser hiển-thị-vs-bộ-đệm (giá · khoảng cách · thời lượng) | Mobile Developer | P12 | P13 | §11 dưới đây, AC-8 khối "Định dạng hiển thị vs. bộ đệm sửa" |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Mất dữ liệu gốc khi đăng xuất | P1 |
| R-1b — trôi schema sang đo hành vi người kia | P1 |
| Migration v2→v3 trên máy đã cài | P1 |
| Migration v3→v4 trên máy đã cài (B-1, 5 cột mới) | **P11** |
| R-1b — trôi schema sang đo hành vi người kia (đợt cột B-1) | **P11**, **P13** |
| Chuỗi đã định dạng rò xuống tầng dữ liệu (A-2) | **P12** |
| SC-1' — danh sách thứ hai | P1 |
| AC-15 mất dữ liệu âm thầm khi lùi trạng thái | P2, P6, **P8** |
| SC-4/SC-5 — đúng một hành động chính, không ngõ cụt | P2, P4, P6 |
| Vỡ hợp đồng cho 11 story sau | P2, P7 |
| R-7/BR-8 — AI hoặc API nội dung ở runtime | P3 |
| R-15a/R-15b — id bền, N là dữ liệu | P3 |
| Điểm vào không tới được | P4 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, command/source runtime registry
    `mobile-app.testCommand` (`flutter test`), `buildCommand`
    (`flutter build apk --debug`), launch path `scripts/run-mobile.sh`.
  - Startup smoke (rule 12g): **REQUIRED một lần ở cấp story**, chạy cuối vòng
    patch. Không phải phase implementation nào cũng chạy: từng phase vẫn
    `NOT_APPLICABLE`. Xem phán quyết R-2 ở §6.
  - Cập nhật 2026-09-08: R-2 vẫn **REQUIRED** và giữ nguyên 4 điều kiện, nhưng
    lần chạy trên emulator-5554 sau P8 là **INVALID-FOR-GATE**, không phải
    FAILED: nó đo trên bản dựng mà bề mặt solo còn bị cổng gốc chặn. Chạy lại
    sau khi P9 (§8) vào. Xem §6 → "Cập nhật R-2".
  - Cập nhật 2026-09-09 (B-1/P11): R-2 vẫn một lần ở cấp story, nhưng điều kiện
    migration của nó rộng thêm — lần chạy cuối phải phủ chuỗi **v2→v3→v4**, vì
    P11 (§10) đưa `schemaVersion` lên 4. Không thêm lần chạy smoke nào cho
    P11/P12/P13; từng phase vẫn `NOT_APPLICABLE`.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | DONE |
| P3 | Mobile Developer | Mobile | P2 | NO | DONE |
| P4 | Mobile Developer | Mobile | P2 | NO | PATCHED_PENDING_GATE |
| P7 | Mobile Developer | Mobile | P4 | NO | DONE |
| P5 | Mobile Developer | Mobile | P3, P4, P7 | NO | PATCHED_PENDING_GATE |
| P6 | Mobile Developer | Mobile | P4, P7 | NO | PATCHED_PENDING_GATE |
| P8 | Mobile Developer | Mobile | P2, P6 | NO | PATCHED_PENDING_GATE |
| P9 | Mobile Developer | Mobile | P4, P8 | NO | PATCHED_PENDING_GATE |
| P10 | Mobile Developer | Mobile | P2, P9 | NO | PLANNED |
| P11 | Mobile Developer | Mobile | P8 | NO | PLANNED |
| P12 | Mobile Developer | Mobile | P11 | NO | PLANNED |
| P13 | Mobile Developer | Mobile | P11, P12 | NO | PLANNED |
| P14 | Mobile Developer | Mobile | P11, P12, P13 | NO | PLANNED |

Số hiệu phase là append-only, nên P7 lớn hơn P5/P6 về số nhưng chạy **trước**
chúng. Thứ tự thực thi đọc ở cột `Depends On`, không đọc theo số hiệu.

P11/P12/P13 là ba phase mới sinh từ vòng phán quyết thiết kế 2026-09-09
(A-1/A-2/A-3/A-4/B-1 do user chốt, cộng D-24+D-25 và R8-F-2/D-20 do Scrum
Master chốt) — chi tiết ở §10, §11, §12. Cả ba đều **lane Mobile**, không có
phần devops: B-1 chạm Drift schema cục bộ trong app, không chạm hạ tầng,
không chạm runtime registry, không chạm biến môi trường.

Vòng patch sau slice review (`../review/review-report.md`, `Outcome:
PATCH_REQUIRED`):

| Phase | Trạng thái sau review | Lý do |
|-------|-----------------------|-------|
| P1 | DONE — đóng, không review lại | Không finding nào chạm file của P1 (S1 sạch) |
| P2 | DONE — đóng, không review lại | Hợp đồng gốc giữ nguyên; phần bổ sung nằm ở P8 |
| P3 | DONE — đóng, không review lại | S3 sạch; mọi finding còn lại là DEFERRED |
| P7 | DONE — đóng, không review lại | Nửa P7 của S2 sạch; `ActivityType` không đổi |
| P4 | PATCHED_PENDING_GATE | B-1 đã nối điều hướng thật (empty state → capture, chạm thẻ → màn detail P6); S4-F-3 nằm ngoài WriteScope |
| P5 | PATCHED_PENDING_GATE | B-5 nửa code đã đóng (xoá placeholder `_QuickEntryStrip`, mount strip thật); kèm S5-F-4 fallback cuộn ngang |
| P6 | PATCHED_PENDING_GATE | B-1 điểm đến detail + B-4 (3 test đỏ) đã đóng |
| P8 | PATCHED_PENDING_GATE | B-2 đã hiện thực trên cả 8 implementer, analyze 0 error; blocker còn lại là startup smoke R-2 (xem `phase-P8-card-field-write-path.md` §8) |
| P9 | PATCHED_PENDING_GATE | Đích điều hướng mới đã xác nhận chạy thật trên máy (`test-results.md` dòng 1146); phần code của P9 đóng |
| P10 | PLANNED | Nạp lại khoá chủ `owner_key` lúc khởi động nguội — defect R-2 phát hiện, chặn toàn bộ đường đọc/ghi thẻ của người dùng quay lại app (§9) |

Ràng buộc B-3: P8 và bản vá P4/P6 phải **cùng** vào một vòng merge. P8 một mình
sửa đường ghi mà không ai thấy; P4/P6 một mình biến lỗi tiềm ẩn thành lỗi lộ
mặt người dùng. Không phase nào trong cặp này được merge lẻ.

`PATCHED_PENDING_GATE` nghĩa là code của bản vá đã nằm trong worktree và test
nhắm đích đã xanh, nhưng gate cấp story (`flutter analyze lib test`, `flutter
test`, startup smoke R-2) **chưa** chạy được: §7.9 ước lượng P8 ~7 file mà không
tính sáu implementer giả của chính hợp đồng nó đổi, nên cây nguồn chưa biên dịch
cho tới khi WriteScope được mở rộng. Chi tiết ở `test-results.md` § Phase P8.

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-local-card-store.md` |
| P2 | `phase-P2-card-domain-repository.md` |
| P3 | `phase-P3-occasion-content-package.md` |
| P4 | `phase-P4-hub-list-and-entry-point.md` |
| P5 | `phase-P5-minute-one-empty-state-and-capture.md` |
| P6 | `phase-P6-card-detail-lifecycle-delete.md` |
| P7 | `phase-P7-activity-type-enum-and-card-icon.md` |
| P8 | `phase-P8-card-field-write-path.md` (mobile-dev tạo từ §7) |
| P9 | `phase-P9-unpaired-root-to-solo-surface.md` (mobile-dev tạo từ §8) |
| P10 | `phase-P10-cold-start-owner-key-rehydration.md` (mobile-dev tạo từ §9) |
| P11 | `phase-P11-b1-card-field-schema-extension.md` (mobile-dev tạo từ §10) |
| P12 | `phase-P12-a2-vi-number-display-vs-edit-buffer.md` (mobile-dev tạo từ §11) |
| P13 | `phase-P13-a1-a3-a4-detail-header-and-block-order.md` (mobile-dev tạo từ §12) |

Artifact hygiene:

- Mỗi phase id ánh xạ đúng một file `phase-Px-*.md`.
- Phase mobile giữ trong một specialist lifecycle (roughly six source/test
  files) hoặc bị tách.
- Không có phase verification/testing đuôi; mỗi phase tự chạy test của nó.
- Test scope của phase không chứa e2e trình duyệt, trace, hay startup smoke.

## 6. Notes

- P1 phải bump `CupidDatabase.schemaVersion` lên 3 **cộng thêm**; bảng thẻ là dữ
  liệu gốc nên cấm migration huỷ-tạo-lại (khác bảng cache theo ADR-015.6).
- P4 là phase wiring điểm vào: nhánh solo của tab "Nhà". Không tạo route/tab mới.
- P7 đóng delta D-5 và **không** chạm `schemaVersion`: cột `activity_type` giữ
  nguyên `TEXT NULL`, chỉ kiểu Dart đổi qua Drift `TypeConverter`. Vì không có
  DDL nào chạy, ràng buộc "cấm migration huỷ-tạo-lại" ở trên vẫn nguyên vẹn.
  Converter đọc khoan dung (chuỗi lạ → `null`) nên hàng đã có giá trị tự do trên
  máy đã cài không bị mất.

### Phán quyết R-2 — rule 12g startup smoke: **REQUIRED**

Story này **phải** có startup smoke thật; khai báo `NOT_APPLICABLE` cũ ở §4 là
sai và đã được sửa. Lý do: story chạm đúng ba thứ mà chỉ lần khởi động thật mới
bắt được, và không widget test nào thấy — (1) P1 bump `CupidDatabase.schemaVersion`
2→3 với migration chạy trên máy đã cài, một migration ném lỗi sẽ giết app ngay
lúc mở DB; (2) P2 đăng ký repository vào DI thật; (3) P4 đổi màn mặc định của
phiên chưa ghép đôi. Harness preview (`main_preview.dart` +
`PREVIEW_SOLO_HUB_FIXTURE=true`) đi vòng qua cả DI thật lẫn DB thật bằng một
fixture repository ném lỗi ở mọi đường ghi, nên nó chứng minh app **biên dịch và
mở được**, không chứng minh được cổng 12g.

Chạy một lần, cuối vòng patch, sau khi P4/P6 (B-1) đã mount xong — đó chính là
đường mã 12g cần đi qua. Bằng chứng ghi vào `../test-results.md`, thay cho khẳng
định ở `test-results.md:391`:

- Khởi động qua `scripts/run-mobile.sh android` (hoặc `ios`) — `main.dart` thật,
  **không** `main_preview.dart`, **không** `PREVIEW_SOLO_HUB_FIXTURE`.
- Nâng cấp DB thật: mở app trên bản cài có schema v2 sẵn để migration v2→v3 thực
  sự chạy, không chỉ tạo mới v3.
- Phiên chưa ghép đôi vào thẳng màn solo hub; mở một thẻ tới màn detail (P6).
- Log khởi động không có exception; đính kèm đoạn log và ảnh chụp màn hub.

Cổng này thuộc Scrum Master + reviewer; mobile-dev thu thập bằng chứng trong
cùng vòng patch. `scripts/run-mobile.sh` là `interactive: true`, `ciSafe: false`
trong runtime registry, nên đây là bước chạy tay có người, không phải lệnh CI.

#### Cập nhật R-2 (2026-09-08) — trạng thái: **REQUIRED, chưa đo được, chờ P9**

Phán quyết REQUIRED và 4 điều kiện ở trên **không đổi**. Đổi ở chỗ khác: lần
chạy thật của mobile-dev trên emulator-5554 (`main.dart` thật) không phải một
lần đo hỏng của P8, mà là một lần đo **không hợp lệ cho cổng** — bản dựng lúc
đó không có đường nào tới bề mặt solo, nên 3 trong 4 điều kiện không thể đúng
dù code của P4/P6/P8 đúng:

- `pair_gate_shell.dart:142` đưa phiên chưa ghép đôi tới `PairingChoiceScreen`
  trước khi `HomeScreen` kịp dựng, nên nhánh solo của `_SoloHomeGate`
  (`home_screen.dart:199-210`) không bao giờ chạy trong bản dựng thật.
- Vì `HomeScreen` không dựng, `ActivityCardRepository` không được chạm, DB
  không mở theo đường của story → migration v2→v3 không chạy (`cupid.sqlite`
  giữ nguyên 36864 byte) và màn detail P6 không tới được.
- Điều kiện duy nhất đạt ("log khởi động không có exception") vẫn giữ giá trị:
  nó chứng minh P8 không làm chết app lúc mở.

Xử lý: P9 (§8) mở cổng gốc; sau khi P9 vào cùng vòng merge B-3, chạy lại R-2
**nguyên văn 4 điều kiện cũ**, trên máy đã cài schema v2. Không nới điều kiện,
không đổi phương pháp đo. Bằng chứng cũ giữ lại trong `../test-results.md` với
nhãn `INVALID-FOR-GATE (pre-P9)` để lần sau không bị đọc nhầm là FAILED.

## 7. P8 — hợp đồng ghi trường sau khi tạo (bổ sung B-2)

Phase mới, owner Mobile Developer, lane `mobile`, `Depends On: P2, P6`, không
song song. Đây là phần Tech Lead sở hữu trong B-2; phần code Dart do mobile-dev
viết từ đặc tả này.

### 7.1 Vấn đề

`ActivityCardRepository` có đúng bốn đường ghi (`createCard` chỉ insert,
`updateStatus`, `clearScheduledDate`, `deleteCard`) và **không có** đường nào ghi
trường sau khi tạo. `ActivityCardDetailCubit._edit` chỉ `emit` thẻ trong bộ nhớ.
Hệ quả thật: store đạt `status = 'scheduled'` với `scheduled_on = NULL`, nên trên
lối đi thường của AC-15 (hẹn ngày hôm nay, lùi trạng thái tuần sau) ngày và ghi
chú đã mất từ lúc dispose, `_needsScheduledDateQuestion` trả `false`, và cú lùi
ghi thẳng — vừa không giữ dữ liệu vừa không hỏi. Cả hai vế `then` của AC-15 hỏng.

### 7.2 Hợp đồng thêm vào

Trong `mobile/lib/features/activity_cards/domain/activity_card_repository.dart`:

```dart
/// Ghi trọn bộ trường người dùng sửa được của một thẻ, trong một transaction
/// (AC-12/AC-15). Không bao giờ chạm `id`, `owner_key`, `status`, `origin`,
/// `created_at`; luôn bump `updated_at`. Ngữ nghĩa ảnh chụp toàn phần: mọi
/// trường trong [edit] được ghi đúng như đưa vào, nên `null` là lệnh xoá cột.
/// Trả về số hàng đã ghi — `0` nghĩa là thẻ không thuộc owner hiện tại.
Future<int> updateCardDetails(String cardId, ActivityCardEdit edit);
```

Trong `domain/activity_card.dart`, thêm `ActivityCardEdit` — đúng 11 giá trị
sửa được mà màn detail đang cho sửa: `title`, `activityType`, `scheduledOn`,
`priceVnd`, `distanceKm`, `needsBooking`, `indoorOutdoor`, `note`, `sourceLink`,
`invited`, `replyState`. Kèm `factory ActivityCardEdit.from(ActivityCard card)`
để cubit gọi một dòng.

Đổi `updateStatus` và `clearScheduledDate` từ `Future<void>` sang `Future<int>`
trả số hàng đã ghi (đóng S2-F2-3). Đổi này tương thích nguồn với mọi consumer
đang bỏ qua giá trị trả về.

### 7.3 Vì sao ảnh chụp toàn phần, không phải patch thưa

Dart không phân biệt được "không sửa trường này" với "đặt trường này về null"
nếu tham số chỉ là nullable, nên patch thưa sẽ cần bọc `Optional<T>` cho chín
trường nullable — nhiều máy móc hơn hẳn phần nó giải quyết. Cubit vốn đã giữ
nguyên cả thẻ trong bộ nhớ, nên ảnh chụp toàn phần không tốn thêm gì ở phía gọi.
Đánh đổi: người ghi sau đè người ghi trước. Chấp nhận được — store cục bộ một
người dùng, mỗi lúc chỉ một màn detail mở.

### 7.4 Hai phương án đã loại

- `setScheduledDate(cardId, scheduledOn)` đơn lẻ: đúng chữ AC-15 nhưng bỏ lại
  `note` (cũng bị B-2 nêu đích danh là mất) và chín trường còn lại vẫn chỉ nằm
  trong bộ nhớ. Với một hợp đồng shared-foundation có 11 story tiêu thụ, nó buộc
  phải sửa hợp đồng lần hai ở STORY-002+.
- Gộp ngày vào tham số của `updateStatus`: AC-12 cho phép đặt/đổi ngày **không**
  kèm chuyển trạng thái, nên đường ghi đó không có cửa; đồng thời phá vỡ dòng
  doc "writes only the `status` column" mà 11 story sau đọc.

### 7.5 Thời điểm ghi

`_edit` gọi `updateCardDetails` ngay — mỗi lần gọi `_edit` đã tương ứng một thao
tác đã chốt (picker đóng, toggle lật). Riêng `title` là ô văn bản: ghi khi submit
hoặc mất focus, rồi đọc lại state từ kết quả ghi (đóng luôn S6-F-6). Sau khi ghi
thật, `_needsScheduledDateQuestion` mới thấy `scheduled_on` có giá trị và câu hỏi
AC-15 mới bật lên — đó là chỗ khoá lỗi.

### 7.6 Sửa test bắt buộc

Suite xanh không phải bằng chứng ở đây: hai test đang chứng nhận lỗi là hành vi
đúng. `card_lifecycle_ui_test.dart:266–278` bật đèn xanh cho cú lùi trạng thái
âm thầm; `:127–138` tên là *"picking a date saves it"* trong khi assert rằng ngày
**không** được lưu. Cả hai phải sửa thành assert có persistence — sửa test là
một phần bắt buộc của P8, không phải việc tuỳ chọn.

### 7.7 Deferred gom vào P8

- S2-F2-3 (bỏ rơi row count) — đóng bằng `Future<int>` ở §7.2.
- S6-F-2 / S4-F-4 (`invited`, `replyState` chỉ trong bộ nhớ) — đóng vì hai
  trường này nằm trong `ActivityCardEdit`.
- S6-F-6 (title lệch pha) — đóng bằng §7.5.

### 7.8 S2-F2-1 (ảnh) — giữ DEFERRED, **không** gom vào P8

Review đề nghị gom; Tech Lead không gom, và đây là phán quyết có chủ ý. Lý do:
không AC nào của STORY-001 đòi lưu ảnh; bảng `activity_card_photos` và DAO đã có
sẵn từ P1, phần thiếu chỉ là mặt tiền repository, mà STORY-007 thêm được **không
phải sửa dòng nào của P8**. Gom vào sẽ thêm ba method, một kiểu giá trị ảnh và
test của chúng, đẩy P8 từ ~7 lên ~11 file — quá một specialist lifecycle, trong
khi B-3 lại bắt P8 phải merge cùng vòng với bản vá P4/P6. Chuyển chủ sở hữu sang
STORY-007.

### 7.9 File dự kiến của P8 (~7 file, một lifecycle)

`domain/activity_card_repository.dart` · `domain/activity_card.dart` ·
`data/activity_card_repository_impl.dart` ·
`core/database/daos/activity_card_dao.dart` (ghi có `WHERE id = ? AND owner_key
= ?`, trả row count) · `presentation/activity_card_detail_cubit.dart` ·
`card_lifecycle_ui_test.dart` (sửa hai test ở §7.6) · một test
repository/DAO cho đường ghi mới.

## 8. P9 — cổng gốc phiên chưa ghép đôi vào bề mặt solo

Tên dispatch: **P9 — unpaired root to solo surface**.
Phase file mobile-dev phải tạo: `phase-P9-unpaired-root-to-solo-surface.md`.

### 8.1 Vấn đề

`mobile/lib/core/navigation/pair_gate_shell.dart:142` (nhánh
`PairGateUnpaired()` trong `_AppShellView.build`) trả `PairingChoiceScreen`.
Đó là màn cuối đường cho phiên chưa ghép đôi: `HomeScreen` không bao giờ được
dựng, nên nhánh solo P4 (`home_screen.dart:199-210` → `_SoloStageOneShell` →
`ActivityCardHubView`) là mã sống nhưng **không tới được** trong bản dựng
thật. Widget test không bắt được vì chúng dựng `HomeScreen` trực tiếp.

### 8.2 Phán quyết: **IN SCOPE cho STORY-001**

Ba nguồn đã chốt sẵn, P9 chỉ thi hành, không mở quyết định sản phẩm mới:

- `../../req_master.md` → `### Cổng cứng (hard gate)`: "Mọi story phải trả lời
  được: chặng 1 có dùng được trọn vẹn kể cả khi người kia không bao giờ tham
  gia không? Nếu KHÔNG → story sai phạm vi." Một cổng gốc chặn đứng phiên chưa
  ghép đôi làm câu trả lời của **cả app** thành KHÔNG.
- `../story_master.md` → `## System Integration And Discoverability`: "Existing
  user-visible surface: NO — chặng 1 chưa có màn hình gốc nào" và "đây là màn
  'về nhà' của chế độ 1 người... Không phải màn khoá vị trí."
- `../ux/uiux-spec.md` §1: "Thanh tab chỉ áp cho nhánh solo (`isPaired ==
  false` **hoặc chưa từng ghép**)". UI/UX đã gán phiên chưa từng ghép cho bề
  mặt solo.

Cổng ghép đôi ở `pair_gate_shell.dart` có trước REQ-016, viết khi app còn
thuần cặp đôi (xem doc `pair_gate_cubit.dart:8-11`). Việc hoà giải nó với phạm
vi đã duyệt của REQ-016 là quyết định ranh giới điều hướng, thuộc Tech Lead.

### 8.3 Vì sao đây **không** phải quyết định sản phẩm

Vì P9 không xoá cửa vào ghép đôi nào. `core/navigation/onboarding_chain.dart`
đã map `OnboardingNode.profileSetup → OnboardingNode.pairingChoice`: cửa vào
ghép đôi của người dùng mới nằm ở chuỗi onboarding, **không** nằm ở
`PairGateShell`. Nhánh unpaired của `PairGateShell` là bức tường **thứ hai**,
chỉ phiên quay lại mới đâm vào. P9 gỡ bức tường thừa đó và không chạm
`onboarding_chain.dart`, nên `PairingChoiceScreen` giữ nguyên vai trò và
`pairing_choice_screen_test.dart` vẫn hợp lệ.

Ngoài phạm vi P9, ghi nhận thành OQ cho PO chứ **không** phải blocker: người
dùng cài mới có được bỏ qua `OnboardingNode.pairingChoice` để vào chặng 1 hay
không. Node đó thuộc requirement ghép đôi, và REQ-016 cố ý đẩy mọi việc "mời
người kia vào" sang chặng 1.5 (`../../req_master.md`, dòng 138 và 166). R-2 đo
trên đường phiên quay lại, đúng đường mobile-dev đã chạy.

### 8.4 Điểm tích hợp tối thiểu (chính xác)

File nguồn duy nhất: `mobile/lib/core/navigation/pair_gate_shell.dart`.

Trong `switch` của `_AppShellView.build`, đổi **một** nhánh:

```dart
PairGateUnpaired() => HomeScreen(resolvePairingStatus: _soloPairingStatus),
```

với một hàm tĩnh trong cùng file:

```dart
static Future<PairingStatus> _soloPairingStatus() async =>
    PairingStatus.unpaired;
```

Ba nhánh `PairGateChecking()`, `PairGateNetworkError()`, `PairGatePaired()`
giữ **nguyên văn**.

### 8.5 Vì sao phải ghim giá trị, không được để `HomeScreen` tự phân giải

Đây là phần bắt buộc, không phải khẩu vị. `HomeScreen` mặc định dùng
`_defaultResolvePairingStatus` → `getIt<CouplePairingStore>().resolve()`, một
nguồn sự thật **thứ hai, độc lập** với `PairGateCubit`, và nó có thể trả
`PairingStatus.unknown` (`core/couple/couple_pairing_store.dart:45`) khi đọc
lỗi hoặc chưa có cache. `_SoloHomeGateState` map **mọi** giá trị khác
`unpaired` sang `coupleBuilder` (`home_screen.dart:406-409`), tức là sẽ dựng
dashboard cặp đôi — một bề mặt chỉ dành cho phiên đã ghép — bên trong phiên
chưa ghép. Đó đúng là bất biến mà `pair_gate_cubit.dart:45-48` dựng ra để giữ.
Ghim giá trị làm cho "unpaired ⇒ chỉ có thể ra bề mặt solo" thành đúng theo
cấu trúc, không phụ thuộc vào một lần đọc store có thể hỏng.

### 8.6 Dọn seam chết sau khi đổi nhánh

`_router`, `_createInviteCubit`, `_createJoincodeCubit` của `PairGateShell` chỉ
được dùng ở nhánh `PairGateUnpaired()` (dòng 143-145), nên sau khi đổi chúng
thành mã chết. Trình tự bắt buộc: đổi nhánh → chạy `flutter analyze lib test` →
gỡ đúng những field/tham số mà analyze báo unused, kèm call site và test mà
analyze/test chỉ ra. Không gỡ trước khi analyze nói, và không giữ lại field
unused để "phòng sau này". Ba call site production hiện không truyền chúng
(`core/di/service_locator.dart:554`, `features/auth/presentation/screens/
splash_screen.dart:116`, `app/cupid_app.dart`), nên bán kính thật rất hẹp.

### 8.7 Test bắt buộc

1. Test nào đang khẳng định cạnh "chưa ghép đôi ở gốc app → `PairingChoiceScreen`"
   (ứng viên: `mobile/test/core/navigation/chain_tail_edges_test.dart`,
   `mobile/test/app/cupid_app_entry_routing_test.dart`) phải sửa thành khẳng
   định bề mặt solo: `find.byKey(const Key('solo_stage_one_shell'))`
   `findsOneWidget`.
2. Cùng chỗ đó thêm khẳng định âm bảo vệ §8.5: dashboard cặp đôi vắng mặt —
   `find.byKey(const Key('home_screen_ready_signal'))` `findsNothing`.
3. Một test hồi quy cho đúng chế độ hỏng mà việc ghim ngăn: dựng `PairGateShell`
   với `PairGateCubit` giả phát `PairGateUnpaired`, trong điều kiện
   `CouplePairingStore` **không** đăng ký trong `getIt` (hoặc đăng ký để trả
   `PairingStatus.unknown`), rồi khẳng định vẫn ra bề mặt solo và vẫn không có
   dashboard cặp đôi.
4. `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart` **giữ
   nguyên**: `PairGateUnpaired` vẫn là trạng thái phát ra cho lần kiểm tra hỏng
   hoặc chưa phân giải; chỉ điểm đến của nó đổi. Không nới test này.
5. `pairing_choice_screen_test.dart` **không** xoá: màn vẫn tồn tại và vẫn tới
   được từ chuỗi onboarding.

### 8.8 Cấm trong P9

- Không chạm nhánh solo của `home_screen.dart`, `_SoloStageOneShell`, thanh tab
  4 mục, hay `ActivityCardHubView`. Hợp đồng canvas D-3 đang khoá
  (`../ux/uiux-spec.md` §8) và bằng chứng visual của P4/P5/P6 đã duyệt.
- Không thêm tab thứ 5, route mới, `PairGateState` mới, hay màn sản phẩm mới.
- Không chạm `schemaVersion` hay migration.
- Không chạm `onboarding_chain.dart`.
- Không đổi hành vi `PairGateNetworkError` (xem §8.10).

### 8.9 File dự kiến của P9 (~5 file, một lifecycle)

`core/navigation/pair_gate_shell.dart` ·
`test/core/navigation/chain_tail_edges_test.dart` ·
`test/app/cupid_app_entry_routing_test.dart` · một test gốc-solo cho
`PairGateShell` (mới hoặc mở rộng file test pair-gate sẵn có) · tối đa một call
site production nếu §8.6 làm analyze đỏ.

Cập nhật 2026-09-08 (vòng patch 3, xem §8.11): danh sách trên thiếu hai file mà
vòng patch phát hiện cũng phụ thuộc đích cũ —
`test/features/pairing/presentation/pair_gate_cubit_test.dart` và
`test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`.
Cả hai vào WriteScope vòng patch tiếp theo của mobile-dev theo đúng phạm vi
sửa/xoá liệt kê ở §8.11, không phải viết lại tự do.

### 8.10 Khoảng hở đã biết, không thuộc P9

Phiên chưa ghép đôi **mất mạng** vẫn rơi vào `_NetworkErrorView` và không vào
được kho thẻ cục bộ của chính mình, vì `PairGateCubit` phát
`PairGateNetworkError` trước mọi quyết định solo. Ghi nhận thành việc tiếp theo
ở cấp requirement, không phải blocker của P9: hành vi này có trước REQ-016 và
tác động y hệt lên phiên đã ghép. Sửa nó là một quyết định riêng về ngưỡng
offline, không nằm trong lần hoà giải điều hướng này.

### 8.11 Phán quyết vòng patch 3 — nới §8.7 rule 4, mở rộng sang `pairing_choice_screen_test.dart` (2026-09-08)

Mobile-dev báo cáo đúng: nhóm `PairGateShell gate (AC4)`
(`pair_gate_cubit_test.dart:202-348`) dựng `PairGateShell` đầy đủ và khẳng định
đích **cũ** cho nhánh unpaired — mâu thuẫn trực tiếp với §8.4/§8.5 (đổi đích) và
rule 4 nguyên văn cũ ("giữ nguyên"). §8.4/§8.5 đứng vững (lý do ghim giá trị để
tránh `CouplePairingStore.unknown` không có lỗ hổng); xử lý bằng cách nới rule 4,
không đổi §8.4/§8.5.

Rà lại **cả 7 test** trong group AC4 (báo cáo mobile-dev chỉ nêu 3; có thêm 2
test vỡ theo cùng cơ chế mà báo cáo chưa liệt kê):

- Dòng 203-228 *"unpaired routes into the pairing stack..."* — **SỬA**, không
  xoá. Khẳng định cũ (`pairing_stack` findsOneWidget, tap `createCodeRowKey` →
  `InviteScreen`) đổi thành đúng cặp khẳng định ở §8.7 rule 1/2:
  `find.byKey(const Key('solo_stage_one_shell'))` `findsOneWidget` và
  `find.byKey(const Key('home_screen_ready_signal'))` `findsNothing`. Bỏ toàn bộ
  đoạn tap `createCodeRowKey` → `InviteScreen`: đường đó không còn tới được từ
  `PairGateShell` nữa.
- Dòng 230-246 *"'They already have a code' navigates directly to
  JoincodeScreen"* — **XOÁ**. Phụ thuộc đích chết ở trên; không mất phủ test vì
  `pairing_choice_screen_test.dart:99-108` ("the enter-code row opens joincode
  directly") đã phủ đúng cạnh này khi dựng `PairingChoiceScreen` trực tiếp.
- Dòng 248-264 *"'Scan the QR on their phone' reaches the same JoincodeScreen
  (AC3)"* — **XOÁ**, cùng lý do; đã phủ ở
  `pairing_choice_screen_test.dart:110-121`.
- Dòng 266-293 *"accepting a code via 'They already have a code' navigates
  through to PairedScreen (onPaired production wiring)"* — **XOÁ**, không phải
  sửa. Test exercise đúng dây nối `onPaired` xuyên qua `PairGateShell`'s
  `_createInviteCubit`/`_createJoincodeCubit`/`_router` — ba thứ §8.6 đã xác
  nhận thành mã chết sau khi đổi nhánh và phải gỡ. Sau §8.6, test này không còn
  compile được, không chỉ fail lúc chạy.
- Dòng 295-308 *"paired routes into the main tab shell"* — **GIỮ NGUYÊN**,
  không chạm nhánh `PairGatePaired`.
- Dòng 310-336 *"a failed check with network error renders network error
  screen and retry works"* — **GIỮ NGUYÊN**, §8.8 cấm đổi hành vi
  `PairGateNetworkError`.
- Dòng 338-347 *"a non-network failed check falls back to the pairing stack"*
  — **SỬA**, cùng mẫu như test đầu tiên. Fail-safe của `PairGateCubit` (lỗi bất
  ngờ → vẫn phát `PairGateUnpaired`, xem test dòng 157-167 cùng file) giờ cũng
  đi qua đích mới **vô điều kiện**: §8.4 đổi nhánh `PairGateUnpaired()`, không
  phân biệt lý do unpaired. Đổi khẳng định sang cặp key ở §8.7 rule 1/2 (đảo
  ngược: `pairing_stack` giờ `findsNothing`, `solo_stage_one_shell`
  `findsOneWidget`); đổi tên test cho khớp đích mới (vd. "...falls back to the
  solo surface (fail-safe)").

**Phát hiện thêm, ngoài phạm vi báo cáo của mobile-dev**:
`mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`
có group `'AC4/AC5 back edges from the unpaired pair gate'` (dòng 154-190) với
helper riêng `_gateHarness()` (dòng 200-223) — helper này **cũng** dựng
`PairGateShell` đầy đủ với `getPartnerLink` trả `partnerId: null` và khẳng định
`pairing_stack` findsOneWidget ngay khi build (dòng 159), rồi tap
`createCodeRowKey`/`enterCodeRowKey` (dòng 163, 180) — hai key không còn tồn
tại trên `HomeScreen`. Cùng lỗi cấu trúc, khác file, mà §8.7 chưa liệt kê ứng
viên. Sau §8.6, `_gateHarness()` truyền `createInviteCubit`/`createJoincodeCubit`
vào `PairGateShell`; dù constructor có giữ tham số đó hay không, cả 2 test
trong group đều fail runtime như trên.

Phán quyết: **XOÁ** nguyên `group('AC4/AC5 back edges from the unpaired pair
gate', ...)` (dòng 154-190) và helper `_gateHarness()` (dòng 200-223) khỏi
`pairing_choice_screen_test.dart`. Không mất phủ sản phẩm: phủ test tự thân của
`PairingChoiceScreen` (`_harness()`, dòng 85-121) đã kiểm đúng ba cạnh
create/enter/scan → đích riêng khi dựng `PairingChoiceScreen` trực tiếp; hành
vi "pop trở lại pairing stack" là cơ chế Navigator nội tại của chính
`PairingChoiceScreen`, không phụ thuộc việc nó được dựng qua `PairGateShell`
hay qua chuỗi onboarding. Phủ "back edges khi vào từ chuỗi onboarding" là
khoảng hở thật nhưng **ngoài phạm vi P9** (§8.8 cấm chạm `onboarding_chain.dart`)
— ghi nhận thành việc tiếp theo cấp requirement, cùng mẫu với §8.10, không phải
blocker của P9.

**Mở rộng WriteScope vòng patch tiếp theo của mobile-dev**, thêm vào danh sách
§8.9: `mobile/test/features/pairing/presentation/pair_gate_cubit_test.dart` và
`mobile/test/features/pairing/presentation/screens/pairing_choice_screen_test.dart`.

**Sửa trực tiếp §8.7 rule 4** (thay nguyên văn cũ "giữ nguyên"): nhóm
`PairGateCubit` (dòng 112-200, test trạng thái cubit thuần) giữ nguyên tuyệt
đối, không được chạm. Nhóm `PairGateShell gate (AC4)` (dòng 202-348) được sửa/
xoá đúng theo bảng phân loại 7 test ở §8.11 này — không nới rộng hơn (không
xoá/sửa test "paired" hay "network error").

### 8.12 Phán quyết vòng patch 4 — `splash_screen_test.dart:208`, cấp quyền đổi đúng một khẳng định (2026-09-08)

Trường hợp mới, độc lập với §8.11 (khác file, khác cơ chế): không phải lỗi
harness/DI cơ học mà là khẳng định over-match sau khi §8.4 đổi đích nhánh
unpaired. Đã xác minh trực tiếp trên mã hiện tại, không dựa vào báo cáo:

- `mobile/lib/core/navigation/pair_gate_shell.dart:136-138` — nhánh
  `PairGateUnpaired()` dựng `HomeScreen(resolvePairingStatus: _soloPairingStatus)`.
- `mobile/test/features/auth/presentation/splash_screen_test.dart:89-91` —
  harness truyền `getPartnerLink` trả `PartnerLink(partnerId: null)`, tức phiên
  **unpaired**. `setUp` (dòng 128-144) đã đăng ký `CupidDatabase` +
  `ActivityCardRepository` nên `HomeScreen` mount thật.

Vậy `HomeScreen` giờ là hậu duệ hợp lệ của `PairGateShell` trong chính test
này; dòng 208 (`findsNothing`) không thể xanh bằng bất kỳ sửa harness/DI nào.

**Rà lớp hồi quy trước khi nới** — tên test ("never a bare HomeScreen", AC1/
ADR-2) bảo vệ một lớp hồi quy thật: `SplashScreen` đẩy thẳng `HomeScreen` thay
vì đi qua gate. Đề xuất của mobile-dev (chỉ đổi 208 thành `find.descendant`)
phủ **thiếu** một nhánh: nếu hồi quy dựng gate đúng **và** đẩy thêm một
`HomeScreen` trần chồng lên, `find.descendant(...)` vẫn thấy đúng 1 widget
trong gate và test vẫn xanh. Dòng 207 cũng không chặn được nhánh đó (gate vẫn
`findsOneWidget`). Vì vậy phán quyết dùng **cặp** khẳng định, mạnh hơn đề xuất.

**Phán quyết: (A)** — cấp quyền đổi khẳng định, giới hạn tuyệt đối ở
`mobile/test/features/auth/presentation/splash_screen_test.dart`, đúng dòng
208, thay bằng khối sau (giữ nguyên 207 và 209, giữ nguyên tên test):

```dart
      expect(find.byType(PairGateShell), findsOneWidget);
      // §8.4: nhánh unpaired của gate giờ dựng chính `HomeScreen`, nên
      // `findsNothing` over-match. Cặp khẳng định dưới vẫn chặn đúng lớp hồi
      // quy "bare HomeScreen": đúng một `HomeScreen` trong cây, và nó nằm
      // dưới gate — không route nào đẩy `HomeScreen` vòng qua gate.
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(PairGateShell),
          matching: find.byType(HomeScreen),
        ),
        findsOneWidget,
      );
      expect(find.byType(SplashScreen), findsNothing);
```

Kèm theo, sửa **comment đã lỗi thời** ở dòng 85-88 cùng file (chỉ comment,
không đổi mã): thay hai câu cuối ("Unpaired keeps the destination at
`_PairingStack`, which needs nothing from `getIt`.") bằng "REQ-016 P9 (§8.4):
the unpaired branch now mounts `HomeScreen`, whose deps the `setUp` above
registers." Giữ nguyên hai câu đầu về `PairingRepository`/ADR-2.

**Không đổi gì khác**: không chạm `pair_gate_shell.dart`, không chạm bất kỳ
test nào khác, không thêm/bớt phase. Không có phương án production nào phù hợp
hơn — đích unpaired mới là hợp đồng đã chốt ở §8.2/§8.4/§8.5, không phải khiếm
khuyết cần vá lại ở lib.

**Vì sao không phải (B)**: ý định của AC1/ADR-2 mà test này canh là "splash
phải đi qua gate, không được bỏ qua gate", và ý định đó **không đổi** sau P9 —
thứ đổi là đích *bên trong* nhánh unpaired, vốn đã được chốt ở §8.2/§8.3 là
quyết định kỹ thuật trong phạm vi đã duyệt, và PO đã vá AC-10/AC-11/AC-22 theo
hướng đó. Không cần định tuyến câu hỏi sản phẩm, không phát sinh open item, và
mục này **không chặn** merge STORY-001.

**Mở rộng WriteScope vòng patch tiếp theo của mobile-dev**, thêm vào danh sách
§8.9: `mobile/test/features/auth/presentation/splash_screen_test.dart`.

## 9. P10 — nạp lại khoá chủ `owner_key` khi khởi động nguội

### 9.1 Vấn đề

Startup smoke R-2 chạy lại sau P9 (`test-results.md` dòng 1123-1187) bắt được
defect thật trên máy, không suy đoán:

```
E flutter : Unhandled Exception: Bad state: ActivityCardRepository used before a backend user id resolved.
E flutter : #0  ActivityCardRepositoryImpl._requireOwnerKey (activity_card_repository_impl.dart:164:7)
E flutter : #1  ActivityCardRepositoryImpl.createCard (activity_card_repository_impl.dart:31:22)
E flutter : #2  _MinuteOneEmptyStateState._acceptSuggestion (minute_one_empty_state.dart:167:31)
```

`BackendUserIdStore` (`mobile/lib/core/realtime/backend_user_id_store.dart`) chỉ
giữ `_backendUserId` trong RAM. Ba đường nạp duy nhất đều là đường **đăng nhập**
(`AuthRepository.signInWithEmail` dòng 65, `verifyOtp` dòng 126,
`_syncBackendProfile` dòng 252/254) cộng `chat_partner_store.dart:57`. Không có
đường nào chạy khi người dùng chỉ mở lại app với phiên đã lưu sẵn.

Hệ quả không phải lỗi hiếm — nó là trạng thái **mặc định** của mọi người dùng
quay lại: `ActivityCardListCubit.load()` hỏng im lặng về 0 thẻ nên hub luôn vẽ
Minute-1, `createCard` ném unhandled, và vì DAO không bao giờ được gọi nên Drift
không mở `cupid.sqlite` — đó là lý do migration v2→v3 không đo được, chứ bản
thân nhánh `if (from < 3)` không sai.

### 9.2 Bất biến đã xác minh trên mã nguồn (nền của phán quyết)

Khoá cần nạp lại **đã nằm sẵn trên đĩa**, không cần persist gì mới:

1. `JwtTokenProvider.userIdKey = 'cupid_user_id'`
   (`mobile/lib/core/auth/jwt_token_provider.dart:9`), ghi trong `saveSession`
   dòng 22.
2. `saveSession` chỉ có đúng một người gọi: `CupidSession.setSession`
   (`cupid_session.dart:97`).
3. `setSession` chỉ có đúng ba người gọi — `auth_repository.dart` dòng 60, 120,
   247 — và cả ba đều truyền `userId: user?['id']`, tức **chính giá trị** mà
   `updateFromLoginResponse` cache vào `_backendUserId` ngay dòng kế tiếp.

Suy ra: `cupid_user_id` trên SharedPreferences luôn bằng backend `User.id`, và
**không bao giờ** là Firebase uid. Bằng chứng vận hành khớp: trong lần R-2 vừa
rồi, prefs đã có đúng ba khoá của `JwtTokenProvider` với user thật
`ea03bad7-35c4-411c-a8af-d3a046b9b30a` (`test-results.md` dòng 1135-1141) đúng
lúc `_requireOwnerKey()` ném.

Bất biến teardown cũng đã đúng sẵn: `CupidSession.signOut()` gọi
`_tokenProvider.clearSession()` (xoá `cupid_user_id`, dòng 109) **trước** vòng
lặp `clearOnSignOut()` (dòng 118). Nên đọc lại prefs sau đăng xuất trả `null`;
AC4/D-012-5 không bị hở.

### 9.3 Phán quyết: phương án (3), nạp lười trong `resolve()`

Chọn **đọc lại `cupid_user_id` đã có sẵn trong SharedPreferences**, nạp lười
ngay trong `BackendUserIdStore.resolve()`.

Hai phương án còn lại bị loại, có lý do:

- **(1) Gọi `GET /users/me` lúc khởi động** — loại. Nó biến kho thẻ cục bộ
  offline-first thành thứ phụ thuộc mạng: người dùng quay lại app khi mất mạng
  sẽ thấy đúng cái triệu chứng đang phải sửa (hub kẹt Minute-1). Nó còn thêm một
  ràng buộc thứ tự khởi động mới và một chế độ hỏng mới, để lấy về đúng cái giá
  trị đã nằm trên đĩa.
- **(2) Persist riêng `backendUserId` bằng khoá mới** — loại. Nó tạo nguồn sự
  thật thứ hai cho cùng một giá trị. Hai khoá sẽ phân kỳ ở đúng chỗ nguy hiểm
  nhất: `JwtTokenProvider.clearSession()` chỉ xoá khoá của nó, nên khoá mới sống
  sót qua đăng xuất và người dùng thứ hai trên cùng máy kế thừa `owner_key` của
  người thứ nhất — chính điều AC-22/D-012-5 cấm.

Phương án (3) không thêm state bền vững nào, không chạm mạng, không đổi thứ tự
khởi động, và teardown đã đúng sẵn theo §9.2.

### 9.4 Điểm tích hợp tối thiểu (chính xác)

**File 1 — `mobile/lib/core/realtime/backend_user_id_store.dart`**

Thêm một tham số constructor tuỳ chọn và sửa **một** hàm:

```dart
BackendUserIdStore({Future<String?> Function()? readPersistedUserId})
    : _readPersistedUserId = readPersistedUserId;

final Future<String?> Function()? _readPersistedUserId;

@override
Future<String?> resolve() async {
  final cached = _backendUserId;
  if (cached != null && cached.isNotEmpty) {
    return cached;
  }
  final read = _readPersistedUserId;
  if (read == null) {
    return cached;
  }
  final persisted = await read();
  if (persisted == null || persisted.isEmpty) {
    return cached;
  }
  _backendUserId = persisted;
  return persisted;
}
```

**File 2 — `mobile/lib/core/di/service_locator.dart` dòng 174**

```dart
getIt.registerLazySingleton<BackendUserIdStore>(
  () => BackendUserIdStore(
    readPersistedUserId: getIt<JwtTokenProvider>().getSavedUserId,
  ),
);
```

`JwtTokenProvider` đăng ký ở dòng 107, trước 174, nên thứ tự resolve đã đúng.

### 9.5 Vì sao mặc định là `null`, không phải `JwtTokenProvider().getSavedUserId`

Mặc định `null` giữ `BackendUserIdStore()` trần **giống hệt hành vi cũ**. Đây là
điều kiện bắt buộc, không phải sở thích: `main_preview.dart:570`, `:764` và
`preview_reminder_fixture.dart:43` đều dựng store trần rồi `..updateUserId(...)`,
và toàn bộ widget test hiện có cũng vậy. Nếu mặc định tự đọc prefs thì mọi test
dựng store trần sẽ chạm `SharedPreferences.getInstance()` và ném
`MissingPluginException` khi thiếu `setMockInitialValues` — biến một bản vá một
dòng thành một đợt sửa test lan rộng.

Đổi lại, tính đúng đắn ở production phụ thuộc **duy nhất** vào dây nối DI ở
§9.4 File 2. Đó là lý do §9.6 rule 3 bắt buộc có test khẳng định chính dây nối
đó, không chỉ test cái store.

### 9.6 Test bắt buộc

1. `mobile/test/core/realtime/backend_user_id_store_test.dart` — `resolve()` trả
   giá trị persist khi RAM rỗng, và cache lại (reader chỉ được gọi một lần cho
   hai lời gọi `resolve()` liên tiếp).
2. Cùng file — giá trị trong RAM **thắng** giá trị persist (đã đăng nhập trong
   phiên này thì không đọc prefs); và reader trả `null`/chuỗi rỗng thì `resolve()`
   trả `null`, không cache chuỗi rỗng.
3. Cùng file — test bất biến teardown §9.2 bằng đồ thật, không bằng fake: dùng
   `SharedPreferences.setMockInitialValues` với `cupid_user_id`, một
   `JwtTokenProvider` thật, một `CupidSession(tokenProvider: ..., firebaseAuth:
   null)` thật có `registerScopedStore(store)`, rồi khẳng định `resolve()` trả id
   trước `signOut()` và trả `null` sau. Test này là thứ duy nhất bắt được nếu
   ai đó đảo thứ tự `clearSession()`/`clearOnSignOut()` trong `core/auth/`.
4. `mobile/test/features/activity_cards/activity_card_repository_test.dart` —
   thêm đúng một test khởi động nguội: dựng `ActivityCardRepositoryImpl` với
   `ownerKeyStore` chưa từng đăng nhập trong phiên nhưng có reader trả id
   persist, rồi khẳng định `createCard` + `cardsByStatus` chạy được và
   `_requireOwnerKey()` **không** ném. Đây là khẳng định trực tiếp cho stack
   trace ở §9.1.
5. Không đổi khẳng định nào đang có trong hai file test trên. P10 chỉ **thêm**.

### 9.7 Cấm trong P10

- Cấm chạm `mobile/lib/features/home/presentation/screens/home_screen.dart`
  (nhánh solo, thanh tab, `ActivityCardHubView` — D-3 khoá độ trung thực thị
  giác).
- Cấm mở lại phạm vi P9: `pair_gate_shell.dart` đã đổi đích và đã xác nhận chạy
  thật (`test-results.md` dòng 1146). Không sửa lại.
- Cấm chạm `CupidDatabase.schemaVersion` và các nhánh migration
  (`cupid_database.dart:46`, `:60`). Chúng đúng, chỉ là chưa với tới được.
- Cấm sửa `mobile/lib/core/auth/cupid_session.dart` và
  `mobile/lib/core/auth/jwt_token_provider.dart`. P10 **đọc** hợp đồng sẵn có
  (`getSavedUserId`) chứ không mở rộng nó; `core/realtime/` giữ nguyên quyền sở
  hữu khoá phòng theo `solution.md` §2/ADR-012b.
- Cấm đổi getter đồng bộ `backendUserId` và cấm chạm
  `mobile/lib/core/couple/couple_pairing_store.dart:99`. Getter đó là đồng bộ
  nên không nạp lười được, và `?? _lastKnownUserId` ở đó là một fallback riêng
  của pairing. Khoảng hở "couple_pairing_store cũng nguội khi khởi động" là thật
  nhưng **ngoài phạm vi P10** — ghi nhận thành việc tiếp theo cấp requirement,
  cùng mẫu với §8.10.
- Cấm thêm khoá SharedPreferences mới (xem §9.3 phương án (2) bị loại).
- Cấm đổi `updateFromLoginResponse`, `updateUserId`, `clearOnSignOut`.
- Cấm sửa `main_preview.dart` và `preview/preview_reminder_fixture.dart`: §9.5
  đã chọn mặc định `null` chính là để không phải chạm chúng.

### 9.8 File dự kiến của P10 (4 file mã/test, một lifecycle)

| # | File | Thay đổi |
|---|------|----------|
| 1 | `mobile/lib/core/realtime/backend_user_id_store.dart` | Tham số `readPersistedUserId` + nạp lười trong `resolve()` (§9.4) |
| 2 | `mobile/lib/core/di/service_locator.dart` | Dây nối dòng 174 (§9.4) |
| 3 | `mobile/test/core/realtime/backend_user_id_store_test.dart` | Rule 1, 2, 3 (§9.6) |
| 4 | `mobile/test/features/activity_cards/activity_card_repository_test.dart` | Rule 4 (§9.6) |

Cộng hai artifact: `coding-plan/phase-P10-cold-start-owner-key-rehydration.md`
(mobile-dev tạo từ §9 này) và mục evidence trong `coding-plan/test-results.md`.

### 9.9 Điều kiện đóng P10

`flutter analyze lib test` 0 error, `flutter test` xanh, và **chạy lại startup
smoke R-2** đúng kịch bản ở `test-results.md` dòng 1123-1141 (đẩy `cupid.sqlite`
schema v2 vào, phiên JWT thật đã lưu, `main.dart` thật). Bốn điều kiện R-2 phải
đạt cả bốn — riêng "migration v2→v3" và "mở một thẻ sang màn chi tiết P6" lần
này mới thực sự đo được, vì P10 là thứ mở đường cho DAO được gọi lần đầu.

## 10. P11 — mở rộng trường thẻ theo B-1 (5 cột + `schemaVersion` 4 + migration)

**Nguồn phán quyết (đã đóng, không mở lại):** B-1 ở
`../../req_master.md` → `## Design Ruling Log`, dòng ngày 2026-09-09. Hợp đồng
tên/kiểu do PO chốt ở `../ux/uiux-spec.md` mục 8; AC tương ứng là **AC-8** đã
vá. `../architecture/contract-summary.md` §3 và §5 đã được vá kèm vòng này.

### 10.1 Vì sao đây là phase riêng, và vì sao nó chạy TRƯỚC P13

B-1 là **mở rộng phạm vi**, không phải sửa câu chữ: nó sinh DDL thật. P13 (§12)
dựng hàng meta A8 gồm **thời lượng** và **khung giờ**; hai giá trị đó chỉ tồn
tại sau P11. Làm ngược lại sẽ buộc P13 vẽ hai ô rỗng vô nghĩa rồi sửa lại —
đúng kiểu nửa vời mà vòng review trước đã phạt.

### 10.2 Tập cột — đóng, đúng 5, không thêm

| Cột | Kiểu Drift | Kiểu SQLite | Ràng buộc |
|---|---|---|---|
| `durationMinutes` | `IntColumn ... nullable()` | INTEGER NULL | Đơn vị **phút**. Không lưu chuỗi đã định dạng |
| `timeOfDaySlot` | `TextColumn ... nullable().map(const TimeOfDaySlotConverter())` | TEXT NULL | Enum đóng, wire ASCII `sang`/`trua`/`chieu`/`toi` |
| `noteKeywords` | `TextColumn ... nullable()` | TEXT NULL | Tách khỏi `note`; `note` **không đổi** |
| `linkSourceLabel` | `TextColumn ... nullable()` | TEXT NULL | Nhãn nguồn cạnh `source_link` |
| `linkSavedAt` | `IntColumn ... nullable()` | INTEGER NULL | Theo đúng bảng chốt của uiux-spec §8 — **INTEGER**, không `DateTimeColumn` |

Ba điều cấm, mỗi điều đều là một cách phase này có thể trượt khỏi phán quyết:

1. **Cấm suy `time_of_day_slot` từ `scheduled_on`.** Cột chỉ nhận giá trị người
   dùng tự chọn. Đây là nguyên văn B-1 và cũng là lý do D-8 từng hoãn field:
   thẻ *Mới nghĩ ra* chưa có ngày mà vẫn phải nói được "tối nay được".
2. **Cấm thêm cột thứ 6 dưới danh nghĩa B-1.** D-24 (chú thích khung ảnh) và
   D-25 (chuỗi đếm liên-thẻ, dải insight) đã đóng là **không** sinh cột.
3. **Cấm đụng `note`.** `note_keywords` là cột mới đứng cạnh, không phải bản
   thay thế, không migrate dữ liệu từ `note` sang.

### 10.3 `TimeOfDaySlot` — theo đúng khuôn `ActivityType` của P7

File mới `mobile/lib/features/activity_cards/domain/time_of_day_slot.dart`, sao
đúng khuôn đã có ở `domain/activity_type.dart` (P7): enum đóng + `wireValue`
ASCII + hàm đọc khoan dung `timeOfDaySlotFromWireValue` trả `null` cho giá trị
lạ. Converter đặt cạnh `ActivityTypeConverter` trong
`core/database/tables/activity_cards_table.dart`, và file bảng phải
`export` symbol mới y như nó đang export `ActivityType` — vì
`cupid_database.g.dart` là `part` và gọi tên kiểu đó trong row type sinh ra.
Đọc khoan dung là bắt buộc: hàng ghi trước v4 đọc lại phải ra `null`, không
được ném.

### 10.4 Migration — cộng thêm, và chuỗi v2→v3→v4 phải còn nguyên

`CupidDatabase.schemaVersion` 3 → **4**. Trong `onUpgrade`, 5 lệnh
`m.addColumn(...)` đi vào nhánh `else if (from < 4)` nối **sau** nhánh
`from < 3` hiện có — loại trừ lẫn nhau, **không** phải một `if (from < 4)` độc
lập chạy tiếp sau đó. Nhánh `from < 2` và `from < 3` giữ nguyên từng ký tự.

Hình dạng `if (from < 3) { createTable } else if (from < 4) { addColumn }` là
**đúng, đã ship, và không được sửa**: `m.createTable(activityCards)` ở nhánh
`from < 3` luôn phát ra định nghĩa bảng **hiện tại**, nên máy đi từ v2 đã nhận
đủ 5 cột B-1 ngay tại nhánh đó. Một `if` thứ hai không điều kiện sẽ gọi
`addColumn` trên bảng đã có sẵn cột và ném lỗi trùng tên cột trên đúng nhóm máy
v2 ấy. Chỉ máy dừng ở v3 mới có bảng hẹp, và đó là nhánh duy nhất cần 5 lệnh
`addColumn`. Câu chữ đầu mục này trước vòng patch round-9 đọc như thể phải dùng
hai `if` độc lập; đó là lỗi diễn đạt của kế hoạch, không phải lỗi của mã.

Cấm tuyệt đối `deleteTable`/`createAll` lại cho `activity_cards` — đây là dữ
liệu gốc client-owned, không có bản sao trên server
(`../architecture/solution.md` §1 Key Discovery, và cảnh báo viết sẵn trong
docstring của chính bảng). Máy đang ở v2 phải đi trọn v2→v3→v4 và giữ nguyên
mọi hàng.

### 10.5 Lan sang tầng domain và repository

`ActivityCard` và `ActivityCardEdit` (`domain/activity_card.dart`) nhận đủ 5
trường mới, **tất cả tuỳ chọn**, cộng `ActivityCardEdit.from` ánh xạ đủ 5. Vì
tham số mới đều là named-optional nên **không** implementer nào của
`ActivityCardRepository` vỡ — khác hẳn vòng P8, nơi §7.9 ước lượng thiếu sáu
implementer giả và làm cây nguồn không biên dịch. Đừng lặp lại phép ước lượng
đó: chạy `flutter analyze lib test` ngay sau khi đổi domain, trước khi viết
tiếp.

Ngữ nghĩa ảnh-chụp-toàn-phần của `ActivityCardEdit` (§7.2) áp nguyên cho 5
trường mới: `null` là **lệnh xoá cột**, không phải "giữ nguyên".

### 10.6 Test bắt buộc

1. `activity_card_dao_test.dart` — allowlist §3 lên **22** cột (17 + 5), và
   `expect(database.schemaVersion, 4)`. Nhóm test "cấm cột đo hành vi người
   kia" (R-1b) giữ nguyên và phải vẫn xanh: không tên cột mới nào chứa
   `partner`/`seen`/`reply_latency`/…
2. `activity_card_migration_test.dart` — mở DB ở v3 có sẵn ≥1 hàng thẻ, nâng
   lên v4, khẳng định: 5 cột tồn tại, hàng cũ **còn nguyên**, và 5 giá trị mới
   của hàng cũ là `null`.
3. `activity_card_repository_test.dart` — vòng ghi-đọc đủ 5 trường; đọc khoan
   dung `time_of_day_slot` với giá trị rác trả `null`; ghi `null` xoá được cột.

### 10.7 File dự kiến của P11 (8 file mã/test, cộng codegen)

| # | File | Thay đổi |
|---|------|----------|
| 1 | `mobile/lib/features/activity_cards/domain/time_of_day_slot.dart` | **Mới** — enum đóng + wire value + đọc khoan dung (§10.3) |
| 2 | `mobile/lib/core/database/tables/activity_cards_table.dart` | 5 cột + `TimeOfDaySlotConverter` + `export` (§10.2, §10.3) |
| 3 | `mobile/lib/core/database/cupid_database.dart` | `schemaVersion` 4 + nhánh `from < 4` (§10.4) |
| 4 | `mobile/lib/features/activity_cards/domain/activity_card.dart` | 5 trường trên `ActivityCard`, `ActivityCardEdit`, `.from` (§10.5) |
| 5 | `mobile/lib/features/activity_cards/data/activity_card_repository_impl.dart` | Ánh xạ row↔domain hai chiều cho 5 trường |
| 6 | `mobile/test/core/database/activity_card_dao_test.dart` | Rule 1 (§10.6) |
| 7 | `mobile/test/core/database/activity_card_migration_test.dart` | Rule 2 (§10.6) |
| 8 | `mobile/test/features/activity_cards/activity_card_repository_test.dart` | Rule 3 (§10.6) |

Cộng `cupid_database.g.dart` và `activity_card_dao.g.dart` **sinh lại bằng
build_runner**, không sửa tay — chúng không tính vào ngân sách lifecycle. Con
số 8 nằm ở mép trần "roughly six source/test files"; **không tách** vì tách
schema khỏi ánh xạ sẽ đẻ ra một phase có cột mà không ai đọc được, đúng thứ
nửa vời bị cấm. Cộng hai artifact:
`coding-plan/phase-P11-b1-card-field-schema-extension.md` và mục evidence
trong `coding-plan/test-results.md`.

### 10.8 Điều kiện đóng P11

`flutter analyze lib test` 0 error, `flutter test` xanh, và migration test ở
§10.6 rule 2 chứng minh dữ liệu cũ sống sót. P11 **không** tự chạy startup
smoke — R-2 vẫn là một lần chạy ở cấp story (§6), nhưng lần chạy R-2 cuối cùng
của story nay phải phủ thêm chuỗi **v3→v4**, không chỉ v2→v3.

## 11. P12 — A-2: hiển thị đã định dạng vs. bộ đệm sửa thô

**Nguồn phán quyết (đã đóng):** A-2 ở `../../req_master.md` →
`## Design Ruling Log` (2026-09-09), thi hành qua **AC-8** khối "Định dạng hiển
thị vs. bộ đệm sửa". **AC-6 không đổi** — luồng tạo nhanh vẫn đúng một trường
bắt buộc, phase này không thêm trường bắt buộc nào vào đó.

### 11.1 Bất biến phải giữ

1. Ô **không** focus → hiện chuỗi **đã định dạng**.
2. Ô **được** focus → đổi ngay sang **văn bản thô**, không dấu phân cách.
3. Bộ đệm đang gõ **luôn** thô; cấm chèn dấu phân cách trong lúc gõ.
4. Tầng dữ liệu **không bao giờ** nhận chuỗi đã định dạng. Đường ghi vẫn là
   `int`/`double` qua `ActivityCardEdit` (§7.2).

Bất biến 3 là thứ dễ trượt nhất: một `TextInputFormatter` nhóm-hàng-nghìn theo
từng phím gõ **vi phạm** A-2. Định dạng chỉ xảy ra ở **thời điểm mất focus**.

### 11.2 Quy ước Việt (đo được)

| Trường | Nguồn | Chuỗi hiển thị | Bộ đệm thô |
|---|---|---|---|
| Giá | `price_vnd` INTEGER | `180.000đ` — chấm ngăn nghìn, hậu tố `đ` | `180000` |
| Khoảng cách | `distance_km` REAL | `1,8 km` — **phẩy** thập phân | `1.8` |
| Thời lượng | `duration_minutes` INTEGER (P11) | `2 tiếng` · `90 phút` · `1 tiếng 30 phút` | `90` |

Dấu `~` trên canvas (`~70.000đ`) là **chữ mẫu của thẻ**, không phải hợp đồng
định dạng — cùng nguyên tắc D-8 đã đóng D-24/D-25. Không sinh tiền tố `~`.

Bộ đệm thô của khoảng cách dùng **dấu chấm** thập phân vì đó là thứ
`double.tryParse` đọc được (đường ghi hiện tại ở `_commitDistance`); phần
chuyển sang **phẩy** chỉ nằm ở nhánh hiển thị. Parser phải nhận cả `1,8` lẫn
`1.8` khi người dùng gõ tay.

### 11.3 Điểm tích hợp

Formatter/parser sống trong file thuần Dart riêng, không phụ thuộc widget, để
test được thẳng và để P13 dùng lại cho hàng meta A8. Màn chi tiết gắn
`FocusNode` listener cho ba ô: mất focus → commit giá trị thô rồi nạp chuỗi đã
định dạng vào controller; được focus → nạp lại chuỗi thô. `_commitPrice` và
`_commitDistance` hiện có (`activity_card_detail_screen.dart` dòng 158-170)
tiếp tục là cửa ghi duy nhất; phase này bọc quanh chúng, không thay chúng.

Cấm dùng `intl`/`NumberFormat` locale-động cho việc này: quy ước ở §11.2 là
hằng số sản phẩm đã chốt, không được đổi theo locale máy.

### 11.4 Test bắt buộc

1. Test thuần cho formatter/parser: cả ba trường, hai chiều, cộng biên —
   `null`, `0`, số rất lớn, chuỗi rác trả `null`, và vòng
   `parse(format(x)) == x`.
2. Widget test: ô mất focus hiện chuỗi đã định dạng; chạm vào ô, chuỗi trong
   controller trở thành thô.
3. Widget test bảo vệ bất biến 3: gõ từng ký tự vào ô giá, khẳng định
   controller **không** mọc dấu chấm giữa chừng.
4. Khẳng định đường ghi vẫn nhận số, không nhận chuỗi đã định dạng.

### 11.5 File dự kiến của P12 (5 file mã/test)

| # | File | Thay đổi |
|---|------|----------|
| 1 | `mobile/lib/features/activity_cards/presentation/formatters/vi_field_format.dart` | **Mới** — format/parse ba trường (§11.2) |
| 2 | `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` | Focus listener + hoán chuỗi cho giá/khoảng cách/thời lượng (§11.3) |
| 3 | `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart` | Cửa ghi `editDurationMinutes` cho trường mới của P11 |
| 4 | `mobile/test/features/activity_cards/vi_field_format_test.dart` | **Mới** — rule 1 (§11.4) |
| 5 | `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart` | Rule 2, 3, 4 (§11.4) |

Cộng hai artifact:
`coding-plan/phase-P12-a2-vi-number-display-vs-edit-buffer.md` và mục evidence
trong `coding-plan/test-results.md`.

### 11.6 Cấm trong P12

- Không đổi AC-6 / luồng tạo nhanh (`quick_capture_sheet.dart`). Phạm vi A-2
  **chỉ** là màn chi tiết.
- Không đổi 4 nhãn SC-4, không đổi số hành động chính.
- Không đổi kiểu cột: `price_vnd` vẫn INTEGER, `distance_km` vẫn REAL.

## 12. P13 — A-1 + A-3 + A-4: header ô tràn, ngoại lệ căn lề A8, thứ tự khối

**Nguồn phán quyết (đã đóng):** A-1, A-3, A-4 ở `../../req_master.md` →
`## Design Ruling Log` (2026-09-09), thi hành qua **AC-14**, **AC-16**,
**AC-17** đã vá và `../ux/uiux-spec.md` mục 5.

### 12.1 Vì sao A-1, A-3, A-4 là MỘT phase, không phải ba

Cảnh báo 2 của req_master nói thẳng **A-1 và A-4 phải làm cùng nhau**: A-4 xoá
khối vòng đời khỏi thân màn đúng vì A-1 vừa chuyển nó vào ô tràn; tách ra sẽ để
lại một màn không có đường đổi trạng thái — vỡ AC-14 giữa chừng. A-3 là ~5 dòng
căn lề trong **cùng hàm `_header`** mà A-1 đang viết lại; tách A-3 thành phase
riêng sẽ đẻ ra một phase một-file sửa đúng chỗ phase kia vừa động vào. Ba mục
là một cụm hành vi trên cùng một file, gộp lại vẫn nằm trong một lifecycle.

### 12.2 A-1 — ô tràn "⋯" trên header

Hiện trạng (`activity_card_detail_screen.dart`): `_header` chỉ có nút back +
`card_detail_status_pill`; thân màn mang `card_detail_change_status_row`,
`card_detail_delete_row` (dòng 251-270) và `_invitedBlock` (dòng 249).

Sau A-1: ba thứ đó **biến khỏi thân màn**, vào ô tràn "⋯" của header với đúng
ba mục — "Chuyển trạng thái", "Xoá thẻ", "Đánh dấu đã trả lời / chưa trả lời".

Bất biến phải kiểm được (AC-16 đã vá):

1. Mỗi mục mở **đúng một** hộp thoại/sheet, **một tầng**.
2. Cấm menu lồng menu, cấm submenu nhiều tầng, cấm màn trung gian trước khi
   tới hành động.
3. `status_change_picker.dart` và `delete_card_dialog.dart` **giữ nguyên** —
   đổi chỗ lối vào, không đổi hộp thoại đích. Hộp thoại xoá vẫn trung tính
   (AC-16 gốc: không hỏi lý do, không câu cảm xúc).
4. AC-14 hai chiều còn nguyên: picker vẫn mở được cả 4 trạng thái, cả tiến lẫn
   lùi, từ trong ô tràn.
5. **Thẻ rút gọn P4 không đổi.** Chip toggle "đã rủ" ở uiux-spec §2 vẫn ở lại
   trên tile; A-1 chỉ chạm màn chi tiết. Đường xoá/ô tràn của tile (D-2) cũng
   không đổi.
6. Ranh giới đạo đức R-1b/AC-18 nguyên vẹn: cờ "đã rủ" vẫn đúng hai trạng
   thái, vẫn chỉ đổi khi người dùng tự bấm, vẫn **không** nhãn thời gian.

**Khoảng hở đã biết, KHÔNG tự quyết trong P13:** uiux-spec §5 mô tả header
canvas là "icon chia sẻ + ô tràn ⋯", nhưng repo hiện **không có** hành vi chia
sẻ nào cho thẻ (grep `Chia sẻ|share` trong `features/activity_cards` chỉ ra
một comment không liên quan), và "xuất lời mời" thuộc STORY-002. Vẽ một icon
chia sẻ không có đích đến là một affordance chết — trái AC-13/SC-5. P13 vì vậy
dựng **ô tràn "⋯"** (thứ mà A-1 thực sự phán quyết và AC-14/16/17 mô tả) và
**không** tự sinh hành vi chia sẻ. Nếu vòng visual-fidelity sau đo thiếu icon
chia sẻ, đó là một quyết định phạm vi cho Scrum Master/PO, không phải chỗ
mobile-dev tự bịa hành vi.

### 12.3 A-3 — ngoại lệ căn lề pill, chỉ trên A8

Trên màn A8 (`card.status == ActivityCardStatus.memory`), pill "★ KỶ NIỆM"
**căn phải**. Ba trạng thái còn lại giữ căn lề chung hiện tại. Đây là **ngoại
lệ đóng**: không suy rộng thành "mỗi trạng thái tự chọn căn lề", và không thêm
tham số cấu hình căn lề cho từng trạng thái. Cách rẻ nhất và đúng ý: một
`Spacer()` chỉ chèn khi `memory`, trong `Row` của `_header` (dòng 296-357).

### 12.4 A-4 — thứ tự khối trên A8

Thứ tự mới, đúng canvas: **tiêu đề → meta → ghi chú → chip → link → CTA**.

Thứ tự hiện tại (dòng 232-274) là tiêu đề → (ảnh) → ghi chú → `_statGrid` →
chip → link → `_invitedBlock` → hàng đổi trạng thái → hàng xoá → CTA. Hai thay
đổi: `_noteBlock` **lùi xuống sau** hàng meta, và ba khối cuối trước CTA biến
mất vào ô tràn (A-1).

"meta" = hàng thông tin có cấu trúc: **ngày hẹn · thời lượng · khung giờ ·
khoảng cách · giá · trong nhà/ngoài trời**. Thời lượng và khung giờ là hai cột
P11 vừa thêm, hiển thị theo canvas dạng lưới 2x2 "THỜI LƯỢNG / KHUNG GIỜ";
chuỗi thời lượng lấy từ formatter P12, **không** tự nối chuỗi tại chỗ.

Lý do cũ "đặt ghi chú ngay dưới tiêu đề để đưa trọng tâm về CTA" đã bị phán
quyết **thay thế** — không viện dẫn lại nó trong comment hay trong phase file.

### 12.5 Hai action item gộp vào dispatch của P13 (không thành phase riêng)

**R8-F-1 (D-28) — màu nhấn dòng hành động phụ.** Dòng
`card_detail_secondary_line` (dòng ~838) đã tồn tại từ D-19; việc còn lại chỉ
là áp đúng token màu nhấn. Thuần style, không đổi hành vi, không đổi hợp đồng:
một sửa đổi trong file P13 đang mở, không đủ trọng lượng thành phase.

**R8-F-2 (D-20) — 4 codepoint icon thật.** Bổ sung `event`, `history`,
`image`, `trash` vào `mobile/lib/design_system/icons/cupid_icons.dart`.
**Bắt buộc tra cmap thật của font icon dùng chung rồi mới ghi**; file này tự
cấm bịa codepoint từ trí nhớ (nó đã ghi lại đúng một lần bịa từ dải PUA của
font khác), và mọi hằng số trong đó đều kèm chú thích "confirmed in the bundled
font's cmap at 0x…". Token mới phải kèm chú thích cùng dạng, và nếu font có
alias thì ghi rõ alias như các mục hiện có. Bốn icon này là thứ hàng meta
(`event`), ô tràn (`trash`, `history`) và khối ảnh (`image`) của P13 tiêu thụ,
nên chúng đi cùng chuyến với P13. **Nếu tra cmap không ra một codepoint nào
đó: dừng và báo, không chọn icon thay thế** — cổng `VISUAL_FIDELITY` là nhị
phân theo `.agent-contract/design-fidelity-spec.md`, icon sai sẽ khoá token đỏ
vĩnh viễn.

### 12.6 Test bắt buộc

1. Header có ô tràn "⋯"; thân màn **không còn** `card_detail_change_status_row`
   và `card_detail_delete_row` (khẳng định `findsNothing` theo đúng hai Key cũ).
2. Mở ô tràn → thấy đủ ba mục; chọn "Chuyển trạng thái" mở thẳng picker 4 lựa
   chọn (một tầng, không màn trung gian); chọn "Xoá thẻ" mở thẳng hộp thoại
   trung tính.
3. AC-14 hai chiều còn sống: từ ô tràn lùi được *Đã hẹn ngày* → *Mới nghĩ ra*,
   và hộp thoại giữ-hay-xoá-ngày (AC-15) vẫn bật.
4. AC-17: đổi cờ "đã rủ" từ ô tràn, đúng hai trạng thái, không nhãn thời gian.
5. A-3: ở `memory` pill nằm mép phải; ở ba trạng thái kia giữ căn lề cũ.
6. A-4: khẳng định **thứ tự** widget trong Column đúng tiêu đề → meta → ghi
   chú → chip → link → CTA (so sánh toạ độ `dy`, không chỉ so sánh sự tồn tại).
7. Test tile P4 hiện có phải vẫn xanh không sửa — bằng chứng A-1 không rò sang
   thẻ rút gọn (bất biến 5, §12.2).

### 12.7 File dự kiến của P13 (6 file mã/test)

| # | File | Thay đổi |
|---|------|----------|
| 1 | `mobile/lib/features/activity_cards/presentation/widgets/card_detail_overflow_menu.dart` | **Mới** — ô tràn "⋯" ba mục, một tầng (§12.2) |
| 2 | `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` | Header + ô tràn, ngoại lệ căn lề A8, thứ tự khối, hàng meta, màu dòng phụ (§12.2-§12.5) |
| 3 | `mobile/lib/design_system/icons/cupid_icons.dart` | 4 codepoint tra từ cmap (§12.5) |
| 4 | `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart` | Rule 1-6 (§12.6) |
| 5 | `mobile/test/features/activity_cards/card_detail_overflow_menu_test.dart` | **Mới** — hình dạng menu một tầng, không submenu |
| 6 | `../visual-fidelity/visual-fidelity-report.md` | Ảnh chụp A4/A8 sau khi sắp lại, đối chiếu canvas |

Cộng hai artifact:
`coding-plan/phase-P13-a1-a3-a4-detail-header-and-block-order.md` và mục
evidence trong `coding-plan/test-results.md`.

### 12.8 Cấm trong P13

- Không đổi thẻ rút gọn P4, không đổi `activityPrimaryActionFor`, không đổi 4
  nhãn SC-4.
- Không thêm hành động chính thứ hai; dòng hành động phụ D-19 vẫn đúng một
  dòng, không nền `--grad`, không dạng pill.
- Không bịa codepoint icon (§12.5).
- Không tự sinh hành vi chia sẻ (§12.2).
- Không mở lại A-1/A-2/A-3/A-4/B-1/D-24/D-25/D-20 — bảy mục đã đóng.

## 13. P14 — đóng vòng đọc/ghi cho 4 cột B-1 còn treo (F-2 + F-3)

**Nguồn phán quyết:** vòng review round-9 của Reviewer trên lát P11+P12+P13
(`Outcome: PATCH_REQUIRED`), finding **F-2** và **F-3**. Đây là **khoảng hở
thực thi của chính §10 và §12**, không phải phán quyết thiết kế mới: B-1 đã
được user chốt từ 2026-09-09 và không mở lại ở đây.

### 13.1 Vì sao P11 + P13 chưa đủ, và vì sao đây là một phase chứ không phải hai

§10 sinh 5 cột và cho chúng chạy hết schema → domain → repository → cubit. §12
chỉ tiêu thụ **một** trong năm (`durationMinutes`, qua ô THỜI LƯỢNG) và đọc
thêm `timeOfDaySlot` ở ô KHUNG GIỜ. Kết quả đo được trên cây nguồn hôm nay:

| Cột | Đường đọc (UI hiển thị) | Đường ghi (người dùng đặt được) |
|---|---|---|
| `durationMinutes` | CÓ — `activity_card_detail_screen.dart:97, 622` | CÓ — `editDurationMinutes`, `cubit:184` |
| `timeOfDaySlot` | CÓ — `_timeSlotCard`, `screen:633, 706-756` | **KHÔNG** |
| `noteKeywords` | **KHÔNG** | **KHÔNG** |
| `linkSourceLabel` | **KHÔNG** | **KHÔNG** |
| `linkSavedAt` | **KHÔNG** | **KHÔNG** |

Bốn cột dưới cùng vì thế là bốn cột chết theo hai kiểu đối xứng nhau, và cả
hai kiểu đều là thứ B-1 bỏ tiền ra một cột + một migration để tránh:

- `timeOfDaySlot` **chỉ đọc**: ô KHUNG GIỜ vĩnh viễn hiện "chưa rõ" vì không có
  đường nào đặt giá trị. Chính docstring `screen:704-705` đã tự thú điều này
  ("no editor yet").
- ba cột còn lại **chỉ ghi**: có DDL, có ánh xạ hai chiều, nhưng không một
  pixel nào trên màn hình đọc chúng. `grep -r 'noteKeywords\|linkSourceLabel\|
  linkSavedAt' mobile/lib/features/activity_cards/presentation/` chỉ trả về
  `cubit:406-408` — chỗ mang giá trị qua `_withEdits` để **không xoá mất** khi
  người dùng sửa việc khác, tức là code giữ nhà, không phải code dùng.

Gộp làm một phase vì cả bốn cột dùng chung đúng một cơ chế ghi
(`_persist`/`_withEdits`) và rơi vào đúng ba khối UI liền kề của cùng một file
màn hình (`_noteBlock`, `_metaBlock`, `_sourceLinkRow`). Tách thành hai phase
sẽ tạo một phase chỉ-đọc và một phase chỉ-ghi trên cùng một tập cột — tái lập
nguyên trạng khuyết tật đang phải vá.

### 13.2 F-3 — `editTimeOfDaySlot`, theo đúng khuôn `editDurationMinutes`

Cubit `activity_card_detail_cubit.dart` nhận thêm đúng một phương thức, đặt
ngay cạnh `editDurationMinutes` (dòng 184-187) và sao đúng hình dạng của nó:

```dart
Future<void> editTimeOfDaySlot(TimeOfDaySlot? timeOfDaySlot) => _persist(
      timeOfDaySlot: timeOfDaySlot,
      clearTimeOfDaySlot: timeOfDaySlot == null,
    );
```

Kèm theo, `_persist` (tham số quanh dòng 279) và `_withEdits` (quanh dòng 375)
nhận cặp `timeOfDaySlot` + `clearTimeOfDaySlot`, và dòng 405 đổi từ mang-nguyên
`timeOfDaySlot: card.timeOfDaySlot` sang đúng khuôn ba ngôi của dòng 398-399:
`clearTimeOfDaySlot ? null : timeOfDaySlot ?? card.timeOfDaySlot`. Khối chú
thích `cubit:400-404` nói "bốn cột B-1 còn lại chưa có editor" phải được sửa
theo — sau phase này nó chỉ còn đúng với `linkSavedAt` (§13.4), và một chú
thích nói sai về mã bên dưới nó là nợ, không phải tài liệu.

**Điểm vào UI:** ô KHUNG GIỜ hiện có (`_timeSlotCard`, `screen:706`) trở thành
vùng chạm mở `TimeOfDaySlotPicker` — một sheet **một tầng** đúng 5 lựa chọn
(*Sáng · Trưa · Chiều · Tối* + *Chưa rõ* để xoá về `null`), sao khuôn
`presentation/widgets/status_change_picker.dart` đã có. Không thêm màn trung
gian, không thêm route: đây là ràng buộc A-1 mà P13 vừa thiết lập cho ô tràn,
áp nguyên ở đây.

**Cấm suy `timeOfDaySlot` từ `scheduledOn`** — nguyên văn điều cấm 1 của §10.2,
nhắc lại vì phase này là chỗ duy nhất có thể vi phạm nó.

### 13.3 F-2 — ba cột còn lại lên màn, đúng vị trí trong thứ tự khối A-4

Thứ tự khối A-4 (`screen:318-337`) **không đổi**: tiêu đề → meta → ghi chú →
chip → link → CTA. Cả ba cột vào **bên trong** khối đã có, không sinh khối thứ
bảy.

**(a) `noteKeywords` → trong `_noteBlock` (`screen:547-603`).** Dải chip từ
khoá nằm **dưới** `card_detail_note_field`, trong cùng `Container` và dưới cùng
nhãn `SỔ TAY CÓ GHI` (dòng 567-576). Đây chính là thứ D-17
(`../visual-fidelity/visual-fidelity-report.md`) từng phải hoãn với lý do
`CONTRACT_GAP` — "hợp đồng chỉ có một cột `note` văn tự do và không có danh
sách từ khoá". B-1 đã sinh ra cột đó, nên lý do hoãn hết hiệu lực; canvas A4 vẽ
dải chip tím nhạt và bây giờ dựng được đúng như vẽ.

Quy ước lưu trữ, chốt tại đây vì §10.2 mới nói "danh sách từ khoá ngắn" mà chưa
nói lưu ra sao: **một chuỗi, các mục ngăn bằng dấu phẩy**, mỗi mục `trim()`,
mục rỗng bị loại, giữ nguyên thứ tự người dùng nhập, danh sách rỗng ghi `null`
chứ không ghi chuỗi rỗng. Hàm `parseNoteKeywords` / `formatNoteKeywords` đặt
trong `presentation/formatters/vi_field_format.dart` cùng chỗ với formatter
P12 — cùng một bất biến A-2: **cột lưu dữ liệu thô, màn hình lo trình bày**.
Dấu `·` trên canvas là ký tự phân cách **hiển thị**, không được lưu xuống cột.

Đường ghi: một ô nhập ngắn "thêm từ khoá" ngay dưới dải chip; commit đẩy qua
`ActivityCardDetailCubit.editNoteKeywords(String?)` theo đúng khuôn
`editNote` (`cubit:165`). Chạm vào một chip sẽ xoá chip đó. **Cấm đụng `note`**
(điều cấm 3 của §10.2): hai cột đứng cạnh nhau, không suy cột này từ cột kia,
không migrate chữ từ `note` sang.

**(b) `linkSourceLabel` + `linkSavedAt` → trong `_sourceLinkRow`
(`screen:877-924`).** Hàng link hiện là một dòng: icon `CupidIcons.link` +
`card_detail_source_link_field`. Nó trở thành hai dòng, đúng D-22
(`visual-fidelity-report.md` dòng 428-431: *"Từ cái link bạn dán ngày 28/8"*
cộng URL rút gọn):

- dòng trên — dòng xuất xứ, `Text` chỉ đọc, dựng từ `linkSourceLabel` và
  `linkSavedAt`. `linkSavedAt` định dạng bằng một hàm mới trong
  `vi_field_format.dart` cho ra dạng ngày Việt ngắn (`28/8`), **không** tự nối
  chuỗi tại chỗ. Thiếu cả hai giá trị thì **ẩn hẳn dòng này**, không dựng một
  dòng "chưa rõ" — hàng link phải trở về đúng hình dạng một dòng như hôm nay.
- dòng dưới — `card_detail_source_link_field` giữ nguyên từng ký tự: cùng Key,
  cùng controller, cùng `_commitSourceLink`. AC-6 (link sửa được) không đổi.

Đường ghi `linkSourceLabel`: ô nhập nhãn nguồn riêng trên dòng xuất xứ, đẩy qua
`editLinkSourceLabel(String?)`. **Cấm suy nhãn từ URL** — nguyên văn hợp đồng
`../architecture/contract-summary.md` dòng 80 ("không suy ra từ URL"); một
`Uri.parse().host` là đúng thứ điều cấm đó chặn.

### 13.4 `linkSavedAt` — dẫn xuất, không phải một ô nhập nữa

`linkSavedAt` là **mốc lúc người dùng dán link**, nên nó không có control
riêng: `_commitSourceLink` (`screen:221-228`) khi ghi một `sourceLink` khác
giá trị cũ và không rỗng thì đặt luôn `linkSavedAt` =
`DateTime.now().millisecondsSinceEpoch`; khi xoá link về `null` thì
`linkSavedAt` cũng về `null`. Sửa các trường khác của thẻ **không** được chạm
vào nó.

Đây là ngoại lệ có chủ đích với "mọi cột phải có đường ghi của người dùng": có
đường ghi, nhưng do hành động dán link kích hoạt, không do một ô nhập thứ hai.
Bắt người dùng gõ tay ngày họ dán link là vô nghĩa, và một `DateTimeColumn` cho
người dùng chọn là đúng thứ §10.2 đã loại (cột là `INTEGER`, không `DATETIME`).

Cả `sourceLink` và `linkSavedAt` phải đi trong **cùng một** lần gọi `_persist`.
Hai lần gọi liên tiếp sẽ có một khoảnh khắc thẻ đã có link mới mà mốc còn cũ,
ghi xuống đĩa được, và §7.2 nói rõ mỗi lần ghi là **một ảnh chụp toàn phần**.

### 13.5 F-5 — đã kiểm chứng trên mã nguồn: **KHÔNG có việc phải làm**

Handoff round-9 mô tả F-5 là "`event`/`history` được thêm vào `cupid_icons.dart`
nhưng không bao giờ nối vào call site", chỉ tới
`activity_card_detail_screen.dart:1004`. Đọc thẳng mã trong worktree cho kết
quả ngược lại, và mobile-dev **không được sửa gì theo mục này**:

| Icon P13 | §12.5 giao cho | Thực tế trên cây nguồn |
|---|---|---|
| `event` | hàng meta | `screen:680`, trong `_metaDateRow` — **đã nối** |
| `history` | ô tràn | `card_detail_overflow_menu.dart:38` — **đã nối** |
| `image` | khối ảnh | `screen:533`, trong `_memoryPhotoPlaceholder` — **đã nối** |
| `delete` | ô tràn | `card_detail_overflow_menu.dart:40` — **đã nối** |

Dòng 1004 nằm trong `_primaryAction` (bắt đầu ở dòng 968): đó là **icon của CTA
chính**, chọn giữa `menuBook` và `schedule` theo
`outlined = action == ActivityCardPrimaryAction.review`. §12.5 chưa bao giờ
giao `event`/`history` cho CTA, và thay icon ở đó sẽ làm hỏng cặp icon SC-4 mà
D-18 đã đóng. Đổi dòng 1004 là một **regression**, không phải một bản vá.

Ghi lại kết luận này vào `coding-plan/test-results.md` kèm 4 dòng bằng chứng
trên để vòng review sau không mở lại F-5 lần thứ hai.

### 13.6 Test bắt buộc

1. `editTimeOfDaySlot` đặt được cả 4 giá trị và xoá được về `null`; đọc lại từ
   repository ra đúng giá trị (F-3 khép vòng ghi-đọc, không chỉ khẳng định UI).
2. Ô KHUNG GIỜ: chạm → mở picker một tầng đúng 5 lựa chọn; chọn *Tối* → ô hiện
   nhãn *Tối*, không còn "chưa rõ"; chọn *Chưa rõ* → về "chưa rõ".
3. Thẻ có `noteKeywords` hiện đúng số chip đúng thứ tự dưới nhãn `SỔ TAY CÓ
   GHI`; thẻ `noteKeywords == null` **không** dựng dải chip rỗng.
4. Nhập "cà phê , , sách " → cột lưu đúng `cà phê,sách` (trim, loại rỗng, không
   lưu `·`); xoá hết chip → cột về `null`, không phải chuỗi rỗng.
5. Thẻ có `linkSourceLabel` + `linkSavedAt` hiện dòng xuất xứ hai giá trị đúng
   dạng ngày Việt; thẻ thiếu cả hai **không** dựng dòng đó, và
   `card_detail_source_link_field` vẫn tìm thấy được ở cả hai trường hợp.
6. Dán link mới → `linkSavedAt` khác `null` sau đúng **một** lần ghi; xoá link
   → cả hai về `null`; sửa `note` sau đó **không** làm `linkSavedAt` đổi
   (đây là bài kiểm tra chống thoái lui cho `_withEdits`).
7. Thứ tự khối A-4 (§12.6 rule 6) vẫn xanh không sửa: ba cột mới vào bên trong
   khối cũ, không đẩy khối nào đi chỗ khác.

### 13.7 File dự kiến của P14 (7 file mã/test)

| # | File | Thay đổi |
|---|------|----------|
| 1 | `mobile/lib/features/activity_cards/presentation/activity_card_detail_cubit.dart` | `editTimeOfDaySlot` + `editNoteKeywords` + `editLinkSourceLabel`; plumbing `_persist`/`_withEdits` cho 4 cột; sửa chú thích dòng 400-404 (§13.2) |
| 2 | `mobile/lib/features/activity_cards/presentation/screens/activity_card_detail_screen.dart` | Dải chip + ô thêm từ khoá trong `_noteBlock`; dòng xuất xứ hai dòng trong `_sourceLinkRow`; `_timeSlotCard` thành vùng chạm; `_commitSourceLink` đặt `linkSavedAt` (§13.2-§13.4) |
| 3 | `mobile/lib/features/activity_cards/presentation/widgets/time_of_day_slot_picker.dart` | **Mới** — sheet một tầng 5 lựa chọn, khuôn `status_change_picker.dart` (§13.2) |
| 4 | `mobile/lib/features/activity_cards/presentation/formatters/vi_field_format.dart` | `parseNoteKeywords`/`formatNoteKeywords` + định dạng ngày Việt ngắn cho `linkSavedAt` (§13.3) |
| 5 | `mobile/test/features/activity_cards/activity_card_detail_screen_test.dart` | Rule 2-7 (§13.6) |
| 6 | `mobile/test/features/activity_cards/vi_field_format_test.dart` | Rule 4 phần thuần hàm (§13.6) |
| 7 | `mobile/test/features/activity_cards/time_of_day_slot_picker_test.dart` | **Mới** — hình dạng picker một tầng, rule 1 (§13.6) |

Cộng hai artifact: `coding-plan/phase-P14-b1-column-read-write-closure.md` và
mục evidence trong `coding-plan/test-results.md` (gồm cả kết luận F-5 ở §13.5).

Bảy file, cùng một lifecycle Mobile. Không tách: mọi cách chia đôi tập này đều
để lại một nửa chỉ-đọc hoặc chỉ-ghi trên cùng tập cột — đúng khuyết tật F-2/F-3
đang vá (§13.1).

### 13.8 Cấm trong P14

- Không sửa migration của §10.4. Hình dạng `if (from < 3) … else if (from < 4)`
  đang ship là **đúng**; §10.4 vừa được vá **câu chữ**, mã giữ nguyên.
- Không đổi dòng 1004 `activity_card_detail_screen.dart` (§13.5).
- Không đổi thứ tự khối A-4, không đổi 4 nhãn SC-4, không đổi
  `activityPrimaryActionFor`.
- Không thêm cột thứ 6 (điều cấm 2 của §10.2), không đụng `note` (điều cấm 3),
  không suy `timeOfDaySlot` từ `scheduledOn` (điều cấm 1).
- Không suy `linkSourceLabel` từ URL.
- Không mở lại A-1/A-2/A-3/A-4/B-1/D-8/D-19/D-20/D-24/D-25, và không đụng khoảng
  hở icon chia sẻ F-6 — Scrum Master đã đóng F-6 là **ngoài phạm vi**
  STORY-001 (`../../req_master.md` → `## Design Ruling Log`, R9-F-6).

### 13.9 Điều kiện đóng P14

`flutter analyze lib test` 0 error, `flutter test` xanh, và 7 rule ở §13.6
xanh. P14 **không** tự chạy startup smoke — R-2 vẫn là một lần chạy ở cấp story
(§6). Sau P14, cả 5 cột B-1 đều có đường đọc **và** đường ghi; bảng ở §13.1 là
tiêu chí nghiệm thu đọc ngược.
