# Phase P2 – Gói nội dung hỏi-tại-chỗ của check-in và cổng nhập của nó

## 1. Objective

Mọi câu chữ mới của story (câu hỏi, nhãn "Tuỳ chọn", nhãn hai loại, dòng nhắc chọn
loại, câu lỗi/thử lại, hai dạng nhãn xuất xứ) là item dữ liệu có id bền trong một gói
nội dung REQ-017, và gói đó đi qua **đúng** cổng nhập của STORY-004.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-checkin-capture-content-pack.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/assets/data/req017/checkin_capture.v1.json`
  - `mobile/lib/features/context_notebook/domain/checkin_capture_content.dart` (mới)
  - `mobile/lib/features/context_notebook/domain/context_content_gate.dart`
  - `mobile/lib/features/context_notebook/data/checkin_capture_content_repository.dart` (mới)
  - `mobile/pubspec.yaml`
  - `mobile/test/features/context_notebook/context_content_gate_test.dart` và một test
    parser cho gói mới
- Impacted Runtime Service/App:
  - Name: `mobile`
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - gói `req017.checkin_capture.v1` + kiểu copy đã phân giải mà P3/P4 nhận vào
- Shared Interfaces Consumed:
  - `validateContextPacks` (`mobile/lib/features/context_notebook/domain/context_content_gate.dart:48`),
    `invariantHitsIn` / `notebookBoundaryHitsIn` (`mobile/lib/core/content/invariant_terms.dart`),
    `ContentPackage` (`mobile/lib/core/content/content_package.dart`)
- Risk Surfaces:
  - RS-4 Content ingestion gate (AC-14/R-15c)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/solution.md` §1 KD-3
  - consumer contract: `validateContextPacks` là cổng nhập duy nhất; luật chỉ sống
    trong Dart, câu chữ chỉ sống trong asset
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-3, AC-14, AC-15, BR-1, BR-5
  - architecture: `../architecture/solution.md` §1 KD-3, §4
  - UX constraints: `../ux/uiux-spec.md` Phần D (danh sách chính xác các mục copy cần id bền)
  - upstream phase outputs: không có
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cluster — gói nội dung mới và cổng nhập của nó
  - Source/Test File Count: 4 source + pubspec + 2 tệp test
  - Split Required: NO

## 2. Required Reads

- `../requirements/requirements.md` (AC-3, AC-14, AC-15, BR-1, BR-5)
- `../architecture/solution.md` §1 KD-3, §4
- `../ux/uiux-spec.md` Phần D

## 3. Tasks

- Tạo `mobile/assets/data/req017/checkin_capture.v1.json` với `schema_id`
  `req017.checkin_capture.v1`, `locale: vi`, và một item id bền cho mỗi mục copy mà
  UX Phần D liệt kê: câu hỏi khối, nhãn "Tuỳ chọn", nhãn loại `Sở thích`, nhãn loại
  `Sự kiện`, dòng nhắc chọn loại, câu lỗi ghi sổ tay, nhãn thử lại, nhãn xuất xứ có
  tên thẻ (mang tham số `{card}`), nhãn xuất xứ suy biến.
- Viết parser cho gói: mỗi item có `id` + `text`, và chỉ item nhãn-có-tên-thẻ được
  khai báo tham số `{card}`. Parser từ chối item khai báo tham số không hỗ trợ và
  từ chối id trùng.
- Mở rộng `validateContextPacks` bằng một tham số gói thứ ba cho gói REQ-017, chạy
  `invariantHitsIn` + `notebookBoundaryHitsIn` trên `text` của từng item. Không thêm
  luật mới vào asset.
- Thêm `- assets/data/req017/` vào `flutter.assets` của `mobile/pubspec.yaml`.
- Thêm repository nạp gói và phân giải nhãn xuất xứ bằng cách thay `{card}` — tầng UI
  không bao giờ ghép chuỗi tên thẻ bằng tay.
- Mở rộng test cổng nhập để quét cả `assets/data/req017/` từ đĩa.

## 4. Acceptance Criteria

- Không câu chữ mới nào của story nằm trong ARB/l10n hay hằng Dart (AC-14).
- Gói chứa từ ngữ đánh giá/chấm điểm người kia làm test cổng nhập đỏ (BR-1, R-1f).
- Item nhãn xuất xứ có tên thẻ phân giải `{card}` đúng; item suy biến không có tham số.
- Gói không hợp lệ (thiếu id, id trùng, tham số lạ) làm test đỏ thay vì im lặng bỏ qua.
- Không thêm chức năng xuất/chia sẻ nào vào gói hay repository (AC-15).

## 5. Planned Outputs

- Code directories or files: như `Write Scope`
- Contracts or schemas: `req017.checkin_capture.v1` và các id item của nó
- Notes or evidence: `coding-plan/test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter `mobile`, tầng nội dung
- Required levels:
  - unit: parser gói (id trùng, tham số lạ, thiếu trường), phân giải `{card}`
  - integration: cổng nhập quét gói thật từ đĩa
  - mobile build/type-check/static-analysis: `flutter analyze lib test` cho tệp đã sửa
    (so delta, baseline repo khác 0)
- Required checks: không chuỗi câu chữ mới nào xuất hiện trong `lib/` hay ARB
- Required regression or contract coverage: `context_content_gate_test.dart` phải vẫn
  xanh cho hai gói REQ-016 cũ
- Minimum gates by risk surface: RS-4 theo `../architecture/solution.md` §4
- Evidence format: lệnh test + kết quả trong `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng hay đổi màn nào
- Verification strategy:
  - Targeted tests/regression/contract checks: chỉ các suite `context_notebook`
  - Required assertion evidence: một gói cố tình vi phạm sinh ra `ContextViolation`
    có `packageId` của gói REQ-017

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-28
