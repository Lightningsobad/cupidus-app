# Phase P1 – Ba gói nội dung chân dung và cổng nhập chạy được

## 1. Objective

Ba gói nội dung `req016.portrait_questions.v1`, `req016.portrait_sections.v1`,
`req016.portrait_asks.v1` tồn tại dưới dạng asset JSON có schema và id bền, đọc
được qua `ContentPackageLoader`, và một cổng nhập **chạy được** làm đỏ bản dựng
khi bất kỳ gói nào vi phạm luật bất biến — ở cả tầng đầu ra (AC-36) lẫn tầng câu
hỏi đầu vào (AC-37).

## 1A. Ownership

- Phase ID: P1
- Canonical Phase File: `phase-P1-content-packs-and-gate.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/your_view_portrait/domain/portrait_content.dart`
  - `mobile/lib/features/your_view_portrait/domain/portrait_content_gate.dart`
  - `mobile/lib/core/content/invariant_terms.dart` (chỉ thêm, không sửa luật cũ)
  - `mobile/assets/data/req016/portrait_questions.v1.json`
  - `mobile/assets/data/req016/portrait_sections.v1.json`
  - `mobile/assets/data/req016/portrait_asks.v1.json`
  - `mobile/test/features/your_view_portrait/portrait_content_gate_test.dart`
  - `mobile/pubspec.yaml` (chỉ khi `assets/data/req016/` chưa được khai báo)
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
  - `PortraitQuestion`, `PortraitSection`, `PortraitAsk`, `PortraitAnswerTarget`
    (`../architecture/contract-summary.md` mục 2, 4)
  - `validatePortraitPacks(...) -> List<PortraitViolation>`
  - `portraitLegalOpeningFrames` (hằng Dart, không bao giờ nằm trong asset)
- Shared Interfaces Consumed:
  - `ContentPackage<T>` / `ContentPackageLoader` (`mobile/lib/core/content/content_package.dart`)
  - `InvariantRule` / `NotebookBoundaryRule` (`mobile/lib/core/content/invariant_terms.dart`)
- Risk Surfaces:
  - Cổng nhập nội dung đầu ra + đầu vào
  - Tất định + offline
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md`
    mục 2 (định danh) và mục 4 (trường của từng item)
  - consumer contract: P3 (composer) và P4 (màn) chỉ đọc gói qua kiểu ở phase này
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-31, AC-33..AC-37,
    BR-15..BR-17
  - architecture: `../architecture/contract-summary.md` mục 2, 4;
    `../architecture/solution.md` mục 4 (hai hàng rủi ro nêu trên)
  - OQ constraints: OQ-3 đã đóng bằng D-15 → R-15a/b/c (độ dài gói là dữ liệu,
    không phải hằng số trong mã)
  - upstream phase outputs: none
  - UX constraints, if truly required: `../ux/uiux-spec.md` mục 2 (mỗi câu phải
    có ít nhất một chip gợi ý) và mục 3 (mỗi phần kết bằng một câu để hỏi)
  - review findings: none yet
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: một cụm hành vi — "nội dung chân dung là dữ liệu có luật, và
    luật chạy được"
  - Source/Test File Count: 6 source/test (3 JSON asset tính là dữ liệu của cùng
    một lát)
  - Split Required: NO
  - Split Rationale: N/A

## 2. Required Reads

- `../requirements/requirements.md` (AC-31, AC-33..AC-37, BR-15..BR-17)
- `../architecture/contract-summary.md` mục 2 và 4
- `../architecture/solution.md` mục 4
- `../requirements/requirements.md` → `## Open Question Impact`
- `../ux/uiux-spec.md` mục 2, 3
- `mobile/lib/features/context_notebook/domain/context_content.dart` và
  `context_content_gate.dart` — khuôn mẫu đã giao của STORY-004, bám sát nó

## 3. Tasks

- Định nghĩa `PortraitQuestion`, `PortraitSection`, `PortraitAsk` cài
  `ContentItem`, parse qua `ContentPackage.parse` với `expectedSchemaId` đúng, chỉ
  dùng các helper `requireContentString` / `optionalContentString` /
  `requireContentObjectList` / `requireContentStringList` sẵn có.
- Định nghĩa `enum PortraitAnswerTarget { notebookInterest('notebook.interest'),
  notebookEvent('notebook.event'), portraitGuess('portrait.guess') }` — enum
  cục bộ của feature, KHÔNG tái dùng `AskTarget` của STORY-004 vì hai tập giá trị
  khác nhau (`skill` không hợp lệ ở đây, `portrait.guess` không hợp lệ ở kia).
- Thêm đúng một luật mới `assertiveClaim` vào `InvariantRule` trong
  `core/content/invariant_terms.dart` cho các cụm app tự khẳng định về người kia
  ("người ấy là", "chắc chắn thích", "thực ra"…). Không sửa denylist đã có.
- Viết `validatePortraitPacks(...)` trả về `List<PortraitViolation>` (không
  throw), kiểm ít nhất: mọi luật `InvariantRule` trên `prompt`/`text`/`clauses`;
  `NotebookBoundaryRule` trên câu hỏi có `target` là `notebook.*` (chặn câu dò
  tần suất/hành vi/phán xét — R-1b, R-1f); mỗi câu có ≥1 chip; mỗi phần có ≥1
  `ask_id` và mọi `ask_id` phải tồn tại trong gói asks; mọi `bindings` trỏ tới
  `question_id` có thật; mọi `requires[]` chỉ nêu biến có trong `bindings`; mọi
  ask kết thúc bằng `?`; mọi phần mở bằng một trong
  `portraitLegalOpeningFrames`; id trùng lặp; `schema_id`/`version` sai.
- Viết `portrait_content_gate_test.dart` **quét asset thật từ đĩa** (`Directory`
  trên `assets/data/req016/portrait_*.json`), không nhúng chuỗi JSON trong test —
  một gói vi phạm phải làm đỏ bản dựng, không chỉ làm đỏ một fixture.
- Bổ sung ca test âm bằng gói dựng trong bộ nhớ cho từng luật để chứng minh cổng
  thật sự bắt, không phải xanh rỗng.
- Viết nội dung hạt giống: 8 câu hỏi, 3 phần, ≥6 câu-để-hỏi. Số lượng là dữ liệu;
  không mã nào được giả định các con số này.

## 4. Acceptance Criteria

- `flutter test test/features/your_view_portrait/portrait_content_gate_test.dart`
  xanh, và làm hỏng một chuỗi trong một gói asset thật khiến nó đỏ.
- Mọi câu hỏi có `target` là `notebook.*` đều đi qua `NotebookBoundaryRule` và
  không câu nào hỏi về tần suất, hành vi, hay phán xét người kia (AC-22 tiền đề).
- Không gói nào chứa %, điểm số, xếp hạng, streak, hay câu app tự khẳng định về
  người kia (AC-34, AC-35, AC-4 của story).
- Không có chuỗi nội dung chân dung nào trong mã Dart hay ARB ngoài asset (R-15a);
  chỉ luật và khung mở đầu hợp lệ sống trong Dart.
- Không mã nào đọc `length` của gói để suy ra tiến độ hay điều kiện kết thúc.

## 5. Planned Outputs

- Code directories or files: `mobile/lib/features/your_view_portrait/domain/`,
  `mobile/lib/core/content/invariant_terms.dart`,
  `mobile/assets/data/req016/portrait_*.v1.json`
- Contracts or schemas: ba `schema_id` ở `../architecture/contract-summary.md`
  mục 2; hình dạng item ở mục 4
- Requirement configuration guide updates: none
- Notes or evidence: kết quả `flutter test` của file cổng, kèm một lần chạy đỏ
  có chủ đích chứng minh cổng bắt được vi phạm

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter/Dart, thuần domain, không widget
- Required levels (omit N/A levels):
  - unit: parse ba gói, mọi nhánh luật của `validatePortraitPacks`
  - integration: cổng quét asset thật từ đĩa
  - mobile build/type-check/static-analysis: `flutter analyze lib test` chỉ để so
    với nền đã biết — nền của repo này KHÁC 0 (222 cảnh báo sẵn có, 0 lỗi), nên
    tiêu chí là "không lỗi mới", không phải exit code 0
- Required checks: mọi `ask_id`/`question_id` tham chiếu chéo phải phân giải được
- Minimum gates by risk surface:
  - Cổng nhập nội dung đầu ra + đầu vào: test quét đĩa phải đỏ khi asset vi phạm
  - Tất định + offline: không lời gọi mạng, không nguồn ngẫu nhiên trong phase này
- Required regression or contract coverage: `flutter test test/features/context_notebook/`
  vẫn xanh sau khi thêm luật vào `invariant_terms.dart` — file đó dùng chung với
  STORY-004
- Evidence format: lệnh đã chạy + dòng tóm tắt kết quả, dán vào
  `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng UI
- Verification strategy:
  - Targeted tests/regression/contract checks: file test của phase +
    `test/features/context_notebook/`
  - Build/type-check/lint command when required: `flutter analyze lib test`
    (so sánh với nền, không dùng exit code làm cổng)
  - Required assertion evidence: một lần chạy đỏ có chủ đích của cổng

## 7. Status

- Status: COMPLETE
- Last updated: 2026-09-11
- Evidence: `test-results.md` → `Phase P1`
- Implementation notes:
  - `pubspec.yaml` không đổi — `assets/data/req016/` đã khai báo từ trước.
  - Write Scope thực tế rộng hơn danh sách ở mục 1B đúng bốn file: thêm
    `assertiveClaim` vào `InvariantRule` buộc bốn gate anh em
    (`context_notebook`, `before_you_go`, `gift_ideas`, `invite_composer`) khai
    cùng wire value, nếu không hai test hiện có đỏ và `_ruleFor` của bốn gate
    ném `StateError` khi luật mới kích hoạt. Ripple được hấp thụ trong P1 để
    phase sau không nhận repo đỏ.
  - `illegalOpeningFrame` kiểm MỌI clause, không chỉ clause đầu: clause thiếu
    biến bị bỏ nguyên câu nên clause nào cũng có thể thành câu mở của phần.
