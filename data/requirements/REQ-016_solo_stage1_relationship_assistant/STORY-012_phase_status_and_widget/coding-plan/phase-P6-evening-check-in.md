# Phase P6 – Nhắc buổi tối sau hẹn + sheet ảnh/nhật ký + hai công tắc

## 1. Objective

Một lời nhắc cục bộ **đúng một lần** cho mỗi thẻ, dẫn thẳng tới chỗ lưu lại ảnh
và dòng nhật ký, cộng hai công tắc tắt hẳn. Nhắc lần hai là vi phạm, không phải
tính năng.

## 1A. Ownership

- Phase ID: P6
- Canonical Phase File: `phase-P6-evening-check-in.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: YES (song song P4, P7)
- Write Scope:
  - `mobile/lib/features/phase_status/data/local_notification_scheduler.dart`
  - `mobile/lib/features/phase_status/domain/evening_check_in_scheduler.dart`
  - `mobile/lib/features/phase_status/presentation/evening_check_in_sheet.dart`
  - `mobile/lib/features/account/presentation/screens/me_screen.dart` (chỉ thêm
    đúng hai hàng công tắc)
  - `mobile/android/app/src/main/AndroidManifest.xml` (chỉ quyền thông báo)
  - `mobile/ios/Runner/AppDelegate.swift` (chỉ đăng ký plugin thông báo)
  - `mobile/test/features/phase_status/evening_check_in_scheduler_test.dart`
  - `mobile/test/features/phase_status/evening_check_in_sheet_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
- Shared Interfaces Produced:
  - `LocalNotificationScheduler` (lớp bọc duy nhất quanh plugin thông báo)
- Shared Interfaces Consumed:
  - P1 gói `nudges.v1.json`, P2 `PhaseStatusPrefs`
  - `mobile/lib/features/journal/presentation/journal_entry_point.dart`
- Risk Surfaces:
  - `REMIND-REPEAT`
- Source Of Truth:
  - authoritative artifact or convention: `../ux/uiux-spec.md` §4
  - consumer contract: không phase nào tiêu thụ P6
- Primary Inputs Summary:
  - requirements: AC-14..AC-19, AC-35, BR-10, BR-14
  - architecture: `../architecture/solution.md` §1 Key Discovery (không có lane
    backend → nhắc phải lên lịch cục bộ), §4 (`REMIND-REPEAT`), assumption A-3
  - upstream phase outputs: P1, P2
  - UX constraints: `../ux/uiux-spec.md` §4, §7
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO (P5 ghi mục quyền thông báo; nếu P5 chưa chạy, P6 ghi
    tạm mục đó và P5 gộp lại)
- Phase Sizing:
  - Behavior Slice: một lời nhắc và đích đến của nó
  - Source/Test File Count: 3 source + 3 file cấu hình/màn sửa + 2 test
  - Split Required: NO
  - Split Rationale: đã kịch trần; vẫn không tách vì tách sẽ ship một thông báo
    chưa có đích đến, đúng thứ AC-16 cấm

## 2. Required Reads

- `../requirements/` nhóm D (AC-14..AC-19) + AC-35, BR-10, BR-14
- `../ux/uiux-spec.md` §4, §7
- `mobile/lib/features/journal/presentation/journal_entry_point.dart`
- `mobile/lib/features/account/presentation/screens/me_screen.dart`
- `mobile/android/app/build.gradle.kts` — xác nhận `compileSdk` ≥ 35 **trước**
  khi ghim phiên bản plugin (assumption A-3)

## 3. Tasks

- Thêm `flutter_local_notifications` + `timezone` vào `pubspec.yaml`. Xác minh
  ràng buộc Flutter SDK ≥ 3.38.1 và `compileSdk` ≥ 35 trước; nếu không thoả, dừng
  và báo blocker thay vì hạ cấp ràng buộc bản dựng.
- `LocalNotificationScheduler`: bọc plugin, phơi `schedule`, `cancel`,
  `requestPermission`. Dùng `AndroidScheduleMode.inexactAllowWhileIdle` —
  **bắt buộc**. Không `exactAllowWhileIdle`, không xin
  `SCHEDULE_EXACT_ALARM` trong manifest (Android 14 cấm đường đó, và ADR-002 D1
  cấm báo thức hệ thống).
- `EveningCheckInScheduler`: khi một thẻ vào `dateDay`, đặt lịch **một** thông
  báo lúc 23h **nếu** `phase_status.reminded_on.<cardId>` chưa có giá trị. Sau
  khi đặt, ghi khoá ngay. Bỏ qua một lần → không bao giờ nhắc lại thẻ đó (BR-10).
- Nội dung thông báo lấy từ gói `nudges.v1.json` slot tương ứng; **không** chuỗi
  cứng, kể cả tiêu đề kênh Android — kênh dùng tên kỹ thuật không dấu.
- Chạm thông báo → mở `EveningCheckInSheet`: đúng hai lối, thêm ảnh và viết dòng
  nhật ký. Không chấm điểm, không đánh giá, không hỏi về người kia (AC-17/BR-14).
- Sheet **định tuyến vào** `journal_entry_point.dart` sẵn có (STORY-003); không
  dựng composer thứ hai.
- Bỏ qua sheet là kết thúc hợp lệ: không nhắc lại, không dấu chấm đỏ, không mục
  "chưa hoàn thành" ở đâu cả (AC-19).
- `me_screen.dart`: thêm **đúng hai** hàng công tắc theo `../ux/uiux-spec.md` §7.
  Tắt → huỷ mọi lịch đang treo và không đặt thêm (AC-35). Không thêm hàng thứ ba.
- Android 13+: xin `POST_NOTIFICATIONS` **tại thời điểm** đặt lịch đầu tiên, chứ
  không xin lúc khởi động app. Từ chối quyền → im lặng, không banner nài nỉ.

## 4. Acceptance Criteria

- Một thẻ `dateDay` → tối đa **một** thông báo, kể cả khi app mở lại nhiều lần
  trong ngày (AC-16/`REMIND-REPEAT`).
- Bỏ qua một lần → thẻ đó không bao giờ được nhắc lại (BR-10/AC-18).
- Sheet chỉ có hai lối: ảnh và dòng nhật ký (AC-17).
- Không chấm điểm buổi hẹn, không hỏi phản ứng người kia (BR-14).
- Bỏ qua không để lại dấu hiệu "còn nợ" nào trong app (AC-19).
- Tắt công tắc → không thông báo nào nữa, và các lịch đang treo bị huỷ (AC-35).
- Không dùng exact alarm, không tiến trình nền (ADR-002 D1).

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/phase_status/`,
  `mobile/lib/features/account/presentation/screens/`
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Dart unit + widget test, plugin thông báo được mock
- Required levels:
  - unit: cổng nhắc một-lần, huỷ lịch khi tắt công tắc, nhánh từ chối quyền
  - widget: sheet đúng hai lối, bỏ qua không để lại dấu vết
  - mobile build/type-check/static-analysis: `flutter analyze lib test`, đếm *error*
- Required checks:
  - test mô phỏng **mở app 5 lần** trong cùng ngày cho cùng thẻ `dateDay`:
    đúng 1 lần gọi `schedule` (`REMIND-REPEAT`)
  - test khẳng định `AndroidScheduleMode.inexactAllowWhileIdle` được truyền, và
    grep khẳng định `SCHEDULE_EXACT_ALARM` không có trong manifest
  - test nhánh `BeforeYouGoPhase == null` vẫn đặt được lịch (assumption A-2)
  - grep khẳng định không chuỗi hiển thị nào trong scheduler
- Minimum gates by risk surface: `REMIND-REPEAT`
- Required regression or contract coverage: `mobile/test/features/journal/` và
  `mobile/test/features/account/` vẫn xanh
- Evidence format: `flutter test` output dán vào `coding-plan/test-results.md`
- Per-story visual fidelity: sheet mới ở `evening_check_in_sheet.dart` là bề mặt
  Flutter dựng được trong widget test → chụp `RepaintBoundary` trong chính test
  của phase, đối chiếu bản thiết kế, và ghi `Design-Screen` do người cài đặt xác
  định sau khi dựng (Tech Lead không gán trước)
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/phase_status/ test/features/journal/ test/features/account/`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: tên test, số pass/fail, và đường dẫn ảnh chụp

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
