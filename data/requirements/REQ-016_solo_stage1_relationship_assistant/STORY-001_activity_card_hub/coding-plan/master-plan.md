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
  - Cập nhật 2026-09-08: R-2 vẫn **REQUIRED** và giữ nguyên 4 điều kiện, nhưng
    lần chạy trên emulator-5554 sau P8 là **INVALID-FOR-GATE**, không phải
    FAILED: nó đo trên bản dựng mà bề mặt solo còn bị cổng gốc chặn. Chạy lại
    sau khi P9 (§8) vào. Xem §6 → "Cập nhật R-2".

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
| P9 | Mobile Developer | Mobile | P4, P8 | NO | PLANNED |

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
| P4 | PATCHED_PENDING_GATE | B-1 đã nối điều hướng thật (empty state → capture, chạm thẻ → màn detail P6); S4-F-3 nằm ngoài WriteScope |
| P5 | PATCHED_PENDING_GATE | B-5 nửa code đã đóng (xoá placeholder `_QuickEntryStrip`, mount strip thật); kèm S5-F-4 fallback cuộn ngang |
| P6 | PATCHED_PENDING_GATE | B-1 điểm đến detail + B-4 (3 test đỏ) đã đóng |
| P8 | PATCHED_PENDING_GATE | B-2 đã hiện thực trên cả 8 implementer, analyze 0 error; blocker còn lại là startup smoke R-2 (xem `phase-P8-card-field-write-path.md` §8) |
| P9 | PLANNED | Mở cổng gốc cho phiên chưa ghép đôi vào bề mặt solo; điều kiện cần để R-2 đo được (§8) |

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
