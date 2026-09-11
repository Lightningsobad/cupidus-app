# Phase P2 – Lưu câu trả lời và cửa ghi hẹp vào sổ tay

## 1. Objective

Câu trả lời của người dùng được giữ lại qua các phiên bằng một bảng Drift duy
nhất không có bất kỳ cột đo lường nào, và câu trả lời loại sở thích/sự kiện đi
vào sổ tay STORY-004 qua **đúng một** cửa ghi hẹp, có kiểu, ghi từng câu một.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-answer-store-and-notebook-door.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/core/database/tables/portrait_answers_table.dart`
  - `mobile/lib/core/database/cupid_database.dart` (bump `schemaVersion`,
    migration cộng thêm)
  - `mobile/lib/features/your_view_portrait/data/portrait_answer_dao.dart`
  - `mobile/lib/features/your_view_portrait/data/portrait_answer_repository.dart`
  - `mobile/lib/features/context_notebook/context_notebook_entry_point.dart`
    (chỉ thêm `recordAnsweredQuestion`)
  - `mobile/test/features/your_view_portrait/portrait_answer_repository_test.dart`
  - các file test hiện có khẳng định `schemaVersion` (sửa theo hiệu ứng lan toả)
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: runtime registry `runCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `recordAnsweredQuestion(...) -> Future<String>`
    (`../architecture/contract-summary.md` mục 3 — bản sửa đổi §6 hợp đồng
    STORY-004)
  - `PortraitAnswerRepository` (đọc/ghi trạng thái `answered` | `skipped`)
- Shared Interfaces Consumed:
  - `CupidDatabase` (ADR-010: một chủ sở hữu Drift duy nhất)
  - `NotebookKind`, `ContextNotebookReader` (STORY-004)
  - `BackendUserIdStore` → `owner_key`
- Risk Surfaces:
  - Migration `schemaVersion` (ADR-010)
  - Ranh giới sổ tay R-1f (AC-22/AC-23)
  - Bỏ dở, không thúc ép (AC-25..AC-28)
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md`
    mục 3 và mục 5 (cột của `portrait_answers`, danh sách cột bị cấm vĩnh viễn)
  - consumer contract: P4 là consumer duy nhất trong story; STORY-008 dùng lại sau
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-5, AC-6 (story_master),
    AC-22, AC-23, AC-25..AC-28
  - architecture: `../architecture/contract-summary.md` mục 3, 5;
    `../architecture/solution.md` mục 4
  - OQ constraints: R-15b — không cột nào được phép suy ra tiến độ
  - upstream phase outputs: `PortraitAnswerTarget` và id câu hỏi từ P1
  - UX constraints, if truly required: `../ux/uiux-spec.md` mục 2.3 (mở lại vào
    đúng câu đang dở), 2.4 (cờ "sẽ lưu vào sổ tay" là ngầm)
  - review findings: none yet
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: một cụm — "câu trả lời sống sót qua phiên, và phần lưu được
    thì chảy vào sổ tay"
  - Source/Test File Count: 6 source/test (chưa kể các assertion lan toả, là sửa
    một dòng mỗi file)
  - Split Required: NO
  - Split Rationale: N/A

## 2. Required Reads

- `../requirements/requirements.md` (AC-22, AC-23, AC-25..AC-28)
- `../architecture/contract-summary.md` mục 3 và 5
- `../architecture/solution.md` mục 4 (ba hàng rủi ro nêu trên)
- `../../STORY-004_context_notebook/architecture/contract-summary.md` mục 6 —
  đọc nguyên văn điều cấm trước khi thêm cửa ghi, để cửa mới vẫn giữ đúng mục
  đích của điều cấm đó
- `mobile/lib/core/database/cupid_database.dart` — `schemaVersion` hiện tại và
  khuôn `MigrationStrategy` đã có
- `../ux/uiux-spec.md` mục 2

## 3. Tasks

- Tạo bảng Drift `portrait_answers` đúng mục 5 hợp đồng: khoá chính
  (`owner_key`, `question_id`), `state`, `option_id` NULL, `answer_value` NULL,
  `notebook_entry_id` NULL, `updated_at`. **Không** thêm bất kỳ cột đếm, điểm,
  phần trăm, streak, `completed_at`, hay `answered_count` nào — mục 5 cấm vĩnh
  viễn, và một cột như thế sau này sẽ được UI dùng để thúc ép.
- Đăng ký bảng vào `@DriftDatabase` của `CupidDatabase`, tăng `schemaVersion`
  đúng **một** đơn vị so với giá trị thật đang có trên nhánh tích hợp (đọc file
  rồi cộng một, không dùng con số nhớ được), và thêm bước `onUpgrade` **chỉ tạo
  bảng mới**, không đụng bảng cũ.
- Sửa mọi assertion `schemaVersion` đang đỏ ở test hiện có **trong chính phase
  này**. Để lại repo đỏ cho phase sau là mất một lượt dispatch.
- `PortraitAnswerDao` + `PortraitAnswerRepository`: `upsertAnswer`,
  `markSkipped`, `answersFor(ownerKey)`. Con trỏ "câu đang dở" được **suy ra**
  từ tập câu trả lời khi đọc, KHÔNG lưu — không có cột nào mang nghĩa tiến độ.
- Thêm `recordAnsweredQuestion(...)` vào
  `features/context_notebook/context_notebook_entry_point.dart` đúng chữ ký ở
  mục 3 hợp đồng: một câu trả lời mỗi lần, `kind` chỉ nhận `interest` hoặc
  `event`, `source = 'ask_on_the_spot'`, `question_id` bắt buộc, trả về id mục
  sổ tay vừa tạo. Không hàng loạt, không import, không update, không delete,
  không đọc-tất-cả.
- Lưu `notebook_entry_id` trả về vào `portrait_answers` để P4 hiển thị lại được
  giá trị đã ghi mà không phải nhân đôi nội dung.

## 4. Acceptance Criteria

- Trả lời một số câu, đóng, mở lại: đúng các câu đã trả lời còn nguyên và câu
  đang dở là câu chưa trả lời đầu tiên (AC-25, AC-6 story).
- Câu `notebook.interest` / `notebook.event` đã trả lời xuất hiện trong sổ tay và
  đọc lại được qua `ContextNotebookReader` (AC-5 story).
- Câu `portrait.guess` **không** tạo mục sổ tay nào (AC-23).
- `recordAnsweredQuestion` từ chối `NotebookKind.skill` ở mức kiểu hoặc ném lỗi
  rõ ràng; không có đường nào ghi hàng loạt.
- Migration chạy được trên DB có sẵn ở phiên bản trước: dữ liệu cũ còn nguyên,
  bảng mới xuất hiện.
- Không cột nào trong `portrait_answers` thuộc danh sách cấm ở mục 5.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/core/database/tables/`,
  `mobile/lib/features/your_view_portrait/data/`,
  `mobile/lib/features/context_notebook/context_notebook_entry_point.dart`
- Contracts or schemas: `portrait_answers` (mục 5), `recordAnsweredQuestion` (mục 3)
- Requirement configuration guide updates: none
- Notes or evidence: kết quả test migration và test repository

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter/Dart, Drift trong bộ nhớ, không widget
- Required levels (omit N/A levels):
  - unit: dao/repository, suy ra con trỏ câu đang dở, từ chối `skill`
  - integration: migration từ phiên bản trước lên phiên bản mới trên DB có dữ liệu;
    ghi qua `recordAnsweredQuestion` rồi đọc lại bằng `ContextNotebookReader`
  - mobile build/type-check/static-analysis: `flutter analyze lib test`, so với
    nền đã biết khác 0 (222 cảnh báo, 0 lỗi), tiêu chí là không lỗi mới
- Required checks: `dart run build_runner build` sinh lại mã Drift trước khi chạy test
- Minimum gates by risk surface:
  - Migration `schemaVersion`: một test nâng cấp từ phiên bản trước, cộng với mọi
    assertion `schemaVersion` hiện có đã xanh trở lại
  - Ranh giới sổ tay R-1f: test khẳng định `portrait.guess` không tạo mục sổ tay
  - Bỏ dở, không thúc ép: test mở lại đúng câu đang dở, và không API nào lộ ra
    số câu đã trả lời dưới dạng tiến độ
- Required regression or contract coverage: toàn bộ
  `flutter test test/features/context_notebook/` và mọi test chạm `CupidDatabase`
- Evidence format: lệnh đã chạy + dòng tóm tắt, dán vào `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng UI
- Verification strategy:
  - Targeted tests/regression/contract checks: test của phase + context_notebook
    + mọi test khẳng định `schemaVersion`
  - Build/type-check/lint command when required: `dart run build_runner build`
    rồi `flutter analyze lib test`
  - Required assertion evidence: log test migration cho thấy dữ liệu cũ còn
    nguyên sau nâng cấp

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-11
