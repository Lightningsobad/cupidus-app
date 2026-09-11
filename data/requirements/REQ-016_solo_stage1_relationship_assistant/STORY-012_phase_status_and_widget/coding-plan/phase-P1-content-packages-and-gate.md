# Phase P1 – Ba gói nội dung preset + cổng nhập luật bất biến

## 1. Objective

Ship nội dung pha, nội dung nhỏ giọt, và nội dung nhắc dưới dạng **gói dữ liệu
có lược đồ và id bền**, cùng một cổng nhập làm **đỏ bản dựng** khi một mục vi
phạm luật bất biến. Mọi phase sau đọc chữ từ đây, không tự viết chữ.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-content-packages-and-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/phase_status/domain/phase_content.dart`
  - `mobile/lib/features/phase_status/domain/phase_content_gate.dart`
  - `mobile/lib/features/phase_status/data/phase_content_repository.dart`
  - `mobile/assets/data/req016/phase_content.v1.json`
  - `mobile/assets/data/req016/drip.v1.json`
  - `mobile/assets/data/req016/nudges.v1.json`
  - `mobile/test/features/phase_status/phase_content_gate_test.dart`
  - `mobile/test/features/phase_status/phase_content_repository_test.dart`
- Impacted Runtime Service/App:
  - Name: `mobile-app`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - Ba lược đồ gói nội dung (`../architecture/contract-summary.md` §4)
- Shared Interfaces Consumed:
  - `mobile/lib/core/content/content_package.dart`
  - `mobile/lib/core/content/invariant_terms.dart`
- Risk Surfaces:
  - `CONTENT-GATE`
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §4
  - consumer contract: P2, P3, P4, P6 đọc gói qua repository của phase này
- Primary Inputs Summary:
  - requirements: AC-34, AC-37, AC-38, AC-39, BR-13, BR-15, BR-16, BR-17
  - architecture: `../architecture/contract-summary.md` §4
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: nội dung-là-dữ liệu + cổng nhập, một cụm hành vi
  - Source/Test File Count: 3 source + 3 asset + 2 test
  - Split Required: NO
  - Split Rationale: gói và cổng gác gói là một cụm; tách ra sẽ có một dispatch
    ship dữ liệu chưa ai kiểm và một dispatch kiểm dữ liệu đã ship

## 2. Required Reads

- `../requirements/` nhóm J (AC-37..AC-39) và BR-13..BR-17
- `../architecture/contract-summary.md` §4
- `mobile/lib/core/content/content_package.dart`
- `mobile/lib/core/content/invariant_terms.dart`
- `mobile/lib/features/gift_ideas/domain/gift_content_gate.dart` làm khuôn mẫu

## 3. Tasks

- Định nghĩa ba kiểu item cài `ContentItem`: `PhaseContentItem` (`phase_id`,
  `primary`, `secondary?`, `surface`), `DripItem` (`body`), `NudgeItem` (`slot`,
  `title?`, `body`). Parser dùng `requireContentString` /
  `optionalContentString` sẵn có, không tự viết validator chuỗi.
- Viết `phase_content_gate.dart`: với mỗi chuỗi hiển thị của mỗi item, gọi
  `invariantHitsIn` và trả về danh sách vi phạm. **Import** danh sách từ
  `core/content/invariant_terms.dart`; không khai lại từ nào.
- Viết `phase_content_repository.dart`: nạp ba asset qua `ContentPackageLoader`
  với `expectedSchemaId` đúng như `contract-summary.md` §4, và đọc khoá gốc
  `thresholds` của `nudges.v1.json` thành `List<int>` đã sắp tăng dần.
- Soạn nội dung seed cho ba gói. Nội dung nói về **tài sản và việc của chính
  người dùng**; bài kiểm tra BR-4: bỏ hẳn sự tồn tại của người kia ra khỏi câu,
  câu đó còn đứng được không. Dùng placeholder `{n}` cho chỗ thay số.
- Đăng ký gì thêm trong `pubspec.yaml`: **không cần** — `assets/data/req016/`
  đã được khai báo sẵn.

## 4. Acceptance Criteria

- Ba asset nạp được, mỗi item có `id` bền và duy nhất trong gói (AC-37).
- Gate từ chối một item chứa `%`, từ tâng bốc, từ streak/chuỗi ngày, từ chỉ báo
  hành vi người kia, hoặc từ điểm số/xếp hạng, và test vì thế **đỏ** (AC-39).
- Không mã nào đọc `package.length` để suy ra hành vi (AC-38/BR-16).
- Gói nhỏ giọt seed có ≥ 0 mục; không AC nào của story suy từ số mục đó.
- `schema_id` sai → `ContentPackageFormatException`, không suy biến thành rỗng.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/phase_status/{domain,data}/`
- Contracts or schemas: ba gói asset theo `contract-summary.md` §4
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Dart thuần, không widget, không thiết bị
- Required levels:
  - unit: parser ba gói, `expectedSchemaId` sai, item id trùng, gate vi phạm
  - mobile build/type-check/static-analysis: `flutter analyze lib test`, đánh
    giá theo số *error* (baseline có warning tồn dư, 0 error)
- Required checks:
  - test nạp **asset thật** trong repo, không chỉ fixture trong bộ nhớ
  - fixture vi phạm cho **từng** `InvariantRule`, khẳng định gate bắt được
  - grep khẳng định module này không khai lại từ nào trong
    `invariantDeniedTerms`
- Minimum gates by risk surface: `CONTENT-GATE`
- Required regression or contract coverage: `mobile/test/core/content/content_package_test.dart` vẫn xanh
- Evidence format: `flutter test` output dán vào `coding-plan/test-results.md`
- Per-story visual fidelity: `NOT_APPLICABLE — phase không dựng bề mặt UI nào`
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/phase_status/ test/core/content/`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: tên test + số test pass/fail nguyên văn

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
