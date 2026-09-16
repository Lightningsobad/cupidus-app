# Phase P5 – Extension WidgetKit iOS + hướng dẫn cấu hình bản dựng

## 1. Objective

Dựng target WidgetKit đọc **đúng** tập khoá P4 đã chốt, qua App Group chung, và
ghi lại toàn bộ cấu hình bản dựng mới (App Group, entitlements, target) để lần
checkout kế tiếp không phải đoán.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-widget-ios-extension.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P4
- Parallelizable: NO (tiêu thụ tập khoá P4 vừa chốt)
- Write Scope:
  - `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.swift`
  - `mobile/ios/CupidPhaseWidget/Info.plist`
  - `mobile/ios/CupidPhaseWidget/CupidPhaseWidget.entitlements`
  - `mobile/ios/Runner/Runner.entitlements`
  - `mobile/ios/Runner.xcodeproj/project.pbxproj`
  - `mobile/test/features/phase_status/native_copy_scan_test.dart` (mở rộng sang `ios/`)
  - `../../deployment/configuration-guide.md` (TẠO MỚI)
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
- Shared Interfaces Produced:
  - Không có hợp đồng mới; P5 là **người tiêu thụ** hợp đồng P4
- Shared Interfaces Consumed:
  - Tập khoá native ở `../architecture/contract-summary.md` §2
- Risk Surfaces:
  - `IOS-WIDGET-TARGET`
  - `HARDCODED-COPY`
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §1, §2, §5
  - consumer contract: không phase nào tiêu thụ P5
- Primary Inputs Summary:
  - requirements: AC-30..AC-33, AC-36, AC-37, BR-11, BR-15
  - architecture: `../architecture/contract-summary.md` §1 (App Group
    `group.com.snapsofts.cupid`, khớp khoá theo văn bản), §5 (khoá chỉ thêm, không
    đổi nghĩa)
  - upstream phase outputs: P4
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: YES — mục App Group, entitlements hai phía, target
    extension, bundle id extension, và cách thêm lại sau khi regenerate iOS
- Phase Sizing:
  - Behavior Slice: một bề mặt widget, một nền tảng, cộng tài liệu cấu hình
  - Source/Test File Count: 5 source/config + 1 test mở rộng + 1 tài liệu
  - Split Required: NO
  - Split Rationale: entitlements và target không có nghĩa nếu thiếu Swift view;
    tách sẽ ship một target rỗng không build được

## 2. Required Reads

- `../architecture/contract-summary.md` §1, §2, §5
- `mobile/lib/features/phase_status/data/home_widget_bridge.dart` (P4)
- `mobile/ios/Runner/Info.plist` và cấu hình flavor iOS hiện có
- `data/bugs/BUG-20260907-002/fix-evidence.md` — build configuration per-flavor
  iOS vừa được thêm; target mới phải khớp cùng bộ configuration

## 3. Tasks

- Tạo target WidgetKit tên `CupidPhaseWidget`, kind chuỗi `CupidPhaseWidget`
  đúng như `contract-summary.md` §2.
- Bật App Group `group.com.snapsofts.cupid` cho **cả hai** target Runner và
  extension. Thiếu một bên là widget trắng vĩnh viễn, không lỗi (`IOS-WIDGET-TARGET`).
- Swift đọc `UserDefaults(suiteName:)` theo **đúng chuỗi khoá** §2. Khớp khoá là
  khớp văn bản, không có lớp sinh mã nào bảo vệ; gõ sai = im lặng.
- Không có payload hoặc thiếu khoá → `Text("")`/khung không chữ. **Không**
  placeholder có chữ, kể cả trong `WidgetPreview`/`placeholder(in:)` của
  WidgetKit — đó là chỗ chuỗi cứng hay lọt vào nhất.
- `widgetURL` = `cupidapp://card/<card_id>`, fallback `cupidapp://home`.
- Extension phải có **mọi** build configuration mà Runner có (Debug/Release/
  Profile × local/prod). Thiếu một configuration là bản dựng flavor đó gãy.
- Mở rộng `native_copy_scan_test.dart` để quét cả `mobile/ios/**` (`.swift`,
  `.plist` phần chuỗi hiển thị).
- Viết `../../deployment/configuration-guide.md`: App Group id, hai file
  entitlements, tên target, bundle id extension, quyền `POST_NOTIFICATIONS`
  Android 13+ (do P6 thêm), và quy trình khôi phục sau `flutter create`/
  regenerate iOS.

## 4. Acceptance Criteria

- Widget iOS hiện cùng nội dung với Android cho cùng trạng thái, vì cả hai đọc
  cùng tập khoá (AC-30).
- Không chuỗi hiển thị nào trong `.swift`/`.plist` (AC-37/BR-15), gồm cả nhánh
  `placeholder(in:)`.
- Không App Group hoặc chưa có payload → khung không chữ, không crash (AC-36).
- Widget không lộ nội dung riêng tư và không hiện đại lượng đếm (AC-31/AC-32).
- `configuration-guide.md` đủ để dựng lại target từ một checkout sạch.

## 5. Planned Outputs

- Code directories or files: `mobile/ios/CupidPhaseWidget/`, `mobile/ios/Runner/`
- Notes or evidence: `coding-plan/test-results.md`,
  `../../deployment/configuration-guide.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: quét tĩnh mã native + biên dịch iOS
- Required levels:
  - mobile build/type-check/static-analysis:
    `flutter build ios --debug --no-codesign --flavor local`, chạy **không pipe**
  - unit: `native_copy_scan_test.dart` mở rộng
- Required checks:
  - test khẳng định mọi chuỗi khoá trong `.swift` có mặt trong danh sách khoá mà
    `home_widget_bridge.dart` ghi ra — bắt lỗi gõ sai khoá (`IOS-WIDGET-TARGET`)
  - quét `.swift` tìm ký tự có dấu tiếng Việt: có là **đỏ**
  - khẳng định target extension có đủ các build configuration của Runner
- Minimum gates by risk surface: `IOS-WIDGET-TARGET`, `HARDCODED-COPY`
- Required regression or contract coverage: `flutter build apk --debug --flavor
  local` (P4) vẫn xanh sau khi sửa `project.pbxproj`
- Evidence format: dòng kết `flutter build ios` nguyên văn + output `flutter test`
- Per-story visual fidelity:
  `NOT_APPLICABLE — bề mặt widget hệ điều hành, không phải route Flutter`
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/phase_status/`
  - Build/type-check/lint command when required:
    `flutter build ios --debug --no-codesign --flavor local` (không pipe)
  - Required assertion evidence: kết quả build iOS + tên test quét khoá
- Nếu toolchain iOS không dựng được trong môi trường này, dừng và báo blocker
  `IOS_TOOLCHAIN_UNAVAILABLE` với văn bản lỗi nguyên văn; **không** đánh dấu
  phase DONE bằng suy luận tĩnh.

## 7. Status

- Status: DONE
- Last updated: 2026-09-17
- Evidence: `coding-plan/test-results.md` §P5 — 14 test mới trong
  `native_copy_scan_test.dart` (27 test trong file, 173 xanh + 4 skip trên
  `test/features/phase_status/`), `flutter build ios --debug --no-codesign
  --flavor local` = `✓ Built build/ios/iphoneos/Runner.app` với
  `Runner.app/PlugIns/CupidPhaseWidget.appex` đã nhúng, hồi quy
  `flutter build apk --debug --flavor local` = `✓ Built app-local-debug.apk`,
  `flutter analyze lib test` = 224 issue / 0 error (đúng mốc nền).
- Đính chính AC: §4 trích AC-30/AC-31/AC-32 là sai — đó là Nhóm H (thông báo),
  không phải widget. AC-33 và AC-36 thì đúng. AC đúng cho pha này là
  AC-9..AC-13 (nội dung widget, riêng tư trên màn khoá, widget là bề mặt bổ
  trợ), cộng AC-33, AC-35, AC-36, AC-37/BR-15, BR-11. Triển khai và test theo
  AC đúng.
- Quyết định lộ ra ngoài phase: nâng `IPHONEOS_DEPLOYMENT_TARGET` 13.0 → 14.0
  (cả 9 configuration). Bắt buộc, nhưng cắt iOS 13 khỏi tập thiết bị cài được —
  Scrum Master/Reviewer cần biết. Chi tiết ở test-results.md §P5.
