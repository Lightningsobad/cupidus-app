# Master Coding Plan – STORY-005 Mồi chuyện

## 1. Planning Metadata

- Story ID: STORY-005_conversation_starters
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — không env var, không
  secret, không tích hợp bên thứ ba mới; toàn bộ nằm trong một bản dựng app.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (`mobile/`), một lane duy nhất.
- Contract-first phase required: NO — mọi consumer của hợp đồng nằm cùng lane,
  cùng owner, chạy tuần tự. P1 **không** phải phase cô lập hợp đồng: nó là
  phase cài đặt thật (hai gói dữ liệu + validator + bộ test cổng nhập), và gộp
  nó vào P3 sẽ vượt xa một vòng đời specialist.
- Parallel execution possible: NO — một lane mobile, một specialist.
- Critical path: P1 → P3 → P4. P2 nằm ngoài đường găng nhưng P3 cần nó.
- Parallelism notes: P1 và P2 không phụ thuộc nhau và chạm tập file rời nhau,
  nên dispatch được theo thứ tự nào cũng đúng. Cả hai phải xong trước P3.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| `req016.starters.v1` schema + luật R-1g ở cổng nhập | Mobile Developer | P1 | P3, P4 | `../architecture/contract-summary.md` section 3 |
| `req016.calendar_events.v1` schema + `calendar_event_state` | Mobile Developer | P1, P2 | P3, P4 | `../architecture/contract-summary.md` section 4 |
| `ActivityCardOrigin.conversationStarter` | Mobile Developer | P3 | STORY-007 | `../architecture/contract-summary.md` section 2 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Cổng nhập nội dung R-15c (AC-29) | P1 |
| Hành vi hết-vòng với mọi N (AC-27/AC-28) | P1, P3 |
| Tất định (AC-17) | P1, P3 |
| Không mạng / không AI (AC-15/AC-16) | P1, P3, P4 |
| Ghi thẻ đúng hợp đồng STORY-001 (AC-11/AC-12) | P2, P3 |
| Migration Drift 6→7 | P2 |
| Visual fidelity màn (6) | P4 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (không phase nào đổi
    đường khởi động app), command/source runtime registry
    `data/devops/system/runtime-command-registry.json` → `mobile-app`

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | None | NO | DONE |
| P3 | Mobile Developer | Mobile | P1, P2 | NO | NOT_STARTED |
| P4 | Mobile Developer | Mobile | P3 | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-content-packs-and-gate.md` |
| P2 | `phase-P2-calendar-event-state-drift.md` |
| P3 | `phase-P3-selection-and-card-handoff.md` |
| P4 | `phase-P4-screen-and-entry-point.md` |

Artifact hygiene:

- Each phase id maps to exactly one canonical `phase-Px-*.md` file.
- Mobile implementation phases fit roughly six source/test files or are split.
  P2 is the one phase that touches more files than that, and deliberately: 4
  substantive files plus 8 one-line `schemaVersion` constant edits in existing
  tests. Those 8 are the mechanical fallout of P2's own migration and belong
  nowhere else.
- No trailing verification/testing phase; each phase owns its own targeted
  tests and build/type-check.

## 6. Notes

- **A-1 cần PO/Reviewer nhìn thấy, không chặn phase nào.**
  `../architecture/solution.md` §3 A-1 chốt rằng AC-18 ("ngày lịch âm tính tất
  định trên thiết bị") được thoả bằng ngày dân dụng chốt sẵn trong gói dữ liệu,
  theo đúng quy ước `occasions.v1.json` mà STORY-001 đã ship — không có phép
  quy đổi âm↔dương nào trong code, và P1 **không** được thêm dependency lịch
  âm. Nếu Reviewer đọc AC-18 theo nghĩa đen "phải có phép tính", đó là một
  Design Ruling ở tầng requirement, không phải lỗi cài đặt của P1.
- Thứ tự bắt buộc bên trong P2: `schemaVersion` lên `7` và migration cộng thêm
  phải vào **cùng một commit** với việc sửa 8 file test đang khẳng định `6`.
  Tách ra là để lại một cây đỏ giữa hai phase.
