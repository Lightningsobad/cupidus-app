# Phase P9 – Nhãn-mí pha + chấm màu trên widget (D-10, install delta D-11/D-12)

## 1. Objective

Widget màn hình chính hiện thêm một **nhãn-mí pha** (eyebrow, "PHA n · <tên
pha>") kèm một **chấm màu riêng của pha** phía trên khối primary/secondary sẵn
có (D-10, AC-9, AC-37, BR-15), dùng đúng khoá payload và bộ token native mà
`architecture/contract-summary.md` §2/§3/§3a đã mở rộng ở lượt
`architecture-solution` trước phase này. D-11 (chia số đếm ngược) và D-12
(bảng màu thương hiệu tối) đã DONE ở P8 (`Lượt patch #2 — C-1`,
2026-09-19, xem `coding-plan/test-results.md`) — phase này chỉ phải **giữ
nguyên**, không sửa lại, hai delta đó trong khi cài D-10; đây là lý do handoff
gọi cả ba là "install delta gộp".

## 1A. Ownership

- Phase ID: P9
- Canonical Phase File: `phase-P9-widget-phase-label-and-dot.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P4, P5
- Parallelizable: YES (không đụng file nào P10 sửa)
- Write Scope:
  - `mobile/lib/features/phase_status/domain/phase_content.dart`
  - `mobile/lib/features/phase_status/data/home_widget_bridge.dart`
  - `mobile/assets/data/req016/phase_content.v1.json`
  - `mobile/android/app/src/main/res/layout/cupid_phase_widget.xml`
  - `mobile/android/app/src/main/kotlin/com/snapsofts/cupid/CupidPhaseWidgetProvider.kt`
  - `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.swift`
  - native palette definition nơi `CupidWidgetPalette` (D-12) hiện sống — file
    Swift + tương đương Android (color resource hoặc Kotlin object); mobile-dev
    xác định đúng file bằng cách đọc chính định nghĩa D-12 hiện có, không tạo
    file mới nếu một file đã tồn tại cho việc này.
  - `mobile/test/features/phase_status/native_copy_scan_test.dart`
  - test cho `phase_content.dart`/`home_widget_bridge.dart` (đúng tên file
    test hiện có của hai file trên, không tạo tên mới)
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: mobile-app
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - None (payload contract đã chốt ở `architecture/contract-summary.md` §2/§3a
    bởi lượt `architecture-solution`)
- Shared Interfaces Consumed:
  - `../architecture/contract-summary.md` §2 (khoá `eyebrow_line`), §3a (bốn
    vai trò token chấm màu theo `phase_id`), §4 (trường `eyebrow` của
    `phase_content.v1.json`)
- Risk Surfaces:
  - `HARDCODED-COPY`
  - `WIDGET-LEAK`
  - `WIDGET-STALE`
- Source Of Truth:
  - authoritative artifact: `../architecture/contract-summary.md` §2/§3/§3a/§4
  - consumer contract: `mobile/test/features/phase_status/native_copy_scan_test.dart`
- Primary Inputs Summary:
  - requirements: AC-9, AC-37, BR-15 (`../requirements/requirements.md`)
  - architecture: `../architecture/contract-summary.md` §2/§3/§3a/§4 (đã mở
    rộng ở lượt trước, KHÔNG sửa lại trong phase này)
  - OQ constraints: none
  - upstream phase outputs: P4 (`buildWidgetPayload`, khoá payload), P5 (iOS
    `CupidPhaseWidget.swift` timeline entry), P8 (D-11/D-12 đã DONE, giữ
    nguyên)
  - UX constraints: `../ux/uiux-spec.md` §2 (nhãn-mí + chấm màu, đoạn "Vá
    2026-09-17")
  - review findings: `../review/review-report.md` mục "Cổng quyết định
    PATCH_REQUIRED" — D-10 là 1 trong 2 delta cần quyết kiến trúc trước khi
    patch (quyết định đã có, đây là lượt patch)
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: một trường nội dung mới (eyebrow) + một tập token native
    đọc theo `phase_id` có sẵn — không thêm khoá logic mới, không đổi luồng
    dữ liệu (`PhaseResolution` không đổi, xem ghi chú §3 Tasks)
  - Source/Test File Count: ~9 file (5 nguồn + tối đa 2 file token native + 2
    test), trong ngưỡng một vòng đời chuyên gia
  - Split Required: NO
  - Split Rationale: D-10/D-11/D-12 là một hợp đồng payload + một bảng token
    duy nhất; tách sẽ buộc hai phase cùng sửa `native_copy_scan_test.dart` và
    cùng file palette, trái quy tắc "không tách vì file trùng"

## 2. Required Reads

- `../requirements/requirements.md` (AC-9, AC-37, BR-15 — dùng đúng anchor, đã
  đọc ở lượt trước, không đọc lại toàn văn)
- `../architecture/contract-summary.md` §2, §3, §3a, §4
- `phase-P4-widget-bridge-android.md`, `phase-P5-widget-ios-extension.md` (P4,
  P5 — pattern khoá payload + test đã có)
- `../ux/uiux-spec.md` §2 (đoạn "Vá 2026-09-17", đã đọc ở lượt trước)
- `../review/review-report.md` mục "Cổng quyết định PATCH_REQUIRED" (D-10)

## 3. Tasks

- Thêm trường `eyebrow` (String, bắt buộc) vào `PhaseContentItem`
  (`phase_content.dart`): constructor, field, và
  `phaseContentItemFromJson` đọc qua `requireContentString(json, 'eyebrow',
  source)`. Thêm `eyebrow` vào `displayStrings` (`<String>[primary, ?secondary,
  eyebrow]`) — đây là chuỗi hiển thị mới, phải lọt vào chính cổng
  `CONTENT-GATE`/AC-39 đang quét `displayStrings`, không phải một trường phụ.
- Thêm mọi mục `eyebrow` còn thiếu vào **toàn bộ** entry của
  `phase_content.v1.json` (không chỉ 4 pha, mà mọi entry hiện có, kể cả
  `surface: screen`) — trường bắt buộc nên parser vỡ nếu bỏ sót một entry;
  liệt kê đủ số entry đã sửa trong `test-results.md`.
- Thêm `const String widgetKeyEyebrowLine = 'eyebrow_line';` vào
  `home_widget_bridge.dart`, thêm vào `widgetPayloadKeys` (giữ đúng thứ tự
  hợp đồng ở contract-summary.md §2), và thêm dòng
  `widgetKeyEyebrowLine: item.eyebrow,` vào map trả về của
  `buildWidgetPayload` — eyebrow không đi qua `_fill`/`{n}` (AC-9 cấm số/giờ
  trong nhãn-mí).
- Android: thêm `TextView` nhãn-mí + một `View`/`ImageView` chấm màu vào
  `cupid_phase_widget.xml`; trong `CupidPhaseWidgetProvider.kt`, đọc
  `eyebrow_line` từ payload và set text, đọc `phase_id` để chọn đúng một
  trong bốn vai trò token (`--dot-waiting`/`--dot-upcoming`/`--dot-today`/
  `--dot-quiet`) từ chính định nghĩa D-12 hiện có — không hardcode mã màu mới
  song song.
- iOS: thêm trường nhãn-mí vào timeline entry của `CupidPhaseWidget.swift`,
  đọc `eyebrow_line`, và chọn màu chấm theo `phase_id` từ `CupidWidgetPalette`
  (D-12) hiện có.
- Mở rộng `native_copy_scan_test.dart`: (a) khẳng định `eyebrow_line` có mặt
  trong tập khoá Dart/native; (b) khẳng định không có chuỗi nhãn-mí hardcode
  trong Kotlin/Swift/XML (chỉ đọc từ payload); (c) khẳng định đúng bốn vai trò
  token được tham chiếu, không role thứ năm, không màu mặc định hệ điều hành.
- Không sửa `domain/solo_phase.dart` / `domain/solo_phase_resolver.dart`:
  `PhaseResolution` không mang nhãn-mí — nhãn-mí đến thẳng từ
  `PhaseContentItem` qua `_widgetLineFor`, đúng đường D-11/D-12 đã đi; xác
  nhận điều này bằng test thay vì bằng đổi kiểu dữ liệu.

## 4. Acceptance Criteria

- AC-9: widget hiện nhãn-mí pha + chấm màu đúng pha đang active; đổi pha thì
  cả nhãn-mí lẫn chấm màu đổi theo (không riêng primary/secondary).
- AC-37/BR-15: không chuỗi nhãn-mí nào nằm trong `cupid_phase_widget.xml`,
  `CupidPhaseWidgetProvider.kt`, hay `CupidPhaseWidget.swift`; đổi câu nhãn-mí
  chỉ cần sửa `phase_content.v1.json`.
- `phase_content.v1.json` không entry nào thiếu `eyebrow` (parser lỗi cứng
  nếu thiếu — test phải khẳng định lỗi này, không chỉ khẳng định trường hợp
  đủ).
- D-11/D-12 (đã DONE ở P8) không hồi quy: `native_copy_scan_test.dart` case
  D-11 (`CupidPhaseSplit.of`) và D-12 (`CupidWidgetPalette`, cấm
  `?android:attr/`/`Color.clear`) vẫn PASS nguyên văn sau lượt sửa này.
- `flutter test test/features/phase_status` xanh toàn bộ, không giảm số case
  so với P8.

## 5. Planned Outputs

- Code directories or files: xem Write Scope
- Contracts or schemas: không thay đổi (đã chốt ở architecture-solution
  trước phase này)
- Requirement configuration guide updates: none
- Notes or evidence: cập nhật `coding-plan/test-results.md` với lượt patch
  D-10, và `visual-fidelity/` nếu widget được chụp lại

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: mobile (Dart unit/widget test + static scan test trên
  layout/Kotlin/Swift qua chuỗi văn bản, không chạy build native)
- Required levels (omit N/A levels):
  - unit: `phase_content.dart` (parse `eyebrow`, lỗi khi thiếu),
    `home_widget_bridge.dart` (`buildWidgetPayload` trả `eyebrow_line`)
  - mobile build/type-check/static-analysis: `flutter analyze
    lib/features/phase_status` (0 error, so theo baseline đã ghi ở
    `master-plan.md` §6 Notes)
- Required checks: `native_copy_scan_test.dart` mở rộng (xem §3 Tasks)
- Mobile discoverability / navigation integration: N/A — widget không phải
  route trong app, bề mặt khám phá đã đóng ở P4/P5
- Minimum gates by risk surface: `HARDCODED-COPY` → static scan test;
  `WIDGET-STALE` → `widgetPayloadKeys` đủ 6 khoá, mọi push ghi cả 6
- Required regression or contract coverage: D-11/D-12 case trong
  `native_copy_scan_test.dart` phải PASS không đổi assertion
- Evidence format: lệnh + kết quả `flutter test`/`flutter analyze` dán
  nguyên văn vào `coding-plan/test-results.md`, theo đúng khuôn các lượt
  patch trước
- Per-story visual fidelity: REQUIRED — widget là UI đổi thị giác
  - Design screen id: canvas widget bốn pha trên `cupid-ch-ng-1` (id thật lấy
    qua `render-design-canvas.js --list-screens`, không dùng `--label`, theo
    ghi chú `design_anchor` đã có của story này)
  - Captured: ảnh widget bốn pha hiện tại là `NOT_COMPARED` trong
    `review-report.md` P-1 — phase này phải chụp và so sánh, đóng đúng ô còn
    thiếu đó
- Runtime startup smoke (omit if NO): NO

## 7. Status

- Status: PENDING
- Last updated: 2026-09-25
