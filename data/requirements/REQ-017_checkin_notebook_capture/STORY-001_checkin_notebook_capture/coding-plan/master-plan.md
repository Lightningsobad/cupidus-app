# Master Coding Plan – Ghi điều mới biết về người ấy vào sổ tay ngay trên màn check-in 23h

## 1. Planning Metadata

- Story ID: STORY-001_checkin_notebook_capture
- Complexity: standard
- OQ Constraints Source: `../../req_master.md` `## User Decisions` (OQ-1, OQ-2, A-5
  đều đã giải quyết 2026-09-27; không OQ nào còn chặn)
- Requirement Configuration Guide impact: NOT_APPLICABLE — không env var, không
  secret, không tích hợp third-party; thay đổi cấu hình duy nhất là một dòng asset
  dir trong `mobile/pubspec.yaml`, thuộc P2.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (module `features/context_notebook`)
- Contract-first phase required: NO — cùng một specialist viết cả lược đồ/cột mới và
  toàn bộ phía tiêu thụ trong story, tuần tự, trong một lane.
- Parallel execution possible: NO — story một lane (`mobile-dev`), bốn phase chạy tuần tự.
- Critical path: P1 → P3 và P1 → P4; P2 → P3 và P2 → P4.
- Parallelism notes: P1 và P2 độc lập về nội dung (persistence vs gói nội dung) nhưng
  vẫn tuần tự vì chỉ có một lane thực thi.

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| RS-1 Notebook local persistence write path | P1 |
| RS-2 Check-in save flow separation (BR-10) | P1, P2, P3 |
| RS-3 Per-check-in idempotency (AC-8/BR-12) | P1, P3 |
| RS-4 Content ingestion gate (AC-14/R-15c) | P2 |
| RS-5 Origin label degrade (AC-9/BR-6) | P1, P4 |
| RS-6 Notebook consumer non-regression (BR-11, AC-10/AC-13) | P1, P4 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source runtime
    registry `mobile-app.testCommand` = `flutter test`

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | None | NO | DONE |
| P3 | Mobile Developer | Mobile | P1, P2 | NO | DONE |
| P4 | Mobile Developer | Mobile | P1, P2 | NO | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-notebook-origin-persistence.md` |
| P2 | `phase-P2-checkin-capture-content-pack.md` |
| P3 | `phase-P3-checkin-capture-block.md` |
| P4 | `phase-P4-notebook-origin-label.md` |

Artifact hygiene:

- Mỗi phase id trên bảng ứng với đúng một tệp `phase-Px-*.md`.
- Phase implementation mobile phải vừa một specialist lifecycle (khoảng sáu tệp
  source/test) hoặc phải tách.
- Không có phase verification/testing đuôi; mỗi phase tự chạy test mục tiêu của nó.
- Không phase nào bị tách chỉ vì hai phase sẽ ghi cùng một tệp.
- Test scope của phase implementation không chứa e2e backend, Playwright/browser e2e,
  mobile e2e, vòng đời emulator/simulator, trace, hay startup smoke.

## 6. Notes

- Không có phase điểm vào riêng: story không thêm route hay điểm vào nào. P3 gắn khối
  hỏi vào màn check-in sẵn có (chỉ tới được từ nhắc 23h) và P4 gắn nhãn xuất xứ vào
  màn Sổ tay sẵn có (vào qua nhóm KHO / tab Sổ tay). Cả hai bề mặt đã phát hiện được
  từ trước story này.
- P1 nâng `schemaVersion`: đọc giá trị thật trên nhánh tích hợp rồi cộng một, và sửa
  trong cùng lần chạy mọi assertion đang chốt số cũ. Bỏ sót sẽ khoá build gate của P3/P4.
