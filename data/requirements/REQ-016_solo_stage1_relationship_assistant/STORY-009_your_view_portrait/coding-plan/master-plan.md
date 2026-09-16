# Master Coding Plan – Chân dung "theo cách BẠN nhìn" (màn 8)

## 1. Planning Metadata

- Story ID: STORY-009_your_view_portrait
- Complexity: complex
- OQ Constraints Source: `../requirements/requirements.md` → `## Open Question Impact`
  (OQ-3 đã đóng 2026-09-06 bằng D-15; không còn OQ chặn)
- Requirement Configuration Guide impact: NOT_APPLICABLE — không biến môi trường,
  không secret, không tích hợp bên ngoài (AC-30)

## 2. Planning Goal

- Shared contract owner: `../architecture/contract-summary.md` (Mobile Developer)
- Contract-first phase required: NO — cùng một specialist cài đặt hợp đồng và mọi
  consumer trong story theo thứ tự, một lane duy nhất; hợp đồng gấp vào P1/P2
  theo quy tắc 11a
- Parallel execution possible: NO — một lane mobile, các phase nối tiếp theo dữ
  liệu (gói nội dung → lưu trữ → composer → màn → cửa vào)
- Critical path: P1 → P2 → P3 → P4 → P5
- Parallelism notes: P3 chỉ cần P1 (hình dạng gói) và P2 (đọc câu trả lời); nếu
  có hai slot mobile, P3 và phần widget tĩnh của P4 chạy song song được, nhưng
  kế hoạch mặc định là tuần tự.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| Ba gói nội dung `req016.portrait_*.v1` | Mobile Developer | P1 | P3, P4 | `../architecture/contract-summary.md` section 2, 4 |
| `recordAnsweredQuestion(...)` (bản sửa đổi §6 STORY-004) | Mobile Developer | P2 | P4 | `../architecture/contract-summary.md` section 3 |
| `openYourViewPortrait(...)` + `PortraitEntrySource` | Mobile Developer | P5 | STORY-008 (sau) | `../architecture/contract-summary.md` section 3 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Cổng nhập nội dung đầu ra + đầu vào (AC-36/AC-37) | P1 |
| Migration `schemaVersion` (ADR-010) | P2 |
| Ranh giới sổ tay R-1f (AC-22/AC-23) | P2, P4 |
| Tất định + offline (AC-29/AC-30) | P1, P3 |
| Bỏ dở, không thúc ép (AC-25..AC-28) | P2, P4 |
| Nhãn xuất xứ trong bố cục (AC-6..AC-8) | P4 |
| Khoá vị trí R-13 (AC-2/AC-3) | P5 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE`, command/source runtime
    registry `data/devops/system/runtime-command-registry.json` → `mobile-app`

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | COMPLETE |
| P2 | Mobile Developer | Mobile | P1 | NO | COMPLETE |
| P3 | Mobile Developer | Mobile | P1, P2 | NO | NOT_STARTED |
| P4 | Mobile Developer | Mobile | P2, P3 | NO | NOT_STARTED |
| P5 | Mobile Developer | Mobile | P4 | NO | NOT_STARTED |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-content-packs-and-gate.md` |
| P2 | `phase-P2-answer-store-and-notebook-door.md` |
| P3 | `phase-P3-deterministic-composer.md` |
| P4 | `phase-P4-portrait-screen.md` |
| P5 | `phase-P5-locked-entry-point.md` |

Artifact hygiene:

- Mỗi phase id ánh xạ đúng một file `phase-Px-*.md`; không có file trùng.
- Mọi phase mobile nằm trong một vòng đời specialist (khoảng sáu file
  source/test) hoặc đã được tách.
- Không phase nào tách chỉ vì hai phase cùng ghi một file, và không phase nào lặp
  lại khuôn của phase anh em cho một biến thể của cùng cụm hành vi.
- Không có phase hợp đồng đứng riêng: cùng specialist, cùng lane, nối tiếp.
- Không có phase kiểm thử đuôi; mỗi phase tự chạy test nhắm đúng phạm vi của nó.
- Test scope của mọi phase không chứa e2e backend, Playwright/browser e2e, trace,
  hay chạy lại kịch bản.

## 6. Notes

- Thứ tự bắt buộc P1 trước P2: cổng nhập nội dung phải đỏ được trước khi có bất kỳ
  đường đọc nào, nếu không một gói vi phạm có thể lọt qua trong lúc lớp dữ liệu
  đang hình thành.
- P2 mang chi phí lan toả đã biết: bump `schemaVersion` làm đỏ các assertion
  `schemaVersion` ở test hiện có. Sửa chúng thuộc chính P2, không để sang phase
  sau — một phase khác nhận repo đỏ là mất một lượt dispatch.
