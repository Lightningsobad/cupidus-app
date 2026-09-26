# Master Coding Plan – STORY-006 "Trước giờ đi" checklist tất định

## 1. Planning Metadata

- Story ID: REQ-016 / STORY-006
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — không env var, không
  secret, không tích hợp bên thứ ba; asset ship trong binary.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (`../architecture/contract-summary.md`)
- Contract-first phase required: NO — cùng một specialist viết gói nội dung và
  mọi bên tiêu thụ trong story, tuần tự, cùng lane. Hợp đồng gộp vào P1.
- Parallel execution possible: NO — một lane duy nhất, P2 mount thứ P1 tạo ra.
- Critical path: P1 → P2
- Parallelism notes: hai phase tách nhau vì tổng ~13 file source/test vượt một
  vòng đời specialist, không phải vì ranh giới lane hay ranh giới hợp đồng.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| Gói nội dung `before_you_go.v1.json` | Mobile Developer | P1 | P2 (và CMS ngoài repo sau này) | `../architecture/contract-summary.md` §1-§3 |
| `BeforeYouGoPhase` (AC-24, STORY-012 đọc) | Mobile Developer | P1 | P2 | `../architecture/contract-summary.md` §4 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Cổng nhập nội dung (AC-31/BR-17) | P1 |
| Chuỗi cứng trong widget (AC-29/BR-15) | P1, và lại ở P2 sau khi widget tồn tại |
| Suy miền từ `location` free-text (AC-11) | P1 |
| Điều kiện hai vế của khối (AC-1/AC-2/AC-3) | P1 (luật), P2 (render) |
| Hồi quy layout chi tiết thẻ | P2 |
| Trạng thái pha cho STORY-012 (AC-24/BR-11) | P1 |
| Rò rỉ quyền riêng tư khi chia sẻ (AC-19/AC-20) | P2 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (không thay đổi khởi
    động app; kiểm chứng bằng `flutter test` + `flutter analyze` phạm vi hẹp),
    command/source `data/devops/system/runtime-command-registry.json` →
    `mobile-app`.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-content-pack-resolver-and-gate.md` |
| P2 | `phase-P2-detail-screen-block-and-dismissal.md` |

Artifact hygiene:

- Mỗi phase id ánh xạ đúng một file `phase-Px-*.md`.
- Không có file trùng cho cùng một phase id.
- Phase mobile phải vừa một vòng đời specialist (khoảng sáu file source/test)
  hoặc bị tách.
- Không có hai phase tách nhau chỉ vì cùng ghi một file.
- Không có phase hợp đồng độc lập: P1 tự mang hợp đồng của nó.
- Không có phase verification/testing đuôi; mỗi phase tự chạy test của mình.
- Test scope của phase không chứa backend e2e, Playwright/browser e2e, mobile
  e2e, vòng đời emulator/simulator, trace, hay chạy lại kịch bản.

## 6. Notes

- P2 sửa `activity_card_detail_screen.dart` — file này cũng là nơi test
  `activity_cards` hiện có bám vào. P2 phải chạy lại cả thư mục test đó, không
  chỉ test mới.
