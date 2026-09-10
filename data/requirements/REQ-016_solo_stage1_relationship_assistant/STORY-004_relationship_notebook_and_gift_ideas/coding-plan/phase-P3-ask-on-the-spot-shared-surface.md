# Phase P3 – Cơ chế hỏi-tại-chỗ + mặt tiền dùng chung

## 1. Objective

`AskOnTheSpotSlot` và mặt tiền một chiều của kho ngữ cảnh tồn tại đúng như hợp
đồng shared-foundation, với bất biến "đúng một câu một lần" nằm trong chính
widget chứ không phải trong kỷ luật của phía gọi.

## 1A. Ownership

- Phase ID: P3
- Canonical Phase File: `phase-P3-ask-on-the-spot-shared-surface.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P1, P2
- Parallelizable: YES (với P5)
- Write Scope:
  - `mobile/lib/features/context_notebook/domain/ask_cadence_policy.dart`
  - `mobile/lib/features/context_notebook/presentation/cubit/ask_on_the_spot_cubit.dart`
  - `mobile/lib/features/context_notebook/presentation/widgets/ask_on_the_spot_slot.dart`
  - `mobile/lib/features/context_notebook/context_notebook_entry_point.dart`
  - `mobile/test/features/context_notebook/ask_cadence_policy_test.dart`
  - `mobile/test/features/context_notebook/ask_on_the_spot_slot_test.dart`
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
  - `AskOnTheSpotSlot`, `ContextNotebookReader`, `openNotebookScreen`,
    `openSkillProfileScreen` (hợp đồng cho STORY-005/008/009/010)
- Shared Interfaces Consumed:
  - `ContextNotebookRepository` (P1), gói `req016.ask_questions.v1` +
    `req016.skill_seeds.v1` (P2)
- Risk Surfaces:
  - Hợp đồng shared-foundation bị định hình sai
- Source Of Truth:
  - authoritative artifact or convention: `../architecture/contract-summary.md` §3
  - consumer contract: cùng §3 — STORY-005/008/009/010 dựng widget này, không vẽ lại
- Primary Inputs Summary:
  - requirements: AC-1, AC-2, AC-3, AC-4, AC-5, AC-10, AC-11, BR-1, BR-2, BR-3
  - architecture: `../architecture/contract-summary.md` §3
  - OQ constraints: none mới
  - upstream phase outputs: P1 repository, P2 hai gói + parser
  - UX constraints: `../ux/uiux-spec.md` Phần A (hình thức thẻ hỏi inline) —
    đây là component mà các story sau bị cấm vẽ khác, nên bố cục là ràng buộc
    thật chứ không phải gợi ý
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một component hỏi-tại-chỗ + mặt tiền công bố nó
  - Source/Test File Count: 6
  - Split Required: NO
  - Split Rationale: chính sách nhịp hỏi, cubit, và widget là một hành vi duy
    nhất; mặt tiền chỉ là file export của cùng feature, không phải hợp đồng cho
    lane khác trong story này (SKILL rule 11a).

## 2. Required Reads

- `../architecture/contract-summary.md` §3
- `../ux/uiux-spec.md` Phần A và Phần C (dải chip mồi khi hồ sơ kỹ năng rỗng)
- `../requirements/requirements.md` (AC-1..AC-5, AC-10, AC-11, BR-1..BR-3)

## 3. Tasks

- `AskCadencePolicy`: chọn câu hỏi tiếp theo từ `neededFieldIds` theo thứ tự ưu
  tiên, loại câu đã `answered`, loại câu `skipped` trong phiên hiện tại, và xếp
  cuối câu đã `skipped` ở phiên trước. Không hằng số thời gian chờ — quy tắc là
  phạm vi phiên, không phải đồng hồ.
- `AskOnTheSpotSlot`: thẻ hỏi inline (không dialog, không route mới) gồm một câu
  `body 17pt`, dải chip chạm-để-chọn, ô "khác..." tuỳ chọn ở cuối dải, và liên
  kết văn bản "Bỏ qua". **Không** nút "Lưu vào hồ sơ", **không** toast/snackbar
  sau khi trả lời.
- Bất biến một-câu-một-lần: slot tự trả `SizedBox.shrink()` khi không thiếu
  trường, khi câu đã trả lời, khi vừa bỏ qua trong phiên, **và khi một slot khác
  đã dựng trên cùng route**.
- Trả lời ghi thẳng vào repository rồi gọi `onContextChanged`; luồng gọi cập
  nhật kết quả tại chỗ, coi như một bước lọc bình thường.
- `context_notebook_entry_point.dart`: mặt tiền duy nhất ra ngoài feature, theo
  mẫu `features/journal/journal_entry_point.dart`. Không re-export DAO, cubit,
  hay widget nội bộ; không hàm đếm/xếp hạng/tìm kiếm.

## 4. Acceptance Criteria

- Trả lời một câu tại chỗ không hiện màn/toast xác nhận nào (AC-1).
- Dựng hai `AskOnTheSpotSlot` trên cùng một route: slot thứ hai render rỗng (AC-2).
- "Bỏ qua" trả lại luồng ngay, không chặn, không hỏi lại câu đó trong phiên, và
  không có câu trách móc nào (AC-3).
- Mục vừa trả lời đọc lại được qua `ContextNotebookReader` (AC-4).
- Khi đích là `skill`, dải chip hiện tối thiểu bốn mồi kỹ năng mềm **trước** khi
  người dùng gõ bất cứ gì, và không có ô nhập tự do trống làm lựa chọn mặc định
  (AC-10, AC-11).
- Không tồn tại route hay bước nào bắt điền trước khi dùng (AC-5, BR-1).
- Không file nào ngoài `features/context_notebook/**` import một symbol nội bộ
  của feature.

## 5. Planned Outputs

- Code directories or files: xem `Write Scope`
- Contracts or schemas: `../architecture/contract-summary.md` §3 (không đổi hình dạng)
- Notes or evidence: `test-results.md`

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, widget + domain
- Required levels:
  - unit: `AskCadencePolicy` chọn câu, bỏ qua, không lặp trong phiên
  - integration: widget test slot ↔ repository (trả lời → mục xuất hiện)
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
  - visual inspection: không áp dụng ở phase này (slot được chụp cùng màn chủ ở P4/P7)
- Required checks: test biên giới import — không import nội bộ nào từ ngoài feature
- Mobile discoverability / navigation integration: N/A — phase này không gắn lối
  vào; P4 và P7 làm việc đó
- Minimum gates by risk surface: test hai-slot-một-route phải tồn tại; thiếu →
  `SHARED_CONTRACT_UNSTABLE`
- Required regression or contract coverage: test P1 giữ nguyên xanh
- Evidence format: lệnh + kết quả tóm tắt trong `test-results.md`
- Per-story visual fidelity: NOT_APPLICABLE — phase dựng component, không dựng
  màn; dòng visual-fidelity của thẻ hỏi được P7 chụp trong ngữ cảnh màn (5)
- Verification strategy:
  - Targeted tests/regression/contract checks: `flutter test test/features/context_notebook`
  - Build/type-check/lint command when required: `flutter analyze lib test`
  - Required assertion evidence: log test hai-slot và test không-toast

## 7. Status

- Status: NOT_STARTED
- Last updated: 2026-09-10
