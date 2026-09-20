# Phase P3 – Bộ dựng chân dung tất định

## 1. Objective

Một hàm thuần biến tập câu trả lời thành danh sách phần chân dung: mệnh đề thiếu
biến bị bỏ nguyên mệnh đề, các mệnh đề còn sống nối bằng đúng một dấu cách, và
mỗi phần kết thúc bằng một câu-để-hỏi lấy theo phép quay vòng — cùng đầu vào cho
ra cùng đầu ra, không mạng, không AI, không ngẫu nhiên.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-deterministic-composer.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/your_view_portrait/domain/portrait_composer.dart`
  - `mobile/test/features/your_view_portrait/portrait_composer_test.dart`
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
  - `composePortrait({required packs, required answers, required askCursor})`
    trả về `List<ComposedSection>`
- Shared Interfaces Consumed:
  - `PortraitSection`, `PortraitAsk`, `PortraitQuestion` (P1)
  - `PortraitAnswerRepository` đọc-only, và giá trị sổ tay cho biến
    `notebook.*` (P2)
- Risk Surfaces:
  - Tất định + offline
  - Cổng nhập nội dung đầu ra + đầu vào
- Source Of Truth:
  - authoritative artifact or convention: ngữ nghĩa mệnh đề + `requires[]` đã
    chốt ở STORY-002 (`../../STORY-002_invite_message_composer/architecture/`);
    `../architecture/contract-summary.md` mục 4
  - consumer contract: P4 chỉ hiển thị kết quả, không tự dựng câu
- Primary Inputs Summary:
  - requirements: `../requirements/requirements.md` AC-29, AC-30; AC-3, AC-4 của
    `story_master.md` (mỗi phần kết bằng câu để hỏi, không điểm số)
  - architecture: `../architecture/contract-summary.md` mục 4;
    `../architecture/solution.md` mục 4
  - OQ constraints: R-15b — hành vi hết-vòng của kho câu-để-hỏi phải đúng với MỌI
    N, kể cả N = 1
  - upstream phase outputs: kiểu gói của P1, repository của P2
  - UX constraints, if truly required: `../ux/uiux-spec.md` mục 3 (mỗi phần một
    khối, kết bằng hàng "Câu để hỏi")
  - review findings: none yet
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
  - Sections To Update: N/A
- Phase Sizing:
  - Behavior Slice: một cụm — "từ câu trả lời ra đoạn văn, tất định"
  - Source/Test File Count: 2 source/test
  - Split Required: NO
  - Split Rationale: N/A

## 2. Required Reads

- `../requirements/requirements.md` (AC-29, AC-30)
- `../architecture/contract-summary.md` mục 4
- `../architecture/solution.md` mục 4
- `../requirements/requirements.md` → `## Open Question Impact`
- `../../STORY-002_invite_message_composer/architecture/contract-summary.md` —
  ngữ nghĩa mệnh đề/`requires[]` đã chốt; lặp lại nó, đừng phát minh biến thể
- `../ux/uiux-spec.md` mục 3

## 3. Tasks

- Viết `composePortrait(...)` là hàm **thuần**: không I/O, không `DateTime.now()`,
  không `Random`, không đọc asset bên trong. Mọi đầu vào truyền vào qua tham số.
- Phân giải biến: với mỗi `bindings` `{var: question_id}`, lấy giá trị từ câu trả
  lời — biến `notebook.*` đọc giá trị đã ghi ở sổ tay qua id mục, biến
  `portrait.guess` đọc `answer_value`. Câu `skipped` coi như thiếu biến.
- Sống sót mệnh đề: mệnh đề thiếu **bất kỳ** biến nào trong `requires[]` bị bỏ
  **nguyên mệnh đề**. Không cắt nửa câu, không thay bằng chỗ trống, không sửa dấu
  câu của mệnh đề còn lại. Nối các mệnh đề sống sót bằng đúng một dấu cách.
- Phần không còn mệnh đề nào sống sót thì **không hiển thị**, thay vì hiển thị
  một tiêu đề rỗng.
- Chọn câu-để-hỏi bằng phép quay vòng trên `ask_ids` của chính phần đó với con
  trỏ truyền vào; con trỏ do người gọi giữ và **không bao giờ được lưu xuống DB**
  (mục 5 hợp đồng). Với `ask_ids` độ dài 1 thì luôn ra cùng một câu — đúng, không
  phải lỗi.
- Không hàm nào trong file này được sinh chuỗi mới: mọi văn bản đến từ gói.

## 4. Acceptance Criteria

- Cùng `(packs, answers, askCursor)` gọi hai lần cho ra hai kết quả bằng nhau
  từng ký tự (AC-29).
- Bỏ qua toàn bộ câu hỏi ⇒ không phần nào hiển thị, và không có thông điệp trách
  móc nào; bỏ qua một câu ⇒ chỉ những mệnh đề cần nó biến mất, phần vẫn đọc trôi.
- Mỗi phần hiển thị kết thúc bằng đúng một câu-để-hỏi, và câu đó kết thúc bằng
  `?` (AC-3 story, R-1g).
- Không đầu ra nào chứa điểm số, phần trăm, xếp hạng, hay câu khẳng định về người
  kia (AC-4 story) — kiểm bằng cách chạy các luật `InvariantRule` của P1 lên
  chuỗi **đã dựng**, không chỉ lên gói nguồn.
- Phép quay vòng đúng với `ask_ids` độ dài 1, 2 và n, không đâu giả định độ dài
  cố định (R-15b).

## 5. Planned Outputs

- Code directories or files:
  `mobile/lib/features/your_view_portrait/domain/portrait_composer.dart`
- Contracts or schemas: `ComposedSection` (kiểu chỉ đọc dành cho P4)
- Requirement configuration guide updates: none
- Notes or evidence: kết quả test composer, gồm ca lặp-lại-ổn-định

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter/Dart, thuần domain, không widget
- Required levels (omit N/A levels):
  - unit: sống sót mệnh đề, phân giải biến, quay vòng câu hỏi, phần rỗng bị ẩn,
    ổn định khi gọi lại
  - mobile build/type-check/static-analysis: `flutter analyze lib test`, so với
    nền khác 0 đã biết, tiêu chí là không lỗi mới
- Required checks: chạy luật `InvariantRule` lên chuỗi đầu ra đã dựng
- Minimum gates by risk surface:
  - Tất định + offline: test gọi hai lần so bằng nhau; grep chứng minh file không
    import `dart:io`, `http`, `Random`, và không gọi `DateTime.now()`
  - Cổng nhập nội dung đầu ra: test luật bất biến trên đầu ra đã dựng
- Required regression or contract coverage: test của P1 vẫn xanh
- Evidence format: lệnh đã chạy + dòng tóm tắt, dán vào `coding-plan/test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase này không dựng UI
- Verification strategy:
  - Targeted tests/regression/contract checks: `portrait_composer_test.dart` +
    `portrait_content_gate_test.dart`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: so sánh bằng nhau từng ký tự giữa hai lần dựng

## 7. Status

- Status: DONE
- Last updated: 2026-09-16
