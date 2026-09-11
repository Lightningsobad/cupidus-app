# Phase P4 – Cầu payload widget + widget màn hình chính Android

## 1. Objective

Đẩy **một** payload đã dựng sẵn chữ từ Dart sang kho khoá-giá trị native, và
dựng widget Android đọc payload đó. Native không giữ một câu chữ nào, và widget
không bao giờ lộ nội dung riêng tư.

## 1A. Ownership

- Phase ID: P4
- Canonical Phase File: `phase-P4-widget-bridge-android.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2, P3
- Parallelizable: YES (song song P6, P7)
- Write Scope:
  - `mobile/lib/features/phase_status/data/home_widget_bridge.dart`
  - `mobile/android/app/src/main/kotlin/com/snapsofts/cupid/CupidPhaseWidgetProvider.kt`
  - `mobile/android/app/src/main/res/layout/cupid_phase_widget.xml`
  - `mobile/android/app/src/main/res/xml/cupid_phase_widget_info.xml`
  - `mobile/android/app/src/main/AndroidManifest.xml` (chỉ thêm receiver)
  - `mobile/pubspec.yaml` (chỉ thêm `home_widget`)
  - `mobile/test/features/phase_status/home_widget_bridge_test.dart`
  - `mobile/test/features/phase_status/native_copy_scan_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
- Shared Interfaces Produced:
  - `buildWidgetPayload` (hàm duy nhất dựng payload) + tập khoá native
- Shared Interfaces Consumed:
  - P2 `resolveSoloPhase`, P3 `WealthCounter`/`DripCadencePolicy`, P1 gói nội dung
- Risk Surfaces:
  - `WIDGET-LEAK`
  - `HARDCODED-COPY`
  - `WIDGET-STALE`
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §1, §2, §3
  - consumer contract: P5 (iOS) đọc **đúng** tập khoá này, không thêm khoá riêng
- Primary Inputs Summary:
  - requirements: AC-30..AC-33, AC-36, AC-37, BR-11, BR-15
  - architecture: `../architecture/contract-summary.md` §1, §2, §3, §5;
    `../architecture/solution.md` §4 (`WIDGET-LEAK`, `HARDCODED-COPY`,
    `WIDGET-STALE`)
  - upstream phase outputs: P1, P2, P3
  - UX constraints: `../ux/uiux-spec.md` §2
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO (P5 tạo file này và gộp cả phần Android vào đó)
- Phase Sizing:
  - Behavior Slice: một bề mặt widget, một nền tảng
  - Source/Test File Count: 4 source + 2 file cấu hình sửa + 2 test
  - Split Required: NO
  - Split Rationale: cầu Dart và bên đọc Android là **một** hành vi; tách ra sẽ
    có một dispatch ghi khoá chưa ai đọc

## 2. Required Reads

- `../requirements/` nhóm H (AC-30..AC-33) + AC-36, AC-37, BR-11, BR-15
- `../architecture/contract-summary.md` §1, §2, §3, §5
- `mobile/android/app/src/main/AndroidManifest.xml`
- `mobile/android/app/build.gradle.kts` (kiểm `compileSdk`, flavor)

## 3. Tasks

- Thêm `home_widget: ^0.9.4` vào `pubspec.yaml`. Không thêm gói nào khác.
- `home_widget_bridge.dart` phơi **đúng một** hàm dựng payload,
  `buildWidgetPayload({required PhaseResolution, ...}) -> Map<String,String>`,
  thuần hàm, không I/O. Một hàm thứ hai `pushWidgetPayload` chỉ làm việc ghi.
- Khoá ghi ra đúng danh sách ở `contract-summary.md` §2: `phase_id`,
  `primary_line`, `secondary_line`, `card_id`, `computed_on`. Không khoá nào khác.
- **Dart dựng xong chuỗi hiển thị cuối cùng** rồi mới đẩy. Native không ghép
  chuỗi, không có bảng chữ, không có chuỗi mặc định (AC-37/BR-15).
- Thứ tự ưu tiên nội dung pha `quiet` theo `../ux/uiux-spec.md` §2; khi mọi nguồn
  trả `null` thì đẩy payload **rỗng chữ** chứ không đẩy câu trấn an nào.
- Cập nhật payload ở đúng ba thời điểm: khi màn (1) mount, khi app resume, và
  ngay sau khi trạng thái thẻ đổi. Không job nền, không alarm (`WIDGET-STALE`).
- `CupidPhaseWidgetProvider.kt`: đọc `SharedPreferences` của `home_widget`, bơm
  vào `RemoteViews`. Không có chuỗi tiếng Việt nào trong file `.kt` và `.xml`
  ngoài `android:contentDescription` lấy từ resource rỗng/kỹ thuật.
- Không payload → `RemoteViews` dựng **khung không chữ**, không placeholder,
  không logo kèm câu.
- Nhấn widget → deep link `cupidapp://card/<card_id>` (hoặc `cupidapp://home` khi
  không có thẻ), qua `PendingIntent` với `FLAG_IMMUTABLE`.
- Manifest: thêm `<receiver>` + `<meta-data>` trỏ `cupid_phase_widget_info.xml`.
  Không thêm quyền nào ở phase này.

## 4. Acceptance Criteria

- Widget **không bao giờ** hiển thị nội dung sổ tay, nhật ký, hay tin nhắn — chỉ
  hiện dòng do gói nội dung cấp (AC-31/BR-11).
- Widget không hiện số ngày đợi, không phần trăm, không chuỗi ngày (AC-32).
- Người nhìn lướt qua vai không suy ra được trạng thái mối quan hệ (BR-11):
  payload pha `waiting` không được khác pha `quiet` về mức riêng tư.
- Không có payload → khung không chữ, không lỗi, không câu mặc định (AC-36).
- Không file native nào (`.kt`, `.xml`, `.swift`) chứa chuỗi hiển thị (AC-37).
- Widget cập nhật khi trạng thái đổi mà không cần tiến trình nền (AC-33).

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/phase_status/data/`,
  `mobile/android/app/src/main/`
- Contracts or schemas: tập khoá native theo `contract-summary.md` §2
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Dart unit test + quét tĩnh mã native + build APK debug
- Required levels:
  - unit: `buildWidgetPayload` cho cả bốn pha + nhánh không payload
  - mobile build/type-check/static-analysis: `flutter analyze lib test` (đếm
    *error*) và `flutter build apk --debug --flavor local` chạy **không pipe**
- Required checks:
  - `native_copy_scan_test.dart`: quét `android/app/src/main/**` (`.kt`, `.xml`)
    tìm ký tự có dấu tiếng Việt và chuỗi hiển thị; có là **đỏ** (`HARDCODED-COPY`)
  - test khẳng định tập khoá payload **đúng bằng** danh sách §2, không thừa khoá
  - test rò rỉ: dựng payload từ thẻ có ghi chú riêng tư, khẳng định không ký tự
    nào của ghi chú đó xuất hiện trong bất kỳ giá trị nào (`WIDGET-LEAK`)
  - test khẳng định `pushWidgetPayload` không được gọi từ bất kỳ timer/isolate nào
- Minimum gates by risk surface: `WIDGET-LEAK`, `HARDCODED-COPY`, `WIDGET-STALE`
- Required regression or contract coverage: toàn bộ `mobile/test/` vẫn xanh sau
  khi thêm dependency mới
- Evidence format: `flutter test` + dòng kết `flutter build apk` nguyên văn
- Per-story visual fidelity:
  `NOT_APPLICABLE — bề mặt widget hệ điều hành, không phải route Flutter`
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/phase_status/` rồi `flutter test`
  - Build/type-check/lint command when required:
    `flutter build apk --debug --flavor local` (chạy trực tiếp, không pipe)
  - Required assertion evidence: tên test, số pass/fail, và dòng kết quả build

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
