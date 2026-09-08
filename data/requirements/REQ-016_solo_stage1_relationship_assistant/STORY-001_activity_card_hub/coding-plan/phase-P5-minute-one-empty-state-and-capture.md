# Phase P5 – Trạng thái rỗng "Phút 1", nhập nhanh, và dải lối-vào-nhanh

## 1. Objective

Làm cho người dùng mới có 1–2 thẻ trong 60 giây bằng đúng hai lời mời một chạm,
và cho người dùng cũ bắt ý tưởng trong 5 giây bằng nút "+" và dán link.

## 1A. Ownership

- Phase ID: P5
- Canonical Phase File: `phase-P5-minute-one-empty-state-and-capture.md`
- Owner: Mobile Developer
- Lane: Mobile

## 1B. Phase Metadata

- Depends On: P3, P4
- Parallelizable: NO
- Write Scope:
  - `mobile/lib/features/activity_cards/presentation/widgets/minute_one_empty_state.dart`
  - `mobile/lib/features/activity_cards/presentation/widgets/quick_capture_sheet.dart`
  - `mobile/lib/features/activity_cards/presentation/widgets/quick_entry_strip.dart`
  - `mobile/lib/l10n/app_vi.arb`
  - `mobile/test/features/activity_cards/minute_one_empty_state_test.dart`
  - `mobile/test/features/activity_cards/quick_capture_sheet_test.dart`
- Impacted Runtime Service/App:
  - Name: mobile-app
  - Runtime Registry Id: `mobile-app`
  - Registry: `data/devops/system/runtime-command-registry.json`
  - Type: mobile
  - Startup Smoke: NOT_APPLICABLE
  - Build Command Source: runtime registry `buildCommand`
  - Readiness Check: N/A
  - Port Contract: N/A
- Shared Interfaces Produced:
  - Dải lối-vào-nhanh 3 ô cố định (khung) mà STORY-004/005/011 điền nội dung
- Shared Interfaces Consumed:
  - `createCard` (P2), `OccasionSuggestionService` (P3), màn hub (P4)
- Risk Surfaces:
  - R-7/BR-8 — AI hoặc API nội dung ở runtime
  - SC-1' — danh sách thứ hai
- Source Of Truth:
  - authoritative artifact: `../ux/uiux-spec.md` §4a, §6
  - consumer contract: STORY-004/005/011 điền nội dung 3 ô
- Primary Inputs Summary:
  - requirements: AC-1, AC-2, AC-3, AC-4, AC-6, AC-7
  - architecture: `../architecture/solution.md` §4 Contracts And Integrations
  - upstream phase outputs: P3, P4
  - UX constraints: `../ux/uiux-spec.md` §4a, §6
- Requirement Configuration Guide:
  - Path: `../../deployment/configuration-guide.md`
  - Update Required: NO
- Phase Sizing:
  - Behavior Slice: một cụm — đường vào tạo thẻ đầu tiên.
  - Source/Test File Count: 6
  - Split Required: NO

## 2. Required Reads

- `../ux/uiux-spec.md` §4a, §6
- `../requirements/requirements.md` Nhóm A, Nhóm B
- `../architecture/contract-summary.md` §1, §2

## 3. Tasks

- Trạng thái rỗng tuyệt đối: ẩn segmented filter, hiện đúng 2 thẻ lời mời xếp
  dọc, tối đa một dòng tiêu đề ngắn phía trên. Không hình minh hoạ lớn, không
  đoạn văn marketing, không form, không wizard.
- Lời mời 1 "dán 1 link": mở ô nhập một trường URL duy nhất, lưu ngay khi dán
  xong, không nút xác nhận phụ, không đòi thêm trường.
- Lời mời 2 "gợi ý theo dịp": hiện 1–2 gợi ý tất định từ P3, mỗi gợi ý là một
  hàng chạm-để-tạo-thẻ.
- Nút "+" nhập nhanh cho kho đã có thẻ: một trường tiêu đề, lưu ngay
  (`origin = manual`). Nút này ẩn ở trạng thái rỗng Phút-1 vì hai CTA đã thay thế.
- Dải lối-vào-nhanh 3 ô cố định (Gợi ý quà / Mồi chuyện / Vỏ hoàng đạo), kích
  thước bằng nhau, luôn hiện kể cả ở trạng thái rỗng. Ô chưa có story dẫn tới
  màn "sắp có" trung tính; không ẩn ô. Không badge số, không chấm "mới".

## 4. Acceptance Criteria

- Kho rỗng hiện đúng hai lời mời, không biểu mẫu onboarding nào (AC-1).
- Mỗi lời mời tạo được ít nhất 1 thẻ `idea` mà không phải điền thêm trường (AC-2, AC-3).
- Nút "+" tạo thẻ chỉ với tiêu đề (AC-6).
- Dán link tạo được thẻ kể cả khi không lấy được tiêu đề/ảnh (AC-7).
- Dải 3 ô luôn có đúng 3 ô, không đổi hình dạng theo dữ liệu người dùng.

## 5. Planned Outputs

- Code: widget trạng thái rỗng, sheet nhập nhanh, dải 3 ô, chuỗi l10n.
- Notes: bằng chứng test và ảnh chụp màn ghi vào `coding-plan/test-results.md`.

## 6. Test Scope

- Decision Source: `Tech Lead phase test scope`
- Platform / Surface: Flutter mobile, tầng presentation
- Required levels:
  - unit: rẽ nhánh rỗng-tuyệt-đối và rỗng-một-ngăn
  - mobile build/type-check/static-analysis: `flutter analyze lib test`
  - visual inspection: ảnh chụp trạng thái rỗng Phút-1
- Required checks:
  - Widget test: kho rỗng render đúng 2 CTA và **không** render `TextFormField`
    onboarding nào ngoài ô URL đã mô tả.
  - Widget test: chạm lời mời → kho có thẻ, không màn trung gian đòi thêm trường.
  - Widget test: dải 3 ô luôn có 3 phần tử, không badge.
- Mobile discoverability / navigation integration: dải 3 ô và nút "+" hiện đúng
  theo trạng thái kho.
- Minimum gates by risk surface: hai risk surface ở §1B đều có gate ở trên.
- Evidence format: output `flutter test` + ảnh chụp màn, ghi vào `coding-plan/test-results.md`.
- Per-story visual fidelity: REQUIRED
  - Design screen id + cách render: implementer phát hiện và khoá id theo
    `contracts/design-fidelity-spec.md`, render bằng
    `capture-mobile-screen.sh --mode=design`.
  - Cách chụp màn đã hiện thực: `capture-mobile-screen.sh`.
  - NOTE: gate của chính story này, không hoãn sang audit cấp requirement; không
    tới được runtime thì block bằng `MOBILE_RUNTIME_UNAVAILABLE`.
- Verification strategy:
  - Targeted tests: `flutter test test/features/activity_cards/`
  - Build/type-check: `flutter analyze lib test`
  - Required assertion evidence: tên test + kết quả pass, kèm ảnh chụp so sánh.

## 7. Status

- Status: COMPLETE
- Last updated: 2026-09-08
- Evidence: `coding-plan/test-results.md` (mục "Phase P5"),
  `visual-fidelity/visual-fidelity-report.md` §7
- Ghi chú: ba widget đã xong và đã kiểm thử nhưng chưa gắn vào
  `activity_card_hub_view.dart` (ngoài write scope pha này) — xem "Khoảng hở
  còn lại" trong `test-results.md`.
