# Master Coding Plan – STORY-011 Vỏ hoàng đạo / trắc nghiệm

## 1. Planning Metadata

- Story ID: STORY-011_zodiac_quiz_shell
- Complexity: standard
- OQ Constraints Source: `../requirements/requirements.md` `## Open Question Impact`
  (OQ-3 ĐÃ ĐÓNG 2026-09-06 bằng D-15 → R-15a/b/c)
- Requirement Configuration Guide impact: NOT_APPLICABLE — không env var, không
  secret, không tích hợp bên thứ ba; nội dung ship trong asset bundle.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (P1 sở hữu hai gói nội dung
  `req016.zodiac_quiz.v1` / `req016.zodiac_outcomes.v1`).
- Contract-first phase required: YES
  <!-- Consumer của gói nội dung là một CMS ngoài repo (deploy unit khác), nên
  rule 11a cho phép P1 đứng riêng. -->
- Parallel execution possible: NO — một lane mobile duy nhất, P1→P2→P3→P4 phụ
  thuộc tuyến tính.
- Critical path: P1 → P2 → P3 → P4.
- Parallelism notes: không có lane backend (AC-22/AC-23 loại bỏ mọi bề mặt
  server), nên không có cặp phase nào chạy song song được.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|----------------------|-------|----------------|----------------|-----------------|
| `req016.zodiac_quiz.v1` | Mobile Developer | P1 | P2, P3 | `../architecture/contract-summary.md` section 3 |
| `req016.zodiac_outcomes.v1` | Mobile Developer | P1 | P2, P3 | `../architecture/contract-summary.md` section 4 |
| `ActivityCardOrigin.zodiacShell` | Mobile Developer | P2 | P3 | `../architecture/contract-summary.md` section 2 |
| `openZodiacShellScreen` | Mobile Developer | P4 | `features/activity_cards` | `../architecture/contract-summary.md` section 2 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|--------------------------------------------------|---------------------|
| Cổng nhập nội dung | P1 |
| N là thuộc tính dữ liệu | P1, P2 |
| Tất định, không xoay theo ngày | P2 |
| Hợp đồng thẻ chỉ-đọc | P2 |
| Bề mặt kết quả một-lượt-cuộn | P3 |
| Giọng R-1e/R-1g ở đầu ra | P1, P3 |
| Cửa vào thấy được | P4 |
| Ngoại tuyến / không AI | P1, P2 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source
    runtime registry `mobile-app.buildCommand` / `testCommand`

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | DONE |
| P2 | Mobile Developer | Mobile | P1 | NO | DONE |
| P3 | Mobile Developer | Mobile | P2 | NO | DONE |
| P4 | Mobile Developer | Mobile | P3 | NO | DONE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-content-pack-and-gate.md` |
| P2 | `phase-P2-deterministic-session.md` |
| P3 | `phase-P3-result-surface-screens.md` |
| P4 | `phase-P4-entry-point-wiring.md` |

Artifact hygiene:

- Mỗi phase id ánh xạ đúng một file `phase-Px-*.md`.
- Không để file trùng cho cùng một phase id.
- Phase mobile phải vừa một vòng đời specialist (khoảng sáu file source/test)
  hoặc phải tách.
- Không phase nào tách chỉ vì hai phase sẽ ghi cùng một file, và không phase nào
  lặp lại khuôn của phase anh em cho một biến thể khác của cùng cụm hành vi.
- P1 đứng riêng vì consumer của hợp đồng là một CMS ngoài repo, không phải vì
  nó là contract.
- Không có phase verification/testing đuôi; mỗi phase tự chạy test nhắm đích và
  build/static-analysis của mình.
- Test scope của phase không chứa backend e2e, Playwright/browser e2e, mobile
  e2e, vòng đời emulator/simulator, ký/upload store, trace, hay chạy lại kịch
  bản.

## 6. Notes

- Thứ tự giao hàng SB-174 (ship sau STORY-004/005/008) là ràng buộc lịch của
  Scrum Master và **đã thoả** — không phase nào được biến nó thành phụ thuộc
  runtime (BR-3).
