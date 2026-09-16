# Master Coding Plan – STORY-008 Kịch bản buổi hẹn 3 phần

## 1. Planning Metadata

- Story ID: REQ-016 / STORY-008
- Complexity: standard
- Requirement Configuration Guide impact: NOT_APPLICABLE — không env var, không
  secret, không tích hợp bên thứ ba, không đổi cổng. Gói nội dung ship trong
  binary như mọi gói `req016.*` hiện có.

## 2. Planning Goal

- Shared contract owner: Mobile Developer (`../architecture/contract-summary.md`)
- Contract-first phase required: NO — một lane duy nhất, tuần tự, cùng một
  specialist vừa viết gói nội dung vừa viết mọi bên tiêu thụ trong story. Hợp
  đồng gộp vào P1; P1 không phải phase hợp đồng mỏng mà là phase dữ liệu + cổng
  nhập thực chất.
- Parallel execution possible: NO — không có lane backend/devops. Xem
  `../architecture/solution.md` §4: story không ghi gì xuống DB, không gọi mạng,
  `CupidDatabase.schemaVersion` không đổi.
- Critical path: P1 → P2 → P3 → P4
- Parallelism notes: bốn phase tách nhau vì tổng ~20 file source/test vượt xa
  một vòng đời specialist, và vì mỗi phase là một cụm hành vi riêng (dữ liệu ·
  chọn & dựng câu · đường vào + khung màn · ba cửa ra). Không phase nào tách vì
  cùng ghi một file.

## 3. Cross-Lane Contract Summary

| Contract / Interface | Owner | Producer Phase | Consumer Phase | Contract Anchor |
|---|---|---|---|---|
| Gói nội dung `date_script.v1.json` (`req016.date_script.v1`) | Mobile Developer | P1 | P2, P3 (và CMS ngoài repo sau này) | `../architecture/contract-summary.md` §1, §3 |
| Bộ biến mad-libs đóng (`activity`·`date`·`time`·`place`·`duration`·`interest`·`event`) | Mobile Developer | P1 | P2 | `../architecture/contract-summary.md` §2 |
| `openDateScriptScreen(BuildContext, ActivityCard)` + `dateScriptEntryPointId` | Mobile Developer | P3 | P4, STORY-009, STORY-010 | `../architecture/contract-summary.md` §1 |
| `ActivityCardOrigin.dateScript` (`date_script`) | Mobile Developer | P4 | STORY-001 hub (chỉ đọc) | `../architecture/contract-summary.md` §2 |

## 3A. Risk Surface To Phase Mapping

| Risk Surface (as named in solution.md section 4) | Required Dependency |
|---|---|
| Khoá vị trí màn (9) — `LOCATION_LOCK_UNVERIFIED` | P3 |
| Ranh giới J7 — `J7_BOUNDARY_UNVERIFIED` | P1 (nội dung phần "trong"), P3 (caption bảo vệ), P4 (không cửa ra nào đặt lịch/nhắc) |
| Cổng nhập nội dung — `CONTENT_GATE_UNVERIFIED` | P1 |
| Tất định + toàn phần — `DETERMINISM_UNVERIFIED` | P2 |
| Ba cửa ra gọi lại — `EXIT_REUSE_UNVERIFIED` | P4 |
| Visual fidelity màn (9) — `VISUAL_FIDELITY_BLOCKED` | P3, P4 |

## 4. Lane Summary

- Impacted runtime services/apps:
  - `mobile-app`: `mobile`, startup smoke `NOT_APPLICABLE` (không đổi đường khởi
    động app; kiểm chứng bằng `flutter test` + `flutter analyze` phạm vi hẹp),
    command/source `data/devops/system/runtime-command-registry.json` →
    `mobile-app`.
- Không có lane backend, không có lane devops, không có bước migration.

## 5. Phases Overview

| Phase | Owner | Lane | Depends On | Parallelizable | Status |
|-------|-------|------|------------|----------------|--------|
| P1 | Mobile Developer | Mobile | None | NO | COMPLETE |
| P2 | Mobile Developer | Mobile | P1 | NO | COMPLETE |
| P3 | Mobile Developer | Mobile | P2 | NO | COMPLETE |
| P4 | Mobile Developer | Mobile | P3 | NO | COMPLETE |

Phase file mapping:

| Phase | Canonical Phase File |
|-------|----------------------|
| P1 | `phase-P1-date-script-pack-and-content-gate.md` |
| P2 | `phase-P2-deterministic-selection-and-render.md` |
| P3 | `phase-P3-entry-point-and-script-screen.md` |
| P4 | `phase-P4-three-exits-and-card-origin.md` |

Artifact hygiene:

- Mỗi phase id ánh xạ đúng một file `phase-Px-*.md`.
- Không có file trùng cho cùng một phase id.
- Phase mobile phải vừa một vòng đời specialist (khoảng sáu file source/test)
  hoặc bị tách.
- Không có hai phase tách nhau chỉ vì cùng ghi một file. P3 và P4 cùng chạm
  `date_script_screen.dart`, nhưng chúng tách vì kích thước và vì hai cụm hành
  vi khác nhau (khung màn + khoá vị trí, so với ba cửa ra đi ra ngoài feature).
- Không có phase hợp đồng độc lập: P1 tự mang hợp đồng của nó.
- Không có phase verification/testing đuôi; mỗi phase tự chạy test của mình.
- Test scope của phase không chứa backend e2e, Playwright/browser e2e, mobile
  e2e, vòng đời emulator/simulator, ký ứng dụng, upload store, trace, hay chạy
  lại kịch bản.

## 6. Notes

- P3 sửa `mobile/lib/features/invite_composer/presentation/widgets/prepare_actions_sheet.dart`.
  Đây là file test `invite_composer` hiện có bám vào, nên P3 phải chạy lại cả
  `test/features/invite_composer/`, không chỉ test mới.
- P4 sửa `mobile/lib/features/activity_cards/domain/activity_card.dart` (thêm
  một giá trị enum, append-only). Chạy lại cả `test/features/activity_cards/`.
- Ghi bằng chứng test vào `coding-plan/test-results.md`; không tạo file bằng
  chứng khác.
