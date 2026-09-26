# Phase P3 – Gói dữ liệu dịp và loader nội dung

## 1. Objective

Ship gợi ý theo dịp ở AC-3 dưới dạng **gói dữ liệu có schema và id bền**, đọc
qua một loader tổng quát, với hành vi đúng ở mọi N và không một lời gọi mạng nào.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-occasion-content-package.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/content/content_package.dart`
  - `mobile/lib/features/activity_cards/domain/occasion_suggestion_service.dart`
  - `mobile/assets/data/req016/occasions.v1.json`
  - `mobile/pubspec.yaml`
  - `mobile/test/core/content/content_package_test.dart`
  - `mobile/test/features/activity_cards/occasion_suggestion_service_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `ContentPackage<T>` (`id`, `version`, `schemaId`, `items[]`) — hình dạng mà
    kho preset của STORY-002+ dùng lại
- Shared Interfaces Consumed:
  - `createCard` từ P2
- Risk Surfaces:
  - R-7/BR-8 — AI hoặc API nội dung ở runtime
  - R-15a/R-15b — id bền, N là dữ liệu
- Source Of Truth:
  - authoritative artifact: `req_master.md` mục 15 (R-15a/b/c)
  - consumer contract: P5, và kho preset của STORY-002/004/005/011
- Primary Inputs Summary:
  - requirements: AC-3, AC-5, BR-8
  - architecture: `../architecture/solution.md` §4 Boundaries And Ownership
  - upstream phase outputs: P2 repository
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — nội dung-là-dữ-liệu cho gợi ý dịp.
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` Nhóm A (AC-3, AC-5)
- `../architecture/contract-summary.md` §2
- `data/requirements/REQ-016_solo_stage1_relationship_assistant/req_master.md` mục 15

## 3. Tasks

- `ContentPackage<T>`: đọc asset JSON, kiểm tra `id`, `version`, `schemaId`, và
  danh sách `items` có `id` bền; lỗi schema là lỗi rõ ràng lúc load, không nuốt.
- `occasions.v1.json`: mỗi mục có `id` bền, ngày dịp (lịch Việt/dương theo dữ
  liệu, không tính trong code), và 1..n gợi ý hoạt động kèm `title` +
  `activity_type`.
- `OccasionSuggestionService`: hàm thuần trên (ngày thiết bị, nội dung gói) trả
  1–2 gợi ý cho dịp gần nhất; chọn gợi ý gọi `createCard` với
  `origin = occasion_suggestion`.
- Đăng ký thư mục asset trong `pubspec.yaml`.
- Cấm mọi hằng số đếm: không `if (items.length == 10)`, không chỉ báo tiến độ
  dựa trên tổng số cố định, không giả định gói không rỗng ngoài kiểm tra rõ ràng.

## 4. Acceptance Criteria

- Với cùng ngày thiết bị và cùng gói, service luôn trả cùng kết quả (tất định).
- Gói N=1 và gói N=50 đều cho hành vi đúng, kể cả trường hợp không có dịp nào
  phía trước trong gói.
- Chọn một gợi ý tạo ngay một thẻ `idea` mà không hỏi thêm trường nào (AC-3).
- Không chuỗi nội dung dịp nào tồn tại trong file Dart.

## 5. Planned Outputs

- Code: loader gói nội dung + service gợi ý dịp.
- Contracts: asset `occasions.v1.json` theo schema ở §3.
- Notes: bằng chứng test ghi vào `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng nội dung/domain
- Required levels:
  - unit: loader hợp lệ/không hợp lệ, chọn dịp gần nhất, tính tất định
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
- Required checks:
  - Chạy luồng gợi ý với HTTP client giả **ném lỗi nếu bị gọi** → vẫn ra 1–2 gợi
    ý (chứng minh không có lời gọi mạng, R-7/BR-8).
  - Chạy cùng bộ test với gói N=1 và N=50 (R-15b).
  - Test khẳng định `id` của mục là chuỗi ổn định, không phải chỉ số mảng.
- Minimum gates by risk surface: hai risk surface ở §1B đều có gate ở trên.
- Evidence format: output `flutter test` dán vào `coding-plan/test-results.md`.
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn hình.
- Verification strategy:
  - Targeted tests: `flutter test test/core/content/ test/features/activity_cards/`
  - Build/type-check: `flutter analyze lib test`
  - Required assertion evidence: tên test + kết quả pass cho từng gate trên.

## 7. Status

- Status: DONE
- Last updated: 2026-09-07
