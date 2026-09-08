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

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Mất dữ liệu gốc khi đăng xuất | P1 |
| R-1b — trôi schema sang đo hành vi người kia | P1 |
| Migration v2→v3 trên máy đã cài | P1 |
| SC-1' — danh sách thứ hai | P1 |
| AC-15 mất dữ liệu âm thầm khi lùi trạng thái | P2, P6 |
| SC-4/SC-5 — đúng một hành động chính, không ngõ cụt | P2, P4, P6 |
| Vỡ hợp đồng cho 11 story sau | P2, P7 |
| R-7/BR-8 — AI hoặc API nội dung ở runtime | P3 |
| R-15a/R-15b — id bền, N là dữ liệu | P3 |
| Điểm vào không tới được | P4 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (implementation
    phases), command/source runtime registry `mobile-app.testCommand`
    (`flutter test`) và `buildCommand` (`flutter build apk --debug`).

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | DONE |
| P3 | Mobile Developer | Mobile | P2 | NO | DONE |
| P4 | Mobile Developer | Mobile | P2 | NO | COMPLETE |
| P7 | Mobile Developer | Mobile | P4 | NO | DONE |
| P5 | Mobile Developer | Mobile | P3, P4, P7 | NO | COMPLETE |
| P6 | Mobile Developer | Mobile | P4, P7 | NO | NOT_STARTED |

Số hiệu phase là append-only, nên P7 lớn hơn P5/P6 về số nhưng chạy **trước**
chúng. Thứ tự thực thi đọc ở cột `Depends On`, không đọc theo số hiệu.

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
