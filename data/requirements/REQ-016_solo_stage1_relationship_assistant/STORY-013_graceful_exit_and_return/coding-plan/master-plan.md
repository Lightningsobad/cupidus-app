# Master Coding Plan – STORY-013 Lối ra (J11) và lối quay lại (J13)

## 1. Planning Metadata

- Story ID: STORY-013_graceful_exit_and_return
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — story không thêm biến
  môi trường, secret, cổng, hay dịch vụ runtime nào; toàn bộ trạng thái nằm
  trong Drift và `SharedPreferences` trên thiết bị.

## 2. Planning Goal

- Shared contract owner: `mobile/lib/features/chapter_closure/` (P1 + P3)
- Contract-first phase required: NO — một lane duy nhất (Mobile Developer) hiện
  thực cả hợp đồng lẫn mọi consumer trong story, tuần tự. `contract-summary.md`
  phục vụ các story REQ-016 **sau** story này, không phải một lane song song.
- Parallel execution possible: NO
- Critical path: P1 → P2 → P3 → P5 (P4 và P6 nhánh ra sau P2/P3)
- Parallelism notes: mọi phase cùng một chủ sở hữu và cùng đụng
  `core/di/service_locator.dart` hoặc `cupid_database.dart`; chạy tuần tự.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| Sổ ghi đóng ngăn + `ChapterClosureGate` | Mobile Developer | P1 | P2, P5 (trong story); STORY-005/007/008/009/010/011/012 (ngoài story) | `../architecture/contract-summary.md` §1-3 |
| `Stage1WipeRegistry` | Mobile Developer | P3 | P6 (trong story); mọi story REQ-016 tạo bảng/thư mục/khoá mới (ngoài story) | `../architecture/contract-summary.md` §4 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Phân loại gắn người sai → mất tài sản | P2 |
| Rò rỉ vật liệu đã đóng ra luồng thường ngày | P2 |
| Phân trang sai do lọc sau khi đọc | P2 |
| Dư lượng sau xoá sạch | P3 |
| Cột cấm lọt vào schema | P1 |
| Màn J13 trở thành cổng chặn | P6 |
| Migration phá dữ liệu người dùng | P1 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `data/devops/system/runtime-command-registry.json`
    (`buildCommand: flutter build apk --debug`, `testCommand: flutter test`)

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | COMPLETE |
| P2 | Mobile Developer | Mobile | P1 | NO | COMPLETE |
| P3 | Mobile Developer | Mobile | P2 | NO | COMPLETE |
| P4 | Mobile Developer | Mobile | P2 | NO | COMPLETE |
| P5 | Mobile Developer | Mobile | P3, P4 | NO | COMPLETE |
| P6 | Mobile Developer | Mobile | P3 | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-closure-ledger-schema.md` |
| P2 | `phase-P2-closure-service-and-read-exclusion.md` |
| P3 | `phase-P3-stage1-wipe-and-purge.md` |
| P4 | `phase-P4-close-chapter-entry-ui.md` |
| P5 | `phase-P5-closed-archive-pane.md` |
| P6 | `phase-P6-return-gate-and-screen.md` |

Artifact hygiene:

- Mỗi phase id ứng đúng một file `phase-Px-*.md`; không có file trùng.
- Phase hiện thực nằm trong một vòng đời specialist (khoảng sáu file
  nguồn/test); phase nào vượt phải tách.
- Không có phase hợp đồng độc lập: cùng một specialist làm hợp đồng và mọi
  consumer trong story, tuần tự.
- Không có phase kiểm thử/verification đuôi; mỗi phase tự chạy test và
  build/type-check của nó.

## 6. Notes

- Thứ tự P1 trước mọi thứ là bắt buộc về mặt runtime, không chỉ về tổ chức: mọi
  truy vấn anti-join tham chiếu `chapter_closure_items`, nên một phase đọc chạy
  trước migration sẽ ném "no such table" trên đường đọc nóng nhất của app.
- P4/P5/P6 là ba bề mặt UI tách rời của cùng một story; mỗi phase tự chịu cổng
  visual fidelity của mình, không phase nào gánh hộ phase khác.
