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

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Mất dữ liệu gốc khi đăng xuất | P1 |
| R-1b — trôi schema sang đo hành vi người kia | P1 |
| Migration v2→v3 trên máy đã cài | P1 |
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

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | DONE |
| P3 | Mobile Developer | Mobile | P2 | NO | DONE |
| P4 | Mobile Developer | Mobile | P2 | NO | PATCH_REQUIRED |
| P7 | Mobile Developer | Mobile | P4 | NO | DONE |
| P5 | Mobile Developer | Mobile | P3, P4, P7 | NO | PATCH_REQUIRED |
| P6 | Mobile Developer | Mobile | P4, P7 | NO | PATCH_REQUIRED |
| P8 | Mobile Developer | Mobile | P2, P6 | NO | PLANNED |

Số hiệu phase là append-only, nên P7 lớn hơn P5/P6 về số nhưng chạy **trước**
chúng. Thứ tự thực thi đọc ở cột `Depends On`, không đọc theo số hiệu.

Vòng patch sau slice review (`../review/review-report.md`, `Outcome:
PATCH_REQUIRED`):

| Phase | Trạng thái sau review | Lý do |
|-------|-----------------------|-------|
| P1 | DONE — đóng, không review lại | Không finding nào chạm file của P1 (S1 sạch) |
| P2 | DONE — đóng, không review lại | Hợp đồng gốc giữ nguyên; phần bổ sung nằm ở P8 |
| P3 | DONE — đóng, không review lại | S3 sạch; mọi finding còn lại là DEFERRED |
| P7 | DONE — đóng, không review lại | Nửa P7 của S2 sạch; `ActivityType` không đổi |
| P4 | PATCH_REQUIRED | B-1: hub chưa mount P5/P6; kèm S4-F-3, S4-F-8 |
| P5 | PATCH_REQUIRED | B-5 nửa code: quick-entry strip render ô rỗng; kèm S5-F-4 |
| P6 | PATCH_REQUIRED | B-1 (điểm đến detail) + B-4 (3 test đỏ do story này gây ra) |
| P8 | PLANNED (mới) | B-2: hợp đồng ghi trường sau khi tạo — xem §7 |

Ràng buộc B-3: P8 và bản vá P4/P6 phải **cùng** vào một vòng merge. P8 một mình
sửa đường ghi mà không ai thấy; P4/P6 một mình biến lỗi tiềm ẩn thành lỗi lộ
mặt người dùng. Không phase nào trong cặp này được merge lẻ.

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
