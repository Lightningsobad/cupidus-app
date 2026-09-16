# Master Coding Plan – STORY-010 Bảng tra ăn khớp

## 1. Planning Metadata

- Story ID: STORY-010_compatibility_lookup
- Complexity: complex
- OQ Constraints Source: `../requirements/requirements.md` → `## Open Question Impact`
  (OQ-3 ĐÃ ĐÓNG 2026-09-06 / D-15; không mục nào của story còn bị chặn)
- Requirement Configuration Guide impact: NOT_APPLICABLE — story không thêm env
  var, secret, hay tích hợp bên thứ ba nào; AC-28 cấm đúng điều đó.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (P1 cho họ gói `req016.compat_*`,
  P2 cho bảng `relationship_labels`)
- Contract-first phase required: YES
  <!-- Không phải vì cross-lane: story chỉ có một lane. Vì hai lý do khác mà
  §2 của template công nhận — (a) gói `req016.compat_*` có consumer NGOÀI repo
  (CMS cấp nội dung tương lai, D-15/R-15), và (b) P5/P6 chạy SONG SONG với
  P3/P4 trên cùng schema đó. Nếu schema và cổng nhập không đứng trước, hai
  nhánh song song sẽ soạn 400 ô theo hai hình dạng khác nhau. -->
- Parallel execution possible: YES
- Critical path: P1 → P3 → P4
- Parallelism notes: P1 ∥ P2 (không phụ thuộc nhau). Sau P1, nhánh nội dung
  (P5 ∥ P6, chỉ ghi file JSON asset) chạy song song hoàn toàn với nhánh code
  (P3 → P4, chỉ ghi `lib/` + `test/`). Hai nhánh không chạm file của nhau.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| Họ gói `req016.compat_*` (schema + id ô bền) | Mobile Developer | P1 | P3, P4, P5, P6, và CMS ngoài repo | `../architecture/contract-summary.md` section 2-3 |
| `relationship_labels` (bảng nhãn tự khai) | Mobile Developer | P2 | P4 | `../architecture/contract-summary.md` section 4 |
| `openCompatibilityLookup` + `CompatibilityEntry` | Mobile Developer | P4 | STORY-008 (cửa vào màn (9), ngoài story này) | `../architecture/contract-summary.md` section 1 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Trượt thành thang đo (DẢI hoá số) | P1 (luật cấm JSON number) + P3 (widget test khối DẢI) |
| Thiếu ô / nội dung dự phòng chung chung | P1 (luật phủ `n²`) + P5, P6 (bộ seed thật) |
| Ô chỉ toàn lời khen | P1 (trường `friction` bắt buộc) + P5, P6 |
| Rò cửa vào (khoá vị trí vỡ) | P4 |
| Kết quả rò vào sổ tay | P2 (cột cấm) + P4 (test phân giải import) |
| Đối xứng thị giác "hợp"/"va" vỡ ở lần sửa sau | P3 |
| Bump `schemaVersion` làm đỏ test story khác | P2 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `mobile-app.testCommand` (`flutter test`) và
    `mobile-app.buildCommand` (`flutter build apk --debug`). SDK không nằm trên
    PATH máy này — giải qua `FLUTTER_SDK_PATH` theo `sdk.resolutionOrder` của
    registry.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | YES (∥ P2) | COMPLETE |
| P2 | Mobile Developer | Mobile | None | YES (∥ P1) | COMPLETE |
| P3 | Mobile Developer | Mobile | P1 | YES (∥ P5, P6) | NOT_STARTED |
| P4 | Mobile Developer | Mobile | P1, P2, P3 | YES (∥ P5, P6) | NOT_STARTED |
| P5 | Mobile Developer | Mobile | P1 | YES (∥ P3, P4, P6) | NOT_STARTED |
| P6 | Mobile Developer | Mobile | P1 | YES (∥ P3, P4, P5) | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-content-schema-and-ingest-gate.md` |
| P2 | `phase-P2-relationship-labels-store.md` |
| P3 | `phase-P3-result-blocks-and-card-push.md` |
| P4 | `phase-P4-entry-point-screen-and-label-capture.md` |
| P5 | `phase-P5-zodiac-seed-content.md` |
| P6 | `phase-P6-mbti-seed-content.md` |

Artifact hygiene:

- Mỗi phase id ánh xạ tới đúng một file `phase-Px-*.md`; không có file trùng id.
- Phase mobile phải vừa một vòng đời chuyên gia (roughly six source/test files)
  hoặc phải tách.
- Không phase nào bị tách chỉ vì hai phase sẽ ghi cùng một file.
- Không có phase kiểm thử/verification đuôi; mỗi phase tự chạy test của nó.
- Test scope của phase không chứa e2e, Playwright, trace, scenario rerun,
  script gate ở gốc repo, hay runtime startup smoke.

## 6. Notes

- **Vì sao P5/P6 tách khỏi P1 dù ghi cùng file JSON:** lý do tách là **khối
  lượng nội dung** (400 ô văn xuôi tiếng Việt do người soạn), không phải ranh
  giới file. P1 ship ba gói **hoàn chỉnh nhưng trục nhỏ**; P5/P6 mở trục lên 12
  và 16 rồi soạn đủ ô.
- **Vì sao bản dựng không bao giờ đỏ giữa các phase:** cổng nhập kiểm độ phủ
  `n²` với `n` suy **từ chính dữ liệu** (AC-36), nên một gói trục-2 đủ 4 ô là
  hợp lệ y như gói trục-12 đủ 144 ô. Đây chính là tính chất cho phép giao nội
  dung theo từng đợt. Nếu ai đó viết `12`/`16` vào `lib/`, tính chất này mất và
  mọi commit trung gian hỏng.
- Bộ seed chỉ được đưa vào bản dựng người dùng thật sau kiểm duyệt lớp 2 do
  user thực hiện (AC-35/D-15). P5/P6 ghi vết duyệt; chúng không tự phê duyệt.
