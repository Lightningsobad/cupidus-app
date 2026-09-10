# Phase P2 – Tầng luật bất biến dùng chung + gói/cổng nhập kho ngữ cảnh

## 1. Objective

Luật bất biến R-15c có đúng một chỗ sống trong repo, và hai gói nội dung của kho
ngữ cảnh (câu hỏi tại chỗ, mồi kỹ năng) đi qua một cổng nhập chạy được làm hỏng
bản dựng khi vi phạm.

## 1A. Ownership

- Phase ID: P2
- Canonical Phase File: `phase-P2-shared-invariant-gate-and-context-packs.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: None
- Parallelizable: YES (với P1)
- Write Scope:
  - `mobile/lib/core/content/invariant_terms.dart`
  - `mobile/lib/features/invite_composer/domain/preset_content_gate.dart`
  - `mobile/lib/features/context_notebook/domain/context_content.dart`
  - `mobile/lib/features/context_notebook/domain/context_content_gate.dart`
  - `mobile/assets/data/req016/ask_questions.v1.json`
  - `mobile/assets/data/req016/skill_seeds.v1.json`
  - `mobile/test/features/context_notebook/context_content_gate_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Startup Command Source: N/A
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - `core/content/invariant_terms.dart` (tầng luật dùng chung cho mọi họ gói)
  - `req016.ask_questions.v1`, `req016.skill_seeds.v1`
- Shared Interfaces Consumed:
  - `ContentPackage` / `ContentPackageLoader` (`mobile/lib/core/content/content_package.dart`)
- Risk Surfaces:
  - Rẽ đôi tầng luật bất biến
  - Ranh giới sổ tay bị bẩn từ tầng ĐẦU VÀO
  - Hồ sơ kỹ năng trượt về hình dạng CV
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §1, §2, §5
  - consumer contract: `../architecture/solution.md` §1 `Key Discovery` (lý do tách tầng luật)
- Primary Inputs Summary:
  - requirements: AC-10, AC-11, AC-32, AC-35, AC-36, BR-16, BR-18
  - architecture: `../architecture/contract-summary.md` §1, §2, §5
  - OQ constraints: R-15a, R-15c
  - upstream phase outputs: none
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một tầng luật bất biến + hai gói nội dung dùng chính tầng đó
  - Source/Test File Count: 7
  - Split Required: NO
  - Split Rationale: tách tầng luật ra khỏi người tiêu thụ đầu tiên của nó sẽ tạo
    một phase hợp đồng đứng một mình mà không có consumer nào ở lane khác
    (SKILL rule 11a); cả hai nửa cùng lane, cùng owner, cùng thứ tự.

## 2. Required Reads

- `../architecture/contract-summary.md` §1, §2, §5
- `../architecture/solution.md` §1 `Key Discovery`
- `../requirements/requirements.md` (AC-32, AC-35, AC-36, BR-16, BR-18)

## 3. Tasks

- Chuyển `_deniedTerms` và hàm so khớp nguyên-từ từ
  `features/invite_composer/domain/preset_content_gate.dart` sang
  `core/content/invariant_terms.dart`. Giữ nguyên `PresetGateRule`,
  `PresetViolation`, chữ ký và hành vi quan sát được của `validatePresetPack` —
  đây là thay đổi cơ học về **nguồn danh sách**, không phải viết lại gate.
- Định nghĩa model + parser cho hai gói: `AskQuestion` (`id`, `prompt`,
  `target`, `chips[]`, `allow_free_text`) và `SkillSeed` (`id`, `label`).
  `target` là enum đóng ba giá trị ở `contract-summary.md` §2; giá trị lạ là lỗi
  parse, không phải giá trị mặc định.
- `validateContextPacks`: áp `invariant_terms` lên mọi chuỗi hiển thị, cộng hai
  luật riêng của phase này — (a) câu hỏi hỏi về **tần suất/hành vi/đánh giá con
  người** bị từ chối (AC-36/BR-4); (b) gói mồi kỹ năng thiếu bất kỳ id nào trong
  bốn id bắt buộc ở `contract-summary.md` §2 bị từ chối (AC-11).
- Gói mồi kỹ năng **không có** trường nhóm/hạng/mức độ; thứ tự hiển thị là thứ
  tự khai báo, nên không thể vẽ "nhóm phụ" mờ hơn (AC-11, BR-5).
- Soạn nội dung bản đầu cho hai gói kèm `editorial_review` theo id bền.

## 4. Acceptance Criteria

- Chỉ tồn tại một định nghĩa danh sách từ cấm trong repo; grep khẳng định điều đó.
- `preset_content_gate_test.dart` (STORY-002) giữ nguyên xanh, không sửa test.
- Fixture vi phạm cho mỗi luật — tâng bốc, `%`, streak, điểm/hạng, hành vi người
  kia, giọng thao túng, câu hỏi về tần suất/hành vi/đánh giá — làm test đỏ.
- Gói mồi kỹ năng thiếu một trong bốn id bắt buộc làm test đỏ.
- Không chuỗi nội dung nào của hai gói xuất hiện trong Dart hay l10n.

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`
- Contracts or schemas: `req016.ask_questions.v1`, `req016.skill_seeds.v1`
- Notes or evidence: `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng nội dung/validation
- Required levels:
  - unit: parser hai gói, mọi luật của `validateContextPacks`, fixture vi phạm
  - integration: test quét `assets/data/req016/*.v1.json` **từ đĩa** rồi chạy
    validator tương ứng — đây là cơ chế làm hỏng bản dựng, không phải test trên
    fixture trong bộ nhớ
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
- Required checks: grep khẳng định không có bản sao thứ hai của danh sách từ cấm
- Minimum gates by risk surface: gate quét-từ-đĩa phải tồn tại và phải đỏ được;
  thiếu → `CONTENT_GATE_FORK` / `NOTEBOOK_INPUT_GATE_MISSING`
- Required regression or contract coverage: toàn bộ test
  `test/features/invite_composer/` giữ nguyên xanh sau khi tách tầng luật
- Evidence format: lệnh + kết quả tóm tắt trong `test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase không dựng màn nào
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/features/context_notebook test/features/invite_composer test/core/content`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: log fixture vi phạm làm đỏ đúng luật mong đợi

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-10
