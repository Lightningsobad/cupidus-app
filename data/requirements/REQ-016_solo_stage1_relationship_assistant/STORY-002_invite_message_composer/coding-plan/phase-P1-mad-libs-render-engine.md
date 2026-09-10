# Phase P1 – Engine render tất định + bộ biến mad-libs

## 1. Objective

Giao lớp `domain/` thuần Dart của `invite_composer`: mô hình preset đã parse,
bộ 5 biến mad-libs rút từ `ActivityCard`, và hàm render tất định bỏ nguyên
clause khi thiếu biến. Không UI, không sqlite, không asset ở phase này.

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-mad-libs-render-engine.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: YES (song song với P3; hai phase không chạm file chung)
- Write Scope:
  - `mobile/lib/features/invite_composer/domain/invite_preset.dart`
  - `mobile/lib/features/invite_composer/domain/mad_libs.dart`
  - `mobile/lib/features/invite_composer/domain/invite_renderer.dart`
  - `mobile/test/features/invite_composer/invite_renderer_test.dart`
  - `mobile/test/features/invite_composer/mad_libs_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `InvitePreset` / `PresetClause` (parser `ContentItem`)
  - `MadLibsValues` + resolver từ `ActivityCard`
  - `renderInvite(InvitePreset, MadLibsValues) -> String`
- Shared Interfaces Consumed:
  - `core/content/ContentPackage` (`ContentItem`, `requireContentString`,
    `requireContentObjectList`, `requireContentStringList`) — dùng nguyên vẹn
  - `features/activity_cards/domain/ActivityCard`
- Risk Surfaces:
  - Tất định và không AI runtime
  - Luật bất biến lọt qua nội dung (phần cấu trúc: `targets`, `role`)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §3
  - consumer contract: P2 (cổng nhập), P5 (sheet)
- Primary Inputs Summary:
  - requirements: AC-6, AC-8, AC-9, AC-10, AC-20
  - architecture: `../architecture/solution.md` §4 Boundaries And Ownership, §6
  - OQ constraints: R-15a (câu chữ không nằm trong code)
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm hành vi — biến dữ liệu thẻ thành chuỗi lời mời.
  - Source/Test File Count: 5
  - Split Required: NO

## 2. Required Reads

- `../requirements/` (AC-6, AC-8, AC-9, AC-10, AC-20)
- `../architecture/contract-summary.md` §2, §3
- `../architecture/solution.md` §1 Key Discovery 4, §4, §6

## 3. Tasks

- Định nghĩa `PresetClause` (`text`, `requires`, `targets`, `role`) và
  `InvitePreset implements ContentItem` với parser `ContentItemParser` khớp
  đúng bảng trường ở `contract-summary.md` §3. Trường bắt buộc thiếu hoặc sai
  kiểu → `ContentPackageFormatException`, không giá trị mặc định im lặng.
- `targets` chỉ nhận `sender` | `neutral`. `recipient` không nằm trong enum, nên
  gói khai báo nó chết ngay ở parser chứ không bị lọc về sau.
- Định nghĩa bộ 5 biến mad-libs đóng — `activity`, `date`, `time`, `place`,
  `duration` — và resolver `MadLibsValues.fromCard(ActivityCard)`. Biến chỉ có
  mặt khi trường nguồn khác `null` và khác chuỗi rỗng sau `trim()`.
- Viết `renderInvite`: duyệt `clauses` theo đúng thứ tự khai báo, **bỏ nguyên
  clause** nếu bất kỳ tên trong `requires` vắng khỏi `MadLibsValues`, thay
  `{tên_biến}` trong clause còn sống, rồi nối bằng một dấu cách. Engine không
  viết hoa, không thêm/bớt dấu chấm, không sửa ngữ pháp.
- Không import `flutter/material.dart`, `dio`, `cupid_api`, `http`; không gọi
  `DateTime.now()`, `Random`, hay bất kỳ nguồn phi tất định nào trong `domain/`.

## 4. Acceptance Criteria

- Cùng preset + cùng thẻ → hai lần render ra chuỗi **bằng nhau** (AC-9).
- Thẻ thiếu `place` → câu chứa `{place}` biến mất hoàn toàn; chuỗi kết quả
  không chứa `{`, `}`, dấu ngoặc rỗng, hay khoảng trắng đôi (AC-6).
- Clause có `requires: []` luôn còn trong đầu ra với mọi tổ hợp trường thiếu —
  đây là cơ chế làm cửa từ chối bất tử (AC-10).
- Gói khai báo `targets: "recipient"` bị parser từ chối bằng exception (R-1d).

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/invite_composer/domain/`
- Contracts or schemas: mô hình Dart của lược đồ `req016.presets.v1`
- Notes or evidence: `../coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, lớp domain thuần Dart
- Required levels:
  - unit: parser preset, resolver mad-libs, `renderInvite`
  - mobile build/type-check/static-analysis: có
- Required checks:
  - render hai lần bằng nhau (tất định)
  - ma trận thiếu trường: đủ 5 biến, thiếu 1, thiếu 4, thiếu tất cả — mọi kết
    quả đều đọc được và không còn placeholder
  - clause `requires: []` sống sót mọi tổ hợp
  - parser từ chối `targets: "recipient"`, `role` lạ, `requires` chứa tên biến
    ngoài bộ 5
  - test khẳng định file trong `domain/` không import `dio`/`cupid_api`/`http`
- Minimum gates by risk surface:
  - Tất định và không AI runtime: unit test tất định + test cấm import mạng
  - Luật bất biến lọt qua nội dung: test từ chối `targets: "recipient"`
- Required regression or contract coverage: `mobile/test/core/content/content_package_test.dart`
  phải vẫn xanh — P1 không được sửa `core/content/`.
- Evidence format: đầu ra `flutter test` dán vào `../coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn UI nào.
- Verification strategy:
  - Targeted tests/regression/contract checks:
    `flutter test test/features/invite_composer/ test/core/content/`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: số test pass/fail của hai thư mục trên

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-10
