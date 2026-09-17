# Scope Gate — REQ-016 / STORY-010 Bảng tra ăn khớp

Phase: SCOPE_GATE
SCOPE_GATE_COMPLETE: YES

Review type: compact-story-review
Review report path: `data/requirements/REQ-016_solo_stage1_relationship_assistant/STORY-010_compatibility_lookup/review/review-report.md`

Ghi chú lệch WriteScope: handoff và `reviewer/SKILL.md` §5a đều nói **không** tạo
file này cho `compact-story-review`, nhưng `validate-reviewer-two-phase.sh` chặn
Stop bằng `SCOPE_GATE_MISSING` kể cả với review compact. File này được ghi thêm
để thoả cổng; mục `Scope Gate` nội tuyến trong `review-report.md` vẫn là bản
chính. Đã báo cáo lệch này cho Scrum Master.

## Source/Test Files In Scope

- `mobile/lib/features/compatibility_lookup/compatibility_lookup_entry_point.dart`
- `mobile/lib/features/gift_ideas/presentation/screens/gift_ideas_screen.dart` (hunk cửa vào)
- `mobile/lib/core/database/cupid_database.dart` (hunk `schemaVersion` + `onUpgrade`)
- `mobile/test/core/database/migration_v5_test.dart`
- `mobile/test/core/database/context_notebook_migration_test.dart`

Diff baseline: `git -C <worktree> diff b58afbe0` — 57 file thay đổi, trong đó 3
JSON seed sinh sẵn, 2 file `.g.dart` sinh máy, 8 file test chỉ đổi con số
`schemaVersion`. Vượt trần 8 file của mode; xem ghi chú phạm vi trong
`review-report.md`.

## Evidence Files In Scope

- `coding-plan/test-results.md` — `## Phase Status`; P2 `### Commands Run` / `### Đối chiếu §10`; P4 toàn phần; P5/P6 `### Commands Run` / `### Files Delivered` / `### Bộ seed được ghim bằng test`
- `visual-fidelity/visual-fidelity-report.md`
- `visual-fidelity/10-bang-tra-an-khop.png`
- `visual-fidelity/design-reference-10-bang-tra-an-khop-ios.png`
- `story_master.md`
- `requirements/requirements.md` — AC-16, AC-17, AC-35, AC-36, AC-38
- `../req_master.md` — bảng phán quyết canvas (D-1…D-19)

## Query Keys

`AC-16`, `AC-17`, `AC-38`, `AC-35`, `AC-36`, `schemaVersion`, `relationship_labels`,
`openCompatibilityLookup`, `Entry Point Reachability`, `Runtime startup smoke`,
`VISUAL_FIDELITY`, `implemented-*.png`, `Design-Screen`

## Touched Risk Surfaces And Critical Gates

| Bề mặt rủi ro | Cổng tới hạn cần kiểm |
|---|---|
| persistence/schema/migration (v6→v7) | test đường nâng cấp có khẳng định bảng mới |
| typed/generated contract | `build_runner` sinh lại sạch |
| local storage/offline | test repository + ranh giới cột bị cấm |
| mobile interaction | test widget/hành vi màn (10) |
| mobile navigation/discoverability | mục `Entry Point Reachability` + tự đọc mã cửa vào |
| app lifecycle / khởi động | `## Story Runtime Startup Smoke` |
| nội dung dạng dữ liệu (400 ô) | cổng nhập + test ghim seed, phủ 100% |
| build/type-check | `flutter build apk --debug` |
| design fidelity (làn mobile, 12e3) | hai ảnh thật + `VISUAL_FIDELITY` có đối chiếu cụ thể |

## Phase 2 Approval

Phase 2 được duyệt: phạm vi đủ hẹp để xác minh bằng diff cộng năm file nguồn/test
ở trên. Không cần mở rộng sang cây `lib/` hay toàn bộ requirement.

Kết quả Phase 2 nằm trong `review-report.md` (một dòng verdict duy nhất ở đầu file).
